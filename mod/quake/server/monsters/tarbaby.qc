/*
==============================================================================

BLOB

==============================================================================
*/

$cd id1/models/tarbaby
$origin 0 0 24
$base base		

// added by rogue
//$skin skin
$skin base
$skin skin2
// rogue (TODO)

$skin skin

const int anim_tbaby_walk1 = 0;
const int anim_tbaby_walk2 = 1;
const int anim_tbaby_walk3 = 2;
const int anim_tbaby_walk4 = 3;
const int anim_tbaby_walk5 = 4;
const int anim_tbaby_walk6 = 5;
const int anim_tbaby_walk7 = 6;
const int anim_tbaby_walk8 = 7;
const int anim_tbaby_walk9 = 8;
const int anim_tbaby_walk10 = 9;
const int anim_tbaby_walk11 = 10;
const int anim_tbaby_walk12 = 11;
const int anim_tbaby_walk13 = 12;
const int anim_tbaby_walk14 = 13;
const int anim_tbaby_walk15 = 14;
const int anim_tbaby_walk16 = 15;
const int anim_tbaby_walk17 = 16;
const int anim_tbaby_walk18 = 17;
const int anim_tbaby_walk19 = 18;
const int anim_tbaby_walk20 = 19;
const int anim_tbaby_walk21 = 20;
const int anim_tbaby_walk22 = 21;
const int anim_tbaby_walk23 = 22;
const int anim_tbaby_walk24 = 23;
const int anim_tbaby_walk25 = 24;

const int anim_tbaby_run1 = 25;
const int anim_tbaby_run2 = 26;
const int anim_tbaby_run3 = 27;
const int anim_tbaby_run4 = 28;
const int anim_tbaby_run5 = 29;
const int anim_tbaby_run6 = 30;
const int anim_tbaby_run7 = 31;
const int anim_tbaby_run8 = 32;
const int anim_tbaby_run9 = 33;
const int anim_tbaby_run10 = 34;
const int anim_tbaby_run11 = 35;
const int anim_tbaby_run12 = 36;
const int anim_tbaby_run13 = 37;
const int anim_tbaby_run14 = 38;
const int anim_tbaby_run15 = 39;
const int anim_tbaby_run16 = 40;
const int anim_tbaby_run17 = 41;
const int anim_tbaby_run18 = 42;
const int anim_tbaby_run19 = 43;
const int anim_tbaby_run20 = 44;
const int anim_tbaby_run21 = 45;
const int anim_tbaby_run22 = 46;
const int anim_tbaby_run23 = 47;
const int anim_tbaby_run24 = 48;
const int anim_tbaby_run25 = 49;

const int anim_tbaby_jump1 = 50;
const int anim_tbaby_jump2 = 51;
const int anim_tbaby_jump3 = 52;
const int anim_tbaby_jump4 = 53;
const int anim_tbaby_jump5 = 54;
const int anim_tbaby_jump6 = 55;

const int anim_tbaby_fly1 = 56;
const int anim_tbaby_fly2 = 57;
const int anim_tbaby_fly3 = 58;
const int anim_tbaby_fly4 = 59;

const int anim_tbaby_exp = 60;

void tbaby_stand1(entity this) { set_anim(this, anim_tbaby_walk1, tbaby_stand1); ai_stand(this); }

void tbaby_hang1(entity this) { set_anim(this, anim_tbaby_walk1, tbaby_hang1); ai_stand(this); }

