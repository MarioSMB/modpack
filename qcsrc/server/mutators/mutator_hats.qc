.entity hatentity;
.string cvar_cl_hat;
.string hatname; // only update when the player spawns

float is_customplayermodel(entity ent)
{
	if not(autocvar_sv_allow_customplayermodels)
		return FALSE;
	
	if(ent.cvar_cl_damnfurries)
		return TRUE;
	
	if(ent.cvar_cl_robot)
		return TRUE;
	
	if(ent.cvar_cl_bikini)
		return TRUE;
		
	if(ent.cvar_cl_sparkle > 2)
		return TRUE;
		
	if(ent.cvar_cl_pony)
		return TRUE;
	
	return FALSE;
}

void hats_Precache(string pattern)
{
	float globhandle, i, n;
	string f;

	globhandle = search_begin(pattern, TRUE, FALSE);
	if (globhandle < 0)
		return;
	n = search_getsize(globhandle);
	for (i = 0; i < n; ++i)
	{
		f = search_getfilename(globhandle, i);
		precache_model(f);
	}
	search_end(globhandle);
}

void hat_Think()
{
	float tag_found;
	self.nextthink = time;
	if (self.owner.hatentity != self || is_customplayermodel(self.owner))
	{
		remove(self);
		return;
	}
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		return;
	}
	if (self.hatname != self.owner.hatname || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.hatname = self.owner.hatname;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.hatname != "" && fexists(strcat("models/hats/", self.owner.hatname, ".md3")))
			setmodel(self, strcat("models/hats/", self.owner.hatname, ".md3")); // precision set below
		else
			self.model = "";
			
		if((tag_found = gettagindex(self.owner, "tag_head")))
		{
			self.tag_index = tag_found;
			self.tag_entity = self.owner;
		}
		else
			setattachment(self, self.owner, "head");
	}
	self.effects = self.owner.effects;
	self.effects |= EF_LOWPRECISION;
	self.effects = self.effects & EFMASK_CHEAP; // eat performance
	if(self.owner.alpha == default_player_alpha)
		self.alpha = default_weapon_alpha;
	else if(self.owner.alpha != 0)
		self.alpha = self.owner.alpha;
	else
		self.alpha = 1;

	self.glowmod = self.owner.glowmod;
	self.colormap = self.owner.colormap;

	CSQCMODEL_AUTOUPDATE();
}

void hats_SpawnHat()
{
	self.hatentity = spawn();
	self.hatentity.classname = "hatentity";
	self.hatentity.solid = SOLID_NOT;
	self.hatentity.owner = self;
	self.hatentity.hatentity = self.hatentity;
	setorigin(self.hatentity, '0 0 0');
	self.hatentity.angles = '0 0 0';
	self.hatentity.think = hat_Think;
	self.hatentity.nextthink = time;
	
	{
		entity oldself = self;
		self = self.hatentity;
		CSQCMODEL_AUTOINIT();
		self = oldself;
	}
}

MUTATOR_HOOKFUNCTION(hats_PlayerSpawn)
{
	if not(is_customplayermodel(self))
	{
		hats_SpawnHat();
		self.hatentity.alpha = default_weapon_alpha;
		self.hatname = strzone(self.cvar_cl_hat);
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(hats_GetCvars)
{
	GetCvars_handleString(get_cvars_s, get_cvars_f, cvar_cl_hat, "cl_magical_hax");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(hats_RemovePlayer)
{
	self.hatentity = world;
	self.hatname = "";
	
	return FALSE;
}

MUTATOR_DEFINITION(mutator_hats)
{
	MUTATOR_HOOK(GetCvars, hats_GetCvars, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, hats_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, hats_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, hats_RemovePlayer, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		hats_Precache("models/hats/*.md3");
	}

	return FALSE;
}
