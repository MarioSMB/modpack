.entity sprite;

.float dmg;
.float dmg_edge;
.float dmg_radius;
.float dmg_force;
.float debrismovetype;
.float debrissolid;
.vector debrisvelocity;
.vector debrisvelocityjitter;
.vector debrisavelocityjitter;
.float debristime;
.float debristimejitter;
.float debrisfadetime;
.float debrisdamageforcescale;
.float debrisskin;

.string mdl_dead; // or "" to hide when broken
.string debris; // space separated list of debris models
// other fields:
//   mdl = particle effect name
//   count = particle effect multiplier
//   targetname = target to trigger to unbreak the model
//   target = targets to trigger when broken
//   health = amount of damage it can take
//   spawnflags:
//     1 = start disabled (needs to be triggered to activate)
//     2 = indicate damage
// notes:
//   for mdl_dead to work, origin must be set (using a common/origin brush).
//   Otherwise mdl_dead will be displayed at the map origin, and nobody would
//   want that!

void func_breakable_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);

//
// func_breakable
// - basically func_assault_destructible for general gameplay use
//
void LaunchDebris (string debrisname, vector force)
{
	local	entity dbr;

	dbr = spawn();
	setorigin(dbr, self.absmin
	           + '1 0 0' * random() * (self.absmax_x - self.absmin_x)
	           + '0 1 0' * random() * (self.absmax_y - self.absmin_y)
	           + '0 0 1' * random() * (self.absmax_z - self.absmin_z));
	setmodel (dbr, debrisname );
	dbr.skin = self.debrisskin;
	dbr.colormap = self.colormap; // inherit team colors
	dbr.owner = self; // do not be affected by our own explosion
	dbr.movetype = self.debrismovetype;
	dbr.solid = self.debrissolid;
	if(dbr.solid != SOLID_BSP) // SOLID_BSP has exact collision, MAYBE this works? TODO check this out
		setsize(dbr, '0 0 0', '0 0 0'); // needed for performance, until engine can deal better with it
	dbr.velocity_x = self.debrisvelocity_x + self.debrisvelocityjitter_x * crandom();
	dbr.velocity_y = self.debrisvelocity_y + self.debrisvelocityjitter_y * crandom();
	dbr.velocity_z = self.debrisvelocity_z + self.debrisvelocityjitter_z * crandom();
	self.velocity = self.velocity + force * self.debrisdamageforcescale;
	dbr.avelocity_x = random()*self.debrisavelocityjitter_x;
	dbr.avelocity_y = random()*self.debrisavelocityjitter_y;
	dbr.avelocity_z = random()*self.debrisavelocityjitter_z;
	dbr.damageforcescale = self.debrisdamageforcescale;
	if(dbr.damageforcescale)
		dbr.takedamage = DAMAGE_YES;
	SUB_SetFade(dbr, time + self.debristime + crandom() * self.debristimejitter, self.debrisfadetime);
}

void func_breakable_colormod()
{
	float h;
	if not(self.spawnflags & 2)
		return;
	h = self.health / self.max_health;
	if(h < 0.25)
		self.colormod = '1 0 0';
	else if(h <= 0.75)
		self.colormod = '1 0 0' + '0 1 0' * (2 * h - 0.5);
	else
		self.colormod = '1 1 1';
}

void func_breakable_look_destroyed()
{
	float floor_z;

	if(self.solid == SOLID_BSP) // in case a misc_follow moved me, save the current origin first
		self.dropped_origin = self.origin;

	if(self.mdl_dead == "")
		self.model = "";
	else {
		if (self.origin == '0 0 0')	{	// probably no origin brush, so don't spawn in the middle of the map..
			floor_z = self.absmin_z;
			setorigin(self,((self.absmax+self.absmin)*.5));
			self.origin_z = floor_z;
		}
		setmodel(self, self.mdl_dead);
	}

	self.solid = SOLID_NOT;
}

void func_breakable_look_restore()
{
	setmodel(self, self.mdl);
	if(self.mdl_dead != "") // only do this if we use mdl_dead, to behave better with misc_follow
		setorigin(self, self.dropped_origin);
	self.solid = SOLID_BSP;
}

void func_breakable_behave_destroyed()
{
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;
	self.bot_attack = FALSE;
	self.event_damage = func_null;
	self.state = 1;
	func_breakable_colormod();
}

