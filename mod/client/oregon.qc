#include "oregon.qh"

void Oregon_HandleCommand(string input)
{
	if(!oregon_started)
	{
		Oregon_Begin();
		return;
	}

	if(input == "end" || input == "stop")
	{
		Oregon_Finish(oregon_handler);
		return;
	}

	Oregon_ParseInput(input);
}

void Oregon_Begin()
{
	oregon_started = true;
	localcmd("\ntoggleconsole\n"); // assumes console was open!
	print("\{3}^7Beginning game of Oregon Trail\n");
	print("\{3}^7Enter \"oregon stop\" in the console at any time to stop the game\n");
	oregon_handler = new(oregon_handler);
	setthink(oregon_handler, Oregon_HandlerThink);
	oregon_handler.nextthink = time + OREGON_TICKRATE;
	oregon_handler.oregon_line = OREGON_STARTLINE;
}

void Oregon_Finish(entity this)
{
	if(this)
	{
		print("\{3}^7Ending game of Oregon Trail\n");
		delete(this);
	}

	oregon_handler = NULL;
	oregon_started = false;
	strfree(oregon_input);

	// clear all the variables so they can't linger
	oregon_A = 0;
	oregon_B = 0;
	oregon_B1 = 0;
	oregon_B3 = 0;
	oregon_C = 0;
	oregon_C1 = 0;
	strfree(oregon_CAND);
	oregon_D = 0;
	oregon_D1 = 0;
	oregon_D3 = 0;
	oregon_D9 = 0;
	oregon_E = 0;
	oregon_F = 0;
	oregon_F1 = 0;
	oregon_F2 = 0;
	oregon_F9 = 0;
	oregon_K8 = 0;
	oregon_L1 = 0;
	oregon_M = 0;
	oregon_M1 = 0;
	oregon_M2 = 0;
	oregon_M9 = 0;
	oregon_P = 0;
	oregon_R1 = 0;
	oregon_S4 = 0;
	oregon_S5 = 0;
	oregon_S6 = 0;
	strfree(oregon_SAND);
	oregon_T = 0;
	oregon_X = 0;
	oregon_X1 = 0;
}

void Oregon_HandlerThink(entity this)
{
	this.nextthink = time + OREGON_TICKRATE;
	if(this.oregon_waitforinput)
		return; // don't progress until input has been received!
	Oregon_Handle(this);
	++this.oregon_line;

	if(this.oregon_line > 9999)
		Oregon_Finish(this);
}

void Oregon_ParseInput(string input)
{
	strcpy(oregon_input, input);
	if(oregon_handler)
		oregon_handler.oregon_waitforinput = false;
}

void Oregon_OpenInput(entity this)
{
	print("\{3}^3NOTE: Enter \"oregon\" in the console to progress if you accidentally close this window\n");
	localcmd("\ncommandmode oregon \n");
	this.oregon_waitforinput = true;
}

// Oregon Trail implementation, ported from BASIC to QuakeC by Mario
// NOTE: strings are hard to handle in QC, so for the sake of simplicity any input processing is handled directly
// NOTE: whenever goto is used, the line is reduced by 1, since the handler increases the line number at the end

string Oregon_get_tab_count(int tabs)
{
	string result = "";
	for(int j = 0; j < tabs; ++j)
		result = strcat(result, " ");
	return result;
}

void Oregon_Handle(entity this)
{
#define REM(s) dprint(strcat((s), "\n"));
#define PRINT(s) print(strcat("\{3}^7", (s), "\n"));
#define PRINTF(...) PRINT(sprintf(__VA_ARGS__))
#define LINE(ln) if(this.oregon_line == ln)
#define GOTO(ln) {this.oregon_line = ln - 1; return;}
#define LET(a, b) oregon_##a = (b);
#define LETSTR(a, b) strcpy(oregon_##a, (b));
#define INPUT(in) {strfree(oregon_input); if((in) != "") print(strcat("\{3}^7", (in), "\n")); Oregon_OpenInput(this);}
#define INPUTSET(s) oregon_##s = stof(oregon_input);
#define IFINPUT(s) if(stof(oregon_input) == (s))
#define IFINPUTSTR(s) if(oregon_input == (s))
#define IFVAR(a, op, b) if(oregon_##a op (b))
#define IFVAL(a, op, b) if((a) op (b))
#define THEN(ln) {this.oregon_line = ln - 1; return;}
#define VAR(s) oregon_##s
#define ON10(s, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10) { \
	switch(s) { case 1: GOTO(c1); case 2: GOTO(c2); case 3: GOTO(c3); case 4: GOTO(c4); case 5: GOTO(c5); \
				case 6: GOTO(c6); case 7: GOTO(c7); case 8: GOTO(c8); case 9: GOTO(c9); case 10: GOTO(c10); }}
#define ON6(s, c1, c2, c3, c4, c5, c6) { \
	switch(s) { case 1: GOTO(c1); case 2: GOTO(c2); case 3: GOTO(c3); case 4: GOTO(c4); case 5: GOTO(c5); \
				case 6: GOTO(c6); }}
#define ON3(s, c1, c2, c3) {switch(s) { case 1: GOTO(c1); case 2: GOTO(c2); case 3: GOTO(c3); }}
#define INT(s) floor(s)
#define GOSUB(ln) {this.oregon_returnline = this.oregon_line + 1; this.oregon_line = ln - 1; return;}
#define RETURN() {this.oregon_line = this.oregon_returnline - 1; return;}
#define RND() (random())
#define RESTORE() this.oregon_data = 0;
#define READ(s) {oregon_##s = oregon_data_values[this.oregon_data]; this.oregon_data += 1;}
#define DATA(...) /* data is already stored! */
#define TAB(d) Oregon_get_tab_count(d)
#define CLK(d) time + (d)
/* oregon specific macro for the sake of simplifying array access */
#define S(d) oregon_shoot_words[oregon_##d]
#define END() Oregon_Finish(this);

LINE(1) REM("The program that follows is a reconstruction")
LINE(2) REM("of the Oregon Trail game written for HP time-shared")
LINE(3) REM("BASIC by Don Rawitsch and Bill Heinemann and Paul Dillenberger")
LINE(4) REM("in 1971. Its source is an updated version published in the")
LINE(5) REM("July-August 1978 issue of Creative Computing.")

