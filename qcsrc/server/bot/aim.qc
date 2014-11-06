
entity ka_ball;
// traces multiple trajectories to find one that will impact the target
// 'end' vector is the place it aims for,
// returns TRUE only if it hit targ (don't target non-solid entities)

float findtrajectorywithleading(vector org, vector m1, vector m2, entity targ, float shotspeed, float shotspeedupward, float maxtime, float shotdelay, entity ignore)
{
	float c, savesolid, shottime;
	vector dir, end, v, o;
	if (shotspeed < 1)
		return FALSE; // could cause division by zero if calculated
	if (targ.solid < SOLID_BBOX) // SOLID_NOT and SOLID_TRIGGER
		return FALSE; // could never hit it
	if (!tracetossent)
		tracetossent = spawn();
	tracetossent.owner = ignore;
	setsize(tracetossent, m1, m2);
	savesolid = targ.solid;
	targ.solid = SOLID_NOT;
	o = (targ.absmin + targ.absmax) * 0.5;
	shottime = ((vlen(o - org) / shotspeed) + shotdelay);
	v = targ.velocity * shottime + o;
	tracebox(o, targ.mins, targ.maxs, v, FALSE, targ);
	v = trace_endpos;
	end = v + (targ.mins + targ.maxs) * 0.5;
	if ((vlen(end - org) / shotspeed + 0.2) > maxtime)
	{
		// out of range
		targ.solid = savesolid;
		return FALSE;
	}

	if (!tracetossfaketarget)
		tracetossfaketarget = spawn();
	tracetossfaketarget.solid = savesolid;
	tracetossfaketarget.movetype = targ.movetype;
	setmodel(tracetossfaketarget, targ.model); // no low precision
	tracetossfaketarget.model = targ.model;
	tracetossfaketarget.modelindex = targ.modelindex;
	setsize(tracetossfaketarget, targ.mins, targ.maxs);
	setorigin(tracetossfaketarget, v);

	c = 0;
	dir = normalize(end - org);
	while (c < 10) // 10 traces
	{
		setorigin(tracetossent, org); // reset
		tracetossent.velocity = findtrajectory_velocity = normalize(dir) * shotspeed + shotspeedupward * '0 0 1';
		tracetoss(tracetossent, ignore); // love builtin functions...
		if (trace_ent == tracetossfaketarget) // done
		{
			targ.solid = savesolid;

			// make it disappear
			tracetossfaketarget.solid = SOLID_NOT;
			tracetossfaketarget.movetype = MOVETYPE_NONE;
			tracetossfaketarget.model = "";
			tracetossfaketarget.modelindex = 0;
			// relink to remove it from physics considerations
			setorigin(tracetossfaketarget, v);

			return TRUE;
		}
		dir_z = dir_z + 0.1; // aim up a little more
		c = c + 1;
	}
	targ.solid = savesolid;

	// make it disappear
	tracetossfaketarget.solid = SOLID_NOT;
	tracetossfaketarget.movetype = MOVETYPE_NONE;
	tracetossfaketarget.model = "";
	tracetossfaketarget.modelindex = 0;
	// relink to remove it from physics considerations
	setorigin(tracetossfaketarget, v);

	// leave a valid one even if it won't reach
	findtrajectory_velocity = normalize(end - org) * shotspeed + shotspeedupward * '0 0 1';
	return FALSE;
}

