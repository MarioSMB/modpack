SOUND(DELUGE_FIRE, "machines/steam_fade");

int PROJECTILE_DELUGE;

STATIC_INIT(DelugeProjectile) { PROJECTILE_DELUGE = MOD_PROJECTILES++; }

#ifdef SVQC

AUTOCVAR(g_vehicle_lightapc_deluge_cannon_radius, float, 10, "");
AUTOCVAR(g_vehicle_lightapc_deluge_cannon_force, float, 100, "");

AUTOCVAR(g_vehicle_lightapc_deluge_damage, float, 0.001, "");
AUTOCVAR(g_vehicle_lightapc_deluge_edgedamage, float, 0.001, "");
AUTOCVAR(g_vehicle_lightapc_deluge_refire, float, 0.03, "");
AUTOCVAR(g_vehicle_lightapc_deluge_ammo_cost, int, 1, "");
AUTOCVAR(g_vehicle_lightapc_deluge_ammo_max, int, 200, "");
AUTOCVAR(g_vehicle_lightapc_deluge_ammo_regen, int, 47, "");
AUTOCVAR(g_vehicle_lightapc_deluge_ammo_regen_pause, float, 1, "");

AUTOCVAR(g_vehicle_lightapc_deluge_water_speed, float, 3600, "");
AUTOCVAR(g_vehicle_lightapc_deluge_water_spread, float, 0.03, "");

void lightapc_deluge_Water_Explode(entity this, entity directhitentity)
{
	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;
	
	if (directhitentity.fire_endtime > time)
		directhitentity.fire_endtime = directhitentity.fire_endtime * 0.9;

	RadiusDamage (this, this.realowner, autocvar_g_vehicle_lightapc_deluge_damage, autocvar_g_vehicle_lightapc_deluge_edgedamage, autocvar_g_vehicle_lightapc_deluge_cannon_radius, world, world,
				autocvar_g_vehicle_lightapc_deluge_cannon_force, this.projectiledeathtype, directhitentity);

	remove (this);
}

void lightapc_deluge_Water_Explode_use(entity this, entity actor, entity trigger)
{
	lightapc_deluge_Water_Explode(this, trigger);
}

void lightapc_deluge_Water_TouchExplode(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);
	lightapc_deluge_Water_Explode(this, toucher);
}

void lightapc_deluge_attack(entity actor, string tagname, entity spigot)
{
	vector v;
	v = gettaginfo(spigot, gettagindex(spigot, tagname));
	v_forward = normalize(v_forward);
	
	entity proj;

	W_SetupShot_ProjectileSize (actor, '0 0 -1', '0 0 -1', false, 2, SND_DELUGE_FIRE, CH_WEAPON_A, WEP_CVAR_SEC(electro, damage));

	w_shotdir = v_forward; // no TrueAim for grenades please

	__pointparticles(_particleeffectnum("deluge_muzzleflash"), v, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "water";
	//proj.owner = proj.realowner = actor;
	proj.owner = actor;
	proj.realowner = actor.owner;
	proj.use = lightapc_deluge_Water_Explode_use;
	setthink(proj, adaptor_think2use_hittype_splash);
	proj.bot_dodge = true;
	proj.bot_dodgerating = autocvar_g_vehicle_lightapc_deluge_damage;
	proj.nextthink = time + WEP_CVAR_SEC(electro, lifetime);
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_DROWN.m_id;
	setorigin(proj, v);

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	set_movetype(proj, MOVETYPE_BOUNCE);
	W_SetupProjVelocity_Explicit(proj, w_shotdir, v_up, autocvar_g_vehicle_lightapc_deluge_water_speed, 0, 0, autocvar_g_vehicle_lightapc_deluge_water_spread, false);
	//W_SETUPPROJECTILEVELOCITY_UP(proj, g_vehicle_lightapc_deluge_water);
	settouch(proj, lightapc_deluge_Water_TouchExplode);
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

	CSQCProjectile(proj, true, PROJECTILE_DELUGE, false); // no culling, it has sound

	MUTATOR_CALLHOOK(EditProjectile, actor, proj);
}

void lightapc_deluge(entity player, entity gunmount) 
{
	if(PHYS_INPUT_BUTTON_ATCK(player) && gunmount.attack_finished_single[0] <= time && (player.waterlevel > 0 || gunmount.vehicle_ammo1 >= autocvar_g_vehicle_lightapc_deluge_ammo_cost))
	{
		gunmount.misc_bulletcounter += 1;
		gunmount.cnt = time;

		lightapc_deluge_attack(player, "tag_mgun", gunmount);

		if(player.waterlevel <= 0) // if player is above water, consume water
			gunmount.vehicle_ammo1 -= autocvar_g_vehicle_lightapc_deluge_ammo_cost;

		gunmount.attack_finished_single[0] = time + autocvar_g_vehicle_lightapc_deluge_refire;
	}
	else
	{
		vehicles_regen(gunmount, gunmount.cnt, vehicle_ammo1, autocvar_g_vehicle_lightapc_deluge_ammo_max,
										   autocvar_g_vehicle_lightapc_deluge_ammo_regen_pause,
										   autocvar_g_vehicle_lightapc_deluge_ammo_regen, frametime, false);
	}

	player.vehicle_ammo1 = (gunmount.vehicle_ammo1 / autocvar_g_vehicle_lightapc_deluge_ammo_max) * 100;
}

#elif defined(CSQC)

REGISTER_MUTATOR(cl_deluge, true);

SOUND(STEAM_FADE, "machines/steam_fade");

MODEL(PROJECTILE_DELUGE, "models/waterblob.iqm");

MUTATOR_HOOKFUNCTION(cl_deluge, Ent_Projectile)
{
	entity proj = M_ARGV(0, entity);

	if(proj.cnt == PROJECTILE_DELUGE)
	{
		setmodel(proj, MDL_PROJECTILE_DELUGE);
		proj.traileffect = EFFECT_TR_NEXUIZPLASMA.m_id;
		return true;
	}
}

MUTATOR_HOOKFUNCTION(cl_deluge, EditProjectile)
{
	entity proj = M_ARGV(0, entity);

	if(proj.cnt == PROJECTILE_DELUGE)
	{
		loopsound(proj, CH_SHOTS_SINGLE, SND(STEAM_FADE), VOL_BASE, ATTN_NORM);
		proj.mins = '0 0 -4';
		proj.maxs = '0 0 -4';
		set_movetype(proj, MOVETYPE_BOUNCE);
		settouch(proj, func_null);
		proj.bouncefactor = WEP_CVAR_SEC(electro, bouncefactor);
		proj.bouncestop = WEP_CVAR_SEC(electro, bouncestop);
	}
}

#endif
