#include "cl_mmm.qh"

#include <client/draw.qh>
#include <client/hud/panel/modicons.qh>

void HUD_Mod_MMM(vector pos, vector mySize)
{
	mod_active = 1; // mmm should always show the mod HUD

	int mystatus = entcs_receiver(player_localnum).mmm_status;
	string player_text = "";
	vector player_color = '1 1 1';
	//string player_icon = "";
	if(mystatus == MMM_STATUS_MURDERER)
	{
		player_text = _("Murderer");
		player_color = '1 0 0';
		//player_icon = "player_red";
	}
	else if(mystatus == MMM_STATUS_CIVILIAN)
	{
		player_text = _("Civilian");
		player_color = '0 1 0';
		//player_icon = "player_neutral";
	}
	else if(mystatus == MMM_STATUS_DETECTIVE)
	{
		player_text = _("Detective");
		player_color = '0 0 1';
		//player_icon = "player_blue";
	}
	else
	{
		// if the player has no valid status, don't draw anything
		return;
	}

	string time_text = string_null;
	vector timer_color = '1 1 1';
	if(!STAT(GAME_STOPPED) && !warmup_stage && STAT(MMM_ROUNDTIMER) > 0)
	{
		float timeleft = max(0, STAT(MMM_ROUNDTIMER) - time);
		timeleft = ceil(timeleft);
		float minutesLeft = floor(timeleft / 60);
		time_text = seconds_tostring(timeleft);
		if(intermission_time || minutesLeft >= 5 || warmup_stage || STAT(MMM_ROUNDTIMER) == 0)
			timer_color = '1 1 1'; //white
		else if(minutesLeft >= 1)
			timer_color = '1 1 0'; //yellow
		else
			timer_color = '1 0 0'; //red
	}
	
	
	//drawpic_aspect_skin(pos, player_icon, vec2(0.5 * mySize.x, mySize.y), '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	if(!time_text)
		drawstring_aspect(pos, player_text, vec2(mySize.x, mySize.y), player_color, panel_fg_alpha, DRAWFLAG_NORMAL);
	else
	{
		drawstring_aspect(pos, player_text, vec2(0.5 * mySize.x, mySize.y), player_color, panel_fg_alpha, DRAWFLAG_NORMAL);
		drawstring_aspect(pos + eX * (0.5 * mySize.x), time_text, vec2(0.5 * mySize.x, mySize.y), timer_color, panel_fg_alpha, DRAWFLAG_NORMAL);
	}
	
}

REGISTER_MUTATOR(cl_mmm, true);

MUTATOR_HOOKFUNCTION(cl_mmm, ForcePlayercolors_Skip, CBC_ORDER_LAST)
{
	if(!ISGAMETYPE(MMM))
		return false;
		
	entity player = M_ARGV(0, entity);
	entity e = entcs_receiver(player.entnum - 1);
	int otherplayer_status = ((e) ? e.mmm_status : 0);
	int mystatus = entcs_receiver(player_localnum).mmm_status;

	int plcolor = MMM_COLOR_CIVILIAN; // default to civilian

	if((mystatus == MMM_STATUS_MURDERER || intermission || STAT(GAME_STOPPED)) && otherplayer_status == MMM_STATUS_MURDERER)
	{
		plcolor = MMM_COLOR_MURDERER;
	}
	
	//LegendGuard adds CIVILIAN part 21-02-2021
	if((mystatus == MMM_STATUS_CIVILIAN || intermission || STAT(GAME_STOPPED)) && otherplayer_status == MMM_STATUS_CIVILIAN)
	{
		plcolor = MMM_COLOR_CIVILIAN;
	}

	//LegendGuard adds if sentence for Detective model color which will shown for everyone 21-02-2021
	if (otherplayer_status == MMM_STATUS_DETECTIVE)
	{
		plcolor = MMM_COLOR_DETECTIVE;
	}

	player.colormap = 1024 + plcolor;
	return true;
}

MUTATOR_HOOKFUNCTION(cl_mmm, DrawScoreboard_Force)
{
	// show the scoreboard when the round ends, so players can see who the murderer was
	return STAT(GAME_STOPPED);
}
