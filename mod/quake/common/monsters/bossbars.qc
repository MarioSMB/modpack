#include "bossbars.qh"

#ifdef SVQC
bool bossbar_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_BOSSBAR);

	// TODO: separate bit flag for extra states?
	// phases etc
	if(this.owner.is_frozen)
		sf |= BIT(7);
	else
		sf &= ~BIT(7);

	WriteByte(MSG_ENTITY, sf);

	if(sf & BIT(0))
	{
		WriteByte(MSG_ENTITY, this.monsterdef.monsterid);
	}

	if(sf & BIT(1))
		WriteByte(MSG_ENTITY, (this.health / this.max_health) * 191.0);

	if(sf & BIT(2))
	{
		WriteVector(MSG_ENTITY, this.origin);
	}

	return true;
}

void bossbar_think(entity this)
{
	if(!this.owner || wasfreed(this.owner) || this.owner.health < 1)
	{
		delete(this);
		return;
	}
	this.nextthink = time;

	entity boss = this.owner;
	if(this.max_health != boss.max_health || this.health != boss.health)
	{
		this.max_health = boss.max_health;
		this.health = boss.health;
		this.SendFlags |= BIT(1);
	}

	if(this.origin != boss.origin)
	{
		this.origin = boss.origin;
		this.SendFlags |= BIT(2);
	}
}

void bossbar_spawn(entity this, Monster mon)
{
	// dupe checker?
	IL_EACH(g_bossbars, it.owner == this, delete(it));

	entity bar = new_pure(bossbar);
	set_movetype(bar, MOVETYPE_NONE); // link to qc
	bar.owner = this;
	setthink(bar, bossbar_think);
	bar.nextthink = time;
	// we store health on the boss bar for networking purposes
	bar.max_health = this.max_health;
	bar.health = this.health;
	bar.monsterdef = mon;
	bar.origin = this.origin;

	Net_LinkEntity(bar, false, 0, bossbar_send);
}
#endif

#ifdef CSQC
PRECACHE(BossBars)
{
	precache_pic("gfx/quake/bossbar");
	precache_pic("gfx/quake/bossbar_bg");

	FOREACH(Monsters, it.spawnflags & MONSTER_TYPE_BOSS,
	{
		precache_pic(strcat("gfx/quake/bossbar_", it.netname));
		precache_pic(strcat("gfx/quake/progressbar_", it.netname));
	});
}

NET_HANDLE(ENT_CLIENT_BOSSBAR, bool isnew)
{
	if (isnew) IL_PUSH(g_bossbars, this);
	int sf = ReadByte();
	// frozen
	if(sf & BIT(7))
		this.count = true;
	else
		this.count = false;

	if(sf & BIT(0))
	{
		this.monsterdef = get_monsterinfo(ReadByte());
	}

	if(sf & BIT(1))
		this.health = ReadByte() / 191.0;

	if(sf & BIT(2))
	{
		this.origin = ReadVector();
	}

	return true;
}

void HUD_BossBar_Draw(entity this)
{
	Monster mon = this.monsterdef; // validity checked during loop

	vector panel_pos = vec2(0.37 * vid_conwidth, 0 * vid_conheight);
	vector panel_size = vec2(0.26 * vid_conwidth, 0.07 * vid_conheight);
	float oldfont = drawfont;
	drawfont = 8;

	vector pos = panel_pos;
	vector mySize = panel_size;

	vector tcolor = mon.m_color;
	if(tcolor == '0 0 0')
		tcolor = '1 0.2 0';
	if(this.count)
		tcolor = '0.5 0.5 0.5';

	// TODO: proper positioning and stuff!
	string pic = strcat("gfx/quake/bossbar_", mon.netname);
	bool have_bar = (precache_pic(pic) != "");
	// background, progress bar, then bar image, nice layering!
	drawpic_aspect(panel_pos + vec2(-mySize.x * 0.5, 0), "gfx/quake/bossbar_bg", mySize * 2, '1 1 1', 0.8, DRAWFLAG_NORMAL);

	HUD_Panel_DrawProgressBar(pos + vec2(mySize.x * 0.05, mySize.y * 1.25), vec2(mySize.x * 0.9, mySize.y * 0.5), strcat("progressbar_", mon.netname), this.health, false, 0, tcolor, 0.6 * 1, DRAWFLAG_NORMAL);

	if(have_bar)
		drawpic_aspect(panel_pos + vec2(-mySize.x * 0.5, 0), pic, mySize * 2, '1 1 1', 0.8, DRAWFLAG_NORMAL);
	else
		drawpic_aspect(panel_pos + vec2(-mySize.x * 0.5, 0), "gfx/quake/bossbar", mySize * 2, '1 1 1', 0.8, DRAWFLAG_NORMAL);

	pos.y += mySize.y * 0.25;
	if(!have_bar)
		drawstring_aspect(pos, mon.m_name, vec2(mySize.x, mySize.y * 0.45), '0.5 0.2 0', 1, DRAWFLAG_NORMAL);
	pos.y += mySize.y * 0.5;
	if(!have_bar && mon.m_description != "")
		drawstring_aspect(pos, mon.m_description, vec2(mySize.x, mySize.y * 0.2), '0.8 0.2 0', 1, DRAWFLAG_NORMAL);

	drawfont = oldfont;
}

const float BOSSBAR_RANGE = 2048; // TODO: per monster?
void HUD_BossBars()
{
	if(sb_showscores)
		return;

	entity chosen = NULL;
	float chosen_dist = 0;
	IL_EACH(g_bossbars, it.monsterdef && it.monsterdef != MON_Null && vdist(view_origin - it.origin, <=, BOSSBAR_RANGE),
	{
		float mydist = vlen2(view_origin - it.origin);
		if(!chosen || mydist <= chosen_dist)
		{
			chosen = it;
			chosen_dist = mydist;
		}
	});

	// draw only the closest boss's bar?
	// TODO: multi-boss fights

	if(chosen)
		HUD_BossBar_Draw(chosen);
}
#endif
