#include "kirby.qh"

#ifdef SVQC
#include "../../../server/player.qh"
#endif

#ifdef SVQC
// TODO
void player_axe1(entity this);
void player_axeb1(entity this);
void player_axed1(entity this);

METHOD(Kirby, m_updatestats, void(Champions this, entity actor))
{
	if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
	{
		STAT(MOVEVARS_GRAVITY, actor) *= 0.5;
		STAT(MOVEVARS_AIRACCELERATE, actor) *= 0.2;
	}
}

METHOD(Kirby, m_playerrun, bool(Champions this, entity actor))
{
	int mystate = STAT(KIRBY_STATE, actor);
	switch(mystate)
	{
		default:
		case KIRBY_NORMAL:
		{
			vector anim = vec3(anim_player_rockrun1, 0, 6);
			if(!IS_ONGROUND(actor))
				anim = vec3(anim_player_axattc1, 0, 6);

			if(actor.walkframe >= anim.z)
				actor.walkframe = anim.y;
			actor.frame = anim.x + actor.walkframe;
			break;
		}
		case KIRBY_FULL:
		{
			vector anim = vec3(anim_player_axrun1, 0, 6);

			if(actor.walkframe >= anim.z)
				actor.walkframe = anim.y;
			actor.frame = anim.x + actor.walkframe;
			break;
		}
		case KIRBY_FLYING:
		{
			vector anim = vec3(anim_player_axatt1 + 3, 0, 2);

			if(actor.walkframe >= anim.z)
				actor.walkframe = anim.y;
			actor.frame = anim.x + actor.walkframe;
			break;
		}
	}

	return true; // override standard animations
}

METHOD(Kirby, m_playerstand, bool(Champions this, entity actor))
{
	int mystate = STAT(KIRBY_STATE, actor);
	switch(mystate)
	{
		default:
		case KIRBY_NORMAL:
		{
			vector anim = vec3(anim_player_axstnd1, 0, 12);
			if(!IS_ONGROUND(actor))
				anim = vec3(anim_player_axattc1, 0, 6);

			if(actor.walkframe >= anim.z)
				actor.walkframe = anim.y;
			actor.frame = anim.x + actor.walkframe;
			break;
		}
		case KIRBY_FULL:
		{
			vector anim = vec3(anim_player_stand1, 0, 5);

			if(actor.walkframe >= anim.z)
				actor.walkframe = anim.y;
			actor.frame = anim.x + actor.walkframe;
			break;
		}
		case KIRBY_FLYING:
		{
			vector anim = vec3(anim_player_axatt1 + 3, 0, 2);

			if(actor.walkframe >= anim.z)
				actor.walkframe = anim.y;
			actor.frame = anim.x + actor.walkframe;
			break;
		}
	}

	return true; // override standard animations
}

METHOD(Kirby, m_activate, void(Champions this, entity actor))
{
	Inventory_add(WEP_STAR, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	W_SwitchWeapon_Force(actor, WEP_STAR, weaponentity);

	float r = random();
	if(r < 0.25)
		player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
	else if(r < 0.50)
		player_sound(actor, CH_VOICE, "start2.wav", ATTN_NORM);
	else if(r < 0.75)
		player_sound(actor, CH_VOICE, "start3.wav", ATTN_NORM);
	else
		player_sound(actor, CH_VOICE, "start4.wav", ATTN_NORM);
}

METHOD(Kirby, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_STAR, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	W_SwitchWeapon_Force(actor, WEP_STAR, weaponentity);
}

METHOD(Kirby, m_clear, void(Champions this, entity actor))
{
	Inventory_remove(WEP_STAR, actor, ITEM_OWNED);

	STAT(KIRBY_STATE, actor) = KIRBY_NORMAL;
	W_Star_Clear(actor);
}

METHOD(Kirby, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.kirby_cannon = true;
}

METHOD(Kirby, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.kirby_cannon)
	{
		if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
			actor.jump_flag = 0; // HACK: reset landing here so there's no land sound
		return false;
	}
	player_sound(actor, CH_TRIGGER_SINGLE, "cannon_land.wav", ATTN_NORM);
	actor.kirby_cannon = false;
	actor.jump_flag = 0;
	return true; // prevent land sound
}

METHOD(Kirby, m_sound_jump, string(entity actor))
{
	if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
	{
		float r = random();
		if(r < 0.25)
			return "player_kirby/fly1.wav";
		else if(r < 0.50)
			return "player_kirby/fly2.wav";
		else if(r < 0.75)
			return "player_kirby/fly3.wav";
		else
			return "player_kirby/fly4.wav";
	}
	else if(STAT(KIRBY_STATE, actor) == KIRBY_FULL)
		return "player_kirby/jump_full.wav";
	return "player_kirby/plyrjmp8.wav";
}

