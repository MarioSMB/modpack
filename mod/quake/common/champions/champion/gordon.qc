#include "gordon.qh"

#ifdef SVQC
METHOD(Gordon, m_activate, void(Champions this, entity actor))
{
	float r = random();
	if(r < 0.33)
		player_sound(actor, CH_VOICE, "start1.wav", ATTN_NORM);
	else if(r < 0.66)
		player_sound(actor, CH_VOICE, "start2.wav", ATTN_NORM);
	else
		player_sound(actor, CH_VOICE, "start3.wav", ATTN_NORM);

	Inventory_add(WEP_CROWBAR, actor, ITEM_OWNED);
	Inventory_add(WEP_GRAVITY_GUN, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
		W_SwitchWeapon(actor, WEP_GRAVITY_GUN, weaponentity);
}

METHOD(Gordon, m_dealdamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(attacker.m_champion != this)
		return 1;
	if(targ != attacker && IS_PLAYER(targ) && targ.armorvalue > 0)
		return 1.5;
	if(targ.monsterdef == MON_JUGGERNAUT || (targ.monsterdef && (targ.monsterdef.spawnflags & MON_FLAG_METAL)))
		return 2;

	return 1;
}

METHOD(Gordon, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_CROWBAR, actor, ITEM_OWNED);
	Inventory_add(WEP_GRAVITY_GUN, actor, ITEM_OWNED);
}
#endif

#ifdef CSQC
METHOD(Gordon, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/gordon_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
