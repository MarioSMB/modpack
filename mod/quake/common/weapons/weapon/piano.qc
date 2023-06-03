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
	precache_model("progs/piano_musicnote_brown.mdl");
}

void player_woodpiano_E20(entity this) { set_anim(this, 16, player_run); this.weaponentity.m_frame = 0; }
void player_woodpiano_E19(entity this) { set_anim(this, 15, player_woodpiano_E20); this.weaponentity.m_frame = 68; }
void player_woodpiano_E18(entity this) { set_anim(this, 14, player_woodpiano_E19); this.weaponentity.m_frame = 67; }
void player_woodpiano_E17(entity this) { set_anim(this, 13, player_woodpiano_E18); this.weaponentity.m_frame = 66; }
void player_woodpiano_E16(entity this) { set_anim(this, 12, player_woodpiano_E17); this.weaponentity.m_frame = 65; }
void player_woodpiano_E15(entity this) { set_anim(this, 16, player_woodpiano_E16); this.weaponentity.m_frame = 64; _sound(this, CH_WEAPON_A, "weapons/piano_chord11.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E14(entity this) { set_anim(this, 15, player_woodpiano_E15); this.weaponentity.m_frame = 63; _sound(this, CH_WEAPON_A, "weapons/piano_chord10.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E13(entity this) { set_anim(this, 14, player_woodpiano_E14); this.weaponentity.m_frame = 62; _sound(this, CH_WEAPON_A, "weapons/piano_chord9.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E12(entity this) { set_anim(this, 13, player_woodpiano_E13); this.weaponentity.m_frame = 61; _sound(this, CH_WEAPON_A, "weapons/piano_chord8.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E11(entity this) { set_anim(this, 12, player_woodpiano_E12); this.weaponentity.m_frame = 60; _sound(this, CH_WEAPON_A, "weapons/piano_chord7.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E10(entity this) { set_anim(this, 16, player_woodpiano_E11); this.weaponentity.m_frame = 59; _sound(this, CH_WEAPON_A, "weapons/piano_chord6.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E9(entity this) { set_anim(this, 15, player_woodpiano_E10); this.weaponentity.m_frame = 58; _sound(this, CH_WEAPON_A, "weapons/piano_chord5.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E8(entity this) { set_anim(this, 14, player_woodpiano_E9); this.weaponentity.m_frame = 57; _sound(this, CH_WEAPON_A, "weapons/piano_chord4.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E7(entity this) { set_anim(this, 13, player_woodpiano_E8); this.weaponentity.m_frame = 56; _sound(this, CH_WEAPON_A, "weapons/piano_chord3.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E6(entity this) { set_anim(this, 12, player_woodpiano_E7); this.weaponentity.m_frame = 55; _sound(this, CH_WEAPON_A, "weapons/piano_chord2.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E5(entity this) { set_anim(this, 16, player_woodpiano_E6); this.weaponentity.m_frame = 54; _sound(this, CH_WEAPON_A, "weapons/piano_chord1.wav", 0.3, ATTN_NORM); }
void player_woodpiano_E4(entity this) { set_anim(this, 15, player_woodpiano_E5); this.weaponentity.m_frame = 53; }
void player_woodpiano_E3(entity this) { set_anim(this, 14, player_woodpiano_E4); this.weaponentity.m_frame = 52; }
void player_woodpiano_E2(entity this) { set_anim(this, 13, player_woodpiano_E3); this.weaponentity.m_frame = 51; }
void player_woodpiano_E1(entity this) { set_anim(this, 12, player_woodpiano_E2); this.weaponentity.m_frame = 0; }

// Assume player is NOT holding down Button0 for player_chains *except for endings which play automatically

/* KEY CHORD 12 ----------------------[] */
void player_woodpiano_key12_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 48; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} // Let Go Reset // Hotswap // Holding = Play Next Random
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayleft); } 	// If LEFT, play RIGHT side 	// If RIGHT, play LEFT side
void player_woodpiano_key12_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 47; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key12_4); }
void player_woodpiano_key12_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 46; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key12_3); }
void player_woodpiano_key12_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 45; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key12_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 11 --------------------[]-- */     
void player_woodpiano_key11_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 44; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;}
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayleft); } 	
void player_woodpiano_key11_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 43; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key11_4); }
void player_woodpiano_key11_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 42; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key11_3); }
void player_woodpiano_key11_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 41; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key11_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 10 ------------------[]---- */     
void player_woodpiano_key10_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 40; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;}
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayleft); } 	
void player_woodpiano_key10_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 39; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key10_4); }
void player_woodpiano_key10_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 38; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key10_3); }
void player_woodpiano_key10_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 37; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key10_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 9  ----------------[]------ */     
void player_woodpiano_key9_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 36; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} 
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayleft); } 	
void player_woodpiano_key9_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 35; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key9_4); }
void player_woodpiano_key9_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 34; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key9_3); }
void player_woodpiano_key9_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 33; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key9_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 8  --------------[]-------- */
void player_woodpiano_key8_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 32; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} 
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayleft); } 	
void player_woodpiano_key8_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 31; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key8_4); }
void player_woodpiano_key8_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 30; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key8_3); }
void player_woodpiano_key8_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 29; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key8_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 7  ------------[]---------- */     
void player_woodpiano_key7_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 28; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} 
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayleft); } 	
void player_woodpiano_key7_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 27; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key7_4); }
void player_woodpiano_key7_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 26; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key7_3); }
void player_woodpiano_key7_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 25; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key7_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 6  ----------[]------------ */     
void player_woodpiano_key6_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 24; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} // Let Go Reset // Hotswap // Holding = Play Next Random
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayright); } 	// If LEFT, play RIGHT side 	// If RIGHT, play LEFT side
void player_woodpiano_key6_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 23; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key6_4); }
void player_woodpiano_key6_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 22; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key6_3); }
void player_woodpiano_key6_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 21; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key6_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 5  --------[]-------------- */     
void player_woodpiano_key5_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 20; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} 
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayright); } 	
void player_woodpiano_key5_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 19; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key5_4); }
void player_woodpiano_key5_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 18; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key5_3); }
void player_woodpiano_key5_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 17; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key5_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 4  ------[]---------------- */
void player_woodpiano_key4_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 16; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} 
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayright); } 	
void player_woodpiano_key4_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 15; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key4_4); }
void player_woodpiano_key4_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 14; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key4_3); }
void player_woodpiano_key4_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 13; this.nextthink = time + 0.02; setthink(this, player_woodpiano_key4_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 3  ----[]------------------ */
void player_woodpiano_key3_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 12; if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} 
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayright); } 	
void player_woodpiano_key3_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 11; this.nextthink = time + 0.06; setthink(this, player_woodpiano_key3_4); }
void player_woodpiano_key3_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 10; this.nextthink = time + 0.04; setthink(this, player_woodpiano_key3_3); }
void player_woodpiano_key3_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 9;  this.nextthink = time + 0.02; setthink(this, player_woodpiano_key3_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 2  --[]-------------------- */
void player_woodpiano_key2_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 8;  if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} 
                                                                           this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayright); } 	
