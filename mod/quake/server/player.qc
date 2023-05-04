#include "player.qh"

#include "impel/impel.qh"

/*
==============================================================================

PLAYER

==============================================================================
*/

//Yoder Sept24 2021, Horde Merge
void MonsterFade(entity this); // Used for handling gibs and corpses

$cd id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

#if 0
const int anim_player_axrun1 = 0;
const int anim_player_axrun2 = 1;
const int anim_player_axrun3 = 2;
const int anim_player_axrun4 = 3;
const int anim_player_axrun5 = 4;
const int anim_player_axrun6 = 5;

const int anim_player_rockrun1 = 6;
const int anim_player_rockrun2 = 7;
const int anim_player_rockrun3 = 8;
const int anim_player_rockrun4 = 9;
const int anim_player_rockrun5 = 10;
const int anim_player_rockrun6 = 11;

const int anim_player_stand1 = 12;
const int anim_player_stand2 = 13;
const int anim_player_stand3 = 14;
const int anim_player_stand4 = 15;
const int anim_player_stand5 = 16;

const int anim_player_axstnd1 = 17;
const int anim_player_axstnd2 = 18;
const int anim_player_axstnd3 = 19;
const int anim_player_axstnd4 = 20;
const int anim_player_axstnd5 = 21;
const int anim_player_axstnd6 = 22;
const int anim_player_axstnd7 = 23;
const int anim_player_axstnd8 = 24;
const int anim_player_axstnd9 = 25;
const int anim_player_axstnd10 = 26;
const int anim_player_axstnd11 = 27;
const int anim_player_axstnd12 = 28;

const int anim_player_axpain1 = 29;
const int anim_player_axpain2 = 30;
const int anim_player_axpain3 = 31;
const int anim_player_axpain4 = 32;
const int anim_player_axpain5 = 33;
const int anim_player_axpain6 = 34;

const int anim_player_pain1 = 35;
const int anim_player_pain2 = 36;
const int anim_player_pain3 = 37;
const int anim_player_pain4 = 38;
const int anim_player_pain5 = 39;
const int anim_player_pain6 = 40;

const int anim_player_axdeth1 = 41;
const int anim_player_axdeth2 = 42;
const int anim_player_axdeth3 = 43;
const int anim_player_axdeth4 = 44;
const int anim_player_axdeth5 = 45;
const int anim_player_axdeth6 = 46;
const int anim_player_axdeth7 = 47;
const int anim_player_axdeth8 = 48;
const int anim_player_axdeth9 = 49;

const int anim_player_deatha1 = 50;
const int anim_player_deatha2 = 51;
const int anim_player_deatha3 = 52;
const int anim_player_deatha4 = 53;
const int anim_player_deatha5 = 54;
const int anim_player_deatha6 = 55;
const int anim_player_deatha7 = 56;
const int anim_player_deatha8 = 57;
const int anim_player_deatha9 = 58;
const int anim_player_deatha10 = 59;
const int anim_player_deatha11 = 60;

const int anim_player_deathb1 = 61;
const int anim_player_deathb2 = 62;
const int anim_player_deathb3 = 63;
const int anim_player_deathb4 = 64;
const int anim_player_deathb5 = 65;
const int anim_player_deathb6 = 66;
const int anim_player_deathb7 = 67;
const int anim_player_deathb8 = 68;
const int anim_player_deathb9 = 69;

const int anim_player_deathc1 = 70;
const int anim_player_deathc2 = 71;
const int anim_player_deathc3 = 72;
const int anim_player_deathc4 = 73;
const int anim_player_deathc5 = 74;
const int anim_player_deathc6 = 75;
const int anim_player_deathc7 = 76;
const int anim_player_deathc8 = 77;
const int anim_player_deathc9 = 78;
const int anim_player_deathc10 = 79;
const int anim_player_deathc11 = 80;
const int anim_player_deathc12 = 81;
const int anim_player_deathc13 = 82;
const int anim_player_deathc14 = 83;
const int anim_player_deathc15 = 84;

const int anim_player_deathd1 = 85;
const int anim_player_deathd2 = 86;
const int anim_player_deathd3 = 87;
const int anim_player_deathd4 = 88;
const int anim_player_deathd5 = 89;
const int anim_player_deathd6 = 90;
const int anim_player_deathd7 = 91;
const int anim_player_deathd8 = 92;
const int anim_player_deathd9 = 93;

const int anim_player_deathe1 = 94;
const int anim_player_deathe2 = 95;
const int anim_player_deathe3 = 96;
const int anim_player_deathe4 = 97;
const int anim_player_deathe5 = 98;
const int anim_player_deathe6 = 99;
const int anim_player_deathe7 = 100;
const int anim_player_deathe8 = 101;
const int anim_player_deathe9 = 102;

const int anim_player_nailatt1 = 103;
const int anim_player_nailatt2 = 104;

const int anim_player_light1 = 105;
const int anim_player_light2 = 106;

const int anim_player_rockatt1 = 107;
const int anim_player_rockatt2 = 108;
const int anim_player_rockatt3 = 109;
const int anim_player_rockatt4 = 110;
const int anim_player_rockatt5 = 111;
const int anim_player_rockatt6 = 112;

const int anim_player_shotatt1 = 113;
const int anim_player_shotatt2 = 114;
const int anim_player_shotatt3 = 115;
const int anim_player_shotatt4 = 116;
const int anim_player_shotatt5 = 117;
const int anim_player_shotatt6 = 118;

const int anim_player_axatt1 = 119;
const int anim_player_axatt2 = 120;
const int anim_player_axatt3 = 121;
const int anim_player_axatt4 = 122;
const int anim_player_axatt5 = 123;
const int anim_player_axatt6 = 124;

const int anim_player_axattb1 = 125;
const int anim_player_axattb2 = 126;
const int anim_player_axattb3 = 127;
const int anim_player_axattb4 = 128;
const int anim_player_axattb5 = 129;
const int anim_player_axattb6 = 130;

const int anim_player_axattc1 = 131;
const int anim_player_axattc2 = 132;
const int anim_player_axattc3 = 133;
const int anim_player_axattc4 = 134;
const int anim_player_axattc5 = 135;
const int anim_player_axattc6 = 136;

const int anim_player_axattd1 = 137;
const int anim_player_axattd2 = 138;
const int anim_player_axattd3 = 139;
const int anim_player_axattd4 = 140;
const int anim_player_axattd5 = 141;
const int anim_player_axattd6 = 142;
#endif

