#include "evile.qh"

#include "../subs/combat.qh"
#include "../subs/subs.qh"

void evile_5(entity this) { set_anim(this, 4, SUB_Remove); }
void evile_4(entity this) { set_anim(this, 3, evile_5); }
void evile_3(entity this) { set_anim(this, 2, evile_4); }
void evile_2(entity this) { set_anim(this, 1, evile_3); }
void evile_1(entity this) { set_anim(this, 0, evile_2); }

void evile_go(entity this)
{
	vector v = '0 0 0';
	v.y = random() * 360;
	makevectors(v);
	
	vector org = this.origin + v_forward * random() * this.summon_count;
	traceline(this.origin, org, true, this);

	entity e = findradius(trace_endpos, 30);
	while(e)
	{
		if(e.takedamage )
			if(!friendly(e, this))
				T_Damage(this.owner, e, this.dama, 3);
		e = e.chain;
	}
	e = spawn();
	_setmodel(e, "progs/evile.spr");
	setorigin(e, trace_endpos);
	setthink(e, evile_1);
	e.nextthink = time;
	if(time > this.ltime)
	{
		_sound(this, CH_VOICE, "misc/null.wav", 1, ATTN_NORM);
		delete(this);
	}
	else
		this.nextthink = time + 0.08;
}
