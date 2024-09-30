#include "balls.qh"

#include "dodgeball.qh"

#ifdef SVQC
entity BringBackTeammate(int tno)
{
	RandomSelection_Init();
	FOREACH_CLIENT(IS_PLAYER(it) && it.team_no == tno,
	{
		if(it.died && it.health > 0)
		{
			RandomSelection_AddEnt(it, 1, 1);
		}
	});

	return RandomSelection_chosen_ent;
}

void player_catch2(entity this);
void s_explode1(entity this);
void ball_touch(entity this, entity toucher)
{
	this.numbounces += 1;
	if(this.numbounces > 1)
		this.owner = NULL;
	
	if(this.model != "progs/ball_db.mdl")
	{
		_setmodel(this, "progs/ball_db.mdl");
		setsize(this, '-5 -5 -5', '5 5 5');
	}

	float damage = 0;
	float chance = 0;
	
	if(autocvar_sv_quake_dodgeball_classic)
	{
		damage = 100;
		chance = -1;
	}
	else
	{
		if(this.cnt == 1)	// power throw
		{
			damage = 80 + 20*random();	// 80-100
			chance = 0.15;
		}
		else if(this.cnt == 2)
		{
			damage = 40 + 35*random();	// 40-75
			chance = 0.1;
		}
		else if(this.cnt == 3)
		{
			damage = 100 + 50*random();	// 100-150
			chance = 0.25;
		}
		else
		{
			damage = 20 + 30*random();	// 20-50
			chance = 0.05;
		}
	}
	
	if(toucher.takedamage == DAMAGE_AIM)
	{
		if(IS_ONGROUND(this) && !STAT(HAS_BALL, toucher) && STAT(FROZEN, toucher) < time)
		{
			_sound(toucher, CHAN_BODY, "dodgeball/catch_db.wav", 1, ATTN_NORM);
			STAT(HAS_BALL, toucher) = true;
			delete(this);
			return;
		}
		
		if(STAT(CATCHING, toucher) > time && STAT(FROZEN, toucher) < time && toucher.health > 0)
		{
			if(infront(toucher, this))
			{
				if((this.cnt == 1 || this.cnt == 3) && this.numbounces == 1)
				{
					damage = damage * 0.1;
					// TODO: catching deathtype
					T_Damage(toucher, this, this.owner, damage, DEATH_CRUSH.m_id);
				}
				
				if(autocvar_sv_quake_dodgeball_classic && this.numbounces == 1 && toucher.team_no != this.owner.team_no)
				{
					entity mate = BringBackTeammate(toucher.team_no);
					if(mate)
					{
						bprint(strcat(mate.netname, " is back!\n"));
						
						entity spot = SelectTeamSpawn(mate, mate.team_no);
						mate.died = false;
						mate.health = 100;
						spawn_tfog(mate.origin);
						setorigin(mate, spot.origin + '0 0 1');
						spawn_tfog(mate.origin);
						spawn_tdeath(mate.origin, mate);
					}
				}
				
				_sound(toucher, CHAN_BODY, "dodgeball/catch_db.wav", 1, ATTN_NORM);
				STAT(HAS_BALL, toucher) = 1;
				player_catch2(toucher);
				delete(this);
				return;
			}
		}
		
		if(STAT(DEFLECTING, toucher) > time && toucher.health > 0)
		{
			_sound(this, CH_WEAPON_SINGLE, "dodgeball/bounce_db.wav", 1, ATTN_NORM);
			return;
		}
		
		if(toucher.team_no != this.owner.team_no && this.numbounces == 1 && this.dmgtime < time)
		{
			this.dmgtime = time + 0.5;
			
			if(random() <= chance)
			{	// critical hit!
				damage = damage * 3;
				if(IS_REAL_CLIENT(this.owner))
					centerprint(this.owner, "Critical!!");
				te_tarexplosion(this.origin);
				
				entity exp = spawn();
				exp.nextthink = time;
				setthink(exp, s_explode1);
				_setmodel(exp, "progs/s_explod.spr");
				setorigin(exp, this.origin);
			}
			int dtype = DEATH_CRUSH.m_id; // TODO: normal hit
			bool headshot = false;
			if(this.cnt == 1 || this.cnt == 3)
			{
				if(IS_PLAYER(toucher))
				{
					toucher.velocity = normalize(this.velocity) * 1500;
					if(toucher.velocity_z < 10)
						toucher.velocity_z += 300;
				}
				
				dtype = DEATH_CRUSH.m_id; // TODO: power
				if(this.origin_z >= (toucher.origin_z + (toucher.maxs_z * 0.7)) && IS_PLAYER(toucher))
				{
					headshot = true;
					dtype = DEATH_CRUSH.m_id; // TODO: headshot
					damage *= 2;
				}
			}
			
			SpawnBlood(this.origin, this.velocity*0.2, damage, toucher);
			T_Damage(toucher, this, this.owner, damage, dtype);
			if(headshot && toucher.health <= 0)
			{
				if(IS_REAL_CLIENT(this.owner))
				{
					centerprint(this.owner, "Head shot!");
					play2(this.owner, "speech/headshot_db.wav");
				}
			}
			
			if(this.cnt == 1 || this.cnt == 3)
				_sound(this, CH_WEAPON_SINGLE, "dodgeball/hit2_db.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_WEAPON_SINGLE, "dodgeball/hit1_db.wav", 1, ATTN_NORM);
			return;
		}
	}
	
	_sound(this, CH_WEAPON_SINGLE, "dodgeball/bounce_db.wav", 1, ATTN_NORM);
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

void teleport_back(entity this)
{
	entity spot = SelectBallSpot();
	
	if(this.model != "progs/ball_db.mdl")
	{
		_setmodel(this, "progs/ball_db.mdl");
		setsize(this, '-5 -5 -5', '5 5 5');
	}
	
	spawn_tfog(this.origin);
	setorigin(this, spot.origin + '0 0 1');
	spawn_tfog(this.origin);
	
	UNSET_ONGROUND(this);
	
	this.velocity_x = crandom()*250;
	this.velocity_y = crandom()*250;
	this.velocity_z = 500;
	
	this.nextthink = time + 20;
	setthink(this, teleport_back);
}

void ThrowSpecialBall(entity this);
void ThrowBall(entity this)
{
	if(!STAT(HAS_BALL, this))
		return;
	
	if(STAT(SPECIAL, this))
	{
		ThrowSpecialBall(this);
		return;
	}
	
	STAT(HAS_BALL, this) = 0;

	this.punchangle_x = -1;

	_sound(this, CH_WEAPON_SINGLE, "zombie/z_shot1.wav", 1, ATTN_NORM);

	entity ball = spawn();
	ball.owner = this;
	set_movetype(ball, MOVETYPE_BOUNCE);
	ball.solid = SOLID_BBOX;
	ball.classname = "dodgeball";
	ball.dphitcontentsmask = this.dphitcontentsmask;

	makevectors (this.v_angle);

	float vel = 850;
	if(dodgeball_Sprinting(this))
	{
		vel = 1150;
		ball.cnt = 2;
	}
	
	if(this.v_angle_x)
		ball.velocity = v_forward * vel + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		ball.velocity = qc_aim(this, 10000);
		ball.velocity = ball.velocity * vel;
		ball.velocity_z = 200;
	}
	
	ball.avelocity = '300 300 300';
	
	ball.angles = vectoangles(ball.velocity);
	
	settouch(ball, ball_touch);
	
	ball.nextthink = time + 10;
	setthink(ball, teleport_back);
	
	_setmodel(ball, "progs/ball_db.mdl");
	setsize(ball, '-5 -5 -5', '5 5 5');
	setorigin(ball, this.origin);
}

void player_ball3(entity this);
void PowerThrow(entity this)
{
	if(ceasefire)
		return;
	if(!STAT(HAS_BALL, this))
		return;
	if(autocvar_sv_quake_dodgeball_classic)
		return;
	if(STAT(SPECIAL, this))
		return;
	if(this.throw_finished > time)
	{
		centerprint(this, strcat("Wait ", ftos(rint(this.throw_finished - time)), " seconds..."));
		return;
	}
	
	STAT(HAS_BALL, this) = 0;
	this.throw_finished = time + 20;
	player_ball3(this);
	
	this.punchangle_x = -2;
	
	_sound(this, CH_WEAPON_SINGLE, "dodgeball/powerthrow_db.wav", 1, ATTN_NORM);
	
	entity ball = spawn();
	ball.owner = this;
	set_movetype(ball, MOVETYPE_BOUNCE);
	ball.solid = SOLID_BBOX;
	ball.classname = "dodgeball";
	ball.cnt = 1;
	ball.dphitcontentsmask = this.dphitcontentsmask;
	
	makevectors(this.v_angle);

	float vel = 1300;
	if(dodgeball_Sprinting(this))
	{
		vel = 1750;
		ball.cnt = 3;
	}
	
	if(this.v_angle_x)
		ball.velocity = v_forward * vel + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		ball.velocity = qc_aim(this, 10000);
		ball.velocity = ball.velocity * vel;
		ball.velocity_z = 200;
	}
	
	ball.avelocity = '400 400 400';
	
	ball.angles = vectoangles(ball.velocity);
	
	settouch(ball, ball_touch);
	
	ball.nextthink = time + 10;
	setthink(ball, teleport_back);
	
	_setmodel(ball, "progs/ball2_db.mdl");
	setsize(ball, '-5 -5 -5', '5 5 5');
	setorigin(ball, this.origin);
}

