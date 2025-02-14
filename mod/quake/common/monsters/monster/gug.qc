#include "gug.qh"

#ifdef SVQC

ERASEABLE
float mrandom(float num)
{
	return 0.5 * num - num * random();
}

void gug_shake_think(entity this)
{
	if(time > this.ltime)
	{
		delete(this);
		return;
	}

	this.nextthink = time + 0.01;
	setthink(this, gug_shake_think);

	this.enemy.punchangle_x = (time - this.ltime) * random() * 10;
	this.enemy.punchangle_y = (time - this.ltime) * random() * 10;
	this.enemy.punchangle_z = (time - this.ltime) * random() * 10;
}

void gug_screen_shake(entity this, float stime, entity eshake)
{
	entity qent = spawn();
	qent.classname = "gug_screen_shake";
	qent.owner = this;
	qent.realowner = this;
	qent.enemy = eshake;
	set_movetype(qent, MOVETYPE_NONE);
	qent.solid = SOLID_NOT;
	qent.nextthink = time + 0.01;
	setthink(qent, gug_shake_think);
	qent.ltime = time + stime;
	setsize(qent, '0 0 0', '0 0 0');
	setorigin(qent, this.origin);
}

void gug_quake_think(entity this)
{
	if(time > this.ltime)
	{
		delete(this);
		return;
	}

	this.nextthink = time + 0.08;
	setthink(this, gug_quake_think);

	FOREACH_ENTITY_RADIUS(this.origin, 800, it != this.owner && it.takedamage == DAMAGE_AIM && !(it.flags & FL_FLY),
	{
		vector org = (it.absmin + it.absmax) * 0.5;
		float points = max(0, 0.01 * vlen(it.origin - org));

		points -= 9;
		if(points <= 0)
			continue;

		it.punchangle_x = (time - this.ltime) * random() * 4;
		it.punchangle_y = (time - this.ltime) * random() * 4;
		it.punchangle_z = (time - this.ltime) * random() * 4;
		if(IS_ONGROUND(it))
		{
			UNSET_ONGROUND(it);
			it.velocity_z += random() * 150;
		}
	});
}

void gug_quake(entity this, float stime)
{
	this.t_width = time + 4.5;
	entity qent = spawn();
	qent.classname = "gug_quake";
	qent.owner = this;
	set_movetype(qent, MOVETYPE_NONE);
	qent.solid = SOLID_NOT;
	qent.realowner = this;
	setthink(qent, gug_quake_think);
	qent.nextthink = time + 0.1;
	qent.ltime = time + stime;
	setsize(qent, '0 0 0', '0 0 0');
	setorigin(qent, this.origin);
}

void gug_quake_damage(entity this)
{
	FOREACH_ENTITY_RADIUS(this.origin, 800, it != this && it.takedamage == DAMAGE_AIM && !(it.flags & FL_FLY) && Damage_ValidTarget(it, this),
	{
		vector org = (it.absmin + it.absmax) * 0.5;
		float points = max(0, 0.01 * vlen(it.origin - org));

		points -= 9; // reduce overall quake damage?
		if(points <= 0)
			continue; // too far away

		if(IS_PLAYER(it) || CanDamage(it, this))
			T_Damage(it, this, this, points, DEATH_MONSTER_GUG.m_id);
	});
}

void gug_run1(entity this);
void gug_quake24(entity this) { set_anim(this, 193, gug_run1); }
void gug_quake23(entity this) { set_anim(this, 192, gug_quake24); }
void gug_quake22(entity this) { set_anim(this, 191, gug_quake23); }
void gug_quake21(entity this) { set_anim(this, 190, gug_quake22); }
void gug_quake20(entity this) { set_anim(this, 189, gug_quake21); }
void gug_quake19(entity this) { set_anim(this, 188, gug_quake20); }
void gug_quake18(entity this) { set_anim(this, 187, gug_quake19); }
void gug_quake17(entity this) { set_anim(this, 186, gug_quake18); gug_quake_damage(this); }
void gug_quake16(entity this) { set_anim(this, 185, gug_quake17); }
void gug_quake15(entity this) { set_anim(this, 184, gug_quake16); gug_quake_damage(this); }
void gug_quake14(entity this) { set_anim(this, 183, gug_quake15); }
void gug_quake13(entity this) { set_anim(this, 182, gug_quake14); gug_quake_damage(this); }
void gug_quake12(entity this) { set_anim(this, 181, gug_quake13); }
void gug_quake11(entity this) { set_anim(this, 180, gug_quake12); gug_quake_damage(this); }
void gug_quake10(entity this) { set_anim(this, 179, gug_quake11); }
void gug_quake9(entity this)
{
	set_anim(this, 178, gug_quake10);
	gug_quake(this, 3.3);
	gug_quake_damage(this);
	this.pain_finished = time + 1.6;
}
void gug_quake8(entity this) { set_anim(this, 177, gug_quake9); }
void gug_quake7(entity this) { set_anim(this, 176, gug_quake8); }
void gug_quake6(entity this) { set_anim(this, 175, gug_quake7); ai_face(this); }
void gug_quake5(entity this) { set_anim(this, 174, gug_quake6); ai_face(this); }
void gug_quake4(entity this) { set_anim(this, 173, gug_quake5); ai_face(this); }
void gug_quake3(entity this) { set_anim(this, 172, gug_quake4); ai_face(this); }
void gug_quake2(entity this) { set_anim(this, 171, gug_quake3); ai_face(this); }
void gug_quake1(entity this) { set_anim(this, 170, gug_quake2); ai_face(this); }