void lag_update()
{
	if (self.lag1_time) if (time > self.lag1_time) {self.lag_func(self.lag1_time, self.lag1_float1, self.lag1_float2, self.lag1_entity1, self.lag1_vec1, self.lag1_vec2, self.lag1_vec3, self.lag1_vec4);self.lag1_time = 0;}
	if (self.lag2_time) if (time > self.lag2_time) {self.lag_func(self.lag2_time, self.lag2_float1, self.lag2_float2, self.lag2_entity1, self.lag2_vec1, self.lag2_vec2, self.lag2_vec3, self.lag2_vec4);self.lag2_time = 0;}
	if (self.lag3_time) if (time > self.lag3_time) {self.lag_func(self.lag3_time, self.lag3_float1, self.lag3_float2, self.lag3_entity1, self.lag3_vec1, self.lag3_vec2, self.lag3_vec3, self.lag3_vec4);self.lag3_time = 0;}
	if (self.lag4_time) if (time > self.lag4_time) {self.lag_func(self.lag4_time, self.lag4_float1, self.lag4_float2, self.lag4_entity1, self.lag4_vec1, self.lag4_vec2, self.lag4_vec3, self.lag4_vec4);self.lag4_time = 0;}
	if (self.lag5_time) if (time > self.lag5_time) {self.lag_func(self.lag5_time, self.lag5_float1, self.lag5_float2, self.lag5_entity1, self.lag5_vec1, self.lag5_vec2, self.lag5_vec3, self.lag5_vec4);self.lag5_time = 0;}
}

float lag_additem(float t, float f1, float f2, entity e1, vector v1, vector v2, vector v3, vector v4)
{
	if (self.lag1_time == 0) {self.lag1_time = t;self.lag1_float1 = f1;self.lag1_float2 = f2;self.lag1_entity1 = e1;self.lag1_vec1 = v1;self.lag1_vec2 = v2;self.lag1_vec3 = v3;self.lag1_vec4 = v4;return TRUE;}
	if (self.lag2_time == 0) {self.lag2_time = t;self.lag2_float1 = f1;self.lag2_float2 = f2;self.lag2_entity1 = e1;self.lag2_vec1 = v1;self.lag2_vec2 = v2;self.lag2_vec3 = v3;self.lag2_vec4 = v4;return TRUE;}
	if (self.lag3_time == 0) {self.lag3_time = t;self.lag3_float1 = f1;self.lag3_float2 = f2;self.lag3_entity1 = e1;self.lag3_vec1 = v1;self.lag3_vec2 = v2;self.lag3_vec3 = v3;self.lag3_vec4 = v4;return TRUE;}
	if (self.lag4_time == 0) {self.lag4_time = t;self.lag4_float1 = f1;self.lag4_float2 = f2;self.lag4_entity1 = e1;self.lag4_vec1 = v1;self.lag4_vec2 = v2;self.lag4_vec3 = v3;self.lag4_vec4 = v4;return TRUE;}
	if (self.lag5_time == 0) {self.lag5_time = t;self.lag5_float1 = f1;self.lag5_float2 = f2;self.lag5_entity1 = e1;self.lag5_vec1 = v1;self.lag5_vec2 = v2;self.lag5_vec3 = v3;self.lag5_vec4 = v4;return TRUE;}
	// no room for it (what is the best thing to do here??)
	return FALSE;
}

float bot_shouldattack(entity e)
{
	if (e.team == self.team)
	{
		if (e == self)
			return FALSE;
		if (teamplay)
		if (e.team != 0)
			return FALSE;
	}

	if(e.frozen)
		return FALSE;

	if(teamplay)
	{
		if(e.team==0)
			return FALSE;
	}
	else if(bot_ignore_bots)
		if(IS_BOT_CLIENT(e))
			return FALSE;

	if (!e.takedamage)
		return FALSE;
	if (e.deadflag)
		return FALSE;
	if (e.BUTTON_CHAT)
		return FALSE;
	if(e.flags & FL_NOTARGET)
		return FALSE;
	if(e.alpha <= 0.5 && e.alpha != 0)
		return FALSE; // invisible

	other = e;
	if(MUTATOR_CALLHOOK(BotShouldAttack))
		return FALSE;

	return TRUE;
}

void bot_lagfunc(float t, float f1, float f2, entity e1, vector v1, vector v2, vector v3, vector v4)
{
	if(self.flags & FL_INWATER)
	{
		self.bot_aimtarg = world;
		return;
	}
	self.bot_aimtarg = e1;
	self.bot_aimlatency = self.ping; // FIXME?  Shouldn't this be in the lag item?
	self.bot_aimselforigin = v1;
	self.bot_aimselfvelocity = v2;
	self.bot_aimtargorigin = v3;
	self.bot_aimtargvelocity = v4;
	if(bot_skill <= 0)
		self.bot_canfire = (random() < 0.8);
	else if(bot_skill <= 1)
		self.bot_canfire = (random() < 0.9);
	else if(bot_skill <= 2)
		self.bot_canfire = (random() < 0.95);
	else
		self.bot_canfire = 1;
}

