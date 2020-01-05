// oh my god, this abomination needs to die

void make_snow(entity this);
void snow_remove(entity this, entity toucher);
void snow_bob(entity this);

spawnfunc(snow_fall)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model2("progs/snow.spr");
	this.nextthink = time + 1;
	setthink(this, make_snow);
}

void make_snow(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/snow.spr");
	setorigin(bubble, this.origin);
	float rnd1 = (bubble.origin_x + (-20 + (random () * 40)));
	float rnd2 = (bubble.origin_y + (-20 + (random () * 40)));
	bubble.origin_x = rnd1;
	bubble.origin_y = rnd2;
	setorigin(bubble, bubble.origin);
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 -30';
	bubble.nextthink = time + 0.5;
	setthink(bubble, snow_bob);
	settouch(bubble, snow_remove);
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.nextthink = ((time + random ()) + 0.5);
	setthink(this, make_snow);
}

void snow_remove(entity this, entity toucher)
{
	if(toucher.classname == this.classname)
		return;
	delete(this);
}

void snow_bob(entity this)
{
	this.cnt = this.cnt + 1;
	if(this.cnt == 20)
	{
		delete(this);
		return;
	}
	float rnd1 = (this.velocity_x + (-20 + (random () * 40)));
	float rnd2 = (this.velocity_y + (-20 + (random () * 40)));
	float rnd3 = ((this.velocity_z - 20) - (random () * 20));
	this.velocity = vec3(rnd1, rnd2, rnd3);
	this.nextthink = time + 0.5;
	setthink(this, snow_bob);
}
void premake_smallsnow(entity this);
void make_smallsnow(entity this);
void smallsnow_remove(entity this, entity toucher);
void smallsnow_bob(entity this);

spawnfunc(smallsnow_fall)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model2("progs/smlsnow.spr");
	this.nextthink = (time + (random () * 15));
	setthink(this, premake_smallsnow);
}

void premake_smallsnow(entity this)
{
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
	make_smallsnow(this);
}

void make_smallsnow(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/smlsnow.spr");
	setorigin (bubble, this.origin);
	float rnd1 = (bubble.origin_x + (-20 + (random () * 40)));
	float rnd2 = (bubble.origin_y + (-20 + (random () * 40)));
	float rnd3 = (bubble.origin_z + (-10 + (random () * 20)));
	setorigin(bubble, vec3(rnd1, rnd2, rnd3));
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 -30';
	bubble.nextthink = time;
	setthink(bubble, snow_bob);
	settouch(bubble, snow_remove);
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.nextthink = time + (random () * 15);
	setthink(this, premake_smallsnow);
}

void smallsnow_remove(entity this, entity toucher)
{
	if(toucher.classname == this.classname)
		return;
	delete(this);
}

void smallsnow_bob(entity this)
{
	this.cnt = this.cnt + 1;
	if(this.cnt == 10)
	{
		delete(this);
		return;
	}
	float rnd3 = this.velocity_z - 100;
	this.velocity_z = rnd3;
	this.nextthink = time + 0.5;
	setthink(this, smallsnow_bob);
}
void make_leaf(entity this);
void leaf_remove(entity this, entity toucher);
void leaf_bob(entity this);

spawnfunc(leaf_fall)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/leaf.mdl");
	this.nextthink = time + 1;
	setthink(this, make_leaf);
}

void make_leaf(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/leaf.mdl");
	setorigin(bubble, this.origin);
	float rnd1 = (bubble.origin_x + (-20 + (random () * 40)));
	float rnd2 = (bubble.origin_y + (-20 + (random () * 40)));
	bubble.origin_x = rnd1;
	bubble.origin_y = rnd2;
	setorigin(bubble, bubble.origin);
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 -30';
	bubble.nextthink = time + 0.5;
	setthink(bubble, leaf_bob);
	settouch(bubble, leaf_remove);
	bubble.classname = "leaf";
	bubble.frame = 0;
	bubble.cnt = 0;
	bubble.angles = bubble.v_angle;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.nextthink = ((time + random ()) + 0.5);
	setthink(this, make_leaf);
}

void leaf_remove(entity this, entity toucher)
{
	if(toucher.classname == this.classname)
		return;
	delete(this);
}

