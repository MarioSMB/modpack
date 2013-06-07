void spawnfunc_turret_mlrs();
void turret_mlrs_dinit();
void turret_mlrs_attack();

void turret_mlrs_postthink()
{
    // 0 = full, 6 = empty
    self.tur_head.frame = bound(0, 6 - floor(0.1 + self.ammo / self.shot_dmg), 6);
    if(self.tur_head.frame < 0)
    {
    	dprint("ammo:",ftos(self.ammo),"\n");
    	dprint("shot_dmg:",ftos(self.shot_dmg),"\n");
    }
}

void turret_mlrs_attack()
{
    entity missile;
    
    turret_tag_fire_update();    
    missile = turret_projectile("weapons/rocket_fire.wav", 6, 10, DEATH_TURRET_MLRS, PROJECTILE_ROCKET, TRUE, TRUE);
    missile.nextthink = time + max(self.tur_impacttime,(self.shot_radius * 2) / self.shot_speed);
    missile.missile_flags = MIF_SPLASH;
    te_explosion (missile.origin);    
}

void turret_mlrs_dinit()
{
    if (self.netname == "")      self.netname  = "MLRS turret";

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL;
    self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;

    if (turret_stdproc_init("mlrs_std", "models/turrets/base.md3", "models/turrets/mlrs.md3", TID_MLRS) == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags |= TFL_DMG_HEADSHAKE;
    self.shoot_flags  |= TFL_SHOOT_VOLLYALWAYS;
    self.volly_counter = self.shot_volly;

    // Our fire routine
    self.turret_firefunc  = turret_mlrs_attack;
    self.turret_postthink = turret_mlrs_postthink;

}

/*QUAKED turret_mlrs (0 .5 .8) ?
*/

void spawnfunc_turret_mlrs()
{
    precache_model ("models/turrets/mlrs.md3");
    precache_model ("models/turrets/base.md3");

    self.think = turret_mlrs_dinit;
    self.nextthink = time + 0.5;
}


