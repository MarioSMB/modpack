//bool autocvar_cl_particles_newvortexbeam;
AUTOCVAR_SAVE(cl_vaporizerbeam,                    int,   0,      _("Draw a client side beam when firing in instagib. -1: always disabled, 0: disabled unless ping is high, 1: enabled"));

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
		string s;
		float hit = 0;
		vector v = '0 0 1' * getstati(STAT_VIEWHEIGHT);

		s = strcat("TE_TEI_G3", Static_Team_ColorName_Upper(myteam));

		WarpZone_TraceLine(view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, world);

		if(trace_fraction < 1 && !trace_ent.entnum)
			hit = 0;
		else
			hit = 1;

		if(hit)
			s = strcat(s, "_HIT");

		WarpZone_TrailParticles(self, _particleeffectnum(s), view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE);

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
