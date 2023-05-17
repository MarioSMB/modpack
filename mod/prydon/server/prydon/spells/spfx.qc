#include "spfx.qh"

#include "../anim/cast.qh"
#include "sval.qh"

void create_fx(entity this, float fram, float sp)
{
	vector org, inc;
	int thecnt, i;
	if(netplay)
		return;
	sp &= 63;
	vector ang = this.angles;
	makevectors(ang);
	if(sp == SP_FIREBALL)
	{
		org = this.origin + v_forward * 8 + v_up * 13 + v_right * -16;
		particle(org, v_right * 2, 235, 3);
		org = org + v_right * 32;
		particle(org, v_right * -2, 235, 3);
	}
	else if(sp == SP_ZAP)
	{	
		// not very fancy
		org = this.origin + v_forward * 16;
		particle(org, '0 0 10', 12, 3);
		
	}
	else if(sp == SP_ICEBLAST)
	{
		ang_y += fram * 60;
		makevectors(ang);
		org = v_forward * 8 + v_up * 13;
		particle(this.origin + org, v_right * -8, 211, 3);
	}
	else if(sp == SP_WARP)
	{
		particle(this.origin + fram * '0 0 5', '0 0 5', 180, 10);	
		particle(this.origin + fram * '0 0 -5', '0 0 -5', 180, 10);			
	}
	else if(sp == SP_POISONBALL)
	{
		org = this.origin + v_forward * 16;
		thecnt = fram * 4;
		for (i = 1; i < thecnt; i = i + 1)
		{
			ang_z = (360/thecnt ) * i;
			makevectors(ang);
			particle(org + fram * 2.5 * v_up, v_up * 5, 59, 3);
		}
	}
	else if(sp == SP_LEECH)
	{
	
		ang = this.origin - this.enemy.origin;
		inc = ang * (1/5);
		
		if(vlen(ang) > 9)
			ang = normalize(ang) * 9;
		org = this.origin + v_up * 22;
		
		for (i = 1; i < 5; i = i + 1)
		{
			particle(org + (inc * i), ang, 74, 6);
		}
		/*
		ang = this.origin - this.enemy.origin;
		if(vlen(ang) > 9)
			ang = normalize(ang) * 9;
		particle(this.enemy.origin, ang, 74, 6);
		*/
	}
	else if(sp == SP_HEAL)
	{
		thecnt = 13 / fram;
		for(i = 1; i < thecnt; i = i + 1)
		{
			org = '0 0 -24' + this.origin + fram * '0 0 10';
			org_x = org_x + (random() * fram * 10) -  (fram * 5);
			org_y = org_y + (random() * fram * 10) -  (fram * 5);
			particle(org, '0 0 100', 45, 3);
		}
	}
	else if(sp == SP_SHIELD)
	{
		org = this.origin + v_forward * 16;
		particle(org + v_up * 16 - (v_right * 16), v_right * 3.2, 45, 5);
		particle(org + v_up * 16 + (v_right * 16), v_up * -3.2, 45, 5);
		particle(org + v_up * -16 + (v_right * 16), v_right * -3.2, 45, 5);
		particle(org + v_up * -16 - (v_right * 16), v_up * 3.2, 45, 5);
	}
	else if(sp == SP_TRANSMUTE)
	{
		particle(this.enemy.origin, '0 0 0', 43, 3);
		particle(this.enemy.origin, '0 0 0', 75, 3);
		particle(this.enemy.origin, '0 0 0', 195, 3);
		particle(this.enemy.origin, '0 0 0', 251, 3);
	}
	else if(sp == SP_REPEL)
	{
	
		org = this.origin;
		thecnt = fram * 4;
		for (i = 1; i < thecnt; i = i + 1)
		{
			ang_y = (360/thecnt ) * i;
			makevectors(ang);
			particle(org + fram * 2.5 * v_forward, v_forward * 5, 132, 3);
		}
	}
	else if(sp == SP_NOVA)
	{
		org = this.origin;
		thecnt = fram * 4;
		for (i = 1; i < thecnt; i = i + 1)
		{
			ang_y = (360/thecnt ) * i;
			makevectors(ang);
			particle(org + fram * 2.5 * v_forward, v_forward * 5, 45, 3);
		}
	}
	else if(sp == SP_TWISTER)
	{	
		thecnt = fram * 4;
		for (i = 1; i < thecnt; i = i + 1)
		{
			ang_y = (360/thecnt ) * i;
			makevectors(ang);
			org = fram * 2.5 * (v_forward + v_up);
			particle(this.origin + org, '0 0 0' - org, 12, 3);
		}
	}
	else if(sp == SP_TELEPORT)
	{
		particle(this.origin + fram * '0 0 5', '0 0 5', 109, 10);	
		particle(this.origin + fram * '0 0 -5', '0 0 -5', 109, 10);			
	}
	else if(sp == SP_SUMMON)
	{
		org = this.origin + v_forward * 8 + v_up * 13 + v_right * -16;
		particle(org, v_right * 2, 210, 3);
		org = org + v_right * 32;
		particle(org, v_right * -2, 210, 3);
	}
	else if(sp == SP_METEOR)
	{
		thecnt = fram * 4;
		for (i = 1; i < thecnt; i = i + 1)
		{
			ang_y = (360/thecnt ) * i;
			makevectors(ang);
			org = fram * 2.5 * (v_forward + v_up);
			particle(this.origin + org, (v_forward + v_up) * 100, 235, 3);
		}
	}
	else if(sp == SP_EVILE)
	{
		thecnt = 13 / fram;
		fram = 6 - fram;
		for(i = 1; i < thecnt; i = i + 1)
		{
			org = '0 0 -24' + this.origin + fram * '0 0 10';
			org_x = org_x + (random() * fram * 10) -  (fram * 5);
			org_y = org_y + (random() * fram * 10) -  (fram * 5);
			particle(org, '0 0 -10', 235, 3);
		}
	}
	else if(sp == SP_HEALOTHER)
	{
		thecnt = 13 / fram;
		for(i = 1; i < thecnt; i = i + 1)
		{
			org = '0 0 -24' + this.m_subject.player.origin + fram * '0 0 10';
			org_x = org_x + (random() * fram * 10) -  (fram * 5);
			org_y = org_y + (random() * fram * 10) -  (fram * 5);
			particle(org, '0 0 100', 45, 3);
		}
		if(fram == 5)
			this.m_subject = NULL;
	}
	else if(sp == SP_SUMMON_LOCAL)
	{
		org = this.origin + v_forward * 8 + v_up * 13 + v_right * -16;
		particle(org, v_right * 2, 210, 3);
		org = org + v_right * 32;
		particle(org, v_right * -2, 210, 3);
	}
	else if(sp == SP_FREEZE)
	{
		ang = this.enemy.origin - this.origin;
		inc = ang * (1/5);
		
		if(vlen(ang) > 9)
			ang = normalize(ang) * 9;
		org = this.origin + v_up * 22;
		
		for (i = 1; i < 5; i = i + 1)
		{
			particle(org + (inc * i), ang, 211, 30);
		}
	}
}
