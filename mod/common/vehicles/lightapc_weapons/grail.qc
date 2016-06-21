#ifdef SVQC

AUTOCVAR(g_vehicle_lightapc_grail_refire, float, 0.4, "");
AUTOCVAR(g_vehicle_lightapc_grail_ammo_cost, int, 5, "");
AUTOCVAR(g_vehicle_lightapc_grail_ammo_max, int, 100, "");
AUTOCVAR(g_vehicle_lightapc_grail_ammo_regen, int, 20, "");
AUTOCVAR(g_vehicle_lightapc_grail_ammo_regen_pause, float, 1, "");

AUTOCVAR(g_vehicle_lightapc_grail_smallcannon, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_grail_smallcannon_damage, float, 10, "");
AUTOCVAR(g_vehicle_lightapc_grail_smallcannon_speed, float, 2500, "");
AUTOCVAR(g_vehicle_lightapc_grail_smallcannon_lifetime, float, 10, "");

AUTOCVAR(g_vehicle_lightapc_grail_cannon, bool, true, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_damage, float, 40, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_edgedamage, float, 20, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_force, float, 200, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_radius, float, 100, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_comboradius, float, 200, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_speed, float, 2000, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_spread, float, 0.03, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_lifetime, float, 20, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_iterforward, int, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_cannon_iterspeedadd, float, 610, "");

AUTOCVAR(g_vehicle_lightapc_grail_link, bool, true, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_spread, float, 0.3, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_speed, float, 700, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_iter, int, 1, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_iterforward, int, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_iterforwardsub, int, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_iterspeedadd, float, 10, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_itersubspeedadd, float, 100, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_shots, int, 3, "");

AUTOCVAR(g_vehicle_lightapc_grail_link_damage, float, 12, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_bouncedamagefactor, float, 0.5, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_bounces, float, 1, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_joinexplode, float, 1, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_joinexplode_damage, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_middle_lifetime, float, 5, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_middle_fadetime, float, 5, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_other_lifetime, float, 5, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_other_fadetime, float, 5, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_joindelay, float, 0.1, "");
AUTOCVAR(g_vehicle_lightapc_grail_link_joinspread, float, 0.2, "");

AUTOCVAR(g_vehicle_lightapc_grail_link1_skip, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_grail_link1_skipiter, int, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link1_skipspeed, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link2_skip, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_grail_link2_skipiter, int, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link2_skipspeed, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link3_skip, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_grail_link3_skipiter, int, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link3_skipspeed, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link4_skip, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_grail_link4_skipiter, int, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link4_skipspeed, float, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link5_skip, bool, false, "");
AUTOCVAR(g_vehicle_lightapc_grail_link5_skipiter, int, 0, "");
AUTOCVAR(g_vehicle_lightapc_grail_link5_skipspeed, float, 0, "");

void lightapc_grail_Plasma_Explode(entity this)
{
	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;
	
	W_Electro_TriggerCombo(this.origin, autocvar_g_vehicle_lightapc_grail_cannon_comboradius, this.realowner);
		RadiusDamage (this, this.realowner, autocvar_g_vehicle_lightapc_grail_cannon_damage, autocvar_g_vehicle_lightapc_grail_cannon_edgedamage,autocvar_g_vehicle_lightapc_grail_cannon_radius,
					NULL, NULL, autocvar_g_vehicle_lightapc_grail_cannon_force, this.projectiledeathtype, other);

	remove (this);
}

void lightapc_grail_Plasma_Explode_use(entity this, entity actor, entity trigger)
{
	lightapc_grail_Plasma_Explode(this);
}

void lightapc_grail_Plasma_TouchExplode(entity this)
{
	PROJECTILE_TOUCH(this);
	lightapc_grail_Plasma_Explode(this);
}

