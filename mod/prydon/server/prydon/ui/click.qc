#include "click.qh"

#include "../spells/sstats.qh"
#include "../spells/sval.qh"
#include "../subs/subs.qh"
#include "ui.qh"

bool difcheck(vector v1, vector v2)
{
	float f = fabs(v1.z - v2.z) - 16;
	v1.z = v2.z = 0;
	return (vdist(v1 - v2, >, f));
}

void h_click(entity this)
{
	vector ang;
	int runaway = 0;
	bool friend = false;
//PRYDON_CLIENTCURSOR

	if(this.cursor_active)
	{
		trace_endpos = this.cursor_trace_endpos;
		trace_ent = this.cursor_trace_ent;

		if(!trace_ent)
		{
			ang = normalize(this.cursor_trace_endpos - this.cursor_trace_start);
					
			traceline(this.cursor_trace_start, this.cursor_trace_endpos, this.button3, this);
		}
		else
		{
			// MAJOR HACK!
			if(trace_ent.classname == "func_door2")
			{
				trace_ent = trace_ent.enemy;
				if(trace_ent.solid != SOLID_BBOX)
					trace_ent = NULL;
			}
			else if(!trace_ent.effects & EF_SELECTABLE)
				trace_ent = NULL;
			if(trace_ent == this.player)
				return;
		}
		this.cursor_trace_ent = trace_ent;			
	}
	else
	{
		trace_ent = ui_over(this);
	
		if(!trace_ent)
		{
			ang = normalize((v_forward * 96) + (v_right * this.cursorpos_x) - (v_up * this.cursorpos_y));
			traceline(this.origin, this.origin + ang * 2300, this.button3, this);
			if(trace_startsolid)
				traceline(this.cursor.origin, this.cursor.origin + ang * 2300, this.button3, this);
			while(trace_plane_normal_z < 0.7 && trace_ent == NULL)
			{
				traceline(trace_endpos + ang, trace_endpos + ang * 2300, this.button3, this);
				runaway = runaway + 1;
				if(runaway > 10)
				{
					this.cursor_trace_ent = NULL;
					return; // oh, it's just a harmless lil' bunny innit?
				}
			}
			if(trace_ent.classname == "func_fadewalk")
			{
				if(trace_ent.alpha == 0)
					traceline(trace_endpos + ang, trace_endpos + ang * 2300, false, trace_ent);
			}
		}
		this.cursor_trace_ent = trace_ent;
	}
		
	if(this.button0)
	{
		if(trace_ent.ui_clicked)
		{
			trace_ent.ui_clicked(trace_ent, this, 0);
		}
		else
		{
			if(this.dbltime == 0)
				this.dbltime = time + 0.5;
			else if(this.dbltime < 0)
			{
			
				if((0 - this.dbltime) >= time)
	                        {
					if(this.player)
						this.player.menu = true; // set speed
				}
				else
					this.dbltime = time;
			}
	
			if(this.player)
			{
				if(getthink(this.player) != AnimatePlayer) // doing an attack??
					return; 
	
				friend = friendly(trace_ent, this.player);
				
				if((!friend) && trace_ent.takedamage)
				{
					this.player.gotstuff = this.altaction;
					this.player.goalentity = trace_ent;
					if(this.menu)
						closemenu(this);
				}
				else if(trace_ent.action)
				{
					if(trace_ent.action != donothing)
					{
						this.player.gotstuff = SP_ACTIVATE;	
						this.player.goalentity = trace_ent;
					}
				}
				else
				{
					if(difcheck(trace_endpos, this.player.origin))
					{
						if(!this.wayp)
							this.wayp = spawn();
						this.wayp.model = "";
						setorigin(this.wayp, trace_endpos + '0 0 22');
						this.wayp.owner = this;
						this.player.goalentity = this.wayp;
						if(this.button3)
							this.player.gotstuff = this.altaction;
						else
							this.player.gotstuff = SP_GOTO;
					}
				}
			}
		}
	}
	else
	{
		if(this.dbltime > 0)
		{
			if(this.dbltime >= time)
				this.dbltime = 0 - (time + 0.5);
			else
				this.dbltime = 0;
		}
		else if(this.dbltime < 0)
		{
			if((0 - this.dbltime) < time)
				this.dbltime = 0;
		}
	}
	if(this.button2)
	{
		if(!IS_JUMP_HELD(this))
		{
			SET_JUMP_HELD(this);
			if(trace_ent.ui_clicked)
			{
				trace_ent.ui_clicked(trace_ent, this, 1);
			}
			else if(this.spell)
			{
				friend = friendly(this.player, trace_ent);
				
				if(this.player)
				{
					if(getthink(this.player) != AnimatePlayer) // doing an attack??
						return; 
					int ca = cast_aground(this.spell);
					if(ca == 2)
					{
						// special Item mode
						if(trace_ent.classname == "item")
						{
							it_simplestat(this, trace_ent.slot1);
							if(stat_it < IT_GOLD)
							{
								if(!trace_ent.menu)
								{	
									this.player.gotstuff = this.spell;
									this.player.goalentity = trace_ent;
									if(this.menu)
										closemenu(this);
								}
							}
						}
					}
					else if(this.spell == SP_HEAL && friend && trace_ent.takedamage)
					{
						this.player.gotstuff = this.spell;
						this.player.goalentity = trace_ent;
						if(this.menu)
							closemenu(this);
					}
					else if(this.spell == SP_SHIELD && friend && trace_ent.takedamage)
					{
						this.player.gotstuff = this.spell;
						this.player.goalentity = trace_ent;
						if(this.menu)
							closemenu(this);
					}
					else if((!friend) && trace_ent.takedamage && !ca)
					{
						this.player.gotstuff = this.spell;
						this.player.goalentity = trace_ent;
						if(this.menu)
							closemenu(this);
					}
					else if(ca || this.button3)
					{
						if(!this.wayp)
							this.wayp = spawn();
						this.wayp.model = "";
						this.wayp.owner = this;
						setorigin(this.wayp, trace_endpos + '0 0 22');
						// do we need this?
						if(this.button3) 
							this.player.enemy = this.wayp;
						this.player.goalentity = this.wayp;
						this.player.gotstuff = this.spell;
					}
				}
			}
		}
	}
	else
		UNSET_JUMP_HELD(this);
}
