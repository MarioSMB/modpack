void spawnfunc_turret_flac();
void turret_flac_dinit();
void turret_flac_attack();

void turret_flac_projectile_think_explode()
{
    if(self.enemy != world)
    if(vlen(self.origin - self.enemy.origin) < self.owner.shot_radius * 3)
        setorigin(self,self.enemy.origin + randomvec() * self.owner.shot_radius);
            
#ifdef TURRET_DEBUG
    float d;
    d = RadiusDamage (self, self.owner, self.owner.shot_dmg, self.owner.shot_dmg, self.owner.shot_radius, self, self.owner.shot_force, self.totalfrags, world);
    self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + d;
    self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#else
    RadiusDamage (self, self.realowner, self.owner.shot_dmg, self.owner.shot_dmg, self.owner.shot_radius, self, self.owner.shot_force, self.totalfrags, world);
#endif
    remove(self);
}

void turret_flac_attack()
{
    entity proj;

    turret_tag_fire_update();
    
    proj = turret_projectile("weapons/hagar_fire.wav", 5, 0, DEATH_TURRET_FLAC, PROJECTILE_HAGAR, TRUE, TRUE);    
    pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);
    proj.think      = turret_flac_projectile_think_explode;
    proj.nextthink  = time + self.tur_impacttime + (random() * 0.01 - random() * 0.01);
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
    self.tur_head.frame = self.tur_head.frame + 1;
    if (self.tur_head.frame >= 4) 
        self.tur_head.frame = 0;

}

void turret_flac_dinit()
{
    if (self.netname == "")      
        self.netname  = "FLAC Cannon";

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_FASTPROJ | TFL_TURRCAPS_MISSILEKILL;
    self.ammo_flags     = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
    self.aim_flags      = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
    
    if (turret_stdproc_init("flac_std", "models/turrets/base.md3", "models/turrets/flac.md3", TID_FLAC) == 0)
    {
        remove(self);
        return;
    }
    setsize(self.tur_head,'-32 -32 0','32 32 64');

    self.damage_flags |= TFL_DMG_HEADSHAKE;
    self.target_select_flags |= TFL_TARGETSELECT_NOTURRETS | TFL_TARGETSELECT_MISSILESONLY;
    
    // Our fire routine
    self.turret_firefunc  = turret_flac_attack;

}
/*QUAKED turret_flac (0 .5 .8) ?
*/

void spawnfunc_turret_flac()
{
    precache_model ("models/turrets/base.md3");
    precache_model ("models/turrets/flac.md3");

    self.think = turret_flac_dinit;
    self.nextthink = time + 0.5;
}

