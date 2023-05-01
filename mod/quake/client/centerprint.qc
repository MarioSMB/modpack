#include "centerprint.qh"

// CenterPrint (#16)

// These are the functions that draw the text at the center of the screen (e.g. frag messages and server MOTD).
// centerprint_Add parses a message and puts it in the circular buffer centerprint_messages
// centerprint_Add is usually called by Local_Notification_centerprint_Add, which is called
// by Local_Notification.
// HUD_CenterPrint draws all the messages on screen

const int CENTERPRINT_MAX_MSGS = 10;
const int CENTERPRINT_MAX_ENTRIES = 50;
const float CENTERPRINT_BASE_SIZE = 1.3;
const float CENTERPRINT_SPACING = 0.3;
const float CENTERPRINT_TITLE_SPACING = 0.35;
int cpm_index;
string centerprint_messages[CENTERPRINT_MAX_MSGS];
int centerprint_msgID[CENTERPRINT_MAX_MSGS];
float centerprint_time[CENTERPRINT_MAX_MSGS];
float centerprint_start_time[CENTERPRINT_MAX_MSGS];
float centerprint_expire_time[CENTERPRINT_MAX_MSGS];
int centerprint_countdown_num[CENTERPRINT_MAX_MSGS];
bool centerprint_showing;

string centerprint_title;
string centerprint_title_left;
string centerprint_title_right;

float stringwidth(string text, float handleColors, vector sz)
{
	vector dfs = drawfontscale;
	drawfontscale = '1 1 0';
	float r = stringwidth_builtin(text, handleColors, sz);
	drawfontscale = dfs;
	return r;
}

void centerprint_Add(int new_id, string strMessage, float duration, int countdown_num)
{
	TC(int, new_id); TC(int, countdown_num);
	//LOG_INFOF("centerprint_Add: ^2id: %d ^3dur: %d ^5countdown: %d\n'%s'", new_id, duration, countdown_num, strreplace("\n", "^7\\n^7", strMessage));
	int i, j;

	if(strMessage == "" && new_id == 0)
		return;

	// strip trailing newlines
	j = strlen(strMessage) - 1;
	while(substring(strMessage, j, 1) == "\n" && j >= 0)
		--j;
	if (j < strlen(strMessage) - 1)
		strMessage = substring(strMessage, 0, j + 1);

	if(strMessage == "" && new_id == 0)
		return;

	// strip leading newlines
	j = 0;
	while(substring(strMessage, j, 1) == "\n" && j < strlen(strMessage))
		++j;
	if (j > 0)
		strMessage = substring(strMessage, j, strlen(strMessage) - j);

	if(strMessage == "" && new_id == 0)
		return;

	if (!centerprint_showing)
		centerprint_showing = true;

	for (i=0, j=cpm_index; i<CENTERPRINT_MAX_MSGS; ++i, ++j)
	{
		if (j == CENTERPRINT_MAX_MSGS)
			j = 0;
		if (new_id && new_id == centerprint_msgID[j])
		{
			if (strMessage == "" && centerprint_messages[j] != "")
			{
				// fade out the current msg (duration and countdown_num are ignored)
				centerprint_start_time[j] = 0;
				centerprint_time[j] = min(5, 0.15);
				centerprint_expire_time[j] = -1; // don't use the variable time here!
				return;
			}
			break; // found a msg with the same id, at position j
		}
	}

	if (strMessage == "")
		return;

	if (i == CENTERPRINT_MAX_MSGS)
	{
		// a msg with the same id was not found, add the msg at the next position
		--cpm_index;
		if (cpm_index == -1)
			cpm_index = CENTERPRINT_MAX_MSGS - 1;
		j = cpm_index;
	}
	strcpy(centerprint_messages[j], strMessage);
	centerprint_start_time[j] = time;
	centerprint_msgID[j] = new_id;
	if (duration < 0)
	{
		centerprint_time[j] = -1;
		centerprint_expire_time[j] = -1; // don't use the variable time here!
	}
	else
	{
		if(duration == 0)
			duration = max(1, 3);
		centerprint_time[j] = duration;
		centerprint_expire_time[j] = -1; // don't use the variable time here!
	}
	centerprint_countdown_num[j] = countdown_num;
}

void centerprint_Kill(int id)
{
	TC(int, id);
	centerprint_Add(id, "", 0, 0);
}

void centerprint_AddStandard(string strMessage)
{
	centerprint_Add(0, strMessage, 3, 0);
}

