#include "galena.qh"

bool Galena_charging(entity actor)
{
#if 0
	if(actor.velocity == '0 0 0')
		return false;
#endif
#ifdef SVQC
	.entity weaponentity = weaponentities[0];
	if(actor.(weaponentity).m_weapon != WEP_SWORD)
		return false;
#endif
#ifdef CSQC
	if(viewmodels[0].activeweapon != WEP_SWORD)
		return false;
#endif
	if(!PHYS_INPUT_BUTTON_ATCK2(actor))
		return false;

#if 0
	// need to be looking in the direction you're moving!
	makevectors(PHYS_WORLD_ANGLES(actor));
	vector vec = normalize(actor.velocity);
	float dot = vec * v_forward;
	if(dot < 0.3)
		return false;
#endif

	return true;
}

METHOD(Galena, m_physics, bool(Champions this, entity actor, float dt))
{
	if(actor.galena_charge)
	{
		actor.movement_y = 0;
#if 1
		actor.movement_x = PHYS_MAXSPEED(actor) * 2; // forced forward
#endif
		return false;
	}

	if(vdist(actor.velocity, <=, PHYS_MAXSPEED(actor)) && vdist(actor.velocity, >, PHYS_MAXSPEED(actor) * 0.5) && PHYS_INPUT_BUTTON_CROUCH(actor) && IS_ONGROUND(actor) && !QCC_HasSpellbook(actor))
	{
		float tap_direction_x = 0;
		float tap_direction_y = 0;
		bool dodge_detected = false;
		vector mymovement = actor.movement;

		#define X(COND,RESULT)																			\
		if (mymovement_##COND) {																			\
			tap_direction_##RESULT;																			\
			dodge_detected = true;																			\
		}
		X(x < 0,	x--);
		X(x > 0,	x++);
		X(y < 0,	y--);
		X(y > 0,	y++);
		#undef X

		if(!dodge_detected)
			return false;

		// normalize the dodging_direction vector.. (unlike UT99) XD
		float length = sqrt(tap_direction_x ** 2 + tap_direction_y ** 2);

		tap_direction_x = tap_direction_x / length;
		tap_direction_y = tap_direction_y / length;

	#ifdef SVQC
		player_sound(actor, CH_PLAYER, "plyrjmp8.wav", ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		actor.galena_dodge_time = time + 0.33;
	#endif
		vector vang = PHYS_INPUT_ANGLES(actor);
		makevectors('0 1 0' * vang.y);
		actor.velocity += tap_direction_x * 300 * v_forward + tap_direction_y * 300 * v_right;
		actor.velocity_z += 200;
		UNSET_ONGROUND(actor);
	}
	return false;
}

bool galena_canblock(entity actor)
{
#ifdef SVQC
	.entity weaponentity = weaponentities[0];
	if(actor.(weaponentity).m_weapon.spawnflags & WEP_FLAG_TWOHANDED)
		return false;
#endif
#ifdef CSQC
	if(viewmodels[0].activeweapon.spawnflags & WEP_FLAG_TWOHANDED)
		return false;
#endif
	return true;
}

METHOD(Galena, m_getmovespeed, float(Champions this, entity actor))
{
	if(actor.galena_charge)
		return 2.5;
	else if(PHYS_INPUT_BUTTON_ATCK2(actor) && galena_canblock(actor))
		return 0.25;
	return 0.9;
}

METHOD(Galena, m_fixclient, void(Champions this, entity actor))
{
	actor.galena_charge = Galena_charging(actor); // saves needing to check it several times during physics loops
}

#ifdef SVQC
// TODO: generic list of deathtypes that should never be blocked
bool Galena_forcedamage(int deathtype)
{
	switch(deathtype)
	{
		case DEATH_VOID.m_id:
		case DEATH_HURTTRIGGER.m_id:
		case DEATH_KILL.m_id:
		case DEATH_GENERIC.m_id:
		case DEATH_LAVA.m_id:
		case DEATH_CHECKPOINT.m_id:
			return true;
	}
	return false;
}

void Galena_ChargeAttack(entity this, .entity weaponentity)
{
	makevectors(this.angles); // not using up/down?
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float arange = 120;
	traceline(source, source + v_forward * arange, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	float r = random();
	if(trace_ent.takedamage) // yoder mod, Jan 05 2021
	{
		{
			if(trace_ent.monsterdef == MON_JUGGERNAUT) // special case: axe attacks produce unique sound against juggernauts TODO: handle melee attacks in monster pain code
				_sound(this, CH_WEAPON_SINGLE, "monsters/juggers/jbent.wav", 1, ATTN_NORM);
			else if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MON_FLAG_METAL))
			{
				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(IS_PLAYER(trace_ent) && trace_ent.armorvalue > 0)
			{
				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else
			{
				_sound(trace_ent, CH_SHOTS, "enviro/physics/trcut.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		float damage = 40;
		T_Damage(trace_ent, this, this, damage, WEP_SWORD.m_id);
	}
	else if(vdist(this.velocity, >=, PHYS_MAXSPEED(this) * 0.8))
	{	// hit wall
		_sound(this, CH_SHOTS, "player/axhit2.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
}

METHOD(Galena, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this && targ.galena_dodge_time > time && !Galena_forcedamage(deathtype))
		return 0;
	if(targ.m_champion == this && PHYS_INPUT_BUTTON_ATCK2(targ) && galena_canblock(targ))
	{
		if(deathmatch)
			return 0.6;
		return 0.25;
	}
	return 1;
}

METHOD(Galena, m_playerthink, void(Champions this, entity actor))
{
	// hack to make charging animation work TODO
	if(Galena_charging(actor))
	{
		.entity weaponentity = weaponentities[0]; // WEAPONTODO?
		entity wepent = actor.(weaponentity);
		if(wepent && wepent.m_weapon == WEP_SWORD)
		{
			//wepent.weapon_nextthink = time + 0.5; // just to keep it from switching anims
			ATTACK_FINISHED(actor, weaponentity) = time + 0.25; // prevent attacking while charging
			wepent.m_frame = 3;
			if(time >= actor.galena_charge_time)
			{
				Galena_ChargeAttack(actor, weaponentity);
				actor.galena_charge_time = time + 0.1;
			}
		}
	}
}

METHOD(Galena, m_updatestats, void(Champions this, entity actor))
{
	if(Galena_charging(actor))
		STAT(MOVEVARS_ACCELERATE, actor) = 3; // slow acceleration, but higher top speed (done elsewhere)
}

METHOD(Galena, m_activate, void(Champions this, entity actor))
{
	float r = random();
	if(r < 0.33)
		player_sound(actor, CH_VOICE, "abl1.wav", ATTN_NORM);
	else if(r < 0.66)
		player_sound(actor, CH_VOICE, "abl2.wav", ATTN_NORM);
	else
		player_sound(actor, CH_VOICE, "abl3.wav", ATTN_NORM);

	actor.skin = bound(0, (etof(actor) % 5) - 1, 4);

	STAT(WEAPONS, actor) |= WEP_SWORD.m_wepset;
}

METHOD(Galena, m_playerspawn, void(Champions this, entity actor))
{
	STAT(WEAPONS, actor) |= WEP_SWORD.m_wepset;
}
#endif
