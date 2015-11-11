#ifdef SVQC

void mg_grail_Plasma_Explode (void)
{
	
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	
	W_Plasma_TriggerCombo(self.origin, autocvar_g_mountedgun_grail_cannon_comboradius, self.realowner);
		RadiusDamage (self, self.realowner, autocvar_g_mountedgun_grail_cannon_damage, autocvar_g_mountedgun_grail_cannon_edgedamage, autocvar_g_mountedgun_grail_cannon_radius, world, autocvar_g_mountedgun_grail_cannon_force, self.projectiledeathtype, other);

	remove (self);
}

void mg_grail_Plasma_TouchExplode (void)
{
	PROJECTILE_TOUCH;
	mg_grail_Plasma_Explode ();
}

void mg_grail_linkattack (string tagname, float putforward, float speedadd, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	v += v_forward * putforward;
	
	float counter, shots;
	entity proj, prevproj, firstproj;
	vector s;
	vector forward, right, up;
	float maxdmg;

	maxdmg = autocvar_g_balance_crylink_primary_damage*autocvar_g_balance_crylink_primary_shots;
	maxdmg *= 1 + autocvar_g_balance_crylink_primary_bouncedamagefactor * autocvar_g_balance_crylink_primary_bounces;
	if(autocvar_g_balance_crylink_primary_joinexplode)
		maxdmg += autocvar_g_balance_crylink_primary_joinexplode_damage;

	W_SetupShot (self, false, 2, W_Sound("crylink_fire"), CH_WEAPON_A, maxdmg);
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = autocvar_g_mountedgun_grail_link_shots;
	Send_Effect(EFFECT_CRYLINK_MUZZLEFLASH, v, v_forward * 1000, shots);
		
	proj = prevproj = firstproj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.reset = W_Crylink_Reset;
		proj.owner = self;
		proj.realowner = self.owner;
		proj.classname = "spike";
		proj.bot_dodge = true;
		proj.bot_dodgerating = autocvar_g_balance_crylink_primary_damage;
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
		proj.projectiledeathtype = WEP_CRYLINK;
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
		s = s * autocvar_g_mountedgun_grail_link_spread * g_weaponspreadfactor;
		W_SetupProjectileVelocityEx(proj, w_shotdir + right * s_y + up * s_z, v_up, (autocvar_g_mountedgun_grail_link_speed + speedadd), 0, 0, 0, false);
		proj.touch = W_Crylink_Touch;

		proj.think = W_Crylink_Fadethink;
		if(counter == 0)
		{
			proj.fade_time = time + autocvar_g_balance_crylink_primary_middle_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crylink_primary_middle_fadetime;
			proj.nextthink = time + autocvar_g_balance_crylink_primary_middle_lifetime + autocvar_g_balance_crylink_primary_middle_fadetime;
		}
		else
		{
			proj.fade_time = time + autocvar_g_balance_crylink_primary_other_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crylink_primary_other_fadetime;
			proj.nextthink = time + autocvar_g_balance_crylink_primary_other_lifetime + autocvar_g_balance_crylink_primary_other_fadetime;
		}
		proj.teleport_time = time + autocvar_g_balance_crylink_primary_joindelay;
		proj.cnt = autocvar_g_balance_crylink_primary_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH;
    
		CSQCProjectile(proj, true, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), true);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
	if(autocvar_g_balance_crylink_primary_joinspread != 0 || autocvar_g_balance_crylink_primary_jointime != 0)
	{
		self.crylink_lastgroup = proj;
		W_Crylink_CheckLinks(proj);
		self.crylink_waitrelease = 1;
	}
}

