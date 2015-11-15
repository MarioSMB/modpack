REGISTER_MUTATOR(mod_projectiles, true);

SOUND(CANNONBALL_FLY, W_Sound("fireball_fly2"));

SOUND(STEAM_FADE, "machines/steam_fade");

MODEL(PROJECTILE_DELUGE, "models/waterblob.iqm");
MODEL(PROJECTILE_CANNONBALL, "models/sphere/sphere.md3");

MUTATOR_HOOKFUNCTION(mod_projectiles, Ent_Projectile)
{
	switch(self.cnt)
	{
		case PROJECTILE_DELUGE: setmodel(self, MDL_PROJECTILE_DELUGE);self.traileffect = EFFECT_TR_NEXUIZPLASMA.m_id; return true;
		case PROJECTILE_CANNONBALL: setmodel(self, MDL_PROJECTILE_CANNONBALL);self.traileffect = EFFECT_TR_ROCKET.m_id; return true;

		case PROJECTILE_SPIKE: setmodel(self, MDL_PROJECTILE_SPIKE);self.traileffect = 0; return true;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mod_projectiles, EditProjectile)
{
	switch(self.cnt)
	{
		case PROJECTILE_DELUGE:
		{
			loopsound(self, CH_SHOTS_SINGLE, SND(STEAM_FADE), VOL_BASE, ATTN_NORM);
			self.mins = '0 0 -4';
			self.maxs = '0 0 -4';
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = func_null;
			self.move_bounce_factor = g_balance_electro_secondary_bouncefactor;
			self.move_bounce_stopspeed = g_balance_electro_secondary_bouncestop;
			break;
		}
		case PROJECTILE_CANNONBALL:
		{
			self.colormod = '1 1 1';
			self.scale = 0.5;
			loopsound(self, CH_SHOTS_SINGLE, SND(CANNONBALL_FLY), VOL_BASE, ATTEN_NORM);
			self.mins = '-16 -16 -16';
			self.maxs = '16 16 16';
			break;
		}
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mod_projectiles, PrecacheProjectiles)
{
	precache_model("models/waterblob.iqm");
	precache_model("progs/spike.mdl");

	precache_sound("machines/steam_fade.wav");
}
