#include "cyberchop_weapons.qh"

#ifdef SVQC

//TODO: REPLACE RAPTOR CANNON WITH ELECTRO ORBS ATTACK

METHOD(CyberChopMinigun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire)) {
    bool isPlayer = IS_PLAYER(actor);
    entity player = isPlayer ? actor : actor.owner;
    entity veh = player.vehicle;
    // 1 [wait] 1 [wait] 2 [wait] 2 [wait] [wait]
    float t = autocvar_g_vehicle_cyberchop_minigun_refire * (1 + ((veh.misc_bulletcounter + 1) >= 4));
    if (fire & 1)
    if (weapon_prepareattack(thiswep, player, weaponentity, false, t)) {
        if (isPlayer) W_SetupShot_Dir(player, weaponentity, v_forward, false, 0, SND_Null, CH_WEAPON_B, 0, DEATH_VH_RAPT_CANNON.m_id);
        vector org = w_shotorg;
        vector dir = w_shotdir;
        if (veh) {
            veh.misc_bulletcounter += 1;
            org = (veh.misc_bulletcounter <= 2) ? gettaginfo(veh.gun1, gettagindex(veh.gun1, "fire1"))
              : (((veh.misc_bulletcounter >= 4) ? veh.misc_bulletcounter = 0 : 0), gettaginfo(veh.gun2, gettagindex(veh.gun2, "fire1")));
            dir = v_forward;
            veh.vehicle_energy -= autocvar_g_vehicle_cyberchop_minigun_cost;
            actor.cnt = time;
        }
        vehicles_projectile(veh, EFFECT_BIGPLASMA_MUZZLEFLASH, SND_ELECTRO_FIRE,
                               org, normalize(dir + randomvec() * autocvar_g_vehicle_cyberchop_minigun_spread) * autocvar_g_vehicle_cyberchop_minigun_speed,
                               autocvar_g_vehicle_cyberchop_minigun_damage, autocvar_g_vehicle_cyberchop_minigun_radius, autocvar_g_vehicle_cyberchop_minigun_force,  0,
                               DEATH_VH_RAPT_CANNON.m_id, PROJECTILE_ELECTRO, 0, true, true, player);
        //CSQCProjectile(veh, true, PROJECTILE_ELECTRO, true);
        weapon_thinkf(player, weaponentity, WFRAME_FIRE1, 0, w_ready);
    }
}
METHOD(CyberChopMinigun, wr_checkammo1, bool(RacerAttack thiswep, entity actor, .entity weaponentity)) {
    bool isPlayer = IS_PLAYER(actor);
    entity player = isPlayer ? actor : actor.owner;
    entity veh = player.vehicle;
    return isPlayer || veh.vehicle_energy >= autocvar_g_vehicle_cyberchop_minigun_cost;
}


void cyberchop_bombdrop(entity this);
METHOD(CyberChopBomb, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire)) {
    bool isPlayer = IS_PLAYER(actor);
    entity player = isPlayer ? actor : actor.owner;
    entity veh = player.vehicle;
    if (fire & 2)
    if (!isPlayer || weapon_prepareattack(thiswep, player, weaponentity, true, autocvar_g_vehicle_cyberchop_bombs_refire)) {
        entity e = (veh) ? veh : player;
        cyberchop_bombdrop(e);
        weapon_thinkf(player, weaponentity, WFRAME_FIRE2, 0, w_ready);
    }
}

void cyberchop_flare_think(entity this);
void cyberchop_flare_damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, .entity weaponentity, vector hitloc, vector force);
void cyberchop_flare_touch(entity this, entity toucher);

