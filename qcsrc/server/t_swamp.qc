/*
*		t_swamp.c
*		Adds spawnfunc_trigger_swamp and suppoart routines for xonotic 1.2.1+
*		Author tZork (Jakob MG) 
*		jakob@games43.se
*		2005 11 29
*/

.float swamp_interval;	//Hurt players in swamp with this interval
.float swamp_slowdown;	//Players in swamp get slowd down by this mutch 0-1 is slowdown 1-~ is speedup (!?)
.entity swampslug;

void spawnfunc_trigger_swamp(void);
void swamp_touch(void);
void swampslug_think();


/*
* Uses a entity calld swampslug to handle players in the swamp
* It works like this: When the plyer enters teh swamp the spawnfunc_trigger_swamp
* attaches a new "swampslug" to the player. As long as the plyer is inside
* the swamp the swamp gives the slug new health. But the slug slowly kills itself
* so when the player goes outside the swamp, it dies and releases the player from the 
* swamps curses (dmg/slowdown) 
* 
* I do it this way becuz there is no "untouch" event.
*
* --NOTE-- 
* THE ACCTUAL slowdown is done in cl_physics.c on line 57-60
* --NOTE--
*/
void swampslug_think(void) 
{
	//Slowly kill the slug
	self.health = self.health - 1;

	//Slug dead? then remove curses.
	if(self.health <= 0) {
		self.owner.in_swamp = 0;
		remove(self);
		//centerprint(self.owner,"Killing slug...\n");
		return;
	}
	
	// Slug still alive, so we are still in the swamp
	// Or we have exited it very recently.
	// Do the damage and renew the timer.
	Damage (self.owner, self, self, self.dmg, DEATH_SWAMP, other.origin, '0 0 0');

	self.nextthink = time + self.swamp_interval;
}

void swamp_touch(void) 
{
	// If whatever thats touching the swamp is not a player
	// or if its a dead player, just dont care abt it.
	if(!IS_PLAYER(other) || other.deadflag != DEAD_NO)
		return;

	EXACTTRIGGER_TOUCH;

	// Chech if player alredy got a swampslug.
	if(other.in_swamp != 1) {
		// If not attach one.
		//centerprint(other,"Entering swamp!\n");
		other.swampslug = spawn();
		other.swampslug.health = 2;
		other.swampslug.think = swampslug_think;
		other.swampslug.nextthink = time;
		other.swampslug.owner = other;
		other.swampslug.dmg = self.dmg;
		other.swampslug.swamp_interval = self.swamp_interval;
		other.swamp_slowdown = self.swamp_slowdown;
		other.in_swamp = 1;
		return;
	}

	//other.in_swamp = 1;

	//Revitalize players swampslug
	other.swampslug.health = 2;
}

/*QUAKED spawnfunc_trigger_swamp (.5 .5 .5) ?
Players gettin into the swamp will 
get slowd down and damaged
*/
void spawnfunc_trigger_swamp(void)
{
	// Init stuff
	EXACTTRIGGER_INIT;
	self.touch = swamp_touch;	

	// Setup default keys, if missing
	if(self.dmg <= 0) 
		self.dmg = 5;
	if(self.swamp_interval <= 0) 
		self.swamp_interval = 1;
	if(self.swamp_slowdown <= 0) 
		self.swamp_slowdown = 0.5;
}
