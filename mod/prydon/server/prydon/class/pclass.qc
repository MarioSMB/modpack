
void(vector cl) PrintClass =
{
	if (cl_x == 1)
	{
		p8('E', 'x', 'p', 'e', 'r', 'i', 'e', 'n');
		p4('c', 'e', 'd', ' ');
	}
	else if (cl_x == 2)
	{
		p8('C', 'h', 'a', 'm', 'p', 'i', 'o', 'n');
		p1(' ');
	}
	else if (cl_x == 3)
		p8('V', 'e', 't', 'e', 'r', 'a', 'n', ' ');
	else if (cl_x == 4)
		p7('M', 'a', 's', 't', 'e', 'r', ' ');
	else if (cl_x == 5)
	{
		p8('L', 'e', 'g', 'e', 'n', 'd', 'a', 'r');
		p2('y', ' ');
	}
	else if (cl_x == 6)
	{
		p8('G', 'o', 'd', 'l', 'i', 'k', 'e', ' ');
	
	}
	if (cl_y == CL_ADVENTURER)
	{
		p8('A', 'd', 'v', 'e', 'n', 't', 'u', 'r');
		p2('e', 'r');
	}
	else if (cl_y == CL_FIGHTER)
		p7('F', 'i', 'g', 'h', 't', 'e', 'r');
	else if (cl_y == CL_BRAWLER)
		p7('B', 'r', 'a', 'w', 'l', 'e', 'r');
	else if (cl_y == CL_BRUTE)
		p5('B', 'r', 'u', 't', 'e');
	else if (cl_y == CL_SLAYER)
		p6('S', 'l', 'a', 'y', 'e', 'r');
	else if (cl_y == CL_WARRIOR)
		p7('W', 'a', 'r', 'r', 'i', 'o', 'r');
	else if (cl_y == CL_KNIGHT)
		p6('K', 'n', 'i', 'g', 'h', 't');
	else if (cl_y == CL_HUNTSMAN)
		p8('H', 'u', 'n', 't', 's', 'm', 'a', 'n');
	else if (cl_y == CL_ARCHER)
		p6('A', 'r', 'c', 'h', 'e', 'r');
	else if (cl_y == CL_RANGER)
		p6('R', 'a', 'n', 'g', 'e', 'r');
	else if (cl_y == CL_SPRINTER)
		p8('S', 'p', 'r', 'i', 'n', 't', 'e', 'r');
	else if (cl_y == CL_COURIER)
		p7('C', 'o', 'u', 'r', 'i', 'e', 'r');
	else if (cl_y == CL_STALKER)
		p7('S', 't', 'a', 'l', 'k', 'e', 'r');
	else if (cl_y == CL_ROBBER)
		p6('R', 'o', 'b', 'b', 'e', 'r');
	else if (cl_y == CL_ATHLETE)
		p7('A', 't', 'h', 'l', 'e', 't', 'e');
	else if (cl_y == CL_ASSASSIN)
		p8('A', 's', 's', 'a', 's', 's', 'i', 'n');
	else if (cl_y == CL_LOOKOUT)
		p7('L', 'o', 'o', 'k', 'o', 'u', 't');
	else if (cl_y == CL_MOUNTAINEER)
	{
		p8('M', 'o', 'u', 'n', 't', 'a', 'i', 'n');
		p3('e', 'e', 'r');
	}
	else if (cl_y == CL_WATCHMAN)
		p8('W', 'a', 't', 'c', 'h', 'm', 'a', 'n');
	else if (cl_y == CL_SCOUT)
		p5('S', 'c', 'o', 'u', 't');
	else if (cl_y == CL_NEOPHYTE)
		p8('N', 'e', 'o', 'p', 'h', 'y', 't', 'e');
	else if (cl_y == CL_MONK)
		p4('M', 'o', 'n', 'k');
	else if (cl_y == CL_PALADIN)
		p7('P', 'a', 'l', 'a', 'd', 'i', 'n');
	else if (cl_y == CL_MAGESLAYER)
	{
		p8('M', 'a', 'g', 'e', 's', 'l', 'a', 'y');
		p2('e', 'r');
	}
	else if (cl_y == CL_AVENGER)
		p7('A', 'v', 'e', 'n', 'g', 'e', 'r');
	else if (cl_y == CL_FLETCHER)
		p8('F', 'l', 'e', 't', 'c', 'h', 'e', 'r');
	else if (cl_y == CL_SWASHBUCKLER)
	{
		p8('S', 'w', 'a', 's', 'h', 'b', 'u', 'c');
		p4('k', 'l', 'e', 'r');
	}
	else if (cl_y == CL_HARBINGER)
	{
		p8('H', 'a', 'r', 'b', 'i', 'n', 'g', 'e');
		p1('r');
	}
	else if (cl_y == CL_EXPLORER)
		p8('E', 'x', 'p', 'l', 'o', 'r', 'e', 'r');
	else if (cl_y == CL_DESPERADO)
	{
		p8('D', 'e', 's', 'p', 'e', 'r', 'a', 'd');
		p1('o');
	}
	else if (cl_y == CL_MAGE)
		p4('M', 'a', 'g', 'e');
	else if (cl_y == CL_THEURGIST)
	{
		p8('T', 'h', 'e', 'u', 'r', 'g', 'i', 's');
		p1('t');
	}
	else if (cl_y == CL_BARD)
		p4('B', 'a', 'r', 'd');
	else if (cl_y == CL_DRUID)
		p5('D', 'r', 'u', 'i', 'd');
	else if (cl_y == CL_WIZARD)
		p6('W', 'i', 'z', 'a', 'r', 'd');
	else if (cl_y == CL_OUTLANDER)
	{
		p8('O', 'u', 't', 'l', 'a', 'n', 'd', 'e');
		p1('r');
	}
	else if (cl_y == CL_GLADIATOR)
	{
		p8('G', 'l', 'a', 'd', 'i', 'a', 't', 'o');
		p1('r');
	}
	else if (cl_y == CL_BARBARIAN)
	{
		p8('B', 'a', 'r', 'b', 'a', 'r', 'i', 'a');
		p1('n');
	}
	else if (cl_y == CL_MAVERICK)
		p8('M', 'a', 'v', 'e', 'r', 'i', 'c', 'k');
	else if (cl_y == CL_SOLDIER)
		p7('S', 'o', 'l', 'd', 'i', 'e', 'r');
	else if (cl_y == CL_COUNTRYMAN)
	{
		p8('C', 'o', 'u', 'n', 't', 'r', 'y', 'm');
		p2('a', 'n');
	}
	else if (cl_y == CL_PIRATE)
		p6('P', 'i', 'r', 'a', 't', 'e');
	else if (cl_y == CL_PIONEER)
		p7('P', 'i', 'o', 'n', 'e', 'e', 'r');
	else if (cl_y == CL_WANDERER)
		p8('W', 'a', 'n', 'd', 'e', 'r', 'e', 'r');
	else if (cl_y == CL_MARAUDER)
		p8('M', 'a', 'r', 'a', 'u', 'd', 'e', 'r');
	else if (cl_y == CL_HERETIC)
		p7('H', 'e', 'r', 'e', 't', 'i', 'c');
	else if (cl_y == CL_TROOPER)
		p7('T', 'r', 'o', 'o', 'p', 'e', 'r');
	else if (cl_y == CL_SEER)
		p4('S', 'e', 'e', 'r');
	else if (cl_y == CL_HOOLIGAN)
		p8('H', 'o', 'o', 'l', 'i', 'g', 'a', 'n');
	else if (cl_y == CL_ARCHMAGE)
		p8('A', 'r', 'c', 'h', 'm', 'a', 'g', 'e');
	else if (cl_y == CL_TRAVELER)
		p8('T', 'r', 'a', 'v', 'e', 'l', 'e', 'r');
	else if (cl_y == CL_REAVER)
		p6('R', 'e', 'a', 'v', 'e', 'r');
	else if (cl_y == CL_WOODSMAN)
		p8('W', 'o', 'o', 'd', 's', 'm', 'a', 'n');
	else if (cl_y == CL_CORSAIR)
		p7('C', 'o', 'r', 's', 'a', 'i', 'r');
	else if (cl_y == CL_SEEKER)
		p6('S', 'e', 'e', 'k', 'e', 'r');
	else if (cl_y == CL_JOURNEYMAN)
	{
		p8('J', 'o', 'u', 'r', 'n', 'e', 'y', 'm');
		p2('a', 'n');
	}
	else if (cl_y == CL_GAMESTER)
		p8('G', 'a', 'm', 'e', 's', 't', 'e', 'r');
	else if (cl_y == CL_SCOUNDREL)
	{
		p8('S', 'c', 'o', 'u', 'n', 'd', 'r', 'e');
		p1('l');
	}
	else if (cl_y == CL_MERCENARY)
	{
		p8('M', 'e', 'r', 'c', 'e', 'n', 'a', 'r');
		p1('y');
	}
	else if (cl_y == CL_THIEF)
		p5('T', 'h', 'i', 'e', 'f');
	else if (cl_y == CL_CONQUEROR)
	{
		p8('C', 'o', 'n', 'q', 'u', 'e', 'r', 'o');
		p1('r');
	}
	else if (cl_y == CL_ROGUE)
		p5('R', 'o', 'g', 'u', 'e');
	else if (cl_y == CL_BURGLAR)
		p7('B', 'u', 'r', 'g', 'l', 'a', 'r');
	else if (cl_y == CL_DRIFTER)
		p7('D', 'r', 'i', 'f', 't', 'e', 'r');
	else if (cl_y == CL_MUGGER)
		p6('M', 'u', 'g', 'g', 'e', 'r');
	else if (cl_y == CL_CUTTHROAT)
	{
		p8('C', 'u', 't', 't', 'h', 'r', 'o', 'a');
		p1('t');
	}
	else if (cl_y == CL_TRICKSTER)
	{
		p8('T', 'r', 'i', 'c', 'k', 's', 't', 'e');
		p1('r');
	}
	else if (cl_y == CL_WAYFARER)
		p8('W', 'a', 'y', 'f', 'a', 'r', 'e', 'r');
	else if (cl_y == CL_STEWARD)
		p7('S', 't', 'e', 'w', 'a', 'r', 'd');
	else if (cl_y == CL_CHARMER)
		p7('C', 'h', 'a', 'r', 'm', 'e', 'r');
	else if (cl_y == CL_DIVINER)
		p7('D', 'i', 'v', 'i', 'n', 'e', 'r');
	else if (cl_y == CL_RUFFIAN)
		p7('R', 'u', 'f', 'f', 'i', 'a', 'n');
	else if (cl_y == CL_DEFENDER)
		p8('D', 'e', 'f', 'e', 'n', 'd', 'e', 'r');
	else if (cl_y == CL_OUTLAW)
		p6('O', 'u', 't', 'l', 'a', 'w');
	else if (cl_y == CL_BANDIT)
		p6('B', 'a', 'n', 'd', 'i', 't');
	else if (cl_y == CL_DIABOLIST)
	{
		p8('D', 'i', 'a', 'b', 'o', 'l', 'i', 's');
		p1('t');
	}
	else if (cl_y == CL_VIKING)
		p6('V', 'i', 'k', 'i', 'n', 'g');
	else if (cl_y == CL_GAMBLER)
		p7('G', 'a', 'm', 'b', 'l', 'e', 'r');
	else if (cl_y == CL_VANDAL)
		p6('V', 'a', 'n', 'd', 'a', 'l');
	else if (cl_y == CL_PICKPOCKET)
	{
		p8('P', 'i', 'c', 'k', 'p', 'o', 'c', 'k');
		p2('e', 't');
	}
	else if (cl_y == CL_LARCENIST)
	{
		p8('L', 'a', 'r', 'c', 'e', 'n', 'i', 's');
		p1('t');
	}
	else if (cl_y == CL_ILLUSIONIST)
	{
		p8('I', 'l', 'l', 'u', 's', 'i', 'o', 'n');
		p3('i', 's', 't');
	}
	else if (cl_y == CL_RAIDER)
		p6('R', 'a', 'i', 'd', 'e', 'r');
	else if (cl_y == CL_CHARLATAN)
	{
		p8('C', 'h', 'a', 'r', 'l', 'a', 't', 'a');
		p1('n');
	}
};
string(vector cl) ClassPreString =
{
	if (cl_x == 1)
		return ("Experienced ");
	else if (cl_x == 2)
		return ("Champion ");
	else if (cl_x == 3)
		return ("Veteran ");
	else if (cl_x == 4)
		return ("Master ");
	else if (cl_x == 5)
		return ("Legendary ");
	else if (cl_x == 6)
		return ("Godlike ");
	else
		return string_null;
};
string(vector cl) ClassString =
{

	if (cl_y == CL_ADVENTURER)
		return ("Adventurer");
	else if (cl_y == CL_FIGHTER)
		return ("Fighter");
	else if (cl_y == CL_BRAWLER)
		return ("Brawler");
	else if (cl_y == CL_BRUTE)
		return ("Brute");
	else if (cl_y == CL_SLAYER)
		return ("Slayer");
	else if (cl_y == CL_WARRIOR)
		return ("Warrior");
	else if (cl_y == CL_KNIGHT)
		return ("Knight");
	else if (cl_y == CL_HUNTSMAN)
		return ("Huntsman");
	else if (cl_y == CL_ARCHER)
		return ("Archer");
	else if (cl_y == CL_RANGER)
		return ("Ranger");
	else if (cl_y == CL_SPRINTER)
		return ("Sprinter");
	else if (cl_y == CL_COURIER)
		return ("Courier");
	else if (cl_y == CL_STALKER)
		return ("Stalker");
	else if (cl_y == CL_ROBBER)
		return ("Robber");
	else if (cl_y == CL_ATHLETE)
		return ("Athlete");
	else if (cl_y == CL_ASSASSIN)
		return ("Assassin");
	else if (cl_y == CL_LOOKOUT)
		return ("Lookout");
	else if (cl_y == CL_MOUNTAINEER)
		return ("Mountaineer");
	else if (cl_y == CL_WATCHMAN)
		return ("Watchman");
	else if (cl_y == CL_SCOUT)
		return ("Scout");
	else if (cl_y == CL_NEOPHYTE)
		return ("Neophyte");
	else if (cl_y == CL_MONK)
		return ("Monk");
	else if (cl_y == CL_PALADIN)
		return ("Paladin");
	else if (cl_y == CL_MAGESLAYER)
		return ("Mageslayer");
	else if (cl_y == CL_AVENGER)
		return ("Avenger");
	else if (cl_y == CL_FLETCHER)
		return ("Fletcher");
	else if (cl_y == CL_SWASHBUCKLER)
		return ("Swashbuckler");
	else if (cl_y == CL_HARBINGER)
		return ("Harbinger");
	else if (cl_y == CL_EXPLORER)
		return ("Explorer");
	else if (cl_y == CL_DESPERADO)
		return ("Desperado");
	else if (cl_y == CL_MAGE)
		return ("Mage");
	else if (cl_y == CL_THEURGIST)
		return ("Theurgist");
	else if (cl_y == CL_BARD)
		return ("Bard");
	else if (cl_y == CL_DRUID)
		return ("Druid");
	else if (cl_y == CL_WIZARD)
		return ("Wizard");
	else if (cl_y == CL_OUTLANDER)
		return ("Outlander");
	else if (cl_y == CL_GLADIATOR)
		return ("Gladiator");
	else if (cl_y == CL_BARBARIAN)
		return ("Barbarian");
	else if (cl_y == CL_MAVERICK)
		return ("Maverick");
	else if (cl_y == CL_SOLDIER)
		return ("Soldier");
	else if (cl_y == CL_COUNTRYMAN)
		return ("Countryman");
	else if (cl_y == CL_PIRATE)
		return ("Pirate");
	else if (cl_y == CL_PIONEER)
		return ("Pioneer");
	else if (cl_y == CL_WANDERER)
		return ("Wanderer");
	else if (cl_y == CL_MARAUDER)
		return ("Marauder");
	else if (cl_y == CL_HERETIC)
		return ("Heretic");
	else if (cl_y == CL_TROOPER)
		return ("Trooper");
	else if (cl_y == CL_SEER)
		return ("Seer");
	else if (cl_y == CL_HOOLIGAN)
		return ("Hooligan");
	else if (cl_y == CL_ARCHMAGE)
		return ("Archmage");
	else if (cl_y == CL_TRAVELER)
		return ("Traveler");
	else if (cl_y == CL_REAVER)
		return ("Reaver");
	else if (cl_y == CL_WOODSMAN)
		return ("Woodsman");
	else if (cl_y == CL_CORSAIR)
		return ("Corsair");
	else if (cl_y == CL_SEEKER)
		return ("Seeker");
	else if (cl_y == CL_JOURNEYMAN)
		return ("Journeyman");
	else if (cl_y == CL_GAMESTER)
		return ("Gamester");
	else if (cl_y == CL_SCOUNDREL)
		return ("Scoundrel");
	else if (cl_y == CL_MERCENARY)
		return ("Mercenary");
	else if (cl_y == CL_THIEF)
		return ("Thief");
	else if (cl_y == CL_CONQUEROR)
		return ("Conqueror");
	else if (cl_y == CL_ROGUE)
		return ("Rogue");
	else if (cl_y == CL_BURGLAR)
		return ("Burglar");
	else if (cl_y == CL_DRIFTER)
		return ("Drifter");
	else if (cl_y == CL_MUGGER)
		return ("Mugger");
	else if (cl_y == CL_CUTTHROAT)
		return ("Cutthroat");
	else if (cl_y == CL_TRICKSTER)
		return ("Trickster");
	else if (cl_y == CL_WAYFARER)
		return ("Wayfarer");
	else if (cl_y == CL_STEWARD)
		return ("Steward");
	else if (cl_y == CL_CHARMER)
		return ("Charmer");
	else if (cl_y == CL_DIVINER)
		return ("Diviner");
	else if (cl_y == CL_RUFFIAN)
		return ("Ruffian");
	else if (cl_y == CL_DEFENDER)
		return ("Defender");
	else if (cl_y == CL_OUTLAW)
		return ("Outlaw");
	else if (cl_y == CL_BANDIT)
		return ("Bandit");
	else if (cl_y == CL_DIABOLIST)
		return ("Diabolist");
	else if (cl_y == CL_VIKING)
		return ("Viking");
	else if (cl_y == CL_GAMBLER)
		return ("Gambler");
	else if (cl_y == CL_VANDAL)
		return ("Vandal");
	else if (cl_y == CL_PICKPOCKET)
		return ("Pickpocket");
	else if (cl_y == CL_LARCENIST)
		return ("Larcenist");
	else if (cl_y == CL_ILLUSIONIST)
		return ("Illusionist");
	else if (cl_y == CL_RAIDER)
		return ("Raider");
	else if (cl_y == CL_CHARLATAN)
		return ("Charlatan");
	else
		return string_null;
};

void(vector cl) BprintClass =
{
	if (cl_x)
		bprint(ClassPreString(cl));
	bprint(ClassString(cl));

};