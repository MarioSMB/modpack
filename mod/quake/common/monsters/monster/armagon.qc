#include "armagon.qh"

#ifdef SVQC
#include "../../../server/triggers/func/exploder.qh"
#include "../../../server/triggers/func/rotate.qh"
#endif

#ifdef SVQC
const int anim_armagon_lwalk = 0; //'0 11 0';
const int anim_armagon_lw0fir = 12; //'12 24 0';
const int anim_armagon_lw1fir = 25; //'25 39 0';
const int anim_armagon_lw2fir = 40; //'40 51 0';
const int anim_armagon_lsfire = 52; //'52 63 0';
const int anim_armagon_lstand = 64; //'64 83 0';
const int anim_armagon_tranl = 84; //'84 85 0';
const int anim_armagon_ldie = 86; //'86 97 0';

const float ATTN_ARMAGON = 0.5;
const float SERVO_VOLUME = 0.5;

.entity attachment;

void armagon_launch_missile(entity this, float ofs, float turn)
{
	float dist;

	vector ang = this.angles;
	ang.y = ang.y + this.fixangle;
	if(turn == 1)
		ang.y = ang.y + 165;
	else if(turn == 2)
		ang.y = ang.y - 165;
	makevectors(ang);
	vector src = this.origin + '0 0 66' + v_right*ofs + v_forward*84;
	vector targ = this.enemy.origin + this.enemy.view_ofs;
	if(autocvar_skill != 0)
	{
		dist = vlen(targ - src);
		targ = targ + (this.enemy.velocity * (dist / 1000));
	}
	vector vec = (targ - src);
	vec = normalize(vec);
	dist = vec * v_forward;
	if(dist < this.worldtype)
		vec = v_forward;
	this.effects = this.effects | EF_MUZZLEFLASH;

	_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = new(missile);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = DEATH_MONSTER_ARMAGON.m_id;

// set missile speed
	missile.velocity = vec * 1000;
	missile.angles = vectoangles(vec);
	settouch(missile, T_MissileTouch);

// set missile duration
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, src);
}

void armagon_launch_laser(entity this, float ofs)
{
	float dist;

	vector ang = this.angles;
	ang.y = ang.y + this.fixangle;
	makevectors(ang);
	vector src = this.origin + '0 0 66' + v_right*ofs + v_forward*84;
	vector targ = this.enemy.origin + this.enemy.view_ofs;
	if(autocvar_skill!=0)
	{
		dist = vlen(targ-src);
		targ = targ + (this.enemy.velocity * (dist/1000));
	}
	vector vec = (targ - src);
	vec = normalize(vec);
	dist = vec * v_forward;
	if(dist < this.worldtype)
		vec = v_forward;
	this.effects = this.effects | EF_MUZZLEFLASH;

	entity newmis = HIP_LaunchLaser(this, src, vec, 0);
	newmis.projectiledeathtype = DEATH_MONSTER_ARMAGON.m_id;
}

void armagon_turn(entity this, float angdelta, float delta)
{
	if(fabs(angdelta) < 10)
		this.fixangle = delta;
	else
	{
		if(angdelta > 5)
			this.fixangle = this.fixangle + 9;
		else if(angdelta < -5)
			this.fixangle = this.fixangle - 9;
		else
			this.fixangle = delta;
	}
}
void armagon_overleft1(entity this);
void armagon_overright1(entity this);

void armagon_think(entity this)
{
	setorigin(this.attachment, this.origin);
	this.attachment.colormod = this.colormod;
	this.attachment.angles = this.angles;
	this.attachment.frame = this.frame;
	this.attachment.angles_y = this.attachment.angles_y + this.fixangle;
	this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
	this.ideal_yaw = this.enemy_yaw;
	float delta = this.ideal_yaw - this.angles_y;
	this.cnt = 0;
	if(delta > 180) delta = delta - 360;
	if(delta < -180) delta = delta + 360;
	if(fabs(delta) > 90)
	{
		delta = 0;
		this.cnt = 1;
	}
	float angdelta = delta-this.fixangle;
	armagon_turn(this, angdelta,delta);
//   this.nextthink = time + 0.1;
	if(this.health < 0)
		return;
	if(time > this.super_time)
	{
		this.super_time = time + 3;
		if(random() < 0.5)
		{
			float r = random();
			if(r < 0.25)
				_sound(this, CH_VOICE, "armagon/idle1.wav", 1, ATTN_ARMAGON);
			else if(r < 0.5)
				_sound(this, CH_VOICE, "armagon/idle2.wav", 1, ATTN_ARMAGON);
			else if(r < 0.75)
				_sound(this, CH_VOICE, "armagon/idle3.wav", 1, ATTN_ARMAGON);
			else
				_sound(this, CH_VOICE, "armagon/idle4.wav", 1, ATTN_ARMAGON);
		}
	}
}