void Freeze(entity ent)
{
	if(STAT(FROZEN, ent) > time)
	{
		STAT(FROZEN, ent) = time + 3;
		return;
	}
	
	STAT(FROZEN, ent) = time + 3;
	if(IS_REAL_CLIENT(ent))
		centerprint(ent, "You are frozen!\n");
}

void iceball_touch(entity this, entity toucher)
{
	if(toucher.takedamage)
	{
		if(toucher.team_no != this.owner.team_no)
		{
			Freeze(toucher);
			DropBall(toucher);
		}
		// TODO: ice deathtype
		T_Damage(toucher, this, this.owner, 10, DEATH_CRUSH.m_id);
	}
	
	_sound(this, CH_WEAPON_SINGLE, "dodgeball/icehit_db.wav", 1, ATTN_NORM);

	for(int j = 0; j < 5; ++j)
	{
		ThrowGib(this, toucher, "progs/ice_db.mdl", -70);
	}
	
	delete(this);
}


void homingball_touch(entity this, entity toucher)
{
	if(toucher.health)
	{
		// TODO: homing deathtype
		T_Damage(toucher, this, this.owner, 50, DEATH_CRUSH.m_id);
	}

	// TODO: homing deathtype
	T_RadiusDamage(this, this.owner, 50, DEATH_CRUSH.m_id, toucher);
	
	this.origin = this.origin - 8 * normalize(this.velocity);

	te_explosion(this.origin);
	
	BecomeExplosion(this);
}

