#ifdef GAMEQC
MODEL(GIFTBOX, "models/items/giftbox.md3");

EFFECT(0, GIFTBOX_PICKUP, "red_ground_quake")
EFFECT(0, GIFTBOX_RESPAWN, "blue_ground_quake")
#endif

// load the different gifts (includes their notifications)
#include "giftbox.qh"

#ifdef SVQC
.int gifts;

// no cvar to control this one, if the model exists it's on
REGISTER_MUTATOR(giftbox, fexists("models/items/giftbox.md3"));

AUTOCVAR(g_giftbox_spawnrate, float, 0.1, "Chance for gift boxes to replace items, value between 0 and 1");
AUTOCVAR(g_giftbox_respawntime, float, 20, "Time for a gift box to regenerate after being used");

void giftbox_newgift(entity this)
{
	this.glowmod = randomvec() * 0.95;
	this.colormap = 1024 + floor(random() * 256);
	this.colormod = '0 0 0';
	this.alpha = 1;
	this.skin = 0;

	this.gifts = get_random_gift();

	Send_Effect(EFFECT_GIFTBOX_RESPAWN, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	sound(this, CH_TRIGGER, SND_ITEMRESPAWN, VOL_BASE, ATTN_NORM);
}

.float gift_msg_time;
void giftbox_touch(entity this, entity toucher)
{
	if(gameover) { return; }

	if(ITEM_TOUCH_NEEDKILL())
	{
		delete(this);
		return;
	}

	if((this.team && DIFF_TEAM(toucher, this))
	|| (STAT(FROZEN, toucher))
	|| (toucher.vehicle)
	|| (!IS_PLAYER(toucher))
	)
	{
		// can't touch this
		return;
	}

	if(toucher.gifts & this.gifts)
	{
		if(time > toucher.gift_msg_time)
		{
			Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_GIFT_NOTHING);
			toucher.gift_msg_time = time + 1;
		}
		return;
	}

	this.glowmod = '0 0 0';
	this.colormap = 1024; // 0 = black, 1024 = white
	this.colormod = '-1 -1 -1';
	this.alpha = 0.25;
	this.skin = 1;

	this.solid = SOLID_NOT;
	this.respawntime = time + autocvar_g_giftbox_respawntime;

	Send_Effect(EFFECT_GIFTBOX_PICKUP, CENTER_OR_VIEWOFS(this), '0 0 100', 1);
	sound(toucher, CH_TRIGGER, SND_SHIELD_RESPAWN, VOL_BASE, ATTN_NORM);

	if(this.gifts & GIFTBOX_GIFT_COAL)
	{
		toucher.gifts = 0;
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, GIFT_COAL);
	}
	else if(this.gifts & GIFTBOX_GIFT_ARMOR)
	{
		int amnt = floor(random() * 150);
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, GIFT_ARMOR, amnt);
		toucher.armorvalue = bound(toucher.armorvalue, 200, toucher.armorvalue + amnt);
	}
	else if(this.gifts & GIFTBOX_GIFT_HEALTH)
	{
		int amnt = floor(random() * 150);
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, GIFT_HEALTH, amnt);
		toucher.health = bound(toucher.health, 200, toucher.health + amnt);
	}
	else
	{
		toucher.gifts |= (this.gifts);
		Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, GIFT, get_gift_name(this.gifts), get_gift_strength(this.gifts), rint(get_gift_percent(this.gifts) * 100));
	}
}

void giftbox_think(entity this)
{
	if(this.skin == 1 && time >= this.respawntime)
	{
		this.solid = SOLID_TRIGGER;
		giftbox_newgift(this);
	}

	this.nextthink = time + 0.1;
	CSQCMODEL_AUTOUPDATE(this);
}

void giftbox_reset(entity this)
{
	this.solid = SOLID_TRIGGER;
	settouch(this, giftbox_touch);

	setthink(this, giftbox_think);
	this.nextthink = time + 0.1;

	giftbox_newgift(this);
}

// not actually a map entity, don't use it as such
spawnfunc(giftbox)
{
	this.flags = FL_ITEM;
	this.bot_pickup = true;
	this.bot_pickupevalfunc = commodity_pickupevalfunc;
	this.bot_pickupbasevalue = 500;
	IL_PUSH(g_items, this);
	this.gravity = 1;
	this.scale = 1;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;

	setmodel(this, MDL_GIFTBOX);
	setsize(this, '-24 -24 0', '24 24 40');

	if(!this.noalign && !(this.spawnflags & 1))
		droptofloor(this);

	this.reset = giftbox_reset;
	
	giftbox_reset(this);

	CSQCMODEL_AUTOINIT(this);
}

MUTATOR_HOOKFUNCTION(giftbox, OnEntityPreSpawn)
{
	entity item = M_ARGV(0, entity);

	if(!item.team) // no teamed items
	if(random() <= autocvar_g_giftbox_spawnrate)
	if(item.classname == "item_rockets" || item.classname == "item_bullets" || item.classname == "item_shells" || item.classname == "item_cells" || startsWith(item.classname, "ammo_"))
		item.classname = "giftbox";
}


