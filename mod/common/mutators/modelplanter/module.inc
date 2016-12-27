#ifndef IMPLEMENTATION
#ifndef MENUQC
	#include "modelplanter.qh"
#endif
#endif

#ifdef SVQC
	#include "modelplanter.qc"
#elif defined(CSQC)
#ifdef IMPLEMENTATION
	#include "mplant/client.qc"
	#include "mplant/networking.qc"
#endif
#endif
