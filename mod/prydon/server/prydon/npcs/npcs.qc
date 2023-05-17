#include "npcs.qh"

#include "../quests/rq_npcs.qh"
#include "../stats/stats.qh"
#include "../subs/_mod.qh"

spawnfunc(npc)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	legacy_npc(this);

	if(this.classname == "npc")
		randomize_inventory(this);
	datacheck(this);	
	if(this.spawnflags & 1)
		if(music)
			if(!this.theme)
				this.theme = "music/boss.wav";
	if(!this.model)
		this.model = rq_npcmodel(this, floor(random() * 15));
	this.oldskin = this.skin;
	if(!this.noise)
		this.noise = "player/swing.wav";

	if(cache)
	{
		precache_model(this.model);
		if(this.bkup_model)
			precache_model(this.bkup_model);

		if(this.noise)
			precache_sound(this.noise);
		if(this.noise1)
			precache_sound(this.noise1);
		if(this.noise2)
			precache_sound(this.noise2);
		if(this.noise3)
			precache_sound(this.noise3);
		if(this.noise4)
			precache_sound(this.noise4);
		if(this.voice)
			precache_sound(this.voice);
		if(this.theme)
			precache_sound(this.theme);
	}
	_setmodel(this, this.model);

	if(this.size_x > 100)
		setsize(this, VEC_HULL2_MIN, VEC_HULL2_MAX);
	else
		setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);

	if(!this.netname)
		this.netname = rq_npcname(floor(random() * 256)) ;
	if(!this.ai)
		this.ai = AI_ROAM;

	this.owner = this;
	this.player = this;
	if(!this.max_health)
		this.max_health = 5;
	Restat(this);
	
	this.health = this.max_health;
//	if(netplay)
//		this.ai = this.ai - (this.ai & AI_ROAM); // no wandering in netplay
	if(this.wad)
		if(!(this.ai & AI_LUMP))
			this.ai |= AI_STAY_NEAR;
	if(!this.altaction)
		this.altaction = SP_FIGHT_MELEE;
	this.gotstuff 	= this.altaction;
	set_movetype(this, MOVETYPE_STEP);
	this.solid	= SOLID_SLIDEBOX;
	this.takedamage	= DAMAGE_AIM;
	this.oldorigin	= this.origin;
	set_frames(this);
	if(!this.speed)
		this.speed = 1;
	this.die = PlayerDie;
	this.use = playertrigger;
	this.mana = this.max_mana;
	this.mana_regen = this.mana_regen + 5;
	if(this.message)
	{
		this.effects |= EF_SELECTABLE;
		this.action = opendialog;
	}
	else if(this.ai & (AI_HUNT_PLAYER | AI_FOLLOW))
		this.effects |= EF_SELECTABLE;
	AnimatePlayer(this);
}