void gug_choosestand(entity this);
void gug_stand1(entity this);
void gug_stand80(entity this) { set_anim(this, 81, gug_choosestand); ai_stand(this); }
void gug_stand79(entity this) { set_anim(this, 80, gug_stand80); ai_stand(this); }
void gug_stand78(entity this) { set_anim(this, 79, gug_stand79); ai_stand(this); }
void gug_stand77(entity this) { set_anim(this, 78, gug_stand78); ai_stand(this); }
void gug_stand76(entity this) { set_anim(this, 77, gug_stand77); ai_stand(this); }
void gug_stand75(entity this) { set_anim(this, 76, gug_stand76); ai_stand(this); }
void gug_stand74(entity this) { set_anim(this, 75, gug_stand75); ai_stand(this); }
void gug_stand73(entity this) { set_anim(this, 74, gug_stand74); ai_stand(this); }
void gug_stand72(entity this) { set_anim(this, 73, gug_stand73); ai_stand(this); }
void gug_stand71(entity this) { set_anim(this, 72, gug_stand72); ai_stand(this); }
void gug_stand70(entity this) { set_anim(this, 71, gug_stand71); ai_stand(this); }
void gug_stand69(entity this) { set_anim(this, 70, gug_stand70); ai_stand(this); }
void gug_stand68(entity this) { set_anim(this, 69, gug_stand69); ai_stand(this); }
void gug_stand67(entity this) { set_anim(this, 68, gug_stand68); ai_stand(this); }
void gug_stand66(entity this) { set_anim(this, 67, gug_stand67); ai_stand(this); }
void gug_stand65(entity this) { set_anim(this, 66, gug_stand66); ai_stand(this); }
void gug_stand64(entity this) { set_anim(this, 65, gug_stand65); ai_stand(this); }
void gug_stand63(entity this) { set_anim(this, 64, gug_stand64); ai_stand(this); }
void gug_stand62(entity this) { set_anim(this, 63, gug_stand63); ai_stand(this); }
void gug_stand61(entity this) { set_anim(this, 62, gug_stand62); ai_stand(this); }
void gug_stand60(entity this) { set_anim(this, 61, gug_choosestand); ai_stand(this); }
void gug_stand59(entity this) { set_anim(this, 60, gug_stand60); ai_stand(this); }
void gug_stand58(entity this) { set_anim(this, 59, gug_stand59); ai_stand(this); }
void gug_stand57(entity this) { set_anim(this, 58, gug_stand58); ai_stand(this); }
void gug_stand56(entity this) { set_anim(this, 57, gug_stand57); ai_stand(this); }
void gug_stand55(entity this) { set_anim(this, 56, gug_stand56); ai_stand(this); }
void gug_stand54(entity this) { set_anim(this, 55, gug_stand55); ai_stand(this); }
void gug_stand53(entity this) { set_anim(this, 54, gug_stand54); ai_stand(this); }
void gug_stand52(entity this) { set_anim(this, 53, gug_stand53); ai_stand(this); }
void gug_stand51(entity this) { set_anim(this, 52, gug_stand52); ai_stand(this); }
void gug_stand50(entity this) { set_anim(this, 51, gug_stand51); ai_stand(this); }
void gug_stand49(entity this) { set_anim(this, 50, gug_stand50); ai_stand(this); }
void gug_stand48(entity this) { set_anim(this, 49, gug_stand49); ai_stand(this); }
void gug_stand47(entity this) { set_anim(this, 48, gug_stand48); ai_stand(this); }
void gug_stand46(entity this) { set_anim(this, 47, gug_stand47); ai_stand(this); }
void gug_stand45(entity this) { set_anim(this, 46, gug_stand46); ai_stand(this); }
void gug_stand44(entity this) { set_anim(this, 45, gug_stand45); ai_stand(this); }
void gug_stand43(entity this) { set_anim(this, 44, gug_stand44); ai_stand(this); }
void gug_stand42(entity this) { set_anim(this, 43, gug_stand43); ai_stand(this); }
void gug_stand41(entity this) { set_anim(this, 42, gug_stand42); ai_stand(this); }
void gug_stand40(entity this) { set_anim(this, 41, gug_choosestand); ai_stand(this); }
void gug_stand39(entity this) { set_anim(this, 40, gug_stand40); ai_stand(this); }
void gug_stand38(entity this) { set_anim(this, 39, gug_stand39); ai_stand(this); }
void gug_stand37(entity this) { set_anim(this, 38, gug_stand38); ai_stand(this); }
void gug_stand36(entity this) { set_anim(this, 37, gug_stand37); ai_stand(this); }
void gug_stand35(entity this) { set_anim(this, 36, gug_stand36); ai_stand(this); }
void gug_stand34(entity this) { set_anim(this, 35, gug_stand35); ai_stand(this); }
void gug_stand33(entity this) { set_anim(this, 34, gug_stand34); ai_stand(this); }
void gug_stand32(entity this) { set_anim(this, 33, gug_stand33); ai_stand(this); }
void gug_stand31(entity this) { set_anim(this, 32, gug_stand32); ai_stand(this); }
void gug_stand30(entity this) { set_anim(this, 31, gug_stand31); ai_stand(this); }
void gug_stand29(entity this) { set_anim(this, 30, gug_stand30); ai_stand(this); }
void gug_stand28(entity this) { set_anim(this, 29, gug_stand29); ai_stand(this); }
void gug_stand27(entity this) { set_anim(this, 28, gug_stand28); ai_stand(this); }
void gug_stand26(entity this) { set_anim(this, 27, gug_stand27); ai_stand(this); }
void gug_stand25(entity this) { set_anim(this, 26, gug_stand26); ai_stand(this); }
void gug_stand24(entity this) { set_anim(this, 25, gug_stand25); ai_stand(this); }
void gug_stand23(entity this) { set_anim(this, 24, gug_stand24); ai_stand(this); }
void gug_stand22(entity this) { set_anim(this, 23, gug_stand23); ai_stand(this); }
void gug_stand21(entity this) { set_anim(this, 22, gug_stand22); ai_stand(this); }
void gug_stand20(entity this) { set_anim(this, 21, gug_choosestand); ai_stand(this); }
void gug_stand19(entity this) { set_anim(this, 20, gug_stand20); ai_stand(this); }
void gug_stand18(entity this) { set_anim(this, 19, gug_stand19); ai_stand(this); }
void gug_stand17(entity this) { set_anim(this, 18, gug_stand18); ai_stand(this); }
void gug_stand16(entity this) { set_anim(this, 17, gug_stand17); ai_stand(this); }
void gug_stand15(entity this) { set_anim(this, 16, gug_stand16); ai_stand(this); }
void gug_stand14(entity this) { set_anim(this, 15, gug_stand15); ai_stand(this); }
void gug_stand13(entity this) { set_anim(this, 14, gug_stand14); ai_stand(this); }
void gug_stand12(entity this) { set_anim(this, 13, gug_stand13); ai_stand(this); }
void gug_stand11(entity this) { set_anim(this, 12, gug_stand12); ai_stand(this); }
void gug_stand10(entity this) { set_anim(this, 11, gug_stand11); ai_stand(this); }
void gug_stand9(entity this) { set_anim(this, 10, gug_stand10); ai_stand(this); }
void gug_stand8(entity this) { set_anim(this, 9, gug_stand9); ai_stand(this); }
void gug_stand7(entity this) { set_anim(this, 8, gug_stand8); ai_stand(this); }
void gug_stand6(entity this) { set_anim(this, 7, gug_stand7); ai_stand(this); }
void gug_stand5(entity this) { set_anim(this, 6, gug_stand6); ai_stand(this); }
void gug_stand4(entity this) { set_anim(this, 5, gug_stand5); ai_stand(this); }
void gug_stand3(entity this) { set_anim(this, 4, gug_stand4); ai_stand(this); }
void gug_stand2(entity this) { set_anim(this, 3, gug_stand3); ai_stand(this); }
void gug_stand1(entity this) { set_anim(this, 2, gug_stand2); ai_stand(this); }

