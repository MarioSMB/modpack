#include "monster.qh"

#include "../spells/sval.qh"
#include "../subs/math.qh"

spawnfunc(monster)
{
	if(!this.lvl)
		this.lvl = 1;
	if(!this.ai)
		this.ai = AI_HUNT_PLAYER;
	if(!this.team)
		this.team = 1;
	this.classname = "monster";
	this.flags |= FL_MONSTER;
	
	spawnfunc_npc(this);
}

void monster_randomize(entity this)
{
	float pf = 0, sf = 0;
	this.lvl = this.lvl * skillm;
	
	this.str = this.agil = this.vit = this.mag = this.dex = this.luck = (this.lvl * 2);
	this.max_health = 5 * this.lvl;

	this.max_mana = 10 * this.lvl;
	float r = rint(this.lvl + (random() * (this.lvl / 2)) - (this.lvl / 4)) - this.value;
	if(random() < 0.5)
	{
		if(r < monsvalue)
		{
			// apply a good prefix/suffix to make the monster better
			if(random() < 0.2)
				pf = ceil(random() * MP_GOOD) + MP_BAD; // # of bad prefixes
			if(random() < 0.2)
				sf = ceil(random() * MS_GOOD) + MS_BAD; // # of bad suffixes
			r = r + ((pf - MP_BAD) * 2) - ((sf - MS_BAD) * 2);
		}
		if(r > monsvalue)
		{
			// avoid making monsters TOO bad
			if(random() < 0.2)
				pf = ceil(random() * MP_BAD); // # of bad prefixes
			if(random() < 0.2)
				sf = ceil(random() * MS_BAD); // # of bad suffixes
			r = r - (pf * 2) - (sf * 2);		
		}		
	}
	if(pf == MP_INFERIOR)
	{
		this.str = this.str - 5;
		this.max_health = ceil(this.max_health * 0.5);
		this.tohit = this.tohit - 10;
		this.scale = 0.9;
	}
	else if(pf == MP_WEAK)
	{
		this.str = this.str - 5;
		this.max_health = ceil(this.max_health * 0.25);
	}
	else if(pf == MP_SICK)
		this.max_health = ceil(this.max_health * 0.1);
	else if(pf == MP_CRIPPLED)
	{
		this.tohit = this.tohit - 60;
		this.dodge = this.dodge - 60;
	}
	else if(pf == MP_ELDERLY)
	{
		this.agil = this.agil - 10;
		this.speed = this.speed * 0.5;
	}
	else if(pf == MP_CLUMSY)
		this.dex = this.dex - 10;
		
	else if(pf == MP_FAST)
	{
		this.agil = this.agil + 10;
		this.speed = this.speed * 2;
		this.aspeed = this.aspeed + 33;
	}
	else if(pf == MP_MUSCULAR)
	{
		// muscular
		this.str = this.str + 25;
	}
	else if(pf == MP_SUPERIOR)
	{
		// superior
		this.tohit = this.tohit + 50;
		this.str = this.str + 10;
		this.max_health = this.max_health * 1.8;
		this.scale = 1.1;
	}
	else if(pf == MP_HEALTHY)
	{
		this.max_health = this.max_health * 3;
	}
	else if(pf == MP_FIERY)
	{
		this.fire = this.fire + 2 + floor(0.25 * this.lvl);
		this.res_fire = this.res_fire + 30;
	}
	else if(pf == MP_VILE)
	{
		this.poidam = this.poidam + 5;
		this.res_poison = this.res_poison + 30;
	}
	else if(pf == MP_HELL)
	{
		this.fire = this.fire + 15;
		this.res_fire = this.res_fire + 30;
		this.agil = this.agil + 5;
		this.speed = this.speed * 1.5;
		this.aspeed = this.aspeed + 10;
	}
	else if(pf == MP_ARMOR)
	{
		this.ac = this.ac + 10 * this.lvl;
	}
	else if(pf == MP_WARDED)
	{
		this.res_mag = this.res_mag + 10  + floor(0.1 * this.lvl);
	}
	else if(pf == MP_BURNING)
	{
		this.fire = this.fire + 5  + floor(0.25 * this.lvl);
		this.res_fire = this.res_fire + 80;
	}
	else if(pf == MP_ENRAGED)
	{
		this.tohit = this.tohit + 50;
		this.speed = this.speed * 1.2;
		this.aspeed = this.aspeed + 10;
	}
	else if(pf == MP_CHARGED)
	{
		this.lit = 5 + floor(0.25 * this.lvl);
		this.res_lit = this.res_lit + 50 + floor(0.25 * this.lvl);
	}
	else if(pf == MP_FROSTY)
	{
		this.cold = 5 + floor(0.25 * this.lvl);
		this.res_cold = this.res_cold + 50 + floor(0.25 * this.lvl);
	}
	if(sf == MS_PUPIL)
		this.tohit = this.tohit - 7;
	else if(sf == MS_OAF)
	{
		this.tohit = this.tohit - 10;
		this.dodge = this.dodge - 10;
	}
	else if(sf == MS_LUMMOX)
	{
		this.dex = this.dex - 20;
	}
	else if(sf == MS_IMBECILE)
	{
		this.mag = this.mag - 10;
		this.max_mana = 10;
	}
	else if(sf == MS_WEAKLING)
	{
		this.str = this.str - 50;
	}
	else if(sf == MS_DAWDLER)
	{
		this.speed = this.speed * 0.5;
	}
	else if(sf == MS_VAMPIRE)
		this.spec = this.spec | SPEC_STEAL_LIFE;
	else if(sf == MS_MASTER)
	{
		// superior
		this.tohit = this.tohit + 50;
		this.str = this.str + 10;
		this.max_health = this.max_health * 1.8;
	}
	else if(sf == MS_CHAMPION)
	{
		// superior
		this.tohit = this.tohit + 50;
		this.str = this.str + 20;
		this.dex = this.dex + 10;
		this.max_health = this.max_health * 3;
		this.visibility = 30;
	}
	else if(sf == MS_WIZARD)
	{
		if(random() < 0.5)
			this.spell = SP_ZAP;
		else
			this.spell = SP_FIREBALL; // for now
	}
	else if(sf == MS_MAGE)
	{
		this.spell = SP_ZAP; // for now;
	}
	else if(sf == MS_CLERIC)
	{
		this.spell = SP_HEALOTHER - 8; // for now HACK! -- legacy_npc adds 8 to all spells over 16
		this.health_regen = 10;
	}
	else if(sf == MS_CHIEFTAIN)
	{
		this.max_health = this.max_health * 3;
		this.res_mag = this.res_mag + 10 + floor(0.25 * this.lvl);
		this.ac = this.ac + 10 + floor(0.25 * this.lvl);
	}
	else if(sf == MS_BESERKER)
	{
		this.tohit = this.tohit - 10;
		this.agil = this.agil + 10;
		this.speed = this.speed * 1.7;
		this.aspeed = this.aspeed + 15;
	}
	this.monnum = recode(this.monnum, 2, pf);
	this.monnum = recode(this.monnum, 3, sf);

	this.experience = floor(r * 2.5);
	if(this.experience < 1)
		this.experience = 1;
	r = floor(ceil(r / monsvalue) * random() + random());
	if((r > 0) && (!this.slot1))
		this.droprandom = this.droprandom | 1;
	if((r > 1) && (!this.slot2))
		this.droprandom = this.droprandom | 2;
	if((r > 2) && (!this.slot3))
		this.droprandom = this.droprandom | 4;

	this.spawnfunc_checked = true;
	spawnfunc_monster(this);
	this.max_health = ceil(this.max_health * 0.7);
	this.health = this.max_health;
	this.tohit = this.tohit - 15; // monsters take a 15% tohit penalty
	this.dodge = this.dodge - 20; // monsters take a 25% dodge penalty
}
