#include "sphere.qh"

// ==============================
// sphere_impact
// ==============================
void sphere_impact(entity this, entity toucher)
{
	if(toucher.health)
		T_Damage(toucher, this, this.owner, 150, this.projectiledeathtype);

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, 150, this.projectiledeathtype, toucher);

//	sound (this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	setorigin(this, this.origin - 8 * normalize(this.velocity));

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	BecomeExplosion(this);
}

void sphere_remove(entity this)
{
	IL_EACH(g_vspheres, it.owner == this,
	{
		delete(it);
	});
}

// ==============================
// sphere_attack
// ==============================
void sphere_chase(entity this)
{
	if(this.enemy.health < 1 || wasfreed(this.enemy) || wasfreed(this.owner))
	{
		delete(this);
		return;
	}
	ai_track(this, this.enemy, 650);
	this.nextthink = time + 0.1;
	setthink(this, sphere_chase);
}

void sphere_attack(entity this, entity targ)
{
	this.enemy = targ;

	this.solid = SOLID_TRIGGER;
	settouch(this, sphere_impact);

	sphere_chase(this);
}

// ==============================
// sphere_think
// ==============================
void sphere_think(entity this)
{
	if(time > this.delay)
	{
		delete(this);
		return;
	}

	if(this.shieldSoundTime < time)
	{
		_sound(this, CH_WEAPON_SINGLE, "sphere/sphere.wav", 1, ATTN_NORM);
		this.shieldSoundTime = time + 4;
	}

	if(this.owner.health < 1 || wasfreed(this.owner))
	{
		delete(this);
		return;
	}

	if(time > this.owner.vsphere_last)
	{
		makevectors(this.owner.v_angle);

		entity selected = W_PickNearbyTarget(this, this.owner, 700, true, false);
		if(selected)
		{
			this.owner.vsphere_last = time + 3;
			sphere_attack(this, selected);
			return;
		}
		// otherwise only check a single sphere once per second
		this.owner.vsphere_last = time + 1;
	}
	
	ai_orbit(this, this.owner, 16, '0 0 48');
	
	setthink(this, sphere_think);
	this.nextthink = time + 0.1;
}

// ==============================
// sphere_spawn
// ==============================
void sphere_spawn(entity item, entity player)
{
	entity missile = new(Vengeance);
	set_movetype(missile, MOVETYPE_FLYMISSILE);
//	missile.solid = SOLID_BBOX;
	missile.solid = SOLID_NOT;
	missile.owner = player;
	missile.weapon = 0;
	missile.delay = time + 30;
	missile.projectiledeathtype = DEATH_SPHERE.m_id;
	_setmodel(missile, "progs/sphere.mdl");
	setsize(missile, '0 0 0', '0 0 0');     
	setorigin(missile, item.origin);
	missile.avelocity = '40 40 40';
	setthink(missile, sphere_think);
	missile.nextthink = time + 0.1 + random();
	IL_PUSH(g_vspheres, missile);
}

/*QUAKED item_sphere (0 0 1) (-8 -8 -8) (8 8 8) ?
The Vengeance Sphere. DEATHMATCH ONLY.
*/
spawnfunc(item_sphere)
{
	//if(!deathmatch) { delete(this); return; }

	precache_model("progs/sphere.mdl");
	precache_sound("sphere/sphere.wav");

	this.noise = "sphere/sphere.wav";
	this.netname = "Vengeance Sphere";
	this.powerups = POWERUP_V_SPHERE;
	settouch(this, powerup_touch);

	_setmodel(this, "progs/sphere.mdl");
	setsize(this, '-8 -8 -8', '8 8 8');
	this.avelocity = '40 40 40';
	StartItem(this);
}
