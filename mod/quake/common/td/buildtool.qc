#include "buildtool.qh"

#ifdef GAMEQC
Turret td_GetSelection(Champions this, int number)
{
	if(!this || !this.td_turrets)
		this = CHAMPION_Ranger;

	Turret tur = TUR_Null;
	FOREACH(Turrets, it.m_champion == this,
	{
		if(it.impulse == number)
		{
			tur = it;
			break;
		}
	});
	return tur;
}

int td_UpgradeCost(int thelevel)
{
	switch(thelevel)
	{
		default:
		case 1: return 100;
		case 2: return 200;
		case 3: return 400;
		case 4: return 700;
		case 5: return 1220;
	}
	// unreachable
	return 0;
}

void buildtool_trace(vector from, vector to, entity this)
{
	int oldclipgroup = this.clipgroup;
	this.clipgroup = 0;
	
	// copy of crosshair_trace_plusvisibletriggers
	// so that we can target the non-solid turrets
	FOREACH_ENTITY_FLOAT(solid, SOLID_TRIGGER,
	{
		if(it.model != "" && it.turretdef)
		{
			it.solid = SOLID_BSP;
			IL_PUSH(g_ctrace_changed, it);
		}
	});

	tracebox(from, '-16 -16 -16', '16 16 16', to, MOVE_NORMAL, this);

	IL_EACH(g_ctrace_changed, true, { it.solid = SOLID_TRIGGER; });
	IL_CLEAR(g_ctrace_changed);

	this.clipgroup = oldclipgroup;
}
#endif

#ifdef CSQC
void Draw_Circle(vector shotorg, float crange)
{
	float a = 0.2;
	vector sw_color = '1 0 0';

	int subdivisions = 20;
	float angle_step = 2 * M_PI / subdivisions;

	R_BeginPolygon("", DRAWFLAG_NORMAL, false);

	for(int j = 0; j <= subdivisions; ++j)
	{
		vector p1 = shotorg;
		p1.x += cos(j * angle_step) * crange;
		p1.y += sin(j * angle_step) * crange;

		R_PolygonVertex(p1, '0 0 0', sw_color, a);
	}

	R_EndPolygon();
}

