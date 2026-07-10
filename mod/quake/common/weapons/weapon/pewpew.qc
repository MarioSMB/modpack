#include "pewpew.qh"

#ifdef SVQC
PRECACHE(PewPew)
{
	precache_model("progs/v_pewpew.mdl");
	precache_model("progs/g_pewpew.mdl");

	precache_sound("weapons/pewpew1.wav");
	precache_sound("weapons/pewpew2.wav");
	precache_sound("weapons/pewpew3.wav");
	precache_sound("weapons/pewpew_load.wav");
}

void wep_pewpew_shot6(entity this) { wep_set_anim(this, 13, w_ready); }
void wep_pewpew_shot5(entity this) { wep_set_anim(this, 12, wep_pewpew_shot6); }
void wep_pewpew_shot4(entity this) { wep_set_anim(this, 11, wep_pewpew_shot5); }
void wep_pewpew_shot3(entity this) { wep_set_anim(this, 10, wep_pewpew_shot4); }
void wep_pewpew_shot2(entity this) { wep_set_anim(this, 9, wep_pewpew_shot3); }
void wep_pewpew_shot1(entity this) { wep_set_anim(this, 8, wep_pewpew_shot2); this.owner.effects |= EF_MUZZLEFLASH; }

void W_FirePewPew(entity this, .entity weaponentity)
{
	float r = random();
	if(r < 0.33)
		_sound(this, CH_WEAPON_SINGLE, "weapons/pewpew1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(this, CH_WEAPON_SINGLE, "weapons/pewpew2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/pewpew3.wav", 1, ATTN_NORM);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;

	vector org = W_Shotorg(this, weaponentity) + v_right * 7;
	vector dir = qc_aim_fromorg(this, org, 1000);
	entity missile = LaunchLaser(this, org, dir);
	missile.projectiledeathtype = WEP_PEWPEW.m_id;
	missile.dmg = 25;
	missile.velocity = dir * 1000;
	missile.angles = vectoangles(missile.velocity);
}

METHOD(PewPew, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_pewpew_shot1(actor.(weaponentity));
		W_FirePewPew(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}

	if(fire & 2)
	if(!(time < actor.attack2_finished))
	{
		_sound(actor, CH_SHOTS_SINGLE, "weapons/pewpew_load.wav", 1, ATTN_NORM);
		actor.attack2_finished = time + 0.2; // not too spammy thank you
		crosshair_trace_plusvisibletriggers(actor);
		entity wp = WaypointSprite_DeployFixed(WP_Here, false, actor, trace_endpos, NULL);
		if (wp)
		{
			if(autocvar_sv_quake_pewpew_colors)
			{
				int col = (actor.colormap >= 1024) ? actor.colormap - 1024 : actor.clientcolors;
				wp.wp_extra = col;
			}
			WaypointSprite_Ping(wp);
		}
	}
}
METHOD(PewPew, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo
}
METHOD(PewPew, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(PewPew, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