const int anim_player_axrun1 = 0; //'0 5 0';
const int anim_player_rockrun1 = 6; //'6 11 0';
const int anim_player_stand1 = 12; //'12 16 0';
const int anim_player_axstnd1 = 17; //'17 28 0';
const int anim_player_axpain1 = 29; //'29 34 0';
const int anim_player_pain1 = 35; //'35 40 0';
const int anim_player_axdeth1 = 41; //'41 49 0';
const int anim_player_deatha1 = 50; //'50 60 0';
const int anim_player_deathb1 = 61; //'61 69 0';
const int anim_player_deathc1 = 70; //'70 84 0';
const int anim_player_deathd1 = 85; //'85 93 0';
const int anim_player_deathe1 = 94; //'94 102 0';
const int anim_player_nailatt1 = 103; //'103 104 0';
const int anim_player_light1 = 105; //'105 106 0';
const int anim_player_rockatt1 = 107; //'107 112 0';
const int anim_player_shotatt1 = 113; //'113 118 0';
const int anim_player_axatt1 = 119; //'119 124 0';
const int anim_player_axattb1 = 125; //'125 130 0';
const int anim_player_axattc1 = 131; //'131 136 0';
const int anim_player_axattd1 = 137; //'137 142 0';


/*
==============================================================================
PLAYER
==============================================================================
*/

void player_run(entity this);

void player_stand1(entity this)
{
	set_anim(this, anim_player_axstnd1, player_stand1);

	this.weaponframe=0;
	if(this.velocity_x || this.velocity_y)
	{
		this.walkframe=0;
		player_run(this);
		return;
	}

	if(this.weapon == WEP_AXE.m_id)
	{
		if(this.walkframe >= 12)
			this.walkframe = 0;
		this.frame = anim_player_axstnd1 + this.walkframe;
	}
	else if(this.weapon == WEP_MJOLNIR.m_id)
	{
		if(this.walkframe >= 12)
			this.walkframe = 0;
		this.frame = 6 + this.walkframe;
	}
	else
	{
		if(this.walkframe >= 5)
			this.walkframe = 0;
		this.frame = anim_player_stand1 + this.walkframe;
	}
	this.walkframe = this.walkframe + 1;	
}

void player_run(entity this)
{
	set_anim(this, anim_player_rockrun1, player_run);

	this.weaponframe=0;
	if(!this.velocity_x && !this.velocity_y)
	{
		this.walkframe=0;
		player_stand1(this);
		return;
	}

	if(this.weapon == WEP_AXE.m_id)
	{
		if(this.walkframe == 6)
			this.walkframe = 0;
		this.frame = anim_player_axrun1 + this.walkframe;
	}
	else if(this.weapon == WEP_MJOLNIR.m_id)
	{
		if(this.walkframe == 6)
			this.walkframe = 0;
		this.frame = this.walkframe;
	}
	else
	{
		bool check_walkframe = (this.walkframe == 6);
		if(MP_IMPEL)
			check_walkframe = (this.walkframe >= 6);
		if(check_walkframe)
			this.walkframe = 0;
		this.frame = this.frame + this.walkframe;
	}

	if(MP_HIPNOTIC && footsteps == 1 && !gameover)
	{
		this.spawnsilent = this.spawnsilent + vlen(this.origin - this.old_velocity);
		this.old_velocity = this.origin;
		if(IS_ONGROUND(this) && this.waterlevel <= 1)
		{
			if(this.spawnsilent > 95)
			{
				if(this.spawnsilent > 190)
					this.spawnsilent = 0;
				else
					this.spawnsilent = 0.5 * (this.spawnsilent - 95);

				float r = random();
				if(r < 0.14)
				_sound(this, CH_VOICE, "misc/foot1.wav", 0.5, ATTN_NORM);
				else if(r < 0.29)
				   _sound(this, CH_VOICE, "misc/foot2.wav", 0.5, ATTN_NORM);
				else if(r < 0.43)
				   _sound(this, CH_VOICE, "misc/foot3.wav", 0.5, ATTN_NORM);
				else if(r < 0.58)
				   _sound(this, CH_VOICE, "misc/foot4.wav", 0.5, ATTN_NORM);
				else if(r < 0.72)
				   _sound(this, CH_VOICE, "misc/foot5.wav", 0.5, ATTN_NORM);
				else if(r < 0.86)
				   _sound(this, CH_VOICE, "misc/foot6.wav", 0.5, ATTN_NORM);
				else
				   _sound(this, CH_VOICE, "misc/foot7.wav", 0.5, ATTN_NORM);
			}
		}
	}
	this.walkframe = this.walkframe + 1;

	if(MP_IMPEL)
	{
		if(this.waterlevel == 0 && !gameover)
		{
			if(this.walkframe == 1 || this.walkframe == 4)
			{
				if(t_checkbottom(this))
				{
					float rand = random();
					if(rand < 0.3)
					{
						if(random() < 0.5)
							_sound(this, CHAN_BODY, "player/walk1.wav", 1, ATTN_NORM);
						else
							_sound(this, CHAN_BODY, "player/walk4.wav", 1, ATTN_NORM);
					}
					else if(rand < 0.6)
					{
						if(random() < 0.5)
							_sound(this, CHAN_BODY, "player/walk2.wav", 1, ATTN_NORM);
						else
							_sound(this, CHAN_BODY, "player/walk5.wav", 1, ATTN_NORM);
					}
					else if(rand < 0.9)
					{
						if(random() < 0.5)
							_sound(this, CHAN_BODY, "player/walk3.wav", 1, ATTN_NORM);
						else
							_sound(this, CHAN_BODY, "player/walk6.wav", 1, ATTN_NORM);
					}
				}
			}
		}
		else if(this.waterlevel == 1)
		{
			if(this.walkframe == 1 || this.walkframe == 4)
			{
				if(t_checkbottom(this))
				{
					if(random() < 0.3)
					{
						if(random() < 0.5)
							_sound(this, CHAN_BODY, "player/walkh2o1.wav", 1, ATTN_NORM);
						else
							_sound(this, CHAN_BODY, "player/walkh2o2.wav", 1, ATTN_NORM);
					}
				}
			}
		}
	}
}

