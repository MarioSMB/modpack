#include "juggernaut.qh"

#ifdef SVQC
void juggernaut_run1(entity this);
void juggernaut_pain6(entity this) { set_anim(this, 95, juggernaut_run1); ai_painforward(this, 1); }
void juggernaut_pain5(entity this) { set_anim(this, 94, juggernaut_pain6); ai_painforward(this, 1); }
void juggernaut_pain4(entity this) { set_anim(this, 93, juggernaut_pain5); ai_painforward(this, 1); }
void juggernaut_pain3(entity this) { set_anim(this, 92, juggernaut_pain4); ai_pain(this, 1); }
void juggernaut_pain2(entity this) { set_anim(this, 91, juggernaut_pain3); ai_pain(this, 1); }
void juggernaut_pain1(entity this) { set_anim(this, 90, juggernaut_pain2); ai_pain(this, 1); }

void juggernaut_pain(entity this, entity attacker, float damage, int deathtype)
{
	float r = random();
	if(r <= 0.3)
		_sound(this, CHAN_AUTO, "monsters/juggers/jshort2.wav", 1, ATTN_NORM);
	else if(r <= 0.6)
		_sound(this, CHAN_AUTO, "monsters/juggers/jshort3.wav", 1, ATTN_NORM);
	else if(r <= 0.9)
		_sound(this, CHAN_AUTO, "monsters/juggers/jshort4.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "monsters/juggers/jshort1.wav", 1, ATTN_NORM);
	if(random() < 0.2)
		_sound(this, CHAN_BODY, "monsters/juggers/jbent.wav", 1, ATTN_NORM);
	if(damage < ((this.health + damage) * 0.2))
		return;
	this.pain_finished = time + 1;
	juggernaut_pain1(this);
}

void JuggerCheckWater(entity this)
{
	if(time < this.pain_finished)
		return; // only so often so players can actually hurt it!
	if(this.watertype == CONTENT_WATER)
	{
		this.effects = EF_DIMLIGHT;
		T_Damage(this, NULL, NULL, 50 * this.waterlevel, DEATH_DROWN.m_id);
		juggernaut_pain(this, NULL, 50 * this.waterlevel, DEATH_DROWN.m_id);
		this.effects &= ~EF_DIMLIGHT;
	}
	else if(this.watertype == CONTENT_SLIME)
	{
		this.effects = EF_DIMLIGHT;
		T_Damage(this, NULL, NULL, 50 * this.waterlevel, DEATH_SLIME.m_id);
		juggernaut_pain(this, NULL, 50 * this.waterlevel, DEATH_SLIME.m_id);
		this.effects &= ~EF_DIMLIGHT;
	}
	else if(this.watertype == CONTENT_LAVA)
	{
		this.effects = EF_DIMLIGHT;
		T_Damage(this, NULL, NULL, 50 * this.waterlevel, DEATH_LAVA.m_id);
		juggernaut_pain(this, NULL, 50 * this.waterlevel, DEATH_LAVA.m_id);
		this.effects &= ~EF_DIMLIGHT;
	}
}

void juggernaut_death11(entity this) { set_anim(this, 106, juggernaut_death11); CorpseThink(this); }
void juggernaut_death10(entity this)
{
	set_anim(this, 105, juggernaut_death11);
	_sound(this, CHAN_ITEM, "monsters/juggers/jfalls.wav", 1, ATTN_NORM);
}
void juggernaut_death9(entity this) { set_anim(this, 104, juggernaut_death10); DropBackpack(this); }
void juggernaut_death8(entity this) { set_anim(this, 103, juggernaut_death9); }
void juggernaut_death7(entity this) { set_anim(this, 102, juggernaut_death8); }
void juggernaut_death6(entity this) { set_anim(this, 101, juggernaut_death7); }
void juggernaut_death5(entity this) { set_anim(this, 100, juggernaut_death6); }
void juggernaut_death4(entity this) { set_anim(this, 99, juggernaut_death5); ai_back(this, 4); }
void juggernaut_death3(entity this) { set_anim(this, 98, juggernaut_death4); }
void juggernaut_death2(entity this) { set_anim(this, 97, juggernaut_death3); ai_back(this, 4); }
void juggernaut_death1(entity this) { set_anim(this, 96, juggernaut_death2); this.solid = SOLID_NOT; }

void juggernaut_die2(entity this)
{
	if(this.mdl == "progs/jugg.mdl")
	{
		ThrowHead(this, this, "progs/h_jugg.mdl", this.health);
		ThrowGib(this, this, "progs/a_jugg.mdl", this.health);
	}
	else if(this.mdl == "progs/jugg2.mdl")
	{
		ThrowHead(this, this, "progs/h_jugg2.mdl", this.health);
		ThrowGib(this, this, "progs/a_jugg2.mdl", this.health);
	}
	T_RadiusDamage(this, this, 120, DEATH_MONSTER_JUGGERNAUT.m_id, this);
	_sound(this, CHAN_ITEM, "monsters/juggers/jgib.wav", 1, ATTN_NORM);
	setorigin(this, this.origin + '0 0 24');
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
}

void juggernaut_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -50)
	{
		setthink(this, juggernaut_die2);
		this.nextthink = time;
		return;
	}
	juggernaut_death1(this);
}

