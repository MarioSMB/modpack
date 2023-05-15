#include "anim.qh"

void AnimatePlayer(entity this)
{
	if(this.player)
		this = this.player;
		
	setthink(this, AnimatePlayer);
	this.nextthink = time;
	CSQCMODEL_AUTOUPDATE(this);
	if (this.groundentity)
		this.flags = this.flags | FL_PARTIALGROUND;
	if (pointcontents(this.origin - '0 0 22') == CONTENT_LAVA)
	{
		bprint(this.owner.netname);
		bprint(" fell into the lava\n");
		PlayerDie(FALSE);
		
		return;
	}
	else if (this.owner.health <= 0)
	{
		bprint(this.owner.netname);
		bprint(" died mysteriously\n");
		PlayerDie(FALSE);
		return;
	}	
	if (!this.flags & FL_ONGROUND)
		this.fallz = this.velocity_z;
	else if (this.fallz)
	{
		if(this.fallz < -500)
		{
			bprintf("%s fell to his death\n", this.owner.netname);
			PlayerDie(this, FALSE);
			return;
		}
		this.fallz = 0;
	}
	if (this.classname == "dummy" || this.classname == "helper")
	{
		entity t = find(NULL, classname, "helper");
		while(t)
		{
			t.solid = SOLID_TRIGGER;
			setorigin(t, t.origin);
			t = find(t, classname, "helper");
		}
	}
	if (this.cold_time < time)
	{
		if (this.cold_factor != 1)
		{
			this.cold_factor = 1;
			this.pausetime = time;
		}
	}

	if (this.sbarsub && this.goalentity != this.sbarsub)
	{
		if (vlen(this.sbarsub.origin - this.origin) > 256)
			end_hunt();
	}
	setorigin(this, this.origin); // force retouch triggers
	if (this.goalentity)
	{
		entity e = this.goalentity;
		vector org = e.origin;
		if (org == '0 0 0')
		{
			org = (e.absmin + e.absmax) * 0.5;
			org_z = this.origin_z;
		}
		vector old = this.origin;
		org_z = (old_z + org_z * 3) * 0.25;
		if (this.goalentity.deadflag)
		{
			this.enemy = NULL;
			end_hunt();
		}
		else
		{
			if (range_check(this.gotstuff, this.goalentity))
			{
			
				if (this.daze_time > time)
				{
					if (random() < 0.1)
					{
						if (random() < 0.1)
						{
							spell_cast(this.goalentity, this.gotstuff);
						}
						else
							this.angles_y = random() * 360;
					}
					end_hunt();
				}
				else
				{
					spell_cast(this.goalentity, this.gotstuff);
					end_hunt();
				}
			}
			else if ((trace_ent == this.goalentity) &&  vlen(trace_endpos - this.origin) < 24)
			{
				if (this.daze_time > time)
				{
					if (random() < 0.1)
					{
						if (random() < 0.1)
						{
							spell_cast(this.goalentity, this.gotstuff);
						}
						else
							this.angles_y = random() * 360;
					}
					end_hunt();
				}
				else
				{
					spell_cast(this.goalentity, this.gotstuff);
					end_hunt();
				}
			}
			else if (!(this.owner.button3))
			{
				if (this.daze_time > time)
				{
					if (this.pausetime < time)
						this.fade = this.fade - 15 + random() * 30;
					if (this.fade < -90)
						this.fade = -90;
					else if (this.fade > 90)
						this.fade = 90;
					if (!moveit(vectoyaw(org - this.origin) - this.fade, 0))
						end_hunt();
					else
						this.dbltime = 0;
				}
				else
				{
					if(!moveit(vectoyaw(org - this.origin), this.menu))
						end_hunt();
					else
						this.dbltime = 0;
				}
			}
			else
			{
				face(0);
				end_hunt();
			}
		}

	}
	else if (this.m_subject)
	{
		this.frame = 0;
		if (this.m_subject.owner.m_subject != this)
			this.m_subject = NULL;
		this.angles_y = vectoyaw(this.m_subject.origin - this.origin);
	}
	else if (this.ai)
	{
		handle_ai();
	}
	else if (this.dbltime)
	{
		if (this.pausetime < time)
		{
			CycleFrames(this.attackframes+1, this.poseframes);
			this.pausetime = time + 0.1 * (1/this.cold_factor);
		}
	}
	else if (this.classname != "dummy")
	{
		// to lessen the load, standing monsters have have less frequent thinks
		// until they aren't standing :)
		this.nextthink = time + 0.5 + random();
		this.frame = 0;
	}
	else
		this.frame = 0;
	
	updatevwep();
	updateskins();
	
	if (this.classname == "dummy" || this.classname == "helper")
	{
		t = find(NULL, classname, "helper");
		while(t)
		{
			t.solid = SOLID_BBOX;
			setorigin(t, t.origin);
			t = find(t, classname, "helper");
		}
	}
}