void centerprint_KillAll()
{
	for (int i=0; i<CENTERPRINT_MAX_MSGS; ++i)
	{
		centerprint_start_time[i] = 0;
		centerprint_expire_time[i] = 0;
		centerprint_time[i] = 1;
		centerprint_msgID[i] = 0;
		strfree(centerprint_messages[i]);
	}
}

void centerprint_SetTitle(string title)
{
	if(title != centerprint_title)
		strcpy(centerprint_title, CCR(title));
}

void centerprint_ClearTitle()
{
	strfree(centerprint_title);
	strfree(centerprint_title_left);
	strfree(centerprint_title_right);
}

void HUD_CenterPrint()
{
	if (!centerprint_showing)
		return;

	vector panel_pos = vec2(0.175 * vid_conwidth, 0.22 * vid_conheight);
	vector panel_size = vec2(0.65 * vid_conwidth, 0.22 * vid_conheight);
	float oldfont = drawfont;
	drawfont = 8;

	//if(3)
	//{
		panel_pos += '1 1 0' * 3;
		panel_size -= '2 2 0' * 3;
	//}

	int i, j, k, n, g;
	float a = 1, sz, align, msg_size;
	vector pos;
	vector cp_fontsize = '11 11 0' * CENTERPRINT_BASE_SIZE;
	string ts = "";
	bool all_messages_expired = true;

	pos = panel_pos;
	align = bound(0, 0.5, 1);

	// Show title if available
	if(centerprint_title != "" || centerprint_title_left != "") {
		vector fontsize = cp_fontsize * 1.3;
		float width = 0, right_width = 0, left_width = 0, max_rl_width = 0;
		if (centerprint_title != "")
			width = stringwidth(centerprint_title, true, fontsize);
		else
		{
			right_width = stringwidth(centerprint_title_right, true, fontsize);
			left_width = stringwidth(centerprint_title_left, true, fontsize);
		}

		vector duel_title_pos = '0 0 0';
		float padding = stringwidth(" ", false, fontsize) * 2;
		if (centerprint_title_left != "")
		{
			if (left_width > right_width)
				max_rl_width = left_width;
			else
				max_rl_width = right_width;

			width = max_rl_width * 2 + padding * 6 + stringwidth(_("vs"), false, fontsize);
			pos.x += (panel_size.x - width) * align;
			duel_title_pos = pos;

			pos.x += padding;
			if (left_width < right_width)
				pos.x += (max_rl_width - left_width) * 0.5;
			drawcolorcodedstring(pos, centerprint_title_left, fontsize, 1, DRAWFLAG_NORMAL);

			pos.x = duel_title_pos.x + max_rl_width + padding * 3;
			drawstring(pos, _("vs"), fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);

			pos.x = duel_title_pos.x + width - padding - max_rl_width;
			if (left_width >= right_width)
				pos.x += (max_rl_width - right_width) * 0.5;
			drawcolorcodedstring(pos, centerprint_title_right, fontsize, 1, DRAWFLAG_NORMAL);
		}
		else
		{
			pos.x = panel_pos.x + (panel_size.x - width) * align;
			drawcolorcodedstring(pos, centerprint_title, fontsize, 1, DRAWFLAG_NORMAL);
		}

		pos.y += fontsize.y + (11 * CENTERPRINT_TITLE_SPACING);

		if (centerprint_title_left != "")
		{
			pos.x = duel_title_pos.x;
			drawfill(pos, vec2(max_rl_width + padding * 2, 1), '1 1 1', 1, DRAWFLAG_NORMAL);
			drawfill(pos + vec2(width - max_rl_width - padding * 2, 0), vec2(max_rl_width + padding * 2, 1), '1 1 1', 1, DRAWFLAG_NORMAL);
		}
		else
			drawfill(pos - eX * padding, vec2(width + 2 * padding, 1), '1 1 1', 1, DRAWFLAG_NORMAL);

		pos.y += cp_fontsize.y * CENTERPRINT_TITLE_SPACING;

		all_messages_expired = false;
	}

	for (g=0, i=0, j=cpm_index; i<CENTERPRINT_MAX_MSGS; ++i, ++j)
	{
		if (j == CENTERPRINT_MAX_MSGS)
			j = 0;
		if (centerprint_expire_time[j] == -1)
		{
			// here we are sure the time variable is not altered by CSQC_Ent_Update
			centerprint_expire_time[j] = time;
			if (centerprint_time[j] > 0)
				centerprint_expire_time[j] += centerprint_time[j];
		}
		if (centerprint_expire_time[j] <= time)
		{
			if (centerprint_countdown_num[j] && centerprint_time[j] > 0 && centerprint_start_time[j])
			{
				centerprint_countdown_num[j] = centerprint_countdown_num[j] - 1;
				if (centerprint_countdown_num[j] == 0)
					continue;
				centerprint_expire_time[j] = centerprint_expire_time[j] + centerprint_time[j];
			}
			else if(centerprint_time[j] != -1)
				continue;
		}

		all_messages_expired = false;

		if (time < centerprint_start_time[j]) continue;

		float fade_in_time = 0;
		float fade_out_time = 0.15;

		if (centerprint_countdown_num[j] && centerprint_start_time[j]) {
			fade_in_time = 0;
			fade_out_time = 0;
		}

		// fade
		if(fade_in_time && centerprint_start_time[j] && time < centerprint_start_time[j] + fade_in_time) // Fade in
			a = (time - centerprint_start_time[j]) / fade_in_time;
		else if(time < centerprint_expire_time[j] - fade_out_time || centerprint_time[j] < 0) // Regularily printed or forced
			a = 1;
		else if(fade_out_time) // Expiring soon, so fade it out.
			a = (centerprint_expire_time[j] - time) / fade_out_time;

		if(centerprint_msgID[j] == ORDINAL(CPID_TIMEIN))
			a = 1;

		// while counting down show it anyway in order to hold the current message position
		if (a <= 0.5/255.0 && centerprint_countdown_num[j] == 0)  // Guaranteed invisible - don't show.
			continue;

		// also fade it based on positioning
		if(true)
		{
			// pass one: all messages after the first have half alpha
			a = a * bound(0.5, (1 - (g / max(1, 3))), 1);
			// pass two: after that, gradually lower alpha even more for each message
			a = a * bound(0.5, (1 - (g / max(1, 10))), 1);
		}
		a *= 1;

		// finally set the size based on the alpha
		sz = 1 + a * (1 - 1);
		drawfontscale = '1 1 1' * sz;

		if (centerprint_countdown_num[j])
			n = tokenizebyseparator(strreplace("^COUNT", ftos(centerprint_countdown_num[j]), centerprint_messages[j]), "\n");
		else
			n = tokenizebyseparator(centerprint_messages[j], "\n");

		msg_size = pos.y;
		for(k = 0; k < n; ++k)
		{
			getWrappedLine_remaining = argv(k);

			bool is_bold = (substring(getWrappedLine_remaining, 0, 5) == BOLD_OPERATOR);
			vector fontsize = cp_fontsize * (is_bold ? 1.2 : 1);
			if (is_bold)
				getWrappedLine_remaining = substring(getWrappedLine_remaining, 5, -1);

			while(getWrappedLine_remaining)
			{
				ts = getWrappedLine(panel_size.x * 1 * sz, fontsize, stringwidth_colors);
				if (ts != "")
				{
					if (align)
						pos.x = panel_pos.x + (panel_size.x - stringwidth(ts, true, fontsize) * sz) * align;
					if (a > 0.5/255.0)  // Otherwise guaranteed invisible - don't show. This is checked a second time after some multiplications with other factors were done so temporary changes of these cannot cause flicker.
					{
						if (is_bold) drawfont = 8 + 3;
						drawcolorcodedstring(pos + eY * 0.5 * (1 - sz * 1) * fontsize.y, ts, fontsize, a, DRAWFLAG_NORMAL);
					}
					pos.y += fontsize.y;
				}
				else
					pos.y += fontsize.y * CENTERPRINT_SPACING/2;
			}
		}

		++g; // move next position number up

		msg_size = pos.y - msg_size;

			pos.y += CENTERPRINT_SPACING * cp_fontsize.y;
			if (a < 1 && centerprint_msgID[j] == 0) // messages with id can be replaced just after they are faded out, so never move over them the next messages
				pos.y -= (1 - sqrt(a));

			if(pos.y > panel_pos.y + panel_size.y - cp_fontsize.y) // check if the next message can be shown
			{
				drawfontscale = '1 1 1';
				drawfont = oldfont;
				return;
			}
	}

	drawfontscale = '1 1 1';
	drawfont = oldfont;
	if (all_messages_expired)
	{
		centerprint_showing = false;
		centerprint_KillAll();
	}
}
