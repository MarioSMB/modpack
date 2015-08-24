#ifdef SVQC

void mg_deluge_Water_Explode (void)
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	
	if (other.fire_endtime > time)
	{
		other.fire_endtime = other.fire_endtime * 0.9;
		//print("fire\n");
	}
	RadiusDamage (self, self.realowner, autocvar_g_mountedgun_deluge_machinegun_damage, autocvar_g_mountedgun_deluge_machinegun_edgedamage, autocvar_g_mountedgun_deluge_cannon_radius, world, world,
				autocvar_g_mountedgun_deluge_cannon_force, self.projectiledeathtype, other);

	remove (self);
}

void mg_deluge_Water_TouchExplode (void)
{
	PROJECTILE_TOUCH;
	mg_deluge_Water_Explode ();
}

void mg_deluge_Water_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{ }

void mg_deluge_attack(string tagname, entity spigot)
{
	vector v;
	v = gettaginfo(spigot, gettagindex(spigot, tagname));
	v_forward = normalize(v_forward);
	
	entity proj;

	W_SetupShot_ProjectileSize (self, '0 0 -1', '0 0 -1', FALSE, 2, "machines/steam_fade.ogg", CH_WEAPON_A, WEP_CVAR_SEC(electro, damage));

	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("deluge_muzzleflash"), v, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "water";
	//proj.owner = proj.realowner = self;
	proj.owner = self;
	proj.realowner = self.owner;
	proj.use = mg_deluge_Water_Explode;
	proj.think = adaptor_think2use_hittype_splash;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_mountedgun_deluge_machinegun_damage;
	proj.nextthink = time + WEP_CVAR_SEC(electro, lifetime);
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_DROWN;
	setorigin(proj, v);

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	W_SetupProjVelocity_Explicit(proj, w_shotdir, v_up, autocvar_g_mountedgun_deluge_water_speed, 0, 0, autocvar_g_mountedgun_deluge_water_spread, false);
	//W_SETUPPROJECTILEVELOCITY_UP(proj, g_vehicle_mg_deluge_water);
	proj.touch = mg_deluge_Water_TouchExplode;
	setsize(proj, '0 0 -1', '0 0 -1');
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = WEP_CVAR_SEC(electro, damageforcescale);
	proj.health = WEP_CVAR_SEC(electro, health);
	proj.event_damage = func_null; // there's checks to prevent this from being executed
	proj.flags = FL_PROJECTILE;
	proj.damagedbycontents = WEP_CVAR_SEC(electro, damagedbycontents);

	proj.bouncefactor = WEP_CVAR_SEC(electro, bouncefactor);
	proj.bouncestop = WEP_CVAR_SEC(electro, bouncestop);
	proj.missile_flags = MIF_SPLASH | MIF_ARC;

	CSQCProjectile(proj, TRUE, PROJECTILE_DELUGE, FALSE); // no culling, it has sound

	MUTATOR_CALLHOOK(EditProjectile, self, proj);
}

void mg_deluge_fire(entity mg, entity player, entity gunmount) 
{
	entity oldself = self;

	if(gunmount.attack_finished_single <= time)
	if(player.waterlevel < 0 || mg.vehicle_ammo1 >= autocvar_g_mountedgun_deluge_machinegun_ammo_cost)
	{
		mg.misc_bulletcounter += 1;

		self = player;
		mg_deluge_attack("tag_mgun", gunmount);
		self = mg;

		if(player.waterlevel <= 0) // if player is above water, consume water
			mg.vehicle_ammo1 -= autocvar_g_mountedgun_deluge_machinegun_ammo_cost;

		gunmount.attack_finished_single = time + autocvar_g_mountedgun_deluge_machinegun_refire;
		player.vehicle_ammo1 = (mg.vehicle_ammo1 / autocvar_g_mountedgun_deluge_machinegun_ammo_max) * 100;
	}

	self = oldself;
}

#endif