void gug_choosestand(entity this)
{
	if(random() < 0.3)
		_sound(this, CH_VOICE, "gug/idle.wav", 1, 0.7);

	float rnd = random();
	if(rnd < 0.25)
		gug_stand1(this);
	else if(rnd < 0.5)
		gug_stand21(this);
	else if(rnd < 0.75)
		gug_stand41(this);
	else
		gug_stand61(this);
}

void gug_step_sound(entity this)
{
	float rnd = random();
	if (rnd < 0.25)
		_sound(this, CH_VOICE, "gug/step1.wav", 1, 0.7);
	else if (rnd < 0.5)
		_sound(this, CH_VOICE, "gug/step2.wav", 1, 0.7);
	else if (rnd < 0.75)
		_sound(this, CH_VOICE, "gug/step3.wav", 1, 0.7);
	else
		_sound(this, CH_VOICE, "gug/step4.wav", 1, 0.7);

	FOREACH_ENTITY_RADIUS(this.origin, 150, IS_PLAYER(it),
	{
		gug_screen_shake(this, 0.2, it);
	});
}

void gug_walk1(entity this);
void gug_walk16(entity this) { set_anim(this, 97, gug_walk1); ai_walk(this, 2); }
void gug_walk15(entity this) { set_anim(this, 96, gug_walk16); ai_walk(this, 3); }
void gug_walk14(entity this) { set_anim(this, 95, gug_walk15); ai_walk(this, 4); }
void gug_walk13(entity this) { set_anim(this, 94, gug_walk14); ai_walk(this, 5); }
void gug_walk12(entity this) { set_anim(this, 93, gug_walk13); ai_walk(this, 6); }
void gug_walk11(entity this) { set_anim(this, 92, gug_walk12); ai_walk(this, 7); }
void gug_walk10(entity this) { set_anim(this, 91, gug_walk11); ai_walk(this, 8); }
void gug_walk9(entity this) { set_anim(this, 90, gug_walk10); ai_walk(this, 8); gug_step_sound(this); }
void gug_walk8(entity this) { set_anim(this, 89, gug_walk9); ai_walk(this, 2); }
void gug_walk7(entity this) { set_anim(this, 88, gug_walk8); ai_walk(this, 3); }
void gug_walk6(entity this) { set_anim(this, 87, gug_walk7); ai_walk(this, 4); }
void gug_walk5(entity this) { set_anim(this, 86, gug_walk6); ai_walk(this, 5); }
void gug_walk4(entity this) { set_anim(this, 85, gug_walk5); ai_walk(this, 6); }
void gug_walk3(entity this) { set_anim(this, 84, gug_walk4); ai_walk(this, 7); }
void gug_walk2(entity this) { set_anim(this, 83, gug_walk3); ai_walk(this, 8); }
void gug_walk1(entity this) { set_anim(this, 82, gug_walk2); ai_walk(this, 8); gug_step_sound(this); }

