void dotc_projectile_think(entity this)
{
	//UpdateCSQCProjectile(this);
	this.nextthink = time;
}

void dotc_projectile_touch(entity this, entity toucher)
{
 	PROJECTILE_TOUCH(this, toucher);

    this.event_damage 	= func_null;
	settouch(this, func_null);

	traceline(this.origin - this.velocity, this.origin + (this.velocity * 2), MOVE_NORMAL, this);
	if(trace_fraction == 1.0)
        __pointparticles(__particleeffectnum(this.explode_fx), findbetterlocation (this.origin, 8), normalize(this.velocity), 1);
	else
        __pointparticles(__particleeffectnum(this.explode_fx), findbetterlocation (this.origin, 8), trace_plane_normal, 1);

    RadiusDamage (this, this.owner, this.shot_dmg, 0, this.shot_radius, world, world, this.shot_force, DEATH_TURRET.m_id, world);
    _sound (this, CH_SHOTS, this.explode_snd, VOL_BASE, ATTN_NORM);

	remove(this);
}

void dotc_projectile_touch_think(entity this)
{
    dotc_projectile_touch(this, NULL);
}

void dotc_projectile_damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{
    this.health -= damage;

    if(this.health >= 0)
        return;

    setthink(this, dotc_projectile_touch_think);
    this.nextthink = time;
}

entity dotc_projectile( entity this,
                        Sound msound,
                        string fxflash,
                        string fxexplode,
                        float  pgravity,
                        float  phealth,
                        int  projectile_id)
{
    sound (this, CH_WEAPON_A, msound, VOL_BASE, ATTN_NORM);
    __pointparticles(__particleeffectnum(fxflash), this.tur_shotorg, v_forward * this.shot_speed, 1);


    //dprint("^1FXFLASH IS: ",fxflash, "  FXEXPLODE IS: ", fxexplode, "\n");

    entity proj = spawn();

	PROJECTILE_MAKETRIGGER(proj);
    setorigin(proj, this.tur_shotorg);
    setsize(proj, '0 0 0 ', '0 0 0');

    //proj.trail_fx;
    //proj.explode_snd;
    proj.explode_fx      = fxexplode;
    proj.owner           = proj.realowner = this;
    proj.shot_dmg 		 = this.shot_dmg;
    proj.shot_radius  	 = this.shot_radius;
    proj.shot_force 	 = this.shot_force;
    proj.bot_dodge       = true;
    proj.bot_dodgerating = this.shot_dmg;
    settouch(proj, dotc_projectile_touch);
    proj.velocity        = normalize(v_forward + randomvec() * this.shot_spread) * this.shot_speed;

    if(phealth)
    {
        proj.health     = phealth;
        proj.flags      = FL_PROJECTILE;
        proj.takedamage = DAMAGE_YES;
        proj.event_damage = dotc_projectile_damage;
    }
    else
    {
        proj.flags  = FL_PROJECTILE | FL_NOTARGET;
    }

    IL_PUSH(g_projectiles, proj);


    if(pgravity)
	{
		set_movetype(proj, MOVETYPE_TOSS);
		proj.gravity    = pgravity;
		setthink(proj, dotc_projectile_think);
		proj.nextthink  = time;
		CSQCProjectile(proj, true, projectile_id, true);

	}
    else
    {
        set_movetype(proj, MOVETYPE_FLY);
        setthink(proj, SUB_Remove);
        proj.nextthink = time + 9;
        CSQCProjectile(proj, true, projectile_id, true);
    }

    return proj;
}