void func_breakable_behave_restore()
{
	self.health = self.max_health;
	if(self.sprite)
	{
		WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
		WaypointSprite_UpdateHealth(self.sprite, self.health);
	}
	self.takedamage = DAMAGE_AIM;
	self.bot_attack = TRUE;
	self.event_damage = func_breakable_damage;
	self.state = 0;
	self.nextthink = 0; // cancel auto respawn
	func_breakable_colormod();
}

void func_breakable_destroyed()
{
	func_breakable_look_destroyed();
	func_breakable_behave_destroyed();
}

void func_breakable_restore()
{
	func_breakable_look_restore();
	func_breakable_behave_restore();
}

vector debrisforce; // global, set before calling this
void func_breakable_destroy() {
	float n, i;
	string oldmsg;

	activator = self.owner;
	self.owner = world; // set by W_PrepareExplosionByDamage

	// now throw around the debris
	n = tokenize_console(self.debris);
	for(i = 0; i < n; ++i)
		LaunchDebris(argv(i), debrisforce);

	func_breakable_destroyed();

	if(self.noise)
		sound (self, CH_TRIGGER, self.noise, VOL_BASE, ATTEN_NORM);

	if(self.dmg)
		RadiusDamage(self, activator, self.dmg, self.dmg_edge, self.dmg_radius, self, self.dmg_force, DEATH_HURTTRIGGER, world);

	if(self.cnt)
		pointparticles(self.cnt, self.absmin * 0.5 + self.absmax * 0.5, '0 0 0', self.count);

	if(self.respawntime)
	{
		self.think = func_breakable_restore;
		self.nextthink = time + self.respawntime + crandom() * self.respawntimejitter;
	}

	oldmsg = self.message;
	self.message = "";
	SUB_UseTargets();
	self.message = oldmsg;
}

void func_breakable_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.state == 1)
		return;
	if(self.spawnflags & DOOR_NOSPLASH)
		if(!(DEATH_ISSPECIAL(deathtype)) && (deathtype & HITTYPE_SPLASH))
			return;
	if(self.team)
		if(attacker.team == self.team)
			return;
	self.health = self.health - damage;
	if(self.sprite)
	{
		WaypointSprite_Ping(self.sprite);
		WaypointSprite_UpdateHealth(self.sprite, self.health);
	}
	func_breakable_colormod();

	if(self.health <= 0)
	{
		debrisforce = force;
		W_PrepareExplosionByDamage(attacker, func_breakable_destroy);
	}
}

void func_breakable_reset()
{
	self.team = self.team_saved;
	func_breakable_look_restore();
	if(self.spawnflags & 1)
		func_breakable_behave_destroyed();
	else
		func_breakable_behave_restore();
}

// destructible walls that can be used to trigger target_objective_decrease
void spawnfunc_func_breakable() {
	float n, i;
	if(!self.health)
		self.health = 100;
	self.max_health = self.health;

	// yes, I know, MOVETYPE_NONE is not available here, not that one would want it here anyway
	if(!self.debrismovetype) self.debrismovetype = MOVETYPE_BOUNCE;
	if(!self.debrissolid) self.debrissolid = SOLID_NOT;
	if(self.debrisvelocity == '0 0 0') self.debrisvelocity = '0 0 140';
	if(self.debrisvelocityjitter == '0 0 0') self.debrisvelocityjitter = '70 70 70';
	if(self.debrisavelocityjitter == '0 0 0') self.debrisavelocityjitter = '600 600 600';
	if(!self.debristime) self.debristime = 3.5;
	if(!self.debristimejitter) self.debristime = 2.5;

	if(self.mdl != "")
		self.cnt = particleeffectnum(self.mdl);
	if(self.count == 0)
		self.count = 1;

	if(self.message == "")
		self.message = "got too close to an explosion";
	if(self.message2 == "")
		self.message2 = "was pushed into an explosion by";
	if(!self.dmg_radius)
		self.dmg_radius = 150;
	if(!self.dmg_force)
		self.dmg_force = 200;

	self.mdl = self.model;
	SetBrushEntityModel();

	self.use = func_breakable_restore;

	// precache all the models
	if (self.mdl_dead)
		precache_model(self.mdl_dead);
	n = tokenize_console(self.debris);
	for(i = 0; i < n; ++i)
		precache_model(argv(i));
	if(self.noise)
		precache_sound(self.noise);

	self.team_saved = self.team;
	self.dropped_origin = self.origin;

	self.reset = func_breakable_reset;
	func_breakable_reset();
}

// for use in maps with a "model" key set
void spawnfunc_misc_breakablemodel() {
	spawnfunc_func_breakable();
}
