#include "radio.qh"

#if defined(SVQC)
	#include "sv_radio.qc"
#elif defined(CSQC)
	#include "cl_radio.qc"
#endif
