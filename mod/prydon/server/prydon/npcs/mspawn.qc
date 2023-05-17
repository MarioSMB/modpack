#include "mspawn.qh"

#include "../spells/sval.qh"
#include "../subs/_mod.qh"

spawnfunc(info_class)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	if(this.model)
		precache_model(this.model);
	else
		delete(this);
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
}

void become_monster(entity this, entity e)
{
	this.model = e.model;
	this.lvl = e.frags;
	this.monnum = e.monnum;
	this.speed = e.speed;
	this.netname = e.netname;
	this.noise = e.noise;
	this.noise1 = e.noise1;
	this.noise2 = e.noise2;
	this.noise3 = e.noise3;
	this.noise4 = e.noise4;
	this.droprandom = e.droprandom;
	this.slot1 = e.slot1;
	this.slot2 = e.slot2;
	this.slot3 = e.slot3;
	this.slot4 = e.slot4;
	this.slot5 = e.slot5;
	this.slot6 = e.slot6;
	this.slot7 = e.slot7;
	this.slot8 = e.slot8;
	this.slot9 = e.slot9;
	this.slot10 = e.slot10;
	this.slot11 = e.slot11;
	this.slot12 = e.slot12;
	this.slot13 = e.slot13;
	this.slot14 = e.slot14;
	this.slot15 = e.slot15;
	this.slot16 = e.slot16;
	this.res_poison = e.res_poison;
	this.res_fire = e.res_fire;
	this.res_lit = e.res_lit;
	this.res_mag = e.res_mag;
	this.res_cold = e.res_cold;
	// an so on
	this.skin = e.skin;
	this.finalangle = e.finalangle;
	this.gotstuff = e.gotstuff;
	this.ai = e.ai;
	this.flags = e.flags;
	this.spell = e.spell;
	this.flags = e.flags;
	this.spec = e.spec;
	this.skill = e.skill;
	this.poidam = e.poidam;
	this.lit = e.lit;
	this.fire = e.fire;
	this.cold = e.cold;
	this.magic = e.magic;
	this.rightarm = e.rightarm;
	this.leftarm = e.leftarm;
	this.ac = e.ac;
	this.tohit = e.tohit;
	this.dodge = e.dodge;
	this.dama = e.dama;
	this.daml = e.daml;
	this.spells1 = e.spells1;
	this.spells2 = e.spells2;
	this.spells3 = e.spells3;
	this.spells4 = e.spells4;
	this.spells5 = e.spells5;
	this.spells6 = e.spells6;
	this.spells7 = e.spells7;
	this.spells8 = e.spells8;
	this.spells9 = e.spells9;
	this.spells10 = e.spells10;
	this.spells11 = e.spells11;
	this.spells12 = e.spells12;
	this.spells13 = e.spells13;
	this.spells14 = e.spells14;
	this.spells15 = e.spells15;
	this.spells16 = e.spells16;
	this.max_health = e.max_health;
	this.effects = e.effects;
	this.alpha = e.alpha;
	this.walkframes = e.walkframes;
	this.runframes = e.runframes;
	this.deathframes = e.deathframes;
	this.attackframes = e.attackframes;
	this.hitframe = e.hitframe;
	this.poseframes = e.poseframes;
	this.castframes = e.castframes;
	this.jumpframes = e.jumpframes;
	this.bowframes = e.bowframes;
	this.throwframes = e.throwframes;
	this.finddist = e.finddist;
	this.mangle = e.mangle;
	this.misc = e.misc;
	this.mana_regen = e.mana_regen;
	this.health_regen = e.health_regen;
	this.attacker_dam = e.attacker_dam;
	this.attacker_fire = e.attacker_fire;
	this.attacker_lit = e.attacker_lit;
	this.attacker_cold = e.attacker_cold;	
	this.attacker_poison = e.attacker_poison;		
	this.damage_reduced = e.damage_reduced;
	this.magic_reduced = e.magic_reduced;
	this.piercing = e.piercing;
	this.visibility = e.visibility;
	this.team = e.team;
	this.gp = e.gp;
}

void monster_spawn_go(entity this)
{
	int counter = 0;
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.solid = SOLID_TRIGGER;
	droptofloor(this);
	
	entity e = find(NULL, classname, "info_class");
	while(e)
	{
		if(e.group == this.group)
			counter += 1;
		e = find(e, classname, "info_class");
	}
	if(!counter)
	{
		delete(this);
		return;
	}

	float f = ceil(counter * random());
	e = find(NULL, classname, "info_class");
	while(e)
	{
		if(e.group == this.group)
			f = f - 1;
		if(f <= 0)
		{
			become_monster(this, e);
			monster_randomize(this);
			return;
		}
		e = find(e, classname, "info_class");
	}
	delete(this);
}

void monster_spawn_go_use(entity this, entity actor, entity trigger)
{
	monster_spawn_go(this);
}

void monster_spawn(entity this)
{
	if(this.targetname != "")
		this.use = monster_spawn_go_use;
	else
	{
		this.nextthink = 0.01;
		setthink(this, monster_spawn_go);
	}
}

void monster_spawner_go(entity this)
{
	entity e = find_spot(this);
	e.angles = this.angles;
	if(this.spawnflags & 1)
		e.target = this.targetname;
	e.group = this.group;
	if(!this.wait)
		monster_spawn_go(e);
	else
	{
		setthink(e, monster_spawn_go);
		e.nextthink = time + this.wait;
	}
}

void monster_spawner_go_use(entity this, entity actor, entity trigger)
{
	monster_spawner_go(this);
}

