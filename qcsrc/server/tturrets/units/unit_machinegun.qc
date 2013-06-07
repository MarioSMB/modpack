void spawnfunc_turret_machinegun();
void turret_machinegun_std_init();
void turret_machinegun_attack();

//.float bulletcounter;
void turret_machinegun_attack()
{
    fireBallisticBullet (self.tur_shotorg, self.tur_shotdir_updated,self.shot_spread, self.shot_speed, 5, self.shot_dmg, self.shot_force, DEATH_TURRET_MACHINEGUN, 0, 1, autocvar_g_balance_uzi_bulletconstant);
    endFireBallisticBullet();

    UziFlash();
    setattachment(self.muzzle_flash, self.tur_head, "tag_fire");
}


void turret_machinegun_std_init()
{
    if (self.netname == "")      self.netname     = "Machinegun Turret";

    self.ammo_flags = TFL_AMMO_BULLETS | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_PLAYERKILL;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
    
	if not (autocvar_g_antilag_bullets)
		self.turrcaps_flags |= TFL_TURRCAPS_HITSCAN;

    if (turret_stdproc_init("machinegun_std", "models/turrets/base.md3", "models/turrets/machinegun.md3", TID_MACHINEGUN) == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags |= TFL_DMG_HEADSHAKE;
	self.target_select_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;

    // Our fire routine
    self.turret_firefunc  = turret_machinegun_attack;

}


/*QUAKED turret_machinegun (0 .5 .8) ?
* machinegun turret. does what you'd expect
*/
void spawnfunc_turret_machinegun()
{
    precache_model ("models/turrets/machinegun.md3");
    precache_model ("models/turrets/base.md3");
    precache_sound ("weapons/uzi_fire.wav");

    self.think = turret_machinegun_std_init;
    self.nextthink = time + 0.5;
}

