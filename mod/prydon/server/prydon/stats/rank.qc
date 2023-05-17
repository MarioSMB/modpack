#include "rank.qh"

float rank(float val)
{
	return floor(val / 15);
}

float rank_s = 0, rank_d = 0, rank_a = 0, rank_m = 0, rank_l = 0, rank_v = 0, rank_total = 0;

// this speeds things up, only setting when we need it (a lot like itemstat)
// could be even faster by making these fields
void set_ranks(entity e)
{
	rank_s = rank(e.str);
	rank_d = rank(e.dex);
	rank_a = rank(e.agil);
	rank_m = rank(e.mag);
	rank_l = rank(e.luck);
	rank_v = rank(e.vit);
	rank_total = rank_s + rank_d + rank_a + rank_m + rank_l + rank_v;

}

vector gettitle()
{
 // for later
	vector ans = '0 0 0';
	float div = floor(rank_total / 4) + 1;
	
	float s = floor(rank_s / div) & 3;
	float d = floor(rank_d / div) & 3;
	float a = floor(rank_a / div) & 3;
	float m = floor(rank_m / div) & 3;
	float l = floor(rank_l / div) & 3;
	float v = floor(rank_v / div) & 3;
	if(div >= 7)
	{
		if(rank_total >= 50)
			ans.x = 6;
		else
			ans.x = 5;
	}
	else
		ans.x = div - 1;
		

	ans.y = s + d * 4 + a * 16 + m * 64 + v * 256 + l * 1024;
	return ans;
	
}

float cost_to_increase(.float fld)
{
	if(rank_total >= 50)
		return 255;
	else if(fld == str)
		return 1 + floor((rank_m + rank_a + rank_l/2) / 2);
	else if(fld == dex)
		return 1 + floor((rank_m + rank_l + rank_v/2) / 2);
	else if(fld == agil)
		return 1 + floor((rank_s + rank_v + rank_m/2) / 2);
	else if(fld == mag)
		return 1 + floor((rank_s + rank_d + rank_v/2) / 2);
	else if(fld == vit)
		return 1 + floor((rank_m + rank_d + rank_a/2) / 2);
	else if(fld == luck)
		return 1 + floor((rank_s + rank_m + rank_d/2) / 2);
	return 0;
}

void titleupdate(entity this)
{
	set_ranks(this);
	
	vector t = gettitle();

	if(t != this.title)
	{
		TitleStat(this.title);
		UseItem(this, -1);
		TitleStat(t);
		UseItem(this, 1);

		if(this.title != '0 0 -1')
		{
			// DON'T KEEP TELLING ME THIS.
			if(IS_CLIENT(this) || ((this.ai & AI_FOLLOW) && this.classname != "helper"))
			{
	
				bprint(this.netname);
				bprint(" has recieved the title ");
				BprintClass(t);
				bprint("\n");
			}
		}
		this.title = t;
	}
}
