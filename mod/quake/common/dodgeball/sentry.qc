#include "sentry.qh"

#ifdef SVQC
void lvl1_sentry_stand(entity this)
{
	set_anim(this, 0, lvl1_sentry_stand);
	SentryFindTarget(this);
	if(this.frags >= 2)
	{
		this.level = 1;
		this.health = 180;
		lvl2_sentry_stand(this);
	}
}
void lvl2_sentry_stand(entity this)
{
	set_anim(this, 2, lvl2_sentry_stand);
	SentryFindTarget(this);
	if(this.frags >= 4)
	{
		this.level = 2;
		this.health = 216;
		lvl3_sentry_stand(this);
	}
}
void lvl3_sentry_stand(entity this)
{
	set_anim(this, 5, lvl3_sentry_stand);
	SentryFindTarget(this);
}

void SentryFindTarget(entity this)
{
	if(!IS_PLAYER(this.builder) || this.builder.health <= 0 || this.builder.died || countdown || ceasefire)
	{
		spawn_tfog(this.origin + '0 0 32');
		delete(this);
		return;
	}

	entity found = NULL;
	float bestdist = 0;
	FOREACH_ENTITY_RADIUS(this.origin, 1000, it.takedamage,
	{
		if(it.health <= 0 || it.died)
			continue;
		if(it.team_no == this.team_no)
			continue;
		if(!visible(this, it))
			continue;
		float newdist = vlen2(it.origin - this.origin);
		if(!bestdist || newdist < bestdist)
		{
			bestdist = newdist;
			found = it;
		}
	});

	if(found)
	{
		this.enemy = found;
		switch(this.level)
		{
			case 0: setthink(this, lvl1_sentry_atk1); this.nextthink = time + 0.1; break;
			case 1: setthink(this, lvl2_sentry_atk1); this.nextthink = time + 0.1; break;
			case 2: setthink(this, lvl3_sentry_atk1); this.nextthink = time + 0.1; break;
		}
	}
}


