#include "ball.qh"

#include "../../dodgeball/_mod.qh"

#ifdef SVQC
void player_ball4(entity this) { set_animofs(this, anim_player_axatt1, 4, player_run); }
void player_ball3(entity this) { set_animofs(this, anim_player_axatt1, 3, player_ball4); }
void player_ball2(entity this) { set_animofs(this, anim_player_axatt1, 2, player_ball3); }
void player_ball1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_ball2); }

void wep_ball_ball4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_ball_ball3(entity this) { wep_set_anim(this, 3, wep_ball_ball4); ThrowBall(this.owner); }
void wep_ball_ball2(entity this) { wep_set_anim(this, 2, wep_ball_ball3); }
void wep_ball_ball1(entity this) { wep_set_anim(this, 1, wep_ball_ball2);}

METHOD(Ball, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(time > STAT(CATCHING, actor) && time > STAT(DEFLECTING, actor))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(STAT(HAS_BALL, actor))
		{
			if(IS_PLAYER(actor))
				player_ball1(actor);
			wep_ball_ball1(actor.(weaponentity));
			weapon_prepareattack(thiswep, actor, weaponentity, 0.4);
		}
		else
		{
			wep_ball_ball1(actor.(weaponentity));
			Catch(actor);
			weapon_prepareattack(thiswep, actor, weaponentity, 0.6);
		}
	}

	if(fire & 2)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(time > STAT(CATCHING, actor) && time > STAT(DEFLECTING, actor) && STAT(HAS_BALL, actor))
	{
		Deflect(actor);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.6);
	}
}
METHOD(Ball, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Ball, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
