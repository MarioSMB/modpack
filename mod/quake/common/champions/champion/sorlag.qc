#include "sorlag.qh"

#ifdef SVQC
METHOD(Sorlag, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

void Sorlag_AcidPoolTouch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER || toucher.health < 1 || toucher.takedamage == DAMAGE_NO || !Damage_ValidTarget(toucher, this.owner))
		return;
	if(toucher.m_champion == CHAMPION_Sorlag)
		return;
	if(!Damage_ValidTarget(toucher, this.owner))
		return;

	float poisontime = 7;
	float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, toucher);
	if((time + poisontime) > curtime)
		StatusEffects_apply(STATUSEFFECT_Poisoned, toucher, time + poisontime, 0);
}

void Sorlag_AcidPoolAnim(entity this)
{
	setthink(this, Sorlag_AcidPoolAnim);
	this.nextthink = time + 0.1;
	this.walkframe += 1;
	if(this.walkframe < 10)
		this.frame = this.walkframe;
	else
		delete(this);
}

void Sorlag_AcidSpitTouch(entity this, entity toucher)
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
		_setmodel(this, "progs/s_sorpool.mdl");
		setsize(this, '-12 -12 0', '12 12 4');
		setorigin(this, trace_endpos);

		vec = trace_plane_normal;
		this.angles = vectoangles(vec);
		this.angles_x -= 90;
		settouch(this, Sorlag_AcidPoolTouch);
		this.frame = 0;
		this.nextthink = time + 4.1;
		setthink(this, Sorlag_AcidPoolAnim);
	}
}

void Sorlag_AcidSpitAnim(entity this)
{
	setthink(this, Sorlag_AcidSpitAnim);
	this.nextthink = time + 0.1;
	particle(this.origin, '0 0 0', 57, 10);
	this.walkframe += 1;
	if(this.walkframe > 5)
		this.walkframe = 0;
	this.frame = this.walkframe;
	if(this.velocity == '0 0 0')
		delete(this);
}

void Sorlag_AcidSpit(entity this)
{
	entity newmis = new(acidspit);
	newmis.flags = FL_PROJECTILE;
	newmis.owner = this;
	newmis.realowner = this;
	set_movetype(newmis, MOVETYPE_TOSS);
	newmis.solid = SOLID_CORPSE;
	newmis.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	makevectors(this.v_angle);
	if(this.v_angle_x)
		newmis.velocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	else
	{
		newmis.velocity = qc_aim(this, 10000);
		newmis.velocity *= 600;
		newmis.velocity_z = 200;
	}

	newmis.poisonous = true;
	newmis.projectiledeathtype = WEP_NAPALM.m_id;
	newmis.clipgroup = this.clipgroup;
	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.avelocity);
	_setmodel(newmis, "progs/s_sorspit.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, this.origin + this.view_ofs);
	setthink(newmis, Sorlag_AcidSpitAnim);
	settouch(newmis, Sorlag_AcidSpitTouch);
	newmis.nextthink = time + 0.1;

	IL_PUSH(g_projectiles, newmis);
}

void Sorlag_AcidSpitProc(entity this)
{
	entity actor = this.owner;
	Sorlag_AcidSpit(actor);
	this.nextthink = time + 0.16;
	setthink(this, Sorlag_AcidSpitProc);

	this.cnt -= 1;
	if(this.cnt < 1)
		delete(this);
}

void Sorlag_Attack(entity this)
{
	player_sound(this, CH_WEAPON_B, "acidspit.wav", ATTN_NORM);
	Sorlag_AcidSpit(this);
	entity ent = spawn();
	setthink(ent, Sorlag_AcidSpitProc);
	ent.nextthink = time + 0.16;
	ent.owner = this;
	ent.cnt = 4;
}

METHOD(Sorlag, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		Sorlag_Attack(actor);
		STAT(QCC_ABILITYTIME, actor) = time + 1.3;
	}
}
#endif

#ifdef CSQC
METHOD(Sorlag, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/sorlag_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
