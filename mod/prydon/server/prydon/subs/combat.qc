#include "combat.qh"

#include "../stats/exp.qh"
#include "../stats/stats.qh"
#include "subs.qh"

void SpawnBlood(vector org, vector vel, float damage)
{
	particle(org, vel*0.1, 73, damage*2);
}

void T_Damage(entity attacker, entity targ, float dam, float magdam)
{
	if(!targ.takedamage)
		return;

	targ = targ.owner;
	attacker = attacker.owner;
	
	if(targ.flags & FL_GODMODE)
		return;
		
	float r = 0;
	
	if(!magdam)
	{
		if((random() * 100) > attacker.piercing)
		{
			if(targ.ac > 50)
				r = (dam * 0.5) + ((targ.ac - 50) / 10);
			else
				r = targ.ac / 100 * dam;
		}
	}
	else if(targ.shield_time > time)
	{
		r = (targ.ac * targ.shield_factor) / 3;

	}
	
	
	if(!magdam)
	{
		if(random() < dam/r)
			DamageEquipment(targ, 0);
		if(attacker)
			if(random() < dam/r)
				DamageEquipment(attacker, 1);
	}
	else
	{
		if(attacker.skill & SKILL_SPELLS)
			dam = dam + dam * ((attacker.title_x + 1) / 7);
			
		if(magdam == 1)
			r = r + dam * (targ.res_fire/100);
		else if(magdam == 2)
			r = r + dam * (targ.res_poison/100);
		else if(magdam == 3)
			r = r + dam * (targ.res_lit/100);
		else if(magdam == 4)
			r = r + dam * (targ.res_cold/100);
		else
			r = r + dam * (targ.res_mag/100);
	}
		
	dam = dam - floor(r);
	if(magdam)
		dam = dam - targ.magic_reduced;
	else
		dam = dam - targ.damage_reduced;
			
	if(dam < 1)
	{
		if(dam > 0)
		{
			if(random() > dam)
				return;
		}
		else
			return;
		dam = 1;
	}

	if(!magdam)
	{
	
		if(attacker.spec & SPEC_DAZE)
			targ.player.daze_time = time + 5;
		if(attacker.spec & SPEC_STEAL_LIFE)
			attacker.health = attacker.health + dam / 2;
		if(targ.attacker_dam)
			T_Damage(targ, attacker, dam * (targ.attacker_dam / 100), 1);
		if(targ.attacker_fire)
			FireDamage(targ, attacker, targ.attacker_fire);
		if(targ.attacker_lit)
			LightningDamage(targ, attacker, targ.attacker_lit);
		if(targ.attacker_cold)
			ColdDamage(targ, attacker, targ.attacker_cold);
		if(targ.attacker_poison)
			PoisonDamage(targ, attacker, targ.attacker_cold);
		if(attacker.spec & SPEC_STEAL_MANA)
			attacker.mana = attacker.mana + dam / 3;
		if(attacker.spec & SPEC_KNOCKBACK)
		{
			targ.player.flags = targ.flags - (targ.flags & FL_ONGROUND);
			targ.player.velocity = targ.velocity + normalize(targ.player.origin - attacker.player.origin) * 300;
			targ.player.velocity_z = 212;
		}
		if(attacker.spec & SPEC_MORTAL_WOUND)
		{
			if(random() < 0.3)
			{
				if(targ.flags & FL_CLIENT)
					sprint(targ, "You have sustained a mortal wound.\n");
				targ.player.mortal_factor = targ.health;
				targ.player.misc = targ.player.misc | MISC_MORTAL_WOUND;
				targ.player.poison_inflictor = attacker;

			}
		}
		if(attacker.spec & SPEC_MAIM)
		{
			if(random() < 0.3)
			{
				if(targ.flags & FL_CLIENT)
					sprint(targ, "You have been maimed.\n");
				targ.player.misc = targ.player.misc | MISC_MAIMED;
			}
		}
	}

	targ.health = targ.health - dam;
	if(targ.ai)
	{
		if(getthink(targ) == AnimatePlayer)
		{
			targ.enemy = attacker.player;
			targ.goalentity = NULL;
		}
	}
	if(attacker)
		boundstats(attacker);
	if(targ.health < 1)
	{

		if((targ.flags & FL_CLIENT) || ((targ.ai & AI_FOLLOW) && targ.classname != "helper"))
			bprint(targ.netname, " was killed by ", attacker.netname, "\n");
		
		targ = targ.player;
		
		if(targ.die)
		{
			targ.die(targ, true);
			//call(targ.die, targ);
		}
		if(attacker)
			GiveExp(attacker, targ, targ.experience);
	}
	else
	{
		targ = targ.player;
		if(targ.pain)
			targ.pain(targ, attacker, NULL);
			
		if(magdam != 2) // no screams for poison
			if(targ.noise3)
				if(random() < 0.5)
					_sound(targ, CH_VOICE, targ.noise3, 1, ATTN_NORM);
	}

	
}

