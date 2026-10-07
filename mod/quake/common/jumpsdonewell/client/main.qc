void JumpsDoneWell_Init()
{
	if(gametype != GAMETYPE_JUMPSDONEWELL)
		return;

	cvar_settemp("chase_active", "1");
	cvar_settemp("chase_back", "0");
	cvar_settemp("chase_up", "0");
}

NET_HANDLE(TE_CSQC_TELEFADE, bool isNew)
{
	telefade_time = 1;
	return true;
}

NET_HANDLE(TE_CSQC_ITEMPICKUP_JDW, bool isNew)
{
	int whichitem = ReadByte();
	string centerprint_msg = "";
	switch(whichitem)
	{
		case 1: centerprint_msg = "Maximum health increased!"; break;
		case 2: centerprint_msg = "Mid-air jumps increased!"; break;
		case 3: centerprint_msg = "New attack obtained!"; break;
		default:
		case 4: centerprint_msg = "Checkpoint reached!"; break;
	}
	centerprint_Add(0, centerprint_msg, 3, 0);
	return true;
}

NET_HANDLE(TE_CSQC_REVIVE, bool isNew)
{
	revive_time = 1;
	return true;
}

NET_HANDLE(TE_CSQC_END1, bool isNew)
{
	which_end = 1;
	end_time = 10;
	string line1 = "Congratulations!\n";
	string line2 = "But you haven't found\n";
	string line3 = "many hearts...";

	centerprint_Add(0, strcat(line1, line2, line3), 10, 0);
	return true;
}

NET_HANDLE(TE_CSQC_END2, bool isNew)
{
	which_end = 2;
	end_time = 10;
	string line1 = "Congratulations!\n";
	string line2 = "You found the...\n";
	string line3 = "TRUE ENDING!!";

	centerprint_Add(0, strcat(line1, line2, line3), 10, 0);
	return true;
}

void bamboo_draw(entity this)
{
	this.alpha = (this.origin.x - (playerx - 30)) * 0.015;
	this.modelindex = (this.alpha < 0.01) ? 0 : this.modelindex;
}

NET_HANDLE(ENT_CLIENT_BAMBOO, bool isnew)
{
	this.origin = ReadVector();
	setorigin(this, this.origin);
	_setmodel(this, "models/bamboo2.iqm");
	this.draw = bamboo_draw;
	if(isnew) IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	return = true;
}
