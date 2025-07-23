module main

import sdl
import tsf
import os

@[heap]
struct App {
mut:
	tiny_sound_font &tsf.Tsf
	mutex           &sdl.Mutex
	stream          &sdl.AudioStream = unsafe { nil }
	buffer          voidptr
}

fn (mut app App) audio_callback(stream &sdl.AudioStream, additional_amount int, total_amount int) {
	sample_count := int(total_amount / int(2 * sizeof(f32)))
	sdl.lock_mutex(app.mutex)
	app.tiny_sound_font.render_float(app.buffer, sample_count, false)
	sdl.put_audio_stream_data(stream, app.buffer, total_amount)
	sdl.unlock_mutex(app.mutex)
}

fn main() {
	notes := [48, 50, 52, 53, 55, 57, 59]!

	// Load the SoundFont from a file
	// Create the mutex
	mut app := App{
		tiny_sound_font: tsf.Tsf.load_filename(os.join_path('..', '..', 'TinySoundFont',
			'examples', 'florestan-subset.sf2'))
		mutex:           sdl.create_mutex()
	}
	if isnil(app.tiny_sound_font) {
		panic('Could not load soundfont')
	}

	// Define the desired audio output format we request
	output_audio_spec := sdl.AudioSpec{
		freq:     44100
		format:   sdl.AudioFormat._f32_1
		channels: 2
	}

	// Initialize the audio system
	if !sdl.init(sdl.init_audio) {
		panic('Could not initialize audio hardware or driver')
	}

	// Set the SoundFont rendering output mode
	app.tiny_sound_font.set_output(.stereo_interleaved, output_audio_spec.freq, 0)

	// Request the desired audio output format
	app.stream = sdl.open_audio_device_stream(sdl.audio_device_default_playback, &output_audio_spec,
		app.audio_callback, &app)

	if app.stream == sdl.null {
		panic('Could not open the audio hardware or the desired audio output format')
	}

	app.buffer = unsafe { malloc(4096) }

	sdl.resume_audio_device(sdl.get_audio_stream_device(app.stream))

	// Loop through all the presets in the loaded SoundFont
	for i in 0 .. app.tiny_sound_font.get_presetcount() {
		// Get exclusive mutex lock, end the previous note and play a new note
		println("Play note ${notes[i % 7]} with preset #${i} '${app.tiny_sound_font.get_presetname(i)}'")
		sdl.lock_mutex(app.mutex)
		if i > 0 {
			app.tiny_sound_font.note_off(i - 1, notes[(i - 1) % 7])
		}
		app.tiny_sound_font.note_on(i, notes[i % 7], 1)
		sdl.unlock_mutex(app.mutex)
		sdl.delay(1000)
	}
	// We could call tsf_close(g_TinySoundFont) and SDL_DestroyMutex(g_Mutex)
	// here to free the memory and resources but we just let the OS clean up
	// because the process ends here.
}