LINE(10) REM("PROGRAM NAME - 0REGON        VERSION:01/01/78")
LINE(20) REM("ORIGINAL PROGRAMMING BY BILL HEINEMANN - 1971")
LINE(30) REM("SUPPORT RESEARCH AND MATERIALS BY DON RAVITSCH")
LINE(40) REM("MINNESOTA EDUCATIONAL COMPUTING CONSORTIUM STAFF")
LINE(50) REM("CDC CYBER 70/73-26 BASIC 3-1")
LINE(60) REM("DOCUMENTATION BOOKLET 'OREGON' AVAILABLE FROM")
LINE(61) REM("   MECC SUPPORT SERVICES")
LINE(62) REM("   2520 BROADWAY DRIVE")
LINE(63) REM("   ST. PAUL, MN  55113")
LINE(80) REM("")
// TODO 91
LINE(150) REM(" *FOR THE MEANING OF THE VARIABLES USED, LIST LINES 6470-6790*")
LINE(155) REM("")
//LINE(156) LETSTR(CAND, "") /* unnecessary in QC */
LINE(157) INPUT("Do you need instructions  (^2y^7/^1n^7)")
LINE(200) IFINPUTSTR("n") THEN(690)
LINE(210) PRINT("")
LINE(220) PRINT("")
LINE(230) REM("***INSTRUCTIONS***")
LINE(240) PRINT("This program simulates a trip over the Oregon Trail from")
LINE(250) PRINT("Independence, Missouri to Oregon City, Oregon in 1847.")
LINE(260) PRINT("Your family of five will cover the 2040 mile Oregon Trail")
LINE(270) PRINT("In 5-6 months -- if you make it alive.")
LINE(280) PRINT("")
LINE(290) PRINT("You have saved ^2$900^7 to spend for the trip, and you've just")
LINE(300) PRINT("   paid ^2$200^7 for a wagon.")
LINE(310) PRINT("You will need to spend the rest of your money on the")
LINE(320) PRINT("   following items:")
LINE(330) PRINT("")
LINE(340) PRINT("     ^9OXEN^7 - You can spend ^2$200^7-^2$300^7 on your team")
LINE(350) PRINT("            The more you spend, the faster you'll go")
LINE(360) PRINT("               because you'll have better animals")
LINE(370) PRINT("")
LINE(380) PRINT("     ^3FOOD^7 - The more you have, the less chance there")
LINE(390) PRINT("               is of getting sick")
LINE(400) PRINT("")
LINE(410) PRINT("     ^4AMMUNITION^7 - ^2$1^7 buys a belt of ^450 bullets")
LINE(420) PRINT("            You will need bullets for attacks by animals")
LINE(430) PRINT("               and bandits, and for hunting food")
LINE(440) PRINT("")
LINE(450) PRINT("     ^5CLOTHING^7 - This is especially important for the cold")
LINE(460) PRINT("               weather you will encounter when crossing")
LINE(470) PRINT("               the mountains")
LINE(480) PRINT("")
LINE(490) PRINT("     ^6MISCELLANEOUS SUPPLIES^7 - This includes medicine and")
LINE(500) PRINT("               other things you will need for sickness")
LINE(510) PRINT("               and emergency repairs")
LINE(520) PRINT("")
LINE(530) PRINT("")
LINE(540) PRINT("You can spend all your money before you start your trip -")
LINE(550) PRINT("or you can save some of your cash to spend at forts along")
LINE(560) PRINT("the way when you run low. However, items cost more at")
LINE(570) PRINT("the forts. You can also go hunting along the way to get")
LINE(580) PRINT("more food.")
LINE(590) PRINT("Whenever you have to use your trusty rifle along the way,")
LINE(600) PRINT("you will be told to type in a word (one that sounds like a")
LINE(610) PRINT("gun shot). The faster you type in that word and hit the")
LINE(620) PRINT("^1RETURN^7 key, the better luck you'll have with your gun.")
LINE(630) PRINT("")
LINE(640) PRINT("At each turn, all items are shown in dollar amounts")
LINE(650) PRINT("except bullets")
LINE(660) PRINT("^3When asked to enter money amounts, don't use a $.")
LINE(670) PRINT("")
LINE(680) PRINT("GOOD LUCK!!!")
LINE(690) PRINT("")
LINE(700) PRINT("")

LINE(710) PRINT("How good a shot are you with your rifle?")
LINE(720) PRINT("  (^21^7) ACE MARKSMAN,  (^22^7) GOOD SHOT,  (^23^7) FAIR TO MIDDLIN'")
LINE(730) PRINT("         (^24^7) NEED MORE PRACTICE,  (^25^7) SHAKY KNEES")
LINE(740) PRINT("Enter one of the above -- the better you claim you are, the")
LINE(750) PRINT("FASTER you'll have to be with your gun to be successful.")
LINE(751) LET(D9, 0)
LINE(760) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(770) INPUTSET(D9)
LINE(770) IFVAR(D9, >, 5) THEN(790)
LINE(780) GOTO(810)
LINE(790) LET(D9, 0)

LINE(810) REM("*** INITIAL PURCHASES***")
LINE(810) LET(X1, -1)
LINE(820) LET(K8, 0)
LINE(821) LET(S4, 0)
LINE(822) LET(F1, 0)
LINE(823) LET(F2, 0)
LINE(824) LET(M, 0)
LINE(825) LET(M9, 0)
LINE(826) LET(D3, 0)
LINE(830) PRINT("")
LINE(840) PRINT("")
LINE(850) PRINT("How much do you want to spend on your ^9OXEN TEAM")
LINE(851) LET(A, 0)
LINE(860) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(870) INPUTSET(A)
LINE(870) IFVAR(A, >=, 200) THEN(900)
LINE(880) PRINT("Not enough")
LINE(890) GOTO(850)
LINE(900) IFVAR(A, <=, 300) THEN(930)
LINE(910) PRINT("Too much")
LINE(920) GOTO(850)
LINE(930) PRINT("How much do you want to spend on ^3FOOD")
LINE(931) LET(F, 0)
LINE(940) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(950) INPUTSET(F)
LINE(950) IFVAR(F, >=, 0) THEN(980)
LINE(960) PRINT("Impossible")
LINE(970) GOTO(930)
LINE(980) PRINT("How much do you want to spend on ^4AMMUNITION")
LINE(981) LET(B, 0)
LINE(990) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(1000) INPUTSET(B)
LINE(1000) IFVAR(B, >=, 0) THEN(1030)
LINE(1010) PRINT("Impossible")
LINE(1020) GOTO(980)
LINE(1030) PRINT("How much do you want to spend on ^5CLOTHING")
LINE(1031) LET(C, 0)
LINE(1040) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(1050) INPUTSET(C)
LINE(1050) IFVAR(C, >=, 0) THEN(1080)
LINE(1060) PRINT("Impossible")
LINE(1070) GOTO(1030)
LINE(1080) PRINT("How much do you want to spend on ^6MISCELLANEOUS SUPPLIES")
LINE(1081) LET(M1, 0)
LINE(1090) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(1100) INPUTSET(M1)
LINE(1100) IFVAR(M1, >=, 0) THEN(1130)
LINE(1110) PRINT("Impossible")
LINE(1120) GOTO(1080)
LINE(1130) LET(T, 700 - VAR(A) - VAR(F) - VAR(B) - VAR(C) - VAR(M1))
LINE(1140) IFVAR(T, >=, 0) THEN(1170)
LINE(1150) PRINT("YOU OVERSPENT--You only had ^2$700^7 to spend.  Buy again.")
LINE(1160) GOTO(830)
LINE(1170) LET(B, 50 * VAR(B))
LINE(1180) PRINTF("After all your purchases, you now have ^2%d^7 dollars left", VAR(T))
LINE(1190) PRINT("")
LINE(1200) PRINT("Monday March 29 1847")
LINE(1210) PRINT("")
LINE(1220) GOTO(1750)
LINE(1230) IFVAR(M, >=, 2040) THEN(5430)

