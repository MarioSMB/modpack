/*
==============================================================================

BOSS-ONE

==============================================================================
*/
$cd id1/models/boss1
$origin 0 0 -15
$base base
$skin skin
$scale 5

const int anim_boss_rise1 = 0;
const int anim_boss_rise2 = 1;
const int anim_boss_rise3 = 2;
const int anim_boss_rise4 = 3;
const int anim_boss_rise5 = 4;
const int anim_boss_rise6 = 5;
const int anim_boss_rise7 = 6;
const int anim_boss_rise8 = 7;
const int anim_boss_rise9 = 8;
const int anim_boss_rise10 = 9;
const int anim_boss_rise11 = 10;
const int anim_boss_rise12 = 11;
const int anim_boss_rise13 = 12;
const int anim_boss_rise14 = 13;
const int anim_boss_rise15 = 14;
const int anim_boss_rise16 = 15;
const int anim_boss_rise17 = 16;

const int anim_boss_walk1 = 17;
const int anim_boss_walk2 = 18;
const int anim_boss_walk3 = 19;
const int anim_boss_walk4 = 20;
const int anim_boss_walk5 = 21;
const int anim_boss_walk6 = 22;
const int anim_boss_walk7 = 23;
const int anim_boss_walk8 = 24;
const int anim_boss_walk9 = 25;
const int anim_boss_walk10 = 26;
const int anim_boss_walk11 = 27;
const int anim_boss_walk12 = 28;
const int anim_boss_walk13 = 29;
const int anim_boss_walk14 = 30;
const int anim_boss_walk15 = 31;
const int anim_boss_walk16 = 32;
const int anim_boss_walk17 = 33;
const int anim_boss_walk18 = 34;
const int anim_boss_walk19 = 35;
const int anim_boss_walk20 = 36;
const int anim_boss_walk21 = 37;
const int anim_boss_walk22 = 38;
const int anim_boss_walk23 = 39;
const int anim_boss_walk24 = 40;
const int anim_boss_walk25 = 41;
const int anim_boss_walk26 = 42;
const int anim_boss_walk27 = 43;
const int anim_boss_walk28 = 44;
const int anim_boss_walk29 = 45;
const int anim_boss_walk30 = 46;
const int anim_boss_walk31 = 47;

const int anim_boss_death1 = 48;
const int anim_boss_death2 = 49;
const int anim_boss_death3 = 50;
const int anim_boss_death4 = 51;
const int anim_boss_death5 = 52;
const int anim_boss_death6 = 53;
const int anim_boss_death7 = 54;
const int anim_boss_death8 = 55;
const int anim_boss_death9 = 56;

const int anim_boss_attack1 = 57;
const int anim_boss_attack2 = 58;
const int anim_boss_attack3 = 59;
const int anim_boss_attack4 = 60;
const int anim_boss_attack5 = 61;
const int anim_boss_attack6 = 62;
const int anim_boss_attack7 = 63;
const int anim_boss_attack8 = 64;
const int anim_boss_attack9 = 65;
const int anim_boss_attack10 = 66;
const int anim_boss_attack11 = 67;
const int anim_boss_attack12 = 68;
const int anim_boss_attack13 = 69;
const int anim_boss_attack14 = 70;
const int anim_boss_attack15 = 71;

const int anim_boss_attack16 = 72;
const int anim_boss_attack17 = 73;
const int anim_boss_attack18 = 74;
const int anim_boss_attack19 = 75;
const int anim_boss_attack20 = 76;
const int anim_boss_attack21 = 77;
const int anim_boss_attack22 = 78;
const int anim_boss_attack23 = 79;

const int anim_boss_shocka1 = 80;
const int anim_boss_shocka2 = 81;
const int anim_boss_shocka3 = 82;
const int anim_boss_shocka4 = 83;
const int anim_boss_shocka5 = 84;
const int anim_boss_shocka6 = 85;
const int anim_boss_shocka7 = 86;
const int anim_boss_shocka8 = 87;
const int anim_boss_shocka9 = 88;
const int anim_boss_shocka10 = 89;

const int anim_boss_shockb1 = 90;
const int anim_boss_shockb2 = 91;
const int anim_boss_shockb3 = 92;
const int anim_boss_shockb4 = 93;
const int anim_boss_shockb5 = 94;
const int anim_boss_shockb6 = 95;

const int anim_boss_shockc1 = 96;
const int anim_boss_shockc2 = 97;
const int anim_boss_shockc3 = 98;
const int anim_boss_shockc4 = 99;
const int anim_boss_shockc5 = 100;
const int anim_boss_shockc6 = 101;
const int anim_boss_shockc7 = 102;
const int anim_boss_shockc8 = 103;
const int anim_boss_shockc9 = 104;
const int anim_boss_shockc10 = 105;