void player_woodpiano_key2_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 7;  this.nextthink = time + 0.06; setthink(this, player_woodpiano_key2_4); }
void player_woodpiano_key2_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 6;  this.nextthink = time + 0.04; setthink(this, player_woodpiano_key2_3); }
void player_woodpiano_key2_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 5;  this.nextthink = time + 0.02; setthink(this, player_woodpiano_key2_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }
/* KEY CHORD 1  []---------------------- */
void player_woodpiano_key1_4(entity this) { this.frame = 105; this.weaponentity.m_frame = 4;  if(!this.button0) {this.weaponentity.m_frame= 0; player_run(this); return; } if(this.impulse) {this.attack_finished= time + 0; player_run(this); return;} 
                                                                         this.nextthink = time + 0.03; setthink(this, player_woodpiano_randomplayright); } 	
void player_woodpiano_key1_3(entity this) { this.frame = 106; this.weaponentity.m_frame = 3;  this.nextthink = time + 0.06; setthink(this, player_woodpiano_key1_4); }
void player_woodpiano_key1_2(entity this) { this.frame = 113; this.weaponentity.m_frame = 2;  this.nextthink = time + 0.04; setthink(this, player_woodpiano_key1_3); }
void player_woodpiano_key1_1(entity this) { this.frame = 103; this.weaponentity.m_frame = 1;  this.nextthink = time + 0.02; setthink(this, player_woodpiano_key1_2); this.attack_finished= time + 0.3; SuperDamageSound(this); W_FireWoodPiano(this); }

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