void BallFindTarget(entity this)
{
	entity selected = NULL;
	float best_dist = 0;
	FOREACH_CLIENT(IS_PLAYER(it) && it.team_no != this.owner.team_no,
	{
		if(it.health <= 0 || it.died)
			continue;

		traceline(this.origin, CENTER_OR_VIEWOFS(it), true, this);
		if(trace_fraction == 1)
		{
			float newdist = vlen2(it.origin - this.origin);
			if(!best_dist || newdist < best_dist)
			{
				best_dist = newdist;
				selected = it;
			}
		}
	});
	
	if(selected)
		this.enemy = selected;
}

void homingball_think(entity this)
{
	this.nextthink = time + 0.2;
	
	if(!this.enemy)
		BallFindTarget(this);
	else
	{
		if(this.enemy.health <= 0)
			this.enemy = NULL;
		
		vector vtemp = this.enemy.origin + '0 0 10';
		vector dir = normalize(vtemp - this.origin);
		this.velocity = dir * 350;
	}
	
	if(this.lifetime < time && gettouch(this))
		gettouch(this)(this, NULL);
}


void bombball_touch(entity this, entity toucher)
{
	// TODO: bomb deathtype
	T_RadiusDamage(this, this.owner, 160, DEATH_CRUSH.m_id, NULL);

	this.origin = this.origin - 8*normalize(this.velocity);

	te_explosion(this.origin);

	BecomeExplosion(this);
}