float bot_aimdir(vector v, float maxfiredeviation)
{
	float dist, delta_t, blend;
	vector desiredang, diffang;

	//dprint("aim ", self.netname, ": old:", vtos(self.v_angle));
	// make sure v_angle is sane first
	self.v_angle_y = self.v_angle_y - floor(self.v_angle_y / 360) * 360;
	self.v_angle_z = 0;

	// get the desired angles to aim at
	//dprint(" at:", vtos(v));
	v = normalize(v);
	//te_lightning2(world, self.origin + self.view_ofs, self.origin + self.view_ofs + v * 200);
	if (time >= self.bot_badaimtime)
	{
		self.bot_badaimtime = max(self.bot_badaimtime + 0.3, time);
		self.bot_badaimoffset = randomvec() * bound(0, 5 - 0.5 * (bot_skill+self.bot_offsetskill), 5) * autocvar_bot_ai_aimskill_offset;
	}
	desiredang = vectoangles(v) + self.bot_badaimoffset;
	//dprint(" desired:", vtos(desiredang));
	if (desiredang_x >= 180)
		desiredang_x = desiredang_x - 360;
	desiredang_x = bound(-90, 0 - desiredang_x, 90);
	desiredang_z = self.v_angle_z;
	//dprint(" / ", vtos(desiredang));

	//// pain throws off aim
	//if (self.bot_painintensity)
	//{
	//	// shake from pain
	//	desiredang = desiredang + randomvec() * self.bot_painintensity * 0.2;
	//}

	// calculate turn angles
	diffang = (desiredang - self.bot_olddesiredang);
	// wrap yaw turn
	diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	if (diffang_y >= 180)
		diffang_y = diffang_y - 360;
	self.bot_olddesiredang = desiredang;
	//dprint(" diff:", vtos(diffang));

	delta_t = time-self.bot_prevaimtime;
	self.bot_prevaimtime = time;
	// Here we will try to anticipate the comming aiming direction
	self.bot_1st_order_aimfilter= self.bot_1st_order_aimfilter
		+ (diffang * (1 / delta_t)    - self.bot_1st_order_aimfilter) * bound(0, autocvar_bot_ai_aimskill_order_filter_1st,1);
	self.bot_2nd_order_aimfilter= self.bot_2nd_order_aimfilter
		+ (self.bot_1st_order_aimfilter - self.bot_2nd_order_aimfilter) * bound(0, autocvar_bot_ai_aimskill_order_filter_2nd,1);
	self.bot_3th_order_aimfilter= self.bot_3th_order_aimfilter
		+ (self.bot_2nd_order_aimfilter - self.bot_3th_order_aimfilter) * bound(0, autocvar_bot_ai_aimskill_order_filter_3th,1);
	self.bot_4th_order_aimfilter= self.bot_4th_order_aimfilter
		+ (self.bot_3th_order_aimfilter - self.bot_4th_order_aimfilter) * bound(0, autocvar_bot_ai_aimskill_order_filter_4th,1);
	self.bot_5th_order_aimfilter= self.bot_5th_order_aimfilter
		+ (self.bot_4th_order_aimfilter - self.bot_5th_order_aimfilter) * bound(0, autocvar_bot_ai_aimskill_order_filter_5th,1);

	//blend = (bound(0,skill,10)*0.1)*pow(1-bound(0,skill,10)*0.05,2.5)*5.656854249; //Plot formule before changing !
	blend = bound(0,bot_skill+self.bot_aimskill,10)*0.1;
	desiredang = desiredang + blend *
	(
		  self.bot_1st_order_aimfilter * autocvar_bot_ai_aimskill_order_mix_1st
		+ self.bot_2nd_order_aimfilter * autocvar_bot_ai_aimskill_order_mix_2nd
		+ self.bot_3th_order_aimfilter * autocvar_bot_ai_aimskill_order_mix_3th
		+ self.bot_4th_order_aimfilter * autocvar_bot_ai_aimskill_order_mix_4th
		+ self.bot_5th_order_aimfilter * autocvar_bot_ai_aimskill_order_mix_5th
	);

	// calculate turn angles
	diffang = desiredang - self.bot_mouseaim;
	// wrap yaw turn
	diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	if (diffang_y >= 180)
		diffang_y = diffang_y - 360;
	//dprint(" diff:", vtos(diffang));

	if (time >= self.bot_aimthinktime)
	{
		self.bot_aimthinktime = max(self.bot_aimthinktime + 0.5 - 0.05*(bot_skill+self.bot_thinkskill), time);
		self.bot_mouseaim = self.bot_mouseaim + diffang * (1-random()*0.1*bound(1,10-(bot_skill+self.bot_thinkskill),10));
	}

	//self.v_angle = self.v_angle + diffang * bound(0, r * frametime * (bot_skill * 0.5 + 2), 1);

	diffang = self.bot_mouseaim - desiredang;
	// wrap yaw turn
	diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	if (diffang_y >= 180)
		diffang_y = diffang_y - 360;
	desiredang = desiredang + diffang * bound(0,autocvar_bot_ai_aimskill_think,1);

	// calculate turn angles
	diffang = desiredang - self.v_angle;
	// wrap yaw turn
	diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	if (diffang_y >= 180)
		diffang_y = diffang_y - 360;
	//dprint(" diff:", vtos(diffang));

	// jitter tracking
	dist = vlen(diffang);
	//diffang = diffang + randomvec() * (dist * 0.05 * (3.5 - bound(0, bot_skill, 3)));

	// turn
	float r, fixedrate, blendrate;
	fixedrate = autocvar_bot_ai_aimskill_fixedrate / bound(1,dist,1000);
	blendrate = autocvar_bot_ai_aimskill_blendrate;
	r = max(fixedrate, blendrate);
	//self.v_angle = self.v_angle + diffang * bound(frametime, r * frametime * (2+skill*skill*0.05-random()*0.05*(10-skill)), 1);
	self.v_angle = self.v_angle + diffang * bound(delta_t, r * delta_t * (2+pow(bot_skill+self.bot_mouseskill,3)*0.005-random()), 1);
	self.v_angle = self.v_angle * bound(0,autocvar_bot_ai_aimskill_mouse,1) + desiredang * bound(0,(1-autocvar_bot_ai_aimskill_mouse),1);
	//self.v_angle = self.v_angle + diffang * bound(0, r * frametime * (bot_skill * 0.5 + 2), 1);
	//self.v_angle = self.v_angle + diffang * (1/ blendrate);
	self.v_angle_z = 0;
	self.v_angle_y = self.v_angle_y - floor(self.v_angle_y / 360) * 360;
	//dprint(" turn:", vtos(self.v_angle));

	makevectors(self.v_angle);
	shotorg = self.origin + self.view_ofs;
	shotdir = v_forward;

	//dprint(" dir:", vtos(v_forward));
	//te_lightning2(world, shotorg, shotorg + shotdir * 100);

	// calculate turn angles again
	//diffang = desiredang - self.v_angle;
	//diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	//if (diffang_y >= 180)
	//	diffang_y = diffang_y - 360;

	//dprint("e ", vtos(diffang), " < ", ftos(maxfiredeviation), "\n");

	// decide whether to fire this time
	// note the maxfiredeviation is in degrees so this has to convert to radians first
	//if ((normalize(v) * shotdir) >= cos(maxfiredeviation * (3.14159265358979323846 / 180)))
	if ((normalize(v) * shotdir) >= cos(maxfiredeviation * (3.14159265358979323846 / 180)))
	if (vlen(trace_endpos-shotorg) < 500+500*bound(0, bot_skill+self.bot_aggresskill, 10) || random()*random()>bound(0,(bot_skill+self.bot_aggresskill)*0.05,1))
		self.bot_firetimer = time + bound(0.1, 0.5-(bot_skill+self.bot_aggresskill)*0.05, 0.5);
	//traceline(shotorg,shotorg+shotdir*1000,FALSE,world);
	//dprint(ftos(maxfiredeviation),"\n");
	//dprint(" diff:", vtos(diffang), "\n");

	return self.bot_canfire && (time < self.bot_firetimer);
}