void gug_run8(entity this) { set_anim(this, 105, gug_run1); ai_run(this, 16); }
void gug_run7(entity this) { set_anim(this, 104, gug_run8); ai_run(this, 18); }
void gug_run6(entity this) { set_anim(this, 103, gug_run7); ai_run(this, 20); }
void gug_run5(entity this) { set_anim(this, 102, gug_run6); ai_run(this, 22); gug_step_sound(this); }
void gug_run4(entity this) { set_anim(this, 101, gug_run5); ai_run(this, 16); }
void gug_run3(entity this) { set_anim(this, 100, gug_run4); ai_run(this, 18); }
void gug_run2(entity this) { set_anim(this, 99, gug_run3); ai_run(this, 20); }
void gug_run1(entity this) { set_anim(this, 98, gug_run2); ai_run(this, 22); gug_step_sound(this); }

void ai_gug_swing(entity this, float dist, float yawspd)
{
	this.yaw_speed = yawspd;
	ai_face(this);
	t_movetogoal(this, dist);
	this.yaw_speed = 15;
}

.float gug_slapped;
void gug_hit(entity this, float dist, float power, float clawdmg, float stime)
{
	makevectors(this.angles);
	vector dir = v_forward;
	vector pushdir = dir * 100;

	FOREACH_ENTITY_RADIUS(this.origin, dist, it != this && it.health > 0 && Damage_ValidTarget(this, this) && visible(this, it),
	{
		vector pushorg = (it.absmin + it.absmax) * 0.5;
		vector pushdir2 = normalize(pushorg - this.origin) * 100;

		vector veca = this.origin + pushdir;
		vector vecb = this.origin + pushdir2;

		if(vdist(veca - vecb, <, 100))
		{
			if(it == this.enemy)
				T_Damage(it, this, this, clawdmg, DEATH_MONSTER_GUG.m_id);
			else
				T_Damage(it, this, this, clawdmg * 0.25, DEATH_MONSTER_GUG.m_id);

			if(!(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(it.monsterdef.spawnflags & MON_FLAG_STATIONARY))
			{
				float pushforce = 100 / vlen(it.maxs - it.mins);

				it.velocity = dir * (100 * pushforce);
				it.velocity_z = (330 * pushforce);
				UNSET_ONGROUND(it);
			}

			if(time >= it.gug_slapped)
			{
				it.gug_slapped = time + 0.5; // prevent spam
				_sound(this, CH_WEAPON_SINGLE, "shambler/smack.wav", 1, ATTN_NORM);
			}
		}
	});
}

void gug_swingl23(entity this) { set_anim(this, 128, gug_run1); ai_gug_swing(this, 18, 20); }
void gug_swingl22(entity this) { set_anim(this, 127, gug_swingl23); ai_gug_swing(this, 20, 21); }
void gug_swingl21(entity this) { set_anim(this, 126, gug_swingl22); ai_gug_swing(this, 22, 21); gug_step_sound(this); }
void gug_swingl20(entity this) { set_anim(this, 125, gug_swingl21); ai_gug_swing(this, 16, 22); }
void gug_swingl19(entity this) { set_anim(this, 124, gug_swingl20); ai_gug_swing(this, 18, 26); }
void gug_swingl18(entity this) { set_anim(this, 123, gug_swingl19); ai_gug_swing(this, 20, 27); gug_hit(this, 150, 500, 45, 0.9); }
void gug_swingl17(entity this) { set_anim(this, 122, gug_swingl18); ai_gug_swing(this, 22, 28); gug_step_sound(this); }
void gug_swingl16(entity this) { set_anim(this, 121, gug_swingl17); ai_gug_swing(this, 2, 27); }
void gug_swingl15(entity this) { set_anim(this, 120, gug_swingl16); ai_gug_swing(this, 1, 25); }
void gug_swingl14(entity this)
{
	set_anim(this, 119, gug_swingl15);
	ai_gug_swing(this, 1, 14);
	_sound(this, CHAN_BODY, "gug/throw.wav", 1, ATTN_NORM);
}
void gug_swingl13(entity this)
{
	set_anim(this, 118, gug_swingl14);
	ai_gug_swing(this, 1, 11);
	if(vdist(this.enemy.origin - this.origin, >, 170))
		setthink(this, gug_run1);
}
void gug_swingl12(entity this) { set_anim(this, 117, gug_swingl13); ai_gug_swing(this, 1, 12); }
void gug_swingl11(entity this) { set_anim(this, 116, gug_swingl12); ai_gug_swing(this, 1, 10); }
void gug_swingl10(entity this) { set_anim(this, 115, gug_swingl11); ai_gug_swing(this, 2, 11); }
void gug_swingl9(entity this) { set_anim(this, 114, gug_swingl10); ai_gug_swing(this, 6, 10); }
void gug_swingl8(entity this) { set_anim(this, 113, gug_swingl9); ai_gug_swing(this, 10, 25); gug_hit(this, 150, 300, 35, 0.6); }
void gug_swingl7(entity this) { set_anim(this, 112, gug_swingl8); ai_gug_swing(this, 14, 25); }
void gug_swingl6(entity this) { set_anim(this, 111, gug_swingl7); ai_gug_swing(this, 16, 24); }
void gug_swingl5(entity this) { set_anim(this, 110, gug_swingl6); ai_gug_swing(this, 18, 24); gug_step_sound(this); }
void gug_swingl4(entity this) { set_anim(this, 109, gug_swingl5); ai_gug_swing(this, 16, 25); }
void gug_swingl3(entity this)
{
	set_anim(this, 108, gug_swingl4);
	ai_gug_swing(this, 18, 25);
	_sound(this, CH_WEAPON_SINGLE, "gug/throw.wav", 1, ATTN_NORM);
}
void gug_swingl2(entity this) { set_anim(this, 107, gug_swingl3); ai_gug_swing(this, 20, 26); }
void gug_swingl1(entity this) { set_anim(this, 106, gug_swingl2); ai_gug_swing(this, 22, 25); gug_step_sound(this); }

void gug_swingr23(entity this) { set_anim(this, 151, gug_run1); ai_gug_swing(this, 18, 20); }
void gug_swingr22(entity this) { set_anim(this, 150, gug_swingr23); ai_gug_swing(this, 20, 21); }
void gug_swingr21(entity this) { set_anim(this, 149, gug_swingr22); ai_gug_swing(this, 22, 21); gug_step_sound(this); }
void gug_swingr20(entity this) { set_anim(this, 148, gug_swingr21); ai_gug_swing(this, 16, 22); }
void gug_swingr19(entity this) { set_anim(this, 147, gug_swingr20); ai_gug_swing(this, 18, 26); }
void gug_swingr18(entity this) { set_anim(this, 146, gug_swingr19); ai_gug_swing(this, 20, 27); gug_hit(this, 150, 500, 45, 0.9); }
void gug_swingr17(entity this) { set_anim(this, 145, gug_swingr18); ai_gug_swing(this, 22, 28); gug_step_sound(this); }
void gug_swingr16(entity this) { set_anim(this, 144, gug_swingr17); ai_gug_swing(this, 2, 27); }
void gug_swingr15(entity this) { set_anim(this, 143, gug_swingr16); ai_gug_swing(this, 1, 25); }
void gug_swingr14(entity this)
{
	set_anim(this, 142, gug_swingr15);
	ai_gug_swing(this, 1, 14);
	_sound(this, CH_WEAPON_SINGLE, "gug/throw.wav", 1, ATTN_NORM);
}
void gug_swingr13(entity this)
{
	set_anim(this, 141, gug_swingr14);
	ai_gug_swing(this, 1, 11);
	if(vdist(this.enemy.origin - this.origin, >, 170))
		setthink(this, gug_run1);
}
void gug_swingr12(entity this) { set_anim(this, 140, gug_swingr13); ai_gug_swing(this, 1, 12); }
void gug_swingr11(entity this) { set_anim(this, 139, gug_swingr12); ai_gug_swing(this, 1, 10); }
void gug_swingr10(entity this) { set_anim(this, 138, gug_swingr11); ai_gug_swing(this, 2, 11); }
void gug_swingr9(entity this) { set_anim(this, 137, gug_swingr10); ai_gug_swing(this, 6, 10); }
void gug_swingr8(entity this) { set_anim(this, 136, gug_swingr9); ai_gug_swing(this, 10, 25); gug_hit(this, 150, 300, 35, 0.6); }
void gug_swingr7(entity this) { set_anim(this, 135, gug_swingr8); ai_gug_swing(this, 14, 25); }
void gug_swingr6(entity this) { set_anim(this, 134, gug_swingr7); ai_gug_swing(this, 16, 24); }
void gug_swingr5(entity this) { set_anim(this, 133, gug_swingr6); ai_gug_swing(this, 18, 24); gug_step_sound(this); }
void gug_swingr4(entity this) { set_anim(this, 132, gug_swingr5); ai_gug_swing(this, 16, 25); }
void gug_swingr3(entity this)
{
	set_anim(this, 131, gug_swingr4);
	ai_gug_swing(this, 18, 25);
	_sound(this, CHAN_BODY, "gug/throw.wav", 1, ATTN_NORM);
}
void gug_swingr2(entity this) { set_anim(this, 130, gug_swingr3); ai_gug_swing(this, 20, 26); }
void gug_swingr1(entity this) { set_anim(this, 129, gug_swingr2); ai_gug_swing(this, 22, 25); gug_step_sound(this); }

void gug_melee(entity this)
{
	_sound(this, CH_VOICE, "gug/swipe.wav", 1, ATTN_NORM);

	if(random() > 0.5)
		gug_swingl1(this);
	else
		gug_swingr1(this);
}


//============================================================================

void bile_expl6(entity this) { set_anim(this, 5, SUB_Remove); }
void bile_expl5(entity this) { set_anim(this, 4, bile_expl6); }
void bile_expl4(entity this) { set_anim(this, 3, bile_expl5); }
void bile_expl3(entity this) { set_anim(this, 2, bile_expl4); }
void bile_expl2(entity this) { set_anim(this, 1, bile_expl3); }
void bile_expl1(entity this) { set_anim(this, 0, bile_expl2); }

void BecomeBileExplosion(entity this)
{
	set_movetype(this, MOVETYPE_NONE);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	this.solid = SOLID_NOT;
	_setmodel(this, "progs/greenexp.spr");
	setsize(this, '0 0 0', '0 0 0');
	bile_expl1(this);
}

void BileFragTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	vector org = this.origin - 8 * normalize(this.velocity);
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, 15, this.projectiledeathtype);
		T_RadiusDamage(this, this.owner, 50 * 0.4, this.projectiledeathtype, toucher);
	}
	else
	{
		if(this.nextthink > time)
			return;

		T_RadiusDamage(this, this.owner, 50 * 0.4, this.projectiledeathtype, NULL);
	}
	te_explosion2(org, 240, 3);
	_sound(this, CH_WEAPON_SINGLE, "gug/bile.wav", 0.5 + 0.5 * random(), 0.8);
	BecomeBileExplosion(this);
}