LINE(1240) REM("***SETTING DATE***")
LINE(1250) LET(D3, VAR(D3) + 1)
LINE(1260) PRINT("")
LINE(1270) PRINT("Monday ")
LINE(1280) IFVAR(D3, >, 10) THEN(1300)
LINE(1290) ON10(VAR(D3), 1310, 1330, 1350, 1370, 1390, 1410, 1430, 1450, 1470, 1490)
LINE(1300) ON10(VAR(D3) - 10, 1510, 1530, 1550, 1570, 1590, 1610, 1630, 1650, 1670, 1690)
LINE(1310) PRINT("April 12 ")
LINE(1320) GOTO(1720)
LINE(1330) PRINT("April 26 ")
LINE(1340) GOTO(1720)
LINE(1350) PRINT("May 10 ")
LINE(1360) GOTO(1720)
LINE(1370) PRINT("May 24 ")
LINE(1380) GOTO(1720)
LINE(1390) PRINT("June 7 ")
LINE(1400) GOTO(1720)
LINE(1410) PRINT("June 21 ")
LINE(1420) GOTO(1720)
LINE(1430) PRINT("July 5 ")
LINE(1440) GOTO(1720)
LINE(1450) PRINT("July 19 ")
LINE(1460) GOTO(1720)
LINE(1470) PRINT("August 2 ")
LINE(1480) GOTO(1720)
LINE(1490) PRINT("August 16 ")
LINE(1500) GOTO(1720)
LINE(1510) PRINT("August 31 ")
LINE(1520) GOTO(1720)
LINE(1530) PRINT("September 13 ")
LINE(1540) GOTO(1720)
LINE(1550) PRINT("September 27 ")
LINE(1560) GOTO(1720)
LINE(1570) PRINT("October 11 ")
LINE(1580) GOTO(1720)
LINE(1590) PRINT("October 25 ")
LINE(1600) GOTO(1720)
LINE(1610) PRINT("November 8 ")
LINE(1620) GOTO(1720)
LINE(1630) PRINT("November 22 ")
LINE(1640) GOTO(1720)
LINE(1650) PRINT("December 6 ")
LINE(1660) GOTO(1720)
LINE(1670) PRINT("December 20 ")
LINE(1680) GOTO(1720)
LINE(1690) PRINT("You have been on the trail too long ------")
LINE(1700) PRINT("^1Your family dies in the first blizzard of winter")
LINE(1710) GOTO(5170)
LINE(1720) PRINT("1847")
LINE(1730) PRINT("")

LINE(1740) REM("***BEGINNING EACH TURN***")
LINE(1750) IFVAR(F, >=, 0) THEN(1770)
LINE(1760) LET(F, 0)
LINE(1770) IFVAR(B, >=, 0) THEN(1790)
LINE(1780) LET(B, 0)
LINE(1790) IFVAR(C, >=, 0) THEN(1810)
LINE(1800) LET(C, 0)
LINE(1810) IFVAR(M1, >=, 0) THEN(1830)
LINE(1820) LET(M1, 0)
LINE(1830) IFVAR(F, >=, 13) THEN(1850)
LINE(1840) PRINT("You'd better do some hunting or buy ^3FOOD^7 and ^1SOON^7!!!!")
LINE(1850) LET(F, INT(VAR(F)))
LINE(1860) LET(B, INT(VAR(B)))
LINE(1870) LET(C, INT(VAR(C)))
LINE(1880) LET(M1, INT(VAR(M1)))
LINE(1890) LET(T, INT(VAR(T)))
LINE(1900) LET(M, INT(VAR(M)))
LINE(1910) LET(M2, VAR(M))
LINE(1920) IFVAR(S4, ==, 1) THEN(1950)
LINE(1930) IFVAR(K8, ==, 1) THEN(1950)
LINE(1940) GOTO(1990)
LINE(1950) LET(T, VAR(T) - 20)
LINE(1960) IFVAR(T, <, 0) THEN(5080)
LINE(1970) PRINT("Doctor's bill is ^2$20")
LINE(1980) LET(K8, 0)
LINE(1981) LET(S4, 0)
LINE(1990) IFVAR(M9, ==, 1) THEN(2020)
LINE(2000) PRINTF("Total mileage is %d", VAR(M))
LINE(2010) GOTO(2040)
LINE(2020) PRINT("Total mileage is 950")
LINE(2030) LET(M9, 0)
LINE(2040) PRINT("^3FOOD ^4BULLETS ^5CLOTHING ^6MISC. SUPP. ^2CASH")
LINE(2050) PRINTF("^3%d     ^4%d        ^5%d         ^6%d            ^2%d", VAR(F), VAR(B), VAR(C), VAR(M1), VAR(T))
LINE(2060) IFVAR(X1, ==, -1) THEN(2170)
LINE(2070) LET(X1, VAR(X1) * -1)

LINE(2080) PRINT("Do you want to (^21^7) stop at the next fort, (^22^7) hunt, ")
LINE(2090) PRINT("or (^23^7) continue")
LINE(2091) LET(X, 0)
LINE(2100) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(2110) INPUTSET(X)
LINE(2110) IFVAR(X, >, 2) THEN(2150)
LINE(2120) IFVAR(X, <, 1) THEN(2150)
LINE(2130) LET(X, INT(VAR(X)))
LINE(2140) GOTO(2270)
LINE(2150) LET(X, 3)
LINE(2160) GOTO(2270)