void sentry_ball_touch(entity this, entity toucher)
{
	float damage;
	float chance;
	if(!this.cnt)
	{
		damage = 20 + 30*random();	// 20-50
		chance = 0.05;
	}
	else
	{
		damage = 80 + 20*random();	// 80-100
		chance = 0.15;
	}
	
	if(toucher.takedamage == DAMAGE_AIM)
	{
		if(toucher.team_no != this.owner.team_no)
		{
			if(STAT(DEFLECTING, toucher) > time && toucher.health > 0)
			{
				if(this.cnt)
					_sound(this, CH_WEAPON_SINGLE, "dodgeball/hit2_db.wav", 1, ATTN_NORM);
				else
					_sound(this, CH_WEAPON_SINGLE, "dodgeball/hit1_db.wav", 1, ATTN_NORM);
				settouch(this, func_null);
				set_movetype(this, MOVETYPE_BOUNCE);
				this.nextthink = time + 1;
				setthink(this, SUB_Remove);
				return;
			}
			
			if(random() <= chance)
			{	// critical hit!
				damage *= 3;
				te_tarexplosion(this.origin);
				
				entity exp = spawn();
				exp.classname = "s_explode";
				exp.nextthink = time;
				setthink(exp, s_explode1);
				_setmodel(exp, "progs/s_explod.spr");
				setorigin(exp, this.origin);
			}
			int dtype = DEATH_CRUSH.m_id; // TODO: normal
			if(this.cnt)
			{
				if(IS_PLAYER(toucher))
				{
					toucher.velocity = normalize(this.velocity) * 1500;
					if(toucher.velocity_z < 10)
						toucher.velocity_z += 300;
				}

				dtype = DEATH_CRUSH.m_id; // TODO: power
				if(this.origin_z >= toucher.origin_z + 20 && IS_PLAYER(toucher))
				{
					dtype = DEATH_CRUSH.m_id; // TODO: headshot
					damage *= 2;
				}
			}
			
			SpawnBlood(this.origin, this.velocity*0.2, damage, toucher);
			T_Damage(toucher, this, this.owner, damage, dtype);
			
			if(this.cnt)
				_sound(this, CH_WEAPON_SINGLE, "dodgeball/hit2_db.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_WEAPON_SINGLE, "dodgeball/hit1_db.wav", 1, ATTN_NORM);	
			delete(this);
			return;
		}
	}
	
	_sound(this, CH_WEAPON_SINGLE, "dodgeball/bounce_db.wav", 1, ATTN_NORM);
	delete(this);
}

bool SentryFire(entity this, float ox, vector up, float power)
{
	if(this.ideal_yaw - ANGLEMOD(this.angles_y) < -25 || this.ideal_yaw - ANGLEMOD(this.angles_y) > 25)
		return false;
	
	this.effects |= EF_MUZZLEFLASH;
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	
	entity ball = spawn();
	ball.owner = this;
	set_movetype(ball, MOVETYPE_FLYMISSILE);
	ball.solid = SOLID_BBOX;
	ball.classname = "dodgeball";

	float vel = (power) ? 1300 : 850;
	
	makevectors(this.angles);
	ball.velocity = normalize(this.enemy.origin - (this.origin + v_forward*32 + v_right*ox + up)) * vel;
	ball.avelocity = '300 300 300';
	ball.angles = vectoangles(ball.velocity);
	
	ball.cnt = power;
	settouch(ball, sentry_ball_touch);
	
	ball.nextthink = time + 5;
	setthink(ball, SUB_Remove);
	
	if(power)
		_setmodel(ball, "progs/ball2_db.mdl");
	else
		_setmodel(ball, "progs/ball_db.mdl");
	setsize(ball, '-5 -5 -5', '5 5 5');
	setorigin(ball, this.origin + v_forward*32 + v_right*ox + up);
	
	return true;
}

void sentry_face(entity this)
{
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	changeyaw(this);
}

void lvl1_sentry_atk1(entity this)
{
	set_anim(this, 1, lvl1_sentry_atk2);
	this.nextthink = time + 0.25;
	sentry_face(this);
	if(this.enemy.health <= 0 || !visible(this, this.enemy) || this.enemy.died || countdown)
		lvl1_sentry_stand(this);
	else if(!SentryFire(this, 0, '0 0 61', 0))
		lvl1_sentry_atk2(this);
}
void lvl1_sentry_atk2(entity this) { set_anim(this, 0, lvl1_sentry_atk1); this.nextthink = time + 0.25; sentry_face(this); }

void lvl2_sentry_atk1(entity this)
{
	set_anim(this, 3, lvl2_sentry_atk2);
	this.nextthink = time + 0.25;
	sentry_face(this);
	if(this.enemy.health <= 0 || !visible(this, this.enemy) || this.enemy.died || countdown)
		lvl2_sentry_stand(this);
	else if(!SentryFire(this, 0, '0 0 61', 0))
		lvl2_sentry_atk3(this);
}
void lvl2_sentry_atk2(entity this)
{
	set_anim(this, 4, lvl2_sentry_atk1);
	this.nextthink = time + 0.25;
	sentry_face(this);
	if(this.enemy.health <= 0 || !visible(this, this.enemy) || this.enemy.died || countdown)
		lvl2_sentry_stand(this);
	else if(!SentryFire(this, 11, '0 0 46', 0))
		lvl2_sentry_atk3(this);
}
void lvl2_sentry_atk3(entity this) { set_anim(this, 2, lvl2_sentry_atk1); this.nextthink = time + 0.25; sentry_face(this); }

void lvl3_sentry_atk1(entity this)
{
	set_anim(this, 6, lvl3_sentry_atk2);
	this.nextthink = time + 0.16;
	float thepower = 0;
	if(this.frags >= 6)
		thepower = 1;
	
	sentry_face(this);
	if(this.enemy.health <= 0 || !visible(this, this.enemy) || this.enemy.died || countdown)
		lvl3_sentry_stand(this);
	else if(!SentryFire(this, 0, '0 0 61', thepower))
		lvl3_sentry_atk4(this);
}
void lvl3_sentry_atk2(entity this)
{
	set_anim(this, 7, lvl3_sentry_atk3);
	this.nextthink = time + 0.16;
	float thepower = 0;
	if(this.frags >= 6)
		thepower = 1;
	
	sentry_face(this);
	if(this.enemy.health <= 0 || !visible(this, this.enemy) || this.enemy.died || countdown)
		lvl3_sentry_stand(this);
	else if(!SentryFire(this, 11, '0 0 46', thepower))
		lvl3_sentry_atk4(this);
}
void lvl3_sentry_atk3(entity this)
{
	set_anim(this, 8, lvl3_sentry_atk1);
	this.nextthink = time + 0.16;
	float thepower = 0;
	if(this.frags >= 6)
		thepower = 1;
	
	sentry_face(this);
	if(this.enemy.health <= 0 || !visible(this, this.enemy) || this.enemy.died || countdown)
		lvl3_sentry_stand(this);
	else if(!SentryFire(this, -11, '0 0 46', thepower))
		lvl3_sentry_atk4(this);
}
void lvl3_sentry_atk4(entity this) { set_anim(this, 5, lvl3_sentry_atk1); this.nextthink = time + 0.16; sentry_face(this);}
#endif
