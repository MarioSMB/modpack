float (vector v1, vector v2) difcheck =
{
	local float f;
	f = fabs (v1_z - v2_z) - 16;
	v1_z = v2_z = 0;
	if (f < vlen(v1 - v2))
		return TRUE;
	return FALSE;
};

void() h_click =
{
	local vector ang;
	float runaway, ca, friend;
//PRYDON_CLIENTCURSOR

	if (self.cursor_active)
	{
		trace_endpos = self.cursor_trace_endpos;
		trace_ent = self.cursor_trace_ent;

		if (!trace_ent)
		{
			ang = normalize(self.cursor_trace_endpos - self.cursor_trace_start);
					
			traceline(self.cursor_trace_start, self.cursor_trace_endpos, self.button3, self);
		}
		else
		{
			// MAJOR HACK!
			if (trace_ent.classname == "func_door2")
			{
				trace_ent = trace_ent.enemy;
				if (trace_ent.solid != SOLID_BBOX)
					trace_ent = world;
			}
			else if (!trace_ent.effects & EF_SELECTABLE)
				trace_ent = world;
			if (trace_ent == self.player)
				return;
		}
		self.cursor_trace_ent = trace_ent;			
	}
	else
	{
		trace_ent = ui_over();
	
		if (!trace_ent)
		{
			ang = normalize((v_forward * 96) + (v_right * self.cursorpos_x) - (v_up * self.cursorpos_y));
			traceline(self.origin, self.origin + ang * 2300, self.button3, self);
			if (trace_startsolid)
				traceline(self.cursor.origin, self.cursor.origin + ang * 2300, self.button3, self);
			while(trace_plane_normal_z < 0.7 && trace_ent == world)
			{
				traceline(trace_endpos + ang, trace_endpos + ang * 2300, self.button3, self);
				runaway = runaway + 1;
				if (runaway > 10)
				{
					self.cursor_trace_ent = world;
					return; // oh, it's just a harmless lil' bunny innit?
				}
			}
			if (trace_ent.classname == "func_fadewalk")
			{
				if (trace_ent.alpha == 0)
					traceline(trace_endpos + ang, trace_endpos + ang * 2300, FALSE, trace_ent);
			}
		}
		self.cursor_trace_ent = trace_ent;
	}
		
	if (self.button0)
	{
		if (trace_ent.ui_clicked)
		{
			other = self;
			self = trace_ent;
			self.ui_clicked(0);
			self = other;
		}
		else
		{
			if (self.dbltime == 0)
				self.dbltime = time + 0.5;
			else if (self.dbltime < 0)
			{
			
				if ((0 - self.dbltime) >= time)
	                        {
					if (self.player)
						self.player.menu = TRUE; // set speed
				}
				else
					self.dbltime = time;
			}
	
			if (self.player)
			{
				if (self.player.think != AnimatePlayer) // doing an attack??
					return; 
	
				friend = friendly(trace_ent, self.player);
				
				if ((!friend) && trace_ent.takedamage)
				{
					self.player.gotstuff = self.altaction;
					self.player.goalentity = trace_ent;
					if (self.menu)
						closemenu(self);
				}
				else if (trace_ent.action)
				{
					if (trace_ent.action != donothing)
					{
						self.player.gotstuff = SP_ACTIVATE;	
						self.player.goalentity = trace_ent;
					}
				}
				else
				{
					if (difcheck(trace_endpos, self.player.origin))
					{
						if (!self.wayp)
							self.wayp = spawn();
						self.wayp.model = "";
						setorigin(self.wayp, trace_endpos + '0 0 22');
						self.wayp.owner = self;
						self.player.goalentity = self.wayp;
						if (self.button3)
							self.player.gotstuff = self.altaction;
						else
							self.player.gotstuff = SP_GOTO;
					}
				}
			}
		}
	}
	else
	{
		if (self.dbltime > 0)
		{
			if (self.dbltime >= time)
				self.dbltime = 0 - (time + 0.5);
			else
				self.dbltime = 0;
		}
		else if (self.dbltime < 0)
		{
			if ((0 - self.dbltime) < time)
				self.dbltime = 0;
		}
	}
	if (self.button2)
	{

		if (self.flags & FL_JUMPRELEASED)
		{
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			if (trace_ent.ui_clicked)
			{
				other = self;
				self = trace_ent;
				self.ui_clicked(1);
				self = other;
			}
			else if (self.spell)
			{

				friend = friendly(self.player, trace_ent);
				
				if (self.player)
				{
					if (self.player.think != AnimatePlayer) // doing an attack??
						return; 
					ca = cast_aground(self.spell);
					if (ca == 2)
					{
						// special Item mode
						if (trace_ent.classname == "item")
						{
							it_simplestat(trace_ent.slot1);
							if (stat_it < IT_GOLD)
							{
								if (!trace_ent.menu)
								{	
									self.player.gotstuff = self.spell;
									self.player.goalentity = trace_ent;
									if (self.menu)
										closemenu(self);
								}
							}
						}
					}
					else if (self.spell == SP_HEAL && friend && trace_ent.takedamage)
					{
						self.player.gotstuff = self.spell;
						self.player.goalentity = trace_ent;
						if (self.menu)
							closemenu(self);
					}
					else if (self.spell == SP_SHIELD && friend && trace_ent.takedamage)
					{
						self.player.gotstuff = self.spell;
						self.player.goalentity = trace_ent;
						if (self.menu)
							closemenu(self);
					}
					else if ((!friend) && trace_ent.takedamage && !ca)
					{
						self.player.gotstuff = self.spell;
						self.player.goalentity = trace_ent;
						if (self.menu)
							closemenu(self);
					}
					else if (ca || self.button3)
					{
						if (!self.wayp)
							self.wayp = spawn();
						self.wayp.model = "";
						self.wayp.owner = self;
						setorigin(self.wayp, trace_endpos + '0 0 22');
						// do we need this?
						if (self.button3) 
							self.player.enemy = self.wayp;
						self.player.goalentity = self.wayp;
						self.player.gotstuff = self.spell;
					}
				}
			}
		}
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;
};