LINE(2170) PRINT("Do you want to (^21^7) hunt, or (^22^7) continue")
LINE(2181) LET(X, 0)
LINE(2180) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(2190) INPUTSET(X)
LINE(2190) IFVAR(X, ==, 1) THEN(2210)
LINE(2200) LET(X, 2)
LINE(2210) LET(X, VAR(X) + 1)
LINE(2220) IFVAR(X, ==, 3) THEN(2260)
LINE(2230) IFVAR(B, >, 39) THEN(2260)
LINE(2240) PRINT("Tough you need more ^4BULLETS^7 to go hunting")
LINE(2250) GOTO(2170)
LINE(2260) LET(X1, VAR(X1) * -1)
LINE(2270) ON3(VAR(X), 2290, 2540, 2720)

LINE(2290) REM("***STOPPING AT FORT***")
LINE(2290) PRINT("Enter what you wish to spend on the following")
LINE(2300) PRINT("^3FOOD")
LINE(2310) GOSUB(2329)
LINE(2320) GOTO(2410)
LINE(2329) LET(P, 0)
LINE(2330) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(2340) INPUTSET(P)
LINE(2340) IFVAR(P, <, 0) THEN(2400)
LINE(2350) LET(T, VAR(T) - VAR(P))
LINE(2360) IFVAR(T, >=, 0) THEN(2400)
LINE(2370) PRINT("You don't have that much--keep your spending down")
LINE(2375) PRINT("You miss your chance to spend on that item")
LINE(2380) LET(T, VAR(T) + VAR(P))
LINE(2390) LET(P, 0)
LINE(2400) RETURN()
LINE(2410) LET(F, VAR(F) + 2 / 3 * VAR(P))
LINE(2420) PRINT("^4AMMUNITION")
LINE(2430) GOSUB(2330)
LINE(2440) LET(B, INT(VAR(B) + 2 / 3 * VAR(P) * 50))
LINE(2450) PRINT("^5CLOTHING")
LINE(2460) GOSUB(2330)
LINE(2470) LET(C, VAR(C) + 2 / 3 * VAR(P))
LINE(2480) PRINT("^6MISCELLANEOUS SUPPLIES")
LINE(2490) GOSUB(2330)
LINE(2500) LET(M1, VAR(M1) + 2 / 3 * VAR(P))
LINE(2510) LET(M, VAR(M) - 45)
LINE(2520) GOTO(2720)

LINE(2540) REM("***HUNTING***")
LINE(2540) IFVAR(B, >, 39) THEN(2570)
LINE(2550) PRINT("Tough---you need M0RE ^4BULLETS^7 to go hunting")
LINE(2560) GOTO(2080)
LINE(2570) LET(M, VAR(M) - 45)
LINE(2580) GOSUB(6140)
LINE(2590) IFVAR(B1, <=, 1) THEN(2660)
LINE(2600) IFVAL(100 * RND(), <, 13 * VAR(B1)) THEN(2710)
LINE(2610) LET(F, VAR(F) + 48 - 2 * VAR(B1))
LINE(2620) PRINT("NICE SHOT--RIGHT ON TARGET--GOOD EATIN' TONIGHT!!")
LINE(2630) LET(B, VAR(B) - 10 - 3 * VAR(B1))
LINE(2640) GOTO(2720)

LINE(2660) REM("**BELLS IN LINE 2660**")
LINE(2660) PRINT("RIGHT BETWEEN THE EYES---YOU GOT A BIG ONE!!!!")
LINE(2670) PRINT("FULL BELLIES TONIGHT!")
LINE(2680) LET(F, VAR(F) + 52 + RND() * 6)
LINE(2690) LET(B, VAR(B) - 10 - RND() * 4)
LINE(2700) GOTO(2720)
LINE(2710) PRINT("You missed---and your dinner got away.....")
LINE(2720) IFVAR(F, >=, 13) THEN(2750)
LINE(2730) GOTO(5060)

LINE(2750) REM("***EATING***")
LINE(2750) PRINT("Do you want to eat (^21^7) POORLY   (^22^7) MODERATELY")
LINE(2760) PRINT("or (^23^7) WELL")
LINE(2770) LET(E, 0)
LINE(2771) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(2780) INPUTSET(E)
LINE(2780) IFVAR(E, >, 3) THEN(2750)
LINE(2790) IFVAR(E, <, 1) THEN(2750)
LINE(2800) LET(E, INT(VAR(E)))
LINE(2810) LET(F, VAR(F) - 8 - 5 * VAR(E))
LINE(2820) IFVAR(F, >=, 0) THEN(2860)
LINE(2830) LET(F, VAR(F) + 8 + 5 * VAR(E))
LINE(2840) PRINT("You can't eat that well")
LINE(2850) GOTO(2750)
LINE(2860) LET(M, VAR(M) + 200 + (VAR(A) - 220) / 5 + 10 * RND())
LINE(2870) LET(L1, 0)
LINE(2871) LET(C1, 0)

