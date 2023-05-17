#include "pmonster.qh"

void PrintMonsterName(entity e)
{
	int pf = decode(e.monnum, 2);
	int sf = decode(e.monnum, 3);
	if(pf)
	{
		if(pf == MP_INFERIOR)
		{
			p8('I', 'n', 'f', 'e', 'r', 'i', 'o', 'r');
			p1(' '); // damage 50%, health 40%, tohit 50%
		
		}
		else if(pf == MP_WEAK)
			p5('W', 'e', 'a', 'k', ' '); // health 66%, damage 50%
		else if(pf == MP_SICK)
			p5('S', 'i', 'c', 'k', ' '); // health 80%, dodge 50%
	
		else if(pf == MP_CRIPPLED)
		{
			p8('C', 'r', 'i', 'p', 'p', 'l', 'e', 'd');
			p1(' ');
			// tohit 20% dodge 10%
		}
		else if(pf == MP_ELDERLY)
			p8('E', 'l', 'd', 'e', 'r', 'l', 'y', ' '); // speed = 60%
		else if(pf == MP_CLUMSY)
			p7('C', 'l', 'u', 'm', 's', 'y', ' '); // to hit -%50
		else if(pf == MP_FAST)
			p5('F', 'a', 's', 't', ' '); // agil +5
		else if(pf == MP_MUSCULAR)
		{
			p8('M', 'u', 's', 'c', 'u', 'l', 'a', 'r'); // str +5
			p1(' ');
		}
		else if(pf == MP_SUPERIOR)
		{
			p8('S', 'u', 'p', 'e', 'r', 'i', 'o', 'r'); // tohit +50% str +5 dex +5
			p1(' ');
		}
		else if(pf == MP_HEALTHY)
			p8('H', 'e', 'a', 'l', 't', 'h', 'y', ' '); // vit +5 (?)
		else if(pf == MP_FIERY)
			p6('F', 'i', 'e', 'r', 'y', ' ');
		else if(pf == MP_VILE)
			p5('V', 'i', 'l', 'e', ' '); // poidam + 5
		else if(pf == MP_HELL)
			p5('H', 'e', 'l', 'l', ' ');
		else if(pf == MP_ARMOR)
			p8('A', 'r', 'm', 'o', 'r', 'e', 'd', ' ');
		else if(pf == MP_WARDED)
			p7('W', 'a', 'r', 'd', 'e', 'd', ' ');
		else if(pf == MP_BURNING)
			p8('B', 'u', 'r', 'n', 'i', 'n', 'g', ' ');
		else if(pf == MP_ENRAGED)
			p8('E', 'n', 'r', 'a', 'g', 'e', 'd', ' ');
		else if(pf == MP_CHARGED)
			p8('C', 'h', 'a', 'r', 'g', 'e', 'd', ' ');
	}
	
	pvstr(e.finalangle);
	pvstr(e.mangle);
	
	if(sf)
	{
		if(sf == MS_PUPIL)
			p6(' ', 'p', 'u', 'p', 'i', 'l');
		else if(sf == MS_OAF)
			p4(' ', 'O', 'a', 'f');
		else if(sf == MS_LUMMOX)
			p7(' ', 'L', 'u', 'm', 'm', 'o', 'x');
		else if(sf == MS_IMBECILE)
		{
			p8(' ', 'I', 'm', 'b', 'e', 'c', 'i', 'l');
			p1('e');
		}
		else if(sf == MS_WEAKLING)
		{
			p8(' ', 'W', 'e', 'a', 'k', 'l', 'i', 'n');
			p1('g');
		}
		else if(sf == MS_DAWDLER)
			p8(' ', 'D', 'a', 'w', 'd', 'l', 'e', 'r');
		
		// pupil tohit -7%
		// oaf dex -5
		// lummox dex -5 tohit -5
		// imbecile int -10
		// weakling vit -10;
		// dawdler agil -5
		else if(sf == MS_VAMPIRE)
			p8(' ', 'V', 'a', 'm', 'p', 'i', 'r', 'e');
		else if(sf == MS_MASTER)
			p7(' ', 'M', 'a', 's', 't', 'e', 'r');
		else if(sf == MS_CHAMPION)
		{
			p8(' ', 'C', 'h', 'a', 'm', 'p', 'i', 'o');
			p1('n');
		}
		else if(sf == MS_WIZARD)
			p7(' ', 'W', 'i', 'z', 'a', 'r', 'd');
		else if(sf == MS_MAGE)
			p5(' ', 'M', 'a', 'g', 'e');
		else if(sf == MS_CLERIC)
			p7(' ', 'C', 'l', 'e', 'r', 'i', 'c');
		else if(sf == MS_CHIEFTAIN)
		{
			p8(' ', 'C', 'h', 'i', 'e', 'f', 't', 'a');
			p2('i', 'n');
		}
		else if(sf == MS_BESERKER)
		{
			p8(' ', 'B', 'e', 's', 'e', 'r', 'k', 'e');
			p1('r');
		}
			
		// savant
		// master
		// champion
		// wizard
		// mage
		// cleric
	}
}
