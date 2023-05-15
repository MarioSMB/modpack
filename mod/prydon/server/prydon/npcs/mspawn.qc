void() info_class =
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.model)
		precache_model(self.model);
	else
		remove(self);
	if (self.noise)
		precache_sound(self.noise);
	if (self.noise1)
		precache_sound(self.noise1);
	if (self.noise2)
		precache_sound(self.noise2);
	if (self.noise3)
		precache_sound(self.noise3);
	if (self.noise4)
		precache_sound(self.noise4);
};

void(entity e) become_monster =
{
	self.model = e.model;
	self.lvl = e.frags;
	self.monnum = e.monnum;
	self.speed = e.speed;
	self.netname = e.netname;
	self.noise = e.noise;
	self.noise1 = e.noise1;
	self.noise2 = e.noise2;
	self.noise3 = e.noise3;
	self.noise4 = e.noise4;
	self.droprandom = e.droprandom;
	self.slot1 = e.slot1;
	self.slot2 = e.slot2;
	self.slot3 = e.slot3;
	self.slot4 = e.slot4;
	self.slot5 = e.slot5;
	self.slot6 = e.slot6;
	self.slot7 = e.slot7;
	self.slot8 = e.slot8;
	self.slot9 = e.slot9;
	self.slot10 = e.slot10;
	self.slot11 = e.slot11;
	self.slot12 = e.slot12;
	self.slot13 = e.slot13;
	self.slot14 = e.slot14;
	self.slot15 = e.slot15;
	self.slot16 = e.slot16;
	self.res_poison = e.res_poison;
	self.res_fire = e.res_fire;
	self.res_lit = e.res_lit;
	self.res_mag = e.res_mag;
	self.res_cold = e.res_cold;
	// an so on
	self.skin = e.skin;
	self.finalangle = e.finalangle;
	self.gotstuff = e.gotstuff;
	self.ai = e.ai;
	self.flags = e.flags;
	self.spell = e.spell;
	self.flags = e.flags;
	self.spec = e.spec;
	self.skill = e.skill;
	self.poidam = e.poidam;
	self.lit = e.lit;
	self.fire = e.fire;
	self.cold = e.cold;
	self.magic = e.magic;
	self.rightarm = e.rightarm;
	self.leftarm = e.leftarm;
	self.ac = e.ac;
	self.tohit = e.tohit;
	self.dodge = e.dodge;
	self.dama = e.dama;
	self.daml = e.daml;
	self.spells1 = e.spells1;
	self.spells2 = e.spells2;
	self.spells3 = e.spells3;
	self.spells4 = e.spells4;
	self.spells5 = e.spells5;
	self.spells6 = e.spells6;
	self.spells7 = e.spells7;
	self.spells8 = e.spells8;
	self.spells9 = e.spells9;
	self.spells10 = e.spells10;
	self.spells11 = e.spells11;
	self.spells12 = e.spells12;
	self.spells13 = e.spells13;
	self.spells14 = e.spells14;
	self.spells15 = e.spells15;
	self.spells16 = e.spells16;
	self.max_health = e.max_health;
	self.effects = e.effects;
	self.alpha = e.alpha;
	self.walkframes = e.walkframes;
	self.runframes = e.runframes;
	self.deathframes = e.deathframes;
	self.attackframes = e.attackframes;
	self.hitframe = e.hitframe;
	self.poseframes = e.poseframes;
	self.castframes = e.castframes;
	self.jumpframes = e.jumpframes;
	self.bowframes = e.bowframes;
	self.throwframes = e.throwframes;
	self.finddist = e.finddist;
	self.mangle = e.mangle;
	self.misc = e.misc;
	self.mana_regen = e.mana_regen;
	self.health_regen = e.health_regen;
	self.attacker_dam = e.attacker_dam;
	self.attacker_fire = e.attacker_fire;
	self.attacker_lit = e.attacker_lit;
	self.attacker_cold = e.attacker_cold;	
	self.attacker_poison = e.attacker_poison;		
	self.damage_reduced = e.damage_reduced;
	self.magic_reduced = e.magic_reduced;
	self.piercing = e.piercing;
	self.visibility = e.visibility;
	self.team = e.team;
	self.gp = e.gp;
};
void() monster_spawn_go =
{
	local float f, count;
	local entity e;
	
	count = 0;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.solid = SOLID_TRIGGER;
	droptofloor();
	
	e = find(world, classname, "info_class");
	while(e)
	{
		if (e.group == self.group)
			count = count + 1;
		e = find(e, classname, "info_class");
	}
	if (!count)
	{
		remove(self);
		return;
	}

	f = ceil(count * random());
	e = find(world, classname, "info_class");
	while(e)
	{
		if (e.group == self.group)
			f = f - 1;
		if (f <= 0)
		{
			become_monster(e);
			monster_randomize();
			return;
		}
		e = find(e, classname, "info_class");
	}
	remove(self);
	return;
};

void() monster_spawn =
{
	if (self.targetname != "")
		self.use = monster_spawn_go;
	else
	{
		self.nextthink = 0.01;
		self.think = monster_spawn_go;
	}
};

void() monster_spawner_go =
{
	local entity e;
	
	e = find_spot();
	e.angles = self.angles;
	if (self.spawnflags & 1)
		e.target = self.targetname;
	e.group = self.group;
	if (!self.wait)
		call(monster_spawn_go, e);
	else
	{
		e.think = monster_spawn_go;
		e.nextthink = time + self.wait;
	}
};