void boss_missile(entity this, vector p);

void boss_face(entity this)
{
// go for another player if multi player
	if(this.enemy.health <= 0 || random() < 0.02)
	{
		this.enemy = find(this.enemy, classname, STR_PLAYER);
		if(!this.enemy)
			this.enemy = find(this.enemy, classname, STR_PLAYER);
	}
	ai_face(this);
}

void boss_missile1(entity this);

void boss_rise17(entity this) { set_anim(this, anim_boss_rise17, boss_missile1); }
void boss_rise16(entity this) { set_anim(this, anim_boss_rise16, boss_rise17); }
void boss_rise15(entity this) { set_anim(this, anim_boss_rise15, boss_rise16); }
void boss_rise14(entity this) { set_anim(this, anim_boss_rise14, boss_rise15); }
void boss_rise13(entity this) { set_anim(this, anim_boss_rise13, boss_rise14); }
void boss_rise12(entity this) { set_anim(this, anim_boss_rise12, boss_rise13); }
void boss_rise11(entity this) { set_anim(this, anim_boss_rise11, boss_rise12); }
void boss_rise10(entity this) { set_anim(this, anim_boss_rise10, boss_rise11); }
void boss_rise9(entity this) { set_anim(this, anim_boss_rise9, boss_rise10); }
void boss_rise8(entity this) { set_anim(this, anim_boss_rise8, boss_rise9); }
void boss_rise7(entity this) { set_anim(this, anim_boss_rise7, boss_rise8); }
void boss_rise6(entity this) { set_anim(this, anim_boss_rise6, boss_rise7); }
void boss_rise5(entity this) { set_anim(this, anim_boss_rise5, boss_rise6); }
void boss_rise4(entity this) { set_anim(this, anim_boss_rise4, boss_rise5); }
void boss_rise3(entity this) { set_anim(this, anim_boss_rise3, boss_rise4); }
void boss_rise2(entity this)
{
	set_anim(this, anim_boss_rise2, boss_rise3);
	_sound(this, CH_VOICE, "boss1/sight1.wav", 1, ATTN_NORM);
}
void boss_rise1(entity this)
{
	set_anim(this, anim_boss_rise1, boss_rise2);
	_sound(this, CH_SHOTS, "boss1/out1.wav", 1, ATTN_NORM);
}

void boss_idle1(entity this);
void boss_idle31(entity this) { set_anim(this, anim_boss_walk31, boss_idle1); boss_face(this); }
void boss_idle30(entity this) { set_anim(this, anim_boss_walk30, boss_idle31); boss_face(this); }
void boss_idle29(entity this) { set_anim(this, anim_boss_walk29, boss_idle30); boss_face(this); }
void boss_idle28(entity this) { set_anim(this, anim_boss_walk28, boss_idle29); boss_face(this); }
void boss_idle27(entity this) { set_anim(this, anim_boss_walk27, boss_idle28); boss_face(this); }
void boss_idle26(entity this) { set_anim(this, anim_boss_walk26, boss_idle27); boss_face(this); }
void boss_idle25(entity this) { set_anim(this, anim_boss_walk25, boss_idle26); boss_face(this); }
void boss_idle24(entity this) { set_anim(this, anim_boss_walk24, boss_idle25); boss_face(this); }
void boss_idle23(entity this) { set_anim(this, anim_boss_walk23, boss_idle24); boss_face(this); }
void boss_idle22(entity this) { set_anim(this, anim_boss_walk22, boss_idle23); boss_face(this); }
void boss_idle21(entity this) { set_anim(this, anim_boss_walk21, boss_idle22); boss_face(this); }
void boss_idle20(entity this) { set_anim(this, anim_boss_walk20, boss_idle21); boss_face(this); }
void boss_idle19(entity this) { set_anim(this, anim_boss_walk19, boss_idle20); boss_face(this); }
void boss_idle18(entity this) { set_anim(this, anim_boss_walk18, boss_idle19); boss_face(this); }
void boss_idle17(entity this) { set_anim(this, anim_boss_walk17, boss_idle18); boss_face(this); }
void boss_idle16(entity this) { set_anim(this, anim_boss_walk16, boss_idle17); boss_face(this); }
void boss_idle15(entity this) { set_anim(this, anim_boss_walk15, boss_idle16); boss_face(this); }
void boss_idle14(entity this) { set_anim(this, anim_boss_walk14, boss_idle15); boss_face(this); }
void boss_idle13(entity this) { set_anim(this, anim_boss_walk13, boss_idle14); boss_face(this); }
void boss_idle12(entity this) { set_anim(this, anim_boss_walk12, boss_idle13); boss_face(this); }
void boss_idle11(entity this) { set_anim(this, anim_boss_walk11, boss_idle12); boss_face(this); }
void boss_idle10(entity this) { set_anim(this, anim_boss_walk10, boss_idle11); boss_face(this); }
void boss_idle9(entity this) { set_anim(this, anim_boss_walk9, boss_idle10); boss_face(this); }
void boss_idle8(entity this) { set_anim(this, anim_boss_walk8, boss_idle9); boss_face(this); }
void boss_idle7(entity this) { set_anim(this, anim_boss_walk7, boss_idle8); boss_face(this); }
void boss_idle6(entity this) { set_anim(this, anim_boss_walk6, boss_idle7); boss_face(this); }
void boss_idle5(entity this) { set_anim(this, anim_boss_walk5, boss_idle6); boss_face(this); }
void boss_idle4(entity this) { set_anim(this, anim_boss_walk4, boss_idle5); boss_face(this); }
void boss_idle3(entity this) { set_anim(this, anim_boss_walk3, boss_idle4); boss_face(this); }
void boss_idle2(entity this) { set_anim(this, anim_boss_walk2, boss_idle3); boss_face(this); }
void boss_idle1(entity this) { set_anim(this, anim_boss_walk1, boss_idle2); }