void fireball_touch(entity this, entity toucher)
{
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, 20, DEATH_BURNING.m_id);
		if(toucher.team_no != this.owner.team_no)
			StatusEffects_apply(STATUSEFFECT_Burning, toucher, time + 3, 0);
	}
	_sound(this, CH_WEAPON_SINGLE, "hknight/attack1.wav", 1, ATTN_NORM);
	BecomeExplosion(this);
}

void roflcopter_explode(entity this)
{
	// TODO: roflcopter deathtype
	T_RadiusDamage(this, this.owner, 100, DEATH_CRUSH.m_id, NULL);
	
	int i = 10;
	while (i > 0)
	{
		entity ball = spawn();
		ball.owner = this.owner;
		set_movetype(ball, MOVETYPE_BOUNCE);
		ball.solid = SOLID_BBOX;
		ball.classname = "dodgeball";
		STAT(SPECIAL, ball) = 1;
		ball.velocity_x = crandom()*300;
		ball.velocity_y = crandom()*300;
		ball.avelocity = '300 300 300';
		ball.angles = vectoangles(ball.velocity);
		ball.nextthink = time + 5;
		setthink(ball, SUB_Remove);
		
		if(random() < 0.3)
		{
			_setmodel(ball, "progs/ball_db.mdl");
			ball.skin = 1;
			settouch(ball, iceball_touch);
		}
		else if(random() < 0.6)
		{
			_setmodel(ball, "progs/ball3_db.mdl");
			ball.skin = 1;
			settouch(ball, bombball_touch);
		}
		else
		{
			_setmodel(ball, "progs/ball3_db.mdl");
			ball.skin = 2;
			settouch(ball, fireball_touch);
		}
		
		setsize(ball, '0 0 0', '0 0 0');
		setorigin (ball, this.origin);
		
		i = i - 1;
	}
	
	if(this.propeller)
		delete(this.propeller);

	te_explosion(this.origin);
	
	BecomeExplosion(this);
}

void roflcopter_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	setthink(this, roflcopter_explode);
	this.nextthink = time;
	settouch(this, func_null);
}

void roflcopter_explode2(entity this)
{
	// TODO: roflcopter deathtype
	T_RadiusDamage(this, this.owner, 100, DEATH_CRUSH.m_id, NULL);
	if(this.propeller)
		delete(this.propeller);
	
	te_explosion(this.origin);
	
	BecomeExplosion(this);
}

void roflcopter_think(entity this)
{
	this.nextthink = time;
	if(countdown)
	{
		roflcopter_explode2(this);
		return;
	}
	if(this.lifetime < time)
	{
		roflcopter_explode(this);
		return;
	}

	if(this.lip != -1 && this.lip < time)
	{
		_sound(this, CH_WEAPON_SINGLE, "speech/takesome_db.wav", 1, ATTN_NORM);
		this.lip = -1;
	}
	
	if(this.t_width < time)
	{
		_sound(this, CHAN_VOICE, "speech/roflcopter_db.wav", 1, ATTN_NORM);
		this.t_width = time + 0.45;
	}
	
	if(this.frags < time)
	{
		makevectors(this.angles);
		this.velocity = v_forward * 100;
	}
	else
		this.velocity = '0 0 100';
	
	setorigin(this.propeller, this.origin);
	UNSET_ONGROUND(this);
}

