module tsf

pub const (
	tsf_render_effect_sample_block = C.TSF_RENDER_EFFECTSAMPLEBLOCK
	tsf_render_short_buffer_block  = C.TSF_RENDER_SHORTBUFFERBLOCK
	tsf_fast_release_time          = C.TSF_FASTRELEASETIME
)

pub type FnReadCb = fn (fd voidptr, buf voidptr, count u32) int

pub type FnSkipCb = fn (data voidptr, count u32) int

struct C.Tsf_region {
	loop_mode        int
	sample_rate      u32
	lokey            u8
	hikey            u8
	lovel            u8
	hivel            u8
	group            u32
	offset           u32
	end              u32
	loop_start       u32
	loop_end         u32
	transpose        int
	tune             int
	pitch_keycenter  int
	pitch_keytrack   int
	attenuation      f32
	pan              f32
	ampenv           Tsf_envelope
	modenv           Tsf_envelope
	initialFilterQ   int
	initialFilterFc  int
	modEnvToPitch    int
	modEnvToFilterFc int
	modLfoToFilterFc int
	modLfoToVolume   int
	delayModLFO      f32
	freqModLFO       int
	modLfoToPitch    int
	delayVibLFO      f32
	freqVibLFO       int
	vibLfoToPitch    int
}

pub type Tsf_region = C.Tsf_region

struct C.Tsf_riffchunk {
	id   [4]i8
	size u32
}

pub type Tsf_riffchunk = C.Tsf_riffchunk

struct C.Tsf_envelope {
	delay         f32
	attack        f32
	hold          f32
	decay         f32
	sustain       f32
	release       f32
	keynumToHold  f32
	keynumToDecay f32
}

pub type Tsf_envelope = C.Tsf_envelope

struct C.Tsf_voice_envelope {
	level                   f32
	slope                   f32
	samplesUntilNextSegment int
	segment                 i16
	midiVelocity            i16
	parameters              Tsf_envelope
	segmentIsExponential    i8
	isAmpEnv                i8
}

pub type Tsf_voice_envelope = C.Tsf_voice_envelope

struct C.Tsf_voice_lowpass {
	QInv   f64
	a0     f64
	a1     f64
	b1     f64
	b2     f64
	z1     f64
	z2     f64
	active i8
}

pub type Tsf_voice_lowpass = C.Tsf_voice_lowpass

struct C.Tsf_voice_lfo {
	samplesUntil int
	level        f32
	delta        f32
}

pub type Tsf_voice_lfo = C.Tsf_voice_lfo

struct C.Tsf_preset {
	presetName [20]i8
	preset     u16
	bank       u16
	regions    &Tsf_region
	regionNum  int
}

pub type Tsf_preset = C.Tsf_preset

struct C.Tsf_voice {
	playingPreset        int
	playingKey           int
	playingChannel       int
	region               &Tsf_region
	pitchInputTimecents  f64
	pitchOutputFactor    f64
	sourceSamplePosition f64
	noteGainDB           f32
	panFactorLeft        f32
	panFactorRight       f32
	playIndex            u32
	loopStart            u32
	loopEnd              u32
	ampenv               Tsf_voice_envelope
	modenv               Tsf_voice_envelope
	lowpass              Tsf_voice_lowpass
	modlfo               Tsf_voice_lfo
	viblfo               Tsf_voice_lfo
}

pub type Tsf_voice = C.Tsf_voice

struct C.Tsf_channel {
	presetIndex    u16
	bank           u16
	pitchWheel     u16
	midiPan        u16
	midiVolume     u16
	midiExpression u16
	midiRPN        u16
	midiData       u16
	panOffset      f32
	gainDB         f32
	pitchRange     f32
	tuning         f32
}

struct C.Tsf_channels {
	setupVoice    fn (&Tsf, &Tsf_voice)
	channelNum    int
	activeChannel int
	// channels      [1]Tsf_channel
	channels Tsf_channel
}

pub type Tsf_channels = C.Tsf_channels
pub type Tsf_channel = C.Tsf_channel

pub struct C.Tsf {
	presets        &Tsf_preset
	fontSamples    &f32
	voices         &Tsf_voice
	channels       &Tsf_channels
	presetNum      int
	voiceNum       int
	maxVoiceNum    int
	voicePlayIndex u32
	outputmode     TSFOutputMode
	outSampleRate  f32
	globalGainDB   f32
	refCount       &int
}

pub type Tsf = C.Tsf

pub struct C.Tsf_stream {
	data voidptr
	read FnReadCb
	skip FnSkipCb
}

pub type Tsf_stream = C.Tsf_stream

pub enum TSFOutputMode {
	stereo_interleaved
	stereo_unweaved
	mono
}

fn C.tsf_load_filename(filename &i8) &C.Tsf
[inline]
pub fn Tsf.load_filename(filename string) &Tsf {
	return C.tsf_load_filename(filename.str)
}

fn C.tsf_load_memory(buffer voidptr, size int) &C.Tsf
[inline]
pub fn Tsf.load_memory(buffer voidptr, size int) &Tsf {
	return C.tsf_load_memory(buffer, size)
}

