.entity hat;
.string cvar_cl_hat;

void hat_think()
{
	self.nextthink = time + 0.1;
	
	self.effects = self.owner.effects & EFMASK_CHEAP; // keep performance
	self.alpha = self.owner.alpha; // keep alpha
}

void GiveHat(entity ent, entity targ, float ispickup)
{
	if(ent == world || targ == world)
		return; // avoid crashes where possible
		
	if(ispickup)
	{
		pointparticles(particleeffectnum("item_pickup"), ent.origin, '0 0 0', 1);
		sound(other, CH_TRIGGER, "misc/itempickup.wav", VOL_BASE, ATTN_NORM);
	}
	
	ent.solid = SOLID_NOT;
	ent.alpha = targ.alpha;
	ent.movetype = MOVETYPE_NONE;
	ent.touch = func_null;
	ent.owner = ent.realowner = targ;
	ent.effects = targ.effects & EFMASK_CHEAP;
	ent.team = targ.team;
	ent.glowmod = targ.glowmod;
	ent.colormap = targ.colormap;
	ent.angles = '0 0 0';
	ent.avelocity = '0 0 0';
	targ.hat = ent;
	ent.velocity = '0 0 0';
	setorigin(ent, '0 0 0');
	setattachment(ent, targ, "head");
	ent.think = hat_think;
	ent.nextthink = time + 0.1;
}

void hat_touch()
{
	makevectors(self.angles);
	self.avelocity = -250 * v_forward;  // maybe there is a way to make it look better?

	if(other == world)
		return;
	
	if(other.hat)
		return;
		
	if not(IS_PLAYER(other))
		return;
		
	if(other.deadflag != DEAD_NO)
		return;
		
	if(other.cvar_cl_pony || (other.cvar_cl_sparkle > 1) || other.cvar_cl_bikini)
		return; // don't allow custom models to wear hats
		
	GiveHat(self, other, TRUE);
}

void DropHat(entity pl)
{
	if(pl.hat == world)
		return;
		
	entity _hat = pl.hat;
	pl.hat = world;
	_hat.owner = world;
		
	setattachment(_hat, world, "");
	setsize(_hat, '-24 -24 -15', '24 24 12');
	setorigin(_hat, pl.origin + pl.view_ofs);
	_hat.alpha = 1;
	_hat.effects = 0;
	_hat.touch = hat_touch;
	_hat.movetype = MOVETYPE_BOUNCE;
	_hat.solid = SOLID_TRIGGER;
	_hat.velocity = '0 0 20';
	SUB_SetFade(_hat, time + 5, 1);
}

MUTATOR_HOOKFUNCTION(hats_PlayerDies)
{
	DropHat(self);
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(hats_PlayerSpawn)
{
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
	MUTATOR_HOOK(PlayerDies, hats_PlayerDies, CBC_ORDER_ANY);
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
		precache_sound ("misc/itempickup.wav");
	}

	return FALSE;
}