void player_shot6(entity this) { set_animofs(this, anim_player_shotatt1, 6, player_run); this.weaponframe = 6; }
void player_shot5(entity this) { set_animofs(this, anim_player_shotatt1, 5, player_shot6); this.weaponframe = 5; }
void player_shot4(entity this) { set_animofs(this, anim_player_shotatt1, 4, player_shot5); this.weaponframe = 4; }
void player_shot3(entity this) { set_animofs(this, anim_player_shotatt1, 3, player_shot4); this.weaponframe = 3; }
void player_shot2(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_shot3); this.weaponframe = 2; }
void player_shot1(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_shot2); this.weaponframe = 1; this.effects |= EF_MUZZLEFLASH; }

void player_shotimp10(entity this) { set_animofs(this, anim_player_shotatt1, 6, player_run); }
void player_shotimp9(entity this) { set_animofs(this, anim_player_shotatt1, 5, player_shotimp10); this.weaponframe = 8; }
void player_shotimp8(entity this) { set_animofs(this, anim_player_shotatt1, 4, player_shotimp9); this.weaponframe = 7; }
void player_shotimp7(entity this) { set_animofs(this, anim_player_shotatt1, 3, player_shotimp8); this.weaponframe = 6; _sound(this, CHAN_AUTO, "weapons/impaler/impload.wav", 1, ATTN_NORM); }
void player_shotimp6(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_shotimp7); this.weaponframe = 6; }
void player_shotimp5(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_shotimp6); this.weaponframe = 5; }
void player_shotimp4(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_shotimp5); this.weaponframe = 4; W_FireSpear(this); }
void player_shotimp3(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_shotimp4); this.weaponframe = 3; this.effects |= EF_MUZZLEFLASH; }
void player_shotimp2(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_shotimp3); this.weaponframe = 2; _sound(this, CHAN_WEAPON, "weapons/impaler/impfire.wav", 1, ATTN_NORM); }
void player_shotimp1(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_shotimp2); this.weaponframe = 1; }

void player_axe4(entity this) { set_animofs(this, anim_player_axatt1, 4, player_run); this.weaponframe = 4; }
void player_axe3(entity this) { set_animofs(this, anim_player_axatt1, 3, player_axe4); this.weaponframe = 3; W_FireAxe(this); }
void player_axe2(entity this) { set_animofs(this, anim_player_axatt1, 2, player_axe3); this.weaponframe = 2; }
void player_axe1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_axe2); this.weaponframe = 1; }

void player_axeb4(entity this) { set_animofs(this, anim_player_axattb1, 4, player_run); this.weaponframe = 8; }
void player_axeb3(entity this) { set_animofs(this, anim_player_axattb1, 3, player_axeb4); this.weaponframe = 7; W_FireAxe(this); }
void player_axeb2(entity this) { set_animofs(this, anim_player_axattb1, 2, player_axeb3); this.weaponframe = 6; }
void player_axeb1(entity this) { set_animofs(this, anim_player_axattb1, 1, player_axeb2); this.weaponframe = 5; }

void player_axec4(entity this) { set_animofs(this, anim_player_axattc1, 4, player_run); this.weaponframe = 4; }
void player_axec3(entity this) { set_animofs(this, anim_player_axattc1, 3, player_axec4); this.weaponframe = 3; W_FireAxe(this); }
void player_axec2(entity this) { set_animofs(this, anim_player_axattc1, 2, player_axec3); this.weaponframe = 2; }
void player_axec1(entity this) { set_animofs(this, anim_player_axattc1, 1, player_axec2); this.weaponframe = 1; }

void player_axed4(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); this.weaponframe = 8; }
void player_axed3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_axed4); this.weaponframe = 7; W_FireAxe(this); }
void player_axed2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_axed3); this.weaponframe = 6; }
void player_axed1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_axed2); this.weaponframe = 5; }


//============================================================================
//ZOID--
void W_FireGrapple(entity this);

void player_grapple3(entity this);
void player_grapple5(entity this) { set_animofs(this, anim_player_axattd1, 4, player_run); this.weaponframe = 1; }
void player_grapple4(entity this)
{
	set_animofs(this, anim_player_deathc1, 4, player_grapple4);
	this.weaponframe = 2;
	if(!this.hook_out)
	{
		player_grapple5(this);
		return;
	}
	if(!this.on_hook || vdist(this.hook.origin - this.origin, <, 5))
	{
		player_grapple3(this);
		return;
	}
}
void player_grapple3(entity this)
{
	set_animofs(this, anim_player_axattd1, 3, player_grapple3);
	this.weaponframe = 2;
	if(!this.hook_out)
	{
		player_grapple5(this);
		return;
	}
	if(this.on_hook && vdist(this.hook.origin - this.origin, >=, 50))
	{
		player_grapple4(this);
		return;
	}
}
void player_grapple2(entity this) { set_animofs(this, anim_player_axattd1, 2, player_grapple3); this.weaponframe = 2; }
void player_grapple1(entity this) { set_animofs(this, anim_player_axattd1, 1, player_grapple2); this.weaponframe = 1; W_FireGrapple(this); }

//--ZOID
//============================================================================

void player_rifle6(entity this) { set_animofs(this, anim_player_shotatt1, 6, player_run); }
void player_rifle5(entity this) { set_animofs(this, anim_player_shotatt1, 5, player_rifle6); }
void player_rifle4(entity this) { set_animofs(this, anim_player_shotatt1, 4, player_rifle5); }
void player_rifle3(entity this) { set_animofs(this, anim_player_shotatt1, 3, player_rifle4); }
void player_rifle2(entity this) { set_animofs(this, anim_player_shotatt1, 2, player_rifle3); }
void player_rifle1(entity this) { set_animofs(this, anim_player_shotatt1, 1, player_rifle2); this.weaponframe = 0; this.effects |= EF_MUZZLEFLASH; }

void player_nail2(entity this);
void player_nail1(entity this)
{
	set_animofs(this, anim_player_nailatt1, 1, player_nail2);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 9)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireSpikes(this, 3);
	this.attack_finished = time + 0.2;
}
void player_nail2(entity this)
{
	set_animofs(this, anim_player_nailatt1, 2, player_nail1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 9)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireSpikes(this, -3);
	this.attack_finished = time + 0.2;
}

//============================================================================

void W_FireLavaSpikes(entity this, float ox);

