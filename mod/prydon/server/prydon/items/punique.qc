#include "punique.qh"

void PrintUnique()
{
	if(stat_it == IT_ITHAELS_ROBE)
	{
		p8('I', 't', 'h', 'a', 'e', 'l', 39, 's');
		p5(' ', 'R', 'o', 'b', 'e');
	}
	else if(stat_it == IT_STONEFLESH)
	{
		p8('S', 't', 'o', 'n', 'e', 'f', 'l', 'e');
		p2('s', 'h');
	}
	else if(stat_it == IT_ICEBINK)
		p7('I', 'c', 'e', 'b', 'i', 'n', 'k');
	else if(stat_it == IT_GRUESKIN)
		p8('G', 'r', 'u', 'e', 's', 'k', 'i', 'n');
	else if(stat_it == IT_THE_GUARDIAN)
	{
		p8('T', 'h', 'e', ' ', 'G', 'u', 'a', 'r');
		p4('d', 'i', 'a', 'n');
	}
	else if(stat_it == IT_BLACKMAIL)
		p8('D', 'a', 'r', 'k', 'p', 'e', 'l', 't');
	else if(stat_it == IT_HELLPLATE)
	{
		p8('H', 'e', 'l', 'l', 'p', 'l', 'a', 't');
		p1('e');
	}
	else if(stat_it == IT_SOULSHEATH)
	{
		p8('S', 'o', 'u', 'l', 's', 'h', 'e', 'a');
		p2('t', 'h');
	}
	else if(stat_it == IT_WIZARDSPIKE)
	{
		p8('W', 'i', 'z', 'a', 'r', 'd', 's', 'p');
		p3('i', 'k', 'e');
	}
	else if(stat_it == IT_FINGERBONE)
	{
		p8('F', 'i', 'n', 'g', 'e', 'r', 'b', 'o');
		p2('n', 'e');
	}
	else if(stat_it == IT_THROATSLITTER)
	{
		p8('T', 'h', 'r', 'o', 'a', 't', 's', 'l');
		p5('i', 't', 't', 'e', 'r');
	}
	else if(stat_it == IT_BITTER_SPIKE)
	{
		p8('B', 'i', 't', 't', 'e', 'r', ' ', 'S');
		p4('p', 'i', 'k', 'e');
	}
	else if(stat_it == IT_BRANWENS_BANE)
	{
		p8('B', 'r', 'a', 'n', 'w', 'e', 'n', 39);
		p6('s', ' ', 'B', 'a', 'n', 'e');
	}
	else if(stat_it == IT_BONESCRAPE)
	{
		p8('B', 'o', 'n', 'e', 's', 'c', 'r', 'a');
		p2('p', 'e');
	}
	else if(stat_it == IT_THE_SKEWER_OF_ANTHEG)
	{
		p8('T', 'h', 'e', ' ', 'S', 'k', 'e', 'w');
		p8('e', 'r', ' ', 'o', 'f', ' ', 'A', 'n');
		p4('t', 'h', 'e', 'g');
	}
	else if(stat_it == IT_RIPSAW)
		p6('R', 'i', 'p', 's', 'a', 'w');
	else if(stat_it == IT_DOOMBRINGER)
	{
		p8('D', 'o', 'o', 'm', 'b', 'r', 'i', 'n');
		p3('g', 'e', 'r');
	}
	else if(stat_it == IT_DRAGON_HEWER)
	{
		p8('D', 'r', 'a', 'g', 'o', 'n', ' ', 'H');
		p4('e', 'w', 'e', 'r');
	}
	else if(stat_it == IT_NIGHTCLUB)
	{
		p8('N', 'i', 'g', 'h', 't', 'c', 'l', 'u');
		p1('b');
	}
	else if(stat_it == IT_POINTY_STICK)
	{
		p8('P', 'o', 'i', 'n', 't', 'y', ' ', 'S');
		p4('t', 'i', 'c', 'k');
	}
	else if(stat_it == IT_CRUSHER)
		p7('C', 'r', 'u', 's', 'h', 'e', 'r');
	else if(stat_it == IT_BASHER)
		p6('B', 'a', 's', 'h', 'e', 'r');
	else if(stat_it == IT_THE_GNARLED_BRANCH)
	{
		p8('T', 'h', 'e', ' ', 'G', 'n', 'a', 'r');
		p8('l', 'e', 'd', ' ', 'B', 'r', 'a', 'n');
		p2('c', 'h');
	}
	else if(stat_it == IT_KNOTTED_SPIRE)
	{
		p8('K', 'n', 'o', 't', 't', 'e', 'd', ' ');
		p5('S', 'p', 'i', 'r', 'e');
	}
	else if(stat_it == IT_THE_FIREPOKER)
	{
		p8('T', 'h', 'e', ' ', 'F', 'i', 'r', 'e');
		p5('p', 'o', 'k', 'e', 'r');
	}
	else if(stat_it == IT_THUNDERCLAP)
	{
		p8('T', 'h', 'u', 'n', 'd', 'e', 'r', 'c');
		p3('l', 'a', 'p');
	}
	else if(stat_it == IT_THE_MANGLER)
	{
		p8('T', 'h', 'e', ' ', 'M', 'a', 'n', 'g');
		p3('l', 'e', 'r');
	}
	else if(stat_it == IT_CADFAELS_CLEAVER)
	{
		p8('C', 'a', 'd', 'f', 'a', 'e', 'l', 39);
		p8('s', ' ', 'C', 'l', 'e', 'a', 'v', 'e');
		p1('r');
	}
	else if(stat_it == IT_SKULLSPLITTER)
	{
		p8('S', 'k', 'u', 'l', 'l', 's', 'p', 'l');
		p5('i', 't', 't', 'e', 'r');
	}
	else if(stat_it == IT_BLADED_TERROR)
	{
		p8('B', 'l', 'a', 'd', 'e', 'd', ' ', 'T');
		p5('e', 'r', 'r', 'o', 'r');
	}
	else if(stat_it == IT_DEATHS_EMISSARY)
	{
		p8('D', 'e', 'a', 't', 'h', 39, 's', ' ');
		p8('E', 'm', 'i', 's', 's', 'a', 'r', 'y');
	}
	else if(stat_it == IT_COLDCUTTER)
	{
		p8('C', 'o', 'l', 'd', 'c', 'u', 't', 't');
		p2('e', 'r');
	}
	else if(stat_it == IT_FLESHSTINGER)
	{
		p8('F', 'l', 'e', 's', 'h', 's', 't', 'i');
		p4('n', 'g', 'e', 'r');
	}
	else if(stat_it == IT_ELVEN_BOW)
	{
		p8('E', 'l', 'v', 'e', 'n', ' ', 'B', 'o');
		p1('w');
	}
	else if(stat_it == IT_ASSASIN_BOW)
	{
		p8('A', 's', 's', 'a', 's', 'i', 'n', ' ');
		p3('B', 'o', 'w');
	}
	else if(stat_it == IT_WITCHSTRING)
	{
		p8('W', 'i', 't', 'c', 'h', 's', 't', 'r');
		p3('i', 'n', 'g');
	}
	else if(stat_it == IT_WRAITHWEAVER)
	{
		p8('W', 'r', 'a', 'i', 't', 'h', 'w', 'e');
		p4('a', 'v', 'e', 'r');
	}
	else if(stat_it == IT_BLIGHT_BOW)
	{
		p8('B', 'l', 'i', 'g', 'h', 't', ' ', 'B');
		p2('o', 'w');
	}
	else if(stat_it == IT_DRAGON_TEETH)
	{
		p8('D', 'r', 'a', 'g', 'o', 'n', ' ', 'T');
		p4('e', 'e', 't', 'h');
	}
	else if(stat_it == IT_RAJAS_SILVER)
	{
		p8('R', 'a', 'j', 'a', 39, 's', ' ', 'S');
		p5('i', 'l', 'v', 'e', 'r');
	}
	else if(stat_it == IT_THE_WARD)
		p8('T', 'h', 'e', ' ', 'W', 'a', 'r', 'd');
	else if(stat_it == IT_DEMON_GUARD)
	{
		p8('D', 'e', 'm', 'o', 'n', ' ', 'G', 'u');
		p3('a', 'r', 'd');
	}
	else if(stat_it == IT_DYLANS_DEFENDER)
	{
		p8('D', 'y', 'l', 'a', 'n', 39, 's', ' ');
		p8('D', 'e', 'f', 'e', 'n', 'd', 'e', 'r');
	}
	else if(stat_it == IT_STORMSHIELD)
	{
		p8('S', 't', 'o', 'r', 'm', 's', 'h', 'i');
		p3('e', 'l', 'd');
	}
	else if(stat_it == IT_AGELESS_AEGIS_OF_THE_AGES)
	{
		p8('A', 'g', 'e', 'l', 'e', 's', 's', ' ');
		p8('A', 'e', 'g', 'i', 's', ' ', 'o', 'f');
		p8(' ', 't', 'h', 'e', ' ', 'A', 'g', 'e');
		p1('s');
	}
	else if(stat_it == IT_SPIKEWALL)
	{
		p8('S', 'p', 'i', 'k', 'e', 'w', 'a', 'l');
		p1('l');
	}
	else if(stat_it == IT_PRETTY_HAT)
	{
		p8('P', 'r', 'e', 't', 't', 'y', ' ', 'H');
		p2('a', 't');
	}
	else if(stat_it == IT_HEADBUCKET)
	{
		p8('H', 'e', 'a', 'd', 'b', 'u', 'c', 'k');
		p2('e', 't');
	}
	else if(stat_it == IT_STEELSKULL)
	{
		p8('S', 't', 'e', 'e', 'l', 's', 'k', 'u');
		p2('l', 'l');
	}
	else if(stat_it == IT_HASCERON)
		p8('H', 'a', 's', 'c', 'e', 'r', 'o', 'n');
	else if(stat_it == IT_DEMONHEAD)
	{
		p8('D', 'e', 'm', 'o', 'n', 'h', 'e', 'a');
		p1('d');
	}
	else if(stat_it == IT_BANEDINS_CROWN)
	{
		p8('B', 'a', 'n', 'e', 'd', 'i', 'n', 39);
		p7('s', ' ', 'C', 'r', 'o', 'w', 'n');
	}
	else if(stat_it == IT_FOOTGARDE)
	{
		p8('F', 'o', 'o', 't', 'g', 'a', 'r', 'd');
		p1('e');
	}
	else if(stat_it == IT_GORERIDER)
	{
		p8('G', 'o', 'r', 'e', 'r', 'i', 'd', 'e');
		p1('r');
	}
	else if(stat_it == IT_IRONHEEL)
		p8('I', 'r', 'o', 'n', 'h', 'e', 'e', 'l');
	else if(stat_it == IT_BYRONS_BANE)
	{
		p7('B', 'y', 'r', 'o', 'n', 39, 's');
		p5(' ', 'B', 'a', 'n', 'e');
	}
	else if(stat_it == IT_PANDORA_PENDANT)
	{
		p8('P', 'a', 'n', 'd', 'o', 'r', 'a', ' ');
		p7('P', 'e', 'n', 'd', 'a', 'n', 't');
	}
	else if(stat_it == IT_MINDS_EYE)
	{
		p8('M', 'i', 'n', 'd', 39, 's', ' ', 'E');
		p2('y', 'e');
	}
	else if(stat_it == IT_DREADSPIKE_ARROWS)
	{
		p8('D', 'r', 'e', 'a', 'd', 's', 'p', 'i');
		p8('k', 'e', ' ', 'A', 'r', 'r', 'o', 'w');
		p1('s');
	}
	else if(stat_it == IT_SURESHOT_ARROWS)
	{
		p8('S', 'u', 'r', 'e', 's', 'h', 'o', 't');
		p7(' ', 'A', 'r', 'r', 'o', 'w', 's');
	}
	else if(stat_it == IT_IMPALER_SPEARS)
	{
		p8('I', 'm', 'p', 'a', 'l', 'e', 'r', ' ');
		p6('S', 'p', 'e', 'a', 'r', 's');
	}
	else if(stat_it == IT_WARSTRIKE_SPEARS)
	{
		p8('W', 'a', 'r', 's', 't', 'r', 'i', 'k');
		p8('e', ' ', 'S', 'p', 'e', 'a', 'r', 's');
	}
	else if(stat_it == IT_NAMUS_RELIC)
	{
		p8('N', 'a', 'm', 'u', 's', ' ', 'R', 'e');
		p3('l', 'i', 'c');
	}
	else if(stat_it == IT_ARIANNAS_BLESSING)
	{
		p8('A', 'r', 'i', 'a', 'n', 'n', 'a', 39);
		p8('s', ' ', 'B', 'l', 'e', 's', 's', 'i');
		p2('n', 'g');
	}
	else
	{
		entity q = get_questitem(stat_it);
		if(q && q.finalangle != '0 0 0')
		{
			pvstr(q.finalangle);
			pvstr(q.mangle);
		}
		else
		{
			p6('I', '.', 'O', '.', 'U', '.');		
		}
	}
}