LINE(2890) REM("***RIDERS ATTACK***")
LINE(2890) IFVAL(RND() * 10, >, ((VAR(M) / 100 - 4) ^ 2 + 72) / ((VAR(M) / 100 - 4) ^ 2 + 12) - 1) THEN(3550)
LINE(2900) PRINT("RIDERS AHEAD.   They ")
LINE(2910) LET(S5, 0)
LINE(2920) IFVAL(RND(), <, .8) THEN(2950)
LINE(2930) PRINT("don't ")
LINE(2940) LET(S5, 1)
LINE(2950) PRINT("look hostile")
LINE(2960) PRINT("^3Tactics")
LINE(2970) PRINT("(^21^7) RUN  (^22^7) ATTACK  (^23^7) CONTINUE  (^24^7) CIRCLE WAGONS")
LINE(2980) IFVAL(RND(), >, .2) THEN(3000)
LINE(2990) LET(S5, 1 - VAR(S5))
LINE(3000) LET(T1, 0)
LINE(3001) INPUT("")
/* new addition for QC, work around a lack of input handling */
LINE(3010) INPUTSET(T1)
LINE(3010) IFVAR(T1, <, 1) THEN(2970)
LINE(3020) IFVAR(T1, >, 4) THEN(2970)
LINE(3030) LET(T1, INT(VAR(T1)))
LINE(3040) IFVAR(S5, ==, 1) THEN(3330)
LINE(3050) IFVAR(T1, >, 1) THEN(3110)
LINE(3060) LET(M, VAR(M) + 20)
LINE(3070) LET(M1, VAR(M1) - 15)
LINE(3080) LET(B, VAR(B) - 150)
LINE(3090) LET(A, VAR(A) - 40)
LINE(3100) GOTO(3470)
LINE(3110) IFVAR(T1, >, 2) THEN(3240)
LINE(3120) GOSUB(6140)
LINE(3130) LET(B, VAR(B) - VAR(B1) * 40 - 80)
LINE(3140) IFVAR(B1, >, 1) THEN(3170)
LINE(3150) PRINT("Nice shooting---you drove them off")
LINE(3160) GOTO(3470)
LINE(3170) IFVAR(B1, <=, 4) THEN(3220)
LINE(3180) PRINT("Lousy shot---you got knifed")
LINE(3190) LET(K8, 1)
LINE(3200) PRINT("You have to see ol' Doc Blanchard")
LINE(3210) GOTO(3470)
LINE(3220) PRINT("Kinda slow with your Colt .45")
LINE(3230) GOTO(3470)
LINE(3240) IFVAR(T1, >, 3) THEN(3290)
LINE(3250) IFVAL(RND(), >, .8) THEN(3450)
LINE(3260) LET(B, VAR(B) - 150)
LINE(3270) LET(M1, VAR(M1) - 15)
LINE(3280) GOTO(3470)
LINE(3290) GOSUB(6140)
LINE(3300) LET(B, VAR(B) - VAR(B1) * 30 - 80)
LINE(3310) LET(M, VAR(M) - 25)
LINE(3320) GOTO(3140)
LINE(3330) IFVAR(T1, >, 1) THEN(3370)
LINE(3340) LET(M, VAR(M) + 15)
LINE(3350) LET(A, VAR(A) - 10)
LINE(3360) GOTO(3470)
LINE(3370) IFVAR(T1, >, 2) THEN(3410)
LINE(3380) LET(M, VAR(M) - 5)
LINE(3390) LET(B, VAR(B) - 100)
LINE(3400) GOTO(3470)
LINE(3410) IFVAR(T1, >, 3) THEN(3430)
LINE(3420) GOTO(3470)
LINE(3430) LET(M, VAR(M) - 20)
LINE(3440) GOTO(3470)
LINE(3450) PRINT("They did not attack")
LINE(3460) GOTO(3550)
LINE(3470) IFVAR(S5, ==, 0) THEN(3500)
LINE(3480) PRINT("Riders were ^2FRIENDLY^7, but check for possible losses")
LINE(3490) GOTO(3550)
LINE(3500) PRINT("Riders were ^1HOSTILE^7--check for losses")
LINE(3510) IFVAR(B, >=, 0) THEN(3550)
LINE(3520) PRINT("^1You ran out of bullets and got massacred by the riders")
LINE(3530) GOTO(5170)

LINE(3550) REM("***SELECTION OF EVENTS***")
LINE(3550) LET(D1, 0)
LINE(3560) RESTORE()
LINE(3570) LET(R1, 100 * RND())
LINE(3580) LET(D1, VAR(D1) + 1)
LINE(3590) IFVAR(D1, ==, 16) THEN(4670)
LINE(3595) LET(D, 0)
LINE(3600) READ(D)
LINE(3610) IFVAR(R1, >, VAR(D)) THEN(3580)
LINE(3620) DATA(6, 11, 13, 15, 17, 22, 32, 35, 37, 42, 44, 54, 64, 69, 95)
LINE(3630) IFVAR(D1, >, 10) THEN(3650)
LINE(3640) ON10(VAR(D1), 3660, 3700, 3740, 3790, 3820, 3850, 3880, 3960, 4130, 4190)
LINE(3650) ON6(VAR(D1) - 10, 4220, 4290, 4340, 4560, 4610, 4670)
LINE(3660) PRINT("Wagon breaks down--lose time and ^6SUPPLIES^7 fixing it")
LINE(3670) LET(M, VAR(M) - 15 - 5 * RND())
LINE(3680) LET(M1, VAR(M1) - 8)
LINE(3690) GOTO(4710)
LINE(3700) PRINT("^9OX^7 injures leg--slows you down rest of trip")
LINE(3710) LET(M, VAR(M) - 25)
LINE(3720) LET(A, VAR(A) - 20)
LINE(3730) GOTO(4710)
LINE(3740) PRINT("Bad luck--your daughter broke her arm")
LINE(3750) PRINT("You had to stop and use ^6SUPPLIES^7 to make a sling")
LINE(3760) LET(M, VAR(M) - 5 - 4 * RND())
LINE(3770) LET(M1, VAR(M1) - 2 - 3 * RND())
LINE(3780) GOTO(4710)
LINE(3790) PRINT("^9OX^7 wanders off--spend time looking for it")
LINE(3800) LET(M, VAR(M) - 17)
LINE(3810) GOTO(4710)
LINE(3820) PRINT("Your son gets lost---spend half the day looking for him")
LINE(3830) LET(M, VAR(M) - 10)
LINE(3840) GOTO(4710)
LINE(3850) PRINT("Unsafe water--lose time looking for clean spring")
LINE(3860) LET(M, VAR(M) - 10 * RND() - 2)
LINE(3870) GOTO(4710)
LINE(3880) IFVAR(M, >, 950) THEN(4490)
LINE(3890) PRINT("Heavy rains---time and ^6SUPPLIES^7 lost")
LINE(3910) LET(F, VAR(F) - 10)
LINE(3920) LET(B, VAR(B) - 500)
LINE(3930) LET(M1, VAR(M1) - 15)
LINE(3940) LET(M, VAR(M) - 10 * RND() - 5)
LINE(3950) GOTO(4710)
LINE(3960) PRINT("^1BANDITS ATTACK")
LINE(3970) GOSUB(6140)
LINE(3980) LET(B, VAR(B) - 20 * VAR(B1))
LINE(3990) IFVAR(B, >=, 0) THEN(4030)
LINE(4000) PRINT("You ran out of bullets---they get lots of ^2CASH")
LINE(4010) LET(T, VAR(T) / 3)
LINE(4020) GOTO(4040)
LINE(4030) IFVAR(B1, <=, 1) THEN(4100)
LINE(4040) PRINT("You got shot in the leg and they took one of your ^9OXEN")
LINE(4050) LET(K8, 1)
LINE(4060) PRINT("Better have a doc look at your wound")
LINE(4070) LET(M1, VAR(M1) - 5)
LINE(4080) LET(A, VAR(A) - 20)
LINE(4090) GOTO(4710)
LINE(4100) PRINT("QUICKEST DRAW OUTSIDE OF DODGE CITY!!!")
LINE(4110) PRINT("YOU GOT 'EM!")
LINE(4120) GOTO(4710)
LINE(4130) PRINT("There was afire in your wagon--^3FOOD^7 and ^6SUPPLIES^7 DAMAGED!")
LINE(4140) LET(F, VAR(F) - 40)
LINE(4150) LET(B, VAR(B) - 400)
LINE(4160) LET(M1, VAR(M1) - RND() * 8 - 3)
LINE(4170) LET(M, VAR(M) - 15)
LINE(4180) GOTO(4710)
LINE(4190) PRINT("Lose your way in heavy fog---time is lost")
LINE(4200) LET(M, VAR(M) - 10 - 5 * RND())
LINE(4210) GOTO(4710)
LINE(4220) PRINT("You killed a poisonous snake after it bit you")
LINE(4230) LET(B, VAR(B) - 10)
LINE(4240) LET(M1, VAR(M1) - 5)
LINE(4250) IFVAR(M1, >=, 0) THEN(4280)
LINE(4260) PRINT("^1You die of snakebite since you have no medicine")
LINE(4270) GOTO(5170)
LINE(4280) GOTO(4710)
LINE(4290) PRINT("Wagon gets swamped fording river--lose ^3FOOD^7 and ^5CLOTHES")
LINE(4300) LET(F, VAR(F) - 30)
LINE(4310) LET(C, VAR(C) - 20)
LINE(4320) LET(M, VAR(M) - 20 - 20 * RND())
LINE(4330) GOTO(4710)
LINE(4340) PRINT("^1WILD ANIMALS ATTACK!")
LINE(4350) GOSUB(6140)
LINE(4360) IFVAR(B, >, 39) THEN(4410)
LINE(4370) PRINT("You were too low on ^4BULLETS^7--")
LINE(4380) PRINT("^1The wolves overpowered you")
LINE(4390) LET(K8, 1)
LINE(4400) GOTO(5120)
LINE(4410) IFVAR(B1, >, 2) THEN(4440)
LINE(4420) PRINT("Nice shootin' pardner---they didn't get much")
LINE(4430) GOTO(4450)
LINE(4440) PRINT("Slow on the draw---they got at your ^3FOOD^7 and ^5CLOTHES")
LINE(4450) LET(B, VAR(B) - 20 * VAR(B1))
LINE(4460) LET(C, VAR(C) - VAR(B1) * 4)
LINE(4470) LET(F, VAR(F) - VAR(B1) * 8)
LINE(4480) GOTO(4710)
LINE(4490) PRINT("Cold weather---BRRRRRRR!---you ")
LINE(4500) IFVAR(C, >, 22 + 4 * RND()) THEN(4530)
LINE(4510) PRINT("don't ")
LINE(4520) LET(C1, 1)
LINE(4530) PRINT("have enough ^5CLOTHING^7 to keep you warm")
LINE(4540) IFVAR(C1, ==, 0) THEN(4710)
LINE(4550) GOTO(6300)
LINE(4560) PRINT("HAIL STORM---^6SUPPLIES^7 damaged")
LINE(4570) LET(M, VAR(M) - 5 - RND() * 10)
LINE(4580) LET(B, VAR(B) - 200)
LINE(4590) LET(M1, VAR(M1) - 4 - RND() * 3)
LINE(4600) GOTO(4710)
LINE(4610) IFVAR(E, ==, 1) THEN(6300)
LINE(4620) IFVAR(E, ==, 3) THEN(4650)
LINE(4630) IFVAL(RND(), >, .25) THEN(6300)
LINE(4640) GOTO(4710)
LINE(4650) IFVAL(RND(), <, .5) THEN(6300)
LINE(4660) GOTO(4710)
LINE(4670) PRINT("Helpful Indians show you where to find more ^3FOOD")
LINE(4680) LET(F, VAR(F) + 14)
LINE(4690) GOTO(4710)