void armagon_walkthink(entity this)
{
	setorigin(this.attachment, this.origin);
	this.attachment.angles = this.angles;
	this.attachment.colormod = this.colormod;
	this.attachment.frame = this.frame;
	this.attachment.angles_y = this.attachment.angles_y + this.fixangle;
	changeyaw(this);
	float delta = 0;
	this.cnt = 0;
	if(delta > 180) delta = delta - 360;
	if(delta < -180) delta = delta + 360;
	if(fabs(delta) > 90)
	{
		delta = 0;
		this.cnt = 1;
	}
	float angdelta = delta - this.fixangle;
	armagon_turn(this, angdelta, delta);
	if(this.health < 0)
		return;
	if(time > this.super_time)
	{
		this.super_time = time + 3;
		if(random() < 0.5)
		{
			float r = random();
			if(r < 0.25)
				_sound(this, CH_VOICE, "armagon/idle1.wav", 1, ATTN_ARMAGON);
			else if(r < 0.5)
				_sound(this, CH_VOICE, "armagon/idle2.wav", 1, ATTN_ARMAGON);
			else if(r < 0.75)
				_sound(this, CH_VOICE, "armagon/idle3.wav", 1, ATTN_ARMAGON);
			else
				_sound(this, CH_VOICE, "armagon/idle4.wav", 1, ATTN_ARMAGON);
		}
	}
	entity client = t_checkclient(this);
	if(!client)
		return;  // current check entity isn't in PVS
	if(visible(this, client))
	{
		this.enemy = client;
		FoundTarget(this);
	}
}

void armagon_overleft_think(entity this)
{
	float delta;
	float angdelta;

	changeyaw(this);
	t_walkmove(this, this.angles_y, 14);
	setorigin(this.attachment, this.origin);
	this.attachment.colormod = this.colormod;
	this.attachment.angles = this.angles;
	this.attachment.frame = this.frame;
	this.attachment.angles_y = this.attachment.angles_y + this.fixangle;
	if(this.count == 0)
	{
		this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
		this.ideal_yaw = this.enemy_yaw;
		delta = this.ideal_yaw - this.angles_y - 165;
		if(delta > 180) delta = delta - 360;
		if(delta < -180) delta = delta + 360;
		angdelta = delta-this.fixangle;
	}
	else if(this.count == 1)
	{
		armagon_launch_missile(this, 40,1);
		return;
	}
	else
	{
		delta = 0;
		angdelta = delta-this.fixangle;
	}
	armagon_turn(this, angdelta, delta);
//   this.nextthink = time + 0.1;
}

void armagon_overright_think(entity this)
{
	float delta, angdelta;

	changeyaw(this);
	t_walkmove(this, this.angles_y, 14);
	setorigin(this.attachment, this.origin);
	this.attachment.colormod = this.colormod;
	this.attachment.angles = this.angles;
	this.attachment.frame = this.frame;
	this.attachment.angles_y = this.attachment.angles_y + this.fixangle;
	if(this.count == 0)
	{
		this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
		this.ideal_yaw = this.enemy_yaw;
		delta = this.ideal_yaw - this.angles_y + 165;
		if(delta > 180) delta = delta - 360;
		if(delta < -180) delta = delta + 360;
		angdelta = delta - this.fixangle;
	}
	else if(this.count == 1)
	{
		armagon_launch_missile(this, -40, 2);
		return;
	}
	else
	{
		delta = 0;
		angdelta = delta - this.fixangle;
	}
	armagon_turn(this, angdelta,delta);
//   this.nextthink = time + 0.1;
}

void armagon_stand_attack(entity this);

.int arma_frame;
void armagon_stand(entity this)
{
	if(this.arma_frame >= 20)
		this.arma_frame = 0;

	set_animofs(this, anim_armagon_lstand, this.arma_frame + 1, armagon_stand);
	int frm = this.arma_frame + 1;
	if(frm == 1 || frm == 10 || frm == 20)
		ai_stand(this);

	armagon_think(this);
	this.nextthink = time + 0.2;

	this.arma_frame += 1;
}