METHOD(Kirby, m_playerjump, float(Champions this, entity actor))
{
	if(IS_ONGROUND(actor))
		player_axeb1(actor);
	return 1;
}
#endif

#ifdef SVQC
METHOD(Kirby, m_touch, void(Champions this, entity actor, entity toucher))
{
	if(StatusEffects_active(STATUSEFFECT_PowerShield, actor))
		return; // better version
	if(time < actor.kirby_bash_time)
		return;
	if(actor.velocity == '0 0 0')
		return;
	if(time > STAT(QCC_ABILITYTIME, actor))
		return;

	if(IS_PLAYER(toucher) || (IS_MONSTER(toucher) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_DECOY)))
	{
		makevectors(actor.angles);
		vector vec = normalize(toucher.origin - actor.origin);
		float dot = vec * v_forward;
		if(dot < 0.3)
			return;

		if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
		{
			float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

			makevectors(actor.angles);
			toucher.velocity = v_forward * (200 * pushforce);
			toucher.velocity_z = (65 * pushforce);
		}

		te_explosion2(toucher.origin, 230, 1);

		float thedamage = 40;
		if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			thedamage = 120;

		T_Damage(toucher, actor, actor, thedamage, DEATH_CRUSH.m_id);

		player_sound(actor, CH_VOICE, "bonk.wav", ATTN_NORM);

		actor.kirby_bash_time = time + 0.5;
	}
}
#endif

void Kirby_PreJump(entity actor)
{
#ifdef SVQC
	if(IS_ONGROUND(actor) || actor.waterlevel > 0)
	{
		STAT(KIRBY_JUMPS, actor) = 0;
		if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
			STAT(KIRBY_STATE, actor) = KIRBY_NORMAL;
	}
#endif
}

METHOD(Kirby, m_physics, bool(Champions this, entity actor, float dt))
{
	if(vdist(actor.velocity, <, PHYS_MAXSPEED(actor) * 0.3) && PHYS_INPUT_BUTTON_CROUCH(actor) && IS_ONGROUND(actor) && !(STAT(ITEMS, actor) & IT_TANK) && STAT(KIRBY_STATE, actor) == KIRBY_NORMAL)
	{
	#ifdef SVQC
		player_sound(actor, CH_PLAYER_SINGLE, "slide.wav", ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		player_axed1(actor);
	#endif
		vector vang = PHYS_INPUT_ANGLES(actor);
		makevectors('0 1 0' * vang.y);
		actor.velocity += v_forward * 500;
		actor.velocity_z += 100;
		UNSET_ONGROUND(actor);
	}
	return false;
}

METHOD(Kirby, m_doublejump, bool(Champions this, entity actor))
{
	if(actor.waterlevel > 0)
		return false;
	int mystate = STAT(KIRBY_STATE, actor);
	switch(mystate)
	{
		default:
		case KIRBY_NORMAL:
		case KIRBY_FLYING:
		{
			if(!IS_JUMP_HELD(actor) && !IS_ONGROUND(actor) && actor.velocity_z <= 0 && STAT(KIRBY_JUMPS, actor) <= 7)
			{
			#ifdef SVQC
				STAT(KIRBY_STATE, actor) = KIRBY_FLYING;
				STAT(KIRBY_JUMPS, actor) += 1;
				player_axe1(actor);
			#endif
				return true;
			}
			break;
		}
		case KIRBY_FULL: break;
	}
	return false;
}

#ifdef CSQC
METHOD(Kirby, m_overlay, void(Champions this))
{
	if(STAT(KIRBY_DISCARD) <= 0 || STAT(KIRBY_TYPE) == 0)
		return;
	if(intermission || STAT(HEALTH) == -666)
		return;

	int oldfont = drawfont;
	drawfont = 8;

	vector pos = '0.5 0 0' * vid_conwidth + '0 0.6 0' * vid_conheight;
	vector mySize = '256 32 0';
	float charge = STAT(KIRBY_DISCARD);
	drawstring_aspect(pos - ('0.5 0 0' * mySize.x), "Discarding...", vec2(mySize.x, mySize.y * 0.45), '1 1 1', 1, DRAWFLAG_NORMAL);
	pos.y += mySize.y;
	HUD_Panel_DrawProgressBar(pos - ('0.5 0 0' * mySize.x), '256 32 0', "progressbar", charge, false, 0, '1 1 0', 0.6, DRAWFLAG_NORMAL);

	drawfont = oldfont;
}
#endif