void tbaby_walk1(entity this);
void tbaby_walk25(entity this) { set_anim(this, anim_tbaby_walk25, tbaby_walk1); ai_walk(this, 2); }
void tbaby_walk24(entity this) { set_anim(this, anim_tbaby_walk24, tbaby_walk25); ai_walk(this, 2); }
void tbaby_walk23(entity this) { set_anim(this, anim_tbaby_walk23, tbaby_walk24); ai_walk(this, 2); }
void tbaby_walk22(entity this) { set_anim(this, anim_tbaby_walk22, tbaby_walk23); ai_walk(this, 2); }
void tbaby_walk21(entity this) { set_anim(this, anim_tbaby_walk21, tbaby_walk22); ai_walk(this, 2); }
void tbaby_walk20(entity this) { set_anim(this, anim_tbaby_walk20, tbaby_walk21); ai_walk(this, 2); }
void tbaby_walk19(entity this) { set_anim(this, anim_tbaby_walk19, tbaby_walk20); ai_walk(this, 2); }
void tbaby_walk18(entity this) { set_anim(this, anim_tbaby_walk18, tbaby_walk19); ai_walk(this, 2); }
void tbaby_walk17(entity this) { set_anim(this, anim_tbaby_walk17, tbaby_walk18); ai_walk(this, 2); }
void tbaby_walk16(entity this) { set_anim(this, anim_tbaby_walk16, tbaby_walk17); ai_walk(this, 2); }
void tbaby_walk15(entity this) { set_anim(this, anim_tbaby_walk15, tbaby_walk16); ai_walk(this, 2); }
void tbaby_walk14(entity this) { set_anim(this, anim_tbaby_walk14, tbaby_walk15); ai_walk(this, 2); }
void tbaby_walk13(entity this) { set_anim(this, anim_tbaby_walk13, tbaby_walk14); ai_walk(this, 2); }
void tbaby_walk12(entity this) { set_anim(this, anim_tbaby_walk12, tbaby_walk13); ai_walk(this, 2); }
void tbaby_walk11(entity this) { set_anim(this, anim_tbaby_walk11, tbaby_walk12); ai_walk(this, 2); }
void tbaby_walk10(entity this) { set_anim(this, anim_tbaby_walk10, tbaby_walk11); ai_turn(this); }
void tbaby_walk9(entity this) { set_anim(this, anim_tbaby_walk9, tbaby_walk10); ai_turn(this); }
void tbaby_walk8(entity this) { set_anim(this, anim_tbaby_walk8, tbaby_walk9); ai_turn(this); }
void tbaby_walk7(entity this) { set_anim(this, anim_tbaby_walk7, tbaby_walk8); ai_turn(this); }
void tbaby_walk6(entity this) { set_anim(this, anim_tbaby_walk6, tbaby_walk7); ai_turn(this); }
void tbaby_walk5(entity this) { set_anim(this, anim_tbaby_walk5, tbaby_walk6); ai_turn(this); }
void tbaby_walk4(entity this) { set_anim(this, anim_tbaby_walk4, tbaby_walk5); ai_turn(this); }
void tbaby_walk3(entity this) { set_anim(this, anim_tbaby_walk3, tbaby_walk4); ai_turn(this); }
void tbaby_walk2(entity this) { set_anim(this, anim_tbaby_walk2, tbaby_walk3); ai_turn(this); }
void tbaby_walk1(entity this) { set_anim(this, anim_tbaby_walk1, tbaby_walk2); ai_turn(this); }

void tbaby_run1(entity this);
void tbaby_run25(entity this) { set_anim(this, anim_tbaby_run25, tbaby_run1); ai_run(this, 2); }
void tbaby_run24(entity this) { set_anim(this, anim_tbaby_run24, tbaby_run25); ai_run(this, 2); }
void tbaby_run23(entity this) { set_anim(this, anim_tbaby_run23, tbaby_run24); ai_run(this, 2); }
void tbaby_run22(entity this) { set_anim(this, anim_tbaby_run22, tbaby_run23); ai_run(this, 2); }
void tbaby_run21(entity this) { set_anim(this, anim_tbaby_run21, tbaby_run22); ai_run(this, 2); }
void tbaby_run20(entity this) { set_anim(this, anim_tbaby_run20, tbaby_run21); ai_run(this, 2); }
void tbaby_run19(entity this) { set_anim(this, anim_tbaby_run19, tbaby_run20); ai_run(this, 2); }
void tbaby_run18(entity this) { set_anim(this, anim_tbaby_run18, tbaby_run19); ai_run(this, 2); }
void tbaby_run17(entity this) { set_anim(this, anim_tbaby_run17, tbaby_run18); ai_run(this, 2); }
void tbaby_run16(entity this) { set_anim(this, anim_tbaby_run16, tbaby_run17); ai_run(this, 2); }
void tbaby_run15(entity this) { set_anim(this, anim_tbaby_run15, tbaby_run16); ai_run(this, 2); }
void tbaby_run14(entity this) { set_anim(this, anim_tbaby_run14, tbaby_run15); ai_run(this, 2); }
void tbaby_run13(entity this) { set_anim(this, anim_tbaby_run13, tbaby_run14); ai_run(this, 2); }
void tbaby_run12(entity this) { set_anim(this, anim_tbaby_run12, tbaby_run13); ai_run(this, 2); }
void tbaby_run11(entity this) { set_anim(this, anim_tbaby_run11, tbaby_run12); ai_run(this, 2); }
void tbaby_run10(entity this) { set_anim(this, anim_tbaby_run10, tbaby_run11); ai_face(this); }
void tbaby_run9(entity this) { set_anim(this, anim_tbaby_run9, tbaby_run10); ai_face(this); }
void tbaby_run8(entity this) { set_anim(this, anim_tbaby_run8, tbaby_run9); ai_face(this); }
void tbaby_run7(entity this) { set_anim(this, anim_tbaby_run7, tbaby_run8); ai_face(this); }
void tbaby_run6(entity this) { set_anim(this, anim_tbaby_run6, tbaby_run7); ai_face(this); }
void tbaby_run5(entity this) { set_anim(this, anim_tbaby_run5, tbaby_run6); ai_face(this); }
void tbaby_run4(entity this) { set_anim(this, anim_tbaby_run4, tbaby_run5); ai_face(this); }
void tbaby_run3(entity this) { set_anim(this, anim_tbaby_run3, tbaby_run4); ai_face(this); }
void tbaby_run2(entity this) { set_anim(this, anim_tbaby_run2, tbaby_run3); ai_face(this); }
void tbaby_run1(entity this) { set_anim(this, anim_tbaby_run1, tbaby_run2); ai_face(this); }


//============================================================================


void tbaby_jump1(entity this);