void armagon_walk(entity this)
{
	if(this.arma_frame >= 12)
		this.arma_frame = 0;

	set_animofs(this, anim_armagon_lwalk, this.arma_frame + 1, armagon_walk);
	int frm = this.arma_frame + 1;
	if(frm == 3 || frm == 9)
		_sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON);
	else if(frm == 5 || frm == 11)
		_sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON);

	t_movetogoal(this, 14);
	armagon_walkthink(this);

	this.arma_frame += 1;
}

.bool run_straight;

void armagon_run(entity this)
{
	if(this.arma_frame >= 12)
		this.arma_frame = 0;

	set_animofs(this, anim_armagon_lwalk, this.arma_frame + 1, armagon_run);
	int frm = this.arma_frame + 1;
	if(frm == 3 || frm == 9)
		_sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON);
	else if(frm == 5 || frm == 11)
		_sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON);

	changeyaw(this);
	this.run_straight = true;
	ai_run(this, 14);
	armagon_think(this);

	if(frm == 12)
	{
		if((this.cnt == 1) && (time > this.attack_finished))
		{
			float delta;
			delta = this.ideal_yaw - this.angles_y;
			if(delta > 180) delta = delta - 360;
			if(delta < -180) delta = delta + 360;
			if(delta > 0)
				setthink(this, armagon_overleft1);
			else
				setthink(this, armagon_overright1);
			return;
		}
		if(this.lefty == 1)
		{
			this.lefty = 0;
			setthink(this, this.th_missile);
		}
	}

	this.arma_frame += 1;
}