spawnfunc(monster_spawner)
{
	this.use = monster_spawner_go_use;
	if(this.spawnflags & 1)
		monster_spawner_go(this);
}

spawnfunc(monster_skuttler)
{
	if(this.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/skuttler.mdl");
		precache_sound("skuttler/attack.wav");
		precache_sound("skuttler/hit.wav");
		precache_sound("skuttler/die.wav");
		return;
	}
	this.monnum = encode(1, 0, 0);
	this.model = "progs/skuttler.mdl";
	this.lvl = 1;
	this.speed = 0.1; // slow
	if(!this.netname)
		this.netname = "a skuttler";
	this.noise = "skuttler/attack.wav";
	this.noise3 = "skuttler/hit.wav";
	this.noise4 = "skuttler/die.wav";
	this.finalangle_x = encode('S', 'k', 'u');
	this.finalangle_y = encode('t', 't', 'l');
	this.finalangle_z = encode('e', 'r', 0);
	monster_randomize(this);
}

spawnfunc(monster_scarite)
{
	if(this.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/skuttler.mdl");
		precache_sound("skuttler/attack.wav");
		precache_sound("skuttler/hit.wav");
		precache_sound("skuttler/die.wav");
		return;
	}
	this.monnum = encode(2, 0, 0);
	this.model = "progs/skuttler.mdl";
	this.skin = 1;
	this.lvl = 2;
	this.speed = 0.15; // slow
	if(!this.netname)
		this.netname = "a scarite";
	this.noise = "skuttler/attack.wav";
	this.noise3 = "skuttler/hit.wav";
	this.noise4 = "skuttler/die.wav";
	this.finalangle_x = encode('S', 'c', 'a');
	this.finalangle_y = encode('r', 'i', 't');
	this.finalangle_z = encode('e', 0, 0);
	monster_randomize(this);
}

spawnfunc(monster_guanite)
{
	if(this.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/horror.mdl");
		precache_sound("horror/attack.wav");
		precache_sound("horror/hit.wav");
		precache_sound("horror/die.wav");
		return;
	}
	this.monnum = encode(3, 0, 0);
	this.model = "progs/horror.mdl";
	this.lvl = 2;
	this.speed = 0.5;
	if(!this.netname)
		this.netname = "a guanite";
	this.spec = SPEC_STEAL_LIFE;
	this.flags = FL_FLY;
	this.noise = "horror/attack.wav";
	this.noise3 = "horror/hit.wav";
	this.noise4 = "horror/die.wav";
	this.finalangle_x = encode('G', 'u', 'a');
	this.finalangle_y = encode('n', 'i', 't');
	this.finalangle_z = encode('e', 0, 0);
	monster_randomize(this);
}

spawnfunc(monster_drak)
{
	if(this.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/horror.mdl");
		precache_sound("horror/attack.wav");
		precache_sound("horror/hit.wav");
		precache_sound("horror/die.wav");
		return;
	}
	// hack to make this easier for now
	this.monnum = encode(4, 0, 0);
	this.model = "progs/horror.mdl";
	this.skin = 1;
	this.lvl = 7;
	this.speed = 0.5;
	if(!this.netname)
		this.netname = "a drak";
	this.spec = SPEC_STEAL_LIFE;
	this.flags = FL_FLY;
	this.noise = "horror/attack.wav";
	this.noise3 = "horror/hit.wav";
	this.noise4 = "horror/die.wav";
	this.finalangle_x = encode('D', 'r', 'a');
	this.finalangle_y = encode('k', 0, 0);
	this.finalangle_z = 0;
	monster_randomize(this);
}
spawnfunc(monster_horror)
{
	if(this.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/horror.mdl");
		precache_sound("horror/attack.wav");
		precache_sound("horror/hit.wav");
		precache_sound("horror/die.wav");
		return;
	}
	this.monnum = encode(5, 0, 0);
	this.model = "progs/horror.mdl";
	this.skin = 2;
	this.lvl = 30;
	this.speed = 0.5;
	if(!this.netname)
		this.netname = "a horror";
	this.spec = SPEC_STEAL_LIFE;
	this.flags = FL_FLY;
	this.noise = "horror/attack.wav";
	this.noise3 = "horror/hit.wav";
	this.noise4 = "horror/die.wav";
	this.finalangle_x = encode('H', 'o', 'r');
	this.finalangle_y = encode('r', 'o', 'r');
	this.finalangle_z = 0;
	monster_randomize(this);
}

spawnfunc(monster_evile_wizard)
{
	if(this.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/warlock.mdl");
		return;
	}
	if(!this.lvl)
		this.lvl = 9;
		
	this.model = "progs/warlock.mdl";
	this.max_health = 30;
	this.netname = "An Evile Wizard";
	this.altaction = SP_FIREBALL;
	this.spell = SP_METEOR;
	this.spawnflags = 1;
	spawnfunc_monster(this);
}

spawnfunc(monster_hideous_goblin)
{
	if(this.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/firbolg.mdl");
		return;
	}
	if(!this.lvl)
		this.lvl = 9;
	this.model = "progs/firbolg.mdl";
	this.max_health = 30;
	this.netname = "Hideous Goblin";
	this.altaction = SP_ICEBLAST;
	this.spawnflags = 1;
	spawnfunc_monster(this);
}

spawnfunc(sewer_monster)
{
	float r = ceil(random() * 5);
	if(r == 1)
		spawnfunc_monster_scarite(this);
	else if(r == 2)
		spawnfunc_monster_guanite(this);
	else if(r < 5)
		spawnfunc_monster_skuttler(this);
}