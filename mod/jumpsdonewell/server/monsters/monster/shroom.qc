#include "shroom.qh"

void shroom_die_proper(entity this)
{
	sound(this, CHAN_AUTO, SND_SWORD2, 0.7, ATTEN_NORM);
	pointparticles(EFFECT_ENEMY_DIE, this.origin + '0 0 32', '0 0 1', 1);
	this.solid = SOLID_NOT;
	this.takedamage = DAMAGE_NO;
	this.modelindex = 0;
	this.nextthink = time + 20;
	setthink(this, spawnfunc_monster_shroom); // respawn
	setorigin(this, this.home);
	CSQCMODEL_AUTOUPDATE(this);
}
void shroom_die2(entity this)
{
	this.frame = 3;
	this.nextthink = time + 0.4;
	setthink(this, shroom_die_proper);
	CSQCMODEL_AUTOUPDATE(this);
}

void shroom_die(entity this)
{
	this.frame = 0;
	this.nextthink = time + 0.05;
	setthink(this, shroom_die2);
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	CSQCMODEL_AUTOUPDATE(this);
}

void shroom_hurt(entity this)
{
	this.frame = 0;
	CSQCMODEL_AUTOUPDATE(this);
}

entity check_for_player(entity this)
{
	makevectors(this.angles);
	FOREACH_CLIENT(it.health > 0 && vdist(it.origin - this.origin, <, 500),
	{
		float dot = v_forward * normalize(it.origin - this.origin);
		if(dot < 0.5)
			continue;
		traceline(this.origin + '0 0 20', it.origin, MOVE_NOMONSTERS, this);
		if(trace_fraction < 1)
			continue;
		return it;
	});
	return NULL;
}

void chase_player(entity this, entity player)
{
	this.ai_state = STATE_CHASING;
	this.enemy = player;
}

void check_and_chase(entity this)
{
	entity pl = check_for_player(this);
	if(pl)
		chase_player(this, pl);
}

void shroom_think(entity this)
{
	vector angles_to_player;
	if(time - this.pain_time < 0.8)
	{
		this.frame = 3;
		this.nextthink = time + 0.1;
		setthink(this, shroom_think);
		CSQCMODEL_AUTOUPDATE(this);
		return;
	}
	switch(this.ai_state)
	{
		case STATE_STANDING:
		{
			this.frame = 0;
			changeyaw(this);
			if(random() > 0.9)
			{
				this.ai_state = STATE_MOVING;
				this.ideal_yaw = random() * 360;
			}
			check_and_chase(this);
			break;
		}
		case STATE_MOVING:
		{
			this.frame = 1;
			changeyaw(this);
			changeyaw(this);
			t_walkmove(this, this.ideal_yaw, 5);
			if(random() > 0.9)
			{
				this.ai_state = STATE_STANDING;
				this.ideal_yaw = random() * 360;
			}
			check_and_chase(this);
			break;
		}
		case STATE_CHASING:
		{
			this.frame = 1;
			if(check_for_player(this))
				this.last_seen_time = time;
			if(time - this.last_seen_time > 3 || this.enemy.health <= 0)
			{
				this.enemy = NULL;
				this.ai_state = STATE_STANDING;
				break;
			}
			angles_to_player = vectoangles(this.enemy.origin - this.origin);
			this.ideal_yaw = angles_to_player.y;
			this.goalentity = this.enemy;
			changeyaw(this);
			t_movetogoal(this, 10);
			
			if(vdist(this.enemy.origin - this.origin, <, 60))
			{
				this.ai_state = STATE_ATTACKING;
				this.ai_attack_time = time;
			}
			break;
		}
		case STATE_ATTACKING:
		{
			this.frame = 2;
			angles_to_player = vectoangles(this.enemy.origin - this.origin);
			this.ideal_yaw = angles_to_player.y;
			changeyaw(this);
			if(time - this.ai_attack_time > 0.6 && !this.ai_attacked)
			{
				if(vdist(this.enemy.origin - this.origin, <, 65) && this.enemy && this.enemy.health > 0)
				{
					damage(this, this.enemy, 1);
					STAT(NO_CONTROL_TIME, this.enemy) = time + 0.35;
					this.enemy.velocity = normalize(this.enemy.origin - this.origin) * 200 + '0 0 200';
					UNSET_ONGROUND(this.enemy);
				}
				this.ai_attacked = true;
			}
			if(time - this.ai_attack_time > 1.0)
			{
				this.ai_state = STATE_CHASING;
				this.ai_attacked = false;
				
				if(this.enemy.health <= 0)
				{
					this.enemy = NULL;
					this.ai_state = STATE_STANDING;
				}
			}
			break;
		}
	}
	this.nextthink = time + 0.1;
	setthink(this, shroom_think);
	CSQCMODEL_AUTOUPDATE(this);
}

void shroom_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher) || toucher.health <= 0)
		return;
	if(toucher.origin_z > (this.origin_z + (this.maxs_z * 0.66)))
	{
		STAT(NO_CONTROL_TIME, toucher) = time + 0.25;
		toucher.velocity = randomvec() * 100 + '0 0 250';
		UNSET_ONGROUND(toucher);
		setorigin(toucher, toucher.origin + '0 0 2');
		damage(toucher, this, 5);
	}
}

void spiky_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher) || toucher.health <= 0)
		return;
	
	STAT(NO_CONTROL_TIME, toucher) = time + 0.25;
	toucher.velocity = randomvec() * 100 + '0 0 250';
	UNSET_ONGROUND(toucher);
	setorigin(toucher, toucher.origin + '0 0 2');
	damage(this, toucher, 1);
}

spawnfunc(monster_shroom)
{
	if(this.home == '0 0 0')
		this.home = this.origin;
	this.solid = SOLID_BBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.takedamage = DAMAGE_YES;
	this.hurt = shroom_hurt;
	this.die = shroom_die;
	this.yaw_speed = 10;
	this.nextthink = time + random() * 0.5;
	setthink(this, shroom_think);
	this.frame = -1;
	
	switch(this.variant)
	{
		default:
		case VARIANT_NORMAL:
		{
			setmodel(this, MDL_MUSHROOM);
			this.health = 30;
			settouch(this, shroom_touch);
			break;
		}
		case VARIANT_SPIKY:
		{
			setmodel(this, MDL_MUSHROOM2);
			this.health = 50;
			settouch(this, spiky_touch);
			break;
		}
	}
	setsize(this, '-20 -20 0', '20 20 48');

	CSQCMODEL_AUTOINIT(this);
}