void Draw_Cone_withline(vector shotorg, vector shotdir, float crange, float maxpitch, float maxrot, vector sw_color, float a, bool showline)
{
	vector _forward, right, up;
	VECTOR_VECTORS(shotdir, _forward, right, up);

	float rotradius = crange * tan(maxrot * DEG2RAD);
	float pitchradius = crange * tan(maxpitch * DEG2RAD);

	vector tip = shotorg;
	vector org = shotorg + shotdir * crange;
	int segments = 20;
	float step = (2 * M_PI) / segments;
	for(int j = 1; j <= segments; ++j)
	{
		float baseangle = j * step;
		// current base point
		vector p1 = org + (right * cos(baseangle) * rotradius) + (up * sin(baseangle) * pitchradius);
		// next base point
		baseangle = (j + 1) * step;
		vector p2 = org + (right * cos(baseangle) * rotradius) + (up * sin(baseangle) * pitchradius);

		// draw triangles (tip, p1, p2)
		R_BeginPolygon("", DRAWFLAG_NORMAL, false);
		R_PolygonVertex(tip, '0 0 0', sw_color, a);
		R_PolygonVertex(p1, '0 0 0', sw_color, a);
		R_PolygonVertex(p2, '0 0 0', sw_color, a);
		R_EndPolygon();
	}

	if(showline)
	{
		// also draw a line for indication of range
		Draw_CylindricLine(shotorg, shotorg + shotdir * crange, 6, "", 0.25, 0, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
	}
}

void Draw_Cone(vector shotorg, vector shotdir, float crange, float maxpitch, float maxrot)
{
	Draw_Cone_withline(shotorg, shotdir, crange, maxpitch, maxrot, '1 0 0', 0.2, true);
}

entity dropmark;
.float max_health;

PRECACHE(BuildTool)
{
	precache_model("progs/s_td_repair.spr");
	precache_model("progs/s_td_upgrade.spr");
	precache_model("progs/s_td_destroy.spr");
}

void buildtool_DrawInfo(entity this)
{
	Turret tur = this.turretdef;
	if(tur == TUR_Null)
		return;
	float fuel = STAT(TD_FUEL);

	int oldfont = drawfont;
	drawfont = 8 + 1; // FONT_USER

	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	vector ent_menu_size = '280 180 0';
	vector myPos = '256 0 0';

	sui_fill(myPos, ent_menu_size, '0 0 0', 0.25, 0);

	sui_push_frame(myPos, ent_menu_size);
	sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_START));

	vector pos = '0 0 0';
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	sui_drawtext(pos, '16 16 0', ((tur.m_name != "") ? tur.m_name : "Turret"), '0.3 1 0.3', 1, 0);

	if(this.classname != "buildtool_dropmark" && tur != TUR_JUMPING_CASTLE)
	{
		pos.y += 16;
		sui_drawtext(pos, '12 12 0', sprintf("Summoned by %s", tur.m_champion.m_name), '1 1 1', 1, 0);
	}
	else if(tur.m_description && tur.m_description != "")
	{
		pos.y += 4;
		int linecount = tokenizebyseparator(tur.m_description, "\n");
		for(int j = 0; j < linecount; ++j)
		{
			pos.y += 12;
			sui_drawtext(pos, '12 12 0', argv(j), '1 1 1', 1, 0);
		}
	}

	sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_START));
	pos.y += 8; // extra padding

	pos.y += 16;
	if(this.health < this.max_health)
		sui_drawcolortext(pos, '16 16 0', sprintf("^7Health: ^1%d ^7/ ^1%d", this.health, this.max_health), 1, 0);
	else
		sui_drawcolortext(pos, '16 16 0', sprintf("^7Health: ^1%d", this.health), 1, 0);

	if(tur.tur_dmg)
	{
		pos.y += 16;
		float damage = tur.tur_dmg;
		if(tur.tur_dmgscale)
			damage *= turret_getpower(this.tur_level, tur.tur_dmgscale);
		sui_drawcolortext(pos, '16 16 0', sprintf("^7Damage: ^3%d", damage), 1, 0);
	}

	if(tur.healamount)
	{
		pos.y += 16;
		// NOTE: hardcoded the 20%
		float healing = tur.healamount * turret_getpower(this.tur_level, 0.2);
		sui_drawcolortext(pos, '16 16 0', sprintf("^7Healing: ^2%d", healing), 1, 0);
	}

	if(tur.tr_getinfo)
		pos = tur.tr_getinfo(tur, this, pos);

	pos.y += 16;
	int myunits = (this.tur_units) ? this.tur_units : tur.tur_units;
	string col = "^5";
	if(this.classname == "buildtool_dropmark" && (myunits + td_ent.tur_units) > td_ent.currentammo)
		col = "^1";
	sui_drawcolortext(pos, '16 16 0', sprintf("^7Defense Units: %s%d", col, myunits), 1, 0);

	sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_END));
	pos = '0 -24 0';

	if(this.classname == "buildtool_dropmark")
	{
		string fcol = (STAT(TD_FUEL) < tur.tur_cost) ? "^1" : "^3";
		sui_drawcolortext(pos, '16 16 0', sprintf("^7Cost: %s%d", fcol, tur.tur_cost), 1, 0);
	}
	else if(this.tur_level >= 5)
		sui_drawtext(pos, '16 16 0', "At maximum level", '1 1 0', 1, 0);
	else
	{
		int fcost = td_UpgradeCost(this.tur_level + 1);
		string fcol = (fuel < fcost) ? "^1" : "^2";
		sui_drawcolortext(pos, '16 16 0', sprintf("^7To next level: %s%d", fcol, fcost), 1, 0);
	}

	sui_pop_frame();

	drawfont = oldfont;
}

void dropmark_think(entity this)
{
	this.nextthink = time;
	if(time >= this.cnt)
	{
		dropmark = NULL;
		if(this.tur_head)
			delete(this.tur_head);
		delete(this);
		return;
	}
}

void buildtool_draw2d(entity this)
{
	if(buildtool_targ)
		buildtool_DrawInfo(buildtool_targ);
}

