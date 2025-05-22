module main

import irishgreencitrus.raylibv as ray
import tsf

const minimal_soundfont = [u8(`R`), `I`, `F`, `F`, 220, 1, 0, 0, `s`, `f`, `b`, `k`, `L`, `I`,
	`S`, `T`, 88, 1, 0, 0, `p`, `d`, `t`, `a`, `p`, `h`, `d`, `r`, 76, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 255, 0, 1, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, `p`, `b`, `a`, `g`, 8, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, `p`,
	`m`, `o`, `d`, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, `p`, `g`, `e`, `n`, 8, 0, 0, 0, 41,
	0, 0, 0, 0, 0, 0, 0, `i`, `n`, `s`, `t`, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
	`i`, `b`, `a`, `g`, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, `i`, `m`, `o`, `d`, 10, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, `i`, `g`, `e`, `n`, 12, 0, 0, 0, 54, 0, 1, 0, 53, 0, 0, 0, 0, 0,
	0, 0, `s`, `h`, `d`, `r`, 92, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0, 49, 0, 0, 0, 34, 86, 0, 0, 60, 0, 0, 0, 1, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, `L`, `I`, `S`, `T`, 112, 0, 0, 0, `s`, `d`, `t`,
	`a`, `s`, `m`, `p`, `l`, 100, 0, 0, 0, 86, 0, 119, 3, 31, 7, 147, 10, 43, 14, 169, 17, 58,
	21, 189, 24, 73, 28, 204, 31, 73, 35, 249, 38, 46, 42, 71, 46, 250, 48, 150, 53, 242, 55, 126,
	60, 151, 63, 108, 66, 126, 72, 207, 70, 86, 83, 100, 72, 74, 100, 163, 39, 241, 163, 59, 175,
	59, 179, 9, 179, 134, 187, 6, 186, 2, 194, 5, 194, 15, 200, 6, 202, 96, 206, 159, 209, 35,
	213, 213, 216, 45, 220, 221, 223, 76, 227, 221, 230, 91, 234, 242, 237, 105, 241, 8, 245, 118,
	248, 32, 252]!

const screen_width = 800
const screen_height = 450
const samples = 4096

@[heap]
pub struct App {
pub mut:
	tiny_sound_font &tsf.Tsf
}

fn (mut app App) audio_callback(buffer voidptr, frames u32) {
	app.tiny_sound_font.render_short(buffer, int(frames), false)
}

type RaylibAudioCallback = fn (buffer voidptr, frames u32)

fn main() {
	// Load the SoundFont from the memory block
	mut app := App{
		tiny_sound_font: tsf.Tsf.load_memory(&minimal_soundfont, minimal_soundfont.len)
	}
	if isnil(app.tiny_sound_font) {
		panic('Could not load soundfont')
	}

	// mut file := os.open_file('minimal_soundfont.sf2', 'w+', 0o666) or { panic(err) }
	// wrote := unsafe { file.write_ptr(&minimal_soundfont, minimal_soundfont.len) }
	// println('write_bytes: ${wrote} [./minimal_soundfont.sf2]')
	// file.flush()
	// file.close()

	ray.set_trace_log_level(ray.log_error)
	ray.init_window(screen_width, screen_height, c'raylib and TinySoundFont in V')

	// Initialize the audio system
	ray.init_audio_device()
	ray.set_audio_stream_buffer_size_default(samples)
	stream := ray.load_audio_stream(44100, 16, 2)

	// Init raw audio stream (sample rate: 44100, sample size: 16bit-short, channels: 2)
	app.tiny_sound_font.set_output(.stereo_interleaved, 44100, -10)
	audio_closure := RaylibAudioCallback(app.audio_callback)
	ray.set_audio_stream_callback(stream, audio_closure)

	// Start processing stream buffer (no data loaded currently)
	ray.play_audio_stream(stream)

	// this is the default, but this is how you would change it
	ray.set_exit_key(ray.key_escape)

	ray.set_target_fps(30)

	gc_disable() // needed to avoid `Collecting from unknown thread` aborts while the sound is playing
	for !ray.window_should_close() {
		if ray.is_key_pressed(ray.key_q) {
			app.tiny_sound_font.note_on(0, 48, 1) // C2
			app.tiny_sound_font.note_on(0, 52, 1) // E2
		}
		if ray.is_key_released(ray.key_q) {
			app.tiny_sound_font.note_off(0, 48)
			app.tiny_sound_font.note_off(0, 52)
		}
		ray.begin_drawing()
		ray.clear_background(ray.raywhite)
		ray.draw_text(c'Press the q key to play sounds', 10, 10, 20, ray.darkgray)
		ray.end_drawing()
	}
	ray.unload_audio_stream(stream)
	ray.close_audio_device()
	ray.close_window()
}
