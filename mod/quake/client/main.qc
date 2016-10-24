// required engine functions

void CSQC_Init()
{

}

void CSQC_Shutdown()
{

}

void CSQC_UpdateView(entity this, float w, float h)
{
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
