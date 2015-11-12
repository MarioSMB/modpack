//bool autocvar_cl_particles_newvortexbeam;
AUTOCVAR_SAVE(cl_vaporizerbeam,                    int,   0,      _("Draw a client side beam when firing in instagib. -1: always disabled, 0: disabled unless ping is high, 1: enabled"));
AUTOCVAR_SAVE(cl_particles_newvortexbeam,          bool,  false,  _("Draw a fancy new vortex beam"));

float vaporizer_delay;
float last_beam;

MUTATOR_HOOKFUNCTION(mutator_mod, UpdateCrosshair)
{
	vaporizer_delay = getstatf(STAT_WEP_VAPORIZER_PRIMARY_REFIRE);

	if(!vaporizer_delay)
		vaporizer_delay = 0.75;

	entity localme = playerslots[player_localnum];

	if(activeweapon == WEP_VAPORIZER.m_id)
	if(time >= STAT(GAMESTARTTIME))
	if(time >= getstatf(STAT_ROUNDSTARTTIME))
	if(!autocvar_chase_active)
	if(!getstatf(STAT_FROZEN))
	if(!spectatee_status)
	if(input_buttons & 1)
	if(autocvar_cl_vaporizerbeam || (localme.ping >= 200 && autocvar_cl_vaporizerbeam != -1))
	if(time >= last_beam)
	{
		vector v = '0 0 1' * getstati(STAT_VIEWHEIGHT);

		WarpZone_TraceLine(view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, world);

		bool hit = ((trace_fraction < 1 && !trace_ent.entnum) ? false : true);

		WarpZone_TrailParticles(self, particleeffectnum((hit ? EFFECT_VAPORIZER_HIT(myteam) : EFFECT_VAPORIZER(myteam))), view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE);

		//sound(self, CH_SHOTS, "weapons/minstanexfire.wav", VOL_BASE, ATTEN_LARGE);

		if(!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
		//if(autocvar_cl_particles_newvortexbeam && (getstati(STAT_ALLOW_OLDVORTEXBEAM) || isdemo()))
			//pointparticles(particleeffectnum("nex_impact_new"), trace_endpos, '0 0 0', 1);
		//else
			__pointparticles(particleeffectnum(EFFECT_VORTEX_IMPACT), trace_endpos, '0 0 0', 1);

		last_beam = time + vaporizer_delay;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, Weapon_ImpactEffect)
{
	if(autocvar_cl_particles_newvortexbeam && w_hitwep == WEP_VORTEX)
	{
		vector org2 = w_org + w_backoff * 6;
		pointparticles(EFFECT_VORTEX_IMPACT_NEW, org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, SND_NEXIMPACT, VOL_BASE, ATTN_NORM);
		return true;
	}

	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, Particles_VortexBeam)
{
	if(autocvar_cl_particles_newvortexbeam && particleeffectnum(EFFECT_VORTEX_BEAM_NEW) >= 0)
	{
		WarpZone_TrailParticles_WithMultiplier(world, particleeffectnum(EFFECT_VORTEX_BEAM_NEW), vbeam_shotorg, vbeam_endpos, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);
		return true;
	}

	return false;
}