void lightapc_grail_linkattack (entity actor, string tagname, float putforward, float speedadd, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	v += v_forward * putforward;
	
	float counter, shots;
	entity proj, prevproj, firstproj;
	vector s;
	vector forward, right, up;
	float maxdmg;

	maxdmg = autocvar_g_vehicle_lightapc_grail_link_damage;
	maxdmg *= 1 + autocvar_g_vehicle_lightapc_grail_link_bouncedamagefactor * autocvar_g_vehicle_lightapc_grail_link_bounces;
	if(autocvar_g_vehicle_lightapc_grail_link_joinexplode)
		maxdmg += autocvar_g_vehicle_lightapc_grail_link_joinexplode_damage;

	W_SetupShot (actor, false, 2, SND_CRYLINK_FIRE, CH_WEAPON_A, maxdmg);
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = autocvar_g_vehicle_lightapc_grail_link_shots;
	Send_Effect(EFFECT_CRYLINK_MUZZLEFLASH, v, v_forward * 1000, shots);
		
	proj = prevproj = firstproj = NULL;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.reset = W_Crylink_Reset;
		proj.owner = fireentity;
		proj.realowner = actor;
		proj.classname = "spike";
		proj.bot_dodge = true;
		proj.bot_dodgerating = autocvar_g_vehicle_lightapc_grail_link_damage;
		if(shots == 1) {
			proj.queuenext = proj;
			proj.queueprev = proj;
		}
		else if(counter == 0) { // first projectile, store in firstproj for now
			firstproj = proj;
		}
		else if(counter == shots - 1) { // last projectile, link up with first projectile
			prevproj.queuenext = proj;
			firstproj.queueprev = proj;
			proj.queuenext = firstproj;
			proj.queueprev = prevproj;
		}
		else { // else link up with previous projectile
			prevproj.queuenext = proj;
			proj.queueprev = prevproj;
		}

		prevproj = proj;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYLINK.m_id;
		//proj.gravity = 0.001;

		setorigin (proj, v);
		setsize(proj, '0 0 0', '0 0 0');


		s = '0 0 0';
		if (counter == 0)
			s = '0 0 0';
		else
		{
			makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
			s_y = v_forward_x;
			s_z = v_forward_y;
		}
		s = s * autocvar_g_vehicle_lightapc_grail_link_spread * g_weaponspreadfactor;
		W_SetupProjVelocity_Explicit(proj, w_shotdir + right * s_y + up * s_z, v_up, (autocvar_g_vehicle_lightapc_grail_link_speed + speedadd), 0, 0, 0, false);
		settouch(proj, W_Crylink_Touch);

		setthink(proj, W_Crylink_Fadethink);
		if(counter == 0)
		{
			proj.fade_time = time + autocvar_g_vehicle_lightapc_grail_link_middle_lifetime;
			proj.fade_rate = 1 / autocvar_g_vehicle_lightapc_grail_link_middle_fadetime;
			proj.nextthink = time + autocvar_g_vehicle_lightapc_grail_link_middle_lifetime + autocvar_g_vehicle_lightapc_grail_link_middle_fadetime;
		}
		else
		{
			proj.fade_time = time + autocvar_g_vehicle_lightapc_grail_link_other_lifetime;
			proj.fade_rate = 1 / autocvar_g_vehicle_lightapc_grail_link_other_fadetime;
			proj.nextthink = time + autocvar_g_vehicle_lightapc_grail_link_other_lifetime + autocvar_g_vehicle_lightapc_grail_link_other_fadetime;
		}
		proj.teleport_time = time + autocvar_g_vehicle_lightapc_grail_link_joindelay;
		proj.cnt = autocvar_g_vehicle_lightapc_grail_link_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
		proj.missile_flags = MIF_SPLASH;
	
		CSQCProjectile(proj, true, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), true);

		MUTATOR_CALLHOOK(EditProjectile, actor, proj);
	}
	if(proj)
	if(autocvar_g_vehicle_lightapc_grail_link_joinspread != 0 || autocvar_g_vehicle_lightapc_grail_link_joindelay != 0)
	{
		actor.crylink_lastgroup = proj;
		W_Crylink_CheckLinks(proj);
		actor.crylink_waitrelease = 1;
	}
}

