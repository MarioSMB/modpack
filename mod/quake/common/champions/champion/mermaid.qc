#include "mermaid.qh"

#ifdef SVQC
void mermaid_bubble_shoot(entity this)
{
	makevectors(this.v_angle);
	vector dir = v_forward;
	vector spread = '0.1 0.1 0';
	dir += (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
	entity newmis = launch_spike(this, this.origin + this.view_ofs, dir);
	newmis.classname = "mermaid_bubble";
	//_setmodel(newmis, "progs/s_bubble.spr");
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
	newmis.clipgroup = this.clipgroup;
	newmis.flags = FL_PROJECTILE;

	// already done by launch_spike TODO
	//IL_PUSH(g_projectiles, newmis);

	CSQCProjectile(newmis, true, PROJECTILE_MERMAID_BUBBLE, true);
}

void mermaid_bubble5(entity this) { set_anim(this, 21, player_run); }
void mermaid_bubble4(entity this) { set_anim(this, 22, mermaid_bubble5); }
void mermaid_bubble3(entity this)
{
	set_anim(this, 23, mermaid_bubble4);
	int bubblecnt = 1;
	if(this.waterlevel >= WATERLEVEL_SWIMMING && this.watertype == CONTENT_WATER)
		bubblecnt = 3;
	for(int j = 0; j < bubblecnt; ++j)
		mermaid_bubble_shoot(this);
}
void mermaid_bubble2(entity this) { set_anim(this, 22, mermaid_bubble3); }
void mermaid_bubble1(entity this) { set_anim(this, 21, mermaid_bubble2); }

METHOD(Mermaid, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Mermaid_Start, ATTN_NORM);

	Inventory_add(WEP_MAGIC, actor, ITEM_OWNED);
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
		sound(actor, CH_PLAYER, SND_Shantae_Transform, 1, ATTN_NORM);
		QCC_ClearTransform(actor);
		te_explosion2(actor.origin, 40, 7);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		return;
	}

	if(PHYS_INPUT_BUTTON_ATCK(actor) && time > actor.mermaid_bubble_time && !actor.tank && !STAT(CANNON, actor))
	{
		sound(actor, CH_WEAPON_B, SND_Mermaid_Shoot, 1, ATTN_NORM);
		actor.mermaid_bubble_time = time + 0.5;
		mermaid_bubble1(actor);
	}
}

METHOD(Mermaid, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_Mermaid_WaterDeath, ATTN_NORM);
	actor.mermaid_cannon = true;
}

METHOD(Mermaid, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.mermaid_cannon)
		return false;
	player_sound(actor, CH_PLAYER_SINGLE, SND_Mermaid_Fall, ATTN_NORM);
	actor.mermaid_cannon = false;
	return false;
}
#endif
#ifdef CSQC
METHOD(Mermaid, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/mermaid_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