void player_lava_nail2(entity this);
void player_lava_nail1(entity this)
{
	set_animofs(this, anim_player_nailatt1, 1, player_lava_nail2);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
	{
		player_run(this);
		return;
	}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 9)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireLavaSpikes(this, 3);
	this.attack_finished = time + 0.2;
}
void player_lava_nail2(entity this)
{
	set_animofs(this, anim_player_nailatt1, 2, player_lava_nail1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 9)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireLavaSpikes(this, -4);
	this.attack_finished = time + 0.2;
}

void player_superlight2(entity this);
void player_superlight1(entity this)
{
	set_animofs(this, anim_player_light1, 1, player_superlight2);

	if(this.ammo_cells < 1)
	{
		this.attack_finished = time + 0.5;
		_sound(this, CHAN_WEAPON, "misc/power.wav", 1, ATTN_NORM);
		this.ammo_cells = 0;
		W_SetCurrentAmmo(this);
		return;
	}
	this.attack_finished = time + 0.1;
	_sound(this, CHAN_AUTO, "weapons/light2/lgstart1.wav", 1, ATTN_NORM);
	this.effects |= EF_MUZZLEFLASH;
	if(!this.button0)
	{
		player_run(this);
		return;
	}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 5)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireSuperLightning(this);
}

void player_superlight2(entity this)
{
	set_animofs(this, anim_player_light1, 2, player_superlight1);

	this.effects |= EF_MUZZLEFLASH;
	if(!this.button0)
	{
		player_run(this);
		return;
	}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 5)
		this.weaponframe = 1;
	SuperDamageSound(this);
	W_FireSuperLightning(this);
	this.attack_finished = time + 0.1;
}

//============================================================================
//ooppee - the entire player_light1 had to be reverted back to id1 code so replace the old player_light1 and player_light2 code with this, I deleted the old code.

