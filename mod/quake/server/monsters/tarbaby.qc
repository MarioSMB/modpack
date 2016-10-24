/*
==============================================================================

BLOB

==============================================================================
*/

$cd id1/models/tarbaby
$origin 0 0 24
$base base		

$skin skin

$frame walk1 walk2 walk3 walk4  walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19
$frame walk20 walk21 walk22 walk23 walk24 walk25

$frame run1 run2 run3 run4 run5 run6  run7 run8 run9 run10 run11 run12 run13
$frame run14 run15 run16 run17 run18 run19 run20 run21 run22 run23
$frame run24 run25

$frame jump1 jump2 jump3 jump4 jump5 jump6

$frame fly1 fly2 fly3 fly4

$frame exp

void(entity this)	tbaby_stand1	=[	$walk1,		tbaby_stand1	] {ai_stand(this);}

void()	tbaby_hang1		=[	$walk1,		tbaby_hang1	] {ai_stand(this);}

void()	tbaby_walk1	=[	$walk1,		tbaby_walk2	] {ai_turn();}
void()	tbaby_walk2	=[	$walk2,		tbaby_walk3	] {ai_turn();}
void()	tbaby_walk3	=[	$walk3,		tbaby_walk4	] {ai_turn();}
void()	tbaby_walk4	=[	$walk4,		tbaby_walk5	] {ai_turn();}
void()	tbaby_walk5	=[	$walk5,		tbaby_walk6	] {ai_turn();}
void()	tbaby_walk6	=[	$walk6,		tbaby_walk7	] {ai_turn();}
void()	tbaby_walk7	=[	$walk7,		tbaby_walk8	] {ai_turn();}
void()	tbaby_walk8	=[	$walk8,		tbaby_walk9	] {ai_turn();}
void()	tbaby_walk9	=[	$walk9,		tbaby_walk10	] {ai_turn();}
void()	tbaby_walk10	=[	$walk10,		tbaby_walk11	] {ai_turn();}
void()	tbaby_walk11	=[	$walk11,		tbaby_walk12	] {ai_walk(2);}
void()	tbaby_walk12	=[	$walk12,		tbaby_walk13	] {ai_walk(2);}
void()	tbaby_walk13	=[	$walk13,		tbaby_walk14	] {ai_walk(2);}
void()	tbaby_walk14	=[	$walk14,		tbaby_walk15	] {ai_walk(2);}
void()	tbaby_walk15	=[	$walk15,		tbaby_walk16	] {ai_walk(2);}
void()	tbaby_walk16	=[	$walk16,		tbaby_walk17	] {ai_walk(2);}
void()	tbaby_walk17	=[	$walk17,		tbaby_walk18	] {ai_walk(2);}
void()	tbaby_walk18	=[	$walk18,		tbaby_walk19	] {ai_walk(2);}
void()	tbaby_walk19	=[	$walk19,		tbaby_walk20	] {ai_walk(2);}
void()	tbaby_walk20	=[	$walk20,		tbaby_walk21	] {ai_walk(2);}
void()	tbaby_walk21	=[	$walk21,		tbaby_walk22	] {ai_walk(2);}
void()	tbaby_walk22	=[	$walk22,		tbaby_walk23	] {ai_walk(2);}
void()	tbaby_walk23	=[	$walk23,		tbaby_walk24	] {ai_walk(2);}
void()	tbaby_walk24	=[	$walk24,		tbaby_walk25	] {ai_walk(2);}
void()	tbaby_walk25	=[	$walk25,		tbaby_walk1	] {ai_walk(2);}

