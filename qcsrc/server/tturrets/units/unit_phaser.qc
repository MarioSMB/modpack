void spawnfunc_turret_phaser();
void turret_phaser_dinit();
void turret_phaser_attack();

.float fireflag;

float turret_phaser_firecheck()
{
    if (self.fireflag != 0) return 0;
    return turret_stdproc_firecheck();
}

void turret_phaser_postthink()
{
    if (self.tur_head.frame == 0)
        return;

    if (self.fireflag == 1)
    {
        if (self.tur_head.frame == 10)
            self.tur_head.frame = 1;
        else
            self.tur_head.frame = self.tur_head.frame +1;
    }
    else if (self.fireflag == 2 )
    {
        self.tur_head.frame = self.tur_head.frame +1;
        if (self.tur_head.frame == 15)
        {
            self.tur_head.frame = 0;
            self.fireflag = 0;
        }
    }
}

void beam_think()
{
    if ((time > self.cnt) || (self.owner.deadflag != DEAD_NO))
    {
        self.owner.attack_finished_single = time + self.owner.shot_refire;
        self.owner.fireflag = 2;
        self.owner.tur_head.frame = 10;
        sound (self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTEN_NORM);
        remove(self);
        return;
    }

    turret_do_updates(self.owner);

    if (time - self.shot_spread > 0)
    {
        self.shot_spread = time + 2;
        sound (self, CH_SHOTS_SINGLE, "turrets/phaser.wav", VOL_BASE, ATTEN_NORM);
    }


    self.nextthink = time + self.ticrate;

    self.owner.attack_finished_single = time + frametime;
    entity oldself;
    oldself = self;
    self = self.owner;
    FireImoBeam (   self.tur_shotorg,
                    self.tur_shotorg + self.tur_shotdir_updated * self.target_range,
                    '-1 -1 -1' * self.shot_radius,
                    '1 1 1' * self.shot_radius,
                    self.shot_force,
                    oldself.shot_dmg,
                    0.75,
                    DEATH_TURRET_PHASER);
    self = oldself;
    self.scale = vlen(self.owner.tur_shotorg - trace_endpos) / 256;

}

void turret_phaser_attack()
{
    entity beam;

    beam = spawn();
    beam.ticrate = 0.1; //autocvar_sys_ticrate;
    setmodel(beam,"models/turrets/phaser_beam.md3");
    beam.effects = EF_LOWPRECISION;
    beam.solid = SOLID_NOT;
    beam.think = beam_think;
    beam.cnt = time + self.shot_speed;
    beam.shot_spread = time + 2;
    beam.nextthink = time;
    beam.owner = self;
    beam.shot_dmg = self.shot_dmg / (self.shot_speed / beam.ticrate);
    beam.scale = self.target_range / 256;
    beam.movetype = MOVETYPE_NONE;
    beam.enemy = self.enemy;
    beam.bot_dodge = TRUE;
    beam.bot_dodgerating = beam.shot_dmg;
    sound (beam, CH_SHOTS_SINGLE, "turrets/phaser.wav", VOL_BASE, ATTEN_NORM);
    self.fireflag = 1;

    beam.attack_finished_single = self.attack_finished_single;
    self.attack_finished_single = time; // + autocvar_sys_ticrate;

    setattachment(beam,self.tur_head,"tag_fire");

    soundat (self, trace_endpos, CH_SHOTS, "weapons/neximpact.wav", VOL_BASE, ATTEN_NORM);

    if (self.tur_head.frame == 0)
        self.tur_head.frame = 1;
}

void turret_phaser_dinit()
{
    if (self.netname == "")      self.netname  = "Phaser Cannon";

    self.turrcaps_flags = TFL_TURRCAPS_SNIPER|TFL_TURRCAPS_HITSCAN|TFL_TURRCAPS_PLAYERKILL;
    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.aim_flags = TFL_AIM_LEAD;

    if (turret_stdproc_init("phaser_std", "models/turrets/base.md3","models/turrets/phaser.md3", TID_PHASER) == 0)
    {
        remove(self);
        return;
    }

    self.turret_firecheckfunc = turret_phaser_firecheck;
    self.turret_firefunc  = turret_phaser_attack;
    self.turret_postthink = turret_phaser_postthink;

}

/*QUAKED turret_phaser(0 .5 .8) ?
*/
void spawnfunc_turret_phaser()
{
    precache_sound ("turrets/phaser.wav");
    precache_model ("models/turrets/phaser.md3");
    precache_model ("models/turrets/phaser_beam.md3");
    precache_model ("models/turrets/base.md3");

    self.think = turret_phaser_dinit;
    self.nextthink = time + 0.5;
}

