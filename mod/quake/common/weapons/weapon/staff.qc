#include "staff.qh"

#ifdef GAMEQC
REGISTER_NET_LINKED(ENT_CLIENT_SUNBEAM)
#endif

#ifdef SVQC
void W_Staff_Attack_Vine(entity this, .entity weaponentity);
void W_Staff_Attack_Beam(entity this, .entity weaponentity);

void wep_staff_vinea4(entity this) { wep_set_anim(this, 4, w_ready); W_Staff_Attack_Vine(this.owner, this.weaponentity_fld); }
void wep_staff_vinea3(entity this) { wep_set_anim(this, 3, wep_staff_vinea4); }
void wep_staff_vinea2(entity this) { wep_set_anim(this, 2, wep_staff_vinea3); }
void wep_staff_vinea1(entity this) { wep_set_anim(this, 1, wep_staff_vinea2); }

void wep_staff_vineb4(entity this) { wep_set_anim(this, 8, w_ready); W_Staff_Attack_Vine(this.owner, this.weaponentity_fld); }
void wep_staff_vineb3(entity this) { wep_set_anim(this, 7, wep_staff_vineb4); }
void wep_staff_vineb2(entity this) { wep_set_anim(this, 6, wep_staff_vineb3); }
void wep_staff_vineb1(entity this) { wep_set_anim(this, 5, wep_staff_vineb2); }

void wep_staff_blast3(entity this) { wep_set_anim(this, 22, w_ready); W_Staff_Attack_Beam(this.owner, this.weaponentity_fld); }
void wep_staff_blast2(entity this) { wep_set_anim(this, 21, wep_staff_blast3); }
void wep_staff_blast1(entity this) { wep_set_anim(this, 20, wep_staff_blast2); }

PRECACHE(Staff)
{
	precache_model("progs/g_staff.mdl");
	precache_model("progs/v_staff.mdl");

	precache_model("progs/staff_vines.mdl");
	precache_model("progs/staff_thunder.mdl");

	precache_sound("weapons/staff_vine_fire.wav");
	precache_sound("ambience/wind2.wav");
	precache_sound("ambience/thunder2.wav");
	precache_sound("weapons/sunbeam_loop.wav");
	precache_sound("weapons/lgbeam_fire.wav");

	precache_sound("weapons/staff_spell0.wav");
	precache_sound("weapons/staff_spell1.wav");
	precache_sound("weapons/staff_spell2.wav");
}

//entity tracetossent;

// slightly different to rune_getspot
// TODO: merge them!
vector keyleth_rune_getspot(entity this, vector src, vector dir, float dist)
{
	vector rmin = '-16 -16 0', rmax = '16 16 4';

	if (!tracetossent)
		tracetossent = new(tracetossent);
	tracetossent.owner = this;
	tracetossent.dphitcontentsmask = DPCONTENTS_SOLID;
	setsize(tracetossent, rmin, rmax);
	setorigin(tracetossent, src);

	tracetossent.velocity = dir * dist;
	tracetoss(tracetossent, this);

	if(trace_startsolid || vdist(trace_endpos - src, <, 32))
		return '0 0 0'; // error case

	return trace_endpos;
}

float W_Staff_AttackRate(entity actor, .entity weaponentity)
{
	int stafftype = STAT(MAGIC_TYPE, actor);
	float attack_delay = 0.5;
	switch(stafftype)
	{
		default:
		case 0: attack_delay = 0.75; break;
		case 1: attack_delay = 1; break;
		case 2: attack_delay = 1.25; break;
	}
	return attack_delay;
}

.vector hook_start, hook_end;
bool sunbeam_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_SUNBEAM);
	sf &= 0x7F;
	if(!sound_allowed(MSG_BROADCAST, this.realowner))
		sf |= 0x80;
	if(this.count)
		sf |= 8;
	else
		sf &= ~8;
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
		WriteByte(MSG_ENTITY, etof(this.realowner));
	if (sf & 2)
		WriteVector(MSG_ENTITY, this.hook_start);
	if (sf & 4)
		WriteVector(MSG_ENTITY, this.hook_end);

	return true;
}