void lightapc_grail_attack(entity actor, string tagname, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	
	entity proj;

	W_SetupShot_ProjectileSize (actor, '0 0 -3', '0 0 -3', false, 2, SND_ELECTRO_FIRE, CH_WEAPON_A, autocvar_g_vehicle_lightapc_grail_smallcannon_damage);

	Send_Effect(EFFECT_ELECTRO_MUZZLEFLASH, v, v_forward * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	//proj.owner = proj.realowner = actor;
	proj.owner = fireentity;
	proj.realowner = actor;
	proj.bot_dodge = true;
	proj.bot_dodgerating = autocvar_g_vehicle_lightapc_grail_smallcannon_damage;
	proj.use = lightapc_grail_Plasma_Explode_use;
	setthink(proj, adaptor_think2use_hittype_splash);
	proj.nextthink = time + autocvar_g_vehicle_lightapc_grail_smallcannon_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO.m_id;
	setorigin(proj, v);

	proj.movetype = MOVETYPE_FLY;
	W_SetupProjVelocity_Basic(proj, autocvar_g_vehicle_lightapc_grail_smallcannon_speed, 0);
	proj.angles = vectoangles(proj.velocity);
	settouch(proj, lightapc_grail_Plasma_TouchExplode);
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.flags = FL_PROJECTILE;
	proj.missile_flags = MIF_SPLASH;

	CSQCProjectile(proj, true, PROJECTILE_ELECTRO_BEAM, true);

	MUTATOR_CALLHOOK(EditProjectile, actor, proj);
}

void lightapc_grail_bigattack(entity actor, string tagname, float putforward, float speedadd, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
		v += v_forward * putforward;
	
	entity proj;

	W_SetupShot_ProjectileSize (actor, '0 0 -9', '0 0 -9', false, 2, SND_ELECTRO_FIRE, CH_WEAPON_A, autocvar_g_vehicle_lightapc_grail_cannon_damage);

	Send_Effect(EFFECT_ELECTRO_MUZZLEFLASH, v, v_forward * 100, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	//proj.owner = proj.realowner = actor;
	proj.owner = fireentity;
	proj.realowner = actor;
	proj.bot_dodge = true;
	proj.bot_dodgerating = autocvar_g_vehicle_lightapc_grail_cannon_damage;
	proj.use = lightapc_grail_Plasma_Explode_use;
	setthink(proj, adaptor_think2use_hittype_splash);
	proj.nextthink = time + autocvar_g_vehicle_lightapc_grail_cannon_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO.m_id;
	proj.scale = 3;
	setorigin(proj, v);

	proj.movetype = MOVETYPE_FLY;
	//W_SETUPPROJECTILEVELOCITY(proj, g_vehicle_lightapc_grail_cannon);
	W_SetupProjVelocity_Explicit(proj, w_shotdir, v_up, (autocvar_g_vehicle_lightapc_grail_cannon_speed + speedadd), 0, 0, autocvar_g_vehicle_lightapc_grail_cannon_spread, false);
	proj.angles = vectoangles(proj.velocity);
	settouch(proj, lightapc_grail_Plasma_TouchExplode);
	setsize(proj, '0 0 -9', '0 0 -9');
	proj.flags = FL_PROJECTILE;
	proj.missile_flags = MIF_SPLASH;

	CSQCProjectile(proj, true, PROJECTILE_ELECTRO_BEAM, true);

	MUTATOR_CALLHOOK(EditProjectile, actor, proj);
}

void lightapc_grail(entity player, entity gunmount) 
{
	if(PHYS_INPUT_BUTTON_ATCK(player) && gunmount.vehicle_ammo1 >= autocvar_g_vehicle_lightapc_grail_ammo_cost && gunmount.attack_finished_single[0] <= time)
	{
		gunmount.cnt = time;
		gunmount.misc_bulletcounter += 1;
		
		makevectors(gunmount.angles);
		vector v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun1"));
		v_forward = normalize(v_forward);
	
		if (autocvar_g_vehicle_lightapc_grail_smallcannon)
		{ 
			lightapc_grail_attack(player, "tag_mgun1", gunmount);
			//lightapc_grail_attack(player, "tag_mgun2", gunmount);
			//lightapc_grail_attack(player, "tag_mgun3", gunmount);
			//lightapc_grail_attack(player, "tag_mgun4", gunmount);
			//lightapc_grail_attack(player, "tag_mgun5", gunmount);
		}
	
		float xc;
		float xfwd = 1;
		float xspd = 0;
		if (autocvar_g_vehicle_lightapc_grail_cannon)
		{
			for (xc = 0;xc < autocvar_g_vehicle_lightapc_grail_link_iter;xc = xc + 1)
			{
				lightapc_grail_bigattack(player, "tag_mgun", xfwd, xspd, gunmount);
				xfwd += autocvar_g_vehicle_lightapc_grail_cannon_iterforward;
				xspd += autocvar_g_vehicle_lightapc_grail_cannon_iterspeedadd;
				//So you can make patterns
			}
		}
	
		xc = 0;
		xfwd = 1;
		xspd = 0;
		if (autocvar_g_vehicle_lightapc_grail_link)
		{
			for (xc = 0;xc < autocvar_g_vehicle_lightapc_grail_link_iter;xc = xc + 1)
			{
				if(!autocvar_g_vehicle_lightapc_grail_link1_skip)
					lightapc_grail_linkattack(player, "tag_mgun1", xfwd, xspd, gunmount);
				if(!autocvar_g_vehicle_lightapc_grail_link1_skipiter)
					xfwd += autocvar_g_vehicle_lightapc_grail_link_iterforwardsub;
				if(!autocvar_g_vehicle_lightapc_grail_link1_skipspeed)
					xspd += autocvar_g_vehicle_lightapc_grail_link_itersubspeedadd;
			
				if(!autocvar_g_vehicle_lightapc_grail_link2_skip)
					lightapc_grail_linkattack(player, "tag_mgun2", xfwd, xspd, gunmount);
				if(!autocvar_g_vehicle_lightapc_grail_link2_skipiter)
					xfwd += autocvar_g_vehicle_lightapc_grail_link_iterforwardsub;
				if(!autocvar_g_vehicle_lightapc_grail_link2_skipspeed)
					xspd += autocvar_g_vehicle_lightapc_grail_link_itersubspeedadd;		
			
				if(!autocvar_g_vehicle_lightapc_grail_link3_skip)
					lightapc_grail_linkattack(player, "tag_mgun3", xfwd, xspd, gunmount);
				if(!autocvar_g_vehicle_lightapc_grail_link3_skipiter)
					xfwd += autocvar_g_vehicle_lightapc_grail_link_iterforwardsub;
				if(!autocvar_g_vehicle_lightapc_grail_link3_skipspeed)
					xspd += autocvar_g_vehicle_lightapc_grail_link_itersubspeedadd;
					
				if(!autocvar_g_vehicle_lightapc_grail_link4_skip)
					lightapc_grail_linkattack(player, "tag_mgun4", xfwd, xspd, gunmount);
				if(!autocvar_g_vehicle_lightapc_grail_link4_skipiter)
					xfwd += autocvar_g_vehicle_lightapc_grail_link_iterforwardsub;
				if(!autocvar_g_vehicle_lightapc_grail_link4_skipspeed)
					xspd += autocvar_g_vehicle_lightapc_grail_link_itersubspeedadd;
					
				if(!autocvar_g_vehicle_lightapc_grail_link5_skip)
					lightapc_grail_linkattack(player, "tag_mgun5", xfwd, xspd, gunmount);
				if(!autocvar_g_vehicle_lightapc_grail_link5_skipiter)
					xfwd += autocvar_g_vehicle_lightapc_grail_link_iterforwardsub;
				if(!autocvar_g_vehicle_lightapc_grail_link5_skipspeed)
					xspd += autocvar_g_vehicle_lightapc_grail_link_itersubspeedadd;
			
				xfwd += autocvar_g_vehicle_lightapc_grail_link_iterforward;
				xspd += autocvar_g_vehicle_lightapc_grail_link_iterspeedadd;
				//So you can make patterns
			}
		}

	 
		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
		v_forward = normalize(v_forward);
		v += v_forward * 5;

		//sound (gunmount, CH_WEAPON_A, W_Sound("campingrifle_fire"), VOL_BASE, ATTN_NORM);

		gunmount.vehicle_ammo1 -= autocvar_g_vehicle_lightapc_grail_ammo_cost;
		gunmount.attack_finished_single[0] = time + autocvar_g_vehicle_lightapc_grail_refire;
	}
	else
	{
		vehicles_regen(gunmount, gunmount.cnt, vehicle_ammo1, autocvar_g_vehicle_lightapc_grail_ammo_max,
										   autocvar_g_vehicle_lightapc_grail_ammo_regen_pause,
										   autocvar_g_vehicle_lightapc_grail_ammo_regen, frametime, false);
	}

	player.vehicle_ammo1 = (gunmount.vehicle_ammo1 / autocvar_g_vehicle_lightapc_grail_ammo_max) * 100;
}

#endif
