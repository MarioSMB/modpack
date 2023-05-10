#include "spawn.qh"

#ifdef SVQC
const int anim_tbaby_walk = 0; //'0 24 0'
const int anim_tbaby_run = 25; //'25 49 0'
const int anim_tbaby_jump = 50; //'50 55 0'
const int anim_tbaby_fly = 56; //'56 59 0'
const int anim_tbaby_exp = 60; //'60 60 0'

void tbaby_stand1(entity this) { set_animofs(this, anim_tbaby_walk, 1, tbaby_stand1); ai_stand(this); }

void tbaby_hang1(entity this) { set_animofs(this, anim_tbaby_walk, 1, tbaby_hang1); ai_stand(this); }

void tbaby_walk1(entity this);
void tbaby_walk25(entity this) { set_animofs(this, anim_tbaby_walk, 25, tbaby_walk1); ai_walk(this, 2); }
void tbaby_walk24(entity this) { set_animofs(this, anim_tbaby_walk, 24, tbaby_walk25); ai_walk(this, 2); }
void tbaby_walk23(entity this) { set_animofs(this, anim_tbaby_walk, 23, tbaby_walk24); ai_walk(this, 2); }
void tbaby_walk22(entity this) { set_animofs(this, anim_tbaby_walk, 22, tbaby_walk23); ai_walk(this, 2); }
void tbaby_walk21(entity this) { set_animofs(this, anim_tbaby_walk, 21, tbaby_walk22); ai_walk(this, 2); }
void tbaby_walk20(entity this) { set_animofs(this, anim_tbaby_walk, 20, tbaby_walk21); ai_walk(this, 2); }
void tbaby_walk19(entity this) { set_animofs(this, anim_tbaby_walk, 19, tbaby_walk20); ai_walk(this, 2); }
void tbaby_walk18(entity this) { set_animofs(this, anim_tbaby_walk, 18, tbaby_walk19); ai_walk(this, 2); }
void tbaby_walk17(entity this) { set_animofs(this, anim_tbaby_walk, 17, tbaby_walk18); ai_walk(this, 2); }
void tbaby_walk16(entity this) { set_animofs(this, anim_tbaby_walk, 16, tbaby_walk17); ai_walk(this, 2); }
void tbaby_walk15(entity this) { set_animofs(this, anim_tbaby_walk, 15, tbaby_walk16); ai_walk(this, 2); }
void tbaby_walk14(entity this) { set_animofs(this, anim_tbaby_walk, 14, tbaby_walk15); ai_walk(this, 2); }
void tbaby_walk13(entity this) { set_animofs(this, anim_tbaby_walk, 13, tbaby_walk14); ai_walk(this, 2); }
void tbaby_walk12(entity this) { set_animofs(this, anim_tbaby_walk, 12, tbaby_walk13); ai_walk(this, 2); }
void tbaby_walk11(entity this) { set_animofs(this, anim_tbaby_walk, 11, tbaby_walk12); ai_walk(this, 2); }
void tbaby_walk10(entity this) { set_animofs(this, anim_tbaby_walk, 10, tbaby_walk11); ai_turn(this); }
void tbaby_walk9(entity this) { set_animofs(this, anim_tbaby_walk, 9, tbaby_walk10); ai_turn(this); }
void tbaby_walk8(entity this) { set_animofs(this, anim_tbaby_walk, 8, tbaby_walk9); ai_turn(this); }
void tbaby_walk7(entity this) { set_animofs(this, anim_tbaby_walk, 7, tbaby_walk8); ai_turn(this); }
void tbaby_walk6(entity this) { set_animofs(this, anim_tbaby_walk, 6, tbaby_walk7); ai_turn(this); }
void tbaby_walk5(entity this) { set_animofs(this, anim_tbaby_walk, 5, tbaby_walk6); ai_turn(this); }
void tbaby_walk4(entity this) { set_animofs(this, anim_tbaby_walk, 4, tbaby_walk5); ai_turn(this); }
void tbaby_walk3(entity this) { set_animofs(this, anim_tbaby_walk, 3, tbaby_walk4); ai_turn(this); }
void tbaby_walk2(entity this) { set_animofs(this, anim_tbaby_walk, 2, tbaby_walk3); ai_turn(this); }
void tbaby_walk1(entity this) { set_animofs(this, anim_tbaby_walk, 1, tbaby_walk2); ai_turn(this); }