void sunbeam_think(entity this)
{
	entity actor = this.owner;

	if(this != actor.sunbeam)
	{
		delete(this);
		return;
	}

	if (STAT(MANA, actor) < 3 || actor.health < 1 || actor.exptime != 0 || !PHYS_INPUT_BUTTON_ATCK(actor) || actor.is_frozen || actor.tank || STAT(CLOCKWORK, actor) || actor.m_transform || STAT(CANNON, actor))
	{
		if(this == actor.sunbeam)
			actor.sunbeam = NULL;
		delete(this);
		return;
	}

	// just keep it up to date until we stop firing!
	.entity weaponentity = this.weaponentity_fld;
	entity wepent = actor.(weaponentity);
	if(wepent)
	{
		ATTACK_FINISHED(actor, weaponentity) = time + 0.25; // prevent attacking again
		wep_set_anim(wepent, 22, w_ready);
	}

	if(IS_PLAYER(actor))
		player_nail1(actor);

	float sunbeam_range = 1024;
	W_TakeMana(actor, 20 * frametime);

	this.nextthink = time;

	makevectors(actor.v_angle);
	vector w_shotorg = W_Shotorg(actor, weaponentity);
	vector w_shotdir = v_forward;

	traceline_antilag(actor, w_shotorg, w_shotorg + w_shotdir * sunbeam_range, MOVE_NORMAL, actor, ANTILAG_LATENCY(actor));

	vector w_shotend = trace_endpos;
	bool didhit = (trace_ent || trace_fraction != 1.0);

	// apply the damage
	if(trace_ent)
	{
		float damage = 85 + random() * 15;
		if(IS_PLAYER(trace_ent))
			damage *= 0.5;
		T_Damage(trace_ent, this, actor, damage * frametime, WEP_STAFF.m_id | HITTYPE_MAGIC);
	}

	// draw effect
	if(w_shotorg != this.hook_start)
	{
		this.SendFlags |= 2;
		this.hook_start = w_shotorg;
	}
	if(w_shotend != this.hook_end)
	{
		this.SendFlags |= 4;
		this.hook_end = w_shotend;
	}
	if(didhit != this.count)
	{
		this.SendFlags |= 8;
		this.count = didhit;
	}
}

void W_Staff_Attack_Beam(entity this, .entity weaponentity)
{
	if(STAT(MANA, this) < 5)
		return;

	_sound(this, CH_WEAPON_A, "weapons/lgbeam_fire.wav", VOL_BASE, ATTEN_NORM);

	entity beam = spawn();
	beam.classname = "sunbeam";
	beam.solid = SOLID_NOT;
	setthink(beam, sunbeam_think);
	beam.owner = beam.realowner = this;
	set_movetype(beam, MOVETYPE_NONE);
	beam.shot_spread = 0;
	Net_LinkEntity(beam, false, 0, sunbeam_send);
	beam.weaponentity_fld = weaponentity;

	this.sunbeam = beam;

	sunbeam_think(beam);
}
.vector vorg1;
bool thunder_hitbox_touch(entity this, entity toucher, vector top)
{
	if(toucher.flags & FL_PROJECTILE)
		return false;

	if(toucher == this || toucher.owner == this)
		return false;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return false;

	top.x += crandom() * 64;
	top.y += crandom() * 64;
	SendCSQCLightningBeam(top, toucher.origin);

	float damage = 70 + random() * 15;
	
	T_Damage(toucher, this, this, damage, WEP_STAFF.m_id | HITTYPE_MAGIC);
	return true;
}

void W_Staff_Attack_Thunder_Strike(entity actor, .entity weaponentity)
{
	entity this = actor.(weaponentity);
	if(this.vorg1 == '0 0 0' || STAT(MANA, actor) < 100)
		return; // what

	traceline(this.vorg1, this.vorg1 + '0 0 256', MOVE_NOMONSTERS, actor);
	vector top = trace_endpos;

	traceline(this.vorg1, this.vorg1 - '0 0 256', MOVE_NOMONSTERS, actor);
	vector bottom = trace_endpos;

	vector emin = bottom, emax = top;
	vector padding = '256 256 64';
	emin -= padding;
	emax += padding;

	bool didhit = false;

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != actor && (!actor.clipgroup || it.clipgroup != actor.clipgroup),
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			didhit |= thunder_hitbox_touch(actor, it, top);
	});

	if(didhit)
	{
		_sound(actor, CH_WEAPON_SINGLE, "ambience/thunder2.wav", 1, 0.5);
		W_TakeMana(actor, 100);
	}

	this.vorg1 = '0 0 0';
}

void wep_staff_thunder(entity this)
{
	if(this.m_frame >= 19)
	{
		W_Staff_Attack_Thunder_Strike(this.owner, this.weaponentity_fld);
		w_ready(this);
		return;
	}

	this.m_frame += 1;
	wep_set_anim(this, this.m_frame, wep_staff_thunder);
}