void fire7(entity this) { set_anim(this, 6, SUB_Remove); }
void fire6(entity this) { set_anim(this, 5, fire7); setorigin(this, this.enemy.origin); }
void fire5(entity this) { set_anim(this, 4, fire6); setorigin(this, this.enemy.origin); }
void fire4(entity this) { set_anim(this, 3, fire5); setorigin(this, this.enemy.origin); }
void fire3(entity this) { set_anim(this, 2, fire4); setorigin(this, this.enemy.origin); }
void fire2(entity this) { set_anim(this, 1, fire3); setorigin(this, this.enemy.origin); }
void fire1(entity this) { set_anim(this, 0, fire2); setorigin(this, this.enemy.origin); }

void FireDamage(entity attacker, entity targ, float dam)
{
	if(targ.player)
		targ = targ.player;		
	entity e = spawn();
	_setmodel(e, "progs/fire.spr");
	e.solid = SOLID_NOT;
	e.enemy = targ;
	setthink(e, fire1);
	e.nextthink = time;
	set_movetype(e, MOVETYPE_NONE);
	e.effects = EF_DIMLIGHT;
	
	float f = (dam / 2) * random() + (dam / 2);
	targ.cold_time = time;
	targ.cold_factor = 1;
	_sound(targ, CHAN_AUTO, "spells/fhit.wav", 1, ATTN_NORM);
	T_Damage(attacker, targ, f, 1);
}

void ColdDamage(entity attacker, entity targ, float dam)
{
	if(targ.player)
		targ = targ.player;
	float f = (dam / 2) * random() + (dam / 2);
	T_Damage(attacker, targ, f, 4);
	if(targ.cold_time < time)
	{	
		_sound(targ, CHAN_AUTO, "spells/freeze.wav", 1, ATTN_NORM);
	
		te_teleport(targ.origin);
	}
	float res = (targ.owner.lvl - attacker.owner.lvl) / 10;
	
	res = res + (res * (targ.owner.res_mag / 100));
	res = res + (res * (targ.owner.res_cold / 100));
	res = res + (res * (targ.owner.shield_factor));
	if(res < 0.175)
		res = 0.175;
	else if(res > 0.9)
		res = 0.9;

	targ.cold_time = time + 5 + (2 * (1/res));
	targ.cold_factor = targ.cold_factor * res;
	updateskins(targ);
}

void MagicDamage(entity attacker, entity targ, float dam)
{
	if(targ.player)
		targ = targ.player;

	T_Damage(attacker, targ, dam, 5);
	targ.effects |= EF_MUZZLEFLASH;
}

void PoisonDamage(entity attacker, entity targ, float dam)
{
	if(targ.player)
		targ = targ.player;
	if(targ.poison_count > 0)
	{
		targ.poison_count = targ.poison_count + dam;
		targ.poison_factor = targ.poison_factor + 1;
	}
	else
	{
		targ.poison_count = dam;
		targ.poison_factor = 1;
	}
	targ.poison_inflictor = attacker;

	_sound(targ, CHAN_AUTO, "wizard/hit.wav", 1, ATTN_NORM);
}

void LightningDamage(entity attacker, entity targ, float dam)
{
	if(targ.player)
		targ = targ.player;
	if(!targ)
		return;
		
	targ.effects |= EF_MUZZLEFLASH;

	vector v = targ.maxs - targ.mins;
	vector o = targ.origin + targ.mins;
	vector org1;
	org1.x = o.x = (v.x * random());
	org1.y = o.y = (v.y * random());
	org1.z = o.z = v.z;
	vector org2;
	org2.x = o.x + (v.x * random());
	org2.y = o.y + (v.y * random());
	org2.z = o.z;

	SendCSQCLightningBeam(org1, org2);

	int f = ceil(random() * dam);
	if(!f)
		f = 1;
	_sound(targ, CHAN_AUTO, "spells/lhit.wav", 1, ATTN_NORM);
	T_Damage(attacker, targ, f, 3);
}