void BileFragThink(entity this)
{
	BileFragTouch(this, NULL);
}

void BileBombTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	vector org = this.origin - 8 * normalize(this.velocity);
	float damage = 85 * 0.5;
	damage += random() * 6; // add a bit of extra randomness to it for funsies
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, 25, this.projectiledeathtype);
		T_RadiusDamage(this, this.owner, damage, this.projectiledeathtype, toucher);
	}
	else
		T_RadiusDamage(this, this.owner, damage, this.projectiledeathtype, NULL);

	int bcnt = 0;
	while(bcnt < 5)
	{
		bcnt += 1;
		entity missile = spawn();
		missile.classname = "bilefrag";
		missile.owner = this;
		set_movetype(missile, MOVETYPE_BOUNCE);
		missile.projectiledeathtype = this.projectiledeathtype;
		missile.solid = SOLID_BBOX;
		makevectors(this.angles);
		missile.velocity_x = mrandom(1000);
		missile.velocity_y = mrandom(1000);
		missile.velocity_z = 250 + 100 * random();
		missile.avelocity = '300 300 300';
		missile.angles = vectoangles(missile.velocity);
		settouch(missile, BileFragTouch);
		missile.owner = this.owner;
		missile.realowner = this.realowner;
		missile.nextthink = time + 0.2 + 0.4 * random();
		setthink(missile, BileFragThink);
		_setmodel(missile, "progs/bilefrag.mdl");
		setsize(missile, '0 0 0', '0 0 0');
		setorigin(missile, this.origin);
	}
	te_explosion2(org, 240, 3);
	_sound(this, CH_WEAPON_SINGLE, "gug/bile.wav", 1, 0.8);
	BecomeBileExplosion(this);
}

