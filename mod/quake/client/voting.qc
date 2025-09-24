#include "voting.qh"

void HUD_Votes()
{
	string s;
	float a;
	if(vote_active != vote_prev) {
		vote_change = time;
		vote_prev = vote_active;
	}

	if(vote_active)
		vote_alpha = bound(0, (time - vote_change) * 2, 1);
	else
		vote_alpha = bound(0, 1 - (time - vote_change) * 2, 1);

	a = vote_alpha * (vote_highlighted ? 0.7 : 1);
	if(a <= 0)
		return;
	//panel_fade_alpha *= a;

	float oldfont = drawfont; // since this is a modern panel, it can use modern fonts
	drawfont = 8; // FONT_USER

	vector panel_pos = vec2(0.73 * vid_conwidth, 0.80 * vid_conheight);
	vector panel_size = vec2(0.19 * vid_conwidth, 0.09 * vid_conheight);

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	// always force 3:1 aspect
	vector newSize = '0 0 0';
	if(mySize.x/mySize.y > 3)
	{
		newSize.x = 3 * mySize.y;
		newSize.y = mySize.y;

		pos.x = pos.x + (mySize.x - newSize.x) / 2;
	}
	else
	{
		newSize.y = 1/3 * mySize.x;
		newSize.x = mySize.x;

		pos.y = pos.y + (mySize.y - newSize.y) / 2;
	}
	mySize = newSize;

	s = _("A vote has been called for:");
	drawstring_aspect(pos, s, vec2(mySize.x, (2/8) * mySize.y), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	s = textShortenToWidth(vote_called_vote, mySize.x, '1 1 0' * mySize.y * (1/8), stringwidth_colors);
	drawcolorcodedstring_aspect(pos + eY * (2/8) * mySize.y, s, vec2(mySize.x, (1.75/8) * mySize.y), autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// print the yes/no counts
	s = sprintf("^2%s ^7(%d)", getcommandkey_forcename(_("Yes"), "vyes"), vote_yescount);
	drawcolorcodedstring_aspect(pos + eY * (4/8) * mySize.y, s, vec2(0.5 * mySize.x, (1.5/8) * mySize.y), autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	s = sprintf("^1%s ^7(%d)", getcommandkey_forcename(_("No"), "vno"), vote_nocount);
	drawcolorcodedstring_aspect(pos + vec2(0.5 * mySize.x, (4/8) * mySize.y), s, vec2(0.5 * mySize.x, (1.5/8) * mySize.y), autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	pos.y += (5/8) * mySize.y;
	vector tmp_size = vec2(mySize.x, (3/8) * mySize.y);
	// draw the progress bar backgrounds
	drawpic(pos, "gfx/hud/old/voteprogress_back", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// draw the highlights
	if(vote_highlighted == 1) {
		drawsetcliparea_builtin(pos.x, pos.y, mySize.x * 0.5, mySize.y);
		drawpic(pos, "gfx/hud/old/voteprogress_voted", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}
	else if(vote_highlighted == -1) {
		drawsetcliparea_builtin(pos.x + 0.5 * mySize.x, pos.y, mySize.x * 0.5, mySize.y);
		drawpic(pos, "gfx/hud/old/voteprogress_voted", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	// draw the progress bars
	if(vote_yescount && vote_needed)
	{
		drawsetcliparea_builtin(pos.x, pos.y, mySize.x * 0.5 * (vote_yescount/vote_needed), mySize.y);
		drawpic(pos, "gfx/hud/old/voteprogress_prog", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	if(vote_nocount && vote_needed)
	{
		drawsetcliparea_builtin(pos.x + mySize.x - mySize.x * 0.5 * (vote_nocount/vote_needed), pos.y, mySize.x * 0.5, mySize.y);
		drawpic(pos, "gfx/hud/old/voteprogress_prog", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	drawresetcliparea();

	drawfont = oldfont;
}
