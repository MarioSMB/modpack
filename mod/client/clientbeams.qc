//bool autocvar_cl_particles_newvortexbeam;
AUTOCVAR_SAVE(cl_vaporizerbeam,                    int,   0,      "Draw a client side beam when firing in instagib. -1: always disabled, 0: disabled unless ping is high, 1: enabled");
AUTOCVAR_SAVE(cl_vaporizerbeam_minping,            int,   160,    "Minimum ping for the client side beams to automatically enable");
AUTOCVAR_SAVE(cl_particles_newvortexbeam,          bool,  false,  "Draw a fancy new vortex beam");

.float last_beam;

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
	WarpZone_TraceBox_ThroughZone(this.vorg1, '0 0 0', '0 0 0', this.vorg2, MOVE_NOTHING, NULL, NULL, Draw_ClientBeam_trace_callback);
	Draw_ClientBeam_trace_callback_tex = string_null;

	/*if(!MUTATOR_CALLHOOK(Particles_ClientBeam, this.vorg1, this.vorg2))
	if(autocvar_cl_particles_oldvortexbeam && (getstati(STAT_ALLOW_OLDVORTEXBEAM) || isdemo()))
		WarpZone_TrailParticles_WithMultiplier(NULL, particleeffectnum(EFFECT_VORTEX_BEAM_OLD), this.vorg1, this.vorg2, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);
	else
		WarpZone_TrailParticles_WithMultiplier(NULL, particleeffectnum(EFFECT_VORTEX_BEAM), this.vorg1, this.vorg2, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);*/
}

void FireClientBeam(vector start, vector end, bool hit)
{
	entity e = spawn();
	setthink(e, SUB_Remove);
	e.nextthink = time + bound(0, autocvar_cl_vaporizerbeam_lifetime, 10);
	e.draw = ClientBeam_Draw;
	e.drawmask = MASK_NORMAL;
	IL_PUSH(g_drawables, e);

	e.vorg1 = start;
	e.vorg2 = end;
	e.cnt = hit;
	e.sv_entnum = player_localentnum;
	e.team = myteam;

	pointparticles(EFFECT_VORTEX_MUZZLEFLASH, e.vorg1, normalize(e.vorg2 - e.vorg1) * 1000, 1);

	if(autocvar_cl_vaporizerbeam_particle)
	{
		WarpZone_TrailParticles(NULL, particleeffectnum(((e.cnt) ? EFFECT_VAPORIZER_HIT(e.team) : EFFECT_VAPORIZER(e.team))), e.vorg1, e.vorg2);
		e.draw = func_null;
		e.drawmask = MASK_NORMAL;
		delete(e);
	}
}

void DrawClientBeam(entity wep, float vordelay, float vapedelay, bool held, entity player)
{
	if(time < wep.last_beam)
		return;

	if(wep.activeweapon == WEP_VAPORIZER || wep.activeweapon == WEP_VORTEX)
	if(held)// || (wep.activeweapon == WEP_VORTEX && WEP_CVAR(vortex, secondary) && attack2_held && !WEP_CVAR(vortex, charge)))
	if(autocvar_cl_vaporizerbeam > 0 || (player.ping >= autocvar_cl_vaporizerbeam_minping && autocvar_cl_vaporizerbeam != -1))
	{
		//vector v = '0 0 1' * getstati(STAT_VIEWHEIGHT);

		vector traceorigin = entcs_receiver(player_localentnum - 1).origin + (eZ * STAT(VIEWHEIGHT));

		//vector vecs = decompressShotOrigin(STAT(SHOTORG));

		traceline(traceorigin, traceorigin + view_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, trueaim);
		vector trueaimpoint = trace_endpos;

		if(vdist((trueaimpoint - traceorigin), <, g_trueaim_minrange))
			trueaimpoint = traceorigin + view_forward * g_trueaim_minrange;

		/*if(vecs.x > 0)
			vecs.y = -vecs.y;
		else
			vecs = '0 0 0';*/

		vector vecs;
		vector md = wep.movedir;
		if(md.x > 0)
		{
			vecs = md;
			vecs.y = -vecs.y;
		}
		else
			vecs = '0 0 0';

		vector dv = view_right * vecs.y + view_up * vecs.z;
		vector w_shotorg = traceorigin + dv;
		float nudge = 1;

		// now move the vecs forward as much as requested if possible
		tracebox(w_shotorg, '0 0 0', '0 0 0', w_shotorg + view_forward * (vecs.x + nudge), MOVE_NORMAL, trueaim); // FIXME this MOVE_NORMAL part will misbehave a little in csqc
		w_shotorg = trace_endpos - view_forward * nudge;
		tracebox(w_shotorg, '0 0 0', '0 0 0', trueaimpoint, MOVE_NORMAL, trueaim);


		//WarpZone_TraceLine(view_origin, view_origin + v + view_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, NULL);

		bool hit = ((trace_fraction < 1 && !trace_ent.entnum) ? false : true);

		int eff = particleeffectnum((hit ? EFFECT_VAPORIZER_HIT(myteam) : EFFECT_VAPORIZER(myteam)));
		if(wep.activeweapon == WEP_VORTEX)
		{
			if(autocvar_cl_particles_oldvortexbeam)
			{ /* keep insta beam */ }
			else if(autocvar_cl_particles_newvortexbeam)
				eff = particleeffectnum(EFFECT_VORTEX_BEAM_NEW);
			else
				eff = particleeffectnum(EFFECT_VORTEX_BEAM);
		}

		if(wep.activeweapon == WEP_VORTEX)
			WarpZone_TrailParticles(player, eff, w_shotorg, trueaimpoint);
		else if(wep.activeweapon == WEP_VAPORIZER)
			FireClientBeam(w_shotorg, trueaimpoint, hit);

		//sound(player, CH_SHOTS, "weapons/minstanexfire.wav", VOL_BASE, ATTEN_LARGE);

		if(!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
		if(autocvar_cl_particles_newvortexbeam && wep.activeweapon == WEP_VORTEX)
			__pointparticles(particleeffectnum(EFFECT_VORTEX_IMPACT_NEW), trace_endpos, '0 0 0', 1);
		else
			__pointparticles(particleeffectnum(EFFECT_VORTEX_IMPACT), trace_endpos, '0 0 0', 1);

		if(wep.activeweapon == WEP_VAPORIZER)
			wep.last_beam = time + vapedelay;
		else if(wep.activeweapon == WEP_VORTEX)
		{
			if(input_buttons & 1)
				wep.last_beam = time + vordelay;
			//else if(WEP_CVAR(vortex, secondary) && attack2_held)
				//wep.last_beam = time + vortex_sdelay;
		}
	}
}

MUTATOR_HOOKFUNCTION(mutator_mod, UpdateCrosshair)
{
	if((time < STAT(GAMESTARTTIME))
	|| (time < STAT(ROUNDSTARTTIME))
	|| (autocvar_chase_active)
	|| (STAT(FROZEN))
	|| (spectatee_status)
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

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		entity wep = viewmodels[slot];
		DrawClientBeam(wep, vortex_pdelay, vaporizer_delay, attack1_held, localme);
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
		WarpZone_TrailParticles_WithMultiplier(NULL, particleeffectnum(EFFECT_VORTEX_BEAM_NEW), M_ARGV(0, vector), M_ARGV(1, vector), 1, PARTICLES_USEALPHA | PARTICLES_USEFADE);
		return true;
	}

	return false;
}
