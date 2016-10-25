/*
==============================================================================

PLAYER

==============================================================================
*/

$cd id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


/*
==============================================================================
PLAYER
==============================================================================
*/

void player_run(entity this);

void player_stand1(entity this)
{
	set_anim(this, $axstnd1, player_stand1);

	this.weaponframe=0;
	if(this.velocity_x || this.velocity_y)
	{
		this.walkframe=0;
		player_run(this);
		return;
	}

	if(this.weapon == IT_AXE)
	{
		if(this.walkframe >= 12)
			this.walkframe = 0;
		this.frame = $axstnd1 + this.walkframe;
	}
	else
	{
		if(this.walkframe >= 5)
			this.walkframe = 0;
		this.frame = $stand1 + this.walkframe;
	}
	this.walkframe = this.walkframe + 1;	
}

void player_run(entity this);
{
	set_anim(this, $rockrun1, player_run);

	this.weaponframe=0;
	if(!this.velocity_x && !this.velocity_y)
	{
		this.walkframe=0;
		player_stand1(this);
		return;
	}

	if(this.weapon == IT_AXE)
	{
		if(this.walkframe == 6)
			this.walkframe = 0;
		this.frame = $axrun1 + this.walkframe;
	}
	else
	{
		if(this.walkframe == 6)
			this.walkframe = 0;
		this.frame = this.frame + this.walkframe;
	}
	this.walkframe = this.walkframe + 1;
}

void player_shot1(entity this) { set_anim(this, $shotatt1, player_shot2); this.weaponframe = 1; this.effects |= EF_MUZZLEFLASH; }
void player_shot2(entity this) { set_anim(this, $shotatt2, player_shot3); this.weaponframe = 2; }
void player_shot3(entity this) { set_anim(this, $shotatt3, player_shot4); this.weaponframe = 3; }
void player_shot4(entity this) { set_anim(this, $shotatt4, player_shot5); this.weaponframe = 4; }
void player_shot5(entity this) { set_anim(this, $shotatt5, player_shot6); this.weaponframe = 5; }
void player_shot6(entity this) { set_anim(this, $shotatt6, player_run); this.weaponframe = 6; }

void player_axe1(entity this) { set_anim(this, $axatt1, player_axe2); this.weaponframe = 1; }
void player_axe2(entity this) { set_anim(this, $axatt2, player_axe3); this.weaponframe = 2; }
void player_axe3(entity this) { set_anim(this, $axatt3, player_axe4); this.weaponframe = 3; W_FireAxe(this); }
void player_axe4(entity this) { set_anim(this, $axatt4, player_run); this.weaponframe = 4; }

void player_axeb1(entity this) { set_anim(this, $axattb1, player_axeb2); this.weaponframe = 5; }
void player_axeb2(entity this) { set_anim(this, $axattb2, player_axeb3); this.weaponframe = 6; }
void player_axeb3(entity this) { set_anim(this, $axattb3, player_axeb4); this.weaponframe = 7; W_FireAxe(this); }
void player_axeb4(entity this) { set_anim(this, $axattb4, player_run); this.weaponframe = 8; }

void player_axec1(entity this) { set_anim(this, $axattc1, player_axec2); this.weaponframe = 1; }
void player_axec2(entity this) { set_anim(this, $axattc2, player_axec3); this.weaponframe = 2; }
void player_axec3(entity this) { set_anim(this, $axattc3, player_axec4); this.weaponframe = 3; W_FireAxe(this); }
void player_axec4(entity this) { set_anim(this, $axattc4, player_run); this.weaponframe = 4; }

void player_axed1(entity this) { set_anim(this, $axattd1, player_axed2); this.weaponframe = 5; }
void player_axed2(entity this) { set_anim(this, $axattd2, player_axed3); this.weaponframe = 6; }
void player_axed3(entity this) { set_anim(this, $axattd3, player_axed4); this.weaponframe = 7; W_FireAxe(this); }
void player_axed4(entity this) { set_anim(this, $axattd4, player_run); this.weaponframe = 8; }


//============================================================================

void player_nail1(entity this)
{
	set_anim(this, $nailatt1, player_nail2);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 9)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireSpikes(this, 4);
	this.attack_finished = time + 0.2;
}
void player_nail2(entity this)
{
	set_anim(this, $nailatt2, player_nail1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 9)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireSpikes(this, -4);
	this.attack_finished = time + 0.2;
}

//============================================================================

void player_light1(entity this)
{
	set_anim(this, $light1, player_light2);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 5)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireLightning(this);
	this.attack_finished = time + 0.2;
}
void player_light2(entity this)
{
	set_anim(this, $light2, player_light1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 5)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireLightning(this);
	this.attack_finished = time + 0.2;
}