void thunder_think(entity this)
{
	this.nextthink = time + 0.1;
	this.frame += 1;
	if(this.frame > 9)
	{
		this.frame = 8;
		SUB_SetFade(this, time, 0.3);
	}
}

void W_Staff_Attack_Thunder_Charge(entity actor, .entity weaponentity)
{
	entity this = actor.(weaponentity);
	vector org = CENTER_OR_VIEWOFS(actor);

	entity rune = new(keyleth_cloud);
	rune.owner = rune.realowner = this;
	rune.solid = SOLID_NOT;
	rune.clipgroup = this.clipgroup;
	_setmodel(rune, "progs/staff_thunder.mdl");
	setsize(rune, '-16 -16 0', '16 16 16'); // dummy size for collision tests
	set_movetype(rune, MOVETYPE_NONE);
	setthink(rune, thunder_think);
	rune.nextthink = time + 0.1;
	rune.frame = 0;
	rune.alpha = 0.75;

	setorigin(rune, org);

	this.vorg1 = org;

	_sound(actor, CH_WEAPON_SINGLE, "ambience/wind2.wav", 1, 0.5);

	wep_set_anim(this, 9, wep_staff_thunder);
}

void vine_hitbox_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;

	if(toucher == this || toucher.owner == this)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;

	float damage = 12 + (random() * 5) + (random() * 5);
	
	T_Damage(toucher, this, this, damage, WEP_STAFF.m_id | HITTYPE_MAGIC);
}

void summon_vinepit(entity this, vector org, vector dir, int index)
{
	vector spot = keyleth_rune_getspot(this, org, dir, 400 * index);
	bool needtrace = true;
	if(spot == '0 0 0')
	{
		if(index > 1)
			return; // only fallback on the first, no overlapping
		needtrace = false;
		tracebox(this.origin, '-16 -16 0', '16 16 16', this.origin - '0 0 2048', MOVE_NOMONSTERS, this);
		spot = trace_endpos;
	}

	entity rune = new(keyleth_rune);
	rune.owner = rune.realowner = this;
	rune.solid = SOLID_NOT;
	rune.clipgroup = this.clipgroup;
	_setmodel(rune, "progs/staff_vines.mdl");
	setsize(rune, '-16 -16 0', '16 16 16'); // dummy size for collision tests
	rune.angles_y = random() * 360;
	set_movetype(rune, MOVETYPE_TOSS);

	if(needtrace)
		tracebox(spot + '0 0 1', '-16 -16 0', '16 16 16', spot - '0 0 2048', MOVE_NOMONSTERS, this);
	setorigin(rune, trace_endpos);

	FOREACH_ENTITY_RADIUS(rune.origin, 128, it != this && (!this.clipgroup || it.clipgroup != this.clipgroup),
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			vine_hitbox_touch(this, it);
	});

	SUB_SetFade(rune, time + 0.7, 0.3);
}

void W_Staff_Attack_Vine(entity this, .entity weaponentity)
{
	if(STAT(MANA, this) < 12)
		return; // incase it got drained

	W_TakeMana(this, 12);

	makevectors(this.angles);
	vector org = W_Shotorg(this, weaponentity);

	for(int j = 1; j <= 3; ++j)
	{
		summon_vinepit(this, org, v_forward, j);
	}
}

void W_Staff_Fire(entity thiswep, entity actor, .entity weaponentity)
{
	float attack_delay = 0;
	entity this = actor.(weaponentity);
	switch(STAT(STAFF_TYPE, actor))
	{
		default:
		case 0:
		{
			if(this.count)
				wep_staff_vineb1(this);
			else
				wep_staff_vinea1(this);
			this.count = (this.count) ? 0 : 1;
			attack_delay = 0.7;
			_sound(actor, CH_WEAPON_SINGLE, "weapons/staff_vine_fire.wav", 1, ATTN_NORM);
			break;
		}
		case 1: W_Staff_Attack_Thunder_Charge(actor, weaponentity); attack_delay = 2; break;
		case 2: wep_staff_blast1(this); attack_delay = 0.5; break;
	}

	weapon_prepareattack(thiswep, actor, weaponentity, attack_delay);
}

int W_Staff_GetCost(entity actor)
{
	switch(STAT(STAFF_TYPE, actor))
	{
		default:
		case 0: return 12;
		case 1: return 100;
		case 2: return 5;
	}
	return 12; // gmqcc
}

