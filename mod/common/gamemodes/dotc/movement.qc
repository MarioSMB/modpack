const float dotc_movestep_size = 128;
bool dotc_isblocked(entity this)
{
	tracebox(this.origin, this.mins, this.maxs, this.origin + v_forward * dotc_movestep_size, MOVE_NORMAL, this);
	if(trace_fraction != 1.0)
		return true;
	
	return false;
}

int dotc_movestep_blocked;
vector dotc_movestep(entity this, vector v_target)
{
	vector v_test, v_best = nil;
	float  d_test = 0, d_best;
	
	d_best = MAX_SHOT_DISTANCE;
	
	dotc_movestep_blocked = 0;
	fixedmakevectors(this.angles);
	if(dotc_isblocked(this))
	{
		dotc_movestep_blocked = 1;
		// Forward-right
		v_test = this.origin + v_forward * dotc_movestep_size + v_right * dotc_movestep_size;		
		tracebox(this.origin, this.mins, this.maxs, v_test, MOVE_NORMAL, this);
		//te_lightning1(world, this.origin, v_test);
		if(trace_fraction == 1.0)
		{
			d_test = vlen(v_test - v_target);
			if(d_test < d_best)
			{
				v_best = v_test; 
				d_best = d_test;
			}
		}
		
		//Forward-left
		v_test = this.origin + v_forward * dotc_movestep_size - v_right * dotc_movestep_size;
		tracebox(this.origin, this.mins, this.maxs, v_test, MOVE_NORMAL, this);
		//te_lightning1(world, this.origin, v_test);
		if(trace_fraction == 1.0)
		{
			d_test = vlen(v_test - v_target);
			if(d_test < d_best)
			{
				v_best = v_test; 
				d_best = d_test;
			}
		}

		//Right
		v_test = this.origin + v_right * dotc_movestep_size;
		tracebox(this.origin, this.mins, this.maxs, v_test, MOVE_NORMAL, this);
		//te_lightning1(world, this.origin, v_test);
		if(trace_fraction == 1.0)
		{
			d_test = vlen(v_test - v_target);
			if(d_test < d_best)
			{
				v_best = v_test; 
				d_best = d_test;
			}
		}
		
		//Left
		v_test = this.origin - v_right * dotc_movestep_size;
		tracebox(this.origin, this.mins, this.maxs, v_test, MOVE_NORMAL, this);
		//te_lightning1(world, this.origin, v_test);
		if(trace_fraction == 1.0)
		{
			d_test = vlen(v_test - v_target);
			if(d_test < d_best)
			{
				v_best = v_test; 
				d_best = d_test;
			}
		}
		
		if(d_test != MAX_SHOT_DISTANCE)
		{
			te_lightning1(world, this.origin, v_best);	
			te_lightning1(world, this.origin, v_target);	
			return v_best;
		}
		
		dotc_movestep_blocked = 2;
		return this.origin;
	}
	else
		return v_target;
}
