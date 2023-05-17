#include "rq_npcs.qh"

#include "_mod.qh"
#include "../subs/subs.qh"

string rq_npcname(float f)
{
	if(f == 0)
		return "Morurn";
	else if(f == 1)
		return "Daron";
	else if(f == 2)
		return "Oughas";
	else if(f == 3)
		return "Awath";
	else if(f == 4)
		return "Omal";
	else if(f == 5)
		return "Haetmos";
	else if(f == 6)
		return "Enthim";
	else if(f == 7)
		return "Brouw";
	else if(f == 8)
		return "Rilageo";
	else if(f == 9)
		return "Rilert";
	else if(f == 10)
		return "Ustghatin";
	else if(f == 11)
		return "Maufdan";
	else if(f == 12)
		return "Enthroth";
	else if(f == 13)
		return "Basultin";
	else if(f == 14)
		return "Foir";
	else if(f == 15)
		return "Dillom";
	else if(f == 16)
		return "Kensid";
	else if(f == 17)
		return "Daiden";
	else if(f == 18)
		return "Garech";
	else if(f == 19)
		return "Radch";
	else if(f == 20)
		return "Listun";
	else if(f == 21)
		return "Isstano";
	else if(f == 22)
		return "Engir";
	else if(f == 23)
		return "Renrad";
	else if(f == 24)
		return "Rocuz";
	else if(f == 25)
		return "Neron";
	else if(f == 26)
		return "Achbur";
	else if(f == 27)
		return "Peretam";
	else if(f == 28)
		return "Chaet";
	else if(f == 29)
		return "Enust";
	else if(f == 30)
		return "Esstor";
	else if(f == 31)
		return "Bob";
	else if(f == 32)
		return "Ieni";
	else if(f == 33)
		return "Syn";
	else if(f == 34)
		return "Saycer";
	else if(f == 35)
		return "Cershy";
	else if(f == 36)
		return "Nyeng";
	else if(f == 37)
		return "Nin";
	else if(f == 38)
		return "Umer";
	else if(f == 39)
		return "Nausta";
	else if(f == 40)
		return "Hunawa";
	else if(f == 41)
		return "Isnys";
	else if(f == 42)
		return "Kimny";
	else if(f == 43)
		return "Beldra";
	else if(f == 44)
		return "Joronda";
	else if(f == 45)
		return "Lornye";
	else if(f == 46)
		return "Shiada";
	else if(f == 47)
		return "Queyna";
	else if(f == 48)
		return "Sululer";
	else if(f == 49)
		return "Treblir";
	else if(f == 50)
		return "Untale";
	else if(f == 51)
		return "Risimyna";
	else if(f == 52)
		return "Vorvoro";
	else if(f == 53)
		return "Xirazatu";
	else if(f == 54)
		return "Sugope";
	else if(f == 55)
		return "Rakasim";
	else if(f == 56)
		return "Uzeashi";
	else if(f == 57)
		return "Lunaless";
	else if(f == 58)
		return "Llazem";
	else if(f == 59)
		return "Xanangi";
	else if(f == 60)
		return "Xasa";
	else if(f == 61)
		return "Zerte";
	else if(f == 62)
		return "Dahyx";
	else if(f == 63)
		return "Vaerd";
	else if(f == 64)
		return "Tanoh";
	else if(f == 65)
		return "Rajik";
	else if(f == 66)
		return "Wago";
	else if(f == 67)
		return "Zole";
	else if(f == 68)
		return "Satuk";
	else if(f == 69)
		return "Noyen";
	else if(f == 70)
		return "Darick";
	else if(f == 71)
		return "Moril";
	else if(f == 72)
		return "Pugi";
	else if(f == 73)
		return "Rajer";
	else if(f == 74)
		return "Kunfu";
	else if(f == 75)
		return "Jabu";
	else if(f == 76)
		return "Credis";
	else if(f == 77)
		return "Jugit";
	else if(f == 78)
		return "Nicotu";
	else if(f == 79)
		return "Depp";
	else if(f == 80)
		return "Hicup";
	else if(f == 81)
		return "Fanumix";
	else if(f == 82)
		return "Hamil";
	else if(f == 83)
		return "Lijoy";
	else if(f == 84)
		return "Buvox";
	else if(f == 85)
		return "Dizo";
	else if(f == 86)
		return "Taroh";
	else if(f == 87)
		return "Judas";
	else if(f == 88)
		return "Lavagano";
	else if(f == 89)
		return "Tosser";
	else if(f == 90)
		return "Pefut";
	else if(f == 91)
		return "Foyet";
	else if(f == 92)
		return "Werebever";
	else if(f == 93)
		return "Foggy";
	else if(f == 94)
		return "Gageh";
	else if(f == 95)
		return "Newsi";
	else if(f == 96)
		return "Heppe";
	else if(f == 97)
		return "Wamoda";
	else if(f == 98)
		return "Xadar";
	else if(f == 99)
		return "Pupan";
	else if(f == 100)
		return "Fegom";
	else if(f == 101)
		return "Rabokov";
	else if(f == 102)
		return "Lamoh";
	else if(f == 103)
		return "Butac";
	else if(f == 104)
		return "Wozic";
	else if(f == 105)
		return "Cofaziwu";
	else if(f == 106)
		return "Lavam";
	else if(f == 107)
		return "Pojep";
	else if(f == 108)
		return "Dufez";
	else if(f == 109)
		return "Milunex";
	else if(f == 110)
		return "Naciye";
	else if(f == 111)
		return "Bovril";
	else if(f == 112)
		return "Firon";
	else if(f == 113)
		return "Helix";
	else if(f == 114)
		return "Choboko";
	else if(f == 115)
		return "Poccoti";
	else if(f == 116)
		return "Gibura";
	else if(f == 117)
		return "Xune";
	else if(f == 118)
		return "Pavorati";
	else if(f == 119)
		return "Piggy";
	else if(f == 120)
		return "Nanunanu";
	else if(f == 121)
		return "Rotabehe";
	else if(f == 122)
		return "Loligag";
	else if(f == 123)
		return "Dazoka";
	else if(f == 124)
		return "Jobe";
	else if(f == 125)
		return "Magid";
	else if(f == 126)
		return "Fefe";
	else if(f == 127)
		return "Jihard";
	else if(f == 128)
		return "Kerock";
	else if(f == 129)
		return "Gapol";
	else if(f == 130)
		return "Xorudus";
	else if(f == 131)
		return "Lolaye";
	else if(f == 132)
		return "Sihawi";
	else if(f == 133)
		return "Axeyu";
	else if(f == 134)
		return "Womuleve";
	else if(f == 135)
		return "Kihud";
	else if(f == 136)
		return "Major";
	else if(f == 137)
		return "Kurodo";
	else if(f == 138)
		return "Raripoy";
	else if(f == 139)
		return "Pafax";
	else if(f == 140)
		return "Pavel";
	else if(f == 141)
		return "Safri";
	else if(f == 142)
		return "Nidox";
	else if(f == 143)
		return "Jezaz";
	else if(f == 144)
		return "Govnuh";
	else if(f == 145)
		return "Rejuvin";
	else if(f == 146)
		return "Geko";
	else if(f == 147)
		return "Tupar";
	else if(f == 148)
		return "Hangun";
	else if(f == 149)
		return "Sehaba";
	else if(f == 150)
		return "Peejik";
	else if(f == 151)
		return "Jojo";
	else if(f == 152)
		return "Furry";
	else if(f == 153)
		return "Cotake";
	else if(f == 154)
		return "Wazat";
	else if(f == 155)
		return "Pixal";
	else if(f == 156)
		return "Zibid";
	else if(f == 157)
		return "Corey";
	else if(f == 158)
		return "Bawah";
	else if(f == 159)
		return "Guzuk";
	else if(f == 160)
		return "Jukukahe";
	else if(f == 161)
		return "Dazetaco";
	else if(f == 162)
		return "Rixekik";
	else if(f == 163)
		return "Hatepyro";
	else if(f == 164)
		return "Labuck";
	else if(f == 165)
		return "Fiver";
	else if(f == 166)
		return "Jibe";
	else if(f == 167)
		return "Gob";
	else if(f == 168)
		return "Zaked";
	else if(f == 169)
		return "Yuroc";
	else if(f == 170)
		return "Yeplib";
	else if(f == 171)
		return "Vito";
	else if(f == 172)
		return "Tuvok";
	else if(f == 173)
		return "Vekogu";
	else if(f == 174)
		return "Sileyo";
	else if(f == 175)
		return "Gauze";
	else if(f == 176)
		return "Kahuye";
	else if(f == 177)
		return "Lovejoy";
	else if(f == 178)
		return "Tiluba";
	else if(f == 179)
		return "Zegag";
	else if(f == 180)
		return "Casem";
	else if(f == 181)
		return "Humax";
	else if(f == 182)
		return "Mame";
	else if(f == 183)
		return "Zefozeb";
	else if(f == 184)
		return "Barcasa";
	else if(f == 185)
		return "Bogey";
	else if(f == 186)
		return "Dayuko";
	else if(f == 187)
		return "Malib";
	else if(f == 188)
		return "Xisen";
	else if(f == 189)
		return "Fevur";
	else if(f == 190)
		return "Toledi";
	else if(f == 191)
		return "Woze";
	else if(f == 192)
		return "Nick";
	else if(f == 193)
		return "Nijal";
	else if(f == 194)
		return "Whey";
	else if(f == 195)
		return "Wigaya";
	else if(f == 196)
		return "Yuluv";
	else if(f == 197)
		return "Kevin";
	else if(f == 198)
		return "Poe";
	else if(f == 199)
		return "Rubon";
	else if(f == 200)
		return "Xevuz";
	else if(f == 201)
		return "Toejam";
	else if(f == 202)
		return "Jolly";
	else if(f == 203)
		return "Mefat";
	else if(f == 204)
		return "Gojugam";
	else if(f == 205)
		return "Divorado";
	else if(f == 206)
		return "Furas";
	else if(f == 207)
		return "Tonur";
	else if(f == 208)
		return "Vileox";
	else if(f == 209)
		return "Bubonik";
	else if(f == 210)
		return "Feezy";
	else if(f == 211)
		return "Wayu";
	else if(f == 212)
		return "Kavok";
	else if(f == 213)
		return "Selejeda";
	else if(f == 214)
		return "Yena";
	else if(f == 215)
		return "Dichu";
	else if(f == 216)
		return "Noxi";
	else if(f == 217)
		return "Zido";
	else if(f == 218)
		return "Fonze";
	else if(f == 219)
		return "Buvedu";
	else if(f == 220)
		return "Milo";
	else if(f == 221)
		return "Vametu";
	else if(f == 222)
		return "Dosan";
	else if(f == 223)
		return "Gelix";
	else if(f == 224)
		return "Nataki";
	else if(f == 225)
		return "Kelax";
	else if(f == 226)
		return "Roofle";
	else if(f == 227)
		return "Cecil";
	else if(f == 228)
		return "Kojak";
	else if(f == 229)
		return "Howard";
	else if(f == 230)
		return "Nufaw";
	else if(f == 231)
		return "Vopiw";
	else if(f == 232)
		return "Kadas";
	else if(f == 233)
		return "Dived";
	else if(f == 234)
		return "Nuncy";
	else if(f == 235)
		return "Yosef";
	else if(f == 236)
		return "Rahoru";
	else if(f == 237)
		return "Sufifa";
	else if(f == 238)
		return "Lewan";
	else if(f == 239)
		return "Vomita";
	else if(f == 240)
		return "Movehit";
	else if(f == 241)
		return "Homer";
	else if(f == 242)
		return "Fapap";
	else if(f == 243)
		return "Gemari";
	else if(f == 244)
		return "Zip";
	else if(f == 245)
		return "Ripina";
	else if(f == 246)
		return "Bisep";
	else if(f == 247)
		return "Zahog";
	else if(f == 248)
		return "Toronto";
	else if(f == 249)
		return "Malun";
	else if(f == 250)
		return "Behoga";
	else if(f == 251)
		return "Dovutiba";
	else if(f == 252)
		return "Yoji";
	else if(f == 253)
		return "Raxil";
	else if(f == 254)
		return "Boy";
	else if(f == 255)
		return "Bacom";
	else
		return "Someone";
}

