#include "overlord.qh"

#include "wrath.qh"

#ifdef SVQC
const int anim_swrath_s_wrtfrm = 0; //'0 0 0';
const int anim_swrath_s_wtwk = 1; //'1 15 0';
const int anim_swrath_s_wtaa = 16; //'16 25 0';
const int anim_swrath_s_wtab = 26; //'26 39 0';
const int anim_swrath_s_wtac = 40; //'40 53 0';
const int anim_swrath_s_wtba = 54; //'54 65 0';
const int anim_swrath_s_wtpa = 66; //'66 79 0';
const int anim_swrath_s_wtpb = 80; //'80 90 0';
const int anim_swrath_s_wtdt = 91; //'91 107 0';

bool isSpawnPointEmpty(entity thePoint)
{
	entity neighbors = findradius(thePoint.origin, 64);
	if(neighbors == NULL)
		return true;

	entity start = neighbors;
	while(neighbors)
	{
		if(neighbors != thePoint && !is_pure(neighbors))
		{
			if(IS_MONSTER(neighbors))
			{
				return false;
			}
			else if(IS_PLAYER(neighbors))
			{
				return false;
			}
			else if(getthink(neighbors) && (neighbors.solid == SOLID_BBOX || neighbors.solid == SOLID_BSP || neighbors.solid == SOLID_SLIDEBOX))
			{
				return false;
			}
		}
		
		neighbors = neighbors.chain;
		if(neighbors == start)
			return true;
	}
	return true;
}

entity overlord_find_newdest(entity this)
{
	entity point = new(overlord_tempdest);
	setthink(point, SUB_Remove);
	point.nextthink = time + 0.1; // we only need it for a single frame!
	setsize(point, this.mins, this.maxs);
	vector extrasize = '1 1 1' * 1200;

	if(MoveToRandomLocationWithinBounds(point, this.absmin - extrasize, this.absmax + extrasize,
											DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, 
											Q3SURFACEFLAG_SKY, 10, 64, 256, true))
	{
		// no special treatment needed, we're just using it as a position!
		point.mangle = '0 1 0' * point.angles_y;
		point.angles = '0 0 0';
		return point;
	}

	// we tried
	delete(point);
	return NULL;
}

entity overlord_find_dest3(entity this)
{
	entity furthestDest = NULL;
	entity bestDest = NULL;
	float theDist = 0;
	entity thePlayer = NULL;
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(!thePlayer || vlen2(it.origin - this.origin) < vlen2(thePlayer.origin - this.origin))
			thePlayer = it;
	});
	entity curDest = NULL;

	makevectors(thePlayer.angles);

	while(1)
	{
		curDest = find(curDest, classname, "info_overlord_destination");
		if(!curDest)
		{
			if(bestDest)
				return bestDest;
			if(furthestDest)
				return furthestDest;
			if(horde_ent)
				return NULL;
			return overlord_find_newdest(this);
		}

		if(isSpawnPointEmpty(curDest))
		{
			vector curVector = curDest.origin - thePlayer.origin;
			float curDist = vlen(curVector);
			curVector = normalize(curVector);
			float dot = curVector * v_forward;
			if( dot > 0.6 )
			{
				if(curDist > 150)
				{
					bestDest = curDest;
				}
			}
			
			if(curDist > theDist )
			{
				furthestDest = curDest;
				theDist = curDist;
			} 
		}
	}

	// just in case, return the NULL.
	return NULL;
}

// =======================================================

entity overlord_find_dest()
{
	entity curDest = find(NULL, classname, "info_overlord_destination");
	if(curDest != NULL)
	{
		entity lastDest = curDest;
		int loopCount = rint(random()*5);
		while (loopCount > 1)
		{
			curDest = nextent ( curDest );
			curDest = find(curDest, classname, "info_overlord_destination");
			if(curDest != NULL)
			{
				if(isSpawnPointEmpty(curDest))
				{
					loopCount = loopCount - 1;
					lastDest = curDest;
				}
				else
					curDest = NULL;
			}
			else
			{
				return lastDest;
			}
		}
		return curDest;
	}
	return curDest;
}


