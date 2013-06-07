/**
    turret_checkpoint
**/


//.entity checkpoint_target;

/*
#define checkpoint_cache_who  flagcarried
#define checkpoint_cache_from lastrocket
#define checkpoint_cache_to   selected_player
*/

.entity pathgoal;
.entity pathcurrent;

/*
entity path_makeorcache(entity forwho,entity start, entity end)
{
    entity oldself;
    entity pth;
    oldself = self;
    self = forwho;

    //pth = pathlib_makepath(start.origin,end.origin,PFL_GROUNDSNAP,500,1.5,PT_QUICKSTAR);

    self = oldself;
    return pth;
}
*/

void turret_checkpoint_use()
{
}

#if 0
void turret_checkpoint_think()
{
    if(self.enemy)
        te_lightning1(self,self.origin, self.enemy.origin);
    
    self.nextthink = time + 0.25;
}
#endif
/*QUAKED turret_checkpoint (1 0 1) (-32 -32 -32) (32 32 32)
-----------KEYS------------
target: .targetname of next waypoint in chain.
wait:   Pause at this point # seconds.
-----------SPAWNFLAGS-----------
---------NOTES----------
If a loop is of targets are formed, any unit entering this loop will patrol it indefinitly.
If the checkpoint chain in not looped, the unit will go "Roaming" when the last point is reached.
*/
//float tc_acum;
void turret_checkpoint_init()
{
    traceline(self.origin + '0 0 16', self.origin - '0 0 1024', MOVE_WORLDONLY, self);
    setorigin(self, trace_endpos + '0 0 32');

    if(self.target != "")
    {
        self.enemy = find(world, targetname, self.target);
        if(self.enemy == world)
            dprint("A turret_checkpoint faild to find its target!\n");
    }
    //self.think = turret_checkpoint_think;
    //self.nextthink = time + tc_acum + 0.25;
    //tc_acum += 0.25;
}

void spawnfunc_turret_checkpoint()
{
    setorigin(self,self.origin);
    self.think = turret_checkpoint_init;
    self.nextthink = time + 0.2;    
}

// Compat.
void spawnfunc_walker_checkpoint()
{
    self.classname = "turret_checkpoint";
    spawnfunc_turret_checkpoint();
}