bool hitcheck(float a, float b)
{
	if(a < 1)
	{
		b += (1 - a);
		a = 1;
	}
	else if(b < 1)
	{
		a += (1 -  b);
		b = 1;
	}

	return ((a / b) * 0.3 < random());
}

bool MagicHit(entity inflictor, entity attacker, entity targ) // projectiles (TODO: something)
{
	if(friendly(attacker, targ))
		return false;
	if(!targ.takedamage)
		return false;
	
	targ = targ.owner;
	attacker = attacker.owner;
	if(!((targ.cold_time > time) || (targ.misc & MISC_MAIMED)))
	{
		if(hitcheck(attacker.tohit, targ.block))
		{
			if(random() < 0.5)
				DamageEquipment(targ, 0);
			_sound(targ.player, CHAN_AUTO, "player/block.wav", 1, ATTN_NORM);
			// hack
			if(getthink(targ))
			{
				setthink(targ, AnimatePlayer);
				targ.frame = targ.attackframes+1;
				targ.dbltime = 1;
			}
			return false;
		}
	}
	if(inflictor.fire)
		FireDamage(attacker, targ, inflictor.fire);
	if(inflictor.lit)
		LightningDamage(attacker, targ, inflictor.lit);
	if(inflictor.poidam)
		PoisonDamage(attacker, targ, inflictor.poidam);
	if(inflictor.cold)
		ColdDamage(attacker, targ, inflictor.cold);
	if(inflictor.magic)
		MagicDamage(attacker, targ, inflictor.magic);
	return true;	
}

bool Hit(entity attacker, entity targ, float special)
{
	entity realtarg = targ;
	if((targ.spec & SPEC_MELEE_IMMUNE) && special == SKILL_MELEE)
		return false;
	if(targ.spec & SPEC_MISSILE_IMMUNE)
	{
		if(special == SKILL_BOW)
			return false;
		if(special == SKILL_THROW)
			return false;
	}
	if(attacker.daze_time > time)
		if(random() < 0.5)
			return false;
	if(friendly(attacker, targ))
		return false;

	if(!targ.takedamage)
		return false;
	if(targ.ai)
	{
		targ.enemy = attacker;
		targ.goalentity = NULL;
	}
	
	targ = targ.owner;
	attacker = attacker.owner;
	float dam = (attacker.daml + random() * attacker.dama);
	if(attacker.player.frenzy_time > time)
		dam = dam * dam * (attacker.player.frenzy_factor / 100);
	if(special != SKILL_SPRINT)
	{
		if((targ.cold_time > time) || (targ.misc & MISC_MAIMED))
		{
			if(hitcheck(attacker.tohit, 0))
				return false;
		}
		else if(hitcheck(attacker.tohit, targ.dodge))
			return false;
		else if(hitcheck(attacker.tohit, targ.block))
		{
			if(random () < 0.5)
				DamageEquipment(targ, 0);
			_sound(realtarg, CHAN_AUTO, "player/block.wav", 1, ATTN_NORM);
			return false;
		}
		if(attacker.skill & special)
		{
			dam = dam + dam * ((attacker.title_x + 1) / 7);
		}
	}
	if((random() * 100) < attacker.critical)
	{
		// crappy..
		entity e = spawn();
		_setmodel(e, "progs/critical.spr");
		if(IS_CLIENT(attacker))
			stuffcmd(attacker, "bf\n");
		setorigin(e, realtarg.origin - (normalize(realtarg.origin - attacker.player.origin) * 32));
		setthink(e, evile_1);
		e.nextthink = time;
		dam *= 3;
	}
	if(targ.takedamage == DAMAGE_AIM)
		SpawnBlood(realtarg.origin - (normalize(realtarg.origin - attacker.player.origin) * 32), '0 0 0', dam);
	T_Damage(attacker, targ, dam, 0);
	if(attacker.fire)
		FireDamage(attacker, targ, attacker.fire);
	if(attacker.lit)
		LightningDamage(attacker, targ, attacker.lit);
	if(attacker.poidam)
		PoisonDamage(attacker, targ, attacker.poidam);
	if(attacker.cold)
		ColdDamage(attacker, targ, attacker.cold);

	return true;	
}