void boss_missile23(entity this) { set_anim(this, anim_boss_attack23, boss_missile1); boss_face(this); }
void boss_missile22(entity this) { set_anim(this, anim_boss_attack22, boss_missile23); boss_face(this); }
void boss_missile21(entity this) { set_anim(this, anim_boss_attack21, boss_missile22); boss_face(this); }
void boss_missile20(entity this) { set_anim(this, anim_boss_attack20, boss_missile21); boss_missile(this, '100 -100 200'); }
void boss_missile19(entity this) { set_anim(this, anim_boss_attack19, boss_missile20); boss_face(this); }
void boss_missile18(entity this) { set_anim(this, anim_boss_attack18, boss_missile19); boss_face(this); }
void boss_missile17(entity this) { set_anim(this, anim_boss_attack17, boss_missile18); boss_face(this); }
void boss_missile16(entity this) { set_anim(this, anim_boss_attack16, boss_missile17); boss_face(this); }
void boss_missile15(entity this) { set_anim(this, anim_boss_attack15, boss_missile16); boss_face(this); }
void boss_missile14(entity this) { set_anim(this, anim_boss_attack14, boss_missile15); boss_face(this); }
void boss_missile13(entity this) { set_anim(this, anim_boss_attack13, boss_missile14); boss_face(this); }
void boss_missile12(entity this) { set_anim(this, anim_boss_attack12, boss_missile13); boss_face(this); }
void boss_missile11(entity this) { set_anim(this, anim_boss_attack11, boss_missile12); boss_face(this); }
void boss_missile10(entity this) { set_anim(this, anim_boss_attack10, boss_missile11); boss_face(this); }
void boss_missile9(entity this) { set_anim(this, anim_boss_attack9, boss_missile10); boss_missile(this, '100 100 200'); }
void boss_missile8(entity this) { set_anim(this, anim_boss_attack8, boss_missile9); boss_face(this); }
void boss_missile7(entity this) { set_anim(this, anim_boss_attack7, boss_missile8); boss_face(this); }
void boss_missile6(entity this) { set_anim(this, anim_boss_attack6, boss_missile7); boss_face(this); }
void boss_missile5(entity this) { set_anim(this, anim_boss_attack5, boss_missile6); boss_face(this); }
void boss_missile4(entity this) { set_anim(this, anim_boss_attack4, boss_missile5); boss_face(this); }
void boss_missile3(entity this) { set_anim(this, anim_boss_attack3, boss_missile4); boss_face(this); }
void boss_missile2(entity this) { set_anim(this, anim_boss_attack2, boss_missile3); boss_face(this); }
void boss_missile1(entity this) { set_anim(this, anim_boss_attack1, boss_missile2); boss_face(this); }

