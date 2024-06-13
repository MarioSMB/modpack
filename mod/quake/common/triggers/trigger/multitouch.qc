#ifdef SVQC

// ======================================================
/*QUAKED trigger_multitouch (.5 .5 .5) ?
A trigger that fires its targets on "first touch", "emptied" or both

YODER Feb08, 2022
*/
const int IGNORE_FIRST_TOUCH = 16;
const int IGNORE_EMPTIED = 32;

void trigger_multitouch_think(entity this)
{ 
    this.wait = 0;
    if(!(this.spawnflags & IGNORE_EMPTIED))
        SUB_UseTargets(this, NULL, NULL);
}

void trigger_multitouch_touch(entity this, entity toucher)
{
    if(!IS_PLAYER(toucher))
        return;
	if(toucher.health <= 0)
		return;
    
    if(this.wait == 0) // first touch?
    {
        this.wait = 1;
        if(!(this.spawnflags & IGNORE_FIRST_TOUCH))
            SUB_UseTargets(this, NULL, NULL);
    }
    
    // think
    setthink(this, trigger_multitouch_think);
    this.nextthink = time + 0.2;
}

spawnfunc(trigger_multitouch)
{
    InitTrigger(this);
    settouch(this, trigger_multitouch_touch);
    this.wait = 0; // 0 is empty, 1 is touched
}

#endif