LINE(4700) REM("***MOUNTAINS***")
LINE(4710) IFVAR(M, <=, 950) THEN(1230)
LINE(4720) IFVAL(RND() * 10, >, 9 - ((VAR(M) / 100 - 15) ^ 2 + 72) / ((VAR(M) / 100 - 15) ^ 2 + 12)) THEN(4860)
LINE(4730) PRINT("^3Rugged Mountains")
LINE(4740) IFVAL(RND(), >, .1) THEN(4780)
LINE(4750) PRINT("You got lost---lose valuable time trying to find trail!")
LINE(4760) LET(M, VAR(M) - 60)
LINE(4770) GOTO(4860)
LINE(4780) IFVAL(RND(), >, .11) THEN(4840)
LINE(4790) PRINT("Wagon DAMAGED!-Lose time and ^6SUPPLIES")
LINE(4800) LET(M1, VAR(M1) - 5)
LINE(4810) LET(B, VAR(B) - 200)
LINE(4820) LET(M, VAR(M) - 20 - 30 * RND())
LINE(4830) GOTO(4860)
LINE(4840) PRINT("The going gets slow")
LINE(4850) LET(M, VAR(M) - 45 - RND() / .02)
LINE(4860) IFVAR(F1, ==, 1) THEN(4900)
LINE(4870) LET(F1, 1)
LINE(4880) IFVAL(RND(), <, .8) THEN(4970)
LINE(4890) PRINT("You made it safely through South Pass--no snow")
LINE(4900) IFVAR(M, <, 1700) THEN(4940)
LINE(4910) IFVAR(F2, ==, 1) THEN(4940)
LINE(4920) LET(F2, 1)
LINE(4930) IFVAL(RND(), <, .7) THEN(4970)
LINE(4940) IFVAR(M, >, 950) THEN(1230)
LINE(4950) LET(M9, 1)
LINE(4960) GOTO(1230)
LINE(4970) PRINT("Blizzard in mountain pass--time and ^6SUPPLIES^7 lost")
LINE(4980) LET(L1, 1)
LINE(4990) LET(F, VAR(F) - 25)
LINE(5000) LET(M1, VAR(M1) - 10)
LINE(5010) LET(B, VAR(B) - 300)
LINE(5020) LET(M, VAR(M) - 30 - 40 * RND())
LINE(5030) IFVAR(C, <, 18 + 2 * RND()) THEN(6300)
LINE(5040) GOTO(4940)

