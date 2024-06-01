#ifdef SVQC

const int anim_pend_frame1 = 0;
const int anim_pend_frame2 = 1;
const int anim_pend_frame3 = 2;
const int anim_pend_frame4 = 3;
const int anim_pend_frame5 = 4;
const int anim_pend_frame6 = 5;
const int anim_pend_frame7 = 6;

const int anim_pend_frame8 = 7;
const int anim_pend_frame9 = 8;
const int anim_pend_frame10 = 9;
const int anim_pend_frame11 = 10;
const int anim_pend_frame12 = 11;
const int anim_pend_frame13 = 12;

.float impactVelocity;

//float pend_frame;

const int PEND_X = BIT(0);
const int PEND_Y = BIT(1);
const int PEND_Z = BIT(2);
const int PEND_TRG = BIT(3);

/*
void() pend_stand  =[ $frame4, pend_stand ] {}
*/
void pend_swing1(entity this);
void pend_swing26(entity this)
{
	set_anim(this, anim_pend_frame1, pend_swing1);

//	pend_frame = pend_frame + 1;
//	0 -148 -88 (center)	W 56, H 80  (28,40)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -176 48', '8 -120 128');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-176 -8 48', '-120 8 128');
	this.nextthink = time + 0.17;
}
void pend_swing25(entity this)
{
	set_anim(this, anim_pend_frame2, pend_swing26);

//	pend_frame = pend_frame + 1;
//	0 -142 -50 (center)	W 60, H 76  (30, 38)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -172 12', '8 -112 88');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-172 -8 12', '-112 8 88');
	this.nextthink = time + 0.15;
}
void pend_swing24(entity this)
{
	set_anim(this, anim_pend_frame3, pend_swing25);

//	pend_frame = pend_frame + 1;
//	0 -128 -14 (center)	W 64, H 72  (32, 36)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -160 -22', '8 -96 50');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-160 -8 -22', '-96 8 50');
	this.nextthink = time + 0.13;
}
void pend_swing23(entity this)
{
	set_anim(this, anim_pend_frame4, pend_swing24);

//	pend_frame = pend_frame + 1;
//	0 -104 17 (center)		W 68, H 68  (34, 34)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -172 -51', '8 -70 17');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-172 -8 -51', '-70 8 17');
	this.nextthink = time + 0.11;
}
void pend_swing22(entity this)
{
	set_anim(this, anim_pend_frame5, pend_swing23);

//	pend_frame = pend_frame + 1;
//	0 -74 40 (center)		W 72, H 64  (36, 32)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -110 -72', '8 -28 -8');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-110 -8 -72', '-28 8 -8');
	this.nextthink = time + 0.09;
}
void pend_swing21(entity this)
{
	set_anim(this, anim_pend_frame6, pend_swing22);

//	pend_frame = pend_frame + 1;
//	0 -38 53 (center)		W 76, H 60  (38, 30)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -76 -83', '8 0 -23');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-76 -8 -83', '0 8 -23');
	this.nextthink = time + 0.07;
}
void pend_swing20(entity this)
{
	set_anim(this, anim_pend_frame7, pend_swing21);

//	pend_frame = pend_frame + 1;
//	0 0 60 (center)		W 80, H 56  (40, 28)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -40 -88', '8 40 -32');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-40 -8 -88', '40 8 -32');
	this.nextthink = time + 0.05;
}
void pend_swing19(entity this)
{
	set_anim(this, anim_pend_frame8, pend_swing20);

//	pend_frame = pend_frame + 1;
//	0 38 53 (center)		W 76, H 60  (38, 30)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 0 -83', '8 76 -23');
	else if(this.spawnflags & PEND_X )
		setsize(this, '0 -8 -83', '76 8 -23');
	this.nextthink = time + 0.07;
}
void pend_swing18(entity this)
{
	set_anim(this, anim_pend_frame9, pend_swing19);

//	pend_frame = pend_frame + 1;
//	0 74 40 (center)		W 72, H 64  (36, 32)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 38 -72', '8 100 -8');
	else if(this.spawnflags & PEND_X )
		setsize(this, '38 -8 -72', '100 8 -8');
	this.nextthink = time + 0.09;
}
void pend_swing17(entity this)
{
	set_anim(this, anim_pend_frame10, pend_swing18);

	_sound(this, CH_TRIGGER, "pendulum/swing.wav", 0.5, ATTN_NORM);

//	pend_frame = pend_frame + 1;
//	0 104 17 (center)		W 68, H 68  (34, 34)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 70 -51', '8 138 17');
	else if(this.spawnflags & PEND_X )
		setsize(this, '70 -8 -51', '138 8 17');
	this.nextthink = time + 0.11;
}
void pend_swing16(entity this)
{
	set_anim(this, anim_pend_frame11, pend_swing17);

//	pend_frame = pend_frame + 1;
//	0 128 -14 (center)		W 64, H 72  (32, 36)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 96 -22', '8 160 50');
	else if(this.spawnflags & PEND_X )
		setsize(this, '96 -8 -22', '160 8 50');
	this.nextthink = time + 0.13;
}
void pend_swing15(entity this)
{
	set_anim(this, anim_pend_frame12, pend_swing16);

//	pend_frame = pend_frame + 1;
//	0 142 -50 (center)		W 60, H 76 (30, 38)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 112 12', '8 172 88');
	else if(this.spawnflags & PEND_X )
		setsize(this, '112 -8 12', '172 8 88');
	this.nextthink = time + 0.15;
	this.impactVelocity = -1;
}
void pend_swing14(entity this)
{
	set_anim(this, anim_pend_frame13, pend_swing15);

//	pend_frame = pend_frame + 1;
	// same frame, same location. no change to bbox.
	this.nextthink = time + 0.17;
}
void pend_swing13(entity this)
{
	set_anim(this, anim_pend_frame13, pend_swing14);

//	pend_frame = pend_frame + 1;
//	0 148 -88 (center)		W 56, H 80 (28, 40)		
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 120 48', '8 176 128');
	else if(this.spawnflags & PEND_X )
		setsize(this, '120 -8 48', '176 8 128');
	this.nextthink = time + 0.17;
}
void pend_swing12(entity this)
{
	set_anim(this, anim_pend_frame12, pend_swing13);

//	pend_frame = pend_frame + 1;
//	0 142 -50 (center)		W 60, H 76 (30, 38)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 112 12', '8 172 88');
	else if(this.spawnflags & PEND_X )
		setsize(this, '112 -8 12', '172 8 88');
	this.nextthink = time + 0.15;
}
void pend_swing11(entity this)
{
	set_anim(this, anim_pend_frame11, pend_swing12);

//	pend_frame = pend_frame + 1;
//	0 128 -14 (center)		W 64, H 72  (32, 36)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 96 -22', '8 160 50');
	else if(this.spawnflags & PEND_X )
		setsize(this, '96 -8 -22', '160 8 50');
	this.nextthink = time + 0.13;
}
void pend_swing10(entity this)
{
	set_anim(this, anim_pend_frame10, pend_swing11);

//	pend_frame = pend_frame + 1;
//	0 104 17 (center)		W 68, H 68  (34, 34)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 70 -51', '8 138 17');
	else if(this.spawnflags & PEND_X )
		setsize(this, '70 -8 -51', '138 8 17');
	this.nextthink = time + 0.11;
}
void pend_swing9(entity this)
{
	set_anim(this, anim_pend_frame9, pend_swing10);

//	pend_frame = pend_frame + 1;
//	0 74 40 (center)		W 72, H 64  (36, 32)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 38 -72', '8 100 -8');
	else if(this.spawnflags & PEND_X )
		setsize(this, '38 -8 -72', '100 8 -8');
	this.nextthink = time + 0.09;
}
void pend_swing8(entity this)
{
	set_anim(this, anim_pend_frame8, pend_swing9);

//	pend_frame = pend_frame + 1;
//	0 38 53 (center)		W 76, H 60  (38, 30)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 0 -83', '8 76 -23');
	else if(this.spawnflags & PEND_X )
		setsize(this, '0 -8 -83', '76 8 -23');
	this.nextthink = time + 0.07;
}
void pend_swing7(entity this)
{
	set_anim(this, anim_pend_frame7, pend_swing8);

//	pend_frame = pend_frame + 1;
//	0 0 60 (center)		W 80, H 56  (40, 28)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -40 -88', '8 40 -32');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-40 -8 -88', '40 8 -32');
	this.nextthink = time + 0.05;
}
void pend_swing6(entity this)
{
	set_anim(this, anim_pend_frame6, pend_swing7);

//	pend_frame = pend_frame + 1;
//	0 -38 53 (center)		W 76, H 60  (38, 30)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -76 -83', '8 0 -23');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-76 -8 -83', '0 8 -23');
	this.nextthink = time + 0.07;
}
void pend_swing5(entity this)
{
	set_anim(this, anim_pend_frame5, pend_swing6);

//	pend_frame = pend_frame + 1;
//	0 -74 40 (center)		W 72, H 64  (36, 32)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -110 -72', '8 -38 -8');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-110 -8 -72', '-38 8 -8');
	this.nextthink = time + 0.09;
}
void pend_swing4(entity this)
{
	set_anim(this, anim_pend_frame4, pend_swing5);

	_sound(this, CH_TRIGGER, "pendulum/swing.wav", 0.5, ATTN_NORM);

////	pend_frame = pend_frame + 1;
//	0 -104 -17 (center)		W 68, H 68  (34, 34)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -138 -51', '8 -70 17');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-138 -8 -51', '-70 8 17');
	this.nextthink = time + 0.11;
}
void pend_swing3(entity this)
{
	set_anim(this, anim_pend_frame3, pend_swing4);

////	pend_frame = pend_frame + 1;
//	0 -128 14 (center)	W 64, H 72  (32, 36)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -160 -22', '8 -96 50');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-160 -8 -22', '-96 8 50');
	this.nextthink = time + 0.13;
}
void pend_swing2(entity this)
{
	set_anim(this, anim_pend_frame2, pend_swing3);

////	pend_frame = pend_frame + 1;
//	0 -142 50 (center)	W 60, H 76  (30, 38)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -172 12', '8 -112 88');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-172 -8 12', '-112 8 88');
	this.nextthink = time + 0.15;
}
void pend_swing1(entity this)
{
	set_anim(this, anim_pend_frame1, pend_swing2);

////	pend_frame = 1;
//	0 -148 88 (center)	W 56, H 80  (28,40)
	if(this.spawnflags & PEND_Y)
		setsize(this, '-8 -176 48', '8 -120 128');
	else if(this.spawnflags & PEND_X )
		setsize(this, '-176 -8 48', '-120 8 128');
	this.nextthink = time + 0.17;
	this.impactVelocity = 1;
}