void armagon_watk13(entity this) { set_animofs(this, anim_armagon_lw0fir, 12, armagon_run); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); this.attack_finished = time + 1; }
//void armagon_watk12(entity this) { set_animofs(this, anim_armagon_lw0fir, 12, armagon_watk13); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk11(entity this) { set_animofs(this, anim_armagon_lw0fir, 11, armagon_watk13); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); armagon_launch_missile(this, -40,0); }
void armagon_watk10(entity this) { set_animofs(this, anim_armagon_lw0fir, 10, armagon_watk11); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON);changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk9(entity this) { set_animofs(this, anim_armagon_lw0fir, 9, armagon_watk10); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk8(entity this) { set_animofs(this, anim_armagon_lw0fir, 8, armagon_watk9); _sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON);changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk7(entity this) { set_animofs(this, anim_armagon_lw0fir, 7, armagon_watk8); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk6(entity this) { set_animofs(this, anim_armagon_lw0fir, 6, armagon_watk7); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); armagon_launch_missile(this, 40,0); }
void armagon_watk5(entity this) { set_animofs(this, anim_armagon_lw0fir, 5, armagon_watk6); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk4(entity this) { set_animofs(this, anim_armagon_lw0fir, 4, armagon_watk5); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON);changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk3(entity this) { set_animofs(this, anim_armagon_lw0fir, 3, armagon_watk4); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk2(entity this) { set_animofs(this, anim_armagon_lw0fir, 2, armagon_watk3); _sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON);changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_watk1(entity this) { set_animofs(this, anim_armagon_lw0fir, 1, armagon_watk2); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }

void armagon_wlaseratk13(entity this) { set_animofs(this, anim_armagon_lw0fir, 12, armagon_run); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); this.attack_finished = time + 1; }
//void armagon_wlaseratk12(entity this) { set_animofs(this, anim_armagon_lw0fir, 12, armagon_wlaseratk13); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk11(entity this) { set_animofs(this, anim_armagon_lw0fir, 11, armagon_wlaseratk13); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); armagon_launch_laser(this, -40); }
void armagon_wlaseratk10(entity this) { set_animofs(this, anim_armagon_lw0fir, 10, armagon_wlaseratk11); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON);changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk9(entity this) { set_animofs(this, anim_armagon_lw0fir, 9, armagon_wlaseratk10); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk8(entity this) { set_animofs(this, anim_armagon_lw0fir, 8, armagon_wlaseratk9); _sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON);changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk7(entity this) { set_animofs(this, anim_armagon_lw0fir, 7, armagon_wlaseratk8); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk6(entity this) { set_animofs(this, anim_armagon_lw0fir, 6, armagon_wlaseratk7); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); armagon_launch_laser(this, 40); }
void armagon_wlaseratk5(entity this) { set_animofs(this, anim_armagon_lw0fir, 5, armagon_wlaseratk6); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk4(entity this) { set_animofs(this, anim_armagon_lw0fir, 4, armagon_wlaseratk5); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON);changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk3(entity this) { set_animofs(this, anim_armagon_lw0fir, 3, armagon_wlaseratk4); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk2(entity this) { set_animofs(this, anim_armagon_lw0fir, 2, armagon_wlaseratk3); _sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON);changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }
void armagon_wlaseratk1(entity this) { set_animofs(this, anim_armagon_lw0fir, 1, armagon_wlaseratk2); changeyaw(this); t_walkmove(this, this.angles_y, 14); armagon_think(this); }

void armagon_overleft15(entity this) { set_animofs(this, anim_armagon_lw1fir, 15, armagon_run); armagon_overleft_think(this); this.attack_finished = time + 1; }
void armagon_overleft14(entity this) { set_animofs(this, anim_armagon_lw1fir, 14, armagon_overleft15); armagon_overleft_think(this); }
void armagon_overleft13(entity this) { set_animofs(this, anim_armagon_lw1fir, 13, armagon_overleft14); armagon_overleft_think(this); }
void armagon_overleft12(entity this) { set_animofs(this, anim_armagon_lw1fir, 12, armagon_overleft13); this.count=2; armagon_overleft_think(this); }
void armagon_overleft11(entity this) { set_animofs(this, anim_armagon_lw1fir, 11, armagon_overleft12); this.count=1; armagon_overleft_think(this); }
void armagon_overleft10(entity this) { set_animofs(this, anim_armagon_lw1fir, 10, armagon_overleft11); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON); armagon_overleft_think(this); }
void armagon_overleft9(entity this) { set_animofs(this, anim_armagon_lw1fir, 9, armagon_overleft10); armagon_overleft_think(this); }
void armagon_overleft8(entity this) { set_animofs(this, anim_armagon_lw1fir, 8, armagon_overleft9); _sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON); armagon_overleft_think(this); }
void armagon_overleft7(entity this) { set_animofs(this, anim_armagon_lw1fir, 7, armagon_overleft8); armagon_overleft_think(this); }
void armagon_overleft6(entity this) { set_animofs(this, anim_armagon_lw1fir, 6, armagon_overleft7); armagon_overleft_think(this); }
void armagon_overleft5(entity this) { set_animofs(this, anim_armagon_lw1fir, 5, armagon_overleft6); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON); armagon_overleft_think(this); }
void armagon_overleft4(entity this) { set_animofs(this, anim_armagon_lw1fir, 4, armagon_overleft5); armagon_overleft_think(this); }
void armagon_overleft3(entity this) { set_animofs(this, anim_armagon_lw1fir, 3, armagon_overleft4); _sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON); armagon_overleft_think(this); }
void armagon_overleft2(entity this) { set_animofs(this, anim_armagon_lw1fir, 2, armagon_overleft3); armagon_overleft_think(this); }
void armagon_overleft1(entity this) { set_animofs(this, anim_armagon_lw1fir, 1, armagon_overleft2); this.count=0; armagon_overleft_think(this); }

void armagon_overright12(entity this) { set_animofs(this, anim_armagon_lw2fir, 12, armagon_run); armagon_overright_think(this); this.attack_finished = time + 1; }
void armagon_overright11(entity this) { set_animofs(this, anim_armagon_lw2fir, 11, armagon_overright12); armagon_overright_think(this); }
void armagon_overright10(entity this) { set_animofs(this, anim_armagon_lw2fir, 10, armagon_overright11); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON); armagon_overright_think(this); }
void armagon_overright9(entity this) { set_animofs(this, anim_armagon_lw2fir, 9, armagon_overright10); armagon_overright_think(this); }
void armagon_overright8(entity this) { set_animofs(this, anim_armagon_lw2fir, 8, armagon_overright9); _sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON); armagon_overright_think(this); }
void armagon_overright7(entity this) { set_animofs(this, anim_armagon_lw2fir, 7, armagon_overright8); armagon_overright_think(this); }
void armagon_overright6(entity this) { set_animofs(this, anim_armagon_lw2fir, 6, armagon_overright7); this.count=2; armagon_overright_think(this); }
void armagon_overright5(entity this) { set_animofs(this, anim_armagon_lw2fir, 5, armagon_overright6); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON);this.count=1; armagon_overright_think(this); }
void armagon_overright4(entity this) { set_animofs(this, anim_armagon_lw2fir, 4, armagon_overright5); armagon_overright_think(this); }
void armagon_overright3(entity this) { set_animofs(this, anim_armagon_lw2fir, 3, armagon_overright4); _sound(this, 7, "armagon/servo.wav", SERVO_VOLUME, ATTN_ARMAGON); armagon_overright_think(this); }
void armagon_overright2(entity this) { set_animofs(this, anim_armagon_lw2fir, 2, armagon_overright3); armagon_overright_think(this); }
void armagon_overright1(entity this) { set_animofs(this, anim_armagon_lw2fir, 1, armagon_overright2); this.count=0; armagon_overright_think(this); }