void mg_grail_attack(string tagname, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
    
	entity proj;

	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', false, 2, W_Sound("electro_fire"), CH_WEAPON_A, autocvar_g_balance_electro_primary_damage);

	Send_Effect(EFFECT_ELECTRO_MUZZLEFLASH, v, v_forward * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	//proj.owner = proj.realowner = self;
	proj.owner = self;
	proj.realowner = self.owner;
	proj.bot_dodge = true;
	proj.bot_dodgerating = autocvar_g_balance_electro_primary_damage;
	proj.use = W_Plasma_Explode;
	proj.think = adaptor_think2use_hittype_splash;
	proj.nextthink = time + autocvar_g_balance_electro_primary_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO;
	setorigin(proj, v);

	proj.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(proj, g_balance_electro_primary);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Plasma_TouchExplode;
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.flags = FL_PROJECTILE;
	proj.missile_flags = MIF_SPLASH;

	CSQCProjectile(proj, true, PROJECTILE_ELECTRO_BEAM, true);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void mg_grail_bigattack(string tagname, float putforward, float speedadd, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
        v += v_forward * putforward;
    
	entity proj;

	W_SetupShot_ProjectileSize (self, '0 0 -9', '0 0 -9', false, 2, W_Sound("electro_fire"), CH_WEAPON_A, autocvar_g_mountedgun_grail_cannon_damage);

	Send_Effect(EFFECT_ELECTRO_MUZZLEFLASH, v, v_forward * 100, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	//proj.owner = proj.realowner = self;
	proj.owner = self;
	proj.realowner = self.owner;
	proj.bot_dodge = true;
	proj.bot_dodgerating = autocvar_g_mountedgun_grail_cannon_damage;
	proj.use = mg_grail_Plasma_Explode;
	proj.think = adaptor_think2use_hittype_splash;
	proj.nextthink = time + autocvar_g_mountedgun_grail_cannon_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO;
	proj.scale = 3;
	setorigin(proj, v);

	proj.movetype = MOVETYPE_FLY;
	//W_SETUPPROJECTILEVELOCITY(proj, g_mountedgun_grail_cannon);
	W_SetupProjectileVelocityEx(proj, w_shotdir, v_up, (autocvar_g_mountedgun_grail_cannon_speed + speedadd), 0, 0, autocvar_g_mountedgun_grail_cannon_spread, false);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Plasma_TouchExplode;
	setsize(proj, '0 0 -9', '0 0 -9');
	proj.flags = FL_PROJECTILE;
	proj.missile_flags = MIF_SPLASH;

	CSQCProjectile(proj, true, PROJECTILE_ELECTRO_BEAM, true);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void mg_grail_fire(entity mg_grail, entity player, entity gunmount) 
{
	mg_grail.cnt = time;
        if(mg_grail.vehicle_ammo1 >= autocvar_g_mountedgun_grail_railgun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_grail.misc_bulletcounter += 1;

	    self = mg_grail;
	    
	    makevectors(self.angles);
	    v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun1"));
            v_forward = normalize(v_forward);
	
	if (autocvar_g_mountedgun_grail_smallcannon) { 
		mg_grail_attack("tag_mgun1", gunmount);
		mg_grail_attack("tag_mgun2", gunmount);
		mg_grail_attack("tag_mgun3", gunmount);
		mg_grail_attack("tag_mgun4", gunmount);
		mg_grail_attack("tag_mgun5", gunmount);
	}
	
	float	xc;
	float   xfwd = 1;
	float   xspd = 0;
	if (autocvar_g_mountedgun_grail_cannon) {
		for (xc = 0;xc < autocvar_g_mountedgun_grail_link_iter;xc = xc + 1) {
			mg_grail_bigattack("tag_mgun", xfwd, xspd, gunmount);
			xfwd += autocvar_g_mountedgun_grail_cannon_iterforward;
			xspd += autocvar_g_mountedgun_grail_cannon_iterspeedadd;
			//So you can make patterns
		}
	}
	
	xc = 0;
	xfwd = 1;
	xspd = 0;
	if (autocvar_g_mountedgun_grail_link) {
	for (xc = 0;xc < autocvar_g_mountedgun_grail_link_iter;xc = xc + 1) {
		if(!autocvar_g_mountedgun_grail_link1_skip)
			mg_grail_linkattack("tag_mgun1", xfwd, xspd, gunmount);
		if(!autocvar_g_mountedgun_grail_link1_skipiter)
			xfwd += autocvar_g_mountedgun_grail_link_iterforwardsub;
		if(!autocvar_g_mountedgun_grail_link1_skipspeed)
			xspd += autocvar_g_mountedgun_grail_link_itersubspeedadd;
	
		if(!autocvar_g_mountedgun_grail_link2_skip)
			mg_grail_linkattack("tag_mgun2", xfwd, xspd, gunmount);
		if(!autocvar_g_mountedgun_grail_link2_skipiter)
			xfwd += autocvar_g_mountedgun_grail_link_iterforwardsub;
		if(!autocvar_g_mountedgun_grail_link2_skipspeed)
			xspd += autocvar_g_mountedgun_grail_link_itersubspeedadd;		
	
		if(!autocvar_g_mountedgun_grail_link3_skip)
			mg_grail_linkattack("tag_mgun3", xfwd, xspd, gunmount);
		if(!autocvar_g_mountedgun_grail_link3_skipiter)
			xfwd += autocvar_g_mountedgun_grail_link_iterforwardsub;
		if(!autocvar_g_mountedgun_grail_link3_skipspeed)
			xspd += autocvar_g_mountedgun_grail_link_itersubspeedadd;
			
		if(!autocvar_g_mountedgun_grail_link4_skip)
			mg_grail_linkattack("tag_mgun4", xfwd, xspd, gunmount);
		if(!autocvar_g_mountedgun_grail_link4_skipiter)
			xfwd += autocvar_g_mountedgun_grail_link_iterforwardsub;
		if(!autocvar_g_mountedgun_grail_link4_skipspeed)
			xspd += autocvar_g_mountedgun_grail_link_itersubspeedadd;
			
		if(!autocvar_g_mountedgun_grail_link5_skip)
			mg_grail_linkattack("tag_mgun5", xfwd, xspd, gunmount);
		if(!autocvar_g_mountedgun_grail_link5_skipiter)
			xfwd += autocvar_g_mountedgun_grail_link_iterforwardsub;
		if(!autocvar_g_mountedgun_grail_link5_skipspeed)
			xspd += autocvar_g_mountedgun_grail_link_itersubspeedadd;
	
		xfwd += autocvar_g_mountedgun_grail_link_iterforward;
		xspd += autocvar_g_mountedgun_grail_link_iterspeedadd;
		//So you can make patterns
	}
	}

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 
   
	 //sound (gunmount, CH_WEAPON_A, W_Sound("campingrifle_fire"), VOL_BASE, ATTN_NORM);

	    
            self = mg_grail;

            mg_grail.vehicle_ammo1 -= autocvar_g_mountedgun_grail_railgun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_mountedgun_grail_railgun_refire;
            player.vehicle_ammo1 = (mg_grail.vehicle_ammo1 / autocvar_g_mountedgun_grail_railgun_ammo_max) * 100;
         
        }
}
