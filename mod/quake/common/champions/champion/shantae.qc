#include "shantae.qh"

#ifdef SVQC
METHOD(Shantae, m_activate, void(Shantae this, entity actor))
{
	// don't play sound if we're swapping from an attack
	if(time >= actor.shantae_transformtime)
	{
		int chosen = bound(1, floor(random() * 8), 7);
		player_sound(actor, CH_VOICE, strcat("start", ftos(chosen), ".wav"), ATTN_NORM);
	}

	STAT(WEAPONS, actor) |= WEP_MAGIC.m_wepset;

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
	{
		W_SwitchWeapon(actor, WEP_MAGIC, weaponentity);
		actor.(weaponentity).cnt = WEP_AXE.m_id;
	}
	else if(time < actor.shantae_transformtime)
	{
		// just transformed back, restore weapons!
		if(STAT(WEAPONS, actor) & actor.shantae_oldweapon.m_wepset)
			W_SwitchWeapon(actor, actor.shantae_oldweapon, weaponentity);

		Weapon prevwep = REGISTRY_GET(Weapons, actor.shantae_prevweapon);
		if(STAT(WEAPONS, actor) & prevwep.m_wepset)
			actor.(weaponentity).cnt = actor.shantae_prevweapon;
	}

	// always clear them anyway
	actor.shantae_oldweapon = WEP_Null;
	actor.shantae_prevweapon = 0;
}

METHOD(Shantae, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		if(random() < 0.33)
		{
			int chosen = bound(1, floor(random() * 8), 7);
			player_sound(actor, CH_VOICE, strcat("transform", ftos(chosen), ".wav"), ATTN_NORM);
		}
		_sound(actor, CH_VOICE, "player_shantae/player_transform.wav", 1, ATTN_NORM);
		te_explosion2(actor.origin, 40, 7);
		actor.transform_health = 70;
		actor.m_transform = CHAMPION_Monkey;
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		.entity weaponentity = weaponentities[0]; // TODO?
		actor.shantae_oldweapon = actor.(weaponentity).m_weapon;
		actor.shantae_prevweapon = actor.(weaponentity).cnt;

		if(actor.waterlevel >= WATERLEVEL_SWIMMING && actor.watertype == CONTENT_WATER)
		{
			actor.transform_health = 150;
			actor.m_transform = CHAMPION_Mermaid;
		}
	}
}

METHOD(Shantae, m_playerspawn, void(Champions this, entity actor))
{
	STAT(WEAPONS, actor) |= WEP_MAGIC.m_wepset;

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
	{
		W_SwitchWeapon(actor, WEP_MAGIC, weaponentity);
		actor.(weaponentity).cnt = WEP_AXE.m_id;
	}
}

METHOD(Shantae, m_clear, void(Champions this, entity actor))
{
	STAT(WEAPONS, actor) &= ~WEP_MAGIC.m_wepset;
	if(actor.magic_bubble)
		delete(actor.magic_bubble);

	actor.magic_bubble = NULL;
}

METHOD(Shantae, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.shantae_cannon = true;
}

METHOD(Shantae, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.shantae_cannon)
		return false;
	player_sound(actor, CH_TRIGGER_SINGLE, "cannon_land.wav", ATTN_NORM);
	actor.shantae_cannon = false;
	actor.jump_flag = 0;
	return true;
}
#endif
