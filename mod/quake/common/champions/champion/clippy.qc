#include "clippy.qh"

#ifdef SVQC
METHOD(Clippy, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);

	actor.clippy_annoytime = time + 30 + (random() * 120);

	SendClippyLine(actor, bound(1, floor(random() * 3) + 1, 3));

	STAT(WEAPONS, actor) |= WEP_PLANE.m_wepset;

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
		W_SwitchWeapon(actor, WEP_PLANE, weaponentity);
}

METHOD(Clippy, m_playerspawn, void(Champions this, entity actor))
{
	SendClippyLine(actor, 4);

	STAT(WEAPONS, actor) |= WEP_PLANE.m_wepset;
}

METHOD(Clippy, m_clear, void(Champions this, entity actor))
{
	STAT(WEAPONS, actor) &= ~WEP_PLANE.m_wepset;
}

METHOD(Clippy, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this && targ.health > 0 && damage > 0 && !(targ.flags & FL_GODMODE) && (targ.health - damage) <= 50 && time >= targ.clippy_dmgtime)
	{
		targ.clippy_dmgtime = time + 20;
		SendClippyLine(targ, 6);
	}
	return 1;
}

METHOD(Clippy, m_playerthink, void(Champions this, entity actor))
{
	if(time >= actor.clippy_annoytime)
	{
		actor.clippy_annoytime = time + 30 + (random() * 120);
		SendClippyLine(actor, 12);
	}
}

METHOD(Clippy, m_pickup_weapon, void(Champions this, entity actor, entity item))
{
	SendClippyLine(actor, 5);
}

METHOD(Clippy, m_pickup_secret, void(Champions this, entity actor, entity trigger))
{
	SendClippyLine(actor, 8);
}

METHOD(Clippy, m_pushbutton, void(Champions this, entity actor, entity trigger))
{
	SendClippyLine(actor, 9);
}

METHOD(Clippy, m_triggermessage, void(Champions this, entity actor, entity trigger))
{
	SendClippyLine(actor, 10);
}

METHOD(Clippy, m_pickup_key, void(Champions this, entity actor, entity item))
{
	SendClippyLine(actor, 7);
}

METHOD(Clippy, m_pickup_armor, void(Champions this, entity actor, entity item))
{
	SendClippyLine(actor, 11);
}

METHOD(Clippy, m_pickup_powerup, void(Champions this, entity actor, entity item))
{
	SendClippyLine(actor, 13);
}

METHOD(Clippy, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(attacker.m_champion == this && IS_MONSTER(targ))
		SendClippyLine(attacker, 14);
}

METHOD(Clippy, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.clippy_cannon = true;
}

METHOD(Clippy, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.clippy_cannon)
		return false;
	player_sound(actor, CH_TRIGGER_SINGLE, "cannon_land.wav", ATTN_NORM);
	actor.clippy_cannon = false;
	return false;
}

void SendClippyLine(entity this, int liner)
{
	if(!liner || !IS_REAL_CLIENT(this))
		return;

	msg_entity = this;
	WriteHeader(MSG_ONE, TE_CSQC_CLIPPY_LINE);
	WriteByte(MSG_ONE, liner);
}
#endif

#ifdef CSQC
string Sbar_ClippyLine(int liner)
{
	switch(liner)
	{
		case 1: return "sb_clippy_line1";
		case 2: return "sb_clippy_line2";
		case 3: return "sb_clippy_line3";
		case 4: return "sb_clippy_line4";
		case 5: return "sb_clippy_line5";
		case 6: return "sb_clippy_line6";
		case 7: return "sb_clippy_line7";
		case 8: return "sb_clippy_line8";
		case 9: return "sb_clippy_line9";
		case 10: return "sb_clippy_line10";
		case 11: return "sb_clippy_line11";
		case 12: return "sb_clippy_line12";
		case 13: return "sb_clippy_line13";
		case 14: return "sb_clippy_line14";
	}

	return string_null;
}

void Sbar_Clippy_Push(int liner)
{
	string icon = Sbar_ClippyLine(liner);
	if(!icon)
		return;

	++clippy_count;
	--clippy_index;

	if (clippy_index == -1)
		clippy_index = CLIPPY_MAX_ENTRIES-1;

	// Free old strings
	if (clippy_icons[clippy_index])
		strunzone(clippy_icons[clippy_index]);

	// Allocate new strings
	clippy_icons[clippy_index] = strzone(icon);
	clippy_times[clippy_index] = time;
}

void Sbar_DrawClippy()
{
	if(clippy_count == 0)
		return;

	vector pos, size;
	// hardcoded values from Xonotic, TODO
	vector panel_pos = vec2(0.13 * vid_conwidth, 0.80 * vid_conheight);
	vector panel_size = vec2(0.265 * vid_conwidth, 0.20 * vid_conheight);
	pos  = panel_pos;
	size = panel_size;

	float fade_start = max(0, 7); // 3 was autocvar_sbar_clippy_time
	if(intermission) // fade out in half the time
		fade_start -= (time - intermission_time);
	float fade_time = max(0, 0.1); // 0.1 was autocvar_sbar_notify_fadetime
	float icon_aspect = 1;

	int entry_count = bound(1, floor(CLIPPY_MAX_ENTRIES * size.y / size.x), CLIPPY_MAX_ENTRIES);
	float entry_height = size.y / entry_count;

	float panel_width_half = size.x * 0.5;
	float icon_width_half = entry_height * icon_aspect / 2;

	vector icon_size = vec2(icon_aspect * 1.5, 1) * entry_height;
	vector icon_left = eX * (panel_width_half - icon_width_half);

	vector icon_pos;
	string icon;
	int i, j, count, step, limit;
	float alpha;

	// Order items from the bottom up
	i = entry_count - 1;
	step = -1;
	limit = -1;

	for(j = clippy_index, count = 0; i != limit; i += step, ++j, ++count)
	{
		if (j == CLIPPY_MAX_ENTRIES)
			j = 0;

		if(clippy_times[j] + fade_start > time)
			alpha = 1;
		else if(fade_time != 0)
		{
			alpha = bound(0, (clippy_times[j] + fade_start + fade_time - time) / fade_time, 1);
			if (alpha == 0)
				break;
		}
		else
			break;

		icon = clippy_icons[j];

		if (icon != "")
		{
			icon_pos = pos + icon_left + eY * i * entry_height;
			drawpic(icon_pos, strcat("gfx/quake/", icon), icon_size, '1 1 1', alpha, DRAWFLAG_NORMAL);
		}
	}

	clippy_count = count;
}

METHOD(Clippy, m_overlay, void(Champions this))
{
	if(intermission || STAT(HEALTH) == -666)
		return;

	Sbar_DrawClippy();
}

NET_HANDLE(TE_CSQC_CLIPPY_LINE, bool isNew)
{
	int liner = ReadByte();
	Sbar_Clippy_Push(liner);

	_sound(NULL, CH_INFO, "player_clippy/talk.wav", VOL_BASE, ATTEN_NONE);
	return true;
}

METHOD(Clippy, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/clippy_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
