float(float val) rank =
{

	return floor(val / 15);
};

nosave float rank_s, rank_d, rank_a, rank_m, rank_l, rank_v, rank_total;

// this speeds things up, only setting when we need it (a lot like itemstat)
// could be even faster by making these fields
void(entity e) set_ranks =
{
	rank_s = rank(e.str);
	rank_d = rank(e.dex);
	rank_a = rank(e.agil);
	rank_m = rank(e.mag);
	rank_l = rank(e.luck);
	rank_v = rank(e.vit);
	rank_total = rank_s + rank_d + rank_a + rank_m + rank_l + rank_v;

}

vector() gettitle =
{
 // for later
	vector ans;
	float s, d, a, m, l, v, div;
	div = floor(rank_total / 4) + 1;
	
	s = floor(rank_s / div) & 3;
	d = floor(rank_d / div) & 3;
	a = floor(rank_a / div) & 3;
	m = floor(rank_m / div) & 3;
	l = floor(rank_l / div) & 3;
	v = floor(rank_v / div) & 3;
	if (div >= 7)
	{
		if (rank_total >= 50)
			ans_x = 6;
		else
			ans_x = 5;
	}
	else
		ans_x = div - 1;
		

	ans_y = s + d * 4 + a * 16 + m * 64 + v * 256 + l * 1024;
	return ans;
	
};


float (.float fld) cost_to_increase =
{
	if (rank_total >= 50)
		return 255;
	else if ((float)fld == (float)str)
		return 1 + floor((rank_m + rank_a + rank_l/2) / 2);
	else if ((float)fld == (float)dex)
		return 1 + floor((rank_m + rank_l + rank_v/2) / 2);
	else if ((float)fld == (float)agil)
		return 1 + floor((rank_s + rank_v + rank_m/2) / 2);
	else if ((float)fld == (float)mag)
		return 1 + floor((rank_s + rank_d + rank_v/2) / 2);
	else if ((float)fld == (float)vit)
		return 1 + floor((rank_m + rank_d + rank_a/2) / 2);
	else if ((float)fld == (float)luck)
		return 1 + floor((rank_s + rank_m + rank_d/2) / 2);
	
};


void() titleupdate =
{
	vector t;
	
	set_ranks(self);
	
	t = gettitle();

	if (t != self.title)
	{
		TitleStat(self.title);
		UseItem(-1);
		TitleStat(t);
		UseItem(1);

		if (self.title != '0 0 -1')
		{
			// DON'T KEEP TELLING ME THIS.
			if ((self.flags & FL_CLIENT) || ((self.ai & AI_FOLLOW) && self.classname != "helper"))
			{
	
				bprint(self.netname);
				bprint(" has recieved the title ");
				BprintClass(t);
				bprint("\n");
			}
		}
		self.title = t;
	}
};
