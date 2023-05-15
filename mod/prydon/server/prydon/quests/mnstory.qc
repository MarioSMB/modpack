nosave var string q_0 = "\bFind Ariana in Pendinas, South of\nCapel Curig, and bring her to safety.\b\n\n";
nosave var string q_1 = "\bFind Cornan in the sewers.\b\n\n";
nosave var string q_2 = "\bFind the source of the\ninfestation in the sewers and\neliminate it.\b\n\n";
nosave var string q_3 = "\bFind Ariana in Pendinas, South of\nCapel Curig, and bring her to safety.\b\n\n";
nosave var string q_4 = "\bAsk Sadoc about the strange barrier.\b\n\n";
nosave var string q_5 = "\bLocate the hermit Idris in the\nSnowdon mountains.\b\n\n";
nosave var string q_6 = "\bFind Idris's spell book in the\nmines and return it.\b";
nosave var string q_7 = "\bFind Ariana in Pendinas, South of\nCapel Curig, and bring her to safety.\b\n\n";
nosave var string q_8 = "\bEliminate the troops occupying Pendinas.\b\n\n";
nosave var string q_9 = "\bSeek revenge on the Circle of Mages\nhiding in crypts below the Pendinas chapel.\b\n\n";
nosave var string q_10 = "\bJourney to Castle Bere.\b\n\n";
nosave var string q_11 = "\bKill the abomination that was\nonce your father.\b\n\n";
nosave var string q_12 = "\bPass through the Prydon Gate.\b\n\n";
nosave var string q_13 = "\bFind Ariana's soul in Hades.\b\n\n";
nosave var string q_14 = "\bDestroy Thanatos.\b\n\n";
nosave var string q_15;

string(float n) mainstorystring =
{
	if (n == 0)
		return q_0;
	else if (n == 1)
		return q_1;
	else if (n == 2)
		return q_2;
	else if (n == 3)
		return q_3;
	else if (n == 4)
		return q_4;
	else if (n == 5)
		return q_5;
	else if (n == 6)
		return q_6;
	else if (n == 7)
		return q_7;
	else if (n == 8)
		return q_8;
	else if (n == 9)
		return q_9;
	else if (n == 10)
		return q_10;
	else if (n == 11)
		return q_11;
	else if (n == 12)
		return q_12;
	else if (n == 13)
		return q_13;
	else if (n == 14)
		return q_14;
	else if (n == 15)
		return q_15;
};