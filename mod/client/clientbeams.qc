//bool autocvar_cl_particles_newvortexbeam;
AUTOCVAR_SAVE(cl_vaporizerbeam,                    int,   0,      _("Draw a client side beam when firing in instagib. -1: always disabled, 0: disabled unless ping is high, 1: enabled"));
AUTOCVAR_SAVE(cl_vaporizerbeam_minping,            int,   160,    _("Minimum ping for the client side beams to automatically enable"));
AUTOCVAR_SAVE(cl_particles_newvortexbeam,          bool,  false,  _("Draw a fancy new vortex beam"));

float last_beam;

//bool autocvar_cl_vaporizerbeam_particle = true;
//float autocvar_cl_vaporizerbeam_lifetime = 0.8;
//float autocvar_cl_vaporizerbeam_colorboost = 0.7;

string Draw_ClientBeam_trace_callback_tex;
float Draw_ClientBeam_trace_callback_rnd;
vector Draw_ClientBeam_trace_callback_rgb;
float Draw_ClientBeam_trace_callback_a;
void Draw_ClientBeam_trace_callback(vector start, vector hit, vector end)
{
	float i;
	vector vorg;
	vorg = WarpZone_TransformOrigin(WarpZone_trace_transform, view_origin);
	for(i = 0; i < Draw_ClientBeam_trace_callback_a; ++i)
		Draw_CylindricLine(hit, start, 8, Draw_ClientBeam_trace_callback_tex, 0.25, Draw_ClientBeam_trace_callback_rnd, Draw_ClientBeam_trace_callback_rgb, min(1, Draw_ClientBeam_trace_callback_a - i), DRAWFLAG_NORMAL, vorg);
	Draw_ClientBeam_trace_callback_rnd += 0.25 * vlen(hit - start) / 8;
}

.vector vorg1, vorg2;
.float spawn_time;
void ClientBeam_Draw(entity this)
{
	//draw either the old v2.3 beam or the new beam
	particles_alphamin = particles_alphamax = particles_fade = 1;

	string tex = "particles/lgbeam";
	if(this.cnt)
		tex = "particles/gauntletbeam";
	//vector rgb = getcsqcplayercolor(this.sv_entnum - 1);
	vector rgb = colormapPaletteColor(stof(getplayerkeyvalue(this.sv_entnum - 1, "colors")) & 0x0F, true);
	rgb *= (1 + autocvar_cl_vaporizerbeam_colorboost);

	float fail = (this.nextthink - time);

	Draw_ClientBeam_trace_callback_tex = tex;
	Draw_ClientBeam_trace_callback_rnd = 0;
	Draw_ClientBeam_trace_callback_rgb = rgb;
	Draw_ClientBeam_trace_callback_a = bound(0, fail, 1);
	WarpZone_TraceBox_ThroughZone(this.vorg1, '0 0 0', '0 0 0', this.vorg2, MOVE_NOTHING, world, world, Draw_ClientBeam_trace_callback);
	Draw_ClientBeam_trace_callback_tex = string_null;

	/*if(!MUTATOR_CALLHOOK(Particles_ClientBeam, this.vorg1, this.vorg2))
	if(autocvar_cl_particles_oldvortexbeam && (getstati(STAT_ALLOW_OLDVORTEXBEAM) || isdemo()))
		WarpZone_TrailParticles_WithMultiplier(world, particleeffectnum(EFFECT_VORTEX_BEAM_OLD), this.vorg1, this.vorg2, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);
	else
		WarpZone_TrailParticles_WithMultiplier(world, particleeffectnum(EFFECT_VORTEX_BEAM), this.vorg1, this.vorg2, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);*/
}

void FireClientBeam(vector start, vector end, bool hit)
{
	entity e = spawn();
	setthink(e, SUB_Remove);
	e.nextthink = time + bound(0, autocvar_cl_vaporizerbeam_lifetime, 10);
	e.draw = ClientBeam_Draw;
	e.drawmask = MASK_NORMAL;

	e.vorg1 = start;
	e.vorg2 = end;
	e.cnt = hit;
	e.sv_entnum = player_localentnum;
	e.team = myteam;

	pointparticles(EFFECT_VORTEX_MUZZLEFLASH, e.vorg1, normalize(e.vorg2 - e.vorg1) * 1000, 1);

	if(autocvar_cl_vaporizerbeam_particle)
	{
		WarpZone_TrailParticles(world, particleeffectnum(((e.cnt) ? EFFECT_VAPORIZER_HIT(e.team) : EFFECT_VAPORIZER(e.team))), e.vorg1, e.vorg2);
		e.draw = func_null;
		e.drawmask = MASK_NORMAL;
		remove(e);
	}
}