void armagon_plant1(entity this) { set_anim(this, anim_armagon_lstand, armagon_plant1); armagon_stand_attack(this); armagon_think(this); }

void armagon_stop2(entity this) { set_animofs(this, anim_armagon_tranl, 2, armagon_plant1); _sound(this, 6, "armagon/footfall.wav",1,ATTN_ARMAGON); armagon_think(this); }
void armagon_stop1(entity this) { set_animofs(this, anim_armagon_tranl, 1, armagon_stop2); armagon_think(this); }

void armagon_satk16(entity this) { set_animofs(this, anim_armagon_lsfire, 12, armagon_plant1); armagon_think(this); this.attack_finished = time + 0.3;; }
void armagon_satk15(entity this) { set_animofs(this, anim_armagon_lsfire, 11, armagon_satk16); armagon_think(this); }
void armagon_satk14(entity this) { set_animofs(this, anim_armagon_lsfire, 10, armagon_satk15); armagon_think(this); }
void armagon_satk13(entity this) { set_animofs(this, anim_armagon_lsfire, 9, armagon_satk14); armagon_think(this); armagon_launch_missile(this, 40,0); armagon_launch_missile(this, -40,0); }
void armagon_satk12(entity this) { set_animofs(this, anim_armagon_lsfire, 10, armagon_satk13); armagon_think(this); }
void armagon_satk11(entity this) { set_animofs(this, anim_armagon_lsfire, 9, armagon_satk12); armagon_think(this); armagon_launch_missile(this, 40,0); armagon_launch_missile(this, -40,0); }
void armagon_satk10(entity this) { set_animofs(this, anim_armagon_lsfire, 10, armagon_satk11); armagon_think(this); }
void armagon_satk9(entity this) { set_animofs(this, anim_armagon_lsfire, 9, armagon_satk10); armagon_think(this); armagon_launch_missile(this, 40,0); armagon_launch_missile(this, -40,0); }
void armagon_satk8(entity this) { set_animofs(this, anim_armagon_lsfire, 8, armagon_satk9); armagon_think(this); }
void armagon_satk7(entity this) { set_animofs(this, anim_armagon_lsfire, 7, armagon_satk8); armagon_think(this); }
void armagon_satk6(entity this) { set_animofs(this, anim_armagon_lsfire, 6, armagon_satk7); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON); armagon_think(this); }
void armagon_satk5(entity this) { set_animofs(this, anim_armagon_lsfire, 5, armagon_satk6); armagon_think(this); }
void armagon_satk4(entity this) { set_animofs(this, anim_armagon_lsfire, 4, armagon_satk5); armagon_think(this); }
void armagon_satk3(entity this) { set_animofs(this, anim_armagon_lsfire, 3, armagon_satk4); armagon_think(this); }
void armagon_satk2(entity this) { set_animofs(this, anim_armagon_lsfire, 2, armagon_satk3); armagon_think(this); }
void armagon_satk1(entity this) { set_animofs(this, anim_armagon_lsfire, 1, armagon_satk2); armagon_think(this); }

