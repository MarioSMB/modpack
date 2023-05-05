#include "impaler.qh"

#ifdef SVQC
void T_SpearTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	float knockback;
	float r = random();
	if(toucher.takedamage && (IS_CLIENT(toucher) || IS_MONSTER(toucher)))
	{
		_setmodel(this, "progs/impstuck.mdl");
		if(IS_CLIENT(toucher))
			knockback = 400 - (toucher.armorvalue * 3);
		else if(toucher.monsterdef == MON_ROTTWEILER)
			knockback = 550;
		else if(toucher.monsterdef == MON_ZOMBIE)
			knockback = 250;
		else if(toucher.monsterdef == MON_GRUNT)
			knockback = 450;
		else if(toucher.monsterdef == MON_KNIGHT || toucher.monsterdef == MON_DARK_KNIGHT)
			knockback = 250;
		else if(toucher.monsterdef == MON_ENFORCER || toucher.monsterdef == MON_LIGHTNING_ENFORCER)
			knockback = 300;
		else if(toucher.monsterdef == MON_OGRE)
			knockback = 100;
		else if(toucher.monsterdef == MON_HELL_KNIGHT)
			knockback = 150;
		else if(toucher.monsterdef == MON_GRENLING)
			knockback = 550;
		else if(toucher.monsterdef == MON_VORE)
			knockback = 100;
		else
			knockback = 0;
		if(knockback > 10)
		{
			if(IS_ONGROUND(toucher))
			{
				UNSET_ONGROUND(toucher);
				setorigin(toucher, toucher.origin + '0 0 1');
			}
			makevectors(this.angles);
			toucher.velocity = toucher.velocity + v_forward * knockback;
			toucher.velocity_z = toucher.velocity_z + knockback / 2;
		}
	}
	if(toucher.takedamage 
		&& (toucher.monsterdef == MON_JUGGERNAUT
			|| toucher.monsterdef == MON_CHTHON || toucher.monsterdef == MON_SHUB || toucher.monsterdef == MON_LEGOND 
			|| toucher.monsterdef == MON_KNIGHT || toucher.monsterdef == MON_DARK_KNIGHT || toucher.monsterdef == MON_HELL_KNIGHT || toucher.monsterdef == MON_SHAMBLER) 
			|| (IS_PLAYER(toucher) && toucher.armorvalue > 1))
	{
		_setmodel(this, "progs/impdef.mdl");
		T_Damage(toucher, this, this.owner, 50);
		if(r < 0.4)
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef1.wav", 1, ATTN_NORM);
		else if(r < 0.7)
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef3.wav", 1, ATTN_NORM);
		if(toucher.health > 0)
			T_Damage(toucher, this, this.owner, 50);
		set_movetype(this, MOVETYPE_BOUNCE);
		this.velocity = this.velocity * 0.35;
		this.avelocity = '300 300 300';
		this.solid = SOLID_NOT;
		setsize(this, '0 0 0', '0 0 0');
		setthink(this, Spear_Bounce_Think);
		this.nextthink = time + 0.5;
		this.count = time + 3;
	}
	else if(((toucher.monsterdef == MON_GRUNT || toucher.monsterdef == MON_SCRAG || toucher.monsterdef == MON_ROTTWEILER) && random() < 0.5) || toucher.monsterdef == MON_ROTFISH)
	{
		T_Damage (toucher, this, this.owner, 5000);
		entity missile = spawn();
		missile.owner = this.owner;
		set_movetype(missile, MOVETYPE_FLYMISSILE);
		missile.solid = SOLID_BBOX;
		missile.classname = "spear";
		makevectors(this.angles);
		missile.velocity = this.movedir;
		missile.angles = vectoangles(missile.velocity);
		missile.movedir = missile.velocity;
		missile.avelocity_z = crandom() * 500;
		missile.count = 0;
		settouch(missile, T_SpearTouch);
		toucher.nextthink = time + 4;
		setthink(toucher, SUB_Remove);
		_setmodel(missile, "progs/impstuck.mdl");
		setsize(missile, '0 0 0', '0 0 0');
		setorigin(missile, this.origin + v_forward);
		delete(this);
	}
	else if(toucher.takedamage && (IS_CLIENT(toucher) || IS_MONSTER(toucher)) && toucher.armorvalue == 0 && 
		(IS_PLAYER(toucher) || toucher.monsterdef == MON_ENFORCER || toucher.monsterdef == MON_LIGHTNING_ENFORCER 
		|| toucher.monsterdef == MON_OGRE || toucher.monsterdef == MON_FIEND 
		|| toucher.monsterdef == MON_BLUD || toucher.monsterdef == MON_GRENLING
		|| toucher.monsterdef == MON_GRUNT || toucher.monsterdef == MON_ROTTWEILER || toucher.monsterdef == MON_SCRAG || toucher.classname == "wall_explode"))
	{
		_setmodel(this, "progs/impstuck.mdl");
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impale.wav", 1, ATTN_NORM);
		if(IS_PLAYER(toucher) || toucher.monsterdef == MON_ENFORCER || toucher.monsterdef == MON_LIGHTNING_ENFORCER)
		{
			BecomeBloodSpurt(this, 25);
			T_Damage(toucher, this, this.owner, 25);
			BecomeBloodSpurt(this, 25);
		}
		if(!(toucher.monsterdef == MON_GRENLING || toucher.monsterdef == MON_GRUNT 
				|| toucher.monsterdef == MON_ROTTWEILER || toucher.monsterdef == MON_SCRAG || toucher.monsterdef == MON_ROTFISH))
		{
			BecomeBloodSpurt(this, 25);
			T_Damage(toucher, this, this.owner, 25);
			BecomeBloodSpurt(this, 25);
		}
		this.enemy = toucher;
		this.cnt = this.enemy.health;
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_NOT;
		setorigin(this, this.origin + normalize(this.velocity) * 30);
		this.v_angle = this.angles - this.enemy.angles;
		this.mangle = this.origin - this.enemy.origin;
		this.mangle_x = this.mangle_x * 0.05;
		this.mangle_y = this.mangle_y * 0.05;
		this.mangle_z = this.mangle_z * 0.1 + 10;
		setthink(this, SpearThink);
		this.nextthink = time + 0.1;
		if(toucher.monsterdef == MON_GRENLING || toucher.monsterdef == MON_GRUNT 
			|| toucher.monsterdef == MON_ROTTWEILER || toucher.monsterdef == MON_SCRAG || toucher.monsterdef == MON_ROTFISH)
		{
			T_Damage (toucher, this, this.owner, 5000);
			BecomeBloodSpurt(this, 5000);
		}
	}
	else if(toucher.takedamage)
	{
		_setmodel(this, "progs/impdef.mdl");
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impale.wav", 1, ATTN_NORM);
		T_Damage (toucher, this, this.owner, 50);
		BecomePurpleExplosion(this, toucher, 50);
		if(r < 0.4)
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef1.wav", 1, ATTN_NORM);
		else if(r < 0.7)
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impdef3.wav", 1, ATTN_NORM);
		BecomePurpleExplosion(this, toucher, 50);
		set_movetype(this, MOVETYPE_BOUNCE);
		this.velocity = this.velocity * 0.05;
		this.avelocity = '300 300 300';
		this.solid = SOLID_NOT;
		setsize(this, '0 0 0', '0 0 0');
		setthink(this, Spear_Bounce_Think);
		this.nextthink = time + 0.5;
		this.count = time + 3;
	}
	else if(toucher.solid == SOLID_BSP || toucher.move_movetype == MOVETYPE_PUSH || IS_CLIENT(toucher) || IS_MONSTER(toucher))
	{
		_setmodel(this, "progs/impwall.mdl");
		BecomePurpleExplosion(this, toucher, 50);
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impwall.wav", 1, ATTN_NORM);
		BecomePurpleExplosion(this, toucher, 50);
		set_movetype(this, MOVETYPE_BOUNCE);
		this.velocity = this.velocity * 0.35;
		this.avelocity = '300 300 300';
		this.solid = SOLID_NOT;
		setsize(this, '0 0 0', '0 0 0');
		setthink(this, Spear_Bounce_Think);
		this.nextthink = time + 0.5;
		this.count = time + 3;
	}
	else
	{
		_setmodel(this, "progs/impwall.mdl");
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impwall.wav", 1, ATTN_NORM);
		BecomePurpleExplosion(this, toucher, 50);
		makevectors(this.angles);
		setorigin(this, this.origin + normalize(this.velocity) * -4);
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_NOT;
		this.nextthink = time + 0.1;
		setthink(this, SpearDig);
	}
}

