module tsf

$if linux {
	#flag -lm
}

$if macos {
	#flag -lm
}

#flag '-DTSF_IMPLEMENTATION'
#include "@VMODROOT/TinySoundFont/tsf.h"

#flag '-DTML_IMPLEMENTATION'
#include "@VMODROOT/TinySoundFont/tml.h"