void armagon_slaser20(entity this) { set_animofs(this, anim_armagon_lsfire, 12, armagon_plant1); armagon_think(this); this.attack_finished = time + 0.3;; }
void armagon_slaser19(entity this) { set_animofs(this, anim_armagon_lsfire, 11, armagon_slaser20); armagon_think(this); }
void armagon_slaser18(entity this) { set_animofs(this, anim_armagon_lsfire, 10, armagon_slaser19); armagon_think(this); }
void armagon_slaser17(entity this) { set_animofs(this, anim_armagon_lsfire, 9, armagon_slaser18); armagon_think(this); armagon_launch_laser(this, 40); armagon_launch_laser(this, -40); }
void armagon_slaser16(entity this) { set_animofs(this, anim_armagon_lsfire, 10, armagon_slaser17); armagon_think(this); }
void armagon_slaser15(entity this) { set_animofs(this, anim_armagon_lsfire, 9, armagon_slaser16); armagon_think(this); armagon_launch_laser(this, 40); armagon_launch_laser(this, -40); }
void armagon_slaser14(entity this) { set_animofs(this, anim_armagon_lsfire, 10, armagon_slaser15); armagon_think(this); }
void armagon_slaser13(entity this) { set_animofs(this, anim_armagon_lsfire, 9, armagon_slaser14); armagon_think(this); armagon_launch_laser(this, 40); armagon_launch_laser(this, -40); }
void armagon_slaser12(entity this) { set_animofs(this, anim_armagon_lsfire, 10, armagon_slaser13); armagon_think(this); }
void armagon_slaser11(entity this) { set_animofs(this, anim_armagon_lsfire, 9, armagon_slaser12); armagon_think(this); armagon_launch_laser(this, 40); armagon_launch_laser(this, -40); }
void armagon_slaser10(entity this) { set_animofs(this, anim_armagon_lsfire, 10, armagon_slaser11); armagon_think(this); }
void armagon_slaser9(entity this) { set_animofs(this, anim_armagon_lsfire, 9, armagon_slaser10); armagon_think(this); armagon_launch_laser(this, 40); armagon_launch_laser(this, -40); }
void armagon_slaser8(entity this) { set_animofs(this, anim_armagon_lsfire, 8, armagon_slaser9); armagon_think(this); }
void armagon_slaser7(entity this) { set_animofs(this, anim_armagon_lsfire, 7, armagon_slaser8); armagon_think(this); }
void armagon_slaser6(entity this) { set_animofs(this, anim_armagon_lsfire, 6, armagon_slaser7); _sound(this, 6, "armagon/footfall.wav", 1, ATTN_ARMAGON); armagon_think(this); }
void armagon_slaser5(entity this) { set_animofs(this, anim_armagon_lsfire, 5, armagon_slaser6); armagon_think(this); }
void armagon_slaser4(entity this) { set_animofs(this, anim_armagon_lsfire, 4, armagon_slaser5); armagon_think(this); }
void armagon_slaser3(entity this) { set_animofs(this, anim_armagon_lsfire, 3, armagon_slaser4); armagon_think(this); }
void armagon_slaser2(entity this) { set_animofs(this, anim_armagon_lsfire, 2, armagon_slaser3); armagon_think(this); }
void armagon_slaser1(entity this) { set_animofs(this, anim_armagon_lsfire, 1, armagon_slaser2); armagon_think(this); }

void armagon_body_explode1(entity this);