fn C.tsf_load(stream &Tsf_stream) &C.Tsf
[inline]
pub fn (mut f Tsf) load(stream &Tsf_stream) &Tsf {
	return C.tsf_load(stream)
}

fn C.tsf_copy(f &Tsf) &C.Tsf
[inline]
pub fn (mut f Tsf) copy() &Tsf {
	return C.tsf_copy(f)
}

fn C.tsf_close(f &Tsf)
[inline]
pub fn (mut f Tsf) close() {
	C.tsf_close(f)
}

fn C.tsf_reset(f &Tsf)
[inline]
pub fn (mut f Tsf) reset() {
	C.tsf_reset(f)
}

fn C.tsf_get_presetindex(f &Tsf, bank int, preset_number int) int
[inline]
pub fn (mut f Tsf) get_presetindex(bank int, preset_number int) int {
	return C.tsf_get_presetindex(f, bank, preset_number)
}

fn C.tsf_get_presetcount(f &Tsf) int
[inline]
pub fn (mut f Tsf) get_presetcount() int {
	return C.tsf_get_presetcount(f)
}

fn C.tsf_get_presetname(f &Tsf, preset_index int) &char
[inline]
pub fn (mut f Tsf) get_presetname(preset_index int) string {
	unsafe {
		return cstring_to_vstring(C.tsf_get_presetname(f, preset_index))
	}
}

fn C.tsf_bank_get_presetname(f &Tsf, bank int, preset_number int) &char
[inline]
pub fn (mut f Tsf) bank_get_presetname(bank int, preset_number int) string {
	unsafe {
		return cstring_to_vstring(C.tsf_bank_get_presetname(f, bank, preset_number))
	}
}

fn C.tsf_set_output(f &Tsf, outputmode TSFOutputMode, samplerate int, global_gain_db f32)
[inline]
pub fn (mut f Tsf) set_output(outputmode TSFOutputMode, samplerate int, global_gain_db f32) {
	C.tsf_set_output(f, outputmode, samplerate, global_gain_db)
}

fn C.tsf_set_volume(f &Tsf, global_gain f32)
[inline]
pub fn (mut f Tsf) set_volume(global_gain f32) {
	C.tsf_set_volume(f, global_gain)
}

fn C.tsf_set_max_voices(f &Tsf, max_voices int) int
[inline]
pub fn (mut f Tsf) set_max_voices(max_voices int) int {
	return C.tsf_set_max_voices(f, max_voices)
}

fn C.tsf_note_on(f &Tsf, preset_index int, key int, vel f32) int
[inline]
pub fn (mut f Tsf) note_on(preset_index int, key int, vel f32) int {
	return C.tsf_note_on(f, preset_index, key, vel)
}

fn C.tsf_bank_note_on(f &Tsf, bank int, preset_number int, key int, vel f32) int
[inline]
pub fn (mut f Tsf) bank_note_on(bank int, preset_number int, key int, vel f32) int {
	return C.tsf_bank_note_on(f, bank, preset_number, key, vel)
}

fn C.tsf_note_off(f &Tsf, preset_index int, key int)
[inline]
pub fn (mut f Tsf) note_off(preset_index int, key int) {
	C.tsf_note_off(f, preset_index, key)
}

fn C.tsf_bank_note_off(f &Tsf, bank int, preset_number int, key int) int
[inline]
pub fn (mut f Tsf) bank_note_off(bank int, preset_number int, key int) int {
	return C.tsf_bank_note_off(f, bank, preset_number, key)
}

fn C.tsf_note_off_all(f &Tsf)
[inline]
pub fn (mut f Tsf) note_off_all() {
	C.tsf_note_off_all(f)
}

fn C.tsf_active_voice_count(f &Tsf) int
[inline]
pub fn (mut f Tsf) active_voice_count() int {
	return C.tsf_active_voice_count(f)
}

fn C.tsf_render_short(f &Tsf, buffer &i16, samples int, flag_mixing bool)
[inline]
pub fn (mut f Tsf) render_short(buffer &i16, samples int, flag_mixing bool) {
	C.tsf_render_short(f, buffer, samples, flag_mixing)
}

fn C.tsf_render_float(f &Tsf, buffer &f32, samples int, flag_mixing bool)
[inline]
pub fn (mut f Tsf) render_float(buffer &f32, samples int, flag_mixing bool) {
	C.tsf_render_float(f, buffer, samples, flag_mixing)
}

fn C.tsf_channel_set_presetindex(f &Tsf, channel int, preset_index int) int
[inline]
pub fn (mut f Tsf) channel_set_presetindex(channel int, preset_index int) int {
	return C.tsf_channel_set_presetindex(f, channel, preset_index)
}

fn C.tsf_channel_set_presetnumber(f &Tsf, channel int, preset_number int, flag_mididrums bool) int
[inline]
pub fn (mut f Tsf) channel_set_presetnumber(channel int, preset_number int, flag_mididrums bool) int {
	return C.tsf_channel_set_presetnumber(f, channel, preset_number, flag_mididrums)
}