void roflcopter_touch(entity this, entity toucher)
{
	if(/*toucher && */toucher.solid != SOLID_BSP)
		return;
	setthink(this, roflcopter_explode);
	this.nextthink = time;
	settouch(this, func_null);
}

void propeller_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	if(toucher.team_no == this.owner.team_no)
		return;

	int dtype = DEATH_CRUSH.m_id;
	if(toucher.origin_z + 22 < this.origin_z)
		dtype = DEATH_CRUSH.m_id; // TODO: bottom deathtype

	T_Damage(toucher, this, this.owner.owner, 50000, dtype);
}

void Launch_Roflcopter(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "speech/coptergoes_db.wav", 1, ATTN_NORM);
	
	entity ball = spawn();
	ball.owner = this;
	set_movetype(ball, MOVETYPE_FLY);
	ball.solid = SOLID_BBOX;
	ball.classname = "roflcopter";
	STAT(SPECIAL, ball) = STAT(SPECIAL, this);
	ball.team_no = this.team_no;
	
	ball.velocity = '0 0 100';
	ball.angles_y = this.angles_y;
	
	ball.health = 150;
	ball.takedamage = DAMAGE_AIM;
	ball.th_die = roflcopter_die;
	
	settouch(ball, roflcopter_touch);
	
	ball.lifetime = time + 5 + 2*random();
	ball.frags = time + 1 + random();
	ball.lip = time + (ball.lifetime - time - 1.5);
	ball.nextthink = time;
	setthink(ball, roflcopter_think);
	
	_setmodel(ball, "progs/bigball_db.mdl");
	setsize(ball, '-16 -16 -24', '16 16 11');
	setorigin (ball, this.origin);

	entity prop = spawn();
	prop.owner = ball;
	ball.propeller = prop;
	prop.solid = SOLID_BBOX;
	prop.classname = "propeller";
	prop.angles_y = this.angles_y;
	settouch(prop, propeller_touch);
	_setmodel(prop, "progs/prop_db.mdl");
	setsize(prop, '-32 -32 0', '32 32 20');
}

void SentryExplode(entity this)
{
	sprint(this.builder, "Your sentry gun was destroyed.\n");
	T_RadiusDamage(this, this, 80, DEATH_CRUSH.m_id, NULL);
	if(this.trigger_field)
		delete(this.trigger_field);
	
	this.origin_z = this.origin_z + 32;
	
	te_explosion(this.origin);
	
	BecomeExplosion(this);
}

void SentryDie(entity this, entity inflictor, entity attacker, int deathtype)
{
	setthink(this, SentryExplode);
	this.nextthink = time;
	settouch(this, func_null);
}

void lvl1_sentry_stand(entity this);
void SentryBuilt(entity this)
{
	if(this.builder.health <= 0 || !IS_PLAYER(this.builder))
	{
		delete(this);
		return;
	}
	
	this.solid = SOLID_NOT;
	
	entity gun = spawn();
	gun.builder = this.builder;
	gun.trigger_field = this;
	set_movetype(gun, MOVETYPE_STEP);
	gun.solid = SOLID_SLIDEBOX;
	gun.classname = "sentry";
	
	gun.health = 150;
	gun.takedamage = DAMAGE_AIM;
	gun.th_die = SentryDie;
	
	gun.team_no = this.builder.team_no;
	gun.view_ofs = '0 0 35';
	gun.angles_y = this.angles_y;
	gun.yaw_speed = 25;
	
	gun.nextthink = time + 0.5;
	setthink(gun, lvl1_sentry_stand);
	
	_setmodel(gun, "progs/sentry_top_db.mdl");
	setsize(gun, '-32 -32 -8', '32 32 74');
	setorigin(gun, this.origin + '0 0 25');
}

