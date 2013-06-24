.entity hat;
.string cvar_cl_hat;

void hat_think()
{
	self.nextthink = time + 0.1;
	
	self.effects = self.owner.effects & EFMASK_CHEAP; // keep performance
	self.alpha = self.owner.alpha; // keep alpha
}

MUTATOR_HOOKFUNCTION(hats_PlayerSpawn)
{
	if(self.cvar_cl_sparkle == 1)
		sprint(self, "Hats enabled!\n");

	if(self.cvar_cl_hat == "")
	{
		if(self.hat)
		{
			remove(self.hat);
			self.hat = world;
		}
	}
	else
	{
		if(self.hat == world)
			self.hat = spawn();
		self.hat.owner = self.hat.realowner = self;
		self.hat.effects = self.effects & EFMASK_CHEAP;
		self.hat.team = self.team;
		self.hat.glowmod = self.glowmod;
		self.hat.colormap = self.colormap;
		self.hat.alpha = self.alpha;
		self.hat.think = hat_think;
		self.hat.nextthink = time + 0.1;
		setattachment(self.hat, self, "head");
		setmodel(self.hat, strcat("models/hats/", self.cvar_cl_hat, ".md3"));
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(hats_RemovePlayer)
{
	if(self.hat)
		remove(self.hat);
		
	self.hat = world;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(hats_GetCvars)
{
	GetCvars_handleString(get_cvars_s, get_cvars_f, cvar_cl_hat, "cl_hat");
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(hats_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Hats");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_hats)
{
	MUTATOR_HOOK(PlayerSpawn, hats_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, hats_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, hats_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleEnter, hats_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleExit, hats_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetCvars, hats_GetCvars, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, hats_BuildMutatorsString, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		precache_all_playermodels("models/hats/*.md3");
	}

	return FALSE;
}
