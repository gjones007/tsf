module main

import os
import tsf
import time
import sokol.audio

@[heap]
struct App {
pub mut:
	msec            f64              // current playback time
	tiny_sound_font &tsf.Tsf         // Holds the global instance pointer
	midi_message    &tsf.Tml_message // next midi_message to be played
}

fn audio_callback(stream &f32, num_frames int, num_channels int, mut app App) {
	print('\r>>> app.msec: ${app.msec:10.3f}ms')
	// Number of samples to process
	mut sample_block := int(tsf.tsf_render_effect_sample_block)
	mut sample_count := num_frames
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
		off += sample_block * num_channels
	}
}

fn main() {
	unbuffer_stdout()
	soundfont_file := os.join_path('..', 'TinySoundFont', 'examples', 'florestan-subset.sf2')
	midi_file := os.join_path('..', 'TinySoundFont', 'examples', 'venture.mid')
	mut app := &App{
		tiny_sound_font: tsf.Tsf.load_filename(soundfont_file)
		midi_message:    tsf.Tml.load_filename(midi_file)
	}
	audio.setup(
		stream_userdata_cb: audio_callback
		sample_rate:        44100
		buffer_frames:      4096
		num_channels:       2
		user_data:          app
	)
	app.tiny_sound_font.channel_set_bank_preset(9, 128, 0)
	app.tiny_sound_font.set_output(.stereo_interleaved, 44100, 0)
	println('Playing ${midi_file} ...')
	for !isnil(app.midi_message) {
		time.sleep(100 * time.millisecond)
	}
	println('\ndone')
}