void armagon_die14(entity this)
{
	set_animofs(this, anim_armagon_ldie, 12, armagon_die14);
	armagon_think(this);
	multi_explosion(this.origin + '0 0 80', 20, 10, 3, 0.1, 0.5);
	// legs
	this.nextthink = -1;
	set_movetype(this, MOVETYPE_NONE);
	this.takedamage = DAMAGE_NO;
	this.solid = SOLID_NOT;
	setsize(this, '-32 -32 -24', '32 32 32' );
	CorpseThink(this); // before flags are set to 0!
	this.flags = 0;
	this.gorging = true;
	this.wait = time + 5;

	//body
	entity body = this.attachment;
	body.nextthink = -1;
	set_movetype(this, MOVETYPE_NONE);
	body.takedamage = DAMAGE_NO;
	body.solid = SOLID_NOT;
//   setsize (body, '-32 -32 30', '32 32 64' );
	setthink(body, armagon_body_explode1);
	body.nextthink = time + 0.1;
	body.gorging = true;

}
void armagon_die13(entity this) { set_animofs(this, anim_armagon_ldie, 11, armagon_die14); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die12(entity this) { set_animofs(this, anim_armagon_ldie, 10, armagon_die13); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die11(entity this) { set_animofs(this, anim_armagon_ldie, 9, armagon_die12); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die10(entity this) { set_animofs(this, anim_armagon_ldie, 8, armagon_die11); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die9(entity this) { set_animofs(this, anim_armagon_ldie, 7, armagon_die10); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die8(entity this)
{
	set_animofs(this, anim_armagon_ldie, 6, armagon_die9);
	armagon_think(this);
	this.nextthink = time + 2;
}
void armagon_die7(entity this) { set_animofs(this, anim_armagon_ldie, 5, armagon_die8); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die6(entity this) { set_animofs(this, anim_armagon_ldie, 4, armagon_die7); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die5(entity this) { set_animofs(this, anim_armagon_ldie, 3, armagon_die6); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die4(entity this)
{
	set_animofs(this, anim_armagon_ldie, 2, armagon_die5);
	armagon_think(this);
	multi_explosion( this.origin + '0 0 48', 48, 10, 6, 0.3, 0.3);
	_sound(this, CH_TRIGGER, "armagon/death.wav", 1, 0.1);
	this.nextthink = time + 0.2;
}
void armagon_die3(entity this) { set_animofs(this, anim_armagon_ldie, 1, armagon_die4); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die2(entity this) { set_animofs(this, anim_armagon_tranl, 2, armagon_die3); armagon_think(this); this.nextthink = time + 0.2; }
void armagon_die1(entity this, entity inflictor, entity attacker, int deathtype) { set_animofs(this, anim_armagon_tranl, 1, armagon_die2); armagon_think(this); this.nextthink = time + 0.2; }

void armagon_body_explode2(entity this)
{
	_sound(this, CH_TRIGGER, "misc/longexpl.wav", 1, ATTN_ARMAGON);
	setthink(this, armagon_body_explode2);
	ThrowGib(this, "progs/gib1.mdl", -200);
	ThrowGib(this, "progs/gib2.mdl", -200);
	ThrowGib(this, "progs/gib3.mdl", -200);
	ThrowGib(this, "progs/gib1.mdl", -200);
	ThrowGib(this, "progs/gib2.mdl", -200);
	ThrowGib(this, "progs/gib3.mdl", -200);
	ThrowGib(this, "progs/gib1.mdl", -200);
	ThrowGib(this, "progs/gib2.mdl", -200);
	ThrowGib(this, "progs/gib3.mdl", -200);
	set_movetype(this, MOVETYPE_NONE);
	setmodel(this, MDL_EXPLOSION);
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	this.nextthink = time + 0.1;
	s_explode1(this);
}

void armagon_body_explode1(entity this)
{
	setthink(this, armagon_body_explode1);
	this.nextthink = time + 0.1;
	if(this.cnt == 0)
		this.count = 0;

	if(this.cnt < 25)
	{
		if(this.cnt > this.count)
		{
			ThrowGib(this, "progs/gib1.mdl", -100);
			ThrowGib(this, "progs/gib2.mdl", -100);
			ThrowGib(this, "progs/gib3.mdl", -100);
			this.count = this.cnt + 1;
		}
		this.cnt = this.cnt + 1;
	}
	else
	{
		this.cnt = 0;
		setthink(this, armagon_body_explode2);
	}
}

void armagon_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health <= 0)
		return;		// allready dying, don't go into pain frame

	if(damage < 25)
		return;
	if(this.pain_finished > time)
		return;
	this.pain_finished = time + 2;

	_sound(this, CH_VOICE, "armagon/pain.wav", 1, ATTN_NORM);
}

void armagon_missile_attack(entity this)
{
	if(random() < 0.5)
		armagon_watk1(this);
	else
		armagon_wlaseratk1(this);
//   this.nextthink = time + 0.1;
}

void armagon_repulse_attack(entity this)
{
	armagon_think(this);
	if(this.state == 0)
	{
		this.attack_finished = time + 0.5;
		_sound(this, CH_PLAYER, "armagon/repel.wav", 1, ATTN_NORM);
		this.state = 1;
		return;
	}
	else if(this.state == 1)
	{
		// look in our immediate vicinity
		entity head = findradius(this.origin, 300);
		while(head)
		{
			if(!(head.flags & FL_NOTARGET) && IS_PLAYER(head) && head.health > 0)
			{
				if(visible(this, head))
				{
					vector dir = head.origin - (this.origin - '0 0 24');
					dir = normalize(dir);
					head.velocity = head.velocity + dir*1500;
				}
			}
			head = head.chain;
		}
		T_RadiusDamage(this, this, 60, DEATH_MONSTER_ARMAGON.m_id, this);
		this.state = 0;
		this.attack_finished = time + 0.1;
	}
//   this.nextthink = time + 0.1;
}

void armagon_stand_attack(entity this)
{
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = this.enemy.origin + this.enemy.view_ofs;

	traceline (spot1, spot2, false, this);

	if(trace_ent != this.enemy)
	{
		armagon_run(this);
		return;
	}

	if(trace_inopen && trace_inwater)
	{
		armagon_run(this);
		return;
	}

	if(time < this.attack_finished)
		return;

	if(vdist(spot2 - spot1, <, 200) && IS_PLAYER(this.enemy))
	{
		armagon_repulse_attack(this);
		return;
	}

	this.state = 0;

	if(vdist(spot2 - spot1, >, 450))
	{
		armagon_run(this);
		return;
	}

	if(random() < 0.5)
		armagon_satk1(this);
	else
		armagon_slaser1(this);

	if(this.cnt == 1)
	{
		armagon_run(this);
		return;
	}
}


bool ArmagonCheckAttack(entity this)
{
	this.lefty = 0;

	entity targ = this.enemy;

// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, false, this);

	if((trace_ent != targ) && (!this.charmed))
		return false;     // don't have a clear shot

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(time < this.attack_finished)
		return false;

	float ang = this.angles_y + this.fixangle;
	float delta = this.ideal_yaw - ang;
	if((fabs(delta) > 10 && (vdist(spot2 - spot1, >, 200))) || !IS_PLAYER(this.enemy))
		return false;
	if(vdist(spot2 - spot1, <, 400))
	{  // melee attack
		this.th_melee(this);
		return true;
	}
// missile attack
	this.lefty = 1;
//   this.th_missile ();
//   SUB_AttackFinished (1.5*random());
	return false;
}

string armagon_sight(entity this) { return "armagon/sight.wav"; }

/*QUAKED monster_armagon (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
spawnfunc(monster_armagon)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	monster_start(this, true, MON_ARMAGON);
}
#endif // SVQC

#ifdef SVQC
METHOD(Armagon, mr_setup, bool(Armagon this, entity actor))
{
    TC(Armagon, this);

	precache_model ("progs/armabody.mdl");

	precache_sound("armagon/footfall.wav");
	precache_sound("armagon/servo.wav");
//   precache_sound("armagon/footfall2.wav");
	precache_sound("armagon/death.wav");
//   precache_sound("armagon/death2.wav");
	precache_sound("armagon/pain.wav");
	precache_sound("armagon/repel.wav");
//   precache_sound("armagon/idle.wav");
	precache_sound("armagon/sight.wav");
	precache_sound("armagon/idle1.wav");
	precache_sound("armagon/idle2.wav");
	precache_sound("armagon/idle3.wav");
	precache_sound("armagon/idle4.wav");

	entity body = new(armagon_body);
	setorigin(body, actor.origin - '0 0 64');

	body.solid = SOLID_NOT;
	body.colormod = actor.colormod;
	set_movetype(body, MOVETYPE_STEP);
	actor.attachment = body;
	body.attachment = actor;
	_setmodel(body, "progs/armabody.mdl");

	actor.fixangle = 0; // TODO: figure out why this is needed and if it should be on all monsters

    if(autocvar_skill == 0)
	{
		actor.yaw_speed = 5;
		actor.health = 3000;
		actor.worldtype = 0.9;
	}
	else if(autocvar_skill == 1)
	{
		actor.yaw_speed = 9;
		actor.health = 3500;
		actor.worldtype = 0.85;
	}
	else
	{
		actor.yaw_speed = 12;
		actor.health = 4500;
		actor.worldtype = 0.75;
	}
	actor.state = 0;
	actor.super_time = 0;
	actor.endtime = 0;

	actor.th_stand = armagon_stand;
	actor.th_walk = armagon_walk;
	actor.th_run = armagon_run;
	actor.th_die = armagon_die1;
	actor.th_missile = armagon_missile_attack;
	actor.th_melee = armagon_stop1;
	actor.th_pain = armagon_pain;

	actor.checkattack = ArmagonCheckAttack;

    return true;
}
METHOD(Armagon, mr_sight, bool(Armagon this, entity actor))
{
    TC(Armagon, this);

    // armagon's sight sound is REALLY loud, so we reduce it here
	_sound(actor, CH_VOICE, "armagon/sight.wav", 1, 0.1);

    return true;
}
#endif