void SpearDig3(entity this)
{
	float r = random();
	this.nextthink = time + r + 1;
	setthink(this, SpearExplosion);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearDig2(entity this)
{
	float r = random();
	this.nextthink = time + r;
	setthink(this, SpearDig3);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearDig(entity this)
{
	float r = random();
	this.nextthink = time + r;
	setthink(this, SpearDig2);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void ImpaledGibs(entity this)
{
	ThrowHead(this, "progs/gib3.mdl", this.health);
	ThrowGib(this, "progs/gib2.mdl", this.health);
	ThrowGib(this, "progs/gib2.mdl", this.health);
	ThrowGib(this, "progs/gib1.mdl", this.health);
	ThrowGib(this, "progs/rawbone.mdl", this.health);
	ThrowGib(this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, "progs/rawbone2.mdl", this.health);
	if(IS_PLAYER(this))
		this.impaled = false;
}

void ImpaledExplosion(entity this)
{
	if(this.enemy.health <= 0)
	{
		T_RadiusDamage(this, this.owner, 60, NULL);
		BecomeBloodSpurt(this, 60);
		this.enemy.health = this.enemy.health - 60 - random() * 100;
		setorigin(this, this.origin - 8 * normalize(this.velocity));
		setthink(this.enemy, ImpaledGibs);
		this.enemy.nextthink = time;
		_sound(this.enemy, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		BecomeBloodSpurt(this, 60);
		_sound(this.enemy, CHAN_BODY, "weapons/impaler/impex.wav", 1, ATTN_NORM);
	}
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	BecomeExplosion(this);
}

void SpearExplosion(entity this)
{
	T_RadiusDamage(this, this.owner, 60, NULL);
	setorigin(this, this.origin - 16 * normalize(this.velocity));
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	BecomeExplosion(this);
}

void SpearGo3(entity this)
{
	float r = random();
	BecomeBloodSpurt(this, 0);
	this.nextthink = time + r + 1;
	BecomeBloodSpurt(this, 0);
	setthink(this, ImpaledExplosion);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if((r < 0.6))
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearGo2(entity this)
{
	float r = random();
	BecomeBloodSpurt(this, 0);
	this.nextthink = time + 1 + r;
	BecomeBloodSpurt(this, 0);
	setthink(this, SpearGo3);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearGo(entity this)
{
	float r = random();
	BecomeBloodSpurt(this, 0);
	this.nextthink = time + 1 + r;
	BecomeBloodSpurt(this, 0);
	setthink(this, SpearGo2);
	BecomePurpleExplosion(this, NULL, 0);
	if(r < 0.3)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft1.wav", 1, ATTN_NORM);
	else if(r < 0.6)
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "weapons/impaler/shaft3.wav", 1, ATTN_NORM);
	BecomePurpleExplosion(this, NULL, 0);
}

void SpearThink(entity this)
{
	setorigin(this, this.enemy.origin + this.mangle);
	this.angles = this.enemy.angles + this.v_angle;
	if(IS_CLIENT(this.enemy) || this.enemy.monsterdef == MON_ENFORCER || IS_PLAYER(this.enemy) || this.enemy.monsterdef == MON_LIGHTNING_ENFORCER)
	{
		if(!(this.flags & FL_NOTARGET))
		{
			makevectors(this.angles);
			traceline(this.origin + v_forward * 20, this.origin, true, this);
			if(trace_startsolid)
			{
				this.classname = "impaler";
				this.enemy.health = 1;
				BecomeBloodSpurt(this, 15);
				T_Damage(this.enemy, this, this.owner, 15);
				BecomeBloodSpurt(this, 15);
				entity fork = spawn();
				fork.solid = SOLID_NOT;
				setorigin(fork, this.origin - v_forward * 10);
				fork.nextthink = time;
				setthink(fork, func_null);
				this.solid = SOLID_NOT;
				this.nextthink = time + 0.1;
				setthink(this, SpearGo);
				return;
			}
		}
	}
	if(IS_ONGROUND(this.enemy) && !(this.flags & FL_NOTARGET))
	{
		this.flags = FL_NOTARGET;
		BecomeBloodSpurt(this, 37);
		T_Damage(this.enemy, this, this.owner, 37);
		BecomeBloodSpurt(this, 37);
	}
	if(this.enemy.health <= 0 || this.enemy.health > this.cnt || random() < 0.01)
	{
		set_movetype(this, MOVETYPE_BOUNCE);
		this.velocity = this.velocity * 0.05;
		this.avelocity = '300 300 300';
		this.solid = SOLID_NOT;
		setsize(this, '0 0 0', '0 0 0');
		setthink(this, Spear_Bounce_Think);
		this.nextthink = time + 0.5;
		this.count = time + 3;
		return;
	}
	this.cnt = this.enemy.health;
	this.count = this.count + 1;
	if((random() * 10) < this.count)
	{
		SpawnBlood(this.origin, '0 0 0', this.count, this.enemy);
		BecomeBloodSpurt(this, this.count / 2);
		T_Damage(this.enemy, this, this.owner, this.count / 2);
		if(this.enemy.health <= 5 && IS_PLAYER(this.enemy))
			T_Damage(this.enemy, this, this.owner, 5);
		BecomeBloodSpurt(this, this.count / 2);
		this.count = 0;
	}
	this.nextthink = time + 0.1;
}

void Spear_Bounce_Think(entity this)
{
	if(this.velocity == '0 0 0' || this.count < time)
		delete(this);
	else
		this.nextthink = time + 0.1;
}

void impale(entity this)
{
	if(this.monsterdef == MON_ENFORCER || this.monsterdef == MON_LIGHTNING_ENFORCER)
	{
		_sound(this, CHAN_BODY, "player/udeath.wav", 1, ATTN_NORM);
		BecomeBloodSpurt(this, 0);
		_sound(this, CHAN_ITEM, "weapons/impaler/mimpale.wav", 1, ATTN_NORM);
		BecomeBloodSpurt(this, 0);
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_NOT;
		setthink(this, func_null);
		this.ammo_shells = 5;
		DropBackpack(this);
		if(random() < 0.2)
			this.frame = 83;
		else if(random() < 0.4)
			this.frame = 79;
		else if(random() < 0.6)
			this.frame = 80;
		else if(random() < 0.8)
			this.frame = 78;
		else
			this.frame = 84;
	}
	else
	{
		if(IS_PLAYER(this))
		{
			this.impaled = true;
			this.powerups &= ~POWERUP_INVISIBILITY;
			this.invisible_finished = 0;
			this.invincible_finished = 0;
			this.super_damage_finished = 0;
			this.radsuit_finished = 0;
			this.modelindex = this.modelindex_player;
			if(deathmatch || coop)
				DropBackpack(this);
			this.view_ofs = '0 0 -4';
			this.nextthink = -1;
			this.deadflag = DEAD_DEAD;
			this.solid = SOLID_NOT;
			UNSET_ONGROUND(this);
			set_movetype(this, MOVETYPE_NONE);
			BecomeBloodSpurt(this, 0);
			DeathSound(this);
			BecomeBloodSpurt(this, 0);
			_sound(this, CHAN_ITEM, "weapons/impaler/pimpale.wav", 1, ATTN_NORM);
			BecomeBloodSpurt(this, 0);
			this.angles_x = this.angles_z = 0;
			if(this.weaponentity.m_weapon == WEP_AXE)
			{
				if(random() < 0.3)
					this.frame = 31;
				else if(random() < 0.6)
					this.frame = 35;
				else
					this.frame = 42;
			}
			else if(random() < 0.3)
				this.frame = 61;
			else if(random() < 0.6)
				this.frame = 71;
			else
				this.frame = 87;
		}
	}
}

void W_FireSpear(entity this)
{
	this.currentammo = this.ammo_rockets = this.ammo_rockets - 1;
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "spear";
	makevectors(this.v_angle);
	missile.velocity = qc_aim(this, 2000);
	missile.velocity = missile.velocity * 2000;
	missile.angles = vectoangles(missile.velocity);
	missile.movedir = missile.velocity;
	missile.avelocity_z = crandom() * 500;
	missile.count = 0;
	settouch(missile, T_SpearTouch);
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/impaler.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin + (v_forward * 8) + '0 0 16');
	if(IS_ONGROUND(this))
	{
		UNSET_ONGROUND(this);
		setorigin(this, this.origin + '0 0 1');
	}
	this.velocity = this.velocity - (v_forward * (600 - this.armorvalue)) + '0 0 50';
	this.punchangle_x = -10;
}

METHOD(Impaler, wr_think, void(entity thiswep, entity actor))
{
	player_shotimp1(actor);
	actor.attack_finished = time + 1;
}
METHOD(Impaler, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
