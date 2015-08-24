const vector MG_GRAIL_MIN = '-20 -20 1';
const vector MG_GRAIL_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_grail;

float autocvar_g_vehicle_mg_grail_respawntime;

float autocvar_g_vehicle_mg_grail_speed_stop;
float autocvar_g_vehicle_mg_grail_speed_strafe;
float autocvar_g_vehicle_mg_grail_speed_walk;
float autocvar_g_vehicle_mg_grail_movement_inertia;

float autocvar_g_vehicle_mg_grail_springlength;
float autocvar_g_vehicle_mg_grail_springup;
float autocvar_g_vehicle_mg_grail_springblend;
float autocvar_g_vehicle_mg_grail_tiltlimit;

float autocvar_g_vehicle_mg_grail_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_grail_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_grail_gun_pitchspeed;
float autocvar_g_vehicle_mg_grail_gun_turnlimit;
float autocvar_g_vehicle_mg_grail_gun_turnspeed;

float autocvar_g_vehicle_mg_grail_smallcannon;
float autocvar_g_vehicle_mg_grail_cannon;
float autocvar_g_vehicle_mg_grail_cannon_damage;
float autocvar_g_vehicle_mg_grail_cannon_edgedamage;
float autocvar_g_vehicle_mg_grail_cannon_force;
float autocvar_g_vehicle_mg_grail_cannon_radius;
float autocvar_g_vehicle_mg_grail_cannon_comboradius;
float autocvar_g_vehicle_mg_grail_cannon_speed;
float autocvar_g_vehicle_mg_grail_cannon_spread;
float autocvar_g_vehicle_mg_grail_cannon_lifetime;
float autocvar_g_vehicle_mg_grail_cannon_iterforward;
float autocvar_g_vehicle_mg_grail_cannon_iterspeedadd;

float autocvar_g_vehicle_mg_grail_link;
float autocvar_g_vehicle_mg_grail_link_speed;
float autocvar_g_vehicle_mg_grail_link_spread;
float autocvar_g_vehicle_mg_grail_link_iter;
float autocvar_g_vehicle_mg_grail_link_iterforward;
float autocvar_g_vehicle_mg_grail_link_iterforwardsub;
float autocvar_g_vehicle_mg_grail_link_iterspeedadd;
float autocvar_g_vehicle_mg_grail_link_itersubspeedadd;
float autocvar_g_vehicle_mg_grail_link_shots;
float autocvar_g_vehicle_mg_grail_link1_skip;
float autocvar_g_vehicle_mg_grail_link1_skipiter;
float autocvar_g_vehicle_mg_grail_link1_skipspeed;
float autocvar_g_vehicle_mg_grail_link2_skip;
float autocvar_g_vehicle_mg_grail_link2_skipiter;
float autocvar_g_vehicle_mg_grail_link2_skipspeed;
float autocvar_g_vehicle_mg_grail_link3_skip;
float autocvar_g_vehicle_mg_grail_link3_skipiter;
float autocvar_g_vehicle_mg_grail_link3_skipspeed;
float autocvar_g_vehicle_mg_grail_link4_skip;
float autocvar_g_vehicle_mg_grail_link4_skipiter;
float autocvar_g_vehicle_mg_grail_link4_skipspeed;
float autocvar_g_vehicle_mg_grail_link5_skip;
float autocvar_g_vehicle_mg_grail_link5_skipiter;
float autocvar_g_vehicle_mg_grail_link5_skipspeed;

float autocvar_g_vehicle_mg_grail_health;
float autocvar_g_vehicle_mg_grail_health_regen;
float autocvar_g_vehicle_mg_grail_health_regen_pause;

float autocvar_g_vehicle_mg_grail_shield;
float autocvar_g_vehicle_mg_grail_shield_regen;
float autocvar_g_vehicle_mg_grail_shield_regen_pause;

float autocvar_g_vehicle_mg_grail_railgun_refire;
float autocvar_g_vehicle_mg_grail_railgun_ammo_cost;
float autocvar_g_vehicle_mg_grail_railgun_ammo_max;
float autocvar_g_vehicle_mg_grail_railgun_ammo_regen;
float autocvar_g_vehicle_mg_grail_railgun_ammo_regen_pause;

vector autocvar_g_vehicle_mg_grail_bouncepain;


void mg_grail_exit(float eject);
void mg_grail_enter();
void mg_grail_spawn(float);

