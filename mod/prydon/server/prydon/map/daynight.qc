nosave float hour, day, night, lasthour;

float TIME_MULTIPLIER = 2;
void() set_tod =
{
	float t;
	t = floor((time + runtime) * TIME_MULTIPLIER);
	
	hour = floor(mod(t/60, 24));
	day = floor(t/1440);
};
string(float p) lightlev =
{
	if (p <= 0)
		return "b";
	if (p > 12)
		return "b";

	else if (p == 1)
		return "b";
	else if (p == 2)
		return "c";
	else if (p == 3)
		return "d";
	else if (p == 4)
		return "e";
	else if (p == 5)
		return "f";
	else if (p == 6)
		return "g";
	else if (p == 7)
		return "h";
	else if (p == 8)
		return "i";		
	else if (p == 9)
		return "j";
	else if (p == 10)
		return "k";
	else if (p == 11)
		return "l";
	else if (p == 12)
		return "m";
};

void() QueryDayNight =
{
	set_tod();
	if ((hour < 6) || (hour > 19))
	{
		if (night != 1)
		{
			night = 1;
			lightstyle(13, "m");
		}
	}
	else
	{
		if (night)
		{
			night = 0;
			lightstyle(13, "a");
		}
	}
	if (hour != lasthour)
	{
		if (hour > 12)
			lightstyle(12, lightlev(24 - hour));
		else
			lightstyle(12, lightlev(hour));
		lasthour = hour;
	}
	
}