void juggernaut_idlea1(entity this);
void juggernaut_idlea16(entity this) { set_anim(this, 15, juggernaut_idlea1); ai_stand(this); }
void juggernaut_idlea15(entity this) { set_anim(this, 14, juggernaut_idlea16); ai_stand(this); }
void juggernaut_idlea14(entity this) { set_anim(this, 13, juggernaut_idlea15); ai_stand(this); }
void juggernaut_idlea13(entity this) { set_anim(this, 12, juggernaut_idlea14); ai_stand(this); }
void juggernaut_idlea12(entity this) { set_anim(this, 11, juggernaut_idlea13); ai_stand(this); }
void juggernaut_idlea11(entity this) { set_anim(this, 10, juggernaut_idlea12); ai_stand(this); }
void juggernaut_idlea10(entity this) { set_anim(this, 9, juggernaut_idlea11); ai_stand(this); }
void juggernaut_idlea9(entity this) { set_anim(this, 8, juggernaut_idlea10); ai_stand(this); }
void juggernaut_idlea8(entity this) { set_anim(this, 7, juggernaut_idlea9); ai_stand(this); }
void juggernaut_idlea7(entity this) { set_anim(this, 6, juggernaut_idlea8); ai_stand(this); }
void juggernaut_idlea6(entity this) { set_anim(this, 5, juggernaut_idlea7); ai_stand(this); }
void juggernaut_idlea5(entity this) { set_anim(this, 4, juggernaut_idlea6); ai_stand(this); }
void juggernaut_idlea4(entity this) { set_anim(this, 3, juggernaut_idlea5); ai_stand(this); }
void juggernaut_idlea3(entity this) { set_anim(this, 2, juggernaut_idlea4); ai_stand(this); }
void juggernaut_idlea2(entity this) { set_anim(this, 1, juggernaut_idlea3); ai_stand(this); }
void juggernaut_idlea1(entity this)
{
	set_anim(this, 0, juggernaut_idlea2);
	ai_stand(this);
	if(random() < 0.2)
		_sound(this, CHAN_AUTO, "monsters/juggers/jidle.wav", 1, ATTN_NORM);
}