//============================================================================


void player_rocket1(entity this) { set_anim(this, $rockatt1, player_rocket2); this.weaponframe = 1; this.effects |= EF_MUZZLEFLASH; }
void player_rocket2(entity this) { set_anim(this, $rockatt2, player_rocket3); this.weaponframe = 2; }
void player_rocket3(entity this) { set_anim(this, $rockatt3, player_rocket4); this.weaponframe = 3; }
void player_rocket4(entity this) { set_anim(this, $rockatt4, player_rocket5); this.weaponframe = 4; }
void player_rocket5(entity this) { set_anim(this, $rockatt5, player_rocket6); this.weaponframe = 5; }
void player_rocket6(entity this) { set_anim(this, $rockatt6, player_run); this.weaponframe = 6; }

void DeathBubbles(entity this, int num_bubbles);

void PainSound(entity this, entity attacker)
{
	if(this.health < 0)
		return;

	if(attacker.classname == "teledeath")
	{
		_sound(this, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

// water pain sounds
	if(this.watertype == CONTENT_WATER && this.waterlevel == 3)
	{
		DeathBubbles(this, 1);
		if(random() > 0.5)
			_sound(this, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		return;
	}

// slime pain sounds
	if(this.watertype == CONTENT_SLIME)
	{
// FIX ME	put in some steam here
		if(random() > 0.5)
			_sound(this, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	if(this.watertype == CONTENT_LAVA)
	{
		if(random() > 0.5)
			_sound(this, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	if(this.pain_finished > time)
	{
		this.axhitme = 0;
		return;
	}
	this.pain_finished = time + 0.5;

// don't make multiple pain sounds right after each other

// ax pain sound
	if(this.axhitme == 1)
	{
		this.axhitme = 0;
		_sound(this, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);
		return;
	}
	

	int rs = rint((random() * 5) + 1);

	this.noise = "";
	switch(rs)
	{
		case 1: this.noise = "player/pain1.wav"; break;
		case 2: this.noise = "player/pain2.wav"; break;
		case 3: this.noise = "player/pain3.wav"; break;
		case 4: this.noise = "player/pain4.wav"; break;
		case 5: this.noise = "player/pain5.wav"; break;
		default: this.noise = "player/pain6.wav"; break;
	}

	_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);
}

void player_pain1(entity this, entity attacker) { set_anim(this, $pain1, player_pain2); PainSound(this, attacker); this.weaponframe = 0; }
void player_pain2(entity this) { set_anim(this, $pain2, player_pain3); }
void player_pain3(entity this) { set_anim(this, $pain3, player_pain4); }
void player_pain4(entity this) { set_anim(this, $pain4, player_pain5); }
void player_pain5(entity this) { set_anim(this, $pain5, player_pain6); }
void player_pain6(entity this) { set_anim(this, $pain6, player_run); }

void player_axpain1(entity this, entity attacker) { set_anim(this, $axpain1, player_axpain2); PainSound(this, attacker); this.weaponframe = 0; }
void player_axpain2(entity this) { set_anim(this, $axpain2, player_axpain3); }
void player_axpain3(entity this) { set_anim(this, $axpain3, player_axpain4); }
void player_axpain4(entity this) { set_anim(this, $axpain4, player_axpain5); }
void player_axpain5(entity this) { set_anim(this, $axpain5, player_axpain6); }
void player_axpain6(entity this) { set_anim(this, $axpain6, player_run); }

void player_pain(entity this, entity attacker, float damage)
{
	if(this.weaponframe)
		return;

	if(this.invisible_finished > time)
		return;		// eyes don't have pain frames

	if(this.weapon == IT_AXE)
		player_axpain1(this, attacker);
	else
		player_pain1(this, attacker);
}

void player_diea1(entity this);
void player_dieb1(entity this);
void player_diec1(entity this);
void player_died1(entity this);
void player_diee1(entity this);
void player_die_ax1(entity this);

void bubble_bob(entity this);

void DeathBubblesSpawn(entity this)
{
	if(this.owner.waterlevel != 3)
		return;
	entity bubble = new(bubble);
	_setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, this.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	setthink(bubble, bubble_bob);
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.nextthink = time + 0.1;
	setthink(this, DeathBubblesSpawn);
	this.air_finished = this.air_finished + 1;
	if(this.air_finished >= this.bubble_count)
		delete(this);
}

void DeathBubbles(entity this, int num_bubbles)
{
	entity bubble_spawner = spawn();
	setorigin(bubble_spawner, this.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	setthink(bubble_spawner, DeathBubblesSpawn);
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = this;
	bubble_spawner.bubble_count = num_bubbles;
	return;
}


void DeathSound(entity this)
{
	// water death sounds
	if(this.waterlevel == 3)
	{
		DeathBubbles(this, 20);
		_sound(this, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}
	
	int rs = rint((random() * 4) + 1);
	if(rs == 1)
		this.noise = "player/death1.wav";
	if(rs == 2)
		this.noise = "player/death2.wav";
	if(rs == 3)
		this.noise = "player/death3.wav";
	if(rs == 4)
		this.noise = "player/death4.wav";
	if(rs == 5)
		this.noise = "player/death5.wav";

	_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NONE);
	return;
}


void PlayerDead(entity this)
{
	this.nextthink = -1;
// allow respawn after a certain time
	this.deadflag = DEAD_DEAD;
}

vector VelocityForDamage(float dm)
{
	vector v;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 200 + 100 * random();

	if(dm > -50)
	{
//		dprint("level 1\n");
		v = v * 0.7;
	}
	else if(dm > -200)
	{
//		dprint("level 3\n");
		v = v * 2;
	}
	else
		v = v * 10;

	return v;
}

void ThrowGib(string gibname, float dm)
{
	entity new = spawn();
	new.origin = this.origin;
	_setmodel(new, gibname);
	setsize(new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage(dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	setthink(new, SUB_Remove);
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
}

void ThrowHead(string gibname, float dm)
{
	_setmodel(this, gibname);
	this.frame = 0;
	this.nextthink = -1;
	this.movetype = MOVETYPE_BOUNCE;
	this.takedamage = DAMAGE_NO;
	this.solid = SOLID_NOT;
	this.view_ofs = '0 0 8';
	setsize(this, '-16 -16 0', '16 16 56');
	this.velocity = VelocityForDamage(dm);
	this.origin_z = this.origin_z - 24;
	this.flags &= ~FL_ONGROUND;
	this.avelocity = crandom() * '0 600 0';
}


void GibPlayer(entity this, entity attacker)
{
	ThrowHead("progs/h_player.mdl", this.health);
	ThrowGib("progs/gib1.mdl", this.health);
	ThrowGib("progs/gib2.mdl", this.health);
	ThrowGib("progs/gib3.mdl", this.health);

	this.deadflag = DEAD_DEAD;

	if(attacker.classname == "teledeath")
	{
		_sound(this, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if(attacker.classname == "teledeath2")
	{
		_sound(this, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if(random() < 0.5)
		_sound(this, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		_sound(this, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
}

void PlayerDie(entity this, entity attacker)
{
	this.items &= ~IT_INVISIBILITY;
	this.invisible_finished = 0;	// don't die as eyes
	this.invincible_finished = 0;
	this.super_damage_finished = 0;
	this.radsuit_finished = 0;
	this.modelindex = modelindex_player;	// don't use eyes

	if(deathmatch || coop)
		DropBackpack(this);
	
	this.weaponmodel="";
	this.view_ofs = '0 0 -8';
	this.deadflag = DEAD_DYING;
	this.solid = SOLID_NOT;
	this.flags &= ~FL_ONGROUND;
	this.movetype = MOVETYPE_TOSS;
	if(this.velocity_z < 10)
		this.velocity_z = this.velocity_z + random()*300;

	if(this.health < -40)
	{
		GibPlayer(this, attacker);
		return;
	}

	DeathSound(this);
	
	this.angles_x = 0;
	this.angles_z = 0;
	
	if(this.weapon == IT_AXE)
	{
		player_die_ax1(this);
		return;
	}
	
	int i = autocvar_temp1;
	if(!i)
		i = 1 + floor(random()*6);

	switch(i)
	{
		case 1: player_diea1(this); break;
		case 2: player_dieb1(this); break;
		case 3: player_diec1(this); break;
		case 4: player_died1(this); break;
		default: player_diee1(this); break;
	}
}

void set_suicide_frame(entity this)
{	// used by kill command and diconnect command
	if(this.model != "progs/player.mdl")
		return;	// allready gibbed
	this.frame = $deatha11;
	this.solid = SOLID_NOT;
	this.movetype = MOVETYPE_TOSS;
	this.deadflag = DEAD_DEAD;
	this.nextthink = -1;
}

void player_diea1(entity this) { set_anim(this, $deatha1, player_diea2); }
void player_diea2(entity this) { set_anim(this, $deatha2, player_diea3); }
void player_diea3(entity this) { set_anim(this, $deatha3, player_diea4); }
void player_diea4(entity this) { set_anim(this, $deatha4, player_diea5); }
void player_diea5(entity this) { set_anim(this, $deatha5, player_diea6); }
void player_diea6(entity this) { set_anim(this, $deatha6, player_diea7); }
void player_diea7(entity this) { set_anim(this, $deatha7, player_diea8); }
void player_diea8(entity this) { set_anim(this, $deatha8, player_diea9); }
void player_diea9(entity this) { set_anim(this, $deatha9, player_diea10); }
void player_diea10(entity this) { set_anim(this, $deatha10, player_diea11); }
void player_diea11(entity this) { set_anim(this, $deatha11, player_diea11); PlayerDead(this); }

void player_dieb1(entity this) { set_anim(this, $deathb1, player_dieb2); }
void player_dieb2(entity this) { set_anim(this, $deathb2, player_dieb3); }
void player_dieb3(entity this) { set_anim(this, $deathb3, player_dieb4); }
void player_dieb4(entity this) { set_anim(this, $deathb4, player_dieb5); }
void player_dieb5(entity this) { set_anim(this, $deathb5, player_dieb6); }
void player_dieb6(entity this) { set_anim(this, $deathb6, player_dieb7); }
void player_dieb7(entity this) { set_anim(this, $deathb7, player_dieb8); }
void player_dieb8(entity this) { set_anim(this, $deathb8, player_dieb9); }
void player_dieb9(entity this) { set_anim(this, $deathb9, player_dieb9); PlayerDead(this); }

void player_diec1(entity this) { set_anim(this, $deathc1, player_diec2); }
void player_diec2(entity this) { set_anim(this, $deathc2, player_diec3); }
void player_diec3(entity this) { set_anim(this, $deathc3, player_diec4); }
void player_diec4(entity this) { set_anim(this, $deathc4, player_diec5); }
void player_diec5(entity this) { set_anim(this, $deathc5, player_diec6); }
void player_diec6(entity this) { set_anim(this, $deathc6, player_diec7); }
void player_diec7(entity this) { set_anim(this, $deathc7, player_diec8); }
void player_diec8(entity this) { set_anim(this, $deathc8, player_diec9); }
void player_diec9(entity this) { set_anim(this, $deathc9, player_diec10); }
void player_diec10(entity this) { set_anim(this, $deathc10, player_diec11); }
void player_diec11(entity this) { set_anim(this, $deathc11, player_diec12); }
void player_diec12(entity this) { set_anim(this, $deathc12, player_diec13); }
void player_diec13(entity this) { set_anim(this, $deathc13, player_diec14); }
void player_diec14(entity this) { set_anim(this, $deathc14, player_diec15); }
void player_diec15(entity this) { set_anim(this, $deathc15, player_diec15); PlayerDead(this); }

void player_died1(entity this) { set_anim(this, $deathd1, player_died2); }
void player_died2(entity this) { set_anim(this, $deathd2, player_died3); }
void player_died3(entity this) { set_anim(this, $deathd3, player_died4); }
void player_died4(entity this) { set_anim(this, $deathd4, player_died5); }
void player_died5(entity this) { set_anim(this, $deathd5, player_died6); }
void player_died6(entity this) { set_anim(this, $deathd6, player_died7); }
void player_died7(entity this) { set_anim(this, $deathd7, player_died8); }
void player_died8(entity this) { set_anim(this, $deathd8, player_died9); }
void player_died9(entity this) { set_anim(this, $deathd9, player_died9); PlayerDead(this); }

void player_diee1(entity this) { set_anim(this, $deathe1, player_diee2); }
void player_diee2(entity this) { set_anim(this, $deathe2, player_diee3); }
void player_diee3(entity this) { set_anim(this, $deathe3, player_diee4); }
void player_diee4(entity this) { set_anim(this, $deathe4, player_diee5); }
void player_diee5(entity this) { set_anim(this, $deathe5, player_diee6); }
void player_diee6(entity this) { set_anim(this, $deathe6, player_diee7); }
void player_diee7(entity this) { set_anim(this, $deathe7, player_diee8); }
void player_diee8(entity this) { set_anim(this, $deathe8, player_diee9); }
void player_diee9(entity this) { set_anim(this, $deathe9, player_diee9); PlayerDead(this); }

void player_die_ax1(entity this) { set_anim(this, $axdeth1, player_die_ax2); }
void player_die_ax2(entity this) { set_anim(this, $axdeth2, player_die_ax3); }
void player_die_ax3(entity this) { set_anim(this, $axdeth3, player_die_ax4); }
void player_die_ax4(entity this) { set_anim(this, $axdeth4, player_die_ax5); }
void player_die_ax5(entity this) { set_anim(this, $axdeth5, player_die_ax6); }
void player_die_ax6(entity this) { set_anim(this, $axdeth6, player_die_ax7); }
void player_die_ax7(entity this) { set_anim(this, $axdeth7, player_die_ax8); }
void player_die_ax8(entity this) { set_anim(this, $axdeth8, player_die_ax9); }
void player_die_ax9(entity this) { set_anim(this, $axdeth9, player_die_ax9); PlayerDead(this); }