void overlord_teleport(entity this)
{
	if(!(this.spawnflags & 2))
		return;

	float chance = random();
	if(chance > 0.75)
		return;

//    theDest = overlord_find_dest();
	entity theDest = overlord_find_dest3(this);
	if(theDest == NULL)
		return;

// put a tfog where the player was
	spawn_tfog(this.origin);

// spawn a tfog flash in front of the destination
	makevectors(this.angles);
	vector org = theDest.origin + 32 * v_forward;

	spawn_tfog(org);
	spawn_tdeath(theDest.origin, this);

	setorigin(this, theDest.origin);
	UNSET_ONGROUND(this);
}
// =======================================================

void overlord_stand1(entity this) { set_anim(this, anim_swrath_s_wtwk, overlord_stand1); ai_stand(this); }

void overlord_walk01(entity this);
void overlord_walk15(entity this) { set_animofs(this, anim_swrath_s_wtwk, 15, overlord_walk01); ai_walk(this, 8); }
void overlord_walk14(entity this) { set_animofs(this, anim_swrath_s_wtwk, 14, overlord_walk15); ai_walk(this, 8); }
void overlord_walk13(entity this) { set_animofs(this, anim_swrath_s_wtwk, 13, overlord_walk14); ai_walk(this, 8); }
void overlord_walk12(entity this) { set_animofs(this, anim_swrath_s_wtwk, 12, overlord_walk13); ai_walk(this, 8); }
void overlord_walk11(entity this) { set_animofs(this, anim_swrath_s_wtwk, 11, overlord_walk12); ai_walk(this, 8); }
void overlord_walk10(entity this) { set_animofs(this, anim_swrath_s_wtwk, 10, overlord_walk11); ai_walk(this, 8); }
void overlord_walk09(entity this) { set_animofs(this, anim_swrath_s_wtwk, 9, overlord_walk10); ai_walk(this, 8); }
void overlord_walk08(entity this) { set_animofs(this, anim_swrath_s_wtwk, 8, overlord_walk09); ai_walk(this, 8); }
void overlord_walk07(entity this) { set_animofs(this, anim_swrath_s_wtwk, 7, overlord_walk08); ai_walk(this, 8); }
void overlord_walk06(entity this) { set_animofs(this, anim_swrath_s_wtwk, 6, overlord_walk07); ai_walk(this, 8); }
void overlord_walk05(entity this) { set_animofs(this, anim_swrath_s_wtwk, 5, overlord_walk06); ai_walk(this, 8); }
void overlord_walk04(entity this) { set_animofs(this, anim_swrath_s_wtwk, 4, overlord_walk05); ai_walk(this, 8); }
void overlord_walk03(entity this) { set_animofs(this, anim_swrath_s_wtwk, 3, overlord_walk04); ai_walk(this, 8); }
void overlord_walk02(entity this) { set_animofs(this, anim_swrath_s_wtwk, 2, overlord_walk03); ai_walk(this, 8); }
void overlord_walk01(entity this) { set_animofs(this, anim_swrath_s_wtwk, 1, overlord_walk02); ai_walk(this, 8); }

