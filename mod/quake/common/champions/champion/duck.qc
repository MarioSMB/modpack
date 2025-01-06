#include "duck.qh"

#ifdef SVQC
void grape_launch(entity this)
{
	entity player = this.owner;
	if(!player || player.health <= 0 || player.m_champion != CHAMPION_Duck || !IS_PLAYER(player))
	{
		delete(this);
		return;
	}
	makevectors(player.v_angle);
	vector dir = v_forward;
	vector spread = '0.1 0.1 0';
	dir += (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
	entity newmis = launch_spike(player, player.origin + player.view_ofs, dir);
	newmis.classname = "grape";
	setmodel(newmis, MDL_Grape);
	newmis.avelocity = randomvec() * 200;
	newmis.dmg = 20;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.noise = "weapons/grape_impact.wav";
	newmis.nextthink = time + 7;
	setthink(newmis, SUB_Remove);
	newmis.velocity = dir * 300;
	settouch(newmis, spike_touch);
	newmis.projectiledeathtype = DEATH_GRAPE.m_id;

	delete(this);
}

void Duck_ShootGrapes(entity this)
{
	for(int j = 0; j < 5; ++j)
	{
		entity grape = new(grape_delayed);
		grape.owner = this;
		setthink(grape, grape_launch);
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

METHOD(Duck, m_condition, bool(Champions this, entity actor))
{
	if(autocvar_sv_allow_customplayermodels_ducklist == "")
		return true;
	return !PlayerInList(actor, autocvar_sv_allow_customplayermodels_ducklist);
}
#endif

#ifdef CSQC
METHOD(Duck, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/duck_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
