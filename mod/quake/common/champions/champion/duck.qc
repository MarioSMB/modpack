#include "duck.qh"

#ifdef SVQC
entity grape_launch(entity this, vector org, vector dir)
{
	vector spread = '0.1 0.1 0';
	dir += (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
	entity newmis = launch_spike(this, org, dir);
	newmis.classname = "grape";
	newmis.avelocity = randomvec() * 200;
	newmis.dmg = 20;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.noise = "weapons/grape_impact.wav";
	newmis.nextthink = time + 7;
	setthink(newmis, SUB_Remove);
	newmis.velocity = dir * 300;
	settouch(newmis, spike_touch);
	newmis.projectiledeathtype = DEATH_GRAPE.m_id;
	newmis.clipgroup = this.clipgroup;
	newmis.flags = FL_PROJECTILE;

	CSQCProjectile(newmis, true, PROJECTILE_GRAPE, true);

	return newmis;
}

void grape_delayedlaunch(entity this)
{
	entity player = this.owner;
	if(!player || player.health <= 0 || player.m_champion != CHAMPION_Duck || !IS_PLAYER(player))
	{
		delete(this);
		return;
	}
	makevectors(player.v_angle);
	vector org = player.origin + player.view_ofs;

	grape_launch(player, org, v_forward);

	delete(this);
}

void Duck_ShootGrapes(entity this)
{
	for(int j = 0; j < 5; ++j)
	{
		entity grape = spawn();
		grape.classname = "grape_delayed";
		grape.owner = this;
		setthink(grape, grape_delayedlaunch);
		grape.nextthink = time + (0.25 * j);
	}
}

METHOD(Duck, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Duck, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		player_sound(actor, CH_VOICE, "attack.wav", ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 2.5;
		Duck_ShootGrapes(actor);
	}
}

METHOD(Duck, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "death2.wav", ATTN_NORM);
	actor.duck_cannon = true;
}

METHOD(Duck, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.duck_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.duck_cannon = false;
	return false;
}
#endif

#ifdef CSQC
METHOD(Duck, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/duck_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
