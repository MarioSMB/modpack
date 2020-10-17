#include "cl_survival.qh"

#include <client/draw.qh>
#include <client/hud/panel/modicons.qh>

void HUD_Mod_Survival(vector pos, vector mySize)
{
	mod_active = 1; // survival should always show the mod HUD

	int mystatus = entcs_receiver(player_localnum).survival_status;
	string player_text = "";
	vector player_color = '1 1 1';
	//string player_icon = "";
	if(mystatus == SV_STATUS_HUNTER)
	{
		player_text = _("Hunter");
		player_color = '1 0 0';
		//player_icon = "player_red";
	}
	else if(mystatus == SV_STATUS_PREY)
	{
		player_text = _("Survivor");
		player_color = '0 1 0';
		//player_icon = "player_neutral";
	}
	else
	{
		// if the player has no valid status, don't draw anything
		return;
	}

	string time_text = string_null;
	vector timer_color = '1 1 1';
	if(!STAT(GAME_STOPPED) && !warmup_stage && STAT(SURVIVAL_ROUNDTIMER) > 0)
	{
		float timeleft = max(0, STAT(SURVIVAL_ROUNDTIMER) - time);
		timeleft = ceil(timeleft);
		float minutesLeft = floor(timeleft / 60);
		time_text = seconds_tostring(timeleft);
		if(intermission_time || minutesLeft >= 5 || warmup_stage || STAT(SURVIVAL_ROUNDTIMER) == 0)
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

REGISTER_MUTATOR(cl_sv, true);

MUTATOR_HOOKFUNCTION(cl_sv, ForcePlayercolors_Skip, CBC_ORDER_LAST)
{
	if(!ISGAMETYPE(SURVIVAL))
		return false;
		
	entity player = M_ARGV(0, entity);
	entity e = entcs_receiver(player.entnum - 1);
	int surv_status = ((e) ? e.survival_status : 0);
	int mystatus = entcs_receiver(player_localnum).survival_status;

	int plcolor = SV_COLOR_PREY; // default to survivor
	if((mystatus == SV_STATUS_HUNTER || intermission || STAT(GAME_STOPPED)) && surv_status == SV_STATUS_HUNTER)
		plcolor = SV_COLOR_HUNTER;

	player.colormap = 1024 + plcolor;
	return true;
}