string rq_npcmodel(entity this, float n)
{
	float skn = (n & 12) / 4;
	n &= 3;
	
	this.skin = skn;
	if(n == 0)
		return "progs/human.mdl";
	else if(n == 1)
		return "progs/guy.mdl";
	else if(n == 2)
		return "progs/fem.mdl";
	else if(n == 3)
		return "progs/sadoc.mdl";
	return "";
}

entity rq_spawnmonster(entity this)
{
	entity e = find_spot(this);
	entity m = rq_getscenario(rndquest);
	e.target = "rq_mondie"; // on death
	e.lvl = monsvalue * 3;
	
	if(m.target)
	{
		// TODO: what was it using this for?
		//entity t = find(NULL, targetname, m.target);
		become_monster(e, m);
		spawnfunc_monster(e);
	}
	else
	{
		rq_villantype(e, rndquest);
	}
	return e;
}

entity rq_spawnnpc_go(entity this, float spawnpoint, float type)
{
	entity e = find_spot(this);
	
	float tm = rq_templateforquest(rndquest);
	
	// random giver
	if(type == 0)
	{
		rq_npcs = rq_npcs + 1;

		e.v_angle_x = rq_npcs;
		e.v_angle_y = world.impulse;
		e.v_angle_z = floor(random() * 256);

		e.message = "WTF?";
		if(rq_vars_x == rq_npcs)
		{
			if(rq_vars_y == world.impulse)
			{
				e.v_angle_z = rq_vars_z;
				if(tm & RQ_ESCORT)
				{
					delete(e);
					return NULL;
				}
	 		}
	 	}
		e.model = rq_npcmodel(e, floor(e.v_angle_z/16) & 15);
		e.netname = rq_npcname(e.v_angle_z);
	}
	// returning 'hero' from escort
	else if(type == 1)
	{
		float f = rq_iscomplete();

		e.model = rq_npcmodel(e, floor(rq_vars_z/16) & 15);
		e.netname = rq_npcname(rq_vars_z);
		e.v_angle = rq_vars;
		e.movedir = rndquest;
		e.ai = AI_FOLLOW;
		if(tm & RQ_FIGHT)
			e.ai |= AI_HUNT_MONSTERS;
		if(f)
		{
			e.ai = AI_STAY_NEAR;
			e.wad = "rq_goalpoint";
			rq_npcsetreward(e);
		}
	}
	// rescues 
	else if(type == 2)
	{
		e.model = rq_modelforquest(e, rndquest);
		e.netname = rq_npcnameforquest(rndquest);
		if(spawnpoint)
		{
			e.ai = AI_FOLLOW;
			if(tm & RQ_FIGHT)
				e.ai |= AI_HUNT_MONSTERS;
		}
		else
		{
			e.message = "I'm not supposed to say this";
			e.ai = AI_LUMP;
		}
	}
	// pickup/gets
	else if(type == 3)
	{
		e.model = rq_modelforquest(e, rndquest);
		e.netname = rq_npcnameforquest(rndquest);
		if(!spawnpoint)
			e.message = "I'm not supposed to say this";
		e.ai = AI_LUMP;

	}
	if(type != 0)
		e.targetname = "rq_npc";
	e.killtarget = "rq_cancel"; // on death
	e.classname = "npc";
 	e.max_health = 17;
	e.lvl = monsvalue;
	e.ac = 2 * monsvalue;
	e.daml = 12;

	spawnfunc_npc(e);
	
	if(type == 0)
	{
		setthink(e, rq_createdialog);
		e.nextthink = time;
	}
	return e;
}

// spawnpoint function
void rq_spawnnpc(entity this)
{
	float tm = rq_templateforquest(rndquest);
	float o = rq_objectives();
	
	// only do spawnpoint ones once.
	if(spawnednpc)
		return;
	spawnednpc = 1;
	
	if((tm & RQ_RESCUE_NPC) && !(o & RQ_RESCUE_NPC))
		rq_spawnnpc_go(this, true, 2);
	if(tm & RQ_ESCORT)
		rq_spawnnpc_go(this, true, 1);
}

// map spawn
spawnfunc(rq_npc)
{
	rq_spawnnpc_go(this, false, 0);
	delete(this);
}
