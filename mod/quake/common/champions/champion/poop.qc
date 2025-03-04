#include "poop.qh"

#ifdef SVQC
int autocvar_sv_quake_poop_count = 4;

METHOD(Poop, m_activate, void(Poop this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

void Poop_AcidPoolTouch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER || toucher.health < 1 || toucher.takedamage == DAMAGE_NO || !Damage_ValidTarget(toucher, this.owner))
		return;
	if(toucher.m_champion == CHAMPION_Poop)
		return;
	if(!Damage_ValidTarget(toucher, this.owner))
		return;

	float poisontime = 7;
	float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, toucher);
	if((time + poisontime) > curtime)
		StatusEffects_apply(STATUSEFFECT_Poisoned, toucher, time + poisontime, 0);
}

void Poop_AcidPoolAnim(entity this)
{
	setthink(this, Poop_AcidPoolAnim);
	this.nextthink = time + 0.1;
	this.walkframe += 1;
	if(this.walkframe < 10)
		this.frame = this.walkframe;
	else
		delete(this);
}

void Poop_PooSpitTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) < CONTENT_WATER)
	{
		delete(this);
		return;
	}

	particle(this.origin, '0 0 0', 57, 50);
	_sound(this, CH_WEAPON_SINGLE, "blob/land1.wav", 1, ATTN_NORM);

	if(toucher.takedamage || IS_MONSTER(toucher))
	{
		float damage = 15;
		T_Damage(toucher, this, this.owner, damage, this.projectiledeathtype);
		if(toucher.move_movetype != MOVETYPE_PUSH)
			return;
	}

	vector vel_norm = normalize(this.velocity);
	vector vec = this.origin - vel_norm;
	traceline(vec, vec + vel_norm * 16, false, this);
	if(trace_fraction < 1)
	{
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_TRIGGER;
		this.colormod = '0.54 0.27 0.07';
		_setmodel(this, "progs/s_mayo.mdl");
		setsize(this, '-12 -12 0', '12 12 4');
		setorigin(this, trace_endpos);

		vec = trace_plane_normal;
		this.angles = vectoangles(vec);
		this.angles_x -= 90;
		settouch(this, Poop_AcidPoolTouch);
		this.frame = 0;
		this.nextthink = time + 4.1;
		setthink(this, Poop_AcidPoolAnim);
	}
}

void Poop_PooSpitAnim(entity this)
{
	setthink(this, Poop_PooSpitAnim);
	this.nextthink = time + 0.1;
	particle(this.origin, '0 0 0', 57, 10);
	this.walkframe += 1;
	if(this.walkframe > 5)
		this.walkframe = 0;
	this.frame = this.walkframe;
	if(this.velocity == '0 0 0')
		delete(this);
}

void Poop_PooSpit(entity this)
{
	entity newmis = new(acidspit);
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_TOSS);
	newmis.solid = SOLID_CORPSE;
	newmis.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	newmis.velocity = randomvec() * 400;
	newmis.velocity_z = 100;

	newmis.poisonous = true;
	newmis.projectiledeathtype = WEP_NAPALM.m_id;
	newmis.clipgroup = this.clipgroup;
	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.avelocity);
	newmis.colormod = '0.54 0.27 0.07';
	_setmodel(newmis, "progs/s_sorspit.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, this.origin + this.view_ofs);
	setthink(newmis, Poop_PooSpitAnim);
	settouch(newmis, Poop_PooSpitTouch);
	newmis.nextthink = time + 0.1;
}

void Poop_PooSpitProc(entity this)
{
	entity actor = this.owner;
	Poop_PooSpit(actor);
	this.nextthink = time + 0.16;
	setthink(this, Poop_PooSpitProc);

	this.cnt -= 1;
	if(this.cnt < 1)
		delete(this);
}

void Poop_Attack(entity this)
{
	if(random() < 0.2)
		player_sound(this, CH_WEAPON_B, "death1.wav", ATTN_NORM);
	else
		player_sound(this, CH_WEAPON_B, "pain1.wav", ATTN_NORM);
	Poop_PooSpit(this);
	entity ent = spawn();
	setthink(ent, Poop_PooSpitProc);
	ent.nextthink = time + 0.16;
	ent.owner = this;
	ent.cnt = autocvar_sv_quake_poop_count;
}

METHOD(Poop, m_playerthink, void(Champions this, entity actor))
{
	if(time > actor.poop_particletime)
	{
		actor.poop_particletime = time + 20 + (random() * 4);
		Send_Effect(EFFECT_POOP_STINK, actor.origin, '0 0 0', 1);
	}

	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		Poop_Attack(actor);
		STAT(QCC_ABILITYTIME, actor) = time + 1.3;
	}
}

METHOD(Poop, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.poop_cannon = true;
}

METHOD(Poop, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.poop_cannon)
		return false;
	player_sound(actor, CH_TRIGGER_SINGLE, "land2.wav", ATTN_NORM);
	actor.poop_cannon = false;
	actor.jump_flag = 0;
	return true;
}
#endif

#ifdef CSQC
METHOD(Poop, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/poop_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