void BuildSentry(entity this)
{
	vector v = this.v_angle;
	v.x = 0;
	
	makevectors(v);
	
	entity base = spawn();
	base.solid = SOLID_SLIDEBOX;
	setsize(base, '-32 -32 -8', '32 32 74');
	setorigin(base, this.origin + v_forward*64);

	tracebox(base.origin, base.mins, base.maxs, base.origin, MOVE_NOMONSTERS, base);
	if(trace_startsolid)
	{
		sprint(this, "Not enough room!\n");
		STAT(SPECIAL, this) = 6; // give ball back
		delete(base);
		return;
	}
	
	delete(base);
	
	base = spawn();
	base.builder = this;
	set_movetype(base, MOVETYPE_TOSS);
	base.solid = SOLID_SLIDEBOX;
	base.classname = "base";
	base.angles_y = this.angles_y;
	base.nextthink = time + 3;
	setthink(base, SentryBuilt);
	_setmodel(base, "progs/sentry_stand_db.mdl");
	setsize(base, '-32 -32 -8', '32 32 74');
	setorigin(base, this.origin + v_forward*64);
}

void ThrowSpecialBall(entity this)
{
	if(!STAT(SPECIAL, this))
		return;
	
	STAT(HAS_BALL, this) = 0;
	if(STAT(SPECIAL, this) == 5)
	{
		Launch_Roflcopter(this);
		STAT(SPECIAL, this) = 0;
		return;
	}
	if(STAT(SPECIAL, this) == 6)
	{
		STAT(SPECIAL, this) = 0;
		BuildSentry(this);
		return;
	}
	
	this.punchangle_x = -1;
	
	_sound(this, CH_WEAPON_SINGLE, "zombie/z_shot1.wav", 1, ATTN_NORM);
	
	entity ball = spawn();
	ball.owner = this;
	set_movetype(ball, MOVETYPE_BOUNCE);
	ball.solid = SOLID_BBOX;
	ball.classname = "dodgeball";
	ball.dphitcontentsmask = this.dphitcontentsmask;
	STAT(SPECIAL, ball) = STAT(SPECIAL, this);	// so bots don't follow'em
	
	makevectors(this.v_angle);
	
	float vel = 850;
	if(dodgeball_Sprinting(this))
	{
		vel = 1150;
		ball.cnt = 2;
	}
	
	if(this.v_angle_x)
		ball.velocity = v_forward * vel + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		ball.velocity = qc_aim(this, 10000);
		ball.velocity = ball.velocity * vel;
		ball.velocity_z = 200;
	}
	
	ball.avelocity = '300 300 300';
	
	ball.angles = vectoangles(ball.velocity);
	
	ball.nextthink = time + 5;
	setthink(ball, SUB_Remove);
	
	if(STAT(SPECIAL, this) == 1)
	{	// ice
		_setmodel(ball, "progs/ball_db.mdl");
		ball.skin = 1;
		settouch(ball, iceball_touch);
	}
	else if(STAT(SPECIAL, this) == 2)
	{	// homing
		_setmodel(ball, "progs/ball3_db.mdl");
		ball.movetype = MOVETYPE_FLYMISSILE;
		ball.velocity = qc_aim(this, 10000);
		ball.velocity = ball.velocity * 400;
		ball.velocity_z += 250;
		settouch(ball, homingball_touch);
		ball.lifetime = time + 10;
		ball.nextthink = time + 0.2;
		setthink(ball, homingball_think);
	}
	else if(STAT(SPECIAL, this) == 3)
	{	// bomb
		_setmodel(ball, "progs/ball3_db.mdl");
		ball.skin = 1;
		settouch(ball, bombball_touch);
	}
	else if(STAT(SPECIAL, this) == 4)
	{	// fire
		_setmodel(ball, "progs/ball3_db.mdl");
		ball.skin = 2;
		settouch(ball, fireball_touch);
	}
	
	STAT(SPECIAL, this) = 0;
	
	setsize(ball, '-5 -5 -5', '5 5 5');
	setorigin(ball, this.origin);
}


