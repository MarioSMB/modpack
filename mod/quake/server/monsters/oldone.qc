/*
==============================================================================

OLD ONE

==============================================================================
*/
$cd id1/models/old_one
$origin 0 0 24
$base base
$skin skin
$scale 1

void finale_1(entity this, entity attacker);
void finale_2(entity this);
void finale_3(entity this);
void finale_4(entity this);


$frame old1 old2 old3 old4 old5 old6 old7 old8 old9 
$frame old10 old11 old12 old13 old14 old15 old16 old17 old18 old19 
$frame old20 old21 old22 old23 old24 old25 old26 old27 old28 old29 
$frame old30 old31 old32 old33 old34 old35 old36 old37 old38 old39 
$frame old40 old41 old42 old43 old44 old45 old46 

$frame shake1 shake2 shake3 shake4 shake5 shake6 shake7 shake8
$frame shake9 shake10 shake11 shake12 shake12 shake13 shake14
$frame shake15 shake16 shake17 shake18 shake19 shake20

//void() old_stand     =[      $old1,       old_stand    ] {}

void() old_idle1        =[      $old1,  old_idle2       ] {}
void() old_idle2        =[      $old2,  old_idle3       ] {}
void() old_idle3        =[      $old3,  old_idle4       ] {}
void() old_idle4        =[      $old4,  old_idle5       ] {}
void() old_idle5        =[      $old5,  old_idle6       ] {}
void() old_idle6        =[      $old6,  old_idle7       ] {}
void() old_idle7        =[      $old7,  old_idle8       ] {}
void() old_idle8        =[      $old8,  old_idle9       ] {}
void() old_idle9        =[      $old9,  old_idle10      ] {}
void() old_idle10       =[      $old10, old_idle11      ] {}
void() old_idle11       =[      $old11, old_idle12      ] {}
void() old_idle12       =[      $old12, old_idle13      ] {}
void() old_idle13       =[      $old13, old_idle14      ] {}
void() old_idle14       =[      $old14, old_idle15      ] {}
void() old_idle15       =[      $old15, old_idle16      ] {}
void() old_idle16       =[      $old16, old_idle17      ] {}
void() old_idle17       =[      $old17, old_idle18      ] {}
void() old_idle18       =[      $old18, old_idle19      ] {}
void() old_idle19       =[      $old19, old_idle20      ] {}
void() old_idle20       =[      $old20, old_idle21      ] {}
void() old_idle21       =[      $old21, old_idle22      ] {}
void() old_idle22       =[      $old22, old_idle23      ] {}
void() old_idle23       =[      $old23, old_idle24      ] {}
void() old_idle24       =[      $old24, old_idle25      ] {}
void() old_idle25       =[      $old25, old_idle26      ] {}
void() old_idle26       =[      $old26, old_idle27      ] {}
void() old_idle27       =[      $old27, old_idle28      ] {}
void() old_idle28       =[      $old28, old_idle29      ] {}
void() old_idle29       =[      $old29, old_idle30      ] {}
void() old_idle30       =[      $old30, old_idle31      ] {}
void() old_idle31       =[      $old31, old_idle32      ] {}
void() old_idle32       =[      $old32, old_idle33      ] {}
void() old_idle33       =[      $old33, old_idle34      ] {}
void() old_idle34       =[      $old34, old_idle35      ] {}
void() old_idle35       =[      $old35, old_idle36      ] {}
void() old_idle36       =[      $old36, old_idle37      ] {}
void() old_idle37       =[      $old37, old_idle38      ] {}
void() old_idle38       =[      $old38, old_idle39      ] {}
void() old_idle39       =[      $old39, old_idle40      ] {}
void() old_idle40       =[      $old40, old_idle41      ] {}
void() old_idle41       =[      $old41, old_idle42      ] {}
void() old_idle42       =[      $old42, old_idle43      ] {}
void() old_idle43       =[      $old43, old_idle44      ] {}
void() old_idle44       =[      $old44, old_idle45      ] {}
void() old_idle45       =[      $old45, old_idle46      ] {}
void() old_idle46       =[      $old46, old_idle1       ] {}


void() old_thrash1        =[ $shake1,  old_thrash2       ] {lightstyle(0, "m");}
void() old_thrash2        =[      $shake2,  old_thrash3       ] {lightstyle(0, "k");}
void() old_thrash3        =[      $shake3,  old_thrash4       ] {lightstyle(0, "k");}
void() old_thrash4        =[      $shake4,  old_thrash5       ] {lightstyle(0, "i");}
void() old_thrash5        =[      $shake5,  old_thrash6       ] {lightstyle(0, "g");}
void() old_thrash6        =[      $shake6,  old_thrash7       ] {lightstyle(0, "e");}
void() old_thrash7        =[      $shake7,  old_thrash8       ] {lightstyle(0, "c");}
void() old_thrash8        =[      $shake8,  old_thrash9       ] {lightstyle(0, "a");}
void() old_thrash9        =[      $shake9,  old_thrash10      ] {lightstyle(0, "c");}
void() old_thrash10       =[      $shake10, old_thrash11      ] {lightstyle(0, "e");}
void() old_thrash11       =[      $shake11, old_thrash12      ] {lightstyle(0, "g");}
void() old_thrash12       =[      $shake12, old_thrash13      ] {lightstyle(0, "i");}
void() old_thrash13       =[      $shake13, old_thrash14      ] {lightstyle(0, "k");}
void() old_thrash14       =[      $shake14, old_thrash15      ] {lightstyle(0, "m");}
void old_thrash15       =[      $shake15, old_thrash16      ] {lightstyle(0, "m")();
this.cnt = this.cnt + 1;
if(this.cnt != 3)
	setthink(this, old_thrash1);
}
void() old_thrash16       =[      $shake16, old_thrash17      ] {lightstyle(0, "g");}
void() old_thrash17       =[      $shake17, old_thrash18      ] {lightstyle(0, "c");}
void() old_thrash18       =[      $shake18, old_thrash19      ] {lightstyle(0, "b");}
void() old_thrash19       =[      $shake19, old_thrash20      ] {lightstyle(0, "a");}
void() old_thrash20       =[      $shake20, old_thrash20      ] {finale_4();}