METHOD(Staff, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(!(fire & 1))
		actor.(weaponentity).count = 0;

	// checking secondary first as a page swap prevents attacking
	if(fire & 2)
	if(!(time < actor.attack2_finished))
	{
		STAT(STAFF_TYPE, actor) += 1;
		if(STAT(STAFF_TYPE, actor) > 2)
			STAT(STAFF_TYPE, actor) = 0;
		string swsound = "";
		switch(STAT(STAFF_TYPE, actor))
		{
			default:
			case 0: swsound = "weapons/staff_spell0.wav"; break;
			case 1: swsound = "weapons/staff_spell1.wav"; break;
			case 2: swsound = "weapons/staff_spell2.wav"; break;
		}
		_sound(actor, CH_WEAPON_B, swsound, 1, ATTN_NORM);
		ATTACK_FINISHED(actor, weaponentity) = max(ATTACK_FINISHED(actor, weaponentity), time + 0.25); // also prevent primary fire during this time
		actor.attack2_finished = time + 0.5; // slight delay between swapping, also prevents fireballs!
	}

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	if(STAT(MANA, actor) >= W_Staff_GetCost(actor))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		W_Staff_Fire(thiswep, actor, weaponentity);
	}
}
METHOD(Staff, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Staff, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Staff, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef CSQC
PRECACHE(Staff)
{
	precache_pic("particles/sunbeam");
}

.float teleport_time;
void Draw_Sunbeam(entity this)
{
	vector a, b;

	if (this.teleport_time && time > this.teleport_time)
	{
		sound(this, CH_SHOTS_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM); // safeguard
		this.teleport_time = 0;
	}

	InterpolateOrigin_Do(this);

	vector vs = '24 0 -12';

	if (this.owner.sv_entnum == (player_localentnum - 1) && ((player_localnum + 1) == player_localentnum))
	{
		if (autocvar_chase_active)
			a = csqcplayer.origin + csqcplayer.view_ofs;
		else
			a = view_origin + view_forward * vs.x + view_right * -vs.y + view_up * vs.z;
		b = this.velocity;
	}
	else
	{
		a = this.origin;
		b = this.velocity;
	}

	float intensity = 1;
	float offset = Noise_Brown(self, frametime) * 10;
	vector rgb = '1 1 1';
	string tex = "particles/sunbeam";

	Draw_CylindricLine(a, b, 8, tex, 0.25, offset, rgb, min(1, intensity), DRAWFLAG_NORMAL, view_origin);

	setorigin(this, a);

	pointparticles(EFFECT_SUNBEAM_MUZZLEFLASH, a, normalize(b - a) * 50, bound(0, frametime, 0.1));

	if(autocvar_r_drawviewmodel && !autocvar_chase_active && this.owner.sv_entnum == (player_localentnum - 1) && ((player_localnum + 1) == player_localentnum))
	{
		this.angles = vectoangles(b - a);
		this.angles.z = random() * 360;
		this.drawmask = MASK_NORMAL;
	}
	else
		this.drawmask = 0;

	if(this.count)
		pointparticles(EFFECT_DRILL_TOUCH, b, normalize(a - b), 0.2);
}

void Remove_Sunbeam(entity this)
{
	sound(this, CH_SHOTS_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM);
}

NET_HANDLE(ENT_CLIENT_SUNBEAM, bool isNew)
{
	int sf = ReadByte();
	this.silent = (sf & 0x80);
	this.count = (sf & 8);

	this.iflags = IFLAG_VELOCITY | IFLAG_ORIGIN;

	InterpolateOrigin_Undo(this);

	if (sf & 1)
	{
		this.sv_entnum = ReadByte();
		this.owner = playerslots[this.sv_entnum - 1];
	}
	if (sf & 2)
	{
		this.origin = ReadVector();
		setorigin(this, this.origin);
	}
	if (sf & 4)
		this.velocity = ReadVector();

	InterpolateOrigin_Note(this);

	if (isNew || !this.teleport_time)
	{
		this.draw = Draw_Sunbeam;
		if (!IL_CONTAINS(g_drawables, this))
			IL_PUSH(g_drawables, this);
		this.entremove = Remove_Sunbeam;

		if(autocvar_r_drawviewmodel)
		{
			this.drawmask = MASK_NORMAL;
			this.solid = SOLID_NOT;
			this.effects = EF_ADDITIVE | EF_FULLBRIGHT;
			this.avelocity.z = 5000;
			setmodel(this, MDL_SUNBEAM_MUZZLEFLASH);
			setsize(this, '0 0 0', '0 0 0');
			this.scale = 0.75;
		}

		if(!this.silent)
			_sound(this, CH_SHOTS_SINGLE, "weapons/sunbeam_loop.wav", 1, ATTEN_NORM);
	}

	this.teleport_time = time + 10;
	return true;
}
#endif
