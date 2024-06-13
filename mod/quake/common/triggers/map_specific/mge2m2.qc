#ifdef SVQC

//Electrodes

spawnfunc(mge2m2_electrode_target)
{
}

// Electrode buttons

bool mge2m2_match_cnt(entity this, entity actor) { return this.cnt == actor.cnt; }

void mge2m2_electrode_button_touch(entity this, entity toucher)
{
    if(!IS_PLAYER(toucher)) return;
    if(toucher.health <= 0) return;
    
    button_touch(this, toucher);
    settouch(this, func_null);

    FOREACH_ENTITY_CLASS("mge2m2_electrode_target", mge2m2_match_cnt(this, it),
    {
        setthink(it, SUB_Remove);
        it.nextthink = time + 0.1;
    });
}

spawnfunc(mge2m2_electrode_button)
{
    spawnfunc_func_button(this);
    settouch(this, mge2m2_electrode_button_touch);
}

// Opening the rune "egg"

void mge2m2_rune_egg_opener_use(entity this, entity actor, entity trigger)
{
    entity t = find(NULL, targetname, this.target);
    while(t)
    {
        if(t.classname == "door")
        {
            t.movedir = t.dest2;
            t.pos1 = t.origin;
            t.pos2 = t.pos1 + t.movedir;
            t.state = STATE_BOTTOM;
            t.speed = 500;
            t.noise1 = "doors/drclos4.wav";
            t.noise2 = "doors/doormv1.wav";
            door_go_up(t);
        }
        t = find(t, targetname, this.target);
    }
}

spawnfunc(mge2m2_rune_egg_opener)
{
    this.use = mge2m2_rune_egg_opener_use;
}

// Rune pickupability

void mge2m2_rune_pickup_fixer_use(entity this, entity actor, entity trigger)
{
    bool dotouch = (this.state);
    if(!dotouch)
        this.state = 1;
    entity ru = find(NULL, classname, "item_sigil");
    while(ru)
    {
        if(dotouch)
            settouch(ru, sigil_touch);
        else
            settouch(ru, func_null);
        ru = find(ru, classname, "item_sigil");
    }
}
void mge2m2_rune_pickup_fixer_use_think(entity this)
{
    mge2m2_rune_pickup_fixer_use(this, NULL, NULL);
}

spawnfunc(mge2m2_rune_pickup_fixer)
{
    this.use = mge2m2_rune_pickup_fixer_use;
    setthink(this, mge2m2_rune_pickup_fixer_use_think);
    this.nextthink = time + 0.8;
}

// Obsolete, replace with trigger_cleanup_corpses
spawnfunc(mge2m2_cleanup_corpses)
{
    LOG_DEBUG("WARNING: entity 'mge2m2_cleanup_corpses' spawned. Please replace with 'trigger_cleanup_corpses'.");
    spawnfunc_trigger_cleanup_corpses(this);
}

#endif