void x_cartoonburst4(entity this) { this.frame = 6; this.nextthink = time + 0.025; setthink(this, SUB_Remove); }
void x_cartoonburst3(entity this) { this.frame = 4; this.nextthink = time + 0.025; setthink(this, x_cartoonburst4); }
void x_cartoonburst2(entity this) { this.frame = 2; this.nextthink = time + 0.025; setthink(this, x_cartoonburst3); }
void x_cartoonburst1(entity this) { this.frame = 0; this.nextthink = time + 0.025; setthink(this, x_cartoonburst2); }

void Become_Burst_6Sided_BrightPurple_Explosion(entity this) // ( Bright Brown / Purple ) --------------------------------------------
{
	set_movetype(this, MOVETYPE_NONE);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/x9_burst_6sided_brightpurple.mdl");
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	x_cartoonburst1(this);
}

void Become_Burst_6Sided_BrightYellow_Explosion(entity this) // ( Bright Yellow ) --------------------------------------------
{
	set_movetype(this, MOVETYPE_NONE);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/x9_burst_6sided_brightyellow.mdl");
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	x_cartoonburst1(this);
}

void Become_Burst_6Sided_Brown_Explosion(entity this) // ( Brown ) --------------------------------------------
{
	set_movetype(this, MOVETYPE_NONE);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/x9_burst_6sided_brown.mdl");
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	x_cartoonburst1(this);
}

void MusicNoteTouch2(entity this, entity toucher) // MUSIC NOTE TOUCH ENEMY / WORLD ------------------------------------------------------------------------------
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}   
	
	if(toucher.takedamage) // if it bleeds...
	{
		//spawn_touchblood (1);
		T_Damage(toucher, this, this.owner, 18, WEP_PIANO.m_id); // DIRECT Damage

		Become_Burst_6Sided_BrightPurple_Explosion(this);
		
		return;         
	}
	
	if(this.velocity == '0 0 0') {this.avelocity = '0 0 0';} // Bounce?
}

void MusicNoteTouch(entity this, entity toucher) // MUSIC NOTE TOUCH ENEMY / WORLD ------------------------------------------------------------------------------
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}   
	
	if(toucher.takedamage) // if it bleeds...
	{
		//spawn_touchblood (1);
		T_Damage(toucher, this, this.owner, 27, WEP_PIANO.m_id); // DIRECT Damage

		Become_Burst_6Sided_BrightYellow_Explosion(this);
		return;         
	}
	
	if(this.velocity == '0 0 0') {this.avelocity = '0 0 0';} // Bounce?

	else
	{
		_setmodel(this, "progs/piano_musicnote_brown.mdl");
		setsize(this, '0 0 0', '0 0 0'); 
		settouch(this, MusicNoteTouch2);	
	}
}

