#include "pepsiman.qh"

#ifdef SVQC
void can_think(entity this)
{
	this.nextthink = time;
	setthink(this, can_think);

	if(this.alpha == 0)
		this.alpha = 1;
	if(time >= this.delay)
		this.alpha -= frametime * this.fade_rate;

	if(this.alpha < 0.01 || time >= this.wait)
	{
		delete(this);
		return;
	}

	FOREACH_ENTITY_RADIUS(this.origin, this.cnt, it != this.owner && it.takedamage && Damage_ValidTarget(it, this.owner),
	{
		if(time < it.pain_finished)
			continue;
		if(!boxesoverlap(it.absmin, it.absmax, this.absmin, this.absmax))
			continue;
		T_Damage(it, this, this.owner, 60, DEATH_CRUSH.m_id);
	});
}

void Pepsiman_ThrowCan(entity this)
{
	makevectors('0 1 0' * this.angles_y);

	vector org = this.origin - v_forward * 150;
	//org.z -= 24;

	entity can = new(can);
	can.owner = this;
	setorigin(can, org);
	set_movetype(can, MOVETYPE_NOCLIP);
	can.angles_y = this.angles_y;
	can.avelocity = '-180 0 0';
	setmodel(can, MDL_CAN);
	can.cnt = 96; // rough bounding box for cheaper math, update if hitbox is changed!
	setsize(can, '-48 -48 0', '48 48 48');
	//SUB_SetFade(can, time + 1, 0.7);
	can.fade_rate = 1.4;
	setthink(can, can_think);
	can.nextthink = time;
	can.delay = time + 1;
	can.wait = time + 1.7;
	can.velocity = v_forward * 500;
	//settouch(can, can_touch); // due to collision issues (TODO?) touch interactions don't work

	_sound(can, CH_TRIGGER_SINGLE, "player_pepsiman/can_roll.wav", 1, 0.5);
}

METHOD(Pepsiman, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Pepsiman, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		STAT(QCC_ABILITYTIME, actor) = time + 2;
		Pepsiman_ThrowCan(actor);
	}
}

METHOD(Pepsiman, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "death2.wav", ATTN_NORM);
	actor.pepsiman_cannon = true;
}

METHOD(Pepsiman, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.pepsiman_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.pepsiman_cannon = false;
	return false;
}
#endif

#ifdef CSQC
float pepsiman_facetime = 0;
int pepsiman_face = 0;
METHOD(Pepsiman, m_drawface, bool(Champions this))
{
	if(time >= pepsiman_facetime)
	{
		pepsiman_face += 1;
		if(pepsiman_face > 9)
			pepsiman_face = 0;
		pepsiman_facetime = time + 0.1;
	}
	string pic = strcat("gfx/quake/pepsiman_face_", ftos(pepsiman_face));
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