LINE(5060) REM("***DYING***")
LINE(5060) PRINT("^1You ran out of ^3FOOD^1 and starved to death")
LINE(5070) GOTO(5170)
LINE(5080) LET(T, 0)
LINE(5090) PRINT("You can't afford a doctor")
LINE(5100) GOTO(5120)
LINE(5110) PRINT("You ran out of medical ^6SUPPLIES")
LINE(5120) PRINT("^1You died of ")
LINE(5130) IFVAR(K8, ==, 1) THEN(5160)
LINE(5140) PRINT("^1PNEUMONIA")
LINE(5150) GOTO(5170)
LINE(5160) PRINT("^1INJURIES")
LINE(5170) PRINT("")
LINE(5180) PRINT("Due to your unfortunate situation, there are a few")
LINE(5190) PRINT("formalities we must go through")
LINE(5200) PRINT("")
LINE(5210) PRINT("Would you like a minister?")
LINE(5220) INPUT("")
LINE(5230) PRINT("Would you like a fancy funeral?")
LINE(5240) INPUT("")
LINE(5250) INPUT("Would you like us to inform your next of kin?")
LINE(5260) INPUT("")
LINE(5270) IFINPUTSTR("y") THEN(5310)
LINE(5280) PRINT("But your aunt Sadie in St. Louis is really worried about you")
LINE(8290) PRINT("")
LINE(8300) GOTO(5330)
LINE(5310) PRINT("That will be ^2$4.50^7 for the telegraph charge.")
LINE(5320) PRINT("")
LINE(5330) PRINT("WE THANK YOU FOR THIS INFORMATION AND WE ARE SORRY YOU")
LINE(5340) PRINT("DIDN'T MAKE IT TO THE GREAT TERRITORY OF OREGON")
LINE(5350) PRINT("BETTER LUCK NEXT TIME")
LINE(5360) PRINT("")
LINE(5370) PRINT("")
LINE(5380) PRINTF("%sSINCERELY", TAB(30))
LINE(5390) PRINT("")
LINE(5400) PRINTF("%sTHE OREGON CITY CHAMBER OF COMMERCE", TAB(17))
LINE(5410) GOTO(9999)

LINE(5430) REM("***FINAL TURN***")
LINE(5430) LET(F9, (2040 - VAR(M2)) / (VAR(M) - VAR(M2)))
LINE(5440) LET(F, VAR(F) + (1 - VAR(F9)) * (8 * 5 * VAR(E)))
LINE(5450) PRINT("")

LINE(5470) REM("**BELLS IN LINES 5470, 5480**")
LINE(5470) PRINT("You finally arrived at Oregon City")
LINE(5480) PRINT("after 2040 long miles---HOORAY !!!!!")
LINE(5490) PRINT("^3A REAL PIONEER!")
LINE(5500) PRINT("")
LINE(5510) LET(F9, INT(VAR(F9) * 14))
LINE(5520) LET(D3, VAR(D3) * 14 + VAR(F9))
LINE(5530) LET(F9, VAR(F9) + 1)
LINE(5540) IFVAR(F9, <, 8) THEN(5560)
LINE(5550) LET(F9, VAR(F9) - 7)
LINE(5560) ON6(VAR(F9), 5570, 5590, 5630, 5650, 5670, 5690)
LINE(5570) PRINT("Monday ")
LINE(5580) GOTO(5700)
LINE(5590) PRINT("Tuesday ")
LINE(5600) GOTO(5700)
LINE(5610) PRINT("Wednesday ")
LINE(5620) GOTO(5700)
LINE(5630) PRINT("Thursday ")
LINE(5640) GOTO(5700)
LINE(5650) PRINT("Friday ")
LINE(5660) GOTO(5700)
LINE(5670) PRINT("Saturday ")
LINE(5680) GOTO(5700)
LINE(5690) PRINT("Sunday ")
LINE(5700) IFVAR(D3, >, 124) THEN(5740)
LINE(5710) LET(D3, VAR(D3) - 93)
LINE(5720) PRINTF("July %d 1847", VAR(D3))
LINE(5730) GOTO(5920)
LINE(5740) IFVAR(D3, >, 155) THEN(5780)
LINE(5750) LET(D3, VAR(D3) - 124)
LINE(5760) PRINTF("August %d 1847", VAR(D3))
LINE(5770) GOTO(5920)
LINE(5780) IFVAR(D3, >, 155) THEN(5820)
LINE(5790) LET(D3, VAR(D3) - 155)
LINE(5800) PRINTF("September %d 1847", VAR(D3))
LINE(5810) GOTO(5920)
LINE(5820) IFVAR(D3, >, 216) THEN(5860)
LINE(5830) LET(D3, VAR(D3) - 155)
LINE(5840) PRINTF("October %d 1847", VAR(D3))
LINE(5850) GOTO(5920)
LINE(5860) IFVAR(D3, >, 246) THEN(5900)
LINE(5870) LET(D3, VAR(D3) - 246)
LINE(5880) PRINTF("November %d 1847", VAR(D3))
LINE(5890) GOTO(5920)
LINE(5900) LET(D3, VAR(D3) - 246)
LINE(5910) PRINTF("December %d 1847", VAR(D3))
LINE(5920) PRINT("")
LINE(5930) PRINT("^3FOOD ^4BULLETS ^5CLOTHING ^6MISC. SUPP. ^2CASH")
LINE(5940) IFVAR(B, >, 0) THEN(5960)
LINE(5950) LET(B, 0)
LINE(5960) IFVAR(C, >, 0) THEN(5980)
LINE(5970) LET(C, 0)
LINE(5980) IFVAR(M1, >, 0) THEN(6000)
LINE(5990) LET(M1, 0)
LINE(6000) IFVAR(T, >, 0) THEN(6020)
LINE(6010) LET(T, 0)
LINE(6020) IFVAR(F, >, 0) THEN(6040)
LINE(6030) LET(F, 0)
LINE(6040) PRINTF("^3%d     ^4%d        ^5%d         ^6%d           ^2%d", INT(VAR(F)), INT(VAR(B)), INT(VAR(C)), INT(VAR(M1)), INT(VAR(T)))
LINE(6050) PRINT("")
LINE(6060) PRINTF("%sPresident James K. Polk sends you his", TAB(11))
LINE(6070) PRINTF("%sHEARTIEST CONGRATULATIONS", TAB(17))
LINE(6080) PRINT("")
LINE(6090) PRINTF("%sand wishes you a PROSPEROUS LIFE AHEAD", TAB(11))
LINE(6100) PRINT("")
LINE(6110) PRINTF("%sat your new home", TAB(22))
LINE(6120) GOTO(9999)

