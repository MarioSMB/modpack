// vengeance sphere

// ==============================
// sphere_impact
// ==============================
void sphere_impact(entity this, entity toucher)
{
	if(toucher.health)
		T_Damage(toucher, this, this, 1000);

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this, 300, toucher);

//	sound (this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	this.origin = this.origin - 8 * normalize(this.velocity);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	BecomeExplosion(this);
}

void sphere_remove(entity this)
{
	bool message_shown = false;
	FOREACH_ENTITY_CLASS("Vengeance", it.owner == this,
	{
		if(!message_shown)
		{
			message_shown = true;
			bprintf("%s is denied Vengeance.\n", it.owner.netname);
		}
		delete(it);
	});
}

// ==============================
// sphere_attack
// ==============================
void sphere_attack(entity this)
{
	this.solid = SOLID_TRIGGER;
	settouch(this, sphere_impact);

	if(this.enemy.health < 1)
	{
		sprint(this.owner, "You are denied Vengeance");
		delete(this);
		return;
	}

	ai_track(this, this.enemy, 650);
	this.nextthink = time + 0.1;
	setthink(this, sphere_attack);
}

// ==============================
// sphere_think
// ==============================
void sphere_think(entity this)
{
	if(this.shieldSoundTime < time)
	{
		_sound( this, CH_VOICE, "sphere/sphere.wav", 1, ATTN_NORM);
		this.shieldSoundTime = time + 4;
	}
	
	if(time > this.delay)
	{
		if(this.owner.powerups & POWERUP_V_SPHERE)
			this.owner.powerups &= ~POWERUP_V_SPHERE;
		sprint( this.owner, "Vengeance Sphere Lost\n");
		delete(this);
		return;
	}

	if(this.owner.health < 1)
	{
		if(this.owner.powerups & POWERUP_V_SPHERE)
			this.owner.powerups &= ~POWERUP_V_SPHERE;
		if(IS_PLAYER(this.owner.enemy))
		{
			this.enemy = this.owner.enemy;
			sphere_attack(this);
			return;
		}
		if(IS_PLAYER(this.owner.enemy.owner)) // wtf lol
		{
			this.enemy = this.owner.enemy.owner; // mikee would be proud
			sphere_attack(this);
			return;
		}
		delete(this);
		return;
	}
	
	ai_orbit(this, this.owner, 16, '0 0 48');
	
	setthink(this, sphere_think);
	this.nextthink = time + 0.1;
}

// ==============================
// sphere_spawn
// ==============================
void sphere_spawn(entity this, entity toucher)
{
	entity missile = new(Vengeance);
	set_movetype(missile, MOVETYPE_FLYMISSILE);
//	missile.solid = SOLID_BBOX;
	missile.solid = SOLID_NOT;
	missile.owner = toucher;
	missile.weapon = 0;
	missile.delay = time + 30;
	_setmodel(missile, "progs/sphere.mdl");
	setsize(missile, '0 0 0', '0 0 0');     
	setorigin(missile, this.origin);
	missile.avelocity = '40 40 40';
	setthink(missile, sphere_think);
	missile.nextthink = time + 0.1;
}

/*QUAKED item_sphere (0 0 1) (-8 -8 -8) (8 8 8) ?
The Vengeance Sphere. DEATHMATCH ONLY.
*/
spawnfunc(item_sphere)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(!deathmatch) { delete(this); return; }

	precache_model("progs/sphere.mdl");
	precache_sound("sphere/sphere.wav");

	this.noise = "sphere/sphere.wav";
	this.netname = "Vengeance Sphere";
	settouch(this, newitems_touch);

	_setmodel(this, "progs/sphere.mdl");
	setsize(this, '-8 -8 -8', '8 8 8');
	this.avelocity = '40 40 40';
	StartItem(this);
}
