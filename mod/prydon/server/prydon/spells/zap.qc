#include "zap.qh"

#include "../subs/combat.qh"
#include "../subs/subs.qh"

void zap_go(entity this, float lev)
{
	makevectors(this.angles);
	_sound(this, CH_WEAPON_SINGLE, "spells/lit.wav", 1, ATTN_NORM);
	vector lightvec;
	lightvec.x = this.origin.x + v_forward.x * 8;
	lightvec.y = this.origin.y + v_forward.y * 8;
	lightvec.z = this.origin.z + 16;
	SendCSQCLightningBeam(lightvec, this.enemy.origin);
	if(lev == 0)
		LightningDamage(this, this.enemy, 6);	
	else
		LightningDamage(this, this.enemy, 10 + lev * lev);	
	lev = lev - 3;
	entity laste = this.enemy;
	
	while(lev > 0)
	{
		entity e = findradius(laste.origin, 100);
		while(e)
		{
			if(e != laste)
			{
				if(e.takedamage && (e.dmg_take != time))
				{
					if(!friendly(e, this))
					{
						SendCSQCLightningBeam(laste.origin, e.origin);
						laste = e;
						e.dmg_take = time;
						LightningDamage(this, e, 15 + ceil(lev * lev * 1.4));
					}
				}
			}
			e = e.chain;
		}
		lev = lev - 2;	
	}
}
