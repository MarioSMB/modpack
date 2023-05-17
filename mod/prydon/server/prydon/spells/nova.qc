#include "nova.qh"

#include "../subs/combat.qh"
#include "../subs/subs.qh"

void nova_9(entity this) { set_anim(this, 8, SUB_Remove); this.nextthink = time + 0.05; }
void nova_8(entity this) { set_anim(this, 7, nova_9); this.nextthink = time + 0.05; }
void nova_7(entity this) { set_anim(this, 6, nova_8); this.nextthink = time + 0.05; }
void nova_6(entity this) { set_anim(this, 5, nova_7); this.nextthink = time + 0.05; }
void nova_5(entity this) { set_anim(this, 4, nova_6); this.nextthink = time + 0.05; }
void nova_4(entity this) { set_anim(this, 3, nova_5); this.nextthink = time + 0.05; }
void nova_3(entity this) { set_anim(this, 2, nova_4); this.nextthink = time + 0.05; }
void nova_2(entity this) { set_anim(this, 1, nova_3); this.nextthink = time + 0.05; }
void nova_1(entity this) { set_anim(this, 0, nova_2); this.nextthink = time + 0.05; }

void nova_go(entity this, float lev)
{
	_sound(this, CHAN_AUTO, "spells/nova.wav", 1, ATTN_NORM);
	entity m = spawn();
	this.effects |= EF_MUZZLEFLASH;
	
	_setmodel(m, "progs/nova.mdl");
	setorigin(m, this.origin + '0 0 -20');
	setthink(m, nova_1);
	m.nextthink = time;
	entity e = findradius(this.origin, 128);
	while(e)
	{
		if(e.takedamage && !friendly(e, this))
			LightningDamage(this, e, 12 + ceil(lev * lev * 2.5));
		e = e.chain;
	}
}