void BileBombThink(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	this.angles = vectoangles(this.velocity);
	makevectors(this.angles);
	int t = 0;
	while(t < 2)
	{
		entity missile = spawn();
		missile.projectiledeathtype = this.projectiledeathtype;
		missile.owner = this.owner;
		missile.realowner = this.realowner;
		set_movetype(missile, MOVETYPE_TOSS);
		missile.solid = SOLID_BBOX;
		float spd = vlen(this.velocity);
		vector org = this.origin;
		vector vec = this.velocity;
		if(t == 0)
			vec = vec + v_right * (spd * 0.3);
		else
			vec = vec - v_right * (spd * 0.3);

		vec = normalize(vec);
		missile.velocity = vec * spd;
		missile.avelocity = '300 300 300';
		settouch(missile, BileBombTouch);
		_setmodel(missile, "progs/bilebomb.mdl");
		setsize(missile, '0 0 0', '0 0 0');
		setorigin(missile, org);
		t += 1;
	}
	delete(this);
}

void gug_bilebomb(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	entity missile = spawn();
	missile.owner = this;
	missile.projectiledeathtype = DEATH_MONSTER_GUG.m_id;
	set_movetype(missile, MOVETYPE_TOSS);
	missile.solid = SOLID_BBOX;
	float dist = vlen(this.enemy.origin - this.origin);
	float spd = 1000 / (850 / dist);
	makevectors(this.angles);
	vector org = this.origin;
	float t = vlen(this.enemy.origin - org) / spd;
	vector vec = vec2(this.enemy.velocity);
	vector d = this.enemy.origin + t * vec;
	vec = normalize(d - org);
	missile.velocity = vec;
	missile.velocity_z = 0;
	missile.velocity = missile.velocity * spd;
	t = this.enemy.origin_z - org_z;
	t = 250 + 1.3 * t;
	missile.velocity_z = t;
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	settouch(missile, BileBombTouch);
	missile.nextthink = time + 0.3;
	setthink(missile, BileBombThink);
	missile.enemy = this.enemy;
	_setmodel(missile, "progs/bilebomb.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin + '0 0 75');
}

void gug_bile26(entity this) { set_anim(this, 169, gug_run1); }
void gug_bile25(entity this) { set_anim(this, 168, gug_bile26); }
void gug_bile24(entity this) { set_anim(this, 167, gug_bile25); }
void gug_bile23(entity this) { set_anim(this, 166, gug_bile24); }
void gug_bile22(entity this) { set_anim(this, 165, gug_bile23); }
void gug_bile21(entity this) { set_anim(this, 164, gug_bile22); }
void gug_bile20(entity this) { set_anim(this, 163, gug_bile21); }
void gug_bile19(entity this) { set_anim(this, 162, gug_bile20); }
void gug_bile18(entity this) { set_anim(this, 161, gug_bile19); }
void gug_bile17(entity this) { set_anim(this, 160, gug_bile18); }
void gug_bile16(entity this) { set_anim(this, 159, gug_bile17); }
void gug_bile15(entity this) { set_anim(this, 158, gug_bile16); }
void gug_bile14(entity this) { set_anim(this, 157, gug_bile15); gug_bilebomb(this); this.pain_finished = time + 1.3; }
void gug_bile13(entity this) { set_anim(this, 156, gug_bile14); ai_face(this); }
void gug_bile12(entity this) { set_anim(this, 155, gug_bile13); ai_face(this); }
void gug_bile5(entity this) { set_anim(this, 154, gug_bile12); ai_face(this); }
void gug_bile3(entity this) { set_anim(this, 153, gug_bile5); ai_face(this); }
void gug_bile1(entity this) { set_anim(this, 152, gug_bile3); ai_face(this); }

void gug_missile(entity this)
{
	if(random() < 0.8 || this.t_width > time)
	{
		gug_bile1(this);
		_sound(this, CHAN_BODY, "gug/bileatk.wav", 1, 0.7);
	}
	else
	{
		gug_quake1(this);
		_sound(this, CHAN_BODY, "gug/quakeatk.wav", 1, 0.7);
	}
}

void gug_pain6(entity this) { set_anim(this, 199, gug_run1); ai_pain(this, 0); }
void gug_pain5(entity this) { set_anim(this, 198, gug_pain6); ai_pain(this, 0); }
void gug_pain4(entity this) { set_anim(this, 197, gug_pain5); ai_pain(this, 5); }
void gug_pain3(entity this) { set_anim(this, 196, gug_pain4); ai_pain(this, 6); }
void gug_pain2(entity this) { set_anim(this, 195, gug_pain3); ai_pain(this, 7); }
void gug_pain1(entity this) { set_anim(this, 194, gug_pain2); ai_pain(this, 8); }

void gug_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health <= 0)
		return;		// allready dying, don't go into pain frame

	if(random()*400 > damage && damage > 55)
		return;		// didn't flinch

	if(this.pain_finished > time)
		return;
	this.pain_finished = time + 3;

	// only roars when really hurt?
	_sound(this, CH_VOICE, "gug/pain.wav", 1, ATTN_NORM);
		
	gug_pain1(this);
}


