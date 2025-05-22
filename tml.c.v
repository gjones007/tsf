module tsf

pub enum MessageType {
	note_off         = C.TML_NOTE_OFF
	note_on          = C.TML_NOTE_ON
	key_pressure     = C.TML_KEY_PRESSURE
	control_change   = C.TML_CONTROL_CHANGE
	program_change   = C.TML_PROGRAM_CHANGE
	channel_pressure = C.TML_CHANNEL_PRESSURE
	pitch_bend       = C.TML_PITCH_BEND
	set_tempo        = C.TML_SET_TEMPO
}

pub enum TMLController {
	bank_select_msb
	modulationwheel_msb
	breath_msb
	foot_msb        = 4
	portamento_time_msb
	data_entry_msb
	volume_msb
	balance_msb
	pan_msb         = 10
	expression_msb
	effects1_msb
	effects2_msb
	gpc1_msb        = 16
	gpc2_msb
	gpc3_msb
	gpc4_msb
	bank_select_lsb = 32
	modulationwheel_lsb
	breath_lsb
	foot_lsb        = 36
	portamento_time_lsb
	data_entry_lsb
	volume_lsb
	balance_lsb
	pan_lsb         = 42
	expression_lsb
	effects1_lsb
	effects2_lsb
	gpc1_lsb        = 48
	gpc2_lsb
	gpc3_lsb
	gpc4_lsb
	sustain_switch  = 64
	portamento_switch
	sostenuto_switch
	soft_pedal_switch
	legato_switch
	hold2_switch
	sound_ctrl1
	sound_ctrl2
	sound_ctrl3
	sound_ctrl4
	sound_ctrl5
	sound_ctrl6
	sound_ctrl7
	sound_ctrl8
	sound_ctrl9
	sound_ctrl10
	gpc5
	gpc6
	gpc7
	gpc8
	portamento_ctrl
	fx_reverb       = 91
	fx_tremolo
	fx_chorus
	fx_celeste_detune
	fx_phaser
	data_entry_incr
	data_entry_decr
	nrpn_lsb
	nrpn_msb
	rpn_lsb
	rpn_msb
	all_sound_off   = 120
	all_ctrl_off
	local_control
	all_notes_off
	omni_off
	omni_on
	poly_off
	poly_on
}

pub struct C.Tml_stream {
	data voidptr
	read FnReadCb
}

pub type Tml_stream = C.Tml_stream

pub struct C.tml_message {
pub:
	time    u32
	@type   MessageType
	channel u8
	// These members are part of sub data structures that can't currently be represented in V.
	// Declaring them directly like this is sufficient for access.
	// union {
	// struct {
	key              u8
	control          u8
	program          u8
	channel_pressure u8
	// }
	// struct {
	velocity      u8
	key_pressure  u8
	control_value u8
	// }
	// }
	// struct {
	pitch_bend u16
	// }
	next &C.tml_message
}

pub type Tml_message = C.tml_message

pub struct Tml {}

fn C.tml_load_filename(filename &i8) &C.tml_message
@[inline]
pub fn Tml.load_filename(filename string) &Tml_message {
	return C.tml_load_filename(filename.str)
}

fn C.tml_load_memory(buffer voidptr, size int) &C.tml_message
@[inline]
pub fn Tml.load_memory(buffer voidptr, size int) &Tml_message {
	return C.tml_load_memory(buffer, size)
}

fn C.tml_get_info(first_message &C.tml_message, used_channels &int, used_programs &int, total_notes &int, time_first_note &u32, time_length &u32) int
@[inline]
pub fn (first_message &Tml_message) get_info(used_channels &int, used_programs &int, total_notes &int, time_first_note &u32, time_length &u32) int {
	return C.tml_get_info(first_message, used_channels, used_programs, total_notes, time_first_note,
		time_length)
}

fn C.tml_get_tempo_value(tempo_message &C.tml_message) int
@[inline]
pub fn (tempo_message &Tml_message) get_tempo_value() int {
	return C.tml_get_tempo_value(tempo_message)
}

fn C.tml_free(f &C.tml_message)
@[inline]
pub fn (f &Tml_message) free() {
	C.tml_free(f)
}

fn C.tml_load(stream &C.Tml_stream) &C.tml_message
@[inline]
pub fn tml_load(stream &Tml_stream) &Tml_message {
	return C.tml_load(stream)
}

fn C.tml_load_tsf_stream(stream &Tsf_stream) &C.tml_message
@[inline]
pub fn tml_load_tsf_stream(stream &Tsf_stream) &Tml_message {
	return C.tml_load_tsf_stream(stream)
}
