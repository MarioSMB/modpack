void() rq_questlog =
{

	if (rq_iscomplete())
	{
		mstring_add("Return to ");
		mstring_add(rq_npcname(rq_vars_z & 63));
		mstring_add(" for a reward\n");
	}
	else 
	{
		if (rndquest_x == 1)
		{
			mstring_add(rq1_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq1_qb);
		}
		else if (rndquest_x == 2)
		{
			mstring_add(rq2_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq2_qb);
		}
		else if (rndquest_x == 3)
		{
			mstring_add(rq3_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq3_qb);
		}
		else if (rndquest_x == 4)
		{
			mstring_add(rq4_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq4_qb);
		}
		else if (rndquest_x == 5)
		{
			mstring_add(rq5_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq5_qb);
		}
		else if (rndquest_x == 6)
		{
			mstring_add(rq6_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq6_qb);
		}
		else if (rndquest_x == 7)
		{
			mstring_add(rq7_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq7_qb);
		}
		else if (rndquest_x == 8)
		{
			mstring_add(rq8_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq8_qb);
		}
		else if (rndquest_x == 9)
		{
			mstring_add(rq9_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq9_qb);
		}
		else if (rndquest_x == 10)
		{
			mstring_add(rq10_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq10_qb);
		}
		else if (rndquest_x == 11)
		{
			mstring_add(rq11_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq11_qb);
		}
		else if (rndquest_x == 12)
		{
			mstring_add(rq12_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq12_qb);
		}
		else if (rndquest_x == 13)
		{
			mstring_add(rq13_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq13_qb);
		}
		else if (rndquest_x == 14)
		{
			mstring_add(rq14_qa);
			mstring_add(getmapname(rndquest_y));
			mstring_add(rq14_qb);
		}
	}

};