void buildtool_selectframe(entity this)
{
	if(!dropmark)
	{
		dropmark = new(buildtool_dropmark);
		dropmark.dphitcontentsmask = DPCONTENTS_SOLID;
		dropmark.solid = SOLID_CORPSE;
		dropmark.drawmask = MASK_NORMAL;
		setthink(dropmark, dropmark_think);
		dropmark.nextthink = time;
		dropmark.effects = EF_ADDITIVE;
		dropmark.alpha = 0.5;
	}

	buildtool_trace(view_origin, view_origin + view_forward * 150, this);

	if(trace_startsolid)
		return;

	// ping it to keep it active
	dropmark.owner = this;
	dropmark.cnt = time + 0.2;

	string mymodel = "";
	int buildmode = STAT(TD_TURRET);
	vector goodcol = '1 1 1';

	switch(buildmode)
	{
		default:
		case 0: mymodel = "progs/s_td_repair.spr"; goodcol = '0 1 1'; break;
		case 1: mymodel = "progs/s_td_upgrade.spr"; goodcol = '0 1 0'; break;
		case 2: mymodel = "progs/s_td_destroy.spr"; goodcol = '1 0 0'; break;
	}
	
	dropmark.colormod = '1 1 1';

	vector org = trace_endpos;
	entity targ = NULL;
	if(trace_ent.turretdef)
	{
		float mhealth = (trace_ent.max_health > 0) ? trace_ent.max_health : 255;
		switch(buildmode)
		{
			default:
			case 0: if(trace_ent.health < mhealth) targ = trace_ent; break;
			case 1: if(trace_ent.tur_level < 5 && STAT(TD_FUEL) >= td_UpgradeCost(trace_ent.tur_level + 1)) targ = trace_ent; break;
			case 2: targ = trace_ent; break;
		}
	}

	if(trace_ent && trace_ent.turretdef)
	{
		buildtool_targ = trace_ent;

		Turret tur = trace_ent.turretdef;
		if(tur.tr_drawselected)
			tur.tr_drawselected(tur, trace_ent);
	}

	if(targ)
	{
		org = targ.origin + ('0 0 1.2' * targ.maxs_z);
		dropmark.colormod = goodcol;
	}

	setorigin(dropmark, org);

	if(mymodel != "" && dropmark.model != mymodel)
	{
		_setmodel(dropmark, mymodel);
		setsize(dropmark, '0 0 0', '0 0 0');
	}

	// might've been a turret
	if(dropmark.tur_head)
	{
		delete(dropmark.tur_head);
		dropmark.tur_head = NULL;
	}
}

void buildtool_frame(entity this)
{
	if(STAT(TD_BUILDMODE) == 2)
	{
		buildtool_selectframe(this);
		return;
	}
	else if(STAT(TD_BUILDMODE) != 1)
		return; // incase of additions

	Turret tur = td_GetSelection(this.m_champion, STAT(TD_TURRET));
	if(tur == TUR_Null)
		return;

	if(!dropmark)
	{
		dropmark = new(buildtool_dropmark);
		dropmark.dphitcontentsmask = DPCONTENTS_SOLID;
		dropmark.solid = SOLID_CORPSE;
		dropmark.drawmask = MASK_NORMAL;
		setthink(dropmark, dropmark_think);
		dropmark.nextthink = time;
		dropmark.effects = EF_ADDITIVE;
		dropmark.alpha = 0.5;
	}

	// ping it to keep it active
	dropmark.owner = this;
	dropmark.cnt = time + 0.2;
	dropmark.turretdef = tur;
	dropmark.health = tur.tur_health;
	dropmark.max_health = dropmark.health;

	if(dropmark.model != tur.mdl)
	{
		precache_model(tur.mdl);
		_setmodel(dropmark, tur.mdl);
		setsize(dropmark, tur.m_mins, tur.m_maxs);

		if(tur.head_model != "" && !dropmark.tur_head)
		{
			dropmark.tur_head = spawn();
			dropmark.tur_head.classname = "buildtool_dropmark_head";
			dropmark.tur_head.drawmask = MASK_NORMAL;
			dropmark.tur_head.effects = EF_ADDITIVE;
			dropmark.tur_head.alpha = 0.5;
			dropmark.tur_head.owner = dropmark;
			setattachment(dropmark.tur_head, dropmark, "");
		}
		else if(dropmark.tur_head)
		{
			delete(dropmark.tur_head);
			dropmark.tur_head = NULL;
		}
	}

	if(dropmark.tur_head && dropmark.tur_head.model != tur.head_model)
	{
		precache_model(tur.head_model);
		_setmodel(dropmark.tur_head, tur.head_model);
		setsize(dropmark.tur_head, '0 0 0', '0 0 0');
		setorigin(dropmark.tur_head, '0 0 0');
	}

	tracebox(view_origin, dropmark.mins, dropmark.maxs, view_origin + view_forward * 150, MOVE_NOMONSTERS, this);

	dropmark.colormod = '1 1 1';
	if(!(tur.spawnflags & TUR_FLAG_FLOATING))
	{
		tracebox(trace_endpos + '0 0 1', dropmark.mins, dropmark.maxs, trace_endpos - '0 0 150', MOVE_NOMONSTERS, this);
		// didn't find ground, no good
		if(trace_fraction == 1.0)
			dropmark.colormod = '1 0 0';
	}

	if(trace_startsolid || STAT(TD_FUEL) < tur.tur_cost || ((tur.tur_units + td_ent.tur_units) > td_ent.currentammo) || td_badplacement(this, tur, trace_endpos))
		dropmark.colormod = '1 0 0';

	if(dropmark.tur_head)
		dropmark.tur_head.colormod = dropmark.colormod;
	dropmark.angles = '0 1 0' * view_angles.y;

	setorigin(dropmark, trace_endpos);

	if(tur.tr_drawselected)
		tur.tr_drawselected(tur, dropmark);

	buildtool_targ = dropmark;
}
#endif

