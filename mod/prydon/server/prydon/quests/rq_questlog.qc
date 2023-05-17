#include "rq_questlog.qh"

#include "maplist.qh"
#include "rq_npcs.qh"
#include "rq_subs.qh"

void rq_questlog(entity this)
{
	if(rq_iscomplete())
	{
		mstring_add(this, "Return to ");
		mstring_add(this, rq_npcname(rq_vars_z & 63));
		mstring_add(this, " for a reward\n");
	}
	else 
	{
		if(rndquest_x == 1)
		{
			mstring_add(this, rq1_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq1_qb);
		}
		else if(rndquest_x == 2)
		{
			mstring_add(this, rq2_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq2_qb);
		}
		else if(rndquest_x == 3)
		{
			mstring_add(this, rq3_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq3_qb);
		}
		else if(rndquest_x == 4)
		{
			mstring_add(this, rq4_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq4_qb);
		}
		else if(rndquest_x == 5)
		{
			mstring_add(this, rq5_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq5_qb);
		}
		else if(rndquest_x == 6)
		{
			mstring_add(this, rq6_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq6_qb);
		}
		else if(rndquest_x == 7)
		{
			mstring_add(this, rq7_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq7_qb);
		}
		else if(rndquest_x == 8)
		{
			mstring_add(this, rq8_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq8_qb);
		}
		else if(rndquest_x == 9)
		{
			mstring_add(this, rq9_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq9_qb);
		}
		else if(rndquest_x == 10)
		{
			mstring_add(this, rq10_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq10_qb);
		}
		else if(rndquest_x == 11)
		{
			mstring_add(this, rq11_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq11_qb);
		}
		else if(rndquest_x == 12)
		{
			mstring_add(this, rq12_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq12_qb);
		}
		else if(rndquest_x == 13)
		{
			mstring_add(this, rq13_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq13_qb);
		}
		else if(rndquest_x == 14)
		{
			mstring_add(this, rq14_qa);
			mstring_add(this, getmapname(rndquest_y));
			mstring_add(this, rq14_qb);
		}
	}
}