void tbaby_run1(entity this);
void tbaby_run25(entity this) { set_animofs(this, anim_tbaby_run, 25, tbaby_run1); ai_run(this, 2); }
void tbaby_run24(entity this) { set_animofs(this, anim_tbaby_run, 24, tbaby_run25); ai_run(this, 2); }
void tbaby_run23(entity this) { set_animofs(this, anim_tbaby_run, 23, tbaby_run24); ai_run(this, 2); }
void tbaby_run22(entity this) { set_animofs(this, anim_tbaby_run, 22, tbaby_run23); ai_run(this, 2); }
void tbaby_run21(entity this) { set_animofs(this, anim_tbaby_run, 21, tbaby_run22); ai_run(this, 2); }
void tbaby_run20(entity this) { set_animofs(this, anim_tbaby_run, 20, tbaby_run21); ai_run(this, 2); }
void tbaby_run19(entity this) { set_animofs(this, anim_tbaby_run, 19, tbaby_run20); ai_run(this, 2); }
void tbaby_run18(entity this) { set_animofs(this, anim_tbaby_run, 18, tbaby_run19); ai_run(this, 2); }
void tbaby_run17(entity this) { set_animofs(this, anim_tbaby_run, 17, tbaby_run18); ai_run(this, 2); }
void tbaby_run16(entity this) { set_animofs(this, anim_tbaby_run, 16, tbaby_run17); ai_run(this, 2); }
void tbaby_run15(entity this) { set_animofs(this, anim_tbaby_run, 15, tbaby_run16); ai_run(this, 2); }
void tbaby_run14(entity this) { set_animofs(this, anim_tbaby_run, 14, tbaby_run15); ai_run(this, 2); }
void tbaby_run13(entity this) { set_animofs(this, anim_tbaby_run, 13, tbaby_run14); ai_run(this, 2); }
void tbaby_run12(entity this) { set_animofs(this, anim_tbaby_run, 12, tbaby_run13); ai_run(this, 2); }
void tbaby_run11(entity this) { set_animofs(this, anim_tbaby_run, 11, tbaby_run12); ai_run(this, 2); }
void tbaby_run10(entity this) { set_animofs(this, anim_tbaby_run, 10, tbaby_run11); ai_face(this); }
void tbaby_run9(entity this) { set_animofs(this, anim_tbaby_run, 9, tbaby_run10); ai_face(this); }
void tbaby_run8(entity this) { set_animofs(this, anim_tbaby_run, 8, tbaby_run9); ai_face(this); }
void tbaby_run7(entity this) { set_animofs(this, anim_tbaby_run, 7, tbaby_run8); ai_face(this); }
void tbaby_run6(entity this) { set_animofs(this, anim_tbaby_run, 6, tbaby_run7); ai_face(this); }
void tbaby_run5(entity this) { set_animofs(this, anim_tbaby_run, 5, tbaby_run6); ai_face(this); }
void tbaby_run4(entity this) { set_animofs(this, anim_tbaby_run, 4, tbaby_run5); ai_face(this); }
void tbaby_run3(entity this) { set_animofs(this, anim_tbaby_run, 3, tbaby_run4); ai_face(this); }
void tbaby_run2(entity this) { set_animofs(this, anim_tbaby_run, 2, tbaby_run3); ai_face(this); }
void tbaby_run1(entity this) { set_animofs(this, anim_tbaby_run, 1, tbaby_run2); ai_face(this); }


//============================================================================


void tbaby_jump1(entity this);

void Tar_JumpTouch(entity this, entity toucher)
{
	if((this.health <= 0 || !this.takedamage))
		return;
	if(toucher.takedamage && toucher.classname != this.classname)
	{
		if( vdist(this.velocity, >, 400) )
		{
			float ldmg = 10 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_SPAWN.m_id);	
			_sound(this, CH_WEAPON_SINGLE, "blob/hit1.wav", 1, ATTN_NORM);
		}
	}
	else
		_sound(this, CH_WEAPON_SINGLE, "blob/land1.wav", 1, ATTN_NORM);


	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this))
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, tbaby_run1);
			set_movetype(this, MOVETYPE_STEP);
			this.nextthink = time + 0.1;

		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	setthink(this, tbaby_jump1);
	this.nextthink = time + 0.1;
}

void tbaby_jump5(entity this);

void tbaby_fly1(entity this);
void tbaby_fly4(entity this)
{
	set_animofs(this, anim_tbaby_fly, 4, tbaby_fly1);
	if(IS_ONGROUND(this))
	{
		settouch(this, func_null);
		setthink(this, tbaby_run1);
		return;
	}
	this.cnt += 1;
	if(this.cnt >= 4)
		tbaby_jump5(this);
}
void tbaby_fly3(entity this) { set_animofs(this, anim_tbaby_fly, 3, tbaby_fly4); }
void tbaby_fly2(entity this) { set_animofs(this, anim_tbaby_fly, 2, tbaby_fly3); }
void tbaby_fly1(entity this) { set_animofs(this, anim_tbaby_fly, 1, tbaby_fly2); }

void tbaby_jump6(entity this) { set_animofs(this, anim_tbaby_jump, 6, tbaby_fly1); }
void tbaby_jump5(entity this)
{
	set_animofs(this, anim_tbaby_jump, 5, tbaby_jump6);

	set_movetype(this, MOVETYPE_BOUNCE);
	settouch(this, Tar_JumpTouch);
	fixedmakevectors(this.angles);
	this.origin_z = this.origin_z + 1;
	this.velocity = v_forward * 600 + '0 0 200';
	this.velocity_z = this.velocity_z + random()*150;
	UNSET_ONGROUND(this);
	this.cnt = 0;
}
void tbaby_jump4(entity this) { set_animofs(this, anim_tbaby_jump, 4, tbaby_jump5); ai_face(this); }
void tbaby_jump3(entity this) { set_animofs(this, anim_tbaby_jump, 3, tbaby_jump4); ai_face(this); }
void tbaby_jump2(entity this) { set_animofs(this, anim_tbaby_jump, 2, tbaby_jump3); ai_face(this); }
void tbaby_jump1(entity this) { set_animofs(this, anim_tbaby_jump, 1, tbaby_jump2); ai_face(this); }



