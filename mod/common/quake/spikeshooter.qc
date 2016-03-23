SOUND(SPIKE_FIRE, "quake_weapons/spike2");

MODEL(PROJECTILE_SPIKE, "progs/spike.mdl");

int PROJECTILE_SPIKE;

STATIC_INIT(SpikeShooterProjectile) { PROJECTILE_SPIKE = MOD_PROJECTILES++; }

#ifdef CSQC
REGISTER_MUTATOR(spikeshooter_projectile, true);

MUTATOR_HOOKFUNCTION(spikeshooter_projectile, Ent_Projectile)
{
	if(self.cnt == PROJECTILE_SPIKE)
	{
		setmodel(self, MDL_PROJECTILE_SPIKE);
		self.traileffect = 0;
		return true;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(spikeshooter_projectile, PrecacheProjectiles)
{
	precache_model("progs/spike.mdl");
}
#endif

#ifdef SVQC

const int SPIKESHOOTER_SUPERSPIKE = 1;
const int SPIKESHOOTER_LASER = 2;

void spikeshooter_explode()
{SELFPARAM();
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage(
		self,
		self.realowner,
		self.dmg,
		self.cnt,
		50,
		world,
		world,
		0,
		self.projectiledeathtype,
		other
	);

	remove(self);
}

void spikeshooter_touch()
{
	PROJECTILE_TOUCH;
	spikeshooter_explode();
}

void spikeshooter_fire()
{SELFPARAM();
	entity proj;
	bool is_laser = (self.spawnflags & SPIKESHOOTER_LASER);

	W_SetupShot_ProjectileSize(
		self,
		'0 0 -3',
		'0 0 -3',
		false,
		0,
		SND_SPIKE_FIRE,
		CH_WEAPON_A,
		self.dmg
	);

	proj = spawn();
	proj.classname = "spikeshooter_spike";
	proj.owner = proj.realowner = self;
	proj.bot_dodge = true;
	proj.bot_dodgerating = self.dmg;
	proj.use = spikeshooter_explode;
	proj.think = proj.use;
	proj.nextthink = time + 7;
	PROJECTILE_MAKETRIGGER(proj);
	proj.dmg = self.dmg;
	proj.projectiledeathtype = WEP_MACHINEGUN.m_id;
	setorigin(proj, self.origin);

	if(is_laser)
		proj.cnt = self.dmg * 0.7;

	proj.movetype = MOVETYPE_FLY;
	W_SetupProjVelocity_Explicit(proj, self.movedir, v_up, 500, 0, 0, 0, false);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = spikeshooter_touch;
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.flags = FL_PROJECTILE;

	CSQCProjectile(proj, true, ((is_laser) ? PROJECTILE_BLASTER : PROJECTILE_SPIKE), false);

	MUTATOR_CALLHOOK(EditProjectile, self, proj);
}

void spikeshooter_think()
{
	spikeshooter_fire();

	self.nextthink = time + self.wait;
}

spawnfunc(trap_spikeshooter)
{
	SetMovedir(this);

	if(!this.dmg)
		this.dmg = 9;

	if(this.spawnflags & SPIKESHOOTER_SUPERSPIKE)
		this.dmg = 18;

	this.use = spikeshooter_fire;
	this.hitplotfh = -1; // fail
}

spawnfunc(trap_shooter)
{
	spawnfunc_trap_spikeshooter(this);

	if(!this.wait)
		this.wait = 1;

	this.think = spikeshooter_think;
	this.nextthink = this.nextthink + this.wait + this.ltime;
	this.hitplotfh = -1; // fail
}

#endif
