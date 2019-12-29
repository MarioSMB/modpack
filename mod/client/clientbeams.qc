//FEATURE: Client-side vaporizer and vortex beams, greatly easing the pain of high ping

//bool autocvar_cl_particles_newvortexbeam;
AUTOCVAR_SAVE(cl_vaporizerbeam,                    int,   0,      "Draw a client side beam when firing in instagib. -1: always disabled, 0: disabled unless ping is high, 1: enabled");
AUTOCVAR_SAVE(cl_vaporizerbeam_minping,            int,   160,    "Minimum ping for the client side beams to automatically enable");
AUTOCVAR_SAVE(cl_particles_newvortexbeam,          bool,  false,  "Draw a fancy new vortex beam");

.float last_beam;

vector w_shotend;
vector w_shotorg;
vector w_shotdir;
int ClientBeam_HitCheck();

int W_SetupShot_Dir_ProjectileSize_Range(entity ent, entity wepent, vector s_forward, vector mi, vector ma, float antilag, float recoil, Sound snd, float chan, float maxdamage, float range)
{
	float nudge = 1; // added to traceline target and subtracted from result  TOOD(divVerent): do we still need this? Doesn't the engine do this now for us?
	vector vecs;
	int oldsolid = ent.dphitcontentsmask;
	if (IS_PLAYER(ent) && wepent.activeweapon == WEP_RIFLE)
		ent.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	else
		ent.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	WarpZone_TraceLine(ent.origin + ent.view_ofs, ent.origin + ent.view_ofs + s_forward * range, MOVE_NOMONSTERS, ent);
	ent.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	vector viewangles = getpropertyvec(VF_CL_VIEWANGLES);
	vector forward, right, up;
	MAKE_VECTORS(viewangles, forward, right, up);
	w_shotend = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos); // warpzone support

	return = ClientBeam_HitCheck();

	// un-adjust trueaim if shotend is too close
	if(vdist(w_shotend - (ent.origin + ent.view_ofs), <, g_trueaim_minrange))
		w_shotend = ent.origin + ent.view_ofs + s_forward * g_trueaim_minrange;

	vector md = wepent.movedir;
	if(md.x > 0)
		vecs = md;
	else
		vecs = '0 0 0';

	vector dv = right * -vecs.y + up * vecs.z;
	w_shotorg = ent.origin + ent.view_ofs + dv;

	int oldsurfaceflags = trace_dphitq3surfaceflags;

	// now move the shotorg forward as much as requested if possible
	tracebox(w_shotorg, mi, ma, w_shotorg + forward * (vecs.x + nudge), MOVE_NORMAL, ent);
	w_shotorg = trace_endpos - forward * nudge;
	// calculate the shotdir from the chosen shotorg
	w_shotdir = normalize(w_shotend - w_shotorg);

	// restore flags for later use
	trace_dphitq3surfaceflags = oldsurfaceflags;

	//vector prevdir = w_shotdir;
	//vector prevorg = w_shotorg;
	//vector prevend = w_shotend;

	ent.dphitcontentsmask = oldsolid; // restore solid type (generally SOLID_SLIDEBOX)

	// nudge w_shotend so a trace to w_shotend hits
	w_shotend = w_shotend + normalize(w_shotend - w_shotorg) * nudge;
	//if(w_shotend != prevend) { printf("SERVER: shotEND differs: %s - %s\n", vtos(w_shotend), vtos(prevend)); }
	//if(w_shotorg != prevorg) { printf("SERVER: shotORG differs: %s - %s\n", vtos(w_shotorg), vtos(prevorg)); }
	//if(w_shotdir != prevdir) { printf("SERVER: shotDIR differs: %s - %s\n", vtos(w_shotdir), vtos(prevdir)); }
}

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
	vector rgb = colormapPaletteColor(entcs_GetClientColors(this.sv_entnum - 1) & 0x0F, true);
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

int ClientBeam_HitCheck()
{
	int n;
	if(trace_ent)
		n = trace_ent.entnum;
	else
		n = trace_networkentity;
	if(n < 1)
		return SHOTTYPE_HITWORLD;
	if(n > maxclients)
		return SHOTTYPE_HITWORLD;
	int t = entcs_GetTeam(n - 1);
	if(teamplay && t == myteam)
		return SHOTTYPE_HITTEAM;
	if(t == NUM_SPECTATOR)
		return SHOTTYPE_HITWORLD;
	return SHOTTYPE_HITENEMY;
}

IntrusiveList g_railgunhit;
STATIC_INIT(g_railgunhit) { g_railgunhit = IL_NEW(); }

