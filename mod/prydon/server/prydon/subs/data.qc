nosave var float datasaved = 0;

void(entity e) writeinventory =
{
	float i;
	qwrite("save_inven");
	if (e.targetname)
		qwrite(e.targetname);
	else
		qwrite(e.netname);
	for (i = 1; i <= TOTAL_SLOTS; i = i + 1)
		qwrite(vtos(GetSlot(e, i)));
	qwrite(ftos(e.gp));
};
void(entity e) writequest =
{
	qwrite("quest");
	qwrite(ftos(e.lip));
	qwrite(e.story_name);
};
void() questitem;
void() readquestitem =
{
	local entity e;
	
	e = spawn();
	e.classname = "questitem";
	e.slot1 = stov(qread());
	e.finalangle = stov(qread());
	e.mangle = stov(qread());
	e.max_health = stof(qread());
	e.model = strzone(qread());
	e.noise = strzone(qread());
	e.ai = stof(qread());
	e.str = stof(qread());
	e.dex = stof(qread());
	e.mag = stof(qread());
	e.vit = stof(qread());
	e.luck = stof(qread());
	e.agil = stof(qread());
	e.ptd = stof(qread());
	e.daml = stof(qread());
	e.dama = stof(qread());
	e.tohit = stof(qread());
	e.currentammo = stof(qread());
	e.health = stof(qread());
	e.ac = stof(qread());
	e.spell = stof(qread());
	e.gotstuff = stof(qread());
	e.fire = stof(qread());
	e.poidam = stof(qread());
	e.lit = stof(qread());
	e.spec = stof(qread());
	e.skill = stof(qread());
	e.misc = stof(qread());
	e.res_fire = stof(qread());
	e.res_lit = stof(qread());
	e.res_poison = stof(qread());
	e.res_mag = stof(qread());
	e.res_cold = stof(qread());
	e.block = stof(qread());
	e.mana_regen = stof(qread());
	e.critical = stof(qread());
	e.aspeed = stof(qread());
	e.health_regen = stof(qread());
	e.attacker_dam = stof(qread());
	e.attacker_fire = stof(qread());
	e.attacker_lit = stof(qread());
	e.attacker_cold = stof(qread());
	e.attacker_poison = stof(qread());
	e.piercing = stof(qread());
	e.req_lvl = stof(qread());
	e.req_str = stof(qread());
	e.req_dex = stof(qread());
	e.req_mag = stof(qread());
	e.req_vit = stof(qread());
	e.req_luck = stof(qread());
	e.req_agil = stof(qread());
	e.req_class = stov(qread());
	
	e.damage_reduced = stof(qread());
	e.magic_reduced = stof(qread());
	e.menu = stof(qread());
	e.visibility = stof(qread());
	
	call(questitem, e);
	
};
void(entity e) writequestitem =
{
	qwrite("questitem");
	qwrite(vtos(e.slot1));
	qwrite(vtos(e.finalangle));
	qwrite(vtos(e.mangle));
	qwrite(ftos(e.max_health));
	qwrite(e.model);
	qwrite(e.noise);
	qwrite(ftos(e.ai));
	qwrite(ftos(e.str));
	qwrite(ftos(e.dex));
	qwrite(ftos(e.mag));
	qwrite(ftos(e.vit));
	qwrite(ftos(e.luck));
	qwrite(ftos(e.agil));
	qwrite(ftos(e.ptd));
	qwrite(ftos(e.daml));
	qwrite(ftos(e.dama));
	qwrite(ftos(e.tohit));
	qwrite(ftos(e.currentammo));
	qwrite(ftos(e.health));
	qwrite(ftos(e.ac));
	qwrite(ftos(e.spell));
	qwrite(ftos(e.gotstuff));
	qwrite(ftos(e.fire));
	qwrite(ftos(e.poidam));
	qwrite(ftos(e.lit));
	qwrite(ftos(e.spec));
	qwrite(ftos(e.skill));
	qwrite(ftos(e.misc));
	qwrite(ftos(e.res_fire));
	qwrite(ftos(e.res_lit));
	qwrite(ftos(e.res_poison));
	qwrite(ftos(e.res_mag));
	qwrite(ftos(e.res_cold));
	qwrite(ftos(e.block));
	qwrite(ftos(e.mana_regen));
	qwrite(ftos(e.critical));
	qwrite(ftos(e.aspeed));
	qwrite(ftos(e.health_regen));
	qwrite(ftos(e.attacker_dam));
	qwrite(ftos(e.attacker_fire));
	qwrite(ftos(e.attacker_lit));
	qwrite(ftos(e.attacker_cold));
	qwrite(ftos(e.attacker_poison));
	qwrite(ftos(e.piercing));
	if (e.req_lvl)
		qwrite(ftos(e.req_lvl));
	else
		qwrite(ftos(e.frags));
	qwrite(ftos(e.req_str));
	qwrite(ftos(e.req_dex));
	qwrite(ftos(e.req_mag));
	qwrite(ftos(e.req_vit));
	qwrite(ftos(e.req_luck));
	qwrite(ftos(e.req_agil));
	qwrite(vtos(e.req_class));
	
	qwrite(ftos(e.damage_reduced));
	qwrite(ftos(e.magic_reduced));
	qwrite(ftos(e.menu));
	qwrite(ftos(e.visibility));

};