LINE(6131) REM("***SHOOTING SUB-ROUTINE***")
LINE(6131) REM("THE METHOD OF TIMING THE SHOOTING")
LINE(6132) REM("WILL VARY FROM SYSTEM TO SYSTEM.")
LINE(6133) REM("USERS WILL PROBABLY PREFER TO USE")
LINE(6134) REM("IF TIMING ON THE USER'S SYSTEM IS HIGHLY SUSCEPTIBLE")
LINE(6135) REM("TO SYSTEM RESPONSE TIME, THE FORMULA IN LINE 6240 CAN")
LINE(6136) REM("BE TAILORED TO ACCOMODATE THIS BY EITHER INCREASING")
LINE(6137) REM("OR DECREASING THE 'SHOOTING' TIME RECORDED BY THE SYSTEM.")
LINE(6140) REM("MOVED TO TOP OF PROGRAM DIM S$(5)")
/* these lines are not necessary in this implementation, as they are stored in an array */
/*
LINE(6150) LET S$(1)="bang"
LINE(6160) LET S$(2)="blam"
LINE(6170) LET S$(3)="pow"
LINE(6180) LET S$(4)="wham"
*/
// NOTE: original code offsets by 1, we do not for array access reasons
LINE(6190) LET(S6, INT(RND() * 4))
LINE(6220) PRINTF("^1Type ^7%s", S(S6)) /* NOTE: adjusted from 6200 for quicker shot reaction times */
LINE(6220) LET(B3, CLK(0)) /* NOTE: adjusted from 6210 for quicker shot reaction times */
LINE(6220) INPUT("")
LINE(6221) LET(B1, CLK(-OREGON_TICKRATE)) /* NOTE: adjusted from 6230 to allow for more accurate word timings */
LINE(6240) LET(B1, ((VAR(B1) - VAR(B3)) * 2) - (VAR(D9) - 1))
LINE(6250) PRINT("")
LINE(6252) REM("PRINTF(\"B1 = %d\", VAR(B1))")
LINE(6255) IFVAR(B1, >, 0) THEN(6260)
LINE(6257) LET(B1, 0)
LINE(6260) IFINPUTSTR(S(S6)) THEN(6280)
LINE(6270) LET(B1, 9)
LINE(6280) RETURN()

LINE(6300) REM("***ILLNESS SUB-ROUTINE***")
LINE(6300) IFVAL(100 * RND(), <, 10 + 35 * (VAR(E) - 1)) THEN(6370)
LINE(6310) IFVAL(100 * RND(), <, 100 - (40 / 4 ^ (VAR(E) - 1))) THEN(6410)
LINE(6320) PRINT("^1SERIOUS ILLNESS")
LINE(6330) PRINT("You must stop for medical attention")
LINE(6340) LET(M1, VAR(M1) - 10)
LINE(6350) LET(S4, 1)
LINE(6360) GOTO(6440)
LINE(6370) PRINT("Mild illness--medicine used")
LINE(6380) LET(M, VAR(M) - 5)
LINE(6390) LET(M1, VAR(M1) - 2)
LINE(6400) GOTO(6440)
LINE(6410) PRINT("BAD illness---medicine used")
LINE(6420) LET(M, VAR(M) - 5)
LINE(6430) LET(M1, VAR(M1) - 5)
LINE(6440) IFVAR(M1, <, 0) THEN(5110)
LINE(6450) IFVAR(L1, ==, 1) THEN(4940)
LINE(6460) GOTO(4710)

LINE(6480) REM("***IDENTIFICATION OF VARIABLES IN THE PROGRAM***")
LINE(6480) REM("A = AMOUNT SPENT ON ANIMALS")
LINE(6490) REM("B = AMOUNT SPENT ON AMMUNITION")
LINE(6500) REM("B1 = ACTUAL RESPONSE TIME FOR INPUTTING \"BANG\"")
LINE(6510) REM("B3 = CLOCK TIME AT START OF INPUTTING \"BANG\"")
LINE(6520) REM("C = AMOUNT SPENT ON CLOTHING")
LINE(6530) REM("C1 = FLAG FOR INSUFFICIENT CLOTHING IN COLD WEATHER")
LINE(6540) REM("C$ = YES/NO RESPONSE TO QUESTIONS")
LINE(6550) REM("D1 = COUNTER IN GENERATING EVENTS")
LINE(6560) REM("D3 = TURN NUMBER FOR SETTING DATE")
LINE(6570) REM("D4 = CURRENT DATE")
LINE(6580) REM("D9 = CHOICE OF SHOOTING EXPERTISE LEVEL")
LINE(6590) REM("E = CHOICE OF EATING")
LINE(6600) REM("F = AMOUNT SPENT ON FOOD")
LINE(6610) REM("F1 = FLAG FOR CLEARING SOUTH PASS")
LINE(6620) REM("F2 = FLAG FOR CLEARING BLUE MOUNTAINS")
LINE(6630) REM("F9 = FRACTION OF 2 WEEKS TRAVELED ON FINAL TURN")
LINE(6640) REM("K8 = FLAG FOR INJURY")
LINE(6650) REM("L1 = FLAG FOR BLIZZARD")
LINE(6660) REM("M = TOTAL MILEAGE WHOLE TRIP")
LINE(6670) REM("M1 = AMOUNT SPENT ON MISCELLANEOUS SUPPLIES")
LINE(6680) REM("M2 = TOTAL MILEAGE UP THROUGH PREVIOUS TURN")
LINE(6690) REM("M9 = FLAG FOR CLEARING SOUTH PASS IN SETTING MILEAGE")
LINE(6700) REM("P = AMOUNT SPENT ON ITEMS AT FORT")
LINE(6710) REM("R1 = RANDOM NUMBER IN CHOOSING EVENTS")
LINE(6720) REM("S4 = FLAG FOR ILLNESS")
LINE(6730) REM("S5 = ""HOSTILITY OF RIDERS"" FACTOR")
LINE(6740) REM("S6 = SHOOTING WORD SELECTOR")
LINE(6750) REM("S$ = VARIATIONS OF SHOOTING WORD")
LINE(6760) REM("T = CASH LEFT OVER AFTER INITIAL PURCHASES")
LINE(6770) REM("T1 = CHOICE OF TACTICS WHEN ATTACKED")
LINE(6780) REM("X = CHOICE OF ACTION FOR EACH TURN")
LINE(6790) REM("X1 = FLAG FOR FORT OPTION")
LINE(9999) END()

#undef REM
#undef PRINT
#undef PRINTF
#undef LINE
#undef GOTO
#undef LET
#undef LETSTR
#undef INPUT
#undef IFINPUT
#undef IFINPUTSTR
#undef IFVAR
#undef IFVAL
#undef THEN
#undef ON10
#undef ON6
#undef ON3
#undef INT
#undef GOSUB
#undef RETURN
#undef RND
#undef RESTORE
#undef READ
#undef DATA
#undef TAB
#undef S
#undef CLK
#undef END
}