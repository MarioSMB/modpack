void spider_stand1(entity this) { set_anim(this, 0, spider_stand1); ai_stand(this); }

void spider_run1(entity this);
void spider_wake10(entity this)
{
	set_anim(this, 9, spider_run1);
	ai_stand(this);
	HuntTarget(this);
}
void spider_wake9(entity this) { set_anim(this, 8, spider_wake10); ai_stand(this); }
void spider_wake8(entity this) { set_anim(this, 7, spider_wake9); ai_stand(this); }
void spider_wake7(entity this) { set_anim(this, 6, spider_wake8); ai_stand(this); }
void spider_wake6(entity this) { set_anim(this, 5, spider_wake7); ai_stand(this); }
void spider_wake5(entity this) { set_anim(this, 4, spider_wake6); ai_stand(this); }
void spider_wake4(entity this) { set_anim(this, 3, spider_wake5); ai_stand(this); }
void spider_wake3(entity this) { set_anim(this, 2, spider_wake4); ai_stand(this); }
void spider_wake2(entity this) { set_anim(this, 1, spider_wake3); ai_stand(this); }
void spider_wake1(entity this)
{
	set_anim(this, 0, spider_wake2);
	_sound(this, CHAN_AUTO, "monsters/spider/sactiv.wav", 1, ATTN_NORM);
	ai_stand(this);
}

void spider_walk1(entity this);
void spider_walk8(entity this) { set_anim(this, 17, spider_walk1); ai_walk(this, 12); }
void spider_walk7(entity this) { set_anim(this, 16, spider_walk8); ai_walk(this, 9); }
void spider_walk6(entity this) { set_anim(this, 15, spider_walk7); ai_walk(this, 9); }
void spider_walk5(entity this)
{
	set_anim(this, 14, spider_walk6);
	_sound(this, CHAN_BODY, "monsters/spider/swalk.wav", 1, ATTN_NORM);
	ai_walk(this, 9);
}
void spider_walk4(entity this) { set_anim(this, 13, spider_walk5); ai_walk(this, 12); }
void spider_walk3(entity this) { set_anim(this, 12, spider_walk4); ai_walk(this, 9); }
void spider_walk2(entity this) { set_anim(this, 11, spider_walk3); ai_walk(this, 6); }
void spider_walk1(entity this)
{
	set_anim(this, 10, spider_walk2);
	_sound(this, CHAN_BODY, "monsters/spider/swalk.wav", 1, ATTN_NORM);
	ai_walk(this, 9);
}

void spider_run1(entity this);
void spider_run8(entity this) { set_anim(this, 17, spider_run1); ai_run(this, 15); }
void spider_run7(entity this)
{
	set_anim(this, 16, spider_run8);
	_sound(this, CHAN_ITEM, "monsters/spider/sactiv.wav", 1, ATTN_NORM);
	ai_run(this, 14);
}
void spider_run6(entity this) { set_anim(this, 15, spider_run7); ai_run(this, 20); }
void spider_run5(entity this) { set_anim(this, 14, spider_run6); ai_run(this, 16); }
void spider_run4(entity this)
{
	set_anim(this, 13, spider_run5);
	_sound(this, CHAN_BODY, "monsters/spider/swalk.wav", 1, ATTN_NORM);
	ai_run(this, 18);
}
void spider_run3(entity this) { set_anim(this, 12, spider_run4); ai_run(this, 16); }
void spider_run2(entity this) { set_anim(this, 11, spider_run3); ai_run(this, 20); }
void spider_run1(entity this)
{
	set_anim(this, 10, spider_run2);
	_sound(this, CHAN_BODY, "monsters/spider/swalk.wav", 1, ATTN_NORM);
	ai_run(this, 16);
}

void spider_die2(entity this)
{
	T_RadiusDamage(this, this, 80, this.other2);
	ThrowGib(this, "progs/spidgib.mdl", ((this.health - 40) - (random () * 40)));
	ThrowGib(this, "progs/spidgib.mdl", ((this.health - 40) - (random () * 40)));
	ThrowHead(this, "progs/spidgib.mdl", ((this.health - 40) - (random () * 40)));
	te_explosion(this.origin);
	BecomeExplosion(this);
}

void spider_die(entity this, entity inflictor, entity attacker)
{
	setthink(this, spider_die2);
	this.nextthink = time;
	this.other2 = attacker;
}

void spider_blowup(entity this)
{
	T_Damage(this, this, this, this.health);
}

void spider_melee(entity this)
{
	_sound(this, CHAN_ITEM, "monsters/spider/sactiv.wav", 1, ATTN_NORM);
	this.nextthink = time + 0.5;
	setthink(this, spider_blowup);
}

string spider_deathmessage(entity this) { return "was blown apart by a Spider Droid"; }

spawnfunc(monster_spider)
{
	if(!MP_IMPEL) { delete(this); return; }
	if(deathmatch) { delete(this); return; }

	if(this.classname == "monster_spider")
		this.mdl = "progs/spid.mdl";
	precache_model(this.mdl);
	precache_model("progs/spidgib.mdl");
	precache_model("progs/spid.mdl");
	precache_sound("monsters/spider/sactiv.wav");
	precache_sound("monsters/spider/swalk.wav");
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	_setmodel(this, this.mdl);
	setsize(this, '-10 -16 -1', '8 16 24');
	this.health = 50;
	this.th_stand = spider_stand1;
	this.th_walk = spider_walk1;
	this.th_run = spider_run1;
	this.th_melee = spider_melee;
	this.th_die = spider_die;

	this.deathmessage = spider_deathmessage;

	monster_start(this, 0);
}