void juggernaut_idleb1(entity this);
void juggernaut_idleb16(entity this) { set_anim(this, 31, juggernaut_idleb1); ai_stand(this); }
void juggernaut_idleb15(entity this) { set_anim(this, 30, juggernaut_idleb16); ai_stand(this); }
void juggernaut_idleb14(entity this) { set_anim(this, 29, juggernaut_idleb15); ai_stand(this); }
void juggernaut_idleb13(entity this) { set_anim(this, 28, juggernaut_idleb14); ai_stand(this); }
void juggernaut_idleb12(entity this) { set_anim(this, 27, juggernaut_idleb13); ai_stand(this); }
void juggernaut_idleb11(entity this) { set_anim(this, 26, juggernaut_idleb12); ai_stand(this); }
void juggernaut_idleb10(entity this) { set_anim(this, 25, juggernaut_idleb11); ai_stand(this); }
void juggernaut_idleb9(entity this) { set_anim(this, 24, juggernaut_idleb10); ai_stand(this); }
void juggernaut_idleb8(entity this) { set_anim(this, 23, juggernaut_idleb9); ai_stand(this); }
void juggernaut_idleb7(entity this) { set_anim(this, 22, juggernaut_idleb8); ai_stand(this); }
void juggernaut_idleb6(entity this) { set_anim(this, 21, juggernaut_idleb7); ai_stand(this); }
void juggernaut_idleb5(entity this) { set_anim(this, 20, juggernaut_idleb6); ai_stand(this); }
void juggernaut_idleb4(entity this) { set_anim(this, 19, juggernaut_idleb5); ai_stand(this); }
void juggernaut_idleb3(entity this) { set_anim(this, 18, juggernaut_idleb4); ai_stand(this); }
void juggernaut_idleb2(entity this) { set_anim(this, 17, juggernaut_idleb3); ai_stand(this); }
void juggernaut_idleb1(entity this)
{
	set_anim(this, 16, juggernaut_idleb2);
	ai_stand(this);
	if(random() < 0.2)
		_sound(this, CHAN_AUTO, "monsters/juggers/jidle.wav", 1, ATTN_NORM);
}

void juggernaut_idle(entity this)
{
	if(random() < 0.5)
		juggernaut_idlea1(this);
	else
		juggernaut_idleb1(this);
}