#ifdef SVQC
PRECACHE(BuildTool)
{
	if(gametype != GAMETYPE_TD)
		return;

	precache_sound("td/switch.wav");
	precache_sound("td/nofuel.wav");

	precache_sound("td/repair1.wav");
	precache_sound("td/repair2.wav");
	precache_sound("td/repair3.wav");

	precache_sound("td/upgrade.wav");

	precache_sound("td/buildmode0.wav");
	precache_sound("td/buildmode1.wav");
	precache_sound("td/buildmode2.wav");
}

void BuildTool_Fire(entity actor)
{
	if(!STAT(TD_BUILDMODE, actor) || td_phase == TD_PHASE_WIN || intermission_running || actor.health < 1 || actor.exptime != 0)
		return;

	if(STAT(TD_BUILDMODE, actor) == 2)
	{
		makevectors(actor.v_angle);
		vector org = CENTER_OR_VIEWOFS(actor);
		buildtool_trace(org, org + v_forward * autocvar_sv_quake_td_buildrange, actor);

		if(IS_TURRET(trace_ent))
		{
			int buildmode = STAT(TD_TURRET, actor);
			switch(buildmode)
			{
				default:
				case 0:
				{
					if(trace_ent.health < trace_ent.max_health && trace_ent.max_health > 0)
					{
						int cost = autocvar_sv_quake_td_repaircost;
						if(STAT(TD_FUEL, actor) < cost)
						{
							_sound(actor, CH_WEAPON_SINGLE, "td/nofuel.wav", 1, ATTN_NORM);
							Send_Notification(NOTIF_ONE_ONLY, actor, MSG_CENTER, CENTER_NO_FUEL);
							actor.attack_finished = time + 0.25;
							break;
						}

						STAT(TD_FUEL, actor) -= cost;
						float repairamount = trace_ent.max_health * 0.02; // small percentage per frame
						if(td_phase == TD_PHASE_BUILD)
							repairamount = trace_ent.max_health * 0.10;

						float prevhp = trace_ent.health;
						trace_ent.health = min(trace_ent.health + repairamount, trace_ent.max_health);
						trace_ent.SendFlags |= TNSF_STATUS;
						float arate = 0.25;
						if(actor.m_champion && actor.m_champion.qcc_attackrate)
							arate *= actor.m_champion.qcc_attackrate;
						if(STAT(PASSIVES, actor) & PASSIVE_ADRENALIN)
							arate *= 0.8;
						actor.attack_finished = time + arate;
						if(time >= actor.spamtime)
						{
							Send_Effect(EFFECT_RUNE_HEAL, trace_ent.origin, '0 0 0', 1);
							actor.spamtime = time + 0.25;
							float r = random();
							if(r < 0.33)
								_sound(actor, CH_WEAPON_SINGLE, "td/repair1.wav", 1, ATTN_NORM);
							else if(r < 0.66)
								_sound(actor, CH_WEAPON_SINGLE, "td/repair2.wav", 1, ATTN_NORM);
							else
								_sound(actor, CH_WEAPON_SINGLE, "td/repair3.wav", 1, ATTN_NORM);
						}

						if(IS_PLAYER(actor))
							actor.score_repaired += (trace_ent.health - prevhp);
					}
					else
					{
						//_sound(actor, CH_WEAPON_SINGLE, "td/nofuel.wav", 1, ATTN_NORM);
						Send_Notification(NOTIF_ONE_ONLY, actor, MSG_CENTER, CENTER_TURRET_FULLHEALTH);
						actor.attack_finished = time + 0.25;
					}
					break;
				}
				case 1:
				{
					int cost = td_UpgradeCost(trace_ent.tur_level + 1);
					if(trace_ent.tur_level < 5)
					{
						if(STAT(TD_FUEL, actor) < cost)
						{
							_sound(actor, CH_WEAPON_SINGLE, "td/nofuel.wav", 1, ATTN_NORM);
							Send_Notification(NOTIF_ONE_ONLY, actor, MSG_CENTER, CENTER_NO_FUEL);
							actor.attack_finished = time + 0.25;
							break;
						}
						STAT(TD_FUEL, actor) = max(STAT(TD_FUEL, actor) - cost, 0);
						turret_levelup(trace_ent);
						Send_Effect(EFFECT_RUNE_FROST_REGEN, trace_ent.origin, '0 0 0', 1);
						_sound(trace_ent, CH_TRIGGER_SINGLE, "td/upgrade.wav", 1, ATTEN_NORM);
						actor.attack_finished = time + 0.5;
						if(IS_PLAYER(actor))
							actor.score_upgrades += 1;
					}
					else
					{
						//_sound(actor, CH_WEAPON_SINGLE, "td/nofuel.wav", 1, ATTN_NORM);
						Send_Notification(NOTIF_ONE_ONLY, actor, MSG_CENTER, CENTER_TURRET_MAXLEVEL);
						actor.attack_finished = time + 0.25;
					}
					break;
				}
				case 2:
				{
					Turret tur = trace_ent.turretdef;
					float hpscale = 0;
					if(trace_ent.health > 0 && trace_ent.max_health > 0)
						hpscale = trace_ent.health / trace_ent.max_health;

					int refund = tur.tur_cost;
					// scale based on damage too so you can't get free resources
					refund *= bound(0, hpscale, 1);
					// also refund SOME of the upgrade cost
					if(tur.tur_level > 0)
					{
						for(int j = 1; j <= tur.tur_level; ++j)
						{
							refund += (td_UpgradeCost(j) * 0.5);
						}
					}
					refund = rint(refund);
					if(refund > 0)
						td_DropFuel(trace_ent, refund, NULL, false);

					sound(trace_ent, CH_SHOTS, SND_ROCKET_EXPLOSION, VOL_BASE, ATTEN_NORM);
					pointparticles(EFFECT_EXPLOSION, trace_ent.origin, '0 0 0', 1);
					if(td_ent)
					{
						td_ent.tur_units -= trace_ent.tur_units;
						td_ent.SendFlags |= SF_TD_ENT_COUNTS;
					}
					if(trace_ent.tur_head)
						delete(trace_ent.tur_head);
					delete(trace_ent);
					actor.attack_finished = time + 0.5;
					break;
				}
			}
		}
		else
		{
			Send_Notification(NOTIF_ONE_ONLY, actor, MSG_CENTER, CENTER_NO_TARGET);
			actor.attack_finished = time + 0.1;
		}
		return;
	}

	Turret tur = td_GetSelection(actor.m_champion, STAT(TD_TURRET, actor));

	if(tur == TUR_Null)
		return;

	if(td_ent && (td_ent.tur_units + tur.tur_units) > td_ent.currentammo)
	{
		_sound(actor, CH_WEAPON_SINGLE, "td/nofuel.wav", 1, ATTN_NORM);
		Send_Notification(NOTIF_ONE_ONLY, actor, MSG_CENTER, CENTER_NO_UNITS);
		actor.attack_finished = time + 0.25;
		return;
	}

	if(STAT(TD_FUEL, actor) < tur.tur_cost)
	{
		_sound(actor, CH_WEAPON_SINGLE, "td/nofuel.wav", 1, ATTN_NORM);
		Send_Notification(NOTIF_ONE_ONLY, actor, MSG_CENTER, CENTER_NO_FUEL);
		actor.attack_finished = time + 0.25;
		return;
	}

	makevectors(actor.v_angle);

	tracebox(CENTER_OR_VIEWOFS(actor), tur.m_mins, tur.m_maxs, CENTER_OR_VIEWOFS(actor) + v_forward * autocvar_sv_quake_td_buildrange, MOVE_NOMONSTERS, actor);
	if(trace_startsolid)
		return;

	if(!(tur.spawnflags & TUR_FLAG_FLOATING))
	{
		tracebox(trace_endpos + '0 0 1', tur.m_mins, tur.m_maxs, trace_endpos - '0 0 150', MOVE_NOMONSTERS, actor);
		if(trace_startsolid || trace_fraction == 1)
			return;
	}

	// regardless of what happens, add a delay to prevent spam
	actor.attack_finished = time + 0.25;

	if(td_badplacement(actor, tur, trace_endpos))
	{
		Send_Notification(NOTIF_ONE_ONLY, actor, MSG_CENTER, CENTER_NO_PLACE);
		return; // TODO: notify for different types of blockage
	}

	entity turret = spawn();
	turret.classname = "turret";
	setorigin(turret, trace_endpos);
	turret.angles = '0 1 0' * actor.angles_y;
	turret.realowner = actor;
	turret.clipgroup = (actor.clipgroup) ? actor.clipgroup : CLIPGROUP_TDTURRET;
	turret.tur_units = tur.tur_units; // store how many units the turret consumed for later use
	//turret.candrag = true; // :)
	turret.attack_finished = time + 3; // prevent newly spawned turrets from firing, no spam
	if(!turret_initialize(turret, tur))
	{
		delete(turret);
		return;
	}

	STAT(TD_FUEL, actor) = max(0, STAT(TD_FUEL, actor) - tur.tur_cost);

	if(td_ent)
	{
		td_ent.tur_units += turret.tur_units;
		td_ent.SendFlags |= SF_TD_ENT_COUNTS;
	}

	sound(actor, CH_WEAPON_B, SND_CANNON_LAND, 1, ATTN_NORM);
}