.bool railgunhit;
.float railgunhitsolidbackup;
.vector railgunhitloc;
void FireRailgunBullet (entity this, entity weaponentity, vector start, vector end, float bdamage, float bforce, float mindist, float maxdist, float halflifedist, float forcehalflifedist, int deathtype)
{
	vector dir = normalize(end - start);

	// go a little bit into the wall because we need to hit this wall later
	end = end + dir;

	// trace multiple times until we hit a wall, each obstacle will be made
	// non-solid so we can hit the next, while doing this we spawn effects and
	// note down which entities were hit so we can damage them later
	entity o = this;
	while (1)
	{
		WarpZone_TraceLine(start, end, false, o);
		if(o && WarpZone_trace_firstzone)
		{
			o = NULL;
			continue;
		}

		// if it is NULL we can't hurt it so stop now
		if (trace_ent == NULL || trace_fraction == 1)
			break;

		// make the entity non-solid so we can hit the next one
		IL_PUSH(g_railgunhit, trace_ent);
		trace_ent.railgunhit = true;
		trace_ent.railgunhitloc = end;
		trace_ent.railgunhitsolidbackup = trace_ent.solid;

		// stop if this is a wall
		if (trace_ent.solid == SOLID_BSP)
			break;

		// make the entity non-solid
		trace_ent.solid = SOLID_NOT;
	}

	vector endpoint = trace_endpos;
	entity endent = trace_ent;
	float endq3surfaceflags = trace_dphitq3surfaceflags;

	// find all the entities the railgun hit and restore their solid state
	IL_EACH(g_railgunhit, it.railgunhit,
	{
		it.solid = it.railgunhitsolidbackup;

		// removal from the list is handled below

		it.railgunhitloc = '0 0 0';
		it.railgunhitsolidbackup = SOLID_NOT;
		it.railgunhit = false;
	});

	IL_CLEAR(g_railgunhit);

	trace_endpos = endpoint;
	trace_ent = endent;
	trace_dphitq3surfaceflags = endq3surfaceflags;
}

void DrawClientBeam(entity wep, float vordelay, float vapedelay, bool held, entity player)
{
	if(wep.activeweapon != WEP_VAPORIZER && wep.activeweapon != WEP_VORTEX)
		return;
	if(!held)
	//if(held)// || (wep.activeweapon == WEP_VORTEX && WEP_CVAR(vortex, secondary) && attack2_held && !WEP_CVAR(vortex, charge)))
		return;
	if(!(autocvar_cl_vaporizerbeam > 0 || (player.ping >= autocvar_cl_vaporizerbeam_minping && autocvar_cl_vaporizerbeam != -1)))
		return;

	//vector v = '0 0 1' * getstati(STAT_VIEWHEIGHT);
	entity rlplayer = CSQCModel_server2csqc(player_localentnum - 1);
	if(!rlplayer)
		rlplayer = csqcplayer; // fall back to the global

	vector viewangles = getpropertyvec(VF_CL_VIEWANGLES);
	vector forward, right, up;
	MAKE_VECTORS(viewangles, forward, right, up);

	//makevectors(rlplayer.v_angle);
	//view_angles

	//v_forward = view_forward;
	//v_right = view_right;
	//v_up = view_up;

	float vaporizer_damage = ((WEP_CVAR_PRI(vaporizer, damage) > 0) ? WEP_CVAR_PRI(vaporizer, damage) : 10000);
	float hit_damage = ((wep.activeweapon == WEP_VORTEX) ? WEP_CVAR_PRI(vortex, damage) : vaporizer_damage);
	float hit_force = ((wep.activeweapon == WEP_VORTEX) ? WEP_CVAR_PRI(vortex, force) : 800);

	int shottype = W_SetupShot_Dir_ProjectileSize_Range(rlplayer, wep, forward, '0 0 0', '0 0 0', false, 0, SND_Null, CH_WEAPON_A, 0, max_shot_distance);
	FireRailgunBullet(rlplayer, wep, w_shotorg, w_shotorg + w_shotdir * max_shot_distance, hit_damage, hit_force, 0, 0, 0, 0, wep.activeweapon.m_id);
	vector shot_endpos = trace_endpos;

	bool hit = boolean(shottype == SHOTTYPE_HITENEMY || shottype == SHOTTYPE_HITTEAM); // also count team shots

	int eff = particleeffectnum((hit ? EFFECT_VAPORIZER_HIT(myteam) : EFFECT_VAPORIZER(myteam)));
	if(wep.activeweapon == WEP_VORTEX)
	{
		if(autocvar_cl_particles_oldvortexbeam)
		{ /* keep insta beam */ }
		else if(autocvar_cl_particles_newvortexbeam && particleeffectnum(EFFECT_VORTEX_BEAM_NEW) >= 0)
			eff = particleeffectnum(EFFECT_VORTEX_BEAM_NEW);
		else
			eff = particleeffectnum(EFFECT_VORTEX_BEAM);
	}

	if(wep.activeweapon == WEP_VORTEX)
		WarpZone_TrailParticles(player, eff, w_shotorg, WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos));
	else if(wep.activeweapon == WEP_VAPORIZER)
		FireClientBeam(w_shotorg, WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos), hit);

	//sound(player, CH_SHOTS, "weapons/minstanexfire.wav", VOL_BASE, ATTEN_LARGE);

	if(!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY) && !hit)
	{
		vector force = w_shotdir * hit_force;
		traceline(shot_endpos - normalize(force) * 16, shot_endpos + normalize(force) * 16, MOVE_NOMONSTERS, NULL);
		w_backoff = -1 * normalize(force);
		vector org2 = shot_endpos + w_backoff * 6;
		if(autocvar_cl_particles_newvortexbeam && wep.activeweapon == WEP_VORTEX)
			pointparticles(EFFECT_VORTEX_IMPACT_NEW, org2, '0 0 0', 1);
		else
			pointparticles(EFFECT_VORTEX_IMPACT, org2, '0 0 0', 1);
	}

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

MUTATOR_HOOKFUNCTION(mutator_mod, DrawCrosshair)
{
	if((time < STAT(GAMESTARTTIME))
	|| (time < STAT(ROUNDSTARTTIME))
	//|| (autocvar_chase_active)
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
		if(time < wep.last_beam)
			continue;
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
