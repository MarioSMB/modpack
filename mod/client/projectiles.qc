REGISTER_MUTATOR(mod_projectiles, true);

MUTATOR_HOOKFUNCTION(mod_projectiles, Ent_Projectile)
{
	switch(self.cnt)
	{
		case PROJECTILE_DELUGE: setmodel(self, "models/waterblob.iqm");self.traileffect = particleeffectnum("TR_DELUGEPLASMA"); return true;
		case PROJECTILE_CANNONBALL: setmodel(self, "models/sphere/sphere.md3");self.traileffect = particleeffectnum("TR_ROCKET"); break;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mod_projectiles, EditProjectile)
{
	switch(self.cnt)
	{
		case PROJECTILE_DELUGE:
		{
			loopsound(self, CH_SHOTS_SINGLE, "machines/steam_fade.wav", VOL_BASE, ATTN_NORM);
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
			self.scale = 0.4;
			loopsound(self, CH_SHOTS_SINGLE, W_Sound("fireball_fly2"), VOL_BASE, ATTEN_NORM);
			self.mins = '-3 -3 -3';
			self.maxs = '3 3 3';
			break;
		}
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mod_projectiles, PrecacheProjectiles)
{
	precache_model("models/waterblob.iqm");

	precache_sound("machines/steam_fade.wav");
}
