//FEATURE-DISABLED Some classic SMB powerups, including the mini mushroom, super star and life shroom!

#include "powerups/all.qh"

REGISTER_MUTATOR(mpowerups, true);

#ifdef SVQC
AUTOCVAR(g_powerups_mario_replace, bool, false, "");

MUTATOR_HOOKFUNCTION(mpowerups, ItemTouch)
{
	entity item = M_ARGV(0, entity);
	entity toucher = M_ARGV(1, entity);
	//GameItem def = item.itemdef;

	if (item.star_finished)
	{
		float t = max(StatusEffects_gettime(STATUSEFFECT_Star, toucher), time);
		if (autocvar_g_powerups_stack)
			t += item.star_finished;
		else
			t = max(t, time + item.star_finished);
		StatusEffects_apply(STATUSEFFECT_Star, toucher, t, 0);
		return MUT_ITEMTOUCH_PICKUP;
	}
	if (item.mini_finished)
	{
		float t = max(StatusEffects_gettime(STATUSEFFECT_Mini, toucher), time);
		if (autocvar_g_powerups_stack)
			t += item.mini_finished;
		else
			t = max(t, time + item.mini_finished);
		StatusEffects_apply(STATUSEFFECT_Mini, toucher, t, 0);
		return MUT_ITEMTOUCH_PICKUP;
	}
	if (item.life_finished)
	{
		float t = max(StatusEffects_gettime(STATUSEFFECT_Life, toucher), time);
		if (autocvar_g_powerups_stack)
			t += item.life_finished;
		else
			t = max(t, time + item.life_finished);
		StatusEffects_apply(STATUSEFFECT_Life, toucher, t, 0);
		return MUT_ITEMTOUCH_PICKUP;
	}

	if(GetResource(item, RES_HEALTH) && StatusEffects_active(STATUSEFFECT_Life, toucher))
	{
		bool gave = Item_GiveAmmoTo(item, toucher, RES_HEALTH, item.max_health * 2);
		if(!gave)
			return MUT_ITEMTOUCH_RETURN;
		return MUT_ITEMTOUCH_PICKUP;
	}
	return MUT_ITEMTOUCH_CONTINUE;
}

MUTATOR_HOOKFUNCTION(mpowerups, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);
	float frag_damage = M_ARGV(4, float);
	vector frag_force = M_ARGV(6, vector);

	if(StatusEffects_active(STATUSEFFECT_Star, frag_target))
	{
		if(!ITEM_DAMAGE_NEEDKILL(frag_deathtype))
			frag_damage = 0;
		if(frag_attacker != frag_target)
			frag_force = '0 0 0';
	}

	M_ARGV(4, float) = frag_damage;
	M_ARGV(6, vector) = frag_force;
}

MUTATOR_HOOKFUNCTION(mpowerups, FixPlayermodel)
{
	entity player = M_ARGV(2, entity);

	if(StatusEffects_active(STATUSEFFECT_Star, player))
		M_ARGV(1, int) = 2;
}

MUTATOR_HOOKFUNCTION(mpowerups, FilterItem, CBC_ORDER_FIRST)
{
	entity item = M_ARGV(0, entity);

	switch(item.itemdef)
	{
		case ITEM_Strength: break;
		case ITEM_Shield: break;
		case ITEM_HealthMega: break;
		default: return false;
	}
	if (!autocvar_g_powerups || !autocvar_g_powerups_mario_replace)
		return false;

	GameItem def;
	float r = random();
	if(r < 0.3)
		def = ITEM_Mini;
	else if(r < 0.6)
		def = ITEM_Life;
	else
		def = ITEM_Star;


	entity newitem = spawn();
	Item_CopyFields(item, newitem);
	newitem.classname = def.m_canonical_spawnfunc;
	if (MUTATOR_IS_ENABLED(ok))
		newitem.ok_item = true;
	newitem.spawnfunc_checked = true;
	StartItem(newitem, def);
	return true;
}

MUTATOR_HOOKFUNCTION(mpowerups, GetResourceLimit)
{
	entity player = M_ARGV(0, entity);
	entity resource_type = M_ARGV(1, entity);

	if(StatusEffects_active(STATUSEFFECT_Star, player) && resource_type == RES_HEALTH)
		M_ARGV(2, float) *= 2; // limit
}

MUTATOR_HOOKFUNCTION(mpowerups, PlayerRegen)
{
	entity player = M_ARGV(0, entity);

	if(StatusEffects_active(STATUSEFFECT_Mini, player))
	{
		M_ARGV(9, float) *= autocvar_g_powerup_mini_healthscale; // regen_health_stable
		M_ARGV(10, float) *= autocvar_g_powerup_mini_healthscale; // regen_health_rotstable
	}

	if(StatusEffects_active(STATUSEFFECT_Life, player))
	{
		M_ARGV(1, float) *= 2; // max_mod
		// limit handled by GetResourceLimit!
	}
}

#endif

#ifdef SVQC
MUTATOR_HOOKFUNCTION(mpowerups, PlayerPhysics_UpdateStats)
{
	entity player = M_ARGV(0, entity);
	// these automatically reset, no need to worry

	if(StatusEffects_active(STATUSEFFECT_Star, player))
		STAT(MOVEVARS_HIGHSPEED, player) *= autocvar_g_powerup_star_speed;
}

MUTATOR_HOOKFUNCTION(mpowerups, PlayerPhysics_PostUpdateStats)
{
	entity player = M_ARGV(0, entity);
	// these automatically reset, no need to worry

	if(StatusEffects_active(STATUSEFFECT_Mini, player))
	{
		float myscale = max(0, autocvar_g_powerup_mini_size);
		STAT(PL_MIN, player) = PL_MIN_CONST * myscale;
		STAT(PL_MAX, player) = PL_MAX_CONST * myscale;
		STAT(PL_CROUCH_MIN, player) = PL_CROUCH_MIN_CONST * myscale;
		STAT(PL_CROUCH_MAX, player) = PL_CROUCH_MAX_CONST * myscale;
		STAT(PL_VIEW_OFS, player) = PL_VIEW_OFS_CONST * myscale;
		STAT(PL_CROUCH_VIEW_OFS, player) = PL_CROUCH_VIEW_OFS_CONST * myscale;
	}
}
#endif

MUTATOR_HOOKFUNCTION(mpowerups, PlayerPhysics)
{
	entity player = M_ARGV(0, entity);

	if(StatusEffects_active(STATUSEFFECT_Mini, player))
	{
		if(player.waterlevel == WATERLEVEL_NONE && vdist(player.velocity, >, STAT(MINI_WATER_MINSPEED, player)))
			player.dphitcontentsmask |= DPCONTENTS_LIQUIDSMASK;
		else
			player.dphitcontentsmask &= ~DPCONTENTS_LIQUIDSMASK;
	}
}