void BuildTool_Fire2(entity actor)
{
	if(!STAT(TD_BUILDMODE, actor) || td_phase == TD_PHASE_WIN || intermission_running || actor.health < 1 || actor.exptime != 0)
		return;

	int oldturret = STAT(TD_TURRET, actor);

	STAT(TD_TURRET, actor) += 1;

	if(STAT(TD_BUILDMODE, actor) == 2)
	{
		if(STAT(TD_TURRET, actor) > 2)
			STAT(TD_TURRET, actor) = 0;
	}
	else
	{
		Turret tur = td_GetSelection(actor.m_champion, STAT(TD_TURRET, actor));
		if(tur == TUR_Null)
		{
			// just reset it and pull whatever is in slot 0
			STAT(TD_TURRET, actor) = 0;
			tur = td_GetSelection(actor.m_champion, STAT(TD_TURRET, actor));
		}
	}

	if(oldturret != STAT(TD_TURRET, actor))
	{
		_sound(actor, CH_WEAPON_B, "td/switch.wav", 1, ATTN_NORM);

		// also prevent primary fire during this time
		actor.attack_finished = time + 0.25;
		actor.attack2_finished = time + 0.5;
	}
}

void buildtool_frame(entity this)
{
	// checking secondary first as a swap prevents attacking
	if(PHYS_INPUT_BUTTON_ATCK2(this) && !(time < this.attack2_finished))
		BuildTool_Fire2(this);

	if(PHYS_INPUT_BUTTON_ATCK(this) && !(time < this.attack_finished))
		BuildTool_Fire(this);
}
#endif