void player_light2(entity this);
void player_light1(entity this)
{
	set_animofs(this, anim_player_light1, 1, player_light2);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 5)
		this.weaponframe = 1;
	SuperDamageSound(this);
	//if(this.weapon == WEP_PLASMA_GUN.m_id)
	//{
		//W_FirePlasma(this);
		//player_run(this);
		//return;
	//}
	//else
	//{
		W_FireLightning(this);
		this.attack_finished = time + 0.2;
	//}
}
void player_light2(entity this)
{
	set_animofs(this, anim_player_light1, 1, player_light1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponframe = this.weaponframe + 1;
	if(this.weaponframe == 5)
		this.weaponframe = 1;
	SuperDamageSound(this);
	//if(this.weapon != WEP_PLASMA_GUN.m_id)
	//{
		W_FireLightning(this);
		this.attack_finished = time + 0.2;
	//}
}
//ooppee end
//ooppee the new plasma code it's a whole new addition. This gives the first person weapon a animation. It does however change the Thirdperson (Player model) animation.
//it previously used the Shaft/Lightning Guns animation. That caused issues due to how short. So I gave it the RPG player model animation. More suiting after all you are
//launching a fucking energy ball of death lol
//A HUGE thanks to the guys at inside3d.com forums for guiding me in the right direction to figure this out!
void W_FirePlasma(entity this);

void player_plasma6(entity this) { set_animofs(this, anim_player_rockatt1, 6, player_run); this.weaponframe = 5; } //ooppee uses the rocket fire animation for thirdperson, it's 6 frames though, not 5 so had to dupe it.
void player_plasma5(entity this) { set_animofs(this, anim_player_rockatt1, 5, player_plasma6); this.weaponframe = 5; }
void player_plasma4(entity this) { set_animofs(this, anim_player_rockatt1, 4, player_plasma5); this.weaponframe = 4; }
void player_plasma3(entity this) { set_animofs(this, anim_player_rockatt1, 3, player_plasma4); this.weaponframe = 3; }
void player_plasma2(entity this) { set_animofs(this, anim_player_rockatt1, 2, player_plasma3); this.weaponframe = 2; }
void player_plasma1(entity this) { set_animofs(this, anim_player_rockatt1, 1, player_plasma2); this.weaponframe = 1; this.effects |= EF_MUZZLEFLASH; }

//ooppee end
//============================================================================


//MED 10/18/96 added HIPWEAPONS
//============================================================================

void player_hammer6(entity this) { set_anim(this, 37, player_run); this.weaponframe = 4; }
void player_hammer5(entity this) { set_anim(this, 36, player_hammer6); this.weaponframe = 4; }
void player_hammer4(entity this) { set_anim(this, 35, player_hammer5); this.weaponframe = 4; HIP_FireMjolnir(this); }
void player_hammer3(entity this) { set_anim(this, 34, player_hammer4); this.weaponframe = 3; }
void player_hammer2(entity this) { set_anim(this, 33, player_hammer3); this.weaponframe = 2; }
void player_hammer1(entity this) { set_anim(this, 32, player_hammer2); this.weaponframe = 1; }

void player_mjolnir6(entity this) { set_anim(this, 43, player_run); this.weaponframe = 4; }
void player_mjolnir5(entity this) { set_anim(this, 42, player_mjolnir6); this.weaponframe = 4; }
void player_mjolnir4(entity this) { set_anim(this, 41, player_mjolnir5); this.weaponframe = 4; HIP_FireMjolnir(this); }
void player_mjolnir3(entity this) { set_anim(this, 40, player_mjolnir4); this.weaponframe = 3; }
void player_mjolnir2(entity this) { set_anim(this, 39, player_mjolnir3); this.weaponframe = 2; }
void player_mjolnir1(entity this) { set_anim(this, 38, player_mjolnir2); this.weaponframe = 1; }

//============================================================================

//MED 10/18/96 added HIPSWEAPONS
//void() player_laser1   =[$nailatt1, player_laser2  ] {this.attack_finished = time + 0.1;this.weaponframe=1;this.nextthink = time + 0.09;HIP_FireLaser(0);}
//void() player_laser2   =[$nailatt2, player_laser4  ] {this.attack_finished = time + 0.1;this.weaponframe=2;this.nextthink = time + 0.09;}
//void() player_laser3   =[$nailatt1, player_laser4  ] {this.attack_finished = time + 0.1;this.weaponframe=3;this.nextthink = time + 0.09;}
//void() player_laser4   =[$nailatt2, player_laser5  ] {this.attack_finished = time + 0.1;this.weaponframe=4;this.nextthink = time + 0.09;HIP_FireLaser(1);}
//void() player_laser5   =[$nailatt1, player_laser1  ] {this.attack_finished = time + 0.1;this.weaponframe=5;this.nextthink = time + 0.09;}
//void() player_laser6   =[$nailatt2, player_laser1  ] {this.attack_finished = time + 0.1;this.weaponframe=6;this.nextthink = time + 0.09;}
void player_laser1(entity this);
void player_laser4(entity this) { set_animofs(this, anim_player_nailatt1, 1, player_laser1); this.attack_finished = time + 0.1; this.weaponframe = 5; this.nextthink = time + 0.1; }
void player_laser3(entity this) { set_animofs(this, anim_player_nailatt1, 2, player_laser1); this.attack_finished = time + 0.1; this.weaponframe = 4; this.nextthink = time + 0.1; HIP_FireLaser(this, 1); }
void player_laser2(entity this) { set_animofs(this, anim_player_nailatt1, 2, player_laser3); this.attack_finished = time + 0.1; this.weaponframe = 2; this.nextthink = time + 0.1; }
void player_laser1(entity this) { set_animofs(this, anim_player_nailatt1, 1, player_laser3); this.attack_finished = time + 0.1; this.weaponframe = 1; this.nextthink = time + 0.1; HIP_FireLaser(this, 0); }


void player_rocket6(entity this) { set_animofs(this, anim_player_rockatt1, 6, player_run); this.weaponframe = 6; }
void player_rocket5(entity this) { set_animofs(this, anim_player_rockatt1, 5, player_rocket6); this.weaponframe = 5; }
void player_rocket4(entity this) { set_animofs(this, anim_player_rockatt1, 4, player_rocket5); this.weaponframe = 4; }
void player_rocket3(entity this) { set_animofs(this, anim_player_rockatt1, 3, player_rocket4); this.weaponframe = 3; }
void player_rocket2(entity this) { set_animofs(this, anim_player_rockatt1, 2, player_rocket3); this.weaponframe = 2; }
void player_rocket1(entity this) { set_animofs(this, anim_player_rockatt1, 1, player_rocket2); this.weaponframe = 1; this.effects |= EF_MUZZLEFLASH; }

string get_painsound(entity this, int chance);
void PainSound(entity this, entity attacker)
{
	if(this.health < 0)
		return;

	if(attacker.classname == "teledeath")
	{
		_sound(this, CH_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

// water pain sounds
	if(this.watertype == CONTENT_WATER && this.waterlevel == 3)
	{
		DeathBubbles(this, 1);
		if(random() > 0.5)
			player_sound(this, CH_VOICE, "drown1.wav", ATTN_NORM);
		else
			player_sound(this, CH_VOICE, "drown2.wav", ATTN_NORM);
		return;
	}

// slime pain sounds
	if(this.watertype == CONTENT_SLIME)
	{
// FIX ME	put in some steam here
		if(random() > 0.5)
			player_sound(this, CH_VOICE, "lburn1.wav", ATTN_NORM);
		else
			player_sound(this, CH_VOICE, "lburn2.wav", ATTN_NORM);
		return;
	}

	if(this.watertype == CONTENT_LAVA)
	{
		if(random() > 0.5)
			player_sound(this, CH_VOICE, "lburn1.wav", ATTN_NORM);
		else
			player_sound(this, CH_VOICE, "lburn2.wav", ATTN_NORM);
		return;
	}

	if(this.pain_finished > time)
	{
		this.axhitme = false;
		return;
	}
	if(!MP_IMPEL)
		this.pain_finished = time + 0.5;

// don't make multiple pain sounds right after each other

// ax pain sound
	if(this.axhitme)
	{
		this.axhitme = false;
		player_sound(this, CH_VOICE, "axhit1.wav", ATTN_NORM);
		return;
	}
	

	int rs = rint((random() * 5) + 1);

	this.noise = "";

	this.noise = get_painsound(this, rs);

	if(this.noise && this.noise != "")
		_sound(this, CH_VOICE, this.noise, 1, ATTN_NORM);
}

void player_pain6(entity this) { set_animofs(this, anim_player_pain1, 6, player_run); }
void player_pain5(entity this) { set_animofs(this, anim_player_pain1, 5, player_pain6); }
void player_pain4(entity this) { set_animofs(this, anim_player_pain1, 4, player_pain5); }
void player_pain3(entity this) { set_animofs(this, anim_player_pain1, 3, player_pain4); }
void player_pain2(entity this) { set_animofs(this, anim_player_pain1, 2, player_pain3); }
void player_pain1(entity this, entity attacker) { set_animofs(this, anim_player_pain1, 1, player_pain2); PainSound(this, attacker); this.weaponframe = 0; }

void player_axpain6(entity this) { set_animofs(this, anim_player_axpain1, 6, player_run); }
void player_axpain5(entity this) { set_animofs(this, anim_player_axpain1, 5, player_axpain6); }
void player_axpain4(entity this) { set_animofs(this, anim_player_axpain1, 4, player_axpain5); }
void player_axpain3(entity this) { set_animofs(this, anim_player_axpain1, 3, player_axpain4); }
void player_axpain2(entity this) { set_animofs(this, anim_player_axpain1, 2, player_axpain3); }
void player_axpain1(entity this, entity attacker) { set_animofs(this, anim_player_axpain1, 1, player_axpain2); PainSound(this, attacker); this.weaponframe = 0; }

// hipnotic
void player_hampain6(entity this) { set_anim(this, 23, player_run); }
void player_hampain5(entity this) { set_anim(this, 22, player_hampain6); }
void player_hampain4(entity this) { set_anim(this, 21, player_hampain5); }
void player_hampain3(entity this) { set_anim(this, 20, player_hampain4); }
void player_hampain2(entity this) { set_anim(this, 19, player_hampain3); }
void player_hampain1(entity this, entity attacker) { set_anim(this, 18, player_hampain2); PainSound(this, attacker); this.weaponframe = 0; }

void player_pain(entity this, entity attacker, float damage)
{
	if(this.weaponframe)
		return;

	if(MP_IMPEL && this.pain_finished > time)
		return;

	if(this.invisible_finished > time)
		return;		// eyes don't have pain frames

	if(this.weapon == WEP_AXE.m_id)
		player_axpain1(this, attacker);
	else if(this.weapon == WEP_MJOLNIR.m_id)
		player_hampain1(this, attacker);
	else
		player_pain1(this, attacker);
	if(MP_IMPEL)
		this.pain_finished = time + 0.5;
}

void player_diea1(entity this);
void player_dieb1(entity this);
void player_diec1(entity this);
void player_died1(entity this);
void player_diee1(entity this);
void player_die_ax1(entity this);

// hipnotic
void player_die_ham1(entity this);

/*QUAKED air_bubbles(0 .5 .8)(-8 -8 -8)(8 8 8)

testing air bubbles
*/

spawnfunc(air_bubbles)
{
	if(deathmatch) { delete(this); return; }

	precache_model("progs/s_bubble.spr");
	this.nextthink = time + 1;
	setthink(this, make_bubbles);
}

void make_bubbles(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, this.origin);
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	setthink(bubble, bubble_bob);
	settouch(bubble, bubble_remove);
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.nextthink = time + random() + 0.5;
	setthink(this, make_bubbles);
}

void bubble_split(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, this.origin);
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = this.velocity;
	bubble.nextthink = time + 0.5;
	setthink(bubble, bubble_bob);
	settouch(bubble, bubble_remove);
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = 10;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.frame = 1;
	this.cnt = 10;
	if(this.waterlevel != 3)
		delete(this);
}

void bubble_remove(entity this, entity toucher)
{
	if(toucher.classname == this.classname)
	{
//		dprint("bump");
		return;
	}
	delete(this);
}

void bubble_bob(entity this)
{
	if(MP_ROGUE)
	{
		// PGM fix - 02/25/97 so bubbles won't go through walls
		float bubcont = pointcontents(this.origin);
		if(bubcont == CONTENT_SOLID)
		{
			delete(this);
			return;
		}
		// PGM fix - 02/25/97 so bubbles pop 2 seconds after leaving water
		else if(bubcont == CONTENT_EMPTY)
		{
			if(this.cnt < 16)
				this.cnt = 16;
		}
	}

	this.cnt = this.cnt + 1;
	if(this.cnt == 4)
		bubble_split(this);
	if(this.cnt == 20)
		delete(this);

	float rnd1 = this.velocity_x +(-10 +(random() * 20));
	float rnd2 = this.velocity_y +(-10 +(random() * 20));
	float rnd3 = this.velocity_z + 10 + random() * 10;

	if(rnd1 > 10)
		rnd1 = 5;
	if(rnd1 < -10)
		rnd1 = -5;
		
	if(rnd2 > 10)
		rnd2 = 5;
	if(rnd2 < -10)
		rnd2 = -5;
		
	if(rnd3 < 10)
		rnd3 = 15;
	if(rnd3 > 30)
		rnd3 = 25;
	
	this.velocity_x = rnd1;
	this.velocity_y = rnd2;
	this.velocity_z = rnd3;
		
	this.nextthink = time + 0.5;
	setthink(this, bubble_bob);
}

.int bubble_count;
void DeathBubblesSpawn(entity this)
{
	if(this.owner.waterlevel != 3)
		return;
	entity bubble = new(bubble);
	_setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, this.owner.origin + '0 0 24');
	set_movetype(bubble, MOVETYPE_NOCLIP);
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
	set_movetype(bubble_spawner, MOVETYPE_NONE);
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	setthink(bubble_spawner, DeathBubblesSpawn);
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = this;
	bubble_spawner.bubble_count = num_bubbles;
}