void() monster_spawner =
{
	self.use = monster_spawner_go;
	if (self.spawnflags & 1)
		monster_spawner_go();
};

void() monster_skuttler =
{
	if (self.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/skuttler.mdl");
		precache_sound("skuttler/attack.wav");
		precache_sound("skuttler/hit.wav");
		precache_sound("skuttler/die.wav");
		return;
	}
	self.monnum = encode(1, 0, 0);
	self.model = "progs/skuttler.mdl";
	self.lvl = 1;
	self.speed = 0.1; // slow
	if (!self.netname)
		self.netname = "a skuttler";
	self.noise = "skuttler/attack.wav";
	self.noise3 = "skuttler/hit.wav";
	self.noise4 = "skuttler/die.wav";
	self.finalangle_x = encode('S', 'k', 'u');
	self.finalangle_y = encode('t', 't', 'l');
	self.finalangle_z = encode('e', 'r', 0);
	monster_randomize();
	
};

void() monster_scarite =
{
	if (self.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/skuttler.mdl");
		precache_sound("skuttler/attack.wav");
		precache_sound("skuttler/hit.wav");
		precache_sound("skuttler/die.wav");
		return;
	}
	self.monnum = encode(2, 0, 0);
	self.model = "progs/skuttler.mdl";
	self.skin = 1;
	self.lvl = 2;
	self.speed = 0.15; // slow
	if (!self.netname)
		self.netname = "a scarite";
	self.noise = "skuttler/attack.wav";
	self.noise3 = "skuttler/hit.wav";
	self.noise4 = "skuttler/die.wav";
	self.finalangle_x = encode('S', 'c', 'a');
	self.finalangle_y = encode('r', 'i', 't');
	self.finalangle_z = encode('e', 0, 0);
	monster_randomize();
};

void() monster_guanite =
{
	if (self.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/horror.mdl");
		precache_sound("horror/attack.wav");
		precache_sound("horror/hit.wav");
		precache_sound("horror/die.wav");
		return;
	}
	self.monnum = encode(3, 0, 0);
	self.model = "progs/horror.mdl";
	self.lvl = 2;
	self.speed = 0.5;
	if (!self.netname)
		self.netname = "a guanite";
	self.spec = SPEC_STEAL_LIFE;
	self.flags = FL_FLY;
	self.noise = "horror/attack.wav";
	self.noise3 = "horror/hit.wav";
	self.noise4 = "horror/die.wav";
	self.finalangle_x = encode('G', 'u', 'a');
	self.finalangle_y = encode('n', 'i', 't');
	self.finalangle_z = encode('e', 0, 0);
	monster_randomize();
};

void() monster_drak =
{
	if (self.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/horror.mdl");
		precache_sound("horror/attack.wav");
		precache_sound("horror/hit.wav");
		precache_sound("horror/die.wav");
		return;
	}
	// hack to make this easier for now
	self.monnum = encode(4, 0, 0);
	self.model = "progs/horror.mdl";
	self.skin = 1;
	self.lvl = 7;
	self.speed = 0.5;
	if (!self.netname)
		self.netname = "a drak";
	self.spec = SPEC_STEAL_LIFE;
	self.flags = FL_FLY;
	self.noise = "horror/attack.wav";
	self.noise3 = "horror/hit.wav";
	self.noise4 = "horror/die.wav";
	self.finalangle_x = encode('D', 'r', 'a');
	self.finalangle_y = encode('k', 0, 0);
	self.finalangle_z = 0;
	monster_randomize();
};
void() monster_horror =
{
	if (self.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/horror.mdl");
		precache_sound("horror/attack.wav");
		precache_sound("horror/hit.wav");
		precache_sound("horror/die.wav");
		return;
	}
	self.monnum = encode(5, 0, 0);
	self.model = "progs/horror.mdl";
	self.skin = 2;
	self.lvl = 30;
	self.speed = 0.5;
	if (!self.netname)
		self.netname = "a horror";
	self.spec = SPEC_STEAL_LIFE;
	self.flags = FL_FLY;
	self.noise = "horror/attack.wav";
	self.noise3 = "horror/hit.wav";
	self.noise4 = "horror/die.wav";
	self.finalangle_x = encode('H', 'o', 'r');
	self.finalangle_y = encode('r', 'o', 'r');
	self.finalangle_z = 0;
	monster_randomize();
};

void() monster_evile_wizard =
{
	if (self.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/warlock.mdl");
		return;
	}
	if (!self.lvl)
		self.lvl = 9;
		
	self.model = "progs/warlock.mdl";
	self.max_health = 30;
	self.netname = "An Evile Wizard";
	self.altaction = SP_FIREBALL;
	self.spell = SP_METEOR;
	self.spawnflags = 1;
	monster();
};

void() monster_hideous_goblin =
{
	if (self.classname == "rq_goalpoint")
	{
		// rq cache only stage
		precache_model("progs/firbolg.mdl");
		return;
	}
	if (!self.lvl)
		self.lvl = 9;
	self.model = "progs/firbolg.mdl";
	self.max_health = 30;
	self.netname = "Hideous Goblin";
	self.altaction = SP_ICEBLAST;
	self.spawnflags = 1;
	monster();
};

void() sewer_monster =
{
	local float r;
	r = ceil(random() * 5);
	if (r == 1)
		monster_scarite();
	else if (r == 2)
		monster_guanite();
	else if (r < 5)
		monster_skuttler();
};