void Tar_JumpTouch(entity this, entity toucher)
{
	if(toucher.takedamage && toucher.classname != this.classname)
	{
		if( vdist(this.velocity, >, 400) )
		{
			float ldmg = 10 + 10*random();
			T_Damage(toucher, this, this, ldmg);	
			_sound(this, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);
		}
	}
	else
		_sound(this, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);


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
	set_anim(this, anim_tbaby_fly4, tbaby_fly1);
	this.cnt += 1;
	if(this.cnt >= 4)
		tbaby_jump5(this);
}
void tbaby_fly3(entity this) { set_anim(this, anim_tbaby_fly3, tbaby_fly4); }
void tbaby_fly2(entity this) { set_anim(this, anim_tbaby_fly2, tbaby_fly3); }
void tbaby_fly1(entity this) { set_anim(this, anim_tbaby_fly1, tbaby_fly2); }

void tbaby_jump6(entity this) { set_anim(this, anim_tbaby_jump6, tbaby_fly1); }
void tbaby_jump5(entity this)
{
	set_anim(this, anim_tbaby_jump5, tbaby_jump6);

	set_movetype(this, MOVETYPE_BOUNCE);
	settouch(this, Tar_JumpTouch);
	makevectors(this.angles);
	this.origin_z = this.origin_z + 1;
	this.velocity = v_forward * 600 + '0 0 200';
	this.velocity_z = this.velocity_z + random()*150;
	UNSET_ONGROUND(this);
	this.cnt = 0;
}
void tbaby_jump4(entity this) { set_anim(this, anim_tbaby_jump4, tbaby_jump5); ai_face(this); }
void tbaby_jump3(entity this) { set_anim(this, anim_tbaby_jump3, tbaby_jump4); ai_face(this); }
void tbaby_jump2(entity this) { set_anim(this, anim_tbaby_jump2, tbaby_jump3); ai_face(this); }
void tbaby_jump1(entity this) { set_anim(this, anim_tbaby_jump1, tbaby_jump2); ai_face(this); }



//=============================================================================

void tbaby_die2(entity this)
{
	set_anim(this, anim_tbaby_exp, tbaby_run1);
	T_RadiusDamage(this, this, 120, NULL);

	_sound(this, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);
	this.origin = this.origin - 8 * normalize(this.velocity);

	te_tarexplosion(this.origin);
	
	BecomeExplosion(this);
}
void tbaby_die1(entity this, entity attacker) { set_anim(this, anim_tbaby_exp, tbaby_die2); this.takedamage = DAMAGE_NO; }

void tbaby_mitosis(entity targ, entity attacker, float damage);
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
	WITHSELF(this, builtin_droptofloor());

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
	this.pausetime = 99999999;
	this.th_stand(this);
	this.nextthink = this.nextthink + random()*0.5;

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;

	monsters_total += 1;
}

void tbaby_mitosis(entity targ, entity attacker, float damage)
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

        _sound(newSpawn, CHAN_VOICE, "blob/mytosis.wav", 1, ATTN_NORM);
	}
}

string tbaby_sight(entity this) { return "blob/sight1.wav"; }
string tbaby_deathmessage(entity this) { return "was slimed by a Spawn"; }

//=============================================================================


/*QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush Blue Green Spots
The Spawn (and hellspawn)

The spawn type is random by default.
If you want a specific type, select "Blue", "Green", or "Spots".
*/
spawnfunc(monster_tarbaby)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model2("progs/tarbaby.mdl");

	precache_sound2("blob/death1.wav");
	precache_sound2("blob/hit1.wav");
	precache_sound2("blob/land1.wav");
	precache_sound2("blob/sight1.wav");
	precache_sound2("blob/mytosis.wav"); // don't bother checking for rogue
	
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/tarbaby.mdl");

	setsize(this, '-16 -16 -24', '16 16 40');
	this.health = 80;

	this.th_stand = tbaby_stand1;
	this.th_walk = tbaby_walk1;
	this.th_run = tbaby_run1;
	this.th_missile = tbaby_jump1;
	this.th_melee = tbaby_jump1;
	this.th_die = tbaby_die1;

	this.sightsound = tbaby_sight;
	this.deathmessage = tbaby_deathmessage;

	if(MP_ROGUE)
	{
		if(this.spawnflags & 8)
		{
			this.th_pain = tbaby_mitosis;
			this.skin = 2;
			this.health = 100;
		}
		else if(this.spawnflags & 4)
		{
			this.th_pain = tbaby_mitosis;
			this.skin = 1;
			this.health = 60;
		}
		else if(this.spawnflags & 2)
			this.skin = 0;
		else
		{
			float myskill = cvar("skill");
			float r = myskill * 0.2;
			r += random();
			if(r > 0.8 && myskill > 1)
			{
				this.th_pain = tbaby_mitosis;
				this.skin = 2;
				this.health = 100;
			}
			else if(r > 0.5)
			{
				this.th_pain = tbaby_mitosis;
				this.skin = 1;
				this.health = 60;
			}
			else
				this.skin = 0;
		}
	}

	monster_start(this, 0);
}
