#include "keyleth.qh"

#include "demon.qh"

#ifdef SVQC
METHOD(Keyleth, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		sound(actor, CH_PLAYER_SINGLE, SND_Keyleth_Transform, 1, ATTN_NORM);
		Send_Effect(EFFECT_QCC_GIB, actor.origin, '0 0 0', 4);
		actor.transform_limited = time + 20;
		actor.transform_health = 300;
		actor.m_transform = CHAMPION_Demon;
		STAT(QCC_ABILITYTIME, actor) = time + 30;
		.entity weaponentity = weaponentities[0]; // TODO?
		actor.keyleth_oldweapon = actor.(weaponentity).m_weapon;
		actor.keyleth_prevweapon = actor.(weaponentity).cnt;
	}
}

METHOD(Keyleth, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Keyleth_Start_Random(), ATTN_NORM);
	Inventory_add(WEP_MUSHROOM, actor, ITEM_OWNED);
	Inventory_add(WEP_STAFF, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
	{
		W_SwitchWeapon(actor, WEP_STAFF, weaponentity);
		actor.(weaponentity).cnt = WEP_AXE.m_id;
	}
	else if(actor.keyleth_oldweapon)
	{
		if(Inventory_have(actor.keyleth_oldweapon, actor, ITEM_OWNED))
			W_SwitchWeapon(actor, actor.keyleth_oldweapon, weaponentity);

		Weapon prevwep = REGISTRY_GET(Weapons, actor.keyleth_prevweapon);
		if(Inventory_have(prevwep, actor, ITEM_OWNED))
			actor.(weaponentity).cnt = actor.keyleth_prevweapon;
	}

	actor.keyleth_oldweapon = NULL;
	actor.keyleth_prevweapon = 0;
}

METHOD(Keyleth, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_MUSHROOM, actor, ITEM_OWNED);
	Inventory_add(WEP_STAFF, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
	{
		W_SwitchWeapon(actor, WEP_STAFF, weaponentity);
		actor.(weaponentity).cnt = WEP_AXE.m_id;
	}

	actor.keyleth_oldweapon = NULL;
	actor.keyleth_prevweapon = 0;
}

METHOD(Keyleth, m_dealdamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(attacker.m_champion == this && (deathtype & HITTYPE_MAGIC))
		return 1.5;
	return 1;
}

METHOD(Keyleth, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_Keyleth_Cannon_Launch, ATTN_NORM);
	actor.keyleth_cannon = true;
}

METHOD(Keyleth, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.keyleth_cannon)
		return false;
	player_sound(actor, CH_PLAYER_SINGLE, SND_Keyleth_Cannon_Land, ATTN_NORM);
	actor.keyleth_cannon = false;
	return false;
}
#endif

#ifdef CSQC
METHOD(Keyleth, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/keyleth_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}

METHOD(Keyleth, m_drawplayer, void(Champions this, entity actor))
{
	if(actor.csqcmodel_isdead)
		return;
	if(!SpawnParticles_list_full(strcat("cl_particle_", EFFECT_QCC_HEALING.eent_eff_name), actor.absmin, actor.absmax, actor.velocity, actor.velocity, bound(0, frametime, 0.1), false, 0))
		boxparticles(particleeffectnum(EFFECT_QCC_HEALING), actor, actor.absmin, actor.absmax, actor.velocity, actor.velocity, bound(0, frametime, 0.1), 0);
}
#endif
