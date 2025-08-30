AUTOCVAR_NOREF_SAVE(cl_nocarry, bool, false, "Prevent players from riding you in the piggyback mutator, requires reconnect or sendcvar");
AUTOCVAR_NOREF_SAVE(cl_noride, bool, false, "Disable riding others in the piggyback mutator, requires reconnect or sendcvar");


// networked cvars
bool cvar_cl_nocarry;
bool cvar_cl_noride;
REPLICATE(cvar_cl_nocarry, bool, "cl_nocarry");
REPLICATE(cvar_cl_noride, bool, "cl_noride");
