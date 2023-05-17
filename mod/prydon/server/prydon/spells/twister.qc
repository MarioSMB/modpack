#include "twister.qh"

#include "../subs/combat.qh"
#include "../subs/subs.qh"

void twister_start(entity this)
{
	if(this.frame < 23)
	{
		this.frame = this.frame + 1;
		this.nextthink = time + 0.05;
	}
	else if(time > this.ac)
	{
		if(this.frame < 48)
		{
			this.frame = this.frame + 1;
			this.nextthink = time + 0.05;
		}
		else
		{
			_sound(this, CH_WEAPON_SINGLE, "misc/null.wav", 1, ATTN_NORM);
			delete(this);
		}
	}
	else
	{
		entity e = findradius(this.origin, 80);
		while(e)
		{
			if(e.takedamage)
			{
				if(!friendly(e, this))
				{
					UNSET_ONGROUND(e);
					vector v = normalize(e.origin - this.origin);
					v.z = 0;
					vector r = '0 0 0';
					r.x = v.y;
					r.y = v.x * -1;
					r = r - v * 0.15;
					r = r * vlen(e.origin - this.origin) * 8;
					e.velocity = r + '0 0 31';
					if(this.attack_finished < time)
					{
						if(random() < 0.4)
							T_Damage(this.owner, e, 1, 4);
						this.attack_finished = time + 0.1;
					}
				}
			}
			e = e.chain;
		}
		makevectors(this.mangle);
		if(random() < 0.1)
			this.mangle_y = this.mangle_y + random() * 180 - 90;
		this.velocity = v_forward * 100;
		UNSET_ONGROUND(this); // LordHavoc 20040417: this was - FL_ONGROUND, which really messed up flags if it wasn't set
		if(!netplay)
		{
			for(int i = 0; i < 9; i = i + 1)
			{
				this.finalangle_y = this.finalangle_y + 10;
				makevectors(this.finalangle);
				particle(this.origin + v_up * (i * 6) + v_forward * (i * 5), v_right * (i * 10) + v_up * 5, 12, 3);
			}
		}		
		this.nextthink = time + 0.01;
	}
}

void twister_go(entity this, float lev)
{
	entity e = spawn();
	setorigin(e, this.enemy.origin - '0 0 20');
	e.frags = lev;
	_setmodel(e, "progs/twister.mdl");
	_sound(e, CH_WEAPON_SINGLE, "spells/twist.wav", 1, ATTN_NORM);
	e.mangle = this.angles;
	setthink(e, twister_start);
	e.owner = this;
	e.solid = SOLID_TRIGGER;
	set_movetype(e, MOVETYPE_FLY);
	setsize(e, '-32 -32 0', '32 32 78');
	e.team = this.team;
	e.nextthink = time;
	e.ac = time + 1 + lev * 3;
	e.effects = EF_ADDITIVE;
	e.alpha = 0.75;
}