void specialball_pickup(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;
	if(STAT(HAS_BALL, toucher))
		return;
	if(STAT(FROZEN, toucher) > time)
		return;

	Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, ITEM_WEAPON_GOT, this.netname);
	
	_sound(toucher, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	STAT(HAS_BALL, toucher) = true;
	STAT(SPECIAL, toucher) = STAT(SPECIAL, this);

	W_SetCurrentAmmo(toucher);

	delete(this);
}

void DropSpecialBall(entity this)
{
	if(!STAT(SPECIAL, this))
		return;
	
	entity ball = spawn();
	ball.owner = this;
	set_movetype(ball, MOVETYPE_BOUNCE);
	ball.solid = SOLID_TRIGGER;
	ball.classname = "dodgeball";
	
	ball.velocity_x = crandom()*100;
	ball.velocity_y = crandom()*100;
	ball.velocity_z = 300;
	
	ball.avelocity = '300 300 300';
	
	ball.angles = vectoangles(ball.velocity);
	
	STAT(SPECIAL, ball) = STAT(SPECIAL, this);
	settouch(ball, specialball_pickup);
	
	if(STAT(SPECIAL, this) == 1)
	{	// ice
		_setmodel(ball, "progs/ball_db.mdl");
		ball.skin = 1;
		ball.netname = "Ice Ball";
		setsize(ball, '-5 -5 -5', '5 5 5');
	}
	else if(STAT(SPECIAL, this) == 2)
	{	// homing
		_setmodel(ball, "progs/ball3_db.mdl");
		ball.netname = "Homing Ball";
		setsize(ball, '-5 -5 -5', '5 5 5');
	}
	else if(STAT(SPECIAL, this) == 3)
	{	// bomb
		_setmodel(ball, "progs/ball3_db.mdl");
		ball.skin = 1;
		ball.netname = "Bomb Ball";
		setsize(ball, '-5 -5 -5', '5 5 5');
	}
	else if(STAT(SPECIAL, this) == 4)
	{	// fire
		_setmodel(ball, "progs/ball3_db.mdl");
		ball.skin = 2;
		ball.netname = "Fire Ball";
		setsize(ball, '-5 -5 -5', '5 5 5');
	}
	else if(STAT(SPECIAL, this) == 5)
	{	// roflcopter
                _setmodel(ball, "progs/ball_roflcopter_db.mdl");
		ball.netname = "Roflcopter";
                setsize(ball, '-5 -5 -5', '5 5 5');
	}
	else if(STAT(SPECIAL, this) == 6)
	{	// sentry ball
		_setmodel(ball, "progs/ball_spanner_db.mdl");
		ball.netname = "Sentry Ball";
		setsize(ball, '-5 -5 -5', '5 5 5');
	}
	
	STAT(SPECIAL, this) = 0;
	
	setorigin(ball, this.origin);
}

void DropBall(entity this)
{
	if(!STAT(HAS_BALL, this))
		return;
	
	STAT(HAS_BALL, this) = 0;
	if(STAT(SPECIAL, this))
	{
		DropSpecialBall(this);
		return;
	}
	
	entity ball = spawn();
	set_movetype(ball, MOVETYPE_BOUNCE);
	ball.solid = SOLID_BBOX;
	ball.classname = "dodgeball";
	
	ball.velocity_x = crandom()*100;
	ball.velocity_y = crandom()*100;
	ball.velocity_z = 300;
	
	ball.avelocity = '300 300 300';
	
	ball.angles = vectoangles(ball.velocity);
	
	settouch(ball, ball_touch);
	
	ball.nextthink = time + 10;
	setthink(ball, teleport_back);
	
	_setmodel(ball, "progs/ball_db.mdl");
	setsize(ball, '-5 -5 -5', '5 5 5');
	setorigin(ball, this.origin);
}
#endif