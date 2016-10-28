// required engine functions

bool oldjump;
void CSQC_Init()
{
	// needs to be done so early because of the constants they create
	static_init();
	static_init_late();
	static_init_precache();

	oldjump = cvar("cl_movement_track_canjump");
	cvar_set("cl_movement_track_canjump", "1");

	localcmd("\ncd remap track001 track002 track003 track004 track005 track006 track007 track008 track009 track010 track011\n");
}

void CSQC_Shutdown()
{
	cvar_set("cl_movement_track_canjump", ftos(oldjump));
	localcmd(sprintf("\ncd remap %s\n", cvar_string("g_cdtracks_remaplist")));
}

void CSQC_UpdateView(entity this, float w, float h)
{
	// ALWAYS Clear Current Scene First
	clearscene();

	// Assign Standard Viewflags
	// Draw the World (and sky)
	setproperty(VF_DRAWWORLD, 1);

	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 1);

	// Draw the Engine Status Bar (the default Quake HUD)
	setproperty(VF_DRAWENGINESBAR, 1);

	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	renderscene();
}

bool CSQC_InputEvent(int inputType, float nPrimary, float nSecondary)
{
	return false;
}

bool CSQC_ConsoleCommand(string s)
{
	return false;
}

void CSQC_Ent_Update(entity this, bool isNew)
{

}

void CSQC_Ent_Remove(entity this)
{

}
