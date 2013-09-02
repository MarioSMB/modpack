/*
* Spawn a boom, trow fake bits arround
* and hide the real ones.
*/
void turret_hide()
{
    self.effects   |= EF_NODRAW;
    self.nextthink = time + self.respawntime - 0.2;
    self.think     = turret_stdproc_respawn;
}

void turret_stdproc_die()
{
    self.deadflag           = DEAD_DEAD;
    self.tur_head.deadflag  = self.deadflag;

// Unsolidify and hide real parts
    self.solid              = SOLID_NOT;
    self.tur_head.solid     = self.solid;

    self.event_damage           = func_null;
    self.takedamage             = DAMAGE_NO;

    self.health             = 0;

// Go boom
    //RadiusDamage (self,self, min(self.ammo,50),min(self.ammo,50) * 0.25,250,world,min(self.ammo,50)*5,DEATH_TURRET,world);

    if(self.damage_flags & TFL_DMG_DEATH_NORESPAWN)
    {
        if (self.turret_diehook)
            self.turret_diehook();

        remove(self.tur_head);
        remove(self);
    }
    else
    {
		// Setup respawn
        self.SendFlags      |= TNSF_STATUS;
        self.nextthink      = time + 0.2;
        self.think          = turret_hide;
        
        if (self.turret_diehook)
            self.turret_diehook();
    }
}

void turret_stdproc_respawn()
{
    // Make sure all parts belong to the same team since
    // this function doubles as "teamchange" function.
    self.tur_head.team 	= self.team;

    self.effects             &= ~EF_NODRAW;
    self.deadflag           = DEAD_NO;
    self.effects            = EF_LOWPRECISION;
    self.solid              = SOLID_BBOX;
    
    self.takedamage 			= DAMAGE_AIM;
    self.event_damage           = turret_stdproc_damage;

    self.avelocity              = '0 0 0';
    self.tur_head.avelocity     = self.avelocity;
    self.tur_head.angles        = self.idle_aim;
    self.health                 = self.tur_health;

    self.enemy                  = world;
    self.volly_counter          = self.shot_volly;
    self.ammo                   = self.ammo_max;

    self.nextthink  = time + self.ticrate;
    self.think      = turret_think;
    
    self.SendFlags  = TNSF_FULL_UPDATE;

    if (self.turret_respawnhook)
        self.turret_respawnhook();
}

/*
* Standard damage proc.
*/
void turret_stdproc_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    // Enougth allready!
    if(self.deadflag == DEAD_DEAD)
        return;

    // Inactive turrets take no damage. (hm..)
    if not (self.active)
        return;

    if (teamplay)
    if (self.team == attacker.team)
    {
        // This does not happen anymore. Re-enable if you fix that.
        if(IS_REAL_CLIENT(attacker))
            sprint(attacker, "\{1}Turret tells you: I'm on your team!\n");

        if(autocvar_g_friendlyfire)
            damage = damage * autocvar_g_friendlyfire;
        else
            return;
    }

    self.health = self.health - damage;

    // thorw head slightly off aim when hit?
    if (self.damage_flags & TFL_DMG_HEADSHAKE)
    {
        self.tur_head.angles_x = self.tur_head.angles_x + (-0.5 + random()) * damage;
        self.tur_head.angles_y = self.tur_head.angles_y + (-0.5 + random()) * damage;
        
        self.SendFlags  |= TNSF_ANG;
    }

    if (self.turrcaps_flags & TFL_TURRCAPS_MOVE)
        self.velocity = self.velocity + vforce;
    
    if (self.health <= 0)
    {
        self.event_damage           = func_null;
        self.tur_head.event_damage  = func_null;
        self.takedamage             = DAMAGE_NO;
        self.nextthink = time;
        self.think = turret_stdproc_die;
    }
    
    self.SendFlags  |= TNSF_STATUS;
}
