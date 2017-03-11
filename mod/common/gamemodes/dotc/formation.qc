#if 0
void dotc_setformation_broad(entity this)
{
	int fx = -floor(this.cnt / 2);
	IL_EACH(g_dotc_drones, it.squad == this,
	{
		++fx;
		it.dotc_formation_ofs_z = 0;
		it.dotc_formation_ofs_y = 0;
		it.dotc_formation_ofs_x = fx * formation_offset1;
	});	
}

void dotc_setformation_line(entity this)
{
	int fy = 0;
	IL_EACH(g_dotc_drones, it.squad == this,
	{
		++fy;
		it.dotc_formation_ofs = vec3(0, fy * formation_offset1, 0);
	});
}

void dotc_setformation_box(entity this)
{
	LOG_DEBUG("dotc_setformation_box not implemented.\n");
}

void dotc_setformation_wedge(entity this)
{
	int numdrones = 0;
	IL_EACH(g_dotc_drones, it.squad == this,
	{
		++numdrones;
	});

	if(!numdrones)
		return;

	if(numdrones == 1)
	{
		IL_EACH(g_dotc_drones, it.squad == this,
		{
			it.dotc_formation_ofs = '0 0 0';
			return;
		});
	}

	int line = 1;
	IL_EACH(g_dotc_drones, it.squad == this,
	{
		float xo = 0.5 * line * -formation_offset1;
		float yo = line * -formation_offset1;
		for(int fx = 0; fx <= line; ++fx)
		{
			it.dotc_formation_ofs_x = xo + fx * formation_offset1;
			it.dotc_formation_ofs_y = yo;
			it.dotc_formation_ofs_z = 0;
		}

		++line;
	});
}
#endif

void dotc_formation_force(entity this)
{
	vector vang = vectoangles(v_forward);

	IL_EACH(g_dotc_drones, it.squad == this,
	{		
		vector pos = this.origin + (it.dotc_formation_ofs_x * v_right) + (it.dotc_formation_ofs_y * v_forward);
		setorigin(it, pos);
		it.pos1 = pos;
		it.angles = vang;
	});
}