void mg_grail_Plasma_Explode (void)
{
	
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	
	W_Plasma_TriggerCombo(self.origin, autocvar_g_vehicle_mg_grail_cannon_comboradius, self.realowner);
		RadiusDamage (self, self.realowner, autocvar_g_vehicle_mg_grail_cannon_damage, autocvar_g_vehicle_mg_grail_cannon_edgedamage, autocvar_g_vehicle_mg_grail_cannon_radius, world, autocvar_g_vehicle_mg_grail_cannon_force, self.projectiledeathtype, other);

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

	W_SetupShot (self, FALSE, 2, "weapons/crylink_fire.wav", CH_WEAPON_A, maxdmg);
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = autocvar_g_vehicle_mg_grail_link_shots;
	pointparticles(particleeffectnum("crylink_muzzleflash"), v, v_forward * 1000, shots);
		
	proj = prevproj = firstproj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.reset = W_Crylink_Reset;
		proj.owner = self;
		proj.realowner = self.owner;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
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
		s = s * autocvar_g_vehicle_mg_grail_link_spread * g_weaponspreadfactor;
		W_SetupProjectileVelocityEx(proj, w_shotdir + right * s_y + up * s_z, v_up, (autocvar_g_vehicle_mg_grail_link_speed + speedadd), 0, 0, 0, FALSE);
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
    
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

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

	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 2, "weapons/electro_fire.wav", CH_WEAPON_A, autocvar_g_balance_electro_primary_damage);

	pointparticles(particleeffectnum("electro_muzzleflash"), v, v_forward * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	//proj.owner = proj.realowner = self;
	proj.owner = self;
	proj.realowner = self.owner;
	proj.bot_dodge = TRUE;
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

	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO_BEAM, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void mg_grail_bigattack(string tagname, float putforward, float speedadd, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
        v += v_forward * putforward;
    
	entity proj;

	W_SetupShot_ProjectileSize (self, '0 0 -9', '0 0 -9', FALSE, 2, "weapons/electro_fire.wav", CH_WEAPON_A, autocvar_g_vehicle_mg_grail_cannon_damage);

	pointparticles(particleeffectnum("electro_muzzleflash"), v, v_forward * 100, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	//proj.owner = proj.realowner = self;
	proj.owner = self;
	proj.realowner = self.owner;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_vehicle_mg_grail_cannon_damage;
	proj.use = mg_grail_Plasma_Explode;
	proj.think = adaptor_think2use_hittype_splash;
	proj.nextthink = time + autocvar_g_vehicle_mg_grail_cannon_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO;
	proj.scale = 3;
	setorigin(proj, v);

	proj.movetype = MOVETYPE_FLY;
	//W_SETUPPROJECTILEVELOCITY(proj, g_vehicle_mg_grail_cannon);
	W_SetupProjectileVelocityEx(proj, w_shotdir, v_up, (autocvar_g_vehicle_mg_grail_cannon_speed + speedadd), 0, 0, autocvar_g_vehicle_mg_grail_cannon_spread, FALSE);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Plasma_TouchExplode;
	setsize(proj, '0 0 -9', '0 0 -9');
	proj.flags = FL_PROJECTILE;
	proj.missile_flags = MIF_SPLASH;

	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO_BEAM, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

float mg_grail_aiframe()
{
    return FALSE;
}

void mg_grail_fire(entity mg_grail, entity player, entity gunmount) 
{
	mg_grail.cnt = time;
        if(mg_grail.vehicle_ammo1 >= autocvar_g_vehicle_mg_grail_railgun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_grail.misc_bulletcounter += 1;

	    self = mg_grail;
	    
	    makevectors(self.angles);
	    v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun1"));
            v_forward = normalize(v_forward);
	
	if (autocvar_g_vehicle_mg_grail_smallcannon) { 
		mg_grail_attack("tag_mgun1", gunmount);
		mg_grail_attack("tag_mgun2", gunmount);
		mg_grail_attack("tag_mgun3", gunmount);
		mg_grail_attack("tag_mgun4", gunmount);
		mg_grail_attack("tag_mgun5", gunmount);
	}
	
	float	xc;
	float   xfwd = 1;
	float   xspd = 0;
	if (autocvar_g_vehicle_mg_grail_cannon) {
		for (xc = 0;xc < autocvar_g_vehicle_mg_grail_link_iter;xc = xc + 1) {
			mg_grail_bigattack("tag_mgun", xfwd, xspd, gunmount);
			xfwd += autocvar_g_vehicle_mg_grail_cannon_iterforward;
			xspd += autocvar_g_vehicle_mg_grail_cannon_iterspeedadd;
			//So you can make patterns
		}
	}
	
	xc = 0;
	xfwd = 1;
	xspd = 0;
	if (autocvar_g_vehicle_mg_grail_link) {
	for (xc = 0;xc < autocvar_g_vehicle_mg_grail_link_iter;xc = xc + 1) {
		if not (autocvar_g_vehicle_mg_grail_link1_skip)
			mg_grail_linkattack("tag_mgun1", xfwd, xspd, gunmount);
		if not (autocvar_g_vehicle_mg_grail_link1_skipiter)
			xfwd += autocvar_g_vehicle_mg_grail_link_iterforwardsub;
		if not (autocvar_g_vehicle_mg_grail_link1_skipspeed)
			xspd += autocvar_g_vehicle_mg_grail_link_itersubspeedadd;
	
		if not (autocvar_g_vehicle_mg_grail_link2_skip)
			mg_grail_linkattack("tag_mgun2", xfwd, xspd, gunmount);
		if not (autocvar_g_vehicle_mg_grail_link2_skipiter)
			xfwd += autocvar_g_vehicle_mg_grail_link_iterforwardsub;
		if not (autocvar_g_vehicle_mg_grail_link2_skipspeed)
			xspd += autocvar_g_vehicle_mg_grail_link_itersubspeedadd;		
	
		if not (autocvar_g_vehicle_mg_grail_link3_skip)
			mg_grail_linkattack("tag_mgun3", xfwd, xspd, gunmount);
		if not (autocvar_g_vehicle_mg_grail_link3_skipiter)
			xfwd += autocvar_g_vehicle_mg_grail_link_iterforwardsub;
		if not (autocvar_g_vehicle_mg_grail_link3_skipspeed)
			xspd += autocvar_g_vehicle_mg_grail_link_itersubspeedadd;
			
		if not (autocvar_g_vehicle_mg_grail_link4_skip)
			mg_grail_linkattack("tag_mgun4", xfwd, xspd, gunmount);
		if not (autocvar_g_vehicle_mg_grail_link4_skipiter)
			xfwd += autocvar_g_vehicle_mg_grail_link_iterforwardsub;
		if not (autocvar_g_vehicle_mg_grail_link4_skipspeed)
			xspd += autocvar_g_vehicle_mg_grail_link_itersubspeedadd;
			
		if not (autocvar_g_vehicle_mg_grail_link5_skip)
			mg_grail_linkattack("tag_mgun5", xfwd, xspd, gunmount);
		if not (autocvar_g_vehicle_mg_grail_link5_skipiter)
			xfwd += autocvar_g_vehicle_mg_grail_link_iterforwardsub;
		if not (autocvar_g_vehicle_mg_grail_link5_skipspeed)
			xspd += autocvar_g_vehicle_mg_grail_link_itersubspeedadd;
	
		xfwd += autocvar_g_vehicle_mg_grail_link_iterforward;
		xspd += autocvar_g_vehicle_mg_grail_link_iterspeedadd;
		//So you can make patterns
	}
	}

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 
   
	 //sound (gunmount, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);

	    
            self = mg_grail;

            mg_grail.vehicle_ammo1 -= autocvar_g_vehicle_mg_grail_railgun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_grail_railgun_refire;
            player.vehicle_ammo1 = (mg_grail.vehicle_ammo1 / autocvar_g_vehicle_mg_grail_railgun_ammo_max) * 100;
         
        }
}

float mg_grail_frame()
{
    vector ad;
    entity player, mg_grail;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_grail = self.vehicle;
    self   = mg_grail;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_grail.tur_head, gettagindex(mg_grail.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_grail);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_grail.angles), AnglesTransform_FromAngles(ad))) - mg_grail.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_grail_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_grail.tur_head.angles_y = bound(autocvar_g_vehicle_mg_grail_gun_turnlimit * -1, mg_grail.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_grail_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_grail_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_grail.tur_head.angles_x = bound(autocvar_g_vehicle_mg_grail_gun_pitchlimit_down, mg_grail.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_grail_gun_pitchlimit_up);


    //fixedmakevectors(mg_grail.angles);
    makevectors(mg_grail.angles + '-2 0 0' * mg_grail.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_grail_springlength, autocvar_g_vehicle_mg_grail_springup, autocvar_g_vehicle_mg_grail_springblend, autocvar_g_vehicle_mg_grail_tiltlimit);

    if(mg_grail.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_grail_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_grail.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_grail, player, -133); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_grail.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_grail, player, autocvar_g_vehicle_mg_grail_speed_walk, autocvar_g_vehicle_mg_grail_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_grail_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_grail_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_grail_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_grail_tiltlimit);
    
    
    if(player.BUTTON_ATCK)
    {
        mg_grail_fire(mg_grail, player, mg_grail.tur_head);
    } else {
        vehicles_regen(mg_grail.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_grail_railgun_ammo_max,
                                           autocvar_g_vehicle_mg_grail_railgun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_grail_railgun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_grail.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_grail_shield, autocvar_g_vehicle_mg_grail_shield_regen_pause, autocvar_g_vehicle_mg_grail_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_grail.dmg_time, vehicle_health, autocvar_g_vehicle_mg_grail_health, autocvar_g_vehicle_mg_grail_health_regen_pause, autocvar_g_vehicle_mg_grail_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_grail.origin + '0 0 1' * MG_GRAIL_MAX_z);
    player.velocity = mg_grail.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_grail);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_grail);

    self = player;
    return 1;    
}
void mg_grail_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_grail_speed_stop);

    self.nextthink = time;
}