//=============================================================================

void tbaby_die2(entity this)
{
	set_anim(this, anim_tbaby_exp, tbaby_run1);
	T_RadiusDamage(this, this, 120, DEATH_MONSTER_SPAWN.m_id, NULL);

	_sound(this, CH_VOICE, "blob/death1.wav", 1, ATTN_NORM);
	this.origin = this.origin - 8 * normalize(this.velocity);

	te_tarexplosion(this.origin);
	
	BecomeExplosion(this);
}
void tbaby_die1(entity this, entity inflictor, entity attacker, int deathtype) { set_anim(this, anim_tbaby_exp, tbaby_die2); this.takedamage = DAMAGE_NO; }

void tbaby_mitosis(entity targ, entity attacker, float damage, int deathtype);
void tbaby_checknew(entity this)
{
	if(!t_walkmove(this, 0, 0))
	{
		delete(this);
		return;
	}
	
	this.enemy = this.enemy;
	this.th_stand = tbaby_stand1;
	this.th_walk = tbaby_walk1;
	this.th_run = tbaby_run1;
	this.th_missile = tbaby_jump1;
	this.th_melee = tbaby_jump1;
	this.th_die = tbaby_die1;       
	this.origin_z = this.origin_z + 1;      // raise off floor a bit
	droptofloor(this);

	if(!t_walkmove(this, 0,0))
	{
		this.owner.th_pain = tbaby_mitosis;
		delete(this);
		return;
	}

	this.takedamage = DAMAGE_AIM;
	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.yaw_speed)
		this.yaw_speed = 20;
	this.view_ofs = '0 0 25';
	this.use = monster_use;
	this.flags |= FL_MONSTER;
	this.pausetime = -1;
	this.th_stand(this);
	this.nextthink = this.nextthink + random()*0.5;

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;

	monsters_total += 1;
}

void tbaby_mitosis(entity targ, entity attacker, float damage, int deathtype)
{
    if(random() < 0.35)
	{
		entity newSpawn = spawn();
		newSpawn.classname = targ.classname;
		set_movetype(newSpawn, MOVETYPE_STEP);
		setsize (newSpawn, '-16 -16 -24', '16 16 40');
		newSpawn.health = 80;
		if(targ.skin == 1)
			newSpawn.health = 60;
		else if(targ.skin == 2)
			newSpawn.health = 100;

		newSpawn.owner = targ;
		targ.th_pain = func_null;
		
		_setmodel(newSpawn, "progs/tarbaby.mdl");
		newSpawn.solid = SOLID_SLIDEBOX;
		newSpawn.skin = targ.skin;
		
		setorigin(newSpawn, targ.origin);
		setthink(newSpawn, tbaby_checknew);
		newSpawn.nextthink = time + 0.5;

        _sound(newSpawn, CH_VOICE, "blob/mytosis.wav", 1, ATTN_NORM);
	}
}

/*QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush Blue Green Spots
The Spawn (and hellspawn)

The spawn type is random by default.
If you want a specific type, select "Blue", "Green", or "Spots".
*/
spawnfunc(monster_tarbaby) { monster_start(this, MON_SPAWN); }
#endif // SVQC

#ifdef SVQC
METHOD(Spawn, mr_setup, bool(Spawn this, entity actor))
{
    TC(Spawn, this);

	precache_sound2("blob/death1.wav");
	precache_sound2("blob/hit1.wav");
	precache_sound2("blob/land1.wav");

    actor.health = 80;
    actor.th_stand = tbaby_stand1;
	actor.th_walk = tbaby_walk1;
	actor.th_run = tbaby_run1;
	actor.th_missile = tbaby_jump1;
	actor.th_melee = tbaby_jump1;
	actor.th_die = tbaby_die1;

	if(MP_ROGUE)
	{
		precache_sound2("blob/mytosis.wav");
		if(actor.spawnflags & 8)
		{
			actor.th_pain = tbaby_mitosis;
			actor.skin = 2;
			actor.health = 100;
		}
		else if(actor.spawnflags & 4)
		{
			actor.th_pain = tbaby_mitosis;
			actor.skin = 1;
			actor.health = 60;
		}
		else if(actor.spawnflags & 2)
			actor.skin = 0;
		else
		{
			float myskill = autocvar_skill;
			float r = myskill * 0.2;
			r += random();
			if(r > 0.8 && myskill > 1)
			{
				actor.th_pain = tbaby_mitosis;
				actor.skin = 2;
				actor.health = 100;
			}
			else if(r > 0.5)
			{
				actor.th_pain = tbaby_mitosis;
				actor.skin = 1;
				actor.health = 60;
			}
			else
				actor.skin = 0;
		}
	}

    return true;
}
#endif