//============================================================================

void finale_1(entity this, entity attacker)
{
	intermission_exittime = time + 10000000;	// never allow exit
	intermission_running = 1;

	// find the intermission spot
	entity pos = find(NULL, classname, "info_intermission");
	if(!pos)
		error("no info_intermission");
	entity pl = find(NULL, classname, "misc_teleporttrain");
	if(!pl)
		error("no teleporttrain");
	delete(pl);

	WriteByte(MSG_ALL, SVC_FINALE);
	WriteString(MSG_ALL, "");

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.view_ofs = '0 0 0';
		it.angles = it.v_angle = pos.mangle;
		it.fixangle = true;		// turn this way immediately
		it.map = this.map;
		it.nextthink = time + 0.5;
		it.takedamage = DAMAGE_NO;
		it.solid = SOLID_NOT;
		it.movetype = MOVETYPE_NONE;
		it.modelindex = 0;
		setorigin(it, pos.origin);
	});
	
	// make fake versions of all players as standins, and move the real
	// players to the intermission spot
	
	// wait for 1 second
	entity timer = spawn();
	timer.owner = this;
	timer.nextthink = time + 1;
	setthink(timer, finale_2);
}

void finale_2(entity this)
{
	// start a teleport splash inside shub
	entity shub = this.owner;

	vector o = shub.origin - '0 100 0';
	setorigin(this, o);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TELEPORT);
	WriteCoord(MSG_BROADCAST, o_x);
	WriteCoord(MSG_BROADCAST, o_y);
	WriteCoord(MSG_BROADCAST, o_z);

	_sound(shub, CHAN_VOICE, "misc/r_tele1.wav", 1, ATTN_NORM);
	
	this.nextthink = time + 2;
	setthink(this, finale_3);
}

void finale_3(entity this)
{
	entity shub = this.owner;
	// start shub thrashing wildly
	setthink(shub, old_thrash1);
	_sound(shub, CHAN_VOICE, "boss2/death.wav", 1, ATTN_NORM);
	lightstyle(0, "abcdefghijklmlkjihgfedcb");	
}

void finale_4(entity this)
{
	entity shub = this.owner;

	// throw tons of meat chunks
	_sound(this, CHAN_VOICE, "boss2/pop2.wav", 1, ATTN_NORM);
	
	vector oldo = this.origin;

	float zz = 16;
	while(zz <= 144)
	{
		float xx = -64;
		while(xx <= 64)
		{
			float yy = -64;
			while(yy <= 64)
			{
				this.origin_x = oldo_x + xx;
				this.origin_y = oldo_y + yy;
				this.origin_z = oldo_z + zz;

				float r = random();
				if(r < 0.3)				
					ThrowGib(this, "progs/gib1.mdl", -999);
				else if(r < 0.6)
					ThrowGib(this, "progs/gib2.mdl", -999);
				else
					ThrowGib(this, "progs/gib3.mdl", -999);
				yy = yy + 32;
			}
			xx = xx + 32;
		}
		zz = zz + 96;
	}
	// start the end text
	WriteByte(MSG_ALL, SVC_FINALE);
	WriteString(MSG_ALL, "Congratulations and well done! You have\nbeaten the hideous Shub-Niggurath, and\nher hundreds of ugly changelings and\nmonsters. You have proven that your\nskill and your cunning are greater than\nall the powers of Quake. You are the\nmaster now. Id Software salutes you.");

// put a player model down
	entity n = spawn();
	_setmodel(n, "progs/player.mdl");
	oldo = oldo - '32 264 0';
	setorigin(n, oldo);
	n.angles = '0 290 0';
	n.frame = 1;

	delete(this);

// switch cd track
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, 3);
	WriteByte(MSG_ALL, 3);
	lightstyle(0, "m");	
}

//============================================================================

void nopain(entity this, entity attacker, float damage)
{
	this.health = 40000;
}

//============================================================================

string oldone_deathmessage() { return "became one with Shub-Niggurath"; }


/*QUAKED monster_oldone(1 0 0)(-16 -16 -24)(16 16 32)
*/
spawnfunc(monster_oldone)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}

	precache_model2("progs/oldone.mdl");

	precache_sound2("boss2/death.wav");
	precache_sound2("boss2/idle.wav");
	precache_sound2("boss2/sight.wav");
	precache_sound2("boss2/pop2.wav");

	this.solid = SOLID_SLIDEBOX;
	this.movetype = MOVETYPE_STEP;
	
	_setmodel(this, "progs/oldone.mdl");
	setsize(this, '-160 -128 -24', '160 128 256');

	this.health = 40000;		// kill by telefrag
	setthink(this, old_idle1);
	this.nextthink = time + 0.1;	
	this.takedamage = DAMAGE_YES;
	this.th_pain = nopain;
	this.th_die = finale_1;

	this.deathmessage = oldone_deathmessage;
	
	total_monsters = total_monsters + 1;
}