void W_FireWoodPiano(entity this) // Fire Music Note + Play Audio Chord---------------------------------------------------
{
	// WHEN ONLY HAVE 1 NAIL AMMO LEFT...
	if(this.ammo_nails <= 1)
	{
		W_SwitchWeapon(this, w_getbestweapon(this));
		return;
	}
	this.ammo_nails -= 2;
	
	//this.punchangle_x = 1;

	entity musicnote = spawn();
	musicnote.owner = this;
	set_movetype(musicnote, MOVETYPE_BOUNCE);
	musicnote.solid = SOLID_BBOX;
	musicnote.classname = "grenade";
		
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
	setthink(musicnote, Become_Burst_6Sided_Brown_Explosion);		

	if(this.weaponentity.m_frame == 1 || this.weaponentity.m_frame == 5 || this.weaponentity.m_frame == 9 || this.weaponentity.m_frame == 13 || this.weaponentity.m_frame == 17 || this.weaponentity.m_frame == 21 ) // Left Side (Keys 1-6) 	(1,5,9,13,17,21) < 23
	{
		if(this.weaponentity.m_frame == 1  ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord1.wav", 1, ATTN_NORM);} // Frame 1, plays Animation Key 1, plays Aduio Chord 1 ...
		if(this.weaponentity.m_frame == 5  ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord2.wav", 1, ATTN_NORM);} 
		if(this.weaponentity.m_frame == 9  ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord3.wav", 1, ATTN_NORM);} 
		if(this.weaponentity.m_frame == 13 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord4.wav", 1, ATTN_NORM);} 
		if(this.weaponentity.m_frame == 17 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord5.wav", 1, ATTN_NORM);} 
		if(this.weaponentity.m_frame == 21 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord6.wav", 1, ATTN_NORM);} 
		
		_setmodel(musicnote, "progs/piano_musicnote_yellow.mdl"); 	
		musicnote.avelocity = '0  90 0'; // Roll
		musicnote.velocity = musicnote.velocity*1 + (v_right* 20) + (v_up* 1); // Don't add .Velocity* (it's already defined above!)
		
		setsize(musicnote, '0 0 0', '0 0 0');		
		setorigin(musicnote, this.origin + v_forward*12 + '0 0 -8' + v_right* -8); 
	}
			
	if(this.weaponentity.m_frame == 25 || this.weaponentity.m_frame == 29 || this.weaponentity.m_frame == 33 || this.weaponentity.m_frame == 37 || this.weaponentity.m_frame == 41 || this.weaponentity.m_frame == 45 )
	{
		if(this.weaponentity.m_frame == 25 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord7.wav", 1, ATTN_NORM);}
		if(this.weaponentity.m_frame == 29 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord8.wav", 1, ATTN_NORM);} 
		if(this.weaponentity.m_frame == 33 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord9.wav", 1, ATTN_NORM);} 
		if(this.weaponentity.m_frame == 37 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord10.wav", 1, ATTN_NORM);} 
		if(this.weaponentity.m_frame == 41 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord11.wav", 1, ATTN_NORM);} 
		if(this.weaponentity.m_frame == 45 ) {_sound(this, CH_WEAPON_A, "weapons/piano_chord12.wav", 1, ATTN_NORM);} 			
		
		_setmodel(musicnote, "progs/piano_musicnote_yellow.mdl"); 	
		musicnote.avelocity = '0 -90 0';
		musicnote.velocity = musicnote.velocity*1 + (v_right*  -20) + (v_up* 1);
					
		setsize(musicnote, '0 0 0', '0 0 0'); 	
		setorigin(musicnote, this.origin + v_forward*12 + '0 0 -8' + v_right* 8); 
	}
}

METHOD(Piano, wr_think, void(entity thiswep, entity actor, int fire))
{
	Weapon oldwep = actor.weaponentity.piano_prevwep;
	actor.weaponentity.piano_prevwep = actor.weaponentity.m_weapon;

	if(oldwep != WEP_PIANO) // only plays once!!
	{
		player_woodpiano_E1(actor);
		return;
	}

	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor))
	{
		if(random() < 0.5)
			player_woodpiano_randomplayleft(actor);
		else	
			player_woodpiano_randomplayright(actor);
	}
}
METHOD(Piano, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_nails >= 2;
	return ammo_amount;
}
METHOD(Piano, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