void juggernaut_walk1(entity this);
void juggernaut_walk10(entity this)
{
	set_anim(this, 41, juggernaut_walk1);
	ai_walk(this, 8);
	JuggerCheckWater(this);
}
void juggernaut_walk9(entity this)
{
	set_anim(this, 40, juggernaut_walk10);
	ai_walk(this, 4);
	JuggerCheckWater(this);
}
void juggernaut_walk8(entity this)
{
	set_anim(this, 39, juggernaut_walk9);
	ai_walk(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_walk7(entity this)
{
	set_anim(this, 38, juggernaut_walk8);
	ai_walk(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_walk6(entity this)
{
	set_anim(this, 37, juggernaut_walk7);
	ai_walk(this, 4);
	JuggerCheckWater(this);
	_sound(this, CHAN_ITEM, "monsters/juggers/jstep2.wav", 0.25, ATTN_NORM);
	if(random() <= 0.2 && this.health < (this.max_health * 0.4))
	{
		if(random() <= 0.2)
			_sound(this, CHAN_AUTO, "monsters/juggers/jshort3.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "monsters/juggers/jshort2.wav", 1, ATTN_NORM);
	}
}
void juggernaut_walk5(entity this)
{
	set_anim(this, 36, juggernaut_walk6);
	ai_walk(this, 8);
	JuggerCheckWater(this);
}
void juggernaut_walk4(entity this)
{
	set_anim(this, 35, juggernaut_walk5);
	ai_walk(this, 4);
	JuggerCheckWater(this);
}
void juggernaut_walk3(entity this)
{
	set_anim(this, 34, juggernaut_walk4);
	ai_walk(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_walk2(entity this)
{
	set_anim(this, 33, juggernaut_walk3);
	ai_walk(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_walk1(entity this)
{
	set_anim(this, 32, juggernaut_walk2);
	ai_walk(this, 8);
	JuggerCheckWater(this);
	_sound(this, CHAN_ITEM, "monsters/juggers/jstep1.wav", 0.5, ATTN_NORM);
	if(random() <= 0.4)
		_sound(this, CHAN_AUTO, "monsters/juggers/jwhir.wav", 1, ATTN_NORM);
	if(random() <= 0.3)
		_sound(this, CHAN_AUTO, "monsters/juggers/jidle.wav", 1, ATTN_NORM);
}

void juggernaut_run1(entity this);
void juggernaut_run10(entity this)
{
	set_anim(this, 41, juggernaut_run1);
	ai_run(this, 16);
	JuggerCheckWater(this);
}
void juggernaut_run9(entity this)
{
	set_anim(this, 40, juggernaut_run10);
	ai_run(this, 8);
	JuggerCheckWater(this);
}
void juggernaut_run8(entity this)
{
	set_anim(this, 39, juggernaut_run9);
	ai_run(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_run7(entity this)
{
	set_anim(this, 38, juggernaut_run8);
	ai_run(this, 4);
	JuggerCheckWater(this);
}
void juggernaut_run6(entity this)
{
	set_anim(this, 37, juggernaut_run7);
	ai_run(this, 0);
	_sound(this, CHAN_ITEM, "monsters/juggers/jstep1.wav", 0.25, ATTN_NORM);
	if(random() <= 0.2 && this.health < (this.max_health * 0.4))
		_sound(this, CHAN_AUTO, "monsters/juggers/jshort4.wav", 1, ATTN_NORM);
}
void juggernaut_run5(entity this)
{
	set_anim(this, 36, juggernaut_run6);
	ai_run(this, 8);
	JuggerCheckWater(this);
}
void juggernaut_run4(entity this)
{
	set_anim(this, 35, juggernaut_run5);
	ai_run(this, 16);
	JuggerCheckWater(this);
}
void juggernaut_run3(entity this)
{
	set_anim(this, 34, juggernaut_run4);
	ai_run(this, 8);
	JuggerCheckWater(this);
}
void juggernaut_run2(entity this)
{
	set_anim(this, 33, juggernaut_run3);
	ai_run(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_run1(entity this)
{
	set_anim(this, 32, juggernaut_run2);
	ai_run(this, 0);
	if(random() <= 0.5)
		_sound(this, CHAN_ITEM, "monsters/juggers/jstep3.wav", 0.5, ATTN_NORM);
	else
		_sound(this, CHAN_ITEM, "monsters/juggers/jstep2.wav", 0.5, ATTN_NORM);
}

void juggernaut_rocket_touch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float damg = (50 + (random() * 10));
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}
	T_RadiusDamage(this, this.owner, 60, this.projectiledeathtype, toucher);
	setorigin(this, this.origin - (8 * normalize(this.velocity)));
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	BecomeExplosion(this);
}
void juggernaut_firea6(entity this);

void juggernaut_launch_rocket(entity this)
{
	ai_face(this);
	_sound(this, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	entity newmis = spawn();
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;
	newmis.classname = "juggy_rocket";
	newmis.projectiledeathtype = DEATH_MONSTER_JUGGERNAUT.m_id;
	makevectors(this.angles);
	float ammo = this.ammo_rockets;
	vector forward = (v_forward * 30);
	vector right, up;
	if((ammo / 3) == floor(ammo / 3))
		right = v_right * 35;
	else if(((ammo + 1) / 3) == floor ((ammo + 1) / 3))
		right = v_right * 31;
	else
		right = v_right * 27;
	if((ceil((ammo / 3)) / 2) == floor((ceil((ammo / 3)) / 2)))
		up = '0 0 40';
	else
		up = '0 0 32';
	vector org = this.origin + forward + right + up;
	vector vec = (this.enemy.origin + '0 0 16') - (this.origin + forward + (v_right * 31) + '0 0 36');
	vec = normalize(vec);
	newmis.velocity = (vec * 1000);
	newmis.angles = vectoangles(newmis.velocity);
	settouch(newmis, juggernaut_rocket_touch);
	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	_setmodel(newmis, "progs/missile.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
	newmis.effects = EF_MUZZLEFLASH;
	this.ammo_rockets = (this.ammo_rockets - 1);
	this.count = (this.count + 1);
	if(this.count < floor(((random() * (autocvar_skill + 1)) * 1.5)) && this.ammo_rockets > 0)
		juggernaut_firea6(this);
}

void juggernaut_laser_touch(entity this, entity toucher)
{
	if(toucher.solid == SOLID_TRIGGER)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	if(toucher.takedamage)
	{
		spawn_touchblood(this, 15, toucher);
		T_Damage(toucher, this, this.owner, 15, this.projectiledeathtype);
	}
	_sound(this, CHAN_BODY, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	delete(this);
}

void juggernaut_fire_chain(entity this)
{
	ai_face(this);
	if(this.ammo_cells < 1)
	{
		_sound(this, CHAN_WEAPON, "monsters/juggers/jwhir.wav", 1, ATTN_NORM);
		return;
	}
	if(random() <= 0.2)
		_sound(this, CHAN_AUTO, "monsters/juggers/jwhir.wav", 1, ATTN_NORM);
	_sound(this, CHAN_WEAPON, "monsters/juggers/jshot.wav", 1, ATTN_NORM);
	makevectors(this.angles);
	vector org = (((this.origin + (v_forward * 10)) - (v_right * 30)) + '0 0 60');
	vector dir = ((this.enemy.origin + '0 0 16') - (this.enemy.velocity * 0.2));
	dir = normalize(dir - org);
	entity newmis = launch_spike(this, org, dir);
	newmis.projectiledeathtype = DEATH_MONSTER_JUGGERNAUT.m_id;
	_setmodel(newmis, "progs/laser.mdl");
	settouch(newmis, juggernaut_laser_touch);
	newmis.effects = EF_MUZZLEFLASH;
	this.ammo_cells = this.ammo_cells - 1;
}

void juggernaut_firea14(entity this)
{
	set_anim(this, 53, juggernaut_run1);
	ai_face(this);
	JuggerCheckWater(this);
}
void juggernaut_firea13(entity this) { set_anim(this, 52, juggernaut_firea14); ai_face(this); }
void juggernaut_firea12(entity this) { set_anim(this, 52, juggernaut_firea13); ai_face(this); }
void juggernaut_firea11(entity this) { set_anim(this, 52, juggernaut_firea12); ai_face(this); }
void juggernaut_firea10(entity this) { set_anim(this, 51, juggernaut_firea11); ai_face(this); }
void juggernaut_firea9(entity this) { set_anim(this, 50, juggernaut_firea10); ai_face(this); }
void juggernaut_firea8(entity this)
{
	set_anim(this, 49, juggernaut_firea9);
	ai_face(this);
	juggernaut_launch_rocket(this);
}
void juggernaut_firea7(entity this) { set_anim(this, 48, juggernaut_firea8); ai_face(this); }
void juggernaut_firea6(entity this)
{
	set_anim(this, 47, juggernaut_firea7);
	ai_face(this);
	JuggerCheckWater(this);
}
void juggernaut_firea5(entity this) { set_anim(this, 46, juggernaut_firea6); ai_face(this); }
void juggernaut_firea4(entity this)
{
	set_anim(this, 45, juggernaut_firea5);
	ai_face(this);
	_sound(this, CHAN_VOICE, "monsters/juggers/jlocked.wav", 1, ATTN_NORM);
}
void juggernaut_firea3(entity this) { set_anim(this, 44, juggernaut_firea4); ai_face(this); }
void juggernaut_firea2(entity this) { set_anim(this, 43, juggernaut_firea3); ai_face(this); }
void juggernaut_firea1(entity this)
{
	set_anim(this, 42, juggernaut_firea2);
	ai_face(this);
	JuggerCheckWater(this);
	this.count = 0;
}

void juggernaut_fireb1(entity this);
void juggernaut_fireb4(entity this)
{
	set_anim(this, 59, juggernaut_fireb1);
	juggernaut_fire_chain(this);
	entity targ = this.enemy;
	vector spot1 = (this.origin + this.view_ofs);
	vector spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, false, this);
	if(trace_ent != targ || (trace_inopen && trace_inwater) || random() < 0.3)
	{
		juggernaut_run1(this);
		return;
	}
}
void juggernaut_fireb3(entity this) { set_anim(this, 58, juggernaut_fireb4); ai_face(this); }
void juggernaut_fireb2(entity this) { set_anim(this, 57, juggernaut_fireb3); juggernaut_fire_chain(this); }
void juggernaut_fireb1(entity this) { set_anim(this, 56, juggernaut_fireb2); ai_face(this); }

void juggernaut_walkfire1(entity this);
void juggernaut_walkfire10(entity this)
{
	set_anim(this, 69, juggernaut_walkfire1);

	ai_walk(this, 4);
	juggernaut_fire_chain(this);
	entity targ = this.enemy;
	vector spot1 = (this.origin + this.view_ofs);
	vector spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, false, this);
	if(trace_ent != targ || (trace_inopen && trace_inwater) || random() < 0.5)
	{
		juggernaut_run1(this);
		return;
	}
}
void juggernaut_walkfire9(entity this)
{
	set_anim(this, 68, juggernaut_walkfire10);
	ai_walk(this, 8);
	JuggerCheckWater(this);
}
void juggernaut_walkfire8(entity this)
{
	set_anim(this, 67, juggernaut_walkfire9);
	ai_walk(this, 4);
	juggernaut_fire_chain(this);
}
void juggernaut_walkfire7(entity this) { set_anim(this, 66, juggernaut_walkfire8); ai_walk(this, 0); }
void juggernaut_walkfire6(entity this)
{
	set_anim(this, 65, juggernaut_walkfire7);
	ai_walk(this, 0);
	juggernaut_fire_chain(this);
	if(random() <= 0.5)
		_sound(this, CHAN_ITEM, "monsters/juggers/jstep3.wav", 0.25, ATTN_NORM);
	else
		_sound(this, CHAN_ITEM, "monsters/juggers/jstep1.wav", 0.25, ATTN_NORM);
}
void juggernaut_walkfire5(entity this)
{
	set_anim(this, 64, juggernaut_walkfire6);
	ai_walk(this, 4);
	JuggerCheckWater(this);
}
void juggernaut_walkfire4(entity this)
{
	set_anim(this, 63, juggernaut_walkfire5);
	ai_walk(this, 8);
	juggernaut_fire_chain(this);
}
void juggernaut_walkfire3(entity this) { set_anim(this, 62, juggernaut_walkfire4); ai_walk(this, 4); }
void juggernaut_walkfire2(entity this)
{
	set_anim(this, 61, juggernaut_walkfire3);
	ai_walk(this, 0);
	JuggerCheckWater(this);
	juggernaut_fire_chain(this);
}
void juggernaut_walkfire1(entity this)
{
	set_anim(this, 60, juggernaut_walkfire2);
	ai_walk(this, 0);
	if(random() <= 0.5)
		_sound(this, CHAN_ITEM, "monsters/juggers/jstep1.wav", 0.25, ATTN_NORM);
	else
		_sound(this, CHAN_ITEM, "monsters/juggers/jstep2.wav", 0.25, ATTN_NORM);
}

void juggernaut_fire(entity this)
{
	if(random() < 0.2)
	{
		if(random() < 0.65 && this.ammo_rockets > 0)
		{
			if(this.health < (this.max_health / 2))
				_sound(this, CHAN_BODY, "monsters/juggers/jhydro2.wav", 1, ATTN_NORM);
			else
				_sound(this, CHAN_BODY, "monsters/juggers/jhydro3.wav", 1, ATTN_NORM);
			juggernaut_firea1(this);
		}
		else if(this.ammo_cells > 0)
		{
			_sound(this, CHAN_BODY, "monsters/juggers/jhydro1.wav", 1, ATTN_NORM);
			if(this.frame == 32)
				juggernaut_walkfire1(this);
			else if(this.frame == 33)
				juggernaut_walkfire2(this);
			else if(this.frame == 34)
				juggernaut_walkfire3(this);
			else if(this.frame == 35)
				juggernaut_walkfire4(this);
			else if(this.frame == 36)
				juggernaut_walkfire5(this);
			else if(this.frame == 37)
				juggernaut_walkfire6(this);
			else if(this.frame == 38)
				juggernaut_walkfire7(this);
			else if(this.frame == 39)
				juggernaut_walkfire8(this);
			else if(this.frame == 40)
				juggernaut_walkfire9(this);
			else if(this.frame == 41)
				juggernaut_walkfire10(this);
		}
	}
}

void juggernaut_ai_melee(entity this, int deathtype)
{
	if(!this.enemy)
		return;
	float r = random();
	if(vdist(this.enemy.origin - this.origin, <=, 80))
	{
		float ldmg = (((random() + random()) + random()) * 15);
		T_Damage(this.enemy, this, this, ldmg, deathtype);
		if(r <= 0.3)
			_sound(this, CHAN_WEAPON, "monsters/juggers/jwhap1.wav", 1, ATTN_NORM);
		else if(r <= 0.6)
			_sound(this, CHAN_WEAPON, "monsters/juggers/jwhap2.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_WEAPON, "monsters/juggers/jwhap3.wav", 1, ATTN_NORM);
	}
	else if(r <= 0.3)
		_sound(this, CHAN_WEAPON, "monsters/juggers/jswipe1.wav", 1, ATTN_NORM);
	else if(r <= 0.6)
		_sound(this, CHAN_WEAPON, "monsters/juggers/jswipe2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_WEAPON, "monsters/juggers/jswipe3.wav", 1, ATTN_NORM);
}

void juggernaut_melee12(entity this) { set_anim(this, 81, juggernaut_run1); ai_charge(this, 0); }
void juggernaut_melee11(entity this) { set_anim(this, 80, juggernaut_melee12); ai_charge(this, 0); }
void juggernaut_melee10(entity this) { set_anim(this, 79, juggernaut_melee11); ai_charge(this, 4); }
void juggernaut_melee9(entity this)
{
	set_anim(this, 78, juggernaut_melee10);
	ai_charge(this, 4);
	juggernaut_ai_melee(this, DEATH_MONSTER_JUGGERNAUT.m_id);
}
void juggernaut_melee8(entity this)
{
	set_anim(this, 77, juggernaut_melee9);
	ai_charge(this, 8);
	juggernaut_ai_melee(this, DEATH_MONSTER_JUGGERNAUT.m_id);
}
void juggernaut_melee7(entity this) { set_anim(this, 76, juggernaut_melee8); ai_charge(this, 8); }
void juggernaut_melee6(entity this) { set_anim(this, 75, juggernaut_melee7); ai_charge(this, 4); }
void juggernaut_melee5(entity this)
{
	set_anim(this, 74, juggernaut_melee6);
	ai_charge(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_melee4(entity this)
{
	set_anim(this, 73, juggernaut_melee5);
	ai_charge(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_melee3(entity this)
{
	set_anim(this, 72, juggernaut_melee4);
	ai_charge(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_melee2(entity this)
{
	set_anim(this, 71, juggernaut_melee3);
	ai_charge(this, 0);
	JuggerCheckWater(this);
}
void juggernaut_melee1(entity this)
{
	set_anim(this, 70, juggernaut_melee2);
	ai_charge(this, 0);
	JuggerCheckWater(this);
}

void juggernaut_meleeb8(entity this) { set_anim(this, 89, juggernaut_run1); ai_charge(this, 0); }
void juggernaut_meleeb7(entity this) { set_anim(this, 88, juggernaut_meleeb8); ai_charge(this, 0); }
void juggernaut_meleeb6(entity this)
{
	set_anim(this, 87, juggernaut_meleeb7);
	ai_charge(this, 0);
	juggernaut_ai_melee(this, DEATH_MONSTER_JUGGERNAUT.m_id);
	juggernaut_ai_melee(this, DEATH_MONSTER_JUGGERNAUT.m_id);
}
void juggernaut_meleeb5(entity this) { set_anim(this, 86, juggernaut_meleeb6); ai_charge(this, 0); }
void juggernaut_meleeb4(entity this) { set_anim(this, 85, juggernaut_meleeb5); ai_charge(this, 0); }
void juggernaut_meleeb3(entity this) { set_anim(this, 84, juggernaut_meleeb4); ai_charge(this, 0); }
void juggernaut_meleeb2(entity this) { set_anim(this, 83, juggernaut_meleeb3); ai_charge(this, 0); }
void juggernaut_meleeb1(entity this) { set_anim(this, 82, juggernaut_meleeb2); ai_charge(this, 0); }

void juggernaut_melee(entity this)
{
	if(vdist((this.enemy.origin + this.enemy.view_ofs) - (this.origin + this.view_ofs), <, 80))
		juggernaut_meleeb1(this);
	else
		juggernaut_melee1(this);
}

spawnfunc(monster_juggernaut)
{
	monster_start(this, true, MON_JUGGERNAUT);
}
// TODO: separate monster!
spawnfunc(monster_juggernaut2)
{
	monster_start(this, true, MON_JUGGERNAUT);
}
#endif // SVQC

#ifdef SVQC
METHOD(Juggernaut, mr_setup, bool(Juggernaut this, entity actor))
{
    TC(Juggernaut, this);

	precache_model("progs/a_jugg.mdl");
	precache_model("progs/a_jugg2.mdl");
	precache_model("progs/laser.mdl");
	precache_sound("enforcer/enfstop.wav");
	precache_sound("monsters/juggers/jbent.wav");
	precache_sound("monsters/juggers/jshot.wav");
	precache_sound("monsters/juggers/jhydro1.wav");
	precache_sound("monsters/juggers/jhydro2.wav");
	precache_sound("monsters/juggers/jhydro3.wav");
	precache_sound("monsters/juggers/jidle.wav");
	precache_sound("monsters/juggers/jstep1.wav");
	precache_sound("monsters/juggers/jstep2.wav");
	precache_sound("monsters/juggers/jstep3.wav");
	precache_sound("monsters/juggers/jshort1.wav");
	precache_sound("monsters/juggers/jshort2.wav");
	precache_sound("monsters/juggers/jshort3.wav");
	precache_sound("monsters/juggers/jshort4.wav");
	precache_sound("monsters/juggers/jwhap1.wav");
	precache_sound("monsters/juggers/jwhap2.wav");
	precache_sound("monsters/juggers/jwhap3.wav");
	precache_sound("monsters/juggers/jwhir.wav");
	precache_sound("monsters/juggers/jfalls.wav");
	precache_sound("monsters/juggers/jswipe1.wav");
	precache_sound("monsters/juggers/jswipe2.wav");
	precache_sound("monsters/juggers/jswipe3.wav");
	precache_sound("monsters/juggers/jgib.wav");

	float r = random();
	if(r <= 0.5)
		actor.mdl = "progs/jugg.mdl";
	else
		actor.mdl = "progs/jugg2.mdl";
	_setmodel(actor, actor.mdl);
	setsize(actor, this.m_mins, this.m_maxs);

    actor.health = 1000;
	actor.th_stand = juggernaut_idle;
	actor.th_walk = juggernaut_walk1;
	actor.th_run = juggernaut_run1;
	actor.th_die = juggernaut_die;
	actor.th_melee = juggernaut_melee;
	actor.th_missile = juggernaut_fire;
	actor.th_pain = juggernaut_pain;
	actor.ammo_rockets = 18;
	actor.ammo_cells = 30;

    return true;
}
#endif