void overlord_run01(entity this);
void overlord_run15(entity this) { set_animofs(this, anim_swrath_s_wtwk, 15, overlord_run01); ai_run(this, 12); }
void overlord_run14(entity this) { set_animofs(this, anim_swrath_s_wtwk, 14, overlord_run15); ai_run(this, 12); }
void overlord_run13(entity this) { set_animofs(this, anim_swrath_s_wtwk, 13, overlord_run14); ai_run(this, 12); }
void overlord_run12(entity this) { set_animofs(this, anim_swrath_s_wtwk, 12, overlord_run13); ai_run(this, 12); }
void overlord_run11(entity this) { set_animofs(this, anim_swrath_s_wtwk, 11, overlord_run12); ai_run(this, 12); }
void overlord_run10(entity this) { set_animofs(this, anim_swrath_s_wtwk, 10, overlord_run11); ai_run(this, 12); }
void overlord_run09(entity this) { set_animofs(this, anim_swrath_s_wtwk, 9, overlord_run10); ai_run(this, 12); }
void overlord_run08(entity this) { set_animofs(this, anim_swrath_s_wtwk, 8, overlord_run09); ai_run(this, 12); }
void overlord_run07(entity this) { set_animofs(this, anim_swrath_s_wtwk, 7, overlord_run08); ai_run(this, 12); }
void overlord_run06(entity this) { set_animofs(this, anim_swrath_s_wtwk, 6, overlord_run07); ai_run(this, 12); }
void overlord_run05(entity this) { set_animofs(this, anim_swrath_s_wtwk, 5, overlord_run06); ai_run(this, 12); }
void overlord_run04(entity this) { set_animofs(this, anim_swrath_s_wtwk, 4, overlord_run05); ai_run(this, 12); }
void overlord_run03(entity this) { set_animofs(this, anim_swrath_s_wtwk, 3, overlord_run04); ai_run(this, 12); }
void overlord_run02(entity this) { set_animofs(this, anim_swrath_s_wtwk, 2, overlord_run03); ai_run(this, 12); }
void overlord_run01(entity this) { set_animofs(this, anim_swrath_s_wtwk, 1, overlord_run02); ai_run(this, 12); }

// =================================================
// overlord hand-to-hand attack
// =================================================
void overlord_smash(entity this);

void overlord_at_a10(entity this) { set_animofs(this, anim_swrath_s_wtaa, 10, overlord_run01); ai_charge(this, 12); }
void overlord_at_a09(entity this) { set_animofs(this, anim_swrath_s_wtaa, 9, overlord_at_a10); ai_charge(this, 12); }
void overlord_at_a08(entity this) { set_animofs(this, anim_swrath_s_wtaa, 8, overlord_at_a09); ai_charge(this, 12); }
void overlord_at_a07(entity this) { set_animofs(this, anim_swrath_s_wtaa, 7, overlord_at_a08); overlord_smash(this); }
void overlord_at_a06(entity this) { set_animofs(this, anim_swrath_s_wtaa, 6, overlord_at_a07); ai_charge(this, 12); }
void overlord_at_a05(entity this) { set_animofs(this, anim_swrath_s_wtaa, 5, overlord_at_a06); ai_charge(this, 12); }
void overlord_at_a04(entity this) { set_animofs(this, anim_swrath_s_wtaa, 4, overlord_at_a05); ai_charge(this, 12); }
void overlord_at_a03(entity this) { set_animofs(this, anim_swrath_s_wtaa, 3, overlord_at_a04); ai_charge(this, 12); }
void overlord_at_a02(entity this) { set_animofs(this, anim_swrath_s_wtaa, 2, overlord_at_a03); ai_charge(this, 12); }
void overlord_at_a01(entity this) { set_animofs(this, anim_swrath_s_wtaa, 1, overlord_at_a02); ai_charge(this, 12); }