void boss_shocka10(entity this) { set_anim(this, anim_boss_shocka10, boss_missile1); }
void boss_shocka9(entity this) { set_anim(this, anim_boss_shocka9, boss_shocka10); }
void boss_shocka8(entity this) { set_anim(this, anim_boss_shocka8, boss_shocka9); }
void boss_shocka7(entity this) { set_anim(this, anim_boss_shocka7, boss_shocka8); }
void boss_shocka6(entity this) { set_anim(this, anim_boss_shocka6, boss_shocka7); }
void boss_shocka5(entity this) { set_anim(this, anim_boss_shocka5, boss_shocka6); }
void boss_shocka4(entity this) { set_anim(this, anim_boss_shocka4, boss_shocka5); }
void boss_shocka3(entity this) { set_anim(this, anim_boss_shocka3, boss_shocka4); }
void boss_shocka2(entity this) { set_anim(this, anim_boss_shocka2, boss_shocka3); }
void boss_shocka1(entity this) { set_anim(this, anim_boss_shocka1, boss_shocka2); }

void boss_shockb10(entity this) { set_anim(this, anim_boss_shockb4, boss_missile1); }
void boss_shockb9(entity this) { set_anim(this, anim_boss_shockb3, boss_shockb10); }
void boss_shockb8(entity this) { set_anim(this, anim_boss_shockb2, boss_shockb9); }
void boss_shockb7(entity this) { set_anim(this, anim_boss_shockb1, boss_shockb8); }
void boss_shockb6(entity this) { set_anim(this, anim_boss_shockb6, boss_shockb7); }
void boss_shockb5(entity this) { set_anim(this, anim_boss_shockb5, boss_shockb6); }
void boss_shockb4(entity this) { set_anim(this, anim_boss_shockb4, boss_shockb5); }
void boss_shockb3(entity this) { set_anim(this, anim_boss_shockb3, boss_shockb4); }
void boss_shockb2(entity this) { set_anim(this, anim_boss_shockb2, boss_shockb3); }
void boss_shockb1(entity this) { set_anim(this, anim_boss_shockb1, boss_shockb2); }

void boss_death1(entity this);

void boss_shockc10(entity this) { set_anim(this, anim_boss_shockc10, boss_death1); }
void boss_shockc9(entity this) { set_anim(this, anim_boss_shockc9, boss_shockc10); }
void boss_shockc8(entity this) { set_anim(this, anim_boss_shockc8, boss_shockc9); }
void boss_shockc7(entity this) { set_anim(this, anim_boss_shockc7, boss_shockc8); }
void boss_shockc6(entity this) { set_anim(this, anim_boss_shockc6, boss_shockc7); }
void boss_shockc5(entity this) { set_anim(this, anim_boss_shockc5, boss_shockc6); }
void boss_shockc4(entity this) { set_anim(this, anim_boss_shockc4, boss_shockc5); }
void boss_shockc3(entity this) { set_anim(this, anim_boss_shockc3, boss_shockc4); }
void boss_shockc2(entity this) { set_anim(this, anim_boss_shockc2, boss_shockc3); }
void boss_shockc1(entity this) { set_anim(this, anim_boss_shockc1, boss_shockc2); }

void boss_death10(entity this)
{
	// being removed, don't need new frame
	//set_anim(this, anim_boss_death9, boss_death10);
	killed_monsters = killed_monsters + 1;
	WriteByte(MSG_ALL, SVC_KILLEDMONSTER);	// FIXME: reliable broadcast
	SUB_UseTargets(this, this.enemy, NULL);
	delete(this);
}
void boss_death9(entity this)
{
	set_anim(this, anim_boss_death9, boss_death10);
	_sound(this, CH_PAIN, "boss1/out1.wav", 1, ATTN_NORM);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);
}
void boss_death8(entity this) { set_anim(this, anim_boss_death8, boss_death9); }
void boss_death7(entity this) { set_anim(this, anim_boss_death7, boss_death8); }
void boss_death6(entity this) { set_anim(this, anim_boss_death6, boss_death7); }
void boss_death5(entity this) { set_anim(this, anim_boss_death5, boss_death6); }
void boss_death4(entity this) { set_anim(this, anim_boss_death4, boss_death5); }
void boss_death3(entity this) { set_anim(this, anim_boss_death3, boss_death4); }
void boss_death2(entity this) { set_anim(this, anim_boss_death2, boss_death3); }
void boss_death1(entity this)
{
	set_anim(this, anim_boss_death1, boss_death2);
	_sound(this, CH_VOICE, "boss1/death.wav", 1, ATTN_NORM);
}