METHOD(CyberChopFlare, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire)) {
    bool isPlayer = IS_PLAYER(actor);
    entity player = isPlayer ? actor : actor.owner;
    entity veh = player.vehicle;
    if (fire & 2)
    if (!isPlayer || weapon_prepareattack(thiswep, player, weaponentity, true, autocvar_g_vehicle_cyberchop_flare_refire)) {
        vector forward, right, up;
        MAKE_VECTORS(player.v_angle, forward, right, up);
        for(int i = 0; i < 3; ++i) {
            entity _flare = new(CyberChopFlare_flare);
            setmodel(_flare, MDL_MG_BROWNING50GUN);
            _flare.effects = EF_LOWPRECISION | EF_FLAME;
            _flare.scale = 0.5;
            setorigin(_flare, actor.origin - '0 0 16');
            set_movetype(_flare, MOVETYPE_TOSS);
            _flare.gravity = 0.15;
            _flare.velocity = 0.25 * actor.velocity + (forward + randomvec() * 0.25)* -500;
            setthink(_flare, cyberchop_flare_think);
            _flare.nextthink = time;
            _flare.owner = veh ? veh : player;
            _flare.solid = SOLID_CORPSE;
            _flare.takedamage = DAMAGE_YES;
            _flare.event_damage = cyberchop_flare_damage;
            SetResourceExplicit(_flare, RES_HEALTH, 20);
            _flare.tur_impacttime = time + autocvar_g_vehicle_cyberchop_flare_lifetime;
            settouch(_flare, cyberchop_flare_touch);
        }
        weapon_thinkf(player, weaponentity, WFRAME_FIRE2, 0, w_ready);
    }
}


void cyberchop_bomblet_boom(entity this)
{
    RadiusDamage (this, this.realowner, autocvar_g_vehicle_cyberchop_bomblet_damage,
                                    autocvar_g_vehicle_cyberchop_bomblet_edgedamage,
                                    autocvar_g_vehicle_cyberchop_bomblet_radius, NULL, NULL,
                                    autocvar_g_vehicle_cyberchop_bomblet_force, DEATH_VH_RAPT_BOMB.m_id, DMG_NOWEP, NULL);
    delete(this);
}

void cyberchop_bomblet_touch(entity this, entity toucher)
{
    if(toucher == this.owner)
        return;

    PROJECTILE_TOUCH(this, toucher);
    setthink(this, cyberchop_bomblet_boom);
    this.nextthink = time + random() * autocvar_g_vehicle_cyberchop_bomblet_explode_delay;
}

void cyberchop_bomb_burst(entity this)
{
    if(this.cnt > time)
    if(autocvar_g_vehicle_cyberchop_bomblet_alt)
    {
        this.nextthink = time;
        traceline(this.origin, this.origin + (normalize(this.velocity) * autocvar_g_vehicle_cyberchop_bomblet_alt), MOVE_NORMAL, this);
        if((trace_fraction == 1.0) || (vdist(this.origin - this.owner.origin, <, autocvar_g_vehicle_cyberchop_bomblet_radius)))
        {
            UpdateCSQCProjectile(this);
            return;
        }
    }

    entity bomblet;
    float i;

    Damage_DamageInfo(this.origin, 0, 0, 0, '0 0 0', DEATH_VH_RAPT_FRAGMENT.m_id, 0, this);

    for(i = 0; i < autocvar_g_vehicle_cyberchop_bomblets; ++i)
    {
        bomblet = new(cyberchop_bomb_bomblet);
        setorigin(bomblet, this.origin);

        set_movetype(bomblet, MOVETYPE_TOSS);
        settouch(bomblet, cyberchop_bomblet_touch);
        setthink(bomblet, cyberchop_bomblet_boom);
        bomblet.nextthink   = time + 5;
        bomblet.owner	   = this.owner;
        bomblet.realowner   = this.realowner;
        bomblet.velocity	= normalize(normalize(this.velocity) + (randomvec() * autocvar_g_vehicle_cyberchop_bomblet_spread)) * vlen(this.velocity);

        PROJECTILE_MAKETRIGGER(bomblet);
        CSQCProjectile(bomblet, true, PROJECTILE_RAPTORBOMBLET, true);
    }

    delete(this);
}

void cyberchop_bomb_touch(entity this, entity toucher)
{
	cyberchop_bomb_burst(this);
}