void overlord_at_b14(entity this) { set_animofs(this, anim_swrath_s_wtab, 14, overlord_run01); ai_charge(this, 12); }
void overlord_at_b13(entity this) { set_animofs(this, anim_swrath_s_wtab, 13, overlord_at_b14); ai_charge(this, 12); }
void overlord_at_b12(entity this) { set_animofs(this, anim_swrath_s_wtab, 12, overlord_at_b13); ai_charge(this, 12); }
void overlord_at_b11(entity this) { set_animofs(this, anim_swrath_s_wtab, 11, overlord_at_b12); ai_charge(this, 12); }
void overlord_at_b10(entity this) { set_animofs(this, anim_swrath_s_wtab, 10, overlord_at_b11); ai_charge(this, 12); }
void overlord_at_b09(entity this) { set_animofs(this, anim_swrath_s_wtab, 9, overlord_at_b10); ai_charge(this, 12); }
void overlord_at_b08(entity this) { set_animofs(this, anim_swrath_s_wtab, 8, overlord_at_b09); overlord_smash(this); }
void overlord_at_b07(entity this) { set_animofs(this, anim_swrath_s_wtab, 7, overlord_at_b08); ai_charge(this, 12); }
void overlord_at_b06(entity this) { set_animofs(this, anim_swrath_s_wtab, 6, overlord_at_b07); ai_charge(this, 12); }
void overlord_at_b05(entity this) { set_animofs(this, anim_swrath_s_wtab, 5, overlord_at_b06); ai_charge(this, 12); }
void overlord_at_b04(entity this) { set_animofs(this, anim_swrath_s_wtab, 4, overlord_at_b05); ai_charge(this, 12); }
void overlord_at_b03(entity this) { set_animofs(this, anim_swrath_s_wtab, 3, overlord_at_b04); ai_charge(this, 12); }
void overlord_at_b02(entity this) { set_animofs(this, anim_swrath_s_wtab, 2, overlord_at_b03); ai_charge(this, 12); }
void overlord_at_b01(entity this) { set_animofs(this, anim_swrath_s_wtab, 1, overlord_at_b02); ai_charge(this, 12); }

void overlord_at_c14(entity this) { set_animofs(this, anim_swrath_s_wtac, 14, overlord_run01); ai_charge(this, 12); }
void overlord_at_c13(entity this) { set_animofs(this, anim_swrath_s_wtac, 13, overlord_at_c14); ai_charge(this, 12); }
void overlord_at_c12(entity this) { set_animofs(this, anim_swrath_s_wtac, 12, overlord_at_c13); ai_charge(this, 12); }
void overlord_at_c11(entity this) { set_animofs(this, anim_swrath_s_wtac, 11, overlord_at_c12); overlord_smash(this); }
void overlord_at_c10(entity this) { set_animofs(this, anim_swrath_s_wtac, 10, overlord_at_c11); ai_charge(this, 12); }
void overlord_at_c09(entity this) { set_animofs(this, anim_swrath_s_wtac, 9, overlord_at_c10); ai_charge(this, 12); }
void overlord_at_c08(entity this) { set_animofs(this, anim_swrath_s_wtac, 8, overlord_at_c09); ai_charge(this, 12); }
void overlord_at_c07(entity this) { set_animofs(this, anim_swrath_s_wtac, 7, overlord_at_c08); ai_charge(this, 12); }
void overlord_at_c06(entity this) { set_animofs(this, anim_swrath_s_wtac, 6, overlord_at_c07); overlord_smash(this); }
void overlord_at_c05(entity this) { set_animofs(this, anim_swrath_s_wtac, 5, overlord_at_c06); ai_charge(this, 12); }
void overlord_at_c04(entity this) { set_animofs(this, anim_swrath_s_wtac, 4, overlord_at_c05); ai_charge(this, 12); }
void overlord_at_c03(entity this) { set_animofs(this, anim_swrath_s_wtac, 3, overlord_at_c04); ai_charge(this, 12); }
void overlord_at_c02(entity this) { set_animofs(this, anim_swrath_s_wtac, 2, overlord_at_c03); ai_charge(this, 12); }
void overlord_at_c01(entity this) { set_animofs(this, anim_swrath_s_wtac, 1, overlord_at_c02); ai_charge(this, 12); }

