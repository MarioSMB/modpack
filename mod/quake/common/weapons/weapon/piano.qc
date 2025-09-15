#include "piano.qh"

#ifdef SVQC
PRECACHE(Piano)
{
	precache_sound("weapons/piano_chord1.wav");
	precache_sound("weapons/piano_chord2.wav");
	precache_sound("weapons/piano_chord3.wav");
	precache_sound("weapons/piano_chord4.wav");
	precache_sound("weapons/piano_chord5.wav");
	precache_sound("weapons/piano_chord6.wav");
	precache_sound("weapons/piano_chord7.wav");
	precache_sound("weapons/piano_chord8.wav");
	precache_sound("weapons/piano_chord9.wav");
	precache_sound("weapons/piano_chord10.wav");
	precache_sound("weapons/piano_chord11.wav");
	precache_sound("weapons/piano_chord12.wav");
	precache_model("progs/x9_burst_6sided_brightyellow.mdl");
	precache_model("progs/x9_burst_6sided_brightpurple.mdl");
	precache_model("progs/x9_burst_6sided_brown.mdl");
	precache_model("progs/g_woodpiano.mdl");
	precache_model("progs/v_woodpiano.mdl");
	precache_model("progs/piano_musicnote_yellow.mdl");
	precache_model("progs/piano_musicnote_white.mdl");
	precache_model("progs/piano_musicnote_brown.mdl");
}

