//bool autocvar_cl_particles_newvortexbeam;
AUTOCVAR_SAVE(cl_vaporizerbeam,                    int,   0,      _("Draw a client side beam when firing in instagib. -1: always disabled, 0: disabled unless ping is high, 1: enabled"));
AUTOCVAR_SAVE(cl_particles_newvortexbeam,          bool,  false,  _("Draw a fancy new vortex beam"));

float last_beam;

MUTATOR_HOOKFUNCTION(mutator_mod, UpdateCrosshair)
{
	if((time < STAT(GAMESTARTTIME))
	|| (time < getstatf(STAT_ROUNDSTARTTIME))
	|| (autocvar_chase_active)
	|| (getstatf(STAT_FROZEN))
	|| (spectatee_status)
	|| (time < last_beam)
	) { return false; }

	float vaporizer_delay = getstatf(STAT_WEP_VAPORIZER_PRIMARY_REFIRE);
	float vortex_pdelay = getstatf(STAT_WEP_VORTEX_PRIMARY_REFIRE);
	float vortex_sdelay = getstatf(STAT_WEP_VORTEX_SECONDARY_REFIRE);
	float vortex_charge = getstatf(STAT_VORTEX_CHARGE);

	if(!vaporizer_delay) vaporizer_delay = 0.75;
	if(!vortex_pdelay) vortex_pdelay = 1.5;
	if(!vortex_sdelay) vortex_sdelay = 0.75;

	entity localme = playerslots[player_localnum];

	if(activeweapon == WEP_VAPORIZER.m_id || activeweapon == WEP_VORTEX.m_id)
	if((input_buttons & 1) || (activeweapon == WEP_VORTEX.m_id && WEP_CVAR(vortex, secondary) && (input_buttons & BUTTON_3) && !vortex_charge))
	if(autocvar_cl_vaporizerbeam > 0 || (localme.ping >= 200 && autocvar_cl_vaporizerbeam != -1))
	{
		vector v = '0 0 1' * getstati(STAT_VIEWHEIGHT);

		WarpZone_TraceLine(view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, world);

		bool hit = ((trace_fraction < 1 && !trace_ent.entnum) ? false : true);

		int eff = particleeffectnum((hit ? EFFECT_VAPORIZER_HIT(myteam) : EFFECT_VAPORIZER(myteam)));
		if(activeweapon == WEP_VORTEX.m_id)
		{
			if(autocvar_cl_particles_oldvortexbeam)
			{ /* keep insta beam */ }
			else if(autocvar_cl_particles_newvortexbeam)
				eff = particleeffectnum(EFFECT_VORTEX_BEAM_NEW);
			else
				eff = particleeffectnum(EFFECT_VORTEX_BEAM);
		}

		WarpZone_TrailParticles(self, eff, view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE);

		//sound(self, CH_SHOTS, "weapons/minstanexfire.wav", VOL_BASE, ATTEN_LARGE);

		if(!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
		if(autocvar_cl_particles_newvortexbeam && activeweapon == WEP_VORTEX.m_id)
			__pointparticles(particleeffectnum(EFFECT_VORTEX_IMPACT_NEW), trace_endpos, '0 0 0', 1);
		else
			__pointparticles(particleeffectnum(EFFECT_VORTEX_IMPACT), trace_endpos, '0 0 0', 1);

		if(activeweapon == WEP_VAPORIZER.m_id)
			last_beam = time + vaporizer_delay;
		else if(activeweapon == WEP_VORTEX.m_id)
		{
			if(input_buttons & 1)
				last_beam = time + vortex_pdelay;
			else if(WEP_CVAR(vortex, secondary) && (input_buttons & BUTTON_3))
				last_beam = time + vortex_sdelay;
		}
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