void overlord_smash(entity this)
{
	if(!this.enemy)
		return;
	if(!CanDamage(this.enemy, this))
		return;

	ai_charge(this, 10);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;

	float smashDmg = 20 + random () * 10;
	
	_sound(this, CH_WEAPON_SINGLE, "s_wrath/smash.wav", 1, ATTN_NORM);
	T_Damage(this.enemy, this, this, smashDmg, DEATH_MONSTER_OVERLORD.m_id);
	vector delta = normalize (this.enemy.origin - this.origin + this.enemy.view_ofs);
	SpawnBlood(this.enemy.origin - delta * 30, delta * -100, smashDmg, this.enemy);
}

void overlord_melee(entity this)
{
	float r = random();

	if(r < 0.33)
		overlord_at_a01(this);
	else if(r < 0.66)
		overlord_at_b01(this);
	else
		overlord_at_c01(this);
}

// ==================================================
// missile attacks
// ==================================================

void overlord_msl_a12(entity this) { set_animofs(this, anim_swrath_s_wtba, 12, overlord_run01); overlord_teleport(this); }
void overlord_msl_a11(entity this) { set_animofs(this, anim_swrath_s_wtba, 11, overlord_msl_a12); ai_charge(this, 12); }
void overlord_msl_a10(entity this) { set_animofs(this, anim_swrath_s_wtba, 10, overlord_msl_a11); ai_charge(this, 12); }
void overlord_msl_a09(entity this) { set_animofs(this, anim_swrath_s_wtba, 9, overlord_msl_a10); ai_charge(this, 12); }
void overlord_msl_a08(entity this) { set_animofs(this, anim_swrath_s_wtba, 8, overlord_msl_a09); ai_charge(this, 12); }
void overlord_msl_a07(entity this) { set_animofs(this, anim_swrath_s_wtba, 7, overlord_msl_a08); ai_charge(this, 12); }
void overlord_msl_a06(entity this) { set_animofs(this, anim_swrath_s_wtba, 6, overlord_msl_a07); WrathMissile(this, 4); }
void overlord_msl_a05(entity this) { set_animofs(this, anim_swrath_s_wtba, 5, overlord_msl_a06); ai_charge(this, 12); }
void overlord_msl_a04(entity this) { set_animofs(this, anim_swrath_s_wtba, 4, overlord_msl_a05); ai_charge(this, 12); }
void overlord_msl_a03(entity this) { set_animofs(this, anim_swrath_s_wtba, 3, overlord_msl_a04); ai_charge(this, 12); }
void overlord_msl_a02(entity this) { set_animofs(this, anim_swrath_s_wtba, 2, overlord_msl_a03); ai_charge(this, 12); }
void overlord_msl_a01(entity this) { set_animofs(this, anim_swrath_s_wtba, 1, overlord_msl_a02); ai_charge(this, 12); }

void overlord_missile(entity this)
{
	//float r = random();

	overlord_msl_a01(this);
}

// ==================================================
// pain
// ==================================================
void overlord_pn_a07(entity this) { set_animofs(this, anim_swrath_s_wtpa, 7, overlord_run01); }
void overlord_pn_a06(entity this) { set_animofs(this, anim_swrath_s_wtpa, 6, overlord_pn_a07); }
void overlord_pn_a05(entity this) { set_animofs(this, anim_swrath_s_wtpa, 5, overlord_pn_a06); }
void overlord_pn_a04(entity this) { set_animofs(this, anim_swrath_s_wtpa, 4, overlord_pn_a05); }
void overlord_pn_a03(entity this) { set_animofs(this, anim_swrath_s_wtpa, 3, overlord_pn_a04); overlord_teleport(this); }
void overlord_pn_a02(entity this) { set_animofs(this, anim_swrath_s_wtpa, 2, overlord_pn_a03); }
void overlord_pn_a01(entity this) { set_animofs(this, anim_swrath_s_wtpa, 1, overlord_pn_a02); }

