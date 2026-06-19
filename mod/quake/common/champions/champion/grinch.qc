#include "grinch.qh"

#ifdef SVQC
int autocvar_sv_quake_grinch_belch_time = 3;

.float thaw_time;
void belch_unfreeze(entity this)
{
	SUB_Unfreeze(this);
	this.thaw_time = time + 2;
}

void Grinch_Belch(entity this)
{
	if(random() < 0.5)
		player_sound(this, CH_VOICE, "belch1.wav", ATTN_NORM);
	else
		player_sound(this, CH_VOICE, "belch2.wav", ATTN_NORM);

	makevectors(this.angles);
	Send_Effect(EFFECT_BELCH, this.origin + this.view_ofs, v_forward * 96, 1);

	FOREACH_ENTITY_RADIUS(this.origin, 120, it.takedamage && it.health > 0 && !it.is_frozen && time > it.thaw_time && IS_MONSTER(it) && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS),
	{
		if(!Damage_ValidTarget(it, this))
			continue;
		vector vec = normalize(it.origin - this.origin);
		float dot = vec * v_forward;
		if(dot < 0.3)
			continue;

		SUB_Freeze(it);
		setthink(it, belch_unfreeze);
		it.nextthink = time + 3;

		float poisontime = 7;
		float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, it);
		if((time + poisontime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Poisoned, it, time + poisontime, 0);
	});
}

.int variant; // TODO
METHOD(Grinch, m_playerthink, void(Champions this, entity actor))
{
	if(!IS_PLAYER(actor))
		return;

	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		STAT(QCC_ABILITYTIME, actor) = time + autocvar_sv_quake_grinch_belch_time;
		Grinch_Belch(actor);
	}

	if(time >= actor.grinch_lastmaxcheck)
	{
		actor.grinch_lastmaxcheck = time + 3;
		bool foundmax = false;
		FOREACH_ENTITY_FLOAT(grinch_max, true,
		{
			if(IS_MONSTER(it) && it.charmed && it.charmer == actor && it.health > 0)
			{
				foundmax = true;
				break;
			}
		});

		if(!foundmax)
		{
			entity mon = new(monster);
			mon.variant = 3; // birthday
			mon = horn_spawnmonster(mon, actor.origin + '0 0 4', actor, MON_ROTTWEILER);
			if(!mon)
				return; // dunno how but just incase!
			mon.flags |= FL_CLONE; // clears it on death
			mon.colormod = '1 1 1'; // we're green, not max!
			mon.health = max(mon.health, 1000); // slight buffer since their health ticks down fast
			if(Challenge_Active(CHALLENGE_ONEHP))
				mon.health = 1;
			mon.max_health = mon.health;
			mon.grinch_max = true;
			mon.damage_mod = 2; // make him kinda strong!
			TeleportToTarget(mon, mon.charmer, false); // "unstick" from owner if possible
		}
	}
}

METHOD(Grinch, m_activate, void(Champions this, entity actor))
{
	float r = random();
	if(r < 0.25)
		player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
	else if(r < 0.50)
		player_sound(actor, CH_VOICE, "start2.wav", ATTN_NORM);
	else if(r < 0.75)
		player_sound(actor, CH_VOICE, "start3.wav", ATTN_NORM);
	else
		player_sound(actor, CH_VOICE, "start4.wav", ATTN_NORM);

	Inventory_add(WEP_SNOWBALL, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
		W_SwitchWeapon(actor, WEP_SNOWBALL, weaponentity);
}

METHOD(Grinch, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_SNOWBALL, actor, ITEM_OWNED);

	actor.grinch_lastmaxcheck = max(actor.grinch_lastmaxcheck, time + 1); // don't spawn him in immediately!
}

METHOD(Grinch, m_clear, void(Champions this, entity actor))
{
	FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
	{
		if(it.charmed && it.charmer == actor && it.grinch_max)
		{
			if(it.health > 20)
				it.health = 20;
			it.grinch_max = false;
		}
	});

	Inventory_remove(WEP_SNOWBALL, actor, ITEM_OWNED);
}

METHOD(Grinch, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.grinch_cannon = true;
}

METHOD(Grinch, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.grinch_cannon)
		return false;
	// NOTE: disabled as his voice clip is short!
	//stopsound(actor, CH_TRIGGER_SINGLE);
	actor.grinch_cannon = false;
	return false;
}
#endif