void()	tbaby_run1	=[	$run1,		tbaby_run2	] {ai_face(this);}
void()	tbaby_run2	=[	$run2,		tbaby_run3	] {ai_face(this);}
void()	tbaby_run3	=[	$run3,		tbaby_run4	] {ai_face(this);}
void()	tbaby_run4	=[	$run4,		tbaby_run5	] {ai_face(this);}
void()	tbaby_run5	=[	$run5,		tbaby_run6	] {ai_face(this);}
void()	tbaby_run6	=[	$run6,		tbaby_run7	] {ai_face(this);}
void()	tbaby_run7	=[	$run7,		tbaby_run8	] {ai_face(this);}
void()	tbaby_run8	=[	$run8,		tbaby_run9	] {ai_face(this);}
void()	tbaby_run9	=[	$run9,		tbaby_run10	] {ai_face(this);}
void()	tbaby_run10	=[	$run10,		tbaby_run11	] {ai_face(this);}
void()	tbaby_run11	=[	$run11,		tbaby_run12	] {ai_run(2);}
void()	tbaby_run12	=[	$run12,		tbaby_run13	] {ai_run(2);}
void()	tbaby_run13	=[	$run13,		tbaby_run14	] {ai_run(2);}
void()	tbaby_run14	=[	$run14,		tbaby_run15	] {ai_run(2);}
void()	tbaby_run15	=[	$run15,		tbaby_run16	] {ai_run(2);}
void()	tbaby_run16	=[	$run16,		tbaby_run17	] {ai_run(2);}
void()	tbaby_run17	=[	$run17,		tbaby_run18	] {ai_run(2);}
void()	tbaby_run18	=[	$run18,		tbaby_run19	] {ai_run(2);}
void()	tbaby_run19	=[	$run19,		tbaby_run20	] {ai_run(2);}
void()	tbaby_run20	=[	$run20,		tbaby_run21	] {ai_run(2);}
void()	tbaby_run21	=[	$run21,		tbaby_run22	] {ai_run(2);}
void()	tbaby_run22	=[	$run22,		tbaby_run23	] {ai_run(2);}
void()	tbaby_run23	=[	$run23,		tbaby_run24	] {ai_run(2);}
void()	tbaby_run24	=[	$run24,		tbaby_run25	] {ai_run(2);}
void()	tbaby_run25	=[	$run25,		tbaby_run1	] {ai_run(2);}


//============================================================================


void()	tbaby_jump1;

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


	if(!checkbottom(this))
	{
		if(this.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, tbaby_run1);
			this.movetype = MOVETYPE_STEP;
			this.nextthink = time + 0.1;

		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	setthink(this, tbaby_jump1);
	this.nextthink = time + 0.1;
}

void()	tbaby_jump5;

void()	tbaby_fly1		=[	$fly1,	tbaby_fly2	] {}
void()	tbaby_fly2		=[	$fly2,	tbaby_fly3	] {}
void()	tbaby_fly3		=[	$fly3,	tbaby_fly4	] {}
void()	tbaby_fly4		=[	$fly4,	tbaby_fly1	] {
this.cnt = this.cnt + 1;
if(this.cnt == 4)
{
//dprint("spawn hop\n");
tbaby_jump5();
}
}

void()	tbaby_jump1		=[	$jump1,	tbaby_jump2		] {ai_face(this);}
void()	tbaby_jump2		=[	$jump2,	tbaby_jump3		] {ai_face(this);}
void()	tbaby_jump3		=[	$jump3,	tbaby_jump4		] {ai_face(this);}
void()	tbaby_jump4		=[	$jump4,	tbaby_jump5		] {ai_face(this);}
void()	tbaby_jump5		=[	$jump5,	tbaby_jump6		]
{	
	this.movetype = MOVETYPE_BOUNCE;
	settouch(this, Tar_JumpTouch);
	makevectors(this.angles);
	this.origin_z = this.origin_z + 1;
	this.velocity = v_forward * 600 + '0 0 200';
	this.velocity_z = this.velocity_z + random()*150;
	if(this.flags & FL_ONGROUND)
		this.flags &= ~FL_ONGROUND;
	this.cnt = 0;
}
void()	tbaby_jump6	=[	$jump6,tbaby_fly1	] {}



//=============================================================================

void(entity this, entity attacker)	tbaby_die1	=[	$exp,		tbaby_die2	] {
this.takedamage = DAMAGE_NO;
}
void()	tbaby_die2	=[	$exp,		tbaby_run1	] 
{
	T_RadiusDamage(this, this, 120, NULL);

	_sound(this, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);
	this.origin = this.origin - 8*normalize(this.velocity);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);
	
	BecomeExplosion(this);
}

string tbaby_sight() { return "blob/sight1.wav"; }
string tbaby_deathmessage() { return "was slimed by a Spawn"; }

//=============================================================================


/*QUAKED monster_tarbaby(1 0 0)(-16 -16 -24)(16 16 24) Ambush
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
	
	this.solid = SOLID_SLIDEBOX;
	this.movetype = MOVETYPE_STEP;

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
	
	walkmonster_start();
}

