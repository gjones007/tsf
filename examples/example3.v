module main

import sdl
import tsf
import os

[heap]
struct App {
pub mut:
	// current playback time
	msec f64
	// Holds the global instance pointer
	tiny_sound_font &tsf.Tsf
	// next midi_message to be played
	midi_message &tsf.Tml_message
}

// Callback function called by the audio thread
fn (mut app App) audio_callback(data voidptr, stream &u8, len int) {
	// Number of samples to process
	mut sample_block := int(tsf.tsf_render_effect_sample_block)
	mut sample_count := int(len / int(2 * sizeof(f32)))
	mut off := int(0)

	for sample_count != 0 {
		// We progress the MIDI playback and then process TSF_RENDER_EFFECT sample_block samples at once
		if sample_block > sample_count {
			sample_block = sample_count
		}

		// Loop through all MIDI messages which need to be played up until the current playback time
		app.msec += f64(sample_block) * (1000.0 / 44100.0)

		for app.midi_message != 0 && app.msec >= app.midi_message.time {
			match app.midi_message.@type {
				// channel program (preset) change (special handling for 10th MIDI channel with drums)
				.program_change {
					app.tiny_sound_font.channel_set_presetnumber(app.midi_message.channel,
						app.midi_message.program, (app.midi_message.channel == 9))
				}
				// play a note
				.note_on {
					app.tiny_sound_font.channel_note_on(app.midi_message.channel, app.midi_message.key,
						f32(app.midi_message.velocity) / 127.0)
				}
				// stop a note
				.note_off {
					app.tiny_sound_font.channel_note_off(app.midi_message.channel, app.midi_message.key)
				}
				// pitch wheel modification
				.pitch_bend {
					app.tiny_sound_font.channel_set_pitchwheel(app.midi_message.channel,
						app.midi_message.pitch_bend)
				}
				// MIDI controller messages
				.control_change {
					app.tiny_sound_font.channel_midi_control(app.midi_message.channel,
						app.midi_message.control, app.midi_message.control_value)
				}
				else {}
			}
			app.midi_message = app.midi_message.next
		}
		unsafe { app.tiny_sound_font.render_float(&stream[off], sample_block, false) }

		sample_count -= sample_block
		off += sample_block * int(2 * sizeof(f32))
	}
}

fn main() {
	// Load the SoundFont from a file
	// Set up the application midi_message pointer to the first MIDI message
	soundfont_file := os.join_path('..', 'TinySoundFont', 'examples', 'florestan-subset.sf2')
	midi_file := os.join_path('..', 'TinySoundFont', 'examples', 'venture.mid')

	mut app := App{
		tiny_sound_font: tsf.Tsf.load_filename(soundfont_file)
		midi_message: tsf.Tml.load_filename(midi_file)
	}

	if isnil(app.midi_message) {
		panic('Could not load MIDI file')
	}

	if isnil(app.tiny_sound_font) {
		panic('Could not load soundfont')
	}

	// Define the desired audio output format we request
	output_audio_spec := sdl.AudioSpec{
		freq: 44100
		format: sdl.audio_f32
		channels: 2
		samples: 4096
		callback: app.audio_callback
	}

	// Initialize the audio system
	if sdl.init(sdl.init_audio) < 0 {
		panic('Could not initialize audio hardware or driver')
	}

	// Initialize preset on special 10th MIDI channel to use percussion sound bank (128) if available
	app.tiny_sound_font.channel_set_bank_preset(9, 128, 0)

	// Set the SoundFont rendering output mode
	app.tiny_sound_font.set_output(.stereo_interleaved, output_audio_spec.freq, 0)

	// Request the desired audio output format
	if sdl.open_audio(&output_audio_spec, sdl.null) < 0 {
		panic('Could not open the audio hardware or the desired audio output format')
	}

	// Start the actual audio playback here
	// The audio thread will begin to call our AudioCallback function
	sdl.pause_audio(0)

	for !isnil(app.midi_message) {
		sdl.delay(100)
	}
}
