// Rogue Teamplay Variants Message of the Day function
// Feb'97 by ZOID <zoid@threewave.com>
// Under contract to id software for Rogue Entertainment

.float motd_time;
.float motd_count;

void MOTD(entity this)
{
	if(this.motd_count < 5)
	{
		if(teamplay > 3 && teamplay < 7)
		{
			string tp = ftos(teamplay);
			stuffcmd(this, "teamplay ");
			stuffcmd(this, tp);
			stuffcmd(this, "\n");
		}
		this.motd_time = time + 1;
		this.motd_count = this.motd_count + 1;
/*
		if(teamplay == TEAM_NORMAL_NODAMAGE)
			centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nTeam play: No Friendly Fire\n");
		else if(teamplay == TEAM_NORMAL_DAMAGE)
			centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nTeam play: Friendly Fire\n");
*/
		if(teamplay == TEAM_DMATCH_TAG)
			centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nDeathmatch Tag!\n");
		else if(teamplay == TEAM_CTF)
			if(this.steam == TEAM1)
				centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n\nYou are Red team!\n");
			else
				centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n\nYou are Blue team!\n");
		else if(teamplay == TEAM_CTF_ONEFLAG)
			if(this.steam == TEAM1)
				centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(One Flag Mode)\n\nYou are Red team!\n");
			else
				centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(One Flag Mode)\n\nYou are Blue team!\n");
		else if(teamplay == TEAM_CTF_ALT)
			if(this.steam == TEAM1)
				centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(Three Team Mode)\n\nYou are Red team!\n");
			else if(this.steam == TEAM2)
				centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(Three Team Mode)\n\nYou are Blue team!\n");
			else
				centerprint(this, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(Three Team Mode)\n\nYou are Grey team!\n");
		return;
	}
	this.motd_time = 0;
}

void CheckMOTD(entity this)
{
//	if(this.motd_time && this.motd_time < time)
	if(this.motd_time)
	{ 
		if(this.motd_time < time)
			MOTD(this);
	}
}

void SetMOTD(entity this)
{
	this.motd_time = time + 3;
	if(teamplay == 3)
		this.motd_count = 2;
	else
		this.motd_count = 0;
}