void boss_missile(entity this, vector p)
{
	vector vec, d;

	vector offang = vectoangles(this.enemy.origin - this.origin);	
	makevectors(offang);

	vector org = this.origin + p_x*v_forward + p_y*v_right + p_z*'0 0 1';
	
// lead the player on hard mode
	if(skill > 1)
	{
		float t = vlen(this.enemy.origin - org) / 300;
		vec = this.enemy.velocity;
		vec_z = 0;
		d = this.enemy.origin + t * vec;		
	}
	else
	{
		d = this.enemy.origin;
	}
	
	vec = normalize(d - org);

	entity newmis = launch_spike(this, org, vec);
	_setmodel(newmis, "progs/lavaball.mdl");
	newmis.avelocity = '200 100 300';
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);		
	newmis.velocity = vec*300;
	settouch(newmis, T_MissileTouch); // rocket explosion
	_sound(this, CH_SHOTS, "boss1/throw.wav", 1, ATTN_NORM);

// check for dead enemy
	if(this.enemy.health <= 0)
		boss_idle1(this);
}


void boss_awake(entity this, entity actor, entity trigger)
{
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.takedamage = DAMAGE_NO;
	
	_setmodel(this, "progs/boss.mdl");
	setsize(this, '-128 -128 -24', '128 128 256');
	
	if(skill == 0)
		this.health = 1;
	else
		this.health = 3;

	this.enemy = actor;

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);

	this.yaw_speed = 20;
	boss_rise1(this);
}


/*QUAKED monster_boss(1 0 0)(-128 -128 -24)(128 128 256)
*/
spawnfunc(monster_boss)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model("progs/boss.mdl");
	precache_model("progs/lavaball.mdl");

	precache_sound("weapons/rocket1i.wav");
	precache_sound("boss1/out1.wav");
	precache_sound("boss1/sight1.wav");
	precache_sound("misc/power.wav");
	precache_sound("boss1/throw.wav");
	precache_sound("boss1/pain.wav");
	precache_sound("boss1/death.wav");

	total_monsters = total_monsters + 1;

	this.use = boss_awake;
}

//===========================================================================

entity	le1, le2;
float lightning_end;

void lightning_fire(entity this)
{
	if(time >= lightning_end)
	{	// done here, put the terminals back up
		door_go_down(le1);
		door_go_down(le2);
		return;
	}
	
	vector p1 =(le1.mins + le1.maxs) * 0.5;
	p1_z = le1.absmin_z - 16;
	
	vector p2 =(le2.mins + le2.maxs) * 0.5;
	p2_z = le2.absmin_z - 16;
	
	// compensate for length of bolt
	p2 = p2 - normalize(p2-p1)*100;

	this.nextthink = time + 0.1;
	setthink(this, lightning_fire);

	WriteByte(MSG_ALL, SVC_TEMPENTITY);
	WriteByte(MSG_ALL, TE_LIGHTNING3);
	WriteEntity(MSG_ALL, NULL);
	WriteCoord(MSG_ALL, p1_x);
	WriteCoord(MSG_ALL, p1_y);
	WriteCoord(MSG_ALL, p1_z);
	WriteCoord(MSG_ALL, p2_x);
	WriteCoord(MSG_ALL, p2_y);
	WriteCoord(MSG_ALL, p2_z);
}

void lightning_use(entity this, entity actor, entity trigger)
{
	if(lightning_end >= time + 1)
		return;

	le1 = find( NULL, target, "lightning");
	le2 = find( le1, target, "lightning");
	if(!le1 || !le2)
	{
		dprint("missing lightning targets\n");
		return;
	}
	
	if(
	(le1.state != STATE_TOP && le1.state != STATE_BOTTOM)
	||(le2.state != STATE_TOP && le2.state != STATE_BOTTOM)
	||(le1.state != le2.state) )
	{
//		dprint("not aligned\n");
		return;
	}

// don't let the electrodes go back up until the bolt is done
	le1.nextthink = -1;
	le2.nextthink = -1;
	lightning_end = time + 1;

	_sound(this, CH_VOICE, "misc/power.wav", 1, ATTN_NORM);
	lightning_fire(this);		

// advance the boss pain if down
	entity e = find(NULL, classname, "monster_boss");
	if(!e)
		return;
	e.enemy = actor;
	if(le1.state == STATE_TOP && e.health > 0)
	{
		_sound(e, CH_VOICE, "boss1/pain.wav", 1, ATTN_NORM);
		e.health = e.health - 1;
		if(e.health >= 2)
			boss_shocka1(e);
		else if(e.health == 1)
			boss_shockb1(e);
		else if(e.health == 0)
			boss_shockc1(e);
	}	
}


/*QUAKED event_lightning(0 1 1)(-16 -16 -16)(16 16 16)
Just for boss level.
*/
spawnfunc(event_lightning)
{
	this.use = lightning_use;
}