void() writedata =
{
	local entity e;
	e = nextent(world);
	while (e)
	{
		if (e.misc & MISC_SAVE_INVENTORY)
			writeinventory(e);
		if (e.classname == "quest")
			writequest(e);
		if (e.classname == "questitem")
			writequestitem(e);
		e = nextent(e);
	}
	qwrite("randquest");
	qwrite(vtos(rndquest));
	qwrite(vtos(rq_vars));
	
	qwrite("enddata");
};

void() readinventory =
{
	local entity e;
	local float i;
	
	e = spawn();
	e.classname = "save_inven";
	e.targetname = strzone(qread());
	for (i = 1; i <= TOTAL_SLOTS; i = i + 1)
		SetSlot(e, i, stov(qread()));
	e.gp = stof(qread());
	e.misc = MISC_SAVE_INVENTORY;
};

void() datacheck =
{
	local entity t;
	local float i;
	
	if (self.misc & MISC_SAVE_INVENTORY)
	{
		t = find(world, classname, "save_inven");
		while(t)
		{
			if (t.targetname == self.targetname || t.targetname == self.netname)
			{
				for (i = 1; i <= TOTAL_SLOTS; i = i + 1)
					SetSlot(self, i, GetSlot(t, i));
				self.gp = t.gp;
				strunzone(t.targetname);
				remove(t);
				break;
			}
			t = find(t, classname, "save_inven");
		}
	}
};
void() readdata =
{
	local string s;
	local float f;
	while(1)
	{
		s = qread();
		if (s == "quest")
		{
			f = stof(qread());
			s = strzone(qread());
			spawnstory(f, s, s);
		}
		else if (s == "save_inven")
			readinventory();
		else if (s == "questitem")
			readquestitem();
		else if (s == "enddata")
			return;
		else if (s == "randquest")
		{
			rndquest = stov(qread());
			rq_vars = stov(qread());
		}
		if (fileerror)
			return;
	}
};
void() loaddata =
{
	local float c;

	
	mainstory = decode(serverflags, 1);
	c = cvar("gamecfg");
	opt1 = decode(c, 1);
	opt2 = decode(c, 2);
	opt3 = decode(c, 3);
	c = cvar("savedgamecfg");
	opt4 = decode(c, 1);
	opt5 = decode(c, 2);
	opt6 = decode(c, 3);
	runtime = cvar("sv_aim");	
	c = cvar("nomonsters");
	rndquest_x = decode(c, 1);
	rndquest_y = decode(c, 2);
	rndquest_z = decode(c, 3);
	c = cvar("samelevel");
	rq_vars_x = decode(c, 1);
	rq_vars_y = decode(c, 2);
	rq_vars_z = decode(c, 3);
	
	if (fileaccess)
	{
		qopenread("gamedata.pgg");
		if (SAVE_VERSION == stof(qread()))
			readdata();
		qclose();
	}
};


void() savedata =
{
	if (datasaved)
		return;
	datasaved = 1;
	if (fileaccess)
	{
		qopenwrite("gamedata.pgg");
		qwrite(ftos(SAVE_VERSION));
		writedata();
		qclose();
	}	
	if (!world.map)
	{
		opt1 = getstorybyname("opt1");
		opt2 = getstorybyname("opt2");
		opt3 = getstorybyname("opt3");
		opt4 = getstorybyname("opt4");
		opt5 = getstorybyname("opt5");
		opt6 = getstorybyname("opt6");
	}
	cvar_set("sv_aim", (ftos(runtime + time)));
	cvar_set("gamecfg", ftos(encode(opt1, opt2, opt3)));
	cvar_set("savedgamecfg", ftos(encode(opt4, opt5, opt6)));
	
	cvar_set("nomonsters", ftos(encode(rndquest_x, rndquest_y, rndquest_z)));
	cvar_set("samelevel", ftos(encode(rq_vars_x, rq_vars_y, rq_vars_z)));
	
	//serverflags = encode(mainstory, averagelvl, world.impulse);
};