fn C.tsf_channel_set_bank(f &Tsf, channel int, bank int) int
[inline]
pub fn (mut f Tsf) channel_set_bank(channel int, bank int) int {
	return C.tsf_channel_set_bank(f, channel, bank)
}

fn C.tsf_channel_set_bank_preset(f &Tsf, channel int, bank int, preset_number int) int
[inline]
pub fn (mut f Tsf) channel_set_bank_preset(channel int, bank int, preset_number int) int {
	return C.tsf_channel_set_bank_preset(f, channel, bank, preset_number)
}

fn C.tsf_channel_set_pan(f &Tsf, channel int, pan f32) int
[inline]
pub fn (mut f Tsf) channel_set_pan(channel int, pan f32) int {
	return C.tsf_channel_set_pan(f, channel, pan)
}

fn C.tsf_channel_set_volume(f &Tsf, channel int, volume f32) int
[inline]
pub fn (mut f Tsf) channel_set_volume(channel int, volume f32) int {
	return C.tsf_channel_set_volume(f, channel, volume)
}

fn C.tsf_channel_set_pitchwheel(f &Tsf, channel int, pitch_wheel int) int
[inline]
pub fn (mut f Tsf) channel_set_pitchwheel(channel int, pitch_wheel int) int {
	return C.tsf_channel_set_pitchwheel(f, channel, pitch_wheel)
}

fn C.tsf_channel_set_pitchrange(f &Tsf, channel int, pitch_range f32) int
[inline]
pub fn (mut f Tsf) channel_set_pitchrange(channel int, pitch_range f32) int {
	return C.tsf_channel_set_pitchrange(f, channel, pitch_range)
}

fn C.tsf_channel_set_tuning(f &Tsf, channel int, tuning f32) int
[inline]
pub fn (mut f Tsf) channel_set_tuning(channel int, tuning f32) int {
	return C.tsf_channel_set_tuning(f, channel, tuning)
}

fn C.tsf_channel_note_on(f &Tsf, channel int, key int, vel f32) int
[inline]
pub fn (mut f Tsf) channel_note_on(channel int, key int, vel f32) int {
	return C.tsf_channel_note_on(f, channel, key, vel)
}

fn C.tsf_channel_note_off(f &Tsf, channel int, key int)
[inline]
pub fn (mut f Tsf) channel_note_off(channel int, key int) {
	C.tsf_channel_note_off(f, channel, key)
}

fn C.tsf_channel_note_off_all(f &Tsf, channel int)
[inline]
pub fn (mut f Tsf) channel_note_off_all(channel int) {
	C.tsf_channel_note_off_all(f, channel)
}

fn C.tsf_channel_sounds_off_all(f &Tsf, channel int)
[inline]
pub fn (mut f Tsf) channel_sounds_off_all(channel int) {
	C.tsf_channel_sounds_off_all(f, channel)
}

fn C.tsf_channel_midi_control(f &Tsf, channel int, controller int, control_value int) int
[inline]
pub fn (mut f Tsf) channel_midi_control(channel int, controller int, control_value int) int {
	return C.tsf_channel_midi_control(f, channel, controller, control_value)
}

fn C.tsf_channel_get_preset_index(f &Tsf, channel int) int
[inline]
pub fn (mut f Tsf) channel_get_preset_index(channel int) int {
	return C.tsf_channel_get_preset_index(f, channel)
}

fn C.tsf_channel_get_preset_bank(f &Tsf, channel int) int
[inline]
pub fn (mut f Tsf) channel_get_preset_bank(channel int) int {
	return C.tsf_channel_get_preset_bank(f, channel)
}

fn C.tsf_channel_get_preset_number(f &Tsf, channel int) int
[inline]
pub fn (mut f Tsf) channel_get_preset_number(channel int) int {
	return C.tsf_channel_get_preset_number(f, channel)
}

fn C.tsf_channel_get_pan(f &Tsf, channel int) f32
[inline]
pub fn (mut f Tsf) channel_get_pan(channel int) f32 {
	return C.tsf_channel_get_pan(f, channel)
}

fn C.tsf_channel_get_volume(f &Tsf, channel int) f32
[inline]
pub fn (mut f Tsf) channel_get_volume(channel int) f32 {
	return C.tsf_channel_get_volume(f, channel)
}

fn C.tsf_channel_get_pitchwheel(f &Tsf, channel int) int
[inline]
pub fn (mut f Tsf) channel_get_pitchwheel(channel int) int {
	return C.tsf_channel_get_pitchwheel(f, channel)
}

fn C.tsf_channel_get_pitchrange(f &Tsf, channel int) f32
[inline]
pub fn (mut f Tsf) channel_get_pitchrange(channel int) f32 {
	return C.tsf_channel_get_pitchrange(f, channel)
}

fn C.tsf_channel_get_tuning(f &Tsf, channel int) f32
[inline]
pub fn (mut f Tsf) channel_get_tuning(channel int) f32 {
	return C.tsf_channel_get_tuning(f, channel)
}
