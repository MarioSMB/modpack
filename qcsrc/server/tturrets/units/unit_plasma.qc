void spawnfunc_turret_plasma();
void spawnfunc_turret_plasma_dual();

void turret_plasma_std_init();
void turret_plasma_dual_init();

void turret_plasma_attack();


void turret_plasma_postthink()
{
    if (self.tur_head.frame != 0)
        self.tur_head.frame = self.tur_head.frame + 1;

    if (self.tur_head.frame > 5)
        self.tur_head.frame = 0;
}

void turret_plasma_dual_postthink()
{
    if ((self.tur_head.frame != 0) && (self.tur_head.frame != 3))
        self.tur_head.frame = self.tur_head.frame + 1;

    if (self.tur_head.frame > 6)
        self.tur_head.frame = 0;
}

void turret_plasma_minsta_attack (void)
{
	float flying;
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last
        
	FireRailgunBullet (self.tur_shotorg, self.tur_shotorg + self.tur_shotdir_updated * MAX_SHOT_DISTANCE, 10000000000,
					   800, 0, 0, 0, 0, DEATH_TURRET_PLASMA);


	pointparticles(particleeffectnum("nex_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);

	// teamcolor / hit beam effect
	vector v;
	string s;
	v = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	s = strcat("TE_TEI_G3", Static_Team_ColorName_Upper(self.team));
    WarpZone_TrailParticles(world, particleeffectnum(s), self.tur_shotorg, v);
	
    if (self.tur_head.frame == 0)
        self.tur_head.frame = 1;
}

void turret_plasma_attack()
{ 
    entity missile = turret_projectile("weapons/hagar_fire.wav", 1, 0, DEATH_TURRET_PLASMA, PROJECTILE_ELECTRO_BEAM, TRUE, TRUE);    
    missile.missile_flags = MIF_SPLASH;
    
    pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);
    if (self.tur_head.frame == 0)
        self.tur_head.frame = 1;
}

void turret_plasma_dual_minsta_attack (void)
{
	float flying;
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last
        
	FireRailgunBullet (self.tur_shotorg, self.tur_shotorg + self.tur_shotdir_updated * MAX_SHOT_DISTANCE, 10000000000,
					   800, 0, 0, 0, 0, DEATH_TURRET_PLASMA);


	pointparticles(particleeffectnum("nex_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);

	// teamcolor / hit beam effect
	vector v;
	string s;
	v = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	s = strcat("TE_TEI_G3", Static_Team_ColorName_Upper(self.team));
    WarpZone_TrailParticles(world, particleeffectnum(s), self.tur_shotorg, v);
	
    self.tur_head.frame += 1;
}

void turret_plasma_dual_attack()
{
    entity missile = turret_projectile("weapons/hagar_fire.wav", 1, 0, DEATH_TURRET_PLASMA, PROJECTILE_ELECTRO_BEAM, TRUE, TRUE); 
    missile.missile_flags = MIF_SPLASH;   
    pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);
    self.tur_head.frame += 1;
}

void turret_plasma_std_init()
{
    if (self.netname == "")      self.netname     = "Plasma Cannon";

    // What ammo to use
    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;

    // How to aim
    self.aim_flags      = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE | TFL_AIM_GROUNDGROUND;
    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL;

    if (turret_stdproc_init("plasma_std", "models/turrets/base.md3", "models/turrets/plasma.md3", TID_PLASMA) == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags    |= TFL_DMG_HEADSHAKE;
    self.firecheck_flags |= TFL_FIRECHECK_AFF;

    // Our fireing routine
    if(g_minstagib)
        self.turret_firefunc  = turret_plasma_minsta_attack;
    else
        self.turret_firefunc  = turret_plasma_attack;

    // Custom per turret frame stuff. usualy animation.
    self.turret_postthink = turret_plasma_postthink;
    turret_do_updates(self);
}


void turret_plasma_dual_init()
{
    if (self.netname == "")      self.netname     = "Dual Plasma Cannon";

    // What ammo to use
    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;

    // How to aim at targets
    self.aim_flags      = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE  | TFL_AIM_GROUNDGROUND ;
    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL;

    if (turret_stdproc_init("plasma_dual", "models/turrets/base.md3", "models/turrets/plasmad.md3", TID_PLASMA_DUAL) == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags    |= TFL_DMG_HEADSHAKE;
    self.firecheck_flags |= TFL_FIRECHECK_AFF;

    // Our fireing routine
    self.turret_firefunc  = turret_plasma_dual_attack;
	
	if(g_minstagib)
        self.turret_firefunc = turret_plasma_dual_minsta_attack;
    else
        self.turret_firefunc = turret_plasma_dual_attack;

    // Custom per turret frame stuff. usualy animation.
    self.turret_postthink = turret_plasma_dual_postthink;
}


/*
* Basic moderate (std) or fast (dual) fireing, short-mid range energy cannon.
* Not too mutch of a therat on its own, but can be rather dangerous in groups.
* Regenerates ammo slowly, support with a fusionreactor(s) to do some real damage.
*/

/*QUAKED turret_plasma (0 .5 .8) ?
*/
void spawnfunc_turret_plasma()
{
    g_turrets_common_precash();
    precache_model ("models/turrets/plasma.md3");
    precache_model ("models/turrets/base.md3");

    self.think = turret_plasma_std_init;
    self.nextthink = time + 0.5;
}

/*QUAKED turret_plasma_dual (0 .5 .8) ?
*/
void spawnfunc_turret_plasma_dual()
{

    precache_model ("models/turrets/plasmad.md3");
    precache_model ("models/turrets/base.md3");

    self.think = turret_plasma_dual_init;
    self.nextthink = time + 0.5;
}