void leaf_bob(entity this)
{
	this.cnt = this.cnt + 1;
	if(this.cnt == 10)
	{
		delete(this);
		return;
	}
	float rnd1 = (this.velocity_x + (-160 + (random () * 320)));
	float rnd2 = (this.velocity_y + (-160 + (random () * 320)));
	float rnd3 = ((this.velocity_z - 20) - (random () * 20));
	this.velocity = vec3(rnd1, rnd2, rnd3);
	this.angles = this.v_angle;
	this.nextthink = time + 0.5;
	setthink(this, leaf_bob);
}
void make_lostbubble(entity this);
void lostbubble_remove(entity this, entity toucher);
void lostbubble_bob(entity this);

spawnfunc(lostbubbles)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model2("progs/s_bubble.spr");
	this.nextthink = time + 1;
	setthink(this, make_lostbubble);
}

void make_lostbubble(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, this.origin);
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 -30';
	bubble.nextthink = time + 0.5;
	setthink(bubble, lostbubble_bob);
	settouch(bubble, lostbubble_remove);
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.nextthink = ((time + random ()) + 0.5);
	setthink(this, make_lostbubble);
}

void lostbubble_split(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, this.origin);
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 -30';
	bubble.nextthink = time + 0.5;
	setthink(bubble, snow_bob);
	settouch(bubble, snow_remove);
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = 10;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.frame = 1;
	this.cnt = 10;
}

void lostbubble_remove(entity this, entity toucher)
{
	if(toucher.classname == this.classname)
		return;
	delete(this);
}

void lostbubble_bob(entity this)
{
	this.cnt = (this.cnt + 1);
	if(this.cnt == 4)
		bubble_split(this);
	if(this.cnt == 20)
	{
		delete(this);
		return;
	}
	float rnd1 = (this.velocity_x + (-20 + (random () * 40)));
	float rnd2 = (this.velocity_y + (-20 + (random () * 40)));
	float rnd3 = ((this.velocity_z - 20) - (random () * 20));
	if(rnd1 > 20)
		rnd1 = 10;
	if(rnd1 < -20)
		rnd1 = -10;
	if(rnd2 > 20)
		rnd2 = 10;
	if(rnd2 < -20)
		rnd2 = -10;
	if(rnd3 < -20)
		rnd3 = -30;
	if(rnd3 > -60)
		rnd3 = -50;
	this.velocity = vec3(rnd1, rnd2, rnd3);
	this.nextthink = time + 0.5;
	setthink(this, lostbubble_bob);
}
void make_drop(entity this);
void drop_bob(entity this, entity toucher);
void make_rain(entity this);

spawnfunc(rain_fall)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_model2("progs/drop.spr");
	precache_model2("progs/drop.spr");
	this.nextthink = time + 1;
	setthink(this, make_drop);
}

void s_rain1(entity this);
void s_rain3(entity this) { set_anim(this, 2, s_rain1); }
void s_rain2(entity this) { set_anim(this, 1, s_rain3); }
void s_rain1(entity this) { set_anim(this, 0, s_rain2); }

void make_rain(entity this)
{
	entity rain = spawn();
	_setmodel(rain, "progs/drop.spr");
	setorigin (rain, this.origin);
	set_movetype(rain, MOVETYPE_NOCLIP);
	rain.solid = SOLID_NOT;
	rain.frame = 0;
	setthink(rain, SUB_Remove);
	rain.nextthink = time + 1;
	rain.velocity = '0 0 -250';
}

void premake_drop(entity this)
{
	make_drop(this);
}

void make_drop(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/drop.spr");
	setorigin (bubble, this.origin);
	float rnd1 = bubble.origin_x + (-120 + (random () * 240));
	float rnd2 = bubble.origin_y + (-120 + (random () * 240));
	bubble.origin_x = rnd1;
	bubble.origin_y = rnd2;
	setorigin(bubble, bubble.origin);
	set_movetype(bubble, MOVETYPE_TOSS);
	bubble.solid = SOLID_BBOX;
	bubble.velocity = '0 0 -50';
	settouch(bubble, drop_bob);
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize(bubble, '0 0 0', '0 0 0');
	this.nextthink = time + 0.2;
	setthink(this, premake_drop);
}

void s_splash5(entity this) { set_anim(this, 4, SUB_Remove); }
void s_splash4(entity this) { set_anim(this, 3, s_splash5); }
void s_splash3(entity this) { set_anim(this, 2, s_splash4); }
void s_splash2(entity this) { set_anim(this, 1, s_splash3); }
void s_splash1(entity this) { set_anim(this, 0, s_splash2); }

void drop_bob(entity this, entity toucher)
{
	s_splash1(this);
}