void pend_touch(entity this, entity toucher)
{
	if(toucher.health < 1 || toucher.takedamage == DAMAGE_NO)
		return;

	if(this.attack_finished < time)
	{
		_sound(this, CH_VOICE, "pendulum/hit.wav", 1, ATTN_NORM);
		this.attack_finished = time + 1;
	}
	
	T_Damage(toucher, this, this, this.currentammo, DEATH_TRAP.m_id);

	// Fling the impactee in the direction the blade was swinging.	
	if(this.spawnflags & PEND_Y)
	{
//		toucher.velocity_y = toucher.velocity_y - this.impactVelocity * 250;
		toucher.velocity_y = this.impactVelocity * -250;
	}
	else if(this.spawnflags & PEND_X)
	{
//		toucher.velocity_x = toucher.velocity_x + this.impactVelocity * 250;
		toucher.velocity_x = this.impactVelocity * 250;
	}
	
	// Fling the impactee up a little bit.
//	toucher.velocity_z = toucher.velocity_z + 200;
	toucher.velocity_z = 200;
	
	SpawnMeatSpray(this, toucher.origin, toucher.velocity);
}

void pend_use(entity this, entity actor, entity trigger)
{
	this.nextthink = time + this.delay;
	setthink(this, pend_swing1);
}


