module tsf

$if linux {
	#flag -lm
}

$if macos {
	#flag -lm
}

$if vorbis ? {
	#include "@VMODROOT/stb_vorbis.c"
}

#flag -D TSF_IMPLEMENTATION
#include "@VMODROOT/TinySoundFont/tsf.h"

#flag -D TML_IMPLEMENTATION
#include "@VMODROOT/TinySoundFont/tml.h"
