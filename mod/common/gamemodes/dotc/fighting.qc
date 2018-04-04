void dotc_projectile_think(entity this)
{
	//UpdateCSQCProjectile(this);
	this.nextthink = time;
}

void dotc_projectile_explode(entity this, entity directhitentity)
{
    this.event_damage = func_null;
	settouch(this, func_null);

	traceline(this.origin - this.velocity, this.origin + (this.velocity * 2), MOVE_NORMAL, this);
	if(trace_fraction == 1.0)
        Send_Effect(this.explode_fx, findbetterlocation(this.origin, 8), normalize(this.velocity), 1);
    else
        Send_Effect(this.explode_fx, findbetterlocation(this.origin, 8), trace_plane_normal, 1);

    RadiusDamage(this, this.owner, this.shot_dmg, 0, this.shot_radius, NULL, NULL, this.shot_force, this.projectiledeathtype, DMG_NOWEP, directhitentity);
    sound(this, CH_SHOTS, this.explode_snd, VOL_BASE, ATTN_NORM);

	delete(this);
}

void dotc_projectile_touch(entity this, entity toucher)
{
    PROJECTILE_TOUCH(this, toucher);

    dotc_projectile_explode(this, toucher);
}

void dotc_projectile_explode_think(entity this)
{
    dotc_projectile_explode(this, NULL);
}

void dotc_projectile_damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, .entity weaponentity, vector hitloc, vector force)
{
    this.health -= damage;

    if(this.health >= 0)
        return;

    setthink(this, dotc_projectile_explode_think);
    this.nextthink = time;
}

entity dotc_projectile( entity this,
                        Sound msound,
                        entity fxflash,
                        entity fxexplode,
                        Sound sfxexplode,
                        float pgravity,
                        float phealth,
                        int pdeathtype,
                        int projectile_id)
{
    sound(this, CH_WEAPON_A, msound, VOL_BASE, ATTN_NORM);
    Send_Effect(fxflash, this.tur_shotorg, v_forward * this.shot_speed, 1);


    //dprint("^1FXFLASH IS: ",fxflash, "  FXEXPLODE IS: ", fxexplode, "\n");

    entity proj = new(dotc_projectile);

	PROJECTILE_MAKETRIGGER(proj);
    setorigin(proj, this.tur_shotorg);
    setsize(proj, '0 0 0 ', '0 0 0');

    //proj.trail_fx;
    proj.explode_snd     = sfxexplode;
    proj.explode_fx      = fxexplode;
    proj.flags           = FL_PROJECTILE;
    proj.owner           = proj.realowner = this;
    proj.shot_dmg 		 = this.shot_dmg;
    proj.shot_radius  	 = this.shot_radius;
    proj.shot_force 	 = this.shot_force;
    proj.bot_dodge       = true;
    proj.bot_dodgerating = this.shot_dmg;
    proj.projectiledeathtype = pdeathtype;
    settouch(proj, dotc_projectile_touch);
    proj.velocity        = normalize(v_forward + randomvec() * this.shot_spread) * this.shot_speed;

    if(phealth)
    {
        proj.health     = phealth;
        proj.takedamage = DAMAGE_YES;
        proj.event_damage = dotc_projectile_damage;
    }
    else
    {
        proj.flags |= FL_NOTARGET;
    }

    IL_PUSH(g_projectiles, proj);
    IL_PUSH(g_bot_dodge, proj);

    if(pgravity)
	{
		set_movetype(proj, MOVETYPE_TOSS);
		proj.gravity = pgravity;
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
