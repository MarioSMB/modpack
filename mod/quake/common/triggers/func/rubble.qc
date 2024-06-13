#ifdef SVQC

void hipRubbleTouch(entity this, entity toucher)
{
	if(this.pausetime == -1 || this.ltime < this.pausetime)
		return;
		
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, 10, DEATH_TRAP.m_id);
		_sound(this, CH_WEAPON_SINGLE, "zombie/z_hit.wav", 1, ATTN_NORM);
		this.pausetime = this.ltime + 0.1;
	}
}

void hipThrowRubble(entity this, string rubblename)
{
	entity rubble = spawn();
	rubble.origin = this.origin;
	_setmodel(rubble, rubblename );
	setsize(rubble, '0 0 0', '0 0 0');
	rubble.velocity_x = 70 * crandom();
	rubble.velocity_y = 70 * crandom();
	rubble.velocity_z = 140 + 70 * random();
	set_movetype(rubble, MOVETYPE_BOUNCE);
	rubble.solid = SOLID_BBOX;
	rubble.avelocity_x = random() * 600;
	rubble.avelocity_y = random() * 600;
	rubble.avelocity_z = random() * 600;
	setthink(rubble, SUB_Remove);
	settouch(rubble, hipRubbleTouch);
	rubble.ltime = time;
	rubble.nextthink = time + 13 + random() * 10;
	this.pausetime = time;
	rubble.frame = 0;
	rubble.flags = 0;
}

void rubble_use(entity this, entity actor, entity trigger)
{
	int index = 0;
	
	do 
	{
		float which = this.cnt;
		if(!this.cnt)
		{
			which = 1 + 3 * random();
			which = floor(which);
		}
		if(which == 1)
			hipThrowRubble(this, "progs/rubble1.mdl");
		else if(which == 2)
			hipThrowRubble(this, "progs/rubble3.mdl");
		else
			hipThrowRubble(this, "progs/rubble2.mdl");

		index = index + 1;
	}
	while(index < this.count);
}

/*QUAKED func_rubble (0.4 0.4 0.2) (0 0 0) (32 32 32)
  Spawns random sized rubble when triggered.  
  
  "count" is the number of pieces of rubble to spawn.  Default is 1.
*/
spawnfunc(func_rubble)
{
	precache_model("progs/rubble1.mdl");
	precache_model("progs/rubble2.mdl");
	precache_model("progs/rubble3.mdl");
	precache_sound("zombie/z_hit.wav");
	this.classname = "rubble";
	this.cnt = 0;
	this.use = rubble_use;
}
	
/*QUAKED func_rubble1 (0.4 0.4 0.2) (0 0 0) (8 8 8)
  Spawns small rubble when triggered.  
  
  "count" is the number of pieces of rubble to spawn.  Default is 1.
*/
spawnfunc(func_rubble1)
{
	precache_model("progs/rubble1.mdl");
	precache_sound("zombie/z_hit.wav");
	this.classname = "rubble1";
	this.cnt = 1;
	this.use = rubble_use;
}
	
/*QUAKED func_rubble2 (0.4 0.4 0.2) (0 0 0) (16 16 16)
  Spawns medium rubble when triggered.  
  
  "count" is the number of pieces of rubble to spawn.  Default is 1.
*/
spawnfunc(func_rubble2)
{
	precache_model ("progs/rubble3.mdl");
	precache_sound("zombie/z_hit.wav");
	this.classname = "rubble2";
	this.cnt = 2;
	this.use = rubble_use;
}
	
/*QUAKED func_rubble3 (0.4 0.4 0.2) (0 0 0) (32 32 32)
  Spawns large rubble when triggered.  
  
  "count" is the number of pieces of rubble to spawn.  Default is 1.
*/
spawnfunc(func_rubble3)
{
	precache_model ("progs/rubble2.mdl");
	precache_sound("zombie/z_hit.wav");
	this.classname = "rubble3";
	this.cnt = 3;
	this.use = rubble_use;
}

#endif
