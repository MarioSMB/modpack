#include "dryad.qh"

#ifdef SVQC
.float leaf_dmgtime;
void dryad_leaf_think(entity this)
{
	if(!this.owner || this.owner.m_champion != CHAMPION_Dryad || this.owner.health < 1 || intermission_running)
	{
		delete(this);
		return;
	}

	this.nextthink = time;

	entity targ = this.owner;
	float trange = 2;
	if(this.enemy && time <= this.leaf_chargetime)
	{
		trange = 0.5;
		targ = this.enemy;
	}

	vector owner_org = ((targ.absmin + targ.absmax) * 0.5);
	vector dir = normalize(owner_org - this.origin);

	dir = dir + v_forward * sin(cos(0.15 * this.spawn_time) * M_PI * time) * trange + v_right * sin(cos(2 * this.spawn_time) * M_PI * time) * trange + v_up * cos(sin(0.15 * this.spawn_time) * M_PI * time) * trange;

	float myspeed = 200;
	if(vdist(this.origin - owner_org, >, 1000))
		myspeed = 700;
	this.velocity = dir * myspeed;
	vector ang = vectoangles(this.velocity);
	this.angles_y = ang.y;

	// NOTE: only hits monsters as leaves are disabled in PvP
	// and we don't want doors randomly opening!
	FOREACH_ENTITY_RADIUS(this.origin, this.cnt, it.takedamage && IS_MONSTER(it) && it != this.owner,
	{
		if(time < it.leaf_dmgtime)
			continue;
		if(it.clipgroup && it.clipgroup == this.clipgroup)
			continue;
		float damg = ((this.dmg) ? this.dmg : 9);
		spawn_touchblood(this, damg, it);
		T_Damage(it, this, this.owner, damg, this.projectiledeathtype);
		it.leaf_dmgtime = time + 0.2;
	});
}

void dryad_leaf_spawn(entity this)
{
	entity leaf = spawn();
	leaf.classname = "dryad_leaf";
	leaf.owner = this;
	leaf.realowner = this;
	leaf.solid = SOLID_NOT;
	set_movetype(leaf, MOVETYPE_NOCLIP);
	leaf.spawn_time = time;
	_setmodel(leaf, "progs/leaf.mdl");
	setsize(leaf, '0 0 0', '0 0 0');
	leaf.cnt = 12; // rough size for damage calculations
	leaf.dmg = 20;
	leaf.projectiledeathtype = DEATH_CRUSH.m_id;
	setorigin(leaf, this.origin);
	setthink(leaf, dryad_leaf_think);
	leaf.nextthink = time;
	leaf.effects = EF_LOWPRECISION;
	leaf.clipgroup = this.clipgroup;

	IL_PUSH(g_leaves, leaf);
}

METHOD(Dryad, m_activate, void(Champions this, entity actor))
{
	if(time >= actor.dryad_transformtime && actor.health > 0)
		player_sound(actor, CH_VOICE, SND_Dryad_Start_Random(), ATTN_NORM);

	Inventory_add(WEP_BLADEOFGRASS, actor, ITEM_OWNED);

	if(time < actor.dryad_transformtime)
	{
		// just transformed back, restore weapons!
		.entity weaponentity = weaponentities[0]; // TODO?
		if(Inventory_have(actor.dryad_oldweapon, actor, ITEM_OWNED))
			W_SwitchWeapon(actor, actor.dryad_oldweapon, weaponentity);

		Weapon prevwep = REGISTRY_GET(Weapons, actor.dryad_prevweapon);
		if(Inventory_have(prevwep, actor, ITEM_OWNED))
			actor.(weaponentity).cnt = actor.dryad_prevweapon;
	}

	// always clear them anyway
	actor.dryad_oldweapon = WEP_Null;
	actor.dryad_prevweapon = 0;
}

METHOD(Dryad, m_playerspawn, void(Champions this, entity actor))
{
	STAT(CORRUPTION, actor) = 0;

	Inventory_add(WEP_BLADEOFGRASS, actor, ITEM_OWNED);
}

METHOD(Dryad, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this)
		return 0.9;
	return 1;
}

METHOD(Dryad, m_playerthink, void(Champions this, entity actor))
{
	if(actor.health > 0 && STAT(CORRUPTION, actor) > 0)
		STAT(CORRUPTION, actor) -= (PHYS_INPUT_FRAMETIME * 0.5); // TODO: why do we need to divide it?

	if(PHYS_INPUT_BUTTON_CROUCH(actor) && STAT(CORRUPTION, actor) < 10 && QCC_CanCastAbility(actor))
	{
		sound(actor, CH_PLAYER, SND_Dryad_Transform, 1, ATTN_NORM);
		te_explosion2(actor.origin, 85, 5);
		actor.m_transform = CHAMPION_Corrupted;
		//actor.transform_health = max(actor.health, 150);
		//actor.transform_limited = time + 20;
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		.entity weaponentity = weaponentities[0]; // TODO?
		actor.dryad_oldweapon = actor.(weaponentity).m_weapon;
		actor.dryad_prevweapon = actor.(weaponentity).cnt;
		return;
	}

	if(time >= actor.dryad_lastleaf && !deathmatch)
	{
		actor.dryad_lastleaf = time + 0.5;

		int lcount = 0;
		IL_EACH(g_leaves, it.owner == actor,
		{
			lcount += 1;
		});
		if(lcount < 12)
			dryad_leaf_spawn(actor);
	}
}
#endif

#ifdef CSQC
STATIC_INIT(Dryad)
{
	registercvar("sbar_dryad_pos", "0.122 0.92");
	registercvar("sbar_dryad_size", "0.18 0.08");
}

METHOD(Dryad, m_overlay, void(Champions this))
{
	if(intermission || STAT(HEALTH) <= 0 || sb_showscores)
		return;

	vector panel_pos = stov(cvar_string("sbar_dryad_pos"));
	vector panel_size = stov(cvar_string("sbar_dryad_size"));

	HUD_Panel_ScalePosSize();

	vector pos = panel_pos;

	vector mySize = panel_size;

	vector col = '0.5 0 0.5';
	float charge = STAT(CORRUPTION);
	if(charge)
		charge /= 10;

	HUD_Panel_DrawProgressBar(pos + vec2(mySize.x * 0.07, mySize.y * 0.5), vec2(mySize.x * 0.85, mySize.y * 0.33), "progressbar", charge, false, 0, col, 0.6, DRAWFLAG_NORMAL);
	drawpic(pos, "gfx/quake/dryad_corruptbar", mySize, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}
#endif