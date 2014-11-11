.float el_editmode;

float el_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_EDITLIGHT);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		WriteCoord(MSG_ENTITY, self.colormod_x);
		WriteCoord(MSG_ENTITY, self.colormod_y);
		WriteCoord(MSG_ENTITY, self.colormod_z);

		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		WriteShort(MSG_ENTITY, self.cnt);
	}

	if(sf & 2)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}

	if(sf & 4)
	{
		WriteCoord(MSG_ENTITY, self.colormod_x);
		WriteCoord(MSG_ENTITY, self.colormod_y);
		WriteCoord(MSG_ENTITY, self.colormod_z);
	}

	if(sf & 8)
	{
		WriteShort(MSG_ENTITY, self.cnt);
	}

	return TRUE;
}

.vector el_oldorig;
.vector el_oldcolor;
.float el_oldcnt;
.float el_oldeditmode;
void el_Think()
{
	self.nextthink = time;

	if(self.origin != self.el_oldorig)
	{
		self.el_oldorig = self.origin;
		self.SendFlags |= 2;
	}

	if(self.cnt != self.el_oldcnt)
	{
		self.el_oldcnt = self.cnt;
		self.SendFlags |= 8;
	}

	if(self.colormod != self.el_oldcolor)
	{
		self.el_oldcolor = self.colormod;
		self.SendFlags |= 4;
	}
}

float el_Customize()
{
	entity e = WaypointSprite_getviewentity(other);
	return (e.el_editmode);
}

MUTATOR_HOOKFUNCTION(el_ClientCommand)
{
	if(cmd_name == "editlights")
	{
		if(argv(1) == "spawn")
		{
			if(!self.el_editmode) { sprint(self, "You cannot spawn lights\n"); return TRUE; }
			WarpZone_TraceLine(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 100, MOVE_NORMAL, self);
			entity e = spawn();
			e.classname = "editlights";
			e.realowner = self;
			e.grab = 3;
			if(argv(4))
			{
				e.colormod_x = stof(argv(2));
				e.colormod_y = stof(argv(3));
				e.colormod_z = stof(argv(4));
			}
			else { e.colormod = '0.5 0.5 0.5'; }
			if(argv(5)) { e.cnt = stof(argv(5)); }
			else { e.cnt = 150; }
			setorigin(e, trace_endpos);
			setsize(e, '-10 -10 -10', '10 10 10'); // for findradius
			e.solid = SOLID_TRIGGER;
			e.think = el_Think;
			e.customizeentityforclient = el_Customize;
			e.nextthink = time + 0.1;
			Net_LinkEntity(e, TRUE, 0, el_SendEntity);
			sprint(self, "Spawned new light entity\n");
			return TRUE;
		}

		if(argv(1) == "remove")
		{
			if(!self.el_editmode) { sprint(self, "You cannot edit lights\n"); return TRUE; }

			entity e, thelight = world;
			for(e = WarpZone_FindRadius(self.origin + self.view_ofs + v_forward * 150, 250, FALSE); e; e = e.chain)
			if(e.classname == "editlights")
			{
				thelight = e;
				break;
			}

			if(thelight)
			{
				remove(thelight);
				sprint(self, "Successfully removed a light\n");
				return TRUE;
			}
			else
			{
				sprint(self, "Light not found\n");
				return TRUE;
			}
		}
		
		if(argv(1) == "edit")
		{
			if(!argv(2))
			{
				if(self.el_editmode)
					self.el_editmode = FALSE;
				else
					self.el_editmode = TRUE;
				sprint(self, "Edit mode ", ((self.el_editmode) ? "enabled" : "disabled"), "\n");
				return TRUE;
			}
			if(!self.el_editmode) { sprint(self, "You cannot edit lights\n"); return TRUE; }

			entity e, thelight = world;
			for(e = WarpZone_FindRadius(self.origin + self.view_ofs + v_forward * 150, 250, FALSE); e; e = e.chain)
			if(e.classname == "editlights")
			{
				thelight = e;
				break;
			}

			if(thelight)
			if(argv(3))
			switch(argv(2))
			{
				case "brightness": thelight.cnt = stof(argv(3)); thelight.SendFlags |= 8; return TRUE;
				case "color":
				if(argv(5))
				{
					thelight.colormod_x = stof(argv(3));
					thelight.colormod_y = stof(argv(4));
					thelight.colormod_z = stof(argv(5));
					thelight.SendFlags |= 2;
					sprint(self, "Color set!\n");
					return TRUE;
				}
			}
		}

		sprint(self, "Command was not handled\n");
	}

	return FALSE;
}

MUTATOR_DEFINITION(mutator_editlights)
{
	MUTATOR_HOOK(SV_ParseClientCommand, el_ClientCommand, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		precache_model("models/runematch/rune.mdl");
	}

	return FALSE;
}