MUTATOR_HOOKFUNCTION(mutator_mod, UpdateCrosshair)
{
	if((time < STAT(GAMESTARTTIME))
	|| (time < STAT(ROUNDSTARTTIME))
	|| (autocvar_chase_active)
	|| (STAT(FROZEN))
	|| (spectatee_status)
	|| (time < last_beam)
	) { return false; }

	float vaporizer_delay = WEP_CVAR_PRI(vaporizer, refire);
	float vortex_pdelay = WEP_CVAR_PRI(vortex, refire);
	//float vortex_sdelay = WEP_CVAR_SEC(vortex, refire);
	//float vortex_charge = STAT(VORTEX_CHARGE);

	bool attack1_held = (input_buttons & BIT(0));
	//bool attack2_held = (input_buttons & BIT(2));

	if(!vaporizer_delay) vaporizer_delay = 0.75;
	if(!vortex_pdelay) vortex_pdelay = 1.5;
	//if(!vortex_sdelay) vortex_sdelay = 0.75;

	entity localme = playerslots[player_localnum];

	if(activeweapon == WEP_VAPORIZER || activeweapon == WEP_VORTEX)
	if(attack1_held)// || (activeweapon == WEP_VORTEX && WEP_CVAR(vortex, secondary) && attack2_held && !WEP_CVAR(vortex, charge)))
	if(autocvar_cl_vaporizerbeam > 0 || (localme.ping >= autocvar_cl_vaporizerbeam_minping && autocvar_cl_vaporizerbeam != -1))
	{
		vector v = '0 0 1' * getstati(STAT_VIEWHEIGHT);

		WarpZone_TraceLine(view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, world);

		bool hit = ((trace_fraction < 1 && !trace_ent.entnum) ? false : true);

		int eff = particleeffectnum((hit ? EFFECT_VAPORIZER_HIT(myteam) : EFFECT_VAPORIZER(myteam)));
		if(activeweapon == WEP_VORTEX)
		{
			if(autocvar_cl_particles_oldvortexbeam)
			{ /* keep insta beam */ }
			else if(autocvar_cl_particles_newvortexbeam)
				eff = particleeffectnum(EFFECT_VORTEX_BEAM_NEW);
			else
				eff = particleeffectnum(EFFECT_VORTEX_BEAM);
		}

		if(activeweapon == WEP_VORTEX)
			WarpZone_TrailParticles(localme, eff, view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE);
		else if(activeweapon == WEP_VAPORIZER)
			FireClientBeam(view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE, hit);

		//sound(localme, CH_SHOTS, "weapons/minstanexfire.wav", VOL_BASE, ATTEN_LARGE);

		if(!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
		if(autocvar_cl_particles_newvortexbeam && activeweapon == WEP_VORTEX)
			__pointparticles(particleeffectnum(EFFECT_VORTEX_IMPACT_NEW), trace_endpos, '0 0 0', 1);
		else
			__pointparticles(particleeffectnum(EFFECT_VORTEX_IMPACT), trace_endpos, '0 0 0', 1);

		if(activeweapon == WEP_VAPORIZER)
			last_beam = time + vaporizer_delay;
		else if(activeweapon == WEP_VORTEX)
		{
			if(input_buttons & 1)
				last_beam = time + vortex_pdelay;
			//else if(WEP_CVAR(vortex, secondary) && attack2_held)
				//last_beam = time + vortex_sdelay;
		}
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, Weapon_ImpactEffect)
{
	if(autocvar_cl_particles_newvortexbeam && M_ARGV(0, entity) == WEP_VORTEX)
	{
		vector org2 = w_org + w_backoff * 6;
		pointparticles(EFFECT_VORTEX_IMPACT_NEW, org2, '0 0 0', 1);
		if(!w_issilent)
			sound(M_ARGV(1, entity), CH_SHOTS, SND_NEXIMPACT, VOL_BASE, ATTN_NORM);
		return true;
	}

	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, Particles_VortexBeam)
{
	if(autocvar_cl_particles_newvortexbeam && particleeffectnum(EFFECT_VORTEX_BEAM_NEW) >= 0)
	{
		WarpZone_TrailParticles_WithMultiplier(world, particleeffectnum(EFFECT_VORTEX_BEAM_NEW), M_ARGV(0, vector), M_ARGV(1, vector), 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);
		return true;
	}

	return false;
}