string get_deathsound(entity this, int chance);
void DeathSound(entity this)
{
	// water death sounds
	if(this.waterlevel == 3)
	{
		DeathBubbles(this, 20);
		player_sound(this, CH_VOICE, "h2odeath.wav", ATTN_NONE);
		return;
	}
	
	int rs = rint((random() * 4) + 1);
	this.noise = get_deathsound(this, rs);

	_sound(this, CH_VOICE, this.noise, 1, ATTN_NONE);
}


void PlayerDead(entity this)
{
	this.nextthink = -1;
// allow respawn after a certain time
	this.deadflag = DEAD_DEAD;
}

vector VelocityForDamage(entity this, float dm)
{
	vector v;

	// check if the inflictor had velocity, e.g. like a rocket or explode box
	if(damage_inflictor.velocity != '0 0 0')
	{
		// impact some of inflictor's velocity on the gibs
		v = 0.2 * damage_inflictor.velocity;
		v = v + (25 * normalize(this.origin - damage_inflictor.origin));
		v.z = 100 + 100 * random();
		v.x = v.x + (50 * crandom());
		v.y = v.y + (50 * crandom());
	}
	else
	{
		v.x = 100 * crandom();
		v.y = 100 * crandom();
		v.z = 200 + 100 * random();
	}

	if(MP_IMPEL && this.monsterdef == MON_BLUD)
		v = v * 2;
	else if(dm > -50)
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

void ThrowGib(entity this, string gibname, float dm)
{
	entity gib = spawn();
	setorigin(gib, this.origin);
	_setmodel(gib, gibname);
	setsize(gib, '0 0 0', '0 0 0');
	gib.velocity = VelocityForDamage(this, dm);
	set_movetype(gib, MOVETYPE_BOUNCE);
	gib.solid = SOLID_NOT;
	gib.avelocity_x = random()*600;
	gib.avelocity_y = random()*600;
	gib.avelocity_z = random()*600;
	setthink(gib, SUB_Remove);
	gib.ltime = time;
	gib.nextthink = time + 10 + random()*10;
	gib.frame = 0;
	gib.flags = 0;
}

void HeadThink(entity this)
{
   	this.nextthink = -1;
   	if(world.worldtype != WORLDTYPE_BASE && this.gorging)
	{
	  	if(random() < 0.1)
		 	_sound(this, 6, "misc/flys.wav", 0.7, ATTN_STATIC);
	}
}

void ThrowHead(entity this, string gibname, float dm)
{
	_setmodel(this, gibname);
	this.frame = 0;
	this.nextthink = -1;
	CorpseThink(this);
	set_movetype(this, MOVETYPE_BOUNCE);
	this.takedamage = DAMAGE_NO;
	this.solid = SOLID_NOT;
	this.view_ofs = '0 0 8';
	setsize(this, '-16 -16 0', '16 16 56');
	this.velocity = VelocityForDamage(this, dm);
	this.origin_z = this.origin_z - 24;
	UNSET_ONGROUND(this);
	this.avelocity = crandom() * '0 600 0';

	// Yoder Sept24 2021, Horde Merge
	if(MP_MG && horde_ent && !IS_PLAYER(this))
	{
		// only monsters gibs should fade away 
		setthink(this, MonsterFade);
		self.nextthink = time + 1;
	}
	else if(MP_HIPNOTIC)
	{
		this.gorging = true;
		setthink(this, HeadThink);
		this.nextthink = time + 1.5;
	}
}

void CorpseThink(entity this)
{
	if(!MP_IMPEL)
		return;
	if(corpse_removal && IS_MONSTER(this))
	{
		setthink(this, SUB_Remove);
		this.nextthink = time + 30 + (random () * 30);
	}
}

void GibPlayer(entity this, entity attacker)
{
	ThrowHead(this, get_playerhead(this), this.health);
	ThrowGib(this, "progs/gib1.mdl", this.health);
	ThrowGib(this, "progs/gib2.mdl", this.health);
	if(MP_IMPEL)
	{
		ThrowGib(this, "progs/rawbone.mdl", this.health);
		ThrowGib(this, "progs/rawbone.mdl", this.health);
		ThrowGib(this, "progs/rawbone2.mdl", this.health);
	}
	ThrowGib(this, "progs/gib3.mdl", this.health);

	this.deadflag = DEAD_DEAD;

	if(attacker.classname == "teledeath")
	{
		_sound(this, CH_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if(attacker.classname == "teledeath2")
	{
		_sound(this, CH_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if(random() < ((MP_IMPEL) ? 0.1 : 0.5))
	{
		if(MP_IMPEL)
		{
			_sound(this, CHAN_BODY, "player/gib.wav", 1, ATTN_NONE);
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NONE);
		}
		else
			_sound(this, CH_VOICE, "player/gib.wav", 1, ATTN_NONE);
	}
	else
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NONE);
}

void DropRune(entity this);
void PlayerDie(entity this, entity inflictor, entity attacker)
{
	ClientObituary(this, inflictor, attacker); // tell the world what happened

	this.powerups &= ~(POWERUP_INVISIBILITY | POWERUP_INVULNERABILITY | POWERUP_SUIT | POWERUP_QUAD);
	this.invisible_finished = 0;	// don't die as eyes
	this.invincible_finished = 0;
	this.super_damage_finished = 0;
	this.field_generator_finished = 0;
	this.radsuit_finished = 0;
	this.effects = 0;
	this.modelindex = this.modelindex_player;	// don't use eyes

	// hipnotic fields
	this.wetsuit_finished = 0;
	this.empathy_finished = 0;
	this.powerups &= ~POWERUP_EMPATHY_SHIELDS;

	// rogue fields
	this.gravity = 1.0;
	this.shield_finished = 0;
	this.antigrav_finished = 0;

	if(deathmatch || coop)
	{
		DropBackpack(this);
		if(MP_ROGUE)
		{
			TeamDropFlagOfPlayer(this);
			DropRune(this);
		}
	}

	if(MP_ROGUE)
	if(this.ctf_killed == 2)
		this.ctf_killed = 0;
	else
		this.ctf_killed = 1;
	
	this.weaponmodel="";
	this.view_ofs = '0 0 -8';
	this.deadflag = DEAD_DYING;
	this.solid = SOLID_NOT;
	UNSET_ONGROUND(this);
	if(MP_IMPEL)
		this.effects = 0;
	set_movetype(this, MOVETYPE_TOSS);
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
	
	if(this.weapon == WEP_AXE.m_id)
	{
		player_die_ax1(this);
		return;
	}
	else if(this.weapon == WEP_MJOLNIR.m_id)
	{
		this.modelindex = modelindex_hammer; // use hammer model
		player_die_ham1(this);
		return;
	}
	
	int j = 1 + floor(random() * 6);

	switch(j)
	{
		case 1: player_diea1(this); break;
		case 2: player_dieb1(this); break;
		case 3: player_diec1(this); break;
		case 4: player_died1(this); break;
		default: player_diee1(this); break;
	}
}

void set_suicide_frame(entity this)
{	// used by kill command and disconnect command
	if(this.model != "progs/player.mdl" && this.model != "progs/player_katria.mdl" && this.model != "progs/player_mario.mdl")
		return;	// already gibbed
	this.frame = anim_player_deatha1 + (11 - 1); // frame 11, hax
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_TOSS);
	this.deadflag = DEAD_DEAD;
	this.nextthink = -1;
}

void player_diea11(entity this) { set_animofs(this, anim_player_deatha1, 11, player_diea11); PlayerDead(this); }
void player_diea10(entity this) { set_animofs(this, anim_player_deatha1, 10, player_diea11); }
void player_diea9(entity this) { set_animofs(this, anim_player_deatha1, 9, player_diea10); }
void player_diea8(entity this) { set_animofs(this, anim_player_deatha1, 8, player_diea9); }
void player_diea7(entity this) { set_animofs(this, anim_player_deatha1, 7, player_diea8); }
void player_diea6(entity this) { set_animofs(this, anim_player_deatha1, 6, player_diea7); }
void player_diea5(entity this) { set_animofs(this, anim_player_deatha1, 5, player_diea6); }
void player_diea4(entity this) { set_animofs(this, anim_player_deatha1, 4, player_diea5); }
void player_diea3(entity this) { set_animofs(this, anim_player_deatha1, 3, player_diea4); }
void player_diea2(entity this) { set_animofs(this, anim_player_deatha1, 2, player_diea3); }
void player_diea1(entity this) { set_animofs(this, anim_player_deatha1, 1, player_diea2); }

void player_dieb9(entity this) { set_animofs(this, anim_player_deathb1, 9, player_dieb9); PlayerDead(this); }
void player_dieb8(entity this) { set_animofs(this, anim_player_deathb1, 8, player_dieb9); }
void player_dieb7(entity this) { set_animofs(this, anim_player_deathb1, 7, player_dieb8); }
void player_dieb6(entity this) { set_animofs(this, anim_player_deathb1, 6, player_dieb7); }
void player_dieb5(entity this) { set_animofs(this, anim_player_deathb1, 5, player_dieb6); }
void player_dieb4(entity this) { set_animofs(this, anim_player_deathb1, 4, player_dieb5); }
void player_dieb3(entity this) { set_animofs(this, anim_player_deathb1, 3, player_dieb4); }
void player_dieb2(entity this) { set_animofs(this, anim_player_deathb1, 2, player_dieb3); }
void player_dieb1(entity this) { set_animofs(this, anim_player_deathb1, 1, player_dieb2); }

void player_diec15(entity this) { set_animofs(this, anim_player_deathc1, 15, player_diec15); PlayerDead(this); }
void player_diec14(entity this) { set_animofs(this, anim_player_deathc1, 14, player_diec15); }
void player_diec13(entity this) { set_animofs(this, anim_player_deathc1, 13, player_diec14); }
void player_diec12(entity this) { set_animofs(this, anim_player_deathc1, 12, player_diec13); }
void player_diec11(entity this) { set_animofs(this, anim_player_deathc1, 11, player_diec12); }
void player_diec10(entity this) { set_animofs(this, anim_player_deathc1, 10, player_diec11); }
void player_diec9(entity this) { set_animofs(this, anim_player_deathc1, 9, player_diec10); }
void player_diec8(entity this) { set_animofs(this, anim_player_deathc1, 8, player_diec9); }
void player_diec7(entity this) { set_animofs(this, anim_player_deathc1, 7, player_diec8); }
void player_diec6(entity this) { set_animofs(this, anim_player_deathc1, 6, player_diec7); }
void player_diec5(entity this) { set_animofs(this, anim_player_deathc1, 5, player_diec6); }
void player_diec4(entity this) { set_animofs(this, anim_player_deathc1, 4, player_diec5); }
void player_diec3(entity this) { set_animofs(this, anim_player_deathc1, 3, player_diec4); }
void player_diec2(entity this) { set_animofs(this, anim_player_deathc1, 2, player_diec3); }
void player_diec1(entity this) { set_animofs(this, anim_player_deathc1, 1, player_diec2); }

void player_died9(entity this) { set_animofs(this, anim_player_deathd1, 9, player_died9); PlayerDead(this); }
void player_died8(entity this) { set_animofs(this, anim_player_deathd1, 8, player_died9); }
void player_died7(entity this) { set_animofs(this, anim_player_deathd1, 7, player_died8); }
void player_died6(entity this) { set_animofs(this, anim_player_deathd1, 6, player_died7); }
void player_died5(entity this) { set_animofs(this, anim_player_deathd1, 5, player_died6); }
void player_died4(entity this) { set_animofs(this, anim_player_deathd1, 4, player_died5); }
void player_died3(entity this) { set_animofs(this, anim_player_deathd1, 3, player_died4); }
void player_died2(entity this) { set_animofs(this, anim_player_deathd1, 2, player_died3); }
void player_died1(entity this) { set_animofs(this, anim_player_deathd1, 1, player_died2); }

void player_diee9(entity this) { set_animofs(this, anim_player_deathe1, 9, player_diee9); PlayerDead(this); }
void player_diee8(entity this) { set_animofs(this, anim_player_deathe1, 8, player_diee9); }
void player_diee7(entity this) { set_animofs(this, anim_player_deathe1, 7, player_diee8); }
void player_diee6(entity this) { set_animofs(this, anim_player_deathe1, 6, player_diee7); }
void player_diee5(entity this) { set_animofs(this, anim_player_deathe1, 5, player_diee6); }
void player_diee4(entity this) { set_animofs(this, anim_player_deathe1, 4, player_diee5); }
void player_diee3(entity this) { set_animofs(this, anim_player_deathe1, 3, player_diee4); }
void player_diee2(entity this) { set_animofs(this, anim_player_deathe1, 2, player_diee3); }
void player_diee1(entity this) { set_animofs(this, anim_player_deathe1, 1, player_diee2); }

void player_die_ax9(entity this) { set_animofs(this, anim_player_axdeth1, 9, player_die_ax9); PlayerDead(this); }
void player_die_ax8(entity this) { set_animofs(this, anim_player_axdeth1, 8, player_die_ax9); }
void player_die_ax7(entity this) { set_animofs(this, anim_player_axdeth1, 7, player_die_ax8); }
void player_die_ax6(entity this) { set_animofs(this, anim_player_axdeth1, 6, player_die_ax7); }
void player_die_ax5(entity this) { set_animofs(this, anim_player_axdeth1, 5, player_die_ax6); }
void player_die_ax4(entity this) { set_animofs(this, anim_player_axdeth1, 4, player_die_ax5); }
void player_die_ax3(entity this) { set_animofs(this, anim_player_axdeth1, 3, player_die_ax4); }
void player_die_ax2(entity this) { set_animofs(this, anim_player_axdeth1, 2, player_die_ax3); }
void player_die_ax1(entity this) { set_animofs(this, anim_player_axdeth1, 1, player_die_ax2); }

// hipnotic animations
void player_die_ham8(entity this) { set_anim(this, 31, player_die_ham8); PlayerDead(this); }
void player_die_ham7(entity this) { set_anim(this, 30, player_die_ham8); }
void player_die_ham6(entity this) { set_anim(this, 29, player_die_ham7); }
void player_die_ham5(entity this) { set_anim(this, 28, player_die_ham6); }
void player_die_ham4(entity this) { set_anim(this, 27, player_die_ham5); }
void player_die_ham3(entity this) { set_anim(this, 26, player_die_ham4); }
void player_die_ham2(entity this) { set_anim(this, 25, player_die_ham3); }
void player_die_ham1(entity this) { set_anim(this, 24, player_die_ham2); }

void shield_spawn(entity shieldOwner, vector dir);

bool TeamArmorDam(entity targ, entity inflictor, entity attacker, float damage);
void player_touch(entity this, entity toucher) 
{
	if(this.powerups & POWERUP_SHIELD)
	{
		if(IS_PLAYER(toucher))
		{
			makevectors(this.angles);
			vector vec = normalize(toucher.origin - this.origin);
			float dot = vec * v_forward;
        	if(dot < 0.3)
				return;
				
			makevectors(this.angles);
		    toucher.velocity = v_forward * 500;
			toucher.velocity_z = 250;
	
			bool doDamage = false;		
			if(TeamArmorDam(toucher, this, this, 15))
			{
				if(this.shield_death_time < time)
					doDamage = true;
			}

			// if shield has timed out, respawn it.
			// don't do particles more than twice a second. 
			if(this.shield_death_time < time)
			{
    	        _sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_NORM);
	
				te_explosion2(toucher.origin, 230, 5);

				shield_spawn(this, v_forward);
			}

			if(doDamage)
				T_Damage(toucher, this.shield_entity, this.shield_entity, 15);

//			this.shield_death_time = time + 0.5;
		}
	}
}

