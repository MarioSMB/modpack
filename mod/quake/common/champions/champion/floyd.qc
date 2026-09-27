#include "floyd.qh"

#ifdef SVQC

void FLaunchLaser(entity this, vector org, vector vec);
void floydchamp_fire(entity this, float muzzle)
{
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.v_angle);
	
	vector org = this.origin + v_forward * 30 + '0 0 28' + v_right * muzzle;
	vector dir = v_forward;

	sound(this, CH_WEAPON_SINGLE, SND_FloydChamp_Shoot, 1, ATTN_NORM);
	FLaunchLaser(this, org, dir);
}

void floydchamp_attack9(entity this) { set_animofs(this, anim_floyd_attack1, 9, player_run); }
void floydchamp_attack8(entity this) { set_animofs(this, anim_floyd_attack1, 8, floydchamp_attack9); }
void floydchamp_attack7(entity this) { set_animofs(this, anim_floyd_attack1, 7, floydchamp_attack8); floydchamp_fire(this, -6); }
void floydchamp_attack6(entity this) { set_animofs(this, anim_floyd_attack1, 6, floydchamp_attack7); }
void floydchamp_attack5(entity this) { set_animofs(this, anim_floyd_attack1, 5, floydchamp_attack6); }
void floydchamp_attack4(entity this) { set_animofs(this, anim_floyd_attack1, 4, floydchamp_attack5); floydchamp_fire(this, 0); }
void floydchamp_attack3(entity this) { set_animofs(this, anim_floyd_attack1, 3, floydchamp_attack4); }
void floydchamp_attack2(entity this) { set_animofs(this, anim_floyd_attack1, 2, floydchamp_attack3); }
void floydchamp_attack1(entity this) { set_animofs(this, anim_floyd_attack1, 1, floydchamp_attack2); floydchamp_fire(this, 6); }

METHOD(FloydChamp, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_FloydChamp_Start, ATTN_NORM);
}

METHOD(FloydChamp, m_weaponframe, bool(Champions this, entity actor, .entity weaponentity))
{
	// no regular weapon use!
	return true;
}

METHOD(FloydChamp, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_ATCK(actor) && time > actor.floyd_shoot_time && !actor.tank && !STAT(CANNON, actor))
	{
		actor.floyd_shoot_time = time + 1.5;
		floydchamp_attack1(actor);
	}

	if(actor.jetpack_status && actor.health > 0 && !intermission_running && !STAT(CANNON, actor))
		actor.modelflags |= MF_ROCKET;
	else
		actor.modelflags &= ~MF_ROCKET;

	if(!actor.jetpack_status && IS_ONGROUND(actor))
		STAT(QCC_JETPACKFUEL, actor) = 100;
}

METHOD(FloydChamp, m_playerspawn, void(Champions this, entity actor))
{
	STAT(QCC_JETPACKFUEL, actor) = 100;
}

METHOD(FloydChamp, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_FloydChamp_Cannon_Launch, ATTN_NORM);
	actor.floyd_cannon = true;
}

METHOD(FloydChamp, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.floyd_cannon)
		return false;
	player_sound(actor, CH_PLAYER_SINGLE, SND_FloydChamp_Land, ATTN_NORM);
	actor.floyd_cannon = false;
	return false;
}
#endif

METHOD(FloydChamp, m_playerjump, float(Champions this, entity actor))
{
	return 0.5;
}

METHOD(FloydChamp, m_jetpack, bool(Champions this, entity actor, float maxspd_mod, float dt))
{
	if(!PHYS_INPUT_BUTTON_CROUCH(actor) || QCC_PlayerOccupied(actor))
		return false;

	float fuel_cost = 15;
	float maxspeed_up = 200;
	float maxspeed_side = 150;
	float accel_side = 200;
	float accel_up = 500;
	float antigrav = 0.5;
	float fuel_scale = 100;
	bool do_vertical_scale = true;
	jetpack_physics(actor, maxspd_mod, dt, fuel_cost, maxspeed_up, maxspeed_side, accel_side, accel_up, antigrav, fuel_scale, do_vertical_scale);
	return true;
}

#ifdef CSQC
METHOD(FloydChamp, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/floyd_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