void overlord_pn_b07(entity this) { set_animofs(this, anim_swrath_s_wtpb, 7, overlord_run01); }
void overlord_pn_b06(entity this) { set_animofs(this, anim_swrath_s_wtpb, 6, overlord_pn_b07); }
void overlord_pn_b05(entity this) { set_animofs(this, anim_swrath_s_wtpb, 5, overlord_pn_b06); }
void overlord_pn_b04(entity this) { set_animofs(this, anim_swrath_s_wtpb, 4, overlord_pn_b05); }
void overlord_pn_b03(entity this) { set_animofs(this, anim_swrath_s_wtpb, 3, overlord_pn_b04); overlord_teleport(this); }
void overlord_pn_b02(entity this) { set_animofs(this, anim_swrath_s_wtpb, 2, overlord_pn_b03); }
void overlord_pn_b01(entity this) { set_animofs(this, anim_swrath_s_wtpb, 1, overlord_pn_b02); }

void overlord_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	
	if(r > 0.2)
		return;
			
	if(r < 0.15)
		overlord_pn_a01(this);
	else 
		overlord_pn_b01(this);

	this.pain_finished = time + 2;
	_sound(this, CH_VOICE, "wrath/wpain.wav", 1, ATTN_NORM);
}

void ol_toss(entity this, string gibName)
{
	makevectors(this.angles);
	vector flingVelocity = v_forward*250 + v_up*300;
	flingVelocity = flingVelocity + v_up * (random() * 100 - 50);
	flingVelocity = flingVelocity + v_right * (random() * 200 - 100);
	
	entity myGib = StartGib(this, gibName);
	myGib.velocity = flingVelocity;
}

// note - death frame 9 is intentionally done twice.
void overlord_die19(entity this)
{
	set_animofs(this, anim_swrath_s_wtdt, 17, overlord_die19);

	int counter = 2;

	te_explosion2(this.origin, 0, 4);

	while(counter > 0)
	{
		ol_toss(this, "progs/gib1.mdl");
		ol_toss(this, "progs/gib2.mdl");
		ol_toss(this, "progs/gib3.mdl");
		counter = counter - 1;
	}

	delete(this);
}
void overlord_die18(entity this) 
{
	set_animofs(this, anim_swrath_s_wtdt, 17, overlord_die19);

	int counter = 2;

	te_explosion2(this.origin, 0, 4);

	while(counter>0)
	{
		ol_toss(this, "progs/gib1.mdl");
		ol_toss(this, "progs/gib2.mdl");
		ol_toss(this, "progs/gib3.mdl");
		counter = counter - 1;
	}
	this.nextthink = time + 0.1;
}
void overlord_die17(entity this)
{
	set_animofs(this, anim_swrath_s_wtdt, 16, overlord_die18);

	this.model = "";

	te_explosion2(this.origin, 0, 4);

	ol_toss(this, "progs/s_wrtgb2.mdl");
	ol_toss(this, "progs/s_wrtgb3.mdl");
	ol_toss(this, "progs/wrthgib1.mdl");
	ol_toss(this, "progs/wrthgib2.mdl");
	ol_toss(this, "progs/wrthgib3.mdl");
	this.nextthink = time + 0.1;
}
void overlord_die16(entity this) { set_animofs(this, anim_swrath_s_wtdt, 15, overlord_die17); this.nextthink = time + 0.05; }
void overlord_die15(entity this) { set_animofs(this, anim_swrath_s_wtdt, 14, overlord_die16); this.nextthink = time + 0.05; }
void overlord_die14(entity this) { set_animofs(this, anim_swrath_s_wtdt, 13, overlord_die15); this.nextthink = time + 0.05; }
void overlord_die13(entity this) { set_animofs(this, anim_swrath_s_wtdt, 12, overlord_die14); this.nextthink = time + 0.05; }
void overlord_die12(entity this) { set_animofs(this, anim_swrath_s_wtdt, 11, overlord_die13); this.nextthink = time + 0.05; }
void overlord_die11(entity this) { set_animofs(this, anim_swrath_s_wtdt, 10, overlord_die12); this.nextthink = time + 0.05; }
void overlord_die10(entity this) { set_animofs(this, anim_swrath_s_wtdt, 9, overlord_die11); this.nextthink = time + 0.05; }
void overlord_die09(entity this) { set_animofs(this, anim_swrath_s_wtdt, 9, overlord_die10); this.nextthink = time + 0.05; }
void overlord_die08(entity this) { set_animofs(this, anim_swrath_s_wtdt, 8, overlord_die09); this.nextthink = time + 0.05; }
void overlord_die07(entity this) { set_animofs(this, anim_swrath_s_wtdt, 7, overlord_die08); this.nextthink = time + 0.05; }
void overlord_die06(entity this) { set_animofs(this, anim_swrath_s_wtdt, 6, overlord_die07); this.nextthink = time + 0.05; }
void overlord_die05(entity this) { set_animofs(this, anim_swrath_s_wtdt, 5, overlord_die06); this.nextthink = time + 0.05; }
void overlord_die04(entity this) { set_animofs(this, anim_swrath_s_wtdt, 4, overlord_die05); this.nextthink = time + 0.05; }
void overlord_die03(entity this) { set_animofs(this, anim_swrath_s_wtdt, 3, overlord_die04); this.nextthink = time + 0.05; }
void overlord_die02(entity this) { set_animofs(this, anim_swrath_s_wtdt, 2, overlord_die03); this.flags |= FL_FLY; this.nextthink = time + 0.05; }
//oid overlord_die01(entity this) { set_animofs(this, anim_swrath_s_wtdt, 1, overlord_die02); this.nextthink = time + 0.05; }

