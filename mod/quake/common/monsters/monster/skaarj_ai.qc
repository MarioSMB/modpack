#include "skaarj_ai.qh"

#ifdef SVQC
bool sk_checkprojectiles(entity this)
{
	if(time < this.sk_dodge_finished)
		return false;

	this.sk_dodge_finished = time + 1;

	entity e = findradius(this.origin, 512);

	while(e)
	{
		if(e.move_movetype == MOVETYPE_FLYMISSILE)
		{
			if(e.owner == this.enemy)
			{
				vector missiledir = normalize(e.velocity);

				traceline(e.origin, e.origin + missiledir*1000, false, e);

				if(trace_fraction < 1)
				{
					if(trace_ent == this)
					{
						if(random() < 0.5)
							skaarj_leftdodge1(this);
						else
							skaarj_rightdodge1(this);

						return true;
					}
				}
			}
		}
		e = e.chain;
	}
	return false;
}

bool sk_checkenemy(entity this)
{
	if(this.enemy.health <= 0 || (this.enemy.flags & FL_NOTARGET))
	{
		this.enemy = NULL;
	// FIXME: look all around for other targets
		if(this.oldenemy.health > 0)
		{
			this.enemy = this.oldenemy;
			HuntTarget(this);
		}
		else
		{
			if(this.movetarget)
				this.th_walk(this);
			else
				this.th_stand(this);
			return false;
		}
	}

	this.show_hostile = time + 1;		// wake up other monsters

	// check knowledge of enemy
	this.enemy_visible = visible(this, this.enemy);
	if(this.enemy_visible)
		this.search_time = time + 5;

	// look for other coop players
	if(coop && this.search_time < time)
	{
		if(FindTarget(this))
			return false;
	}

	return true;
}

bool sk_checkrefire(entity this)
{
	vector enemydist = (this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs);
	float rnd = random();

	return ((vdist(enemydist, <, 200) && rnd < 0.3) || (vdist(enemydist, >=, 200) && rnd < 0.7));
}

bool sk_checkrunfire(entity this)
{
	return (random() < 0.2);
}

bool sk_trycharge(entity this)
{
	if(vdist(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs, <, 200))
	{
		setthink(this, skaarj_run_charge1);
		return true;
	}
	return false;
}

bool sk_tryrun(entity this)
{
	if(vdist(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs, <, 200))
	{
		setthink(this, skaarj_run1);
		return true;
	}
	return false;
}

bool sk_trymelee(entity this)
{
	if(vdist(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs, <, 80))
	{
		setthink(this, skaarj_melee);
		return true;
	}
	return false;
}

bool sk_tryspin(entity this)
{
	if(vdist(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs, <, 80))
	{
		setthink(this, skaarj_spin1);
		return true;
	}
	return false;
}

void sk_fight(entity this, float dist)
{
// see if the enemy is dead
	
	if(!sk_checkenemy(this))
		return;

	this.enemy_range = range(this, this.enemy);
	this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);

	makevectors(this.angles);
	vector vec = normalize(this.enemy.origin - this.origin);

	if((vec * v_forward) < 0.7)
	{
		this.sk_strafe_finished = time + 2 + random()* 2;
		if((vec * v_right) > 0)
			setthink(this, skaarj_straferight_fr1);
		else
			setthink(this, skaarj_strafeleft_fr1);
		return;
	}

	//if(sk_trycharge()) return;

	if(sk_trymelee(this))
		return;

	if(sk_tryrun(this))
		return;

	if(time > this.skaarj_fight_finished)
	{
		skaarj_run1(this);
		return;
	}

	if(CheckAnyAttack(this))
		return;	
	
	if(sk_checkprojectiles(this))
		return;

	if(dist)
		t_movetogoal(this, dist);
}

void sk_side(entity this, float dist, float yaw)
{
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	changeyaw(this);
	t_walkmove(this, this.ideal_yaw + yaw, dist);
}

void sk_strafe(entity this, float dist, float yaw)
{
	if(sk_checkprojectiles(this))
		return;
	sk_trymelee(this);
	sk_side(this, dist, yaw);

	if(time > this.sk_strafe_finished)
		setthink(this, skaarj_fight);
}

void sk_run_charge(entity this, float dist)
{
	if(!sk_checkenemy(this))
		return;

	makevectors(this.angles);
	this.enemy_range = range(this, this.enemy);
	this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
	vector enemy_dir = normalize(this.enemy.origin - this.origin);

	if(vdist(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs, <, 120) && this.attack_finished < time)
	{
		if((enemy_dir * v_forward) > 0.5)
		{
			skaarj_lunge1(this);
			return;
		}
		else
			sk_trymelee(this);
	}

	t_movetogoal(this, dist);
}

void sk_run(entity this, float dist)
{
	if(!sk_checkenemy(this))
		return;

	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	changeyaw(this);

	if(sk_trycharge(this))
		return;

	if(sk_checkprojectiles(this))
		return;

	if(time > this.sk_strafe_finished)
	{
		this.sk_strafe_yaw = crandom() * 100;
		if(random() < 0.30)
			this.sk_strafe_yaw *= -1;
		this.sk_strafe_finished = time + 0.3;
	}

	t_walkmove(this, this.ideal_yaw + this.sk_strafe_yaw, dist);
}
#endif
