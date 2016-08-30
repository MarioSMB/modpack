#ifdef SVQC

const int GUARD_ANIM_IDLE =  1;
const int GUARD_ANIM_WALK =  2;
const int GUARD_ANIM_TURN =  2;
const int GUARD_ANIM_SHOOT = 3;
const int GUARD_ANIM_DIE1 =  4;
const int GUARD_ANIM_DIE2 =  4;

/*
1 3 1 0 // guardian_legs idle
4 41 30 1 // guardian_legs walk
45 6 30 0 // guardian_legs shot
51 121 30 0 // guardian_legs death
172 3 1 0 // guardian_legs idle
175 3 1 0 // guardian_legs idle
178 3 1 0 // guardian_legs idle
181 3 1 0 // guardian_legs idle
*/

.entity grd_railgun;
.entity grd_blaster;
.entity grd_torso;

.vector moveto;


entity dotc_guardian_addpart(entity this, string s_bone, Model s_model, entity e_to)
{
	entity prt;
	prt 			= spawn();
	prt.owner 		= this;
	prt.colormap 	= this.colormap;

	setmodel(prt, s_model);
	setattachment(prt, e_to, s_bone);

	return prt;
}

vector dotc_guardian_stepto(entity this, vector v_target)
{
	vector v_step, v_dir;
	fixedmakevectors(this.angles);

	v_dir = v_forward;
	//v_dir_z = 0; // never pich/roll.
	//v_dir_x = 0; // never pich/roll.
	v_step = this.origin + v_dir * 160;

	tracebox(this.origin, this.mins, this.maxs, v_step, MOVE_NORMAL, this);
	//te_lightning1(NULL, this.origin, v_step);

	//We can fir the whole bbox at least  160 units ahead, no need to do anything fancy.
	if(trace_fraction == 1.0)
	{
		return v_step;
	}
	else
	{
		vector v_step_r, v_step_l;
		float f_step_r, f_step_l;

		v_step_r = (v_forward * 160) + (v_right * 80) + this.origin;
		tracebox(this.origin, this.mins, this.maxs, v_step_r, MOVE_NORMAL, this);
		f_step_r = trace_fraction;
		te_lightning1(NULL, this.origin, v_step_r);
		//GUARDIAN_CRUSHIT // If a enemy player is blocking us, chaneg behaviour and step on the basterd :P
		
		v_step_l = (v_forward * 160) - (v_right * 80) + this.origin;
		tracebox(this.origin, this.mins, this.maxs, v_step_l, MOVE_NORMAL, this);
		f_step_l = trace_fraction;
		te_lightning1(NULL, this.origin, v_step_l);		

		// Both angled steps free, select the one closer to goal (this.moveto)
		if(f_step_l + f_step_r == 2.0)
		{
			f_step_l = vlen(this.moveto - v_step_l);
			f_step_r = vlen(this.moveto - v_step_r);
			if(f_step_l <= f_step_r)
				return v_step_l;
			else
				return v_step_r;
		}
		else
		{
			// Left step free?
			if(f_step_l == 1.0)
				return v_step_l;

			// Right step free?
			if(f_step_r == 1.0)
				return v_step_r;

			// NO free step, trace wider.
			v_step_r = (v_right * 160) + this.origin;
			tracebox(this.origin, this.mins, this.maxs, v_step_r, MOVE_NORMAL, this);
			f_step_r = trace_fraction;
			te_lightning1(NULL, this.origin, v_step_r);

			v_step_l = (v_right * -160) + this.origin;
			tracebox(this.origin, this.mins, this.maxs, v_step_l, MOVE_NORMAL, this);
			f_step_l = trace_fraction;
			te_lightning1(NULL, this.origin, v_step_l);

			// no free step ar all
			if(f_step_l != 1.0 && f_step_r != 1.0)
			{
				// Indicate wer stuck
				return '0 0 0';
			}
			
			// Both steps valid, take the shorter path.
			if(f_step_l + f_step_r == 2)
			{
				f_step_l = vlen(this.moveto - v_step_l);
				f_step_r = vlen(this.moveto - v_step_r);
				if(f_step_l <= f_step_r)
					return v_step_l;
				else
					return v_step_r;
			}
			
			// Left step free?
			if(f_step_l == 1.0)
				return v_step_l;

			// Right step free?
			if(f_step_r == 1.0)
				return v_step_r;
		}
	}
	
	dprint("Once I saw a drunk crow. Fascinating!\n");
	return '0 0 0'; // this point should never be reached..
}

void dotc_guardian_think_idle(entity this)
{
	this.nextthink = time + 0.1;
	if(!round_handler_IsRoundStarted())
		return;
	fixedmakevectors(this.angles);
	this.moveto = dotc_guardian_stepto(this, '0 0 0');
	// Stuck?
	if(this.moveto == '0 0 0')
		dprint("Bwaaaaa aaaa *sob*\n");
	else
	{
		vector m_angle;
		this.steerto = normalize(this.moveto - this.origin);
		m_angle = dotc_ai_moveangle(this, '0 0 0', vectoangles(normalize(this.squad.enemy.origin - this.origin)) , '360 360 360');		
		this.avelocity_y = bound(this.dotc_turnspeed * -1, m_angle_y, this.dotc_turnspeed);

		//te_lightning1(NULL, this.origin + '0 0 90', this.moveto + '0 0 90');		
		//te_lightning1(NULL, this.origin + '0 0 90', this.origin + this.steerto * 512 + '0 0 190');
	}
		

	this.tur_shotorg = gettaginfo(this.grd_railgun, gettagindex(this.grd_railgun, "firerail01"));
	//te_lightning1(NULL,this.tur_shotorg, this.tur_shotorg + v_forward * 256);
	// dprint("moonbase say:", ftos(autocvar_dotc_guardian_test), "\n");

	CSQCMODEL_AUTOUPDATE(this);
}


spawnfunc(dotc_guardian)
{
	if(!g_dotc) { delete(this); return; }

	this.solid 			= SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_WALK);
	this.takedamage 	= DAMAGE_AIM;
	this.deadflag 		= DEAD_NO;
	this.dotc_unittype = DOTC_UF_GUARDIAN;
	this.colormap 		= 1024 + (this.team - 1) * 17;
	this.netname 		= "Guardian";
	this.dotc_turnspeed = 180; // FIXME unhardcode >.<
	
	setmodel(this, MDL_DOTC_GUARDIAN_LEGS);
	this.grd_torso   = dotc_guardian_addpart(this, "torso", MDL_DOTC_GUARDIAN_BODY, this);
	this.grd_railgun = dotc_guardian_addpart(this, "turret01", MDL_DOTC_GUARDIAN_RAIL, this.grd_torso);
	this.grd_blaster = dotc_guardian_addpart(this, "turret02", MDL_DOTC_GUARDIAN_PLASMA, this.grd_torso);

	setsize(this, '-80 -80 0', '80 80 180');

	this.nextthink = time + 1;
	setthink(this, dotc_guardian_think_idle);

	CSQCMODEL_AUTOINIT(this);
}

#endif
