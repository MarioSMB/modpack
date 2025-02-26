#include "mermaid.qh"

#ifdef SVQC
void mermaid_bubble_think(entity this)
{

}

void mermaid_bubble_shoot(entity this)
{
	makevectors(this.v_angle);
	vector dir = v_forward;
	vector spread = '0.1 0.1 0';
	dir += (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
	entity newmis = launch_spike(this, this.origin + this.view_ofs, dir);
	newmis.classname = "mermaid_bubble";
	_setmodel(newmis, "progs/s_bubble.spr");
	newmis.alpha = 0.75;
	newmis.scale = 5 + (random() * 2);
	newmis.avelocity = randomvec() * 200;
	newmis.dmg = 20;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.noise = "weapons/bubble_impact.wav";
	newmis.nextthink = time + 7;
	setthink(newmis, SUB_Remove);
	newmis.velocity = dir * 600;
	settouch(newmis, spike_touch);
	newmis.projectiledeathtype = WEP_MAGIC.m_id;
}

void mermaid_bubble5(entity this) { set_anim(this, 21, player_run); }
void mermaid_bubble4(entity this) { set_anim(this, 22, mermaid_bubble5); }
void mermaid_bubble3(entity this)
{
	set_anim(this, 23, mermaid_bubble4);
	mermaid_bubble_shoot(this);
}
void mermaid_bubble2(entity this) { set_anim(this, 22, mermaid_bubble3); }
void mermaid_bubble1(entity this) { set_anim(this, 21, mermaid_bubble2); }

METHOD(Mermaid, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "mermaid_start.wav", ATTN_NORM);

	STAT(WEAPONS, actor) |= WEP_MAGIC.m_wepset;
}

METHOD(Mermaid, m_weaponframe, bool(Champions this, entity actor, .entity weaponentity))
{
	// no regular weapon use!
	return true;
}

METHOD(Mermaid, m_playerthink, void(Champions this, entity actor))
{
	if(actor.m_transform == this && PHYS_INPUT_BUTTON_CROUCH(actor) && time >= STAT(QCC_ABILITYTIME, actor)) //&& QCC_CanCastAbility(actor))
	{
		actor.shantae_transformtime = time + 0.5; // prevent player voices on transform
		_sound(actor, CH_VOICE, "player_shantae/player_transform.wav", 1, ATTN_NORM);
		QCC_ClearTransform(actor);
		te_explosion2(actor.origin, 40, 7);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		return;
	}

	if(PHYS_INPUT_BUTTON_ATCK(actor) && actor.waterlevel >= WATERLEVEL_SWIMMING && actor.watertype == CONTENT_WATER && time > actor.mermaid_bubble_time && !actor.tank && !STAT(CANNON, actor))
	{
		_sound(actor, CH_VOICE, "weapons/bubble_shoot.wav", 1, ATTN_NORM);
		actor.mermaid_bubble_time = time + 0.5;
		mermaid_bubble1(actor);
	}
}

METHOD(Mermaid, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	_sound(actor, CH_TRIGGER_SINGLE, "shantae/h2odeath.wav", 1, ATTN_NORM);
	actor.mermaid_cannon = true;
}

METHOD(Mermaid, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.mermaid_cannon)
		return false;
	_sound(actor, CH_TRIGGER_SINGLE, "shantae/land2.wav", 1, ATTN_NORM);
	actor.mermaid_cannon = false;
	return false;
}
#endif
#ifdef CSQC
METHOD(Mermaid, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/mermaid_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