vector bot_shotlead(vector targorigin, vector targvelocity, float shotspeed, float shotdelay)
{
	// Try to add code here that predicts gravity effect here, no clue HOW to though ... well not yet atleast...
	return targorigin + targvelocity * (shotdelay + vlen(targorigin - shotorg) / shotspeed);
}

float bot_aim(float shotspeed, float shotspeedupward, float maxshottime, float applygravity)
{
	float f, r, hf, distanceratio;
	vector v;
	/*
	eprint(self);
	dprint("bot_aim(", ftos(shotspeed));
	dprint(", ", ftos(shotspeedupward));
	dprint(", ", ftos(maxshottime));
	dprint(", ", ftos(applygravity));
	dprint(");\n");
	*/

	hf = self.dphitcontentsmask;
	self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	shotspeed *= g_weaponspeedfactor;
	shotspeedupward *= g_weaponspeedfactor;
	if (!shotspeed)
	{
		dprint("bot_aim: WARNING: weapon ", W_Name(self.weapon), " shotspeed is zero!\n");
		shotspeed = 1000000;
	}
	if (!maxshottime)
	{
		dprint("bot_aim: WARNING: weapon ", W_Name(self.weapon), " maxshottime is zero!\n");
		maxshottime = 1;
	}
	makevectors(self.v_angle);
	shotorg = self.origin + self.view_ofs;
	shotdir = v_forward;
	v = bot_shotlead(self.bot_aimtargorigin, self.bot_aimtargvelocity, shotspeed, self.bot_aimlatency);
	distanceratio = sqrt(bound(0,bot_skill,10000))*0.3*(vlen(v-shotorg)-100)/autocvar_bot_ai_aimskill_firetolerance_distdegrees;
	distanceratio = bound(0,distanceratio,1);
	r =  (autocvar_bot_ai_aimskill_firetolerance_maxdegrees-autocvar_bot_ai_aimskill_firetolerance_mindegrees)
		* (1-distanceratio) + autocvar_bot_ai_aimskill_firetolerance_mindegrees;
	if (applygravity && self.bot_aimtarg)
	{
		if (!findtrajectorywithleading(shotorg, '0 0 0', '0 0 0', self.bot_aimtarg, shotspeed, shotspeedupward, maxshottime, 0, self))
		{
			self.dphitcontentsmask = hf;
			return FALSE;
		}

		f = bot_aimdir(findtrajectory_velocity - shotspeedupward * '0 0 1', r);
	}
	else
	{
		f = bot_aimdir(v - shotorg, r);
		//dprint("AIM: ");dprint(vtos(self.bot_aimtargorigin));dprint(" + ");dprint(vtos(self.bot_aimtargvelocity));dprint(" * ");dprint(ftos(self.bot_aimlatency + vlen(self.bot_aimtargorigin - shotorg) / shotspeed));dprint(" = ");dprint(vtos(v));dprint(" : aimdir = ");dprint(vtos(normalize(v - shotorg)));dprint(" : ");dprint(vtos(shotdir));dprint("\n");
		//traceline(shotorg, shotorg + shotdir * 10000, FALSE, self);
		//if (trace_ent.takedamage)
		//if (trace_fraction < 1)
		//if (!bot_shouldattack(trace_ent))
		//	return FALSE;
		traceline(shotorg, self.bot_aimtargorigin, FALSE, self);
		if (trace_fraction < 1)
		if (trace_ent != self.enemy)
		if (!bot_shouldattack(trace_ent))
		{
			self.dphitcontentsmask = hf;
			return FALSE;
		}
	}

	//if (r > maxshottime * shotspeed)
	//	return FALSE;
	self.dphitcontentsmask = hf;
	return TRUE;
}