void overlord_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -150)
	{
		overlord_die19(this);
		return;
	}
	overlord_die02(this);
}

/*QUAKED info_overlord_destination (.5 .5 .5) (-8 -8 -8) (8 8 32) 
This is the destination marker for the overlord.

It does not require any other fields filled in.
*/
spawnfunc(info_overlord_destination)
{
	if(!MP_ROGUE) { delete(this); return; }

// this does nothing, just serves as a target spot
	this.mangle = this.angles;
	this.angles = '0 0 0';
	this.model = "";
	setorigin(this, this.origin + '0 0 27');
}

/*QUAKED monster_super_wrath (1 0 0) (-16 -16 -24) (16 16 32) Ambush BossMode
The super wrath (Overlord).

BossMode enables the superwrath's powershield and the random teleporting.
*/
spawnfunc(monster_super_wrath)
{
	if(!MP_ROGUE) { delete(this); return; }
	monster_start(this, true, MON_OVERLORD);
}
#endif // SVQC

#ifdef SVQC
METHOD(Overlord, mr_setup, bool(Overlord this, entity actor))
{
    TC(Overlord, this);

	precache_model("progs/s_wrtgb1.mdl");
	precache_model("progs/s_wrtgb2.mdl");
	precache_model("progs/s_wrtgb3.mdl");
	precache_model("progs/wrthgib1.mdl");
	precache_model("progs/wrthgib2.mdl");
	precache_model("progs/wrthgib3.mdl");

	precache_model("progs/w_ball.mdl");
	precache_sound("wrath/watt.wav");
	precache_sound("wrath/wpain.wav");
	precache_sound("wrath/wdthc.wav");
	precache_sound("s_wrath/smash.wav");

    actor.health = 1000;
	actor.pain_finished = 0;
	
//    if(actor.spawnflags & 2)
//       actor.powerups = POWERUP_SHIELD;

	// uncomment for a potentially broken fight
	//if(autocvar_skill == 3)
		//actor.spawnflags |= 2;
	actor.th_stand = overlord_stand1;
	actor.th_walk = overlord_walk01;
	actor.th_run = overlord_run01;
	actor.th_missile = overlord_missile;
	actor.th_melee = overlord_melee;
	actor.th_pain = overlord_pain;
	actor.th_die = overlord_die;

    return true;
}
#endif