// implementation of effects

MUTATOR_HOOKFUNCTION(giftbox, PlayerPhysics)
{
	entity player = M_ARGV(0, entity);

	if(player.gifts & GIFTBOX_GIFT_ROCKINGHORSE)
	{
		player.stat_sv_maxspeed *= (1 + get_gift_percent(GIFTBOX_GIFT_ROCKINGHORSE));
		player.stat_sv_airspeedlimit_nonqw *= (1 + get_gift_percent(GIFTBOX_GIFT_ROCKINGHORSE));
	}
}

MUTATOR_HOOKFUNCTION(giftbox, PlayerDamage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);

	if(frag_attacker.gifts & GIFTBOX_GIFT_EGGNOG)
		M_ARGV(4, float) *= (1 + get_gift_percent(GIFTBOX_GIFT_EGGNOG)); // damage

	if(frag_target.gifts & GIFTBOX_GIFT_SLIPPERS)
	if(frag_deathtype == DEATH_FALL.m_id)
		M_ARGV(4, float) *= (1 - get_gift_percent(GIFTBOX_GIFT_SLIPPERS)); // damage

	if(frag_target.gifts & GIFTBOX_GIFT_SWEATER)
		M_ARGV(4, float) *= (1 - get_gift_percent(GIFTBOX_GIFT_SWEATER)); // damage

	if(frag_target.gifts & GIFTBOX_GIFT_SCARF)
		M_ARGV(4, float) *= (1 - get_gift_percent(GIFTBOX_GIFT_SCARF)); // damage
}

MUTATOR_HOOKFUNCTION(giftbox, PlayerRegen)
{
	entity player = M_ARGV(0, entity);

	if(player.gifts & GIFTBOX_GIFT_CANDYCORN)
	{
		M_ARGV(9, float) *= (1 + get_gift_percent(GIFTBOX_GIFT_CANDYCORN)); // regen_health_stable
		M_ARGV(10, float) *= (1 + get_gift_percent(GIFTBOX_GIFT_CANDYCORN)); // regen_health_rotstable
	}

	if(player.gifts & GIFTBOX_GIFT_CHOCOLATE)
		M_ARGV(2, float) *= (1 + get_gift_percent(GIFTBOX_GIFT_CHOCOLATE)); // regen_mod

	if(player.gifts & GIFTBOX_GIFT_CHOCOLATE)
		M_ARGV(2, float) *= (1 + get_gift_percent(GIFTBOX_GIFT_CHOCOLATE)); // regen_mod
}

MUTATOR_HOOKFUNCTION(giftbox, PlayerDamaged)
{
	entity player = M_ARGV(1, entity);

	if((player.gifts & GIFTBOX_GIFT_MUG) && player.pauseregen_finished > 0)
	{
		float thered = autocvar_g_balance_pause_health_regen * (1 - get_gift_percent(GIFTBOX_GIFT_MUG));
		player.pauseregen_finished -= thered;
	}
}

MUTATOR_HOOKFUNCTION(giftbox, PlayerJump)
{
	entity player = M_ARGV(0, entity);

	if(player.gifts & GIFTBOX_GIFT_FAIRYFLOSS)
		M_ARGV(1, float) *= (1 + get_gift_percent(GIFTBOX_GIFT_FAIRYFLOSS)); // jump height
}

MUTATOR_HOOKFUNCTION(giftbox, WeaponRateFactor)
{
	entity player = M_ARGV(1, entity);

	if(player.gifts & GIFTBOX_GIFT_WATCH)
		M_ARGV(0, float) *= (1 - get_gift_percent(GIFTBOX_GIFT_WATCH));
}

MUTATOR_HOOKFUNCTION(giftbox, WeaponSpeedFactor)
{
	entity player = M_ARGV(1, entity);

	if(player.gifts & GIFTBOX_GIFT_WATCH)
		M_ARGV(0, float) *= (1 + get_gift_percent(GIFTBOX_GIFT_WATCH));
}

MUTATOR_HOOKFUNCTION(giftbox, PlayerDies)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);

	frag_target.gifts = 0;
	frag_target.gift_msg_time = 0;

	if(frag_attacker.gifts & GIFTBOX_GIFT_RING)
	{
		// drop around half their weapons
		FOREACH(Weapons, it != WEP_Null && random() > 0.5, LAMBDA(
			if(frag_target.weapons & WepSet_FromWeapon(it))
			if(PS(frag_target).m_switchweapon != it)
			if(W_IsWeaponThrowable(frag_target, it.m_id))
				W_ThrowNewWeapon(frag_target, it.m_id, false, CENTER_OR_VIEWOFS(frag_target), randomvec() * 175 + '0 0 325');
		));
	}
}


// handle loss of gifts when spawning
MUTATOR_HOOKFUNCTION(giftbox, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	player.gifts = 0;
	player.gift_msg_time = 0;
}
#endif