//============================================================================

void gug_death41(entity this) { set_anim(this, 240, gug_death41); CorpseThink(this); }
void gug_death40(entity this) { set_anim(this, 239, gug_death41); }
void gug_death39(entity this) { set_anim(this, 238, gug_death40); }
void gug_death38(entity this) { set_anim(this, 237, gug_death39); }
void gug_death37(entity this) { set_anim(this, 236, gug_death38); }
void gug_death36(entity this) { set_anim(this, 235, gug_death37); }
void gug_death35(entity this) { set_anim(this, 234, gug_death36); }
void gug_death34(entity this) { set_anim(this, 233, gug_death35); }
void gug_death33(entity this) { set_anim(this, 232, gug_death34); }
void gug_death32(entity this) { set_anim(this, 231, gug_death33); }
void gug_death31(entity this) { set_anim(this, 230, gug_death32); }
void gug_death30(entity this) { set_anim(this, 229, gug_death31); }
void gug_death29(entity this) { set_anim(this, 228, gug_death30); }
void gug_death28(entity this) { set_anim(this, 227, gug_death29); }
void gug_death27(entity this) { set_anim(this, 226, gug_death28); }
void gug_death26(entity this) { set_anim(this, 225, gug_death27); }
void gug_death25(entity this)
{
	set_anim(this, 224, gug_death26);

	FOREACH_ENTITY_RADIUS(this.origin, 550, IS_PLAYER(it) && IS_ONGROUND(it),
	{
		gug_screen_shake(this, 0.4, it);
	});
}
void gug_death24(entity this) { set_anim(this, 223, gug_death25); }
void gug_death23(entity this) { set_anim(this, 222, gug_death24); }
void gug_death22(entity this) { set_anim(this, 221, gug_death23); }
void gug_death21(entity this) { set_anim(this, 220, gug_death22); }
void gug_death20(entity this) { set_anim(this, 219, gug_death21); }
void gug_death19(entity this) { set_anim(this, 218, gug_death20); }
void gug_death18(entity this) { set_anim(this, 217, gug_death19); }
void gug_death17(entity this) { set_anim(this, 216, gug_death18); }
void gug_death16(entity this) { set_anim(this, 215, gug_death17); }
void gug_death15(entity this) { set_anim(this, 214, gug_death16); }
void gug_death14(entity this) { set_anim(this, 213, gug_death15); }
void gug_death13(entity this) { set_anim(this, 212, gug_death14); }
void gug_death12(entity this) { set_anim(this, 211, gug_death13); }
void gug_death11(entity this) { set_anim(this, 210, gug_death12); }
void gug_death10(entity this) { set_anim(this, 209, gug_death11); }
void gug_death9(entity this) { set_anim(this, 208, gug_death10); }
void gug_death8(entity this) { set_anim(this, 207, gug_death9); }
void gug_death7(entity this) { set_anim(this, 206, gug_death8); }
void gug_death6(entity this) { set_anim(this, 205, gug_death7); }
void gug_death5(entity this) { set_anim(this, 204, gug_death6); }
void gug_death4(entity this) { set_anim(this, 203, gug_death5); }
void gug_death3(entity this) { set_anim(this, 202, gug_death4); }
void gug_death2(entity this) { set_anim(this, 201, gug_death3); }
void gug_death1(entity this) { set_anim(this, 200, gug_death2); this.solid = SOLID_NOT; }

