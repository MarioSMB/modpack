SOUND(DELUGE_FIRE, "machines/steam_fade");

int PROJECTILE_DELUGE;

STATIC_INIT(DelugeProjectile) { PROJECTILE_DELUGE = MOD_PROJECTILES++; }

#ifdef SVQC

.float deluge_damage;
.float deluge_edgedamage;
.float deluge_radius;
.float deluge_force;

void vwep_deluge_Water_Explode(entity this, entity directhitentity)
{
	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;
	
	if (directhitentity.fire_endtime > time)
		directhitentity.fire_endtime *= 0.7;

	RadiusDamage (this, this.realowner, this.deluge_damage, this.deluge_edgedamage, this.deluge_radius, NULL, NULL,
				this.deluge_force, this.projectiledeathtype, directhitentity);

	delete (this);
}

void vwep_deluge_Water_Explode_use(entity this, entity actor, entity trigger)
{
	vwep_deluge_Water_Explode(this, trigger);
}

void vwep_deluge_Water_TouchExplode(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);
	vwep_deluge_Water_Explode(this, toucher);
}

void vwep_deluge_attack(
	entity actor,
	string tagname,
	entity spigot,
	float atk_damage,
	float atk_edgedamage,
	float atk_force,
	float atk_speed,
	float atk_spread,
	float atk_health,
	float atk_radius)
{
	vector v = gettaginfo(spigot, gettagindex(spigot, tagname));
	v_forward = normalize(v_forward);

	W_SetupShot_ProjectileSize (actor, weaponentities[0], '0 0 -1', '0 0 -1', false, 2, SND_DELUGE_FIRE, CH_WEAPON_A, atk_damage);

	w_shotdir = v_forward; // no TrueAim for grenades please

	Send_Effect(EFFECT_DELUGE_MUZZLEFLASH, v, w_shotdir * 1000, 1);

	entity proj = new(water);
	//proj.owner = proj.realowner = actor;
	proj.owner = actor;
	proj.realowner = actor.owner;
	proj.use = vwep_deluge_Water_Explode_use;
	setthink(proj, adaptor_think2use_hittype_splash);
	proj.bot_dodge = true;
	proj.bot_dodgerating = atk_damage;
	proj.nextthink = time + WEP_CVAR_SEC(electro, lifetime);
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_DROWN.m_id;
	setorigin(proj, v);

	proj.deluge_damage = atk_damage;
	proj.deluge_edgedamage = atk_edgedamage;
	proj.deluge_radius = atk_radius;
	proj.deluge_force = atk_force;
	proj.deluge_radius = atk_radius;

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	set_movetype(proj, MOVETYPE_BOUNCE);
	W_SetupProjVelocity_Explicit(proj, w_shotdir, v_up, atk_speed, 0, 0, atk_spread, false);
	settouch(proj, vwep_deluge_Water_TouchExplode);
	setsize(proj, '0 0 -1', '0 0 -1');
	proj.takedamage = DAMAGE_YES;
	proj.health = atk_health;
	proj.event_damage = func_null; // there's checks to prevent this from being executed
	proj.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, proj);
	IL_PUSH(g_bot_dodge, proj);
	proj.damagedbycontents = true; // YES, water evaporates in lava
	IL_PUSH(g_damagedbycontents, proj);

	proj.bouncefactor = WEP_CVAR_SEC(electro, bouncefactor);
	proj.bouncestop = WEP_CVAR_SEC(electro, bouncestop);
	proj.missile_flags = MIF_SPLASH | MIF_ARC;

	CSQCProjectile(proj, true, PROJECTILE_DELUGE, false); // no culling, it has sound

	MUTATOR_CALLHOOK(EditProjectile, actor, proj);
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
		loopsound(proj, CH_SHOTS_SINGLE, SND_STEAM_FADE, VOL_BASE, ATTN_NORM);
		proj.mins = '0 0 -4';
		proj.maxs = '0 0 -4';
		set_movetype(proj, MOVETYPE_BOUNCE);
		settouch(proj, func_null);
		proj.bouncefactor = WEP_CVAR_SEC(electro, bouncefactor);
		proj.bouncestop = WEP_CVAR_SEC(electro, bouncestop);
	}
}

#endif
