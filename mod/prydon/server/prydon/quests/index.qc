
void(string s, float lv) SetOldStory =
{
	if (s == "main")
		mainstory = lv;
	else if (s == "opt1")
		opt1 = lv;
	else if (s == "opt2")
		opt2 = lv;
	else if (s == "opt3")
		opt3 = lv;
	else if (s == "opt4")
		opt4 = lv;
	else if (s == "opt5")
		opt5 = lv;
	else if (s == "opt6")
		opt6 = lv;
};

float (string s, float f) GetOldStory =
{
	if (s == "main")
		return mainstory;
	else if (s == "opt1")
		return opt1;
	else if (s == "opt2")
		return opt2;
	else if (s == "opt3")
		return opt3;	
	else if (s == "opt4")
		return opt4;
	else if (s == "opt5")
		return opt5;
	else if (s == "opt6")
		return opt6;
	else
		return f;
		
};