void mg_grail_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_grail_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_grail_shield) * 100;
    
    mg_enter(self.owner);
}

void mg_grail_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_grail_think;
    self.nextthink  = time;
    self.frame      = 5;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    
	    spot = mg_exit_stationary(spot);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_grail_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			
			spot = mg_exit_stationary(spot);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = mg_exit_stationary(spot);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void mg_grail_impact()
{
    if(autocvar_g_vehicle_mg_grail_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_grail_bouncepain_x, autocvar_g_vehicle_mg_grail_bouncepain_y, autocvar_g_vehicle_mg_grail_bouncepain_z);    
}

void mg_grail_headfade()
{
	self.think = mg_grail_headfade;
	self.nextthink = self.fade_time;
	self.alpha = 1 - (time - self.fade_time) * self.fade_rate;

    if(self.cnt < time || self.alpha < 0.1)
    {
        if(self.alpha > 0.1)
        {
            sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
            pointparticles(particleeffectnum("explosion_big"), self.origin + '0 0 100', '0 0 0', 1);
        }
        remove(self);
    }
}

void mg_grail_blowup()
{
    if(self.cnt > time)
    {
        if(random() < 0.1)
        {
            sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
            pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
        }
        self.nextthink = time + 0.1;
        return;
    }
    
    entity h, b;
    b = spawn();
    h = spawn();


    setmodel(b,  "models/mountedguns/maximgun_mount.iqm");
    h.lodmodel1 = "models/mountedguns/grailgun_lod1.iqm";
    setmodel(h,  "models/mountedguns/grailgun.iqm");
    InitializeEntity(h, LODmodel_attach, INITPRIO_FINDTARGET);

    setorigin(b, self.origin);
    b.frame         = 11;
    b.angles        = self.angles;
    setsize(b, self.mins, self.maxs);

    setorigin(h, gettaginfo(self, gettagindex(self, "tag_head")));
    h.movetype      = MOVETYPE_BOUNCE;
    h.solid         = SOLID_BBOX;
    h.velocity      = v_up * (500 + random() * 500) + randomvec() * 128;
    h.modelflags    = MF_ROCKET;
    h.effects       = EF_FLAME | EF_LOWPRECISION;
    h.avelocity     = randomvec() * 360;

    h.alpha         = 1;
    h.cnt           = time + (3.5 * random());
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_grail_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_grail_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_grail_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_grail_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_grail_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_grail_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_grail_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();    
        
        self.gravity            = 1;
        self.mass               = 250;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/grailgun_lod1.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_grail_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_grail_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_grail_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = self.tur_head.alpha = self.colormap;
    self.tur_head.angles    = '0 0 0';

    if (self.spawnflags >= 16) {
	setorigin(self, self.pos1);
	self.movetype           = MOVETYPE_NONE;
    } else {
	setorigin(self, self.pos1 + '0 0 32');	
    }
    self.angles = self.pos2;
    self.vehicle_impact = mg_grail_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_grail()
{
    if(!autocvar_g_vehicle_mg_grail)
    {
        remove(self);
        return;
    }        
    
    string bodymodel;
    if (self.spawnflags == 16) {
    	precache_model ( "models/mountedguns/maximgun_circmount.iqm");
	bodymodel = "models/mountedguns/maximgun_circmount.iqm";
    } else if (self.spawnflags == 32) {
    	precache_model ( "models/mountedguns/maximgun_pointmount.iqm");
	bodymodel = "models/mountedguns/maximgun_pointmount.iqm";
    } else {
    	precache_model ( "models/mountedguns/maximgun_mount.iqm");
    	bodymodel = "models/mountedguns/maximgun_mount.iqm";
	self.vehicle_flags |= VHF_DMGSHAKE;
    }
    
    mg_shield_precache();
    precache_model ( "models/mountedguns/grailgun.iqm");
    precache_model ( "models/mountedguns/grailgun_lod1.iqm");

    precache_sound ( "weapons/electro_fire.wav" );
    precache_sound ( "weapons/crylink_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_grail_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_grail_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_grail_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "GRailGun",
             bodymodel,
             "models/mountedguns/grailgun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_GRAIL_MIN, MG_GRAIL_MAX,
             FALSE,
             mg_grail_spawn, autocvar_g_vehicle_mg_grail_respawntime,
             mg_grail_frame,
             mg_grail_enter, mg_grail_exit,
             mg_grail_die,   mg_grail_think,
             FALSE, 
             autocvar_g_vehicle_mg_grail_health,
             autocvar_g_vehicle_mg_grail_shield, 1, 0, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

