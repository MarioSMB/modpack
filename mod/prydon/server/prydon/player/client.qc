#include "client.qh"

#include "../stats/stats.qh"
#include "../subs/combat.qh"
#include "../ui/_mod.qh"

void prydon_ClientKill(entity this)
{
	T_Damage(this, this.player, 50000, 4);
}

void prydon_ClientConnect(entity this)
{
	entity e;
	this.pin = 0;
	if(mplayer)
		Secure_GetPin(this);
	for (e = find(NULL, classname, "npc"); e; e = find(e, classname, "npc"))
	{
		if(e.ai & AI_FOLLOW)
		{
			if(e.sbarsub)
				e.sbarsub.follow_npcs = 0;
			e.sbarsub = NULL;
		}
	}
	saveversion = SAVE_VERSION;
	numplayers += 1;
	bprintf("%s joined to fight the tides of evil\n", this.netname);
	gameload = 0;
	this.misc = 0;
}
void prydon_ClientDisconnect(entity this)
{
	regain_body(this);
	if(fileaccess)
	{
		Unstat(this);
		SetParms(this);
	}
	numplayers -= 1;
	bprintf("%s left this realm\n", this.netname);
	averagelvl = averagelvl - this.lvl;

	if(this.camera)
		delete(this.camera);
	if(this.wayp)
		delete(this.wayp);
	if(this.player.spellprop)
		delete(this.player.spellprop);
	if(this.player.wayp)
		delete(this.player.wayp);
	if(this.player.camera)
		delete(this.player.camera);
	if(this.player)
		delete(this.player);
	if(this.cursor)
		delete(this.cursor);

}
void ui_setitemsolid(entity this, float st)
{
	FOREACH_ENTITY_CLASS("item", true,
	{
		it.solid = st;
		setorigin(it, it.origin);
	});
}
void prydon_PlayerPreThink(entity this)
{
	// savegame compatibility hack
	if(mapname == "save")
		return;
	if(secure)
	{
		if(this.authed == AUTH_YES)
		{
			if(this.netname != this.username)
			{
				sprint(this, "\bName changed, your character will not be saved until you return to your old name\b\n");
				this.authed = AUTH_NAMECHANGED;
			}
		}
		else if(this.authed == AUTH_NAMECHANGED)
		{
			if(this.netname == this.username)
			{
				sprint(this, "\bThank you.\b\n");
				this.authed = AUTH_YES;
			}
		}
		else if(!this.menu)
			openmenu(this, m_pin, this);
	}
	if(world.map)
		return;
	itemvalue = ((averagelvl * 8) + 5 + this.luck * 1.2) / 20;

	if(!IS_CLIENT(this))
		return; // Quake runs extra player frames before you connect
	
	if(gameload)
	{
		if(!cvar("developer"))
		{
			prompt(this, "You must use the Inn to save", this, 0);
			stuffcmd(this, "v_cshift 0 0 0 255\n");
		}
		else
		{
			if(this.camera)
				delete(this.camera);
			this.gotstuff = time;
			this.camera = NULL;
			gameload = 0;
		}
	}
	h_stuff(this);
	if(!this.player)
		return;	
	else if(this.player.ai)
	{
		h_camera(this);
		if(this.cursor)
			delete(this.cursor);
		this.cursor = NULL;
	}
	else
	{
		h_cursor(this);
		h_camera(this);
		ui_update(this);
		ui_setitemsolid(this, SOLID_BBOX);
		h_click(this);
		h_sbar(this);
		ui_setitemsolid(this, SOLID_TRIGGER);
	}
}

void prydon_PlayerPostThink(entity this)
{
	if(mapname == "save")
		return;
	if(world.map)
		return;
	if(!IS_CLIENT(this))
		return;
	this.button1 = 0;
	menu_impulse(this);
	if(this.player)
		h_impulse(this);

	m_menu(this);

	setitems(this);
	if(this.player)
	{
		if(pointcontents(this.player.origin - '0 0 24') < -2)
		{
			this.player.noise1 = "player/wstep1.wav";
			this.player.noise2 = "player/wstep2.wav";
		}
		else
		{
			this.player.noise1 = "player/step1.wav";
			this.player.noise2 = "player/step2.wav";
		}
	}
	if(this.impulse > 0)
		this.impulse = 0;
	if(this.voice != string_null)
	{
		msg_entity = this;
		soundto(MSG_ONE, this, CH_VOICE, this.voice, VOL_BASE, ATTEN_NONE);
		this.voice = string_null;
	}
}