void cyberchop_bombdrop(entity this)
{
    entity bomb_1 = new(bombmount_left);
    entity bomb_2 = new(bombmount_right);

    vector org = gettaginfo(this, gettagindex(this, "bombmount_left"));
    setorigin(bomb_1, org);
    org = gettaginfo(this, gettagindex(this, "bombmount_right"));
    setorigin(bomb_2, org);

    set_movetype(bomb_1, MOVETYPE_BOUNCE);
    set_movetype(bomb_2, MOVETYPE_BOUNCE);
    bomb_1.velocity	 = bomb_2.velocity   = this.velocity;
    settouch(bomb_1, cyberchop_bomb_touch);
    settouch(bomb_2, cyberchop_bomb_touch);
    setthink(bomb_1, cyberchop_bomb_burst);
    setthink(bomb_2, cyberchop_bomb_burst);
    bomb_1.cnt		  = bomb_2.cnt		= time + 10;

    if(autocvar_g_vehicle_cyberchop_bomblet_alt)
        bomb_1.nextthink = bomb_2.nextthink  = time;
    else
        bomb_1.nextthink = bomb_2.nextthink  = time + autocvar_g_vehicle_cyberchop_bomblet_time;

    bomb_1.owner	 = bomb_2.owner	  = this;
    bomb_1.realowner = bomb_2.realowner  = this.owner;
    bomb_1.solid	 = bomb_2.solid	  = SOLID_BBOX;
    bomb_1.gravity   = bomb_2.gravity	= 1;

    PROJECTILE_MAKETRIGGER(bomb_1);
    PROJECTILE_MAKETRIGGER(bomb_2);

    CSQCProjectile(bomb_1, true, PROJECTILE_RAPTORBOMB, true);
    CSQCProjectile(bomb_2, true, PROJECTILE_RAPTORBOMB, true);
}

void cyberchop_flare_touch(entity this, entity toucher)
{
    delete(this);
}

void cyberchop_flare_damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, .entity weaponentity, vector hitloc, vector force)
{
    TakeResource(this, RES_HEALTH, damage);
    if(GetResource(this, RES_HEALTH) <= 0)
        delete(this);
}

void cyberchop_flare_think(entity this)
{
    this.nextthink = time + 0.1;
    IL_EACH(g_projectiles, it.enemy == this.owner,
    {
        if(vdist(this.origin - it.origin, <, autocvar_g_vehicle_cyberchop_flare_range))
        if(random() > autocvar_g_vehicle_cyberchop_flare_chase)
            it.enemy = this;
    });

    if(this.tur_impacttime < time)
        delete(this);
}

#endif

#ifdef CSQC

void CyberChopCBShellfragDraw(entity this)
{
    if(wasfreed(this))
        return;

    Movetype_Physics_MatchTicrate(this, autocvar_cl_gibs_ticrate, autocvar_cl_gibs_sloppy);
    this.avelocity += randomvec() * 15;
    this.renderflags = 0;

    if(this.cnt < time)
        this.alpha = bound(0, this.nextthink - time, 1);

    if(this.alpha < ALPHA_MIN_VISIBLE)
        delete(this);
}

void CyberChopCBShellfragToss(vector _org, vector _vel, vector _ang)
{
    entity sfrag = new(CyberChopCBShellfrag);
    setmodel(sfrag, MDL_VEH_RAPTOR_CB_FRAGMENT);
    setorigin(sfrag, _org);

    set_movetype(sfrag, MOVETYPE_BOUNCE);
    sfrag.gravity = 0.15;
    sfrag.solid = SOLID_CORPSE;

    sfrag.draw = CyberChopCBShellfragDraw;
    IL_PUSH(g_drawables, sfrag);

    sfrag.velocity = _vel;
    sfrag.avelocity = prandomvec() * vlen(sfrag.velocity);
    sfrag.angles = _ang;

    sfrag.move_time = time;
    sfrag.damageforcescale = 4;

    sfrag.nextthink = time + 3;
    sfrag.cnt = time + 2;
    sfrag.alpha = 1;
    sfrag.drawmask = MASK_NORMAL;
}

#endif
