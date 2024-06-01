#ifdef SVQC

void bar_spin1(entity this);
void bar_spin6(entity this) { set_anim(this, 5, bar_spin1); }
void bar_spin5(entity this) { set_anim(this, 4, bar_spin6); }
void bar_spin4(entity this) { set_anim(this, 3, bar_spin5); }
void bar_spin3(entity this) { set_anim(this, 2, bar_spin4); }
void bar_spin2(entity this) { set_anim(this, 1, bar_spin3); }
void bar_spin1(entity this)
{
	set_anim(this, 0, bar_spin2);
	if(random() < 0.2)
		_sound(this, CHAN_AUTO, "enviro/physics/trspin1.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "enviro/physics/trspin2.wav", 1, ATTN_NORM);
}

void TrapbarTouch(entity this, entity toucher)
{
	if(this.dmgtime < time)
	{
		float damg = 200 + (random() * 100);
		if(random() < 0.5)
			_sound(this, CHAN_AUTO, "enviro/physics/spill1.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "enviro/physics/spill2.wav", 1, ATTN_NORM);
		if(random() < 0.5)
			_sound(this, CHAN_AUTO, "enviro/physics/pour.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "enviro/physics/trkild.wav", 1, ATTN_NORM);
		_sound(this, CHAN_AUTO, "enviro/physics/trcut.wav", 1, ATTN_NORM);
		_sound(this, CHAN_AUTO, "enviro/physics/trcut.wav", 1, ATTN_NORM);
		_sound(this, CHAN_AUTO, "enviro/physics/trcut.wav", 1, ATTN_NORM);
		T_Damage(toucher, this, this, damg, DEATH_TRAP.m_id);
		this.dmgtime = (time + 0.1);
	}
}

void dropblood(entity this)
{
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_NOT;
	missile.nextthink = time + 1;
	setthink(missile, SUB_Remove);
	this.nextthink = (time + 0.2);
	setthink(this, dropblood);
	if(random() < 0.5)
		_sound(this, CHAN_AUTO, "enviro/physics/spill2.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_AUTO, "enviro/physics/spill1.wav", 1, ATTN_NORM);
	_setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	missile.velocity_z = ((missile.velocity_z + 250) + (50 * random()));
	missile.avelocity = '3000 1000 2000';
	setorigin(missile, this.origin);
}

void trapbar_explode(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CHAN_AUTO, "enviro/physics/trstop.wav", 1, ATTN_NORM);
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	ThrowGib(this, inflictor, "progs/spidgib.mdl", ((this.health - 40) - (random() * 40)));
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	BecomeExplosion(this);
}

void trapbar_pain(entity this, entity attacker, float damage, int deathtype)
{
	this.health = 5000;
}

spawnfunc(trapbar)
{
	if(!MP_IMPEL) { delete(this); return; }

	this.solid = SOLID_BBOX;
	set_movetype(this, MOVETYPE_NONE);
	precache_model("progs/trapbar.mdl");
	precache_model("progs/spidgib.mdl");
	precache_sound("enviro/physics/trkild.wav");
	precache_sound("enviro/physics/pour.wav");
	precache_sound("enviro/physics/spill1.wav");
	precache_sound("enviro/physics/spill2.wav");
	precache_sound("enviro/physics/trspin1.wav");
	precache_sound("enviro/physics/trspin2.wav");
	precache_sound("enviro/physics/trcut.wav");
	precache_sound("enviro/physics/trstop.wav");
	_setmodel(this, "progs/trapbar.mdl");
	settouch(this, TrapbarTouch);
	setsize(this, '-100 -34 -34', '100 34 34');
	this.nextthink = time + 0.2;
	setthink(this, dropblood);
	this.health = 5000;
	this.takedamage = DAMAGE_YES;
	this.th_die = trapbar_explode;
	this.th_pain = trapbar_pain;
	bar_spin1(this);
}

#endif