/*QUAKED pendulum (0 .5 .8) (-8 -24 -100) (8 24 100) PEND_X PEND_Y PEND_TRG
The Pendulum

Values:
delay - amount of time (in seconds) before starting swinging. default 1.
currentammo - amount of damage for each contact. default 5.

Directional Flags: Pendulum swings perpendicular to it's angle. (eg. A pendulum facing east will swing north/south).

Default: PEND_Y

The pendulum angle is set automatically depending on the PEND_ choice.

PEND_X - a pendulum hanging from the ceiling swinging parallel to the X axis. 
PEND_Y - a pendulum hanging from the ceiling swinging parallel to the Y axis.

PEND_TRG - the pendulum must be triggered to start swinging. The delay value still affects the pendulum.
*/
spawnfunc(pendulum)
{
	if(!MP_ROGUE) { delete(this); return; }
	
	precache_model ("progs/pendulum.mdl");
	precache_sound ("pendulum/swing.wav");
	precache_sound ("pendulum/hit.wav");

	_setmodel(this, "progs/pendulum.mdl");
	
	if(!this.spawnflags)
		this.spawnflags |= PEND_Y;
		
	if(this.spawnflags & PEND_Y)
	{
		setsize (this, '-8 -24 -100', '8 24 100');
		this.angles = '0 0 0';
		this.v_angle = '0 0 0';
//		if(this.angles_y != 0 )
//			this.angles_y = 0;
	}
	else if(this.spawnflags & PEND_X )
	{
		setsize (this, '-24 -8 -100', '24 8 100');
		this.angles = '0 270 0';
		this.v_angle = '0 270 0';
//		if(this.angles_y != 270 )
//			this.angles_y = 270;
	}
	else	
		LOG_FATAL("ERROR: Unimplemented Pendulum Type (pendulum.qc)");	

	if(!this.currentammo)
		this.currentammo = 5;
	if(!this.delay)
		this.delay = 1;
		
	this.impactVelocity = 0;
	this.solid = SOLID_TRIGGER;
	this.takedamage = DAMAGE_NO;
	settouch(this, pend_touch);
	
	if(this.spawnflags & PEND_TRG)
		this.use = pend_use;
	else
	{	
		this.nextthink = time + this.delay;
		setthink(this, pend_swing1);
	}
}

#endif
