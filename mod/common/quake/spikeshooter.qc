SOUND(SPIKE_FIRE, "quake_weapons/spike2");

MODEL(PROJECTILE_SPIKE, "progs/spike.mdl");

int PROJECTILE_SPIKE;

STATIC_INIT(SpikeShooterProjectile) { PROJECTILE_SPIKE = MOD_PROJECTILES++; }

#ifdef CSQC
REGISTER_MUTATOR(spikeshooter_projectile, true);

MUTATOR_HOOKFUNCTION(spikeshooter_projectile, Ent_Projectile)
{
	entity proj = M_ARGV(0, entity);

	if(proj.cnt == PROJECTILE_SPIKE)
	{
		setmodel(proj, MDL_PROJECTILE_SPIKE);
		proj.traileffect = 0;
		return true;
	}
}

MUTATOR_HOOKFUNCTION(spikeshooter_projectile, PrecacheProjectiles)
{
	precache_model("progs/spike.mdl");
}
#endif

#ifdef SVQC

const int SPIKESHOOTER_SUPERSPIKE = 1;
const int SPIKESHOOTER_LASER = 2;

void spikeshooter_explode(entity this, entity directhitentity)
{
	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;

	RadiusDamage(
		this,
		this.realowner,
		this.dmg,
		this.cnt,
		50,
		world,
		world,
		0,
		this.projectiledeathtype,
		directhitentity
	);

	remove(this);
}

void spikeshooter_explode_use(entity this, entity actor, entity trigger)
{
	spikeshooter_explode(this, trigger);
}

void spikeshooter_touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);
	spikeshooter_explode(this, toucher);
}

void spikeshooter_fire(entity this, entity actor, entity trigger)
{
	entity proj;
	bool is_laser = (this.spawnflags & SPIKESHOOTER_LASER);

	W_SetupShot_ProjectileSize(
		this,
		'0 0 -3',
		'0 0 -3',
		false,
		0,
		SND_SPIKE_FIRE,
		CH_WEAPON_A,
		this.dmg
	);

	proj = spawn();
	proj.classname = "spikeshooter_spike";
	proj.owner = proj.realowner = this;
	proj.bot_dodge = true;
	proj.bot_dodgerating = this.dmg;
	proj.use = spikeshooter_explode_use;
	setthink(proj, adaptor_think2use);
	proj.nextthink = time + 7;
	PROJECTILE_MAKETRIGGER(proj);
	proj.dmg = this.dmg;
	proj.projectiledeathtype = WEP_MACHINEGUN.m_id;
	setorigin(proj, this.origin);

	if(is_laser)
		proj.cnt = this.dmg * 0.7;

	set_movetype(proj, MOVETYPE_FLY);
	W_SetupProjVelocity_Explicit(proj, this.movedir, v_up, 500, 0, 0, 0, false);
	proj.angles = vectoangles(proj.velocity);
	settouch(proj, spikeshooter_touch);
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, proj);

	CSQCProjectile(proj, true, ((is_laser) ? PROJECTILE_BLASTER : PROJECTILE_SPIKE), false);

	MUTATOR_CALLHOOK(EditProjectile, this, proj);
}

void spikeshooter_think(entity this)
{
	spikeshooter_fire(this, NULL, NULL);

	this.nextthink = time + this.wait;
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

	setthink(this, spikeshooter_think);
	this.nextthink = this.nextthink + this.wait + this.ltime;
	this.hitplotfh = -1; // fail
}

#endif