void wep_piano_woodpiano_E20(entity this) { wep_set_anim(this, 0, w_ready); }
void wep_piano_woodpiano_E19(entity this) { wep_set_anim(this, 68, wep_piano_woodpiano_E20); }
void wep_piano_woodpiano_E18(entity this) { wep_set_anim(this, 67, wep_piano_woodpiano_E19); }
void wep_piano_woodpiano_E17(entity this) { wep_set_anim(this, 66, wep_piano_woodpiano_E18); }
void wep_piano_woodpiano_E16(entity this) { wep_set_anim(this, 65, wep_piano_woodpiano_E17); }
void wep_piano_woodpiano_E15(entity this) { wep_set_anim(this, 64, wep_piano_woodpiano_E16); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord11.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E14(entity this) { wep_set_anim(this, 63, wep_piano_woodpiano_E15); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord10.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E13(entity this) { wep_set_anim(this, 62, wep_piano_woodpiano_E14); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord9.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E12(entity this) { wep_set_anim(this, 61, wep_piano_woodpiano_E13); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord8.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E11(entity this) { wep_set_anim(this, 60, wep_piano_woodpiano_E12); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord7.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E10(entity this) { wep_set_anim(this, 59, wep_piano_woodpiano_E11); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord6.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E9(entity this) { wep_set_anim(this, 58, wep_piano_woodpiano_E10); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord5.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E8(entity this) { wep_set_anim(this, 57, wep_piano_woodpiano_E9); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord4.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E7(entity this) { wep_set_anim(this, 56, wep_piano_woodpiano_E8); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord3.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E6(entity this) { wep_set_anim(this, 55, wep_piano_woodpiano_E7); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord2.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E5(entity this) { wep_set_anim(this, 54, wep_piano_woodpiano_E6); _sound(this.owner, CH_WEAPON_A, "weapons/piano_chord1.wav", 0.3, ATTN_NORM); }
void wep_piano_woodpiano_E4(entity this) { wep_set_anim(this, 53, wep_piano_woodpiano_E5); }
void wep_piano_woodpiano_E3(entity this) { wep_set_anim(this, 52, wep_piano_woodpiano_E4); }
void wep_piano_woodpiano_E2(entity this) { wep_set_anim(this, 51, wep_piano_woodpiano_E3); }
void wep_piano_woodpiano_E1(entity this) { wep_set_anim(this, 0, wep_piano_woodpiano_E2); }

// Assume player is NOT holding down Button0 for player_chains *except for endings which play automatically

bool piano_checkplayer(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(!actor.button0 || actor.impulse || actor.health < 1 || gameover || intermission_running)
	{
		if(actor.impulse) // TODO: probably don't need this check!
			ATTACK_FINISHED(actor, weaponentity) = time;
		w_ready(this);
		return true;
	}
	return false;
}

void player_piano4(entity this) { set_anim(this, 105, player_run); this.nextthink = time + 0.1; }
void player_piano3(entity this) { set_anim(this, 106, player_piano4); this.nextthink = time + 0.06; }
void player_piano2(entity this) { set_anim(this, 113, player_piano3); this.nextthink = time + 0.04; }
void player_piano1(entity this) { set_anim(this, 103, player_piano2); this.nextthink = time + 0.02; }

void player_pianoanim(entity this)
{
	if(IS_PLAYER(this))
		player_piano1(this);
}

/* KEY CHORD 12 ----------------------[] */
void player_woodpiano_key12_4(entity this) { this.m_frame = 48; if(piano_checkplayer(this)) return; // Let Go Reset // Hotswap // Holding = Play Next Random
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayleft; } 	// If LEFT, play RIGHT side 	// If RIGHT, play LEFT side
void player_woodpiano_key12_3(entity this) { this.m_frame = 47; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key12_4; }
void player_woodpiano_key12_2(entity this) { this.m_frame = 46; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key12_3; }
void player_woodpiano_key12_1(entity this) { player_pianoanim(this.owner); this.m_frame = 45; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key12_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 11 --------------------[]-- */     
void player_woodpiano_key11_4(entity this) { this.m_frame = 44; if(piano_checkplayer(this)) return;
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayleft; } 	
void player_woodpiano_key11_3(entity this) { this.m_frame = 43; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key11_4; }
void player_woodpiano_key11_2(entity this) { this.m_frame = 42; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key11_3; }
void player_woodpiano_key11_1(entity this) { player_pianoanim(this.owner); this.m_frame = 41; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key11_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 10 ------------------[]---- */     
void player_woodpiano_key10_4(entity this) { this.m_frame = 40; if(piano_checkplayer(this)) return;
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayleft; } 	
void player_woodpiano_key10_3(entity this) { this.m_frame = 39; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key10_4; }
void player_woodpiano_key10_2(entity this) { this.m_frame = 38; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key10_3; }
void player_woodpiano_key10_1(entity this) { player_pianoanim(this.owner); this.m_frame = 37; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key10_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 9  ----------------[]------ */     
void player_woodpiano_key9_4(entity this) { this.m_frame = 36; if(piano_checkplayer(this)) return; 
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayleft; } 	
void player_woodpiano_key9_3(entity this) { this.m_frame = 35; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key9_4; }
void player_woodpiano_key9_2(entity this) { this.m_frame = 34; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key9_3; }
void player_woodpiano_key9_1(entity this) { player_pianoanim(this.owner); this.m_frame = 33; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key9_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 8  --------------[]-------- */
void player_woodpiano_key8_4(entity this) { this.m_frame = 32; if(piano_checkplayer(this)) return; 
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayleft; } 	
void player_woodpiano_key8_3(entity this) { this.m_frame = 31; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key8_4; }
void player_woodpiano_key8_2(entity this) { this.m_frame = 30; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key8_3; }
void player_woodpiano_key8_1(entity this) { player_pianoanim(this.owner); this.m_frame = 29; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key8_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 7  ------------[]---------- */     
void player_woodpiano_key7_4(entity this) { this.m_frame = 28; if(piano_checkplayer(this)) return; 
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayleft; } 	
void player_woodpiano_key7_3(entity this) { this.m_frame = 27; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key7_4; }
void player_woodpiano_key7_2(entity this) { this.m_frame = 26; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key7_3; }
void player_woodpiano_key7_1(entity this) { player_pianoanim(this.owner); this.m_frame = 25; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key7_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 6  ----------[]------------ */     
void player_woodpiano_key6_4(entity this) { this.m_frame = 24; if(piano_checkplayer(this)) return; // Let Go Reset // Hotswap // Holding = Play Next Random
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayright; } 	// If LEFT, play RIGHT side 	// If RIGHT, play LEFT side
void player_woodpiano_key6_3(entity this) { this.m_frame = 23; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key6_4; }
void player_woodpiano_key6_2(entity this) { this.m_frame = 22; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key6_3; }
void player_woodpiano_key6_1(entity this) { player_pianoanim(this.owner); this.m_frame = 21; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key6_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 5  --------[]-------------- */     
void player_woodpiano_key5_4(entity this) { this.m_frame = 20; if(piano_checkplayer(this)) return; 
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayright; } 	
void player_woodpiano_key5_3(entity this) { this.m_frame = 19; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key5_4; }
void player_woodpiano_key5_2(entity this) { this.m_frame = 18; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key5_3; }
void player_woodpiano_key5_1(entity this) { player_pianoanim(this.owner); this.m_frame = 17; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key5_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 4  ------[]---------------- */
void player_woodpiano_key4_4(entity this) { this.m_frame = 16; if(piano_checkplayer(this)) return; 
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayright; } 	
void player_woodpiano_key4_3(entity this) { this.m_frame = 15; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key4_4; }
void player_woodpiano_key4_2(entity this) { this.m_frame = 14; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key4_3; }
void player_woodpiano_key4_1(entity this) { player_pianoanim(this.owner); this.m_frame = 13; this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key4_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 3  ----[]------------------ */
void player_woodpiano_key3_4(entity this) { this.m_frame = 12; if(piano_checkplayer(this)) return; 
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayright; } 	
void player_woodpiano_key3_3(entity this) { this.m_frame = 11; this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key3_4; }
void player_woodpiano_key3_2(entity this) { this.m_frame = 10; this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key3_3; }
void player_woodpiano_key3_1(entity this) { player_pianoanim(this.owner); this.m_frame = 9;  this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key3_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 2  --[]-------------------- */
void player_woodpiano_key2_4(entity this) { this.m_frame = 8;  if(piano_checkplayer(this)) return; 
                                                                           this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayright; } 	
void player_woodpiano_key2_3(entity this) { this.m_frame = 7;  this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key2_4; }
void player_woodpiano_key2_2(entity this) { this.m_frame = 6;  this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key2_3; }
void player_woodpiano_key2_1(entity this) { player_pianoanim(this.owner); this.m_frame = 5;  this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key2_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }
/* KEY CHORD 1  []---------------------- */
void player_woodpiano_key1_4(entity this) { this.m_frame = 4;  if(piano_checkplayer(this)) return; 
                                                                         this.weapon_nextthink = time + 0.03; this.weapon_think = player_woodpiano_randomplayright; } 	
void player_woodpiano_key1_3(entity this) { this.m_frame = 3;  this.weapon_nextthink = time + 0.06; this.weapon_think = player_woodpiano_key1_4; }
void player_woodpiano_key1_2(entity this) { this.m_frame = 2;  this.weapon_nextthink = time + 0.04; this.weapon_think = player_woodpiano_key1_3; }
void player_woodpiano_key1_1(entity this) { player_pianoanim(this.owner); this.m_frame = 1;  this.weapon_nextthink = time + 0.02; this.weapon_think = player_woodpiano_key1_2; ATTACK_FINISHED(this.owner, this.weaponentity_fld) = time + 0.3; SuperDamageSound(this.owner); W_FireWoodPiano(this.owner, this.weaponentity_fld); }

// If LEFT, play Random RIGHT side 	// If RIGHT, play Random LEFT side

void player_woodpiano_randomplayleft(entity this) // Keys 1 - 6 LEFT SIDE
{
	float r = random();
	
	if      ( r < 0.1666 )	{player_woodpiano_key1_1(this); }
	else if( r < 0.3333 )	{player_woodpiano_key2_1(this); }
	else if( r < 0.5    )	{player_woodpiano_key3_1(this); }
	else if( r < 0.6666 )	{player_woodpiano_key4_1(this); }
	else if( r < 0.8333 )	{player_woodpiano_key5_1(this); }
	else 			{player_woodpiano_key6_1(this); }
}

void player_woodpiano_randomplayright(entity this) // Keys 7 - 12 RIGHT SIDE
{
	float r = random();
	
	if      ( r < 0.1666 )	{player_woodpiano_key7_1(this); }
	else if( r < 0.3333 )	{player_woodpiano_key8_1(this); }
	else if( r < 0.5    )	{player_woodpiano_key9_1(this); }
	else if( r < 0.6666 )	{player_woodpiano_key10_1(this); }
	else if( r < 0.8333 )	{player_woodpiano_key11_1(this); }
	else 			{player_woodpiano_key12_1(this); }
}

void W_FireWoodPiano(entity this, .entity weaponentity) // Fire Music Note + Play Audio Chord---------------------------------------------------
{
	if(STAT(MANA, this) < 3)
	{
		w_ready(this.(weaponentity));
		return;
	}
	W_TakeMana(this, 3);
	
	//this.punchangle_x = 1;

	entity musicnote = spawn();
	musicnote.flags = FL_PROJECTILE;
	musicnote.projectiledeathtype = WEP_PIANO.m_id;
	musicnote.clipgroup = this.clipgroup;
	musicnote.owner = this;
	musicnote.dmg = 27;
	set_movetype(musicnote, MOVETYPE_BOUNCE);
	musicnote.solid = SOLID_BBOX;
	musicnote.classname = "grenade";
	musicnote.effects = EF_FULLBRIGHT;
		
	makevectors(this.v_angle);
	
	if(this.v_angle_x)
	{
		// Right aim toward center		// old Velocity = forward*600, up*300
		musicnote.velocity = (v_forward* 1400) + (v_up* 250);
	}
	else
	{
		musicnote.velocity = qc_aim(this, 1000);		
		//musicnote.velocity = musicnote.velocity * 700;		
		musicnote.velocity = musicnote.velocity * 1400;		
		musicnote.velocity_z = 0;
	}

	musicnote.angles = vectoangles(musicnote.velocity);
	settouch(musicnote, MusicNoteTouch);
	
	musicnote.nextthink = time + 2.5; // Remove/Explode Time
	//musicnote.think = SUB_Remove; 
	setthink(musicnote, BecomeCartoonExplosion);

	vector mycolor = '1 1 0';
	if(random() < 0.5)
	{
		mycolor.x = max(0.25, random() * 5);
		mycolor.y = max(0.25, random() * 5);
		mycolor.z = max(0.25, random() * 5);
	}

	bool dopitched = !autocvar_sv_quake_music_random;

	int wfrm = this.(weaponentity).m_frame;
	if(wfrm == 1 || wfrm == 5 || wfrm == 9 || wfrm == 13 || wfrm == 17 || wfrm == 21 ) // Left Side (Keys 1-6) 	(1,5,9,13,17,21) < 23
	{
		if(dopitched)
		{
			float r = W_Music_PitchFromAngles(this.v_angle_x, 2) * 0.75;
			sound7(this, CH_WEAPON_A, "weapons/piano_chord12.wav", 1, ATTN_NORM, r, 0);
		}
		else
		{
			if(wfrm == 1  ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord1.wav", 1, ATTN_NORM);} // Frame 1, plays Animation Key 1, plays Aduio Chord 1 ...
			if(wfrm == 5  ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord2.wav", 1, ATTN_NORM);} 
			if(wfrm == 9  ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord3.wav", 1, ATTN_NORM);} 
			if(wfrm == 13 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord4.wav", 1, ATTN_NORM);} 
			if(wfrm == 17 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord5.wav", 1, ATTN_NORM);} 
			if(wfrm == 21 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord6.wav", 1, ATTN_NORM);} 
		}

		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = mycolor;
		musicnote.avelocity = '0 90 0'; // Roll
		musicnote.velocity = musicnote.velocity*1 + (v_right* 20) + (v_up* 1); // Don't add .Velocity* (it's already defined above!)

		setsize(musicnote, '0 0 0', '0 0 0');
		setorigin(musicnote, W_Shotorg(this, weaponentity) + v_forward*12 + '0 0 -8' + v_right * -8); 
	}

	if(wfrm == 25 || wfrm == 29 || wfrm == 33 || wfrm == 37 || wfrm == 41 || wfrm == 45 )
	{
		if(dopitched)
		{
			float r = W_Music_PitchFromAngles(this.v_angle_x, 2) * 0.75;
			sound7(this, CH_WEAPON_A, "weapons/piano_chord12.wav", 1, ATTN_NORM, r, 0);
		}
		else
		{
			if(wfrm == 25 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord7.wav", 1, ATTN_NORM);}
			if(wfrm == 29 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord8.wav", 1, ATTN_NORM);}
			if(wfrm == 33 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord9.wav", 1, ATTN_NORM);}
			if(wfrm == 37 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord10.wav", 1, ATTN_NORM);}
			if(wfrm == 41 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord11.wav", 1, ATTN_NORM);}
			if(wfrm == 45 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord12.wav", 1, ATTN_NORM);}
		}

		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = mycolor;
		musicnote.avelocity = '0 -90 0';
		musicnote.velocity = musicnote.velocity*1 + (v_right*  -20) + (v_up* 1);

		setsize(musicnote, '0 0 0', '0 0 0'); 	
		setorigin(musicnote, W_Shotorg(this, weaponentity) + v_forward*12 + '0 0 -8' + v_right * 8); 
	}
}

METHOD(Piano, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	Weapon oldwep = actor.(weaponentity).piano_prevwep;
	actor.(weaponentity).piano_prevwep = actor.(weaponentity).m_weapon;

	if(oldwep != WEP_PIANO) // only plays once!!
	{
		wep_piano_woodpiano_E1(actor.(weaponentity));
		return;
	}

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 3)
	{
		if(random() < 0.5)
			player_woodpiano_randomplayleft(actor.(weaponentity));
		else	
			player_woodpiano_randomplayright(actor.(weaponentity));
	}
}
METHOD(Piano, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Piano, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Piano, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
