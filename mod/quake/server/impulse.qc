#include "impulse.qh"

#define IMPULSE(id) _IMPULSE(IMP_##id)
#define _IMPULSE(id) \
	void id##_handle(entity this); \
	STATIC_INIT_LATE(id) \
	{ \
		id.impulse_handle = id##_handle; \
	} \
	void id##_handle(entity this)

/**
 * Impulse map:
 *
 * 0 reserved (no input)
 *
 * 99: loaded
 *
 * 140: moving clone
 * 141: ctf speedrun
 * 142: fixed clone
 * 143: emergency teleport
 * 148: unfairly eliminate
 *
 * TODO:
 * 200 to 209: prev weapon shortcuts
 * 210 to 219: best weapon shortcuts
 * 220 to 229: next weapon shortcuts
 * 230 to 253: individual weapons (up to 24)
 */

// weapon switching impulses

void weapon_group_handle(entity this, int number, int imp)
{
	if (this.health <= 0)
	{
		this.impulse = imp;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_NextWeaponOnImpulse(this, number, weaponentity);
		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

#define X(i) \
	IMPULSE(weapon_group_##i) \
	{ \
		weapon_group_handle(this, i, IMP_weapon_group_##i.impulse); \
	}
X(1)
X(2)
X(3)
X(4)
X(5)
X(6)
X(7)
X(8)
X(9)
X(0)
#undef X

// custom order weapon cycling

void weapon_priority_handle(entity this, int dir, int number, int imp)
{
	if (this.health <= 0)
	{
		this.impulse = imp;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_CycleWeapon(this, this.cvar_cl_weaponpriorities[number], dir, weaponentity);
		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

#define X(i, dir) \
	IMPULSE(weapon_priority_##i##_##dir) \
	{ \
		noref int prev = -1; \
		noref int best =  0; \
		noref int next = +1; \
		weapon_priority_handle(this, dir, i, IMP_weapon_priority_##i##_##dir.impulse); \
	}
X(0, prev)
X(1, prev)
X(2, prev)
X(3, prev)
X(4, prev)
X(5, prev)
X(6, prev)
X(7, prev)
X(8, prev)
X(9, prev)

X(0, best)
X(1, best)
X(2, best)
X(3, best)
X(4, best)
X(5, best)
X(6, best)
X(7, best)
X(8, best)
X(9, best)

X(0, next)
X(1, next)
X(2, next)
X(3, next)
X(4, next)
X(5, next)
X(6, next)
X(7, next)
X(8, next)
X(9, next)
#undef X

// direct weapons

void weapon_byid_handle(entity this, int number, int imp)
{
	if (this.health <= 0)
	{
		this.impulse = imp;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_SwitchWeapon_TryOthers(this, REGISTRY_GET(Weapons, WEP_FIRST + number), weaponentity);
		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

#define X(i) \
	IMPULSE(weapon_byid_##i) \
	{ \
		weapon_byid_handle(this, i, IMP_weapon_byid_##i.impulse); \
	}
X(0)
X(1)
X(2)
X(3)
X(4)
X(5)
X(6)
X(7)
X(8)
X(9)
X(10)
X(11)
X(12)
X(13)
X(14)
X(15)
X(16)
X(17)
X(18)
X(19)
X(20)
X(21)
X(22)
X(23)
#undef X

IMPULSE(weapon_next_byid)
{
	if (this.health <= 0)
	{
		this.impulse = IMP_weapon_next_byid.impulse;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_NextWeapon(this, 0, weaponentity);

		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

IMPULSE(weapon_prev_byid)
{
	if (this.health <= 0)
	{
		this.impulse = IMP_weapon_prev_byid.impulse;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_PreviousWeapon(this, 0, weaponentity);

		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

IMPULSE(weapon_next_bygroup)
{
	if (this.health <= 0)
	{
		this.impulse = IMP_weapon_next_bygroup.impulse;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_NextWeapon(this, 1, weaponentity);

		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

IMPULSE(weapon_prev_bygroup)
{
	if (this.health <= 0)
	{
		this.impulse = IMP_weapon_prev_bygroup.impulse;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_PreviousWeapon(this, 1, weaponentity);

		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

IMPULSE(weapon_next_bypriority)
{
	if (this.health <= 0)
	{
		this.impulse = IMP_weapon_next_bypriority.impulse;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_NextWeapon(this, 2, weaponentity);

		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

IMPULSE(weapon_prev_bypriority)
{
	if (this.health <= 0)
	{
		this.impulse = IMP_weapon_prev_bypriority.impulse;
		return;
	}
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_PreviousWeapon(this, 2, weaponentity);

		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

IMPULSE(weapon_last)
{
	if (this.health <= 0) return;
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_LastWeapon(this, weaponentity);

		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

IMPULSE(weapon_best)
{
	if (this.health <= 0) return;
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);

		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}
}

IMPULSE(weapon_reload)
{
	if (this.health <= 0) return;
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		Weapon w = this.(weaponentity).m_weapon;
		if(w == WEP_SPELLBOOK)
		{
			this.spellbook_altfire = !(this.spellbook_altfire);
			return;
		}
	}
}

void GiveAllWeapons(entity this)
{
	if(!autocvar_sv_cheats && !this.maycheat)
		return; // no more singleplayer functionality, unless they're smart enough to enable this!

	this.ammo_rockets = 100;
	this.ammo_nails = 200;
	this.ammo_shells = 100;
	this.ammo_cells = 200;
	FOREACH(Weapons, it != WEP_Null,
	{
		if(!MP_HIPNOTIC && (it.spawnflags & WEP_FLAG_HIPNOTIC))
			continue;
		if(!MP_ROGUE && (it.spawnflags & WEP_FLAG_ROGUE))
			continue;
		if(!MP_IMPEL && (it.spawnflags & WEP_FLAG_IMPEL))
			continue;
		STAT(WEAPONS, this) |= it.m_wepset;
	});
	//this.items |= (IT_KEY1 | IT_KEY2); // breaks levels

	// mal: also give full armor...
	this.armortype = 0.8;
	this.armorvalue = 200;
	this.items &= ~(IT_ARMOR1 | IT_ARMOR2);
	this.items |= IT_ARMOR3;

	this.ammo_lava_nails = 200;
	this.ammo_multi_rockets = 100;
	this.ammo_plasma = 100;

	//this.items |= (IT_PULSERIFLE | IT_PULSEPOWER1 | IT_PULSEPOWER2);

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		if(autocvar_g_weaponswitch_debug != 1)
			break;
	}

	this.impulse = 0;
	_sound(this, CH_WEAPON_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);
}

void GiveDualWeapons(entity this)
{
	if(!autocvar_sv_cheats && !this.maycheat)
		return; // no more singleplayer functionality, unless they're smart enough to enable this!

	FOREACH(Weapons, it != WEP_Null && !(it.spawnflags & WEP_FLAG_NODUAL),
	{
		STAT(DUAL_WEAPONS, this) |= it.m_wepset;
	});
	_sound(this, CH_WEAPON_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);
}

void GiveQuad(entity this)
{
	if(!autocvar_sv_cheats && !this.maycheat)
		return; // no more singleplayer functionality, unless they're smart enough to enable this!

	this.powerups |= POWERUP_QUAD;
	this.super_time = 1;
	this.super_damage_finished = time + 999;
	_sound(this, CH_WEAPON_SINGLE, "items/damage.wav", 1, ATTN_NORM);
}

// also CheatImpulse
void ImpulseCommands(entity this)
{
	if (gameover || intermission_running) return;

	int imp = this.impulse;
	if (!imp) return;
	this.impulse = 0;

	if(imp == CHIMPULSE_GIVE_ALL.impulse)
	{
		GiveAllWeapons(this);
		return;
	}

	if(imp == CHIMPULSE_GIVE_DUALWEPS.impulse)
	{
		GiveDualWeapons(this);
		return;
	}

	if(imp == CHIMPULSE_GIVE_QUAD.impulse)
	{
		GiveQuad(this);
		return;
	}

	FOREACH(IMPULSES, it.impulse == imp, {
		void(entity) f = it.impulse_handle;
		if (!f) continue;
		f(this);
		return;
	});
}

void crosshair_trace(entity pl)
{
	traceline(pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * 65535, MOVE_NORMAL, pl);
}

void crosshair_trace_plusvisibletriggers(entity pl)
{
	FOREACH_ENTITY_FLOAT(solid, SOLID_TRIGGER,
	{
		if(it.model != "")
		{
			it.solid = SOLID_BSP;
			IL_PUSH(g_ctrace_changed, it);
		}
	});

	crosshair_trace(pl);

	IL_EACH(g_ctrace_changed, true, { it.solid = SOLID_TRIGGER; });

	IL_CLEAR(g_ctrace_changed);
}

IMPULSE(waypoint_personal_here)
{
	entity wp = WaypointSprite_DeployPersonal(WP_Waypoint, this, this.origin, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "personal waypoint spawned at location\n");
}

IMPULSE(waypoint_personal_crosshair)
{
	crosshair_trace(this);
	entity wp = WaypointSprite_DeployPersonal(WP_Waypoint, this, trace_endpos, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "personal waypoint spawned at crosshair\n");
}

IMPULSE(waypoint_personal_death)
{
	if (!this.death_origin) return;
	entity wp = WaypointSprite_DeployPersonal(WP_Waypoint, this, this.death_origin, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "personal waypoint spawned at death location\n");
}

IMPULSE(waypoint_here_follow)
{
	if (!coop) return;
	if (this.health <= 0) return;
	{
		entity wp = WaypointSprite_Attach(WP_Helpme, this, true, NULL);
		if (!wp) WaypointSprite_HelpMePing(this.waypointsprite_attachedforcarrier);
		else WaypointSprite_Ping(wp);
	}
	sprint(this, "HELP ME attached\n");
}

IMPULSE(waypoint_here_here)
{
	entity wp = WaypointSprite_DeployFixed(WP_Here, false, this, this.origin, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "HERE spawned at location\n");
}

IMPULSE(waypoint_here_crosshair)
{
	crosshair_trace_plusvisibletriggers(this);
	entity wp = WaypointSprite_DeployFixed(WP_Here, false, this, trace_endpos, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "HERE spawned at crosshair\n");
}

IMPULSE(waypoint_here_death)
{
	if (!this.death_origin) return;
	entity wp = WaypointSprite_DeployFixed(WP_Here, false, this, this.death_origin, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "HERE spawned at death location\n");
}

IMPULSE(waypoint_danger_here)
{
	entity wp = WaypointSprite_DeployFixed(WP_Danger, false, this, this.origin, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "DANGER spawned at location\n");
}

IMPULSE(waypoint_danger_crosshair)
{
	crosshair_trace(this);
	entity wp = WaypointSprite_DeployFixed(WP_Danger, false, this, trace_endpos, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "DANGER spawned at crosshair\n");
}

IMPULSE(waypoint_danger_death)
{
	if (!this.death_origin) return;
	entity wp = WaypointSprite_DeployFixed(WP_Danger, false, this, this.death_origin, NULL);
	if (wp) WaypointSprite_Ping(wp);
	sprint(this, "DANGER spawned at death location\n");
}

IMPULSE(waypoint_clear_personal)
{
	WaypointSprite_ClearPersonal(this);
	sprint(this, "personal waypoint cleared\n");
}

IMPULSE(waypoint_clear)
{
	WaypointSprite_ClearOwned(this);
	sprint(this, "all waypoints cleared\n");
}