void gug_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -80 || this.dmg_take > (this.max_health * 0.6))
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		this.solid = SOLID_NOT;
		this.takedamage = DAMAGE_NO;
		settouch(this, func_null);
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return;
	}

// regular death
	_sound(this, CH_VOICE, "gug/death.wav", 1, ATTN_NORM);
	gug_death1(this);
}

/*
===========
CheckGugAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool CheckGugAttack(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	if(vdist(spot1 - spot2, >, 1200))
		return false;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}

	// we're doing so many checks that vlen is actually cheaper!
	float dist = vlen(spot1 - spot2);
	float chance = 0;

	if(dist >= 600)
	{
		chance = 0.9;
		this.attack_finished = 0;
	}
	else if(dist >= 250)
		chance = 0.8;
	else if(dist >= 170)
		chance = 0.2;

	if(random() > chance)
		return false;
			
// missile attack
		
	this.attack_state = AS_MISSILE;
	this.attack_finished = time + 2.3 + 0.3 * random();
	return true;
}

/*QUAKED monster_gug(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_gug) { monster_start(this, true, MON_GUG); }
#endif // SVQC

#ifdef SVQC
METHOD(Gug, mr_setup, bool(Gug this, entity actor))
{
    TC(Gug, this);

	precache_model("progs/bilebomb.mdl");
	precache_model("progs/bilefrag.mdl");
	precache_model("progs/greenexp.spr");
	precache_sound("gug/step1.wav");
	precache_sound("gug/step2.wav");
	precache_sound("gug/step3.wav");
	precache_sound("gug/step4.wav");
	precache_sound("gug/pain.wav");
	precache_sound("gug/death.wav");
	precache_sound("gug/idle.wav");
	precache_sound("gug/bileatk.wav");
	precache_sound("gug/swipe.wav");
	precache_sound("gug/quakeatk.wav");
	precache_sound("gug/bile.wav");
	precache_sound("gug/gquake.wav");
	precache_sound("gug/throw.wav");
	precache_sound("shambler/smack.wav");

	actor.yaw_speed = 15;
    actor.health = 800;
    actor.th_stand = gug_stand1;
	actor.th_walk = gug_walk1;
	actor.th_run = gug_run1;
	actor.th_die = gug_die;
	actor.th_melee = gug_melee;
	actor.th_missile = gug_missile;
	actor.th_pain = gug_pain;

	actor.checkattack = CheckGugAttack;

    return true;
}
#endif
