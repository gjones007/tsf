module main

import sdl
import tsf

const (
	minimal_soundfont = [u8(`R`), `I`, `F`, `F`, 220, 1, 0, 0, `s`, `f`, `b`, `k`, `L`, `I`, `S`,
		`T`, 88, 1, 0, 0, `p`, `d`, `t`, `a`, `p`, `h`, `d`, `r`, 76, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 255, 0, 1,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, `p`, `b`, `a`, `g`, 8, 0, 0, 0, 0, 0, 0, 0, 1, 0,
		0, 0, `p`, `m`, `o`, `d`, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, `p`, `g`, `e`, `n`,
		8, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, `i`, `n`, `s`, `t`, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 1, 0, `i`, `b`, `a`, `g`, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, `i`,
		`m`, `o`, `d`, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, `i`, `g`, `e`, `n`, 12, 0, 0,
		0, 54, 0, 1, 0, 53, 0, 0, 0, 0, 0, 0, 0, `s`, `h`, `d`, `r`, 92, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0, 49, 0,
		0, 0, 34, 86, 0, 0, 60, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, `L`, `I`, `S`, `T`, 112, 0, 0, 0, `s`, `d`, `t`, `a`, `s`, `m`, `p`, `l`, 100, 0, 0,
		0, 86, 0, 119, 3, 31, 7, 147, 10, 43, 14, 169, 17, 58, 21, 189, 24, 73, 28, 204, 31, 73,
		35, 249, 38, 46, 42, 71, 46, 250, 48, 150, 53, 242, 55, 126, 60, 151, 63, 108, 66, 126,
		72, 207, 70, 86, 83, 100, 72, 74, 100, 163, 39, 241, 163, 59, 175, 59, 179, 9, 179, 134,
		187, 6, 186, 2, 194, 5, 194, 15, 200, 6, 202, 96, 206, 159, 209, 35, 213, 213, 216, 45,
		220, 221, 223, 76, 227, 221, 230, 91, 234, 242, 237, 105, 241, 8, 245, 118, 248, 32, 252]!
)

[heap]
struct App {
mut:
	tiny_sound_font &tsf.Tsf
}

fn (mut app App) audio_callback(data voidptr, stream &u8, len int) {
	// Note we don't do any thread concurrency control here because in this
	// example all notes are started before the audio playback begins.
	// If you do play notes while the audio thread renders output you
	// will need a mutex of some sort.
	sample_count := int(len / int(2 * sizeof(i16)))
	app.tiny_sound_font.render_short(stream, sample_count, false)
}

fn main() {
	// Load the SoundFont from the memory block
	mut app := App{
		tiny_sound_font: tsf.Tsf.load_memory(&minimal_soundfont, minimal_soundfont.len)
	}
	if isnil(app.tiny_sound_font) {
		panic('Could not load soundfont')
	}

	// Define the desired audio output format we request
	output_audio_spec := sdl.AudioSpec{
		freq: 44100
		format: sdl.audio_s16
		channels: 2
		samples: 4096
		callback: app.audio_callback
	}

	// Initialize the audio system
	if sdl.init(sdl.init_audio) < 0 {
		panic('Could not initialize audio hardware or driver')
	}

	// Set the rendering output mode to 44.1khz and -10 decibel gain
	app.tiny_sound_font.set_output(.stereo_interleaved, output_audio_spec.freq, -10)

	// Start two notes before starting the audio playback
	app.tiny_sound_font.note_on(0, 48, 1) // C2
	app.tiny_sound_font.note_on(0, 52, 1) // E2

	// Request the desired audio output format
	if sdl.open_audio(&output_audio_spec, sdl.null) < 0 {
		panic('Could not open the audio hardware or the desired audio output format')
	}

	// Start the actual audio playback here
	// The audio thread will begin to call our AudioCallback function
	sdl.pause_audio(0)

	// Let the audio callback play some sound for 3 seconds
	sdl.delay(3000)

	// We could call tsf_close(g_TinySoundFont) and SDL_DestroyMutex(g_Mutex)
	// here to free the memory and resources but we just let the OS clean up
	// because the process ends here.
}
