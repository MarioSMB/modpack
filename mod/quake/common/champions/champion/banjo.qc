#include "banjo.qh"

#ifdef SVQC

METHOD(BanjoKazooie, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Banjo_Start, ATTN_NORM);
	Inventory_add(WEP_BREEGULLBLASTER, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
		W_SwitchWeapon(actor, WEP_BREEGULLBLASTER, weaponentity);
}

METHOD(BanjoKazooie, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_Banjo_Falling, ATTN_NORM);
	actor.banjo_cannon = true;
}

METHOD(BanjoKazooie, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.banjo_cannon)
		return false;
	stopsound(actor, CH_PLAYER_SINGLE);
	actor.banjo_cannon = false;
	actor.jump_flag = 0;
	return false;
}

METHOD(BanjoKazooie, m_pickup_sigil, void(Champions this, entity actor, entity item))
{
	// play a sigil collection sound, but give it a delay to play any jingles
	actor.banjo_sigilsound = time + 2.5;
}

METHOD(BanjoKazooie, m_playerthink, void(Champions this, entity actor))
{
	if(!actor.banjo_landed && IS_ONGROUND(actor))
	{
		actor.banjo_landed = true;
		STAT(QCC_JETPACKFUEL, actor) = 100;
	}

	if(actor.banjo_sigilsound && time > actor.banjo_sigilsound)
	{
		player_sound(actor, CH_VOICE, SND_Banjo_Start, ATTN_NORM);
		actor.banjo_sigilsound = 0;
	}
}

METHOD(BanjoKazooie, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_BREEGULLBLASTER, actor, ITEM_OWNED);
}

METHOD(BanjoKazooie, m_clear, void(Champions this, entity actor))
{
	actor.banjo_sigilsound = 0;
	Inventory_remove(WEP_BREEGULLBLASTER, actor, ITEM_OWNED);
}

#endif

METHOD(BanjoKazooie, m_jetpack, bool(Champions this, entity actor, float maxspd_mod, float dt))
{
	if(!PHYS_INPUT_BUTTON_CROUCH(actor) || QCC_PlayerOccupied(actor))
		return false;

#ifdef SVQC
	if(actor.banjo_landed && !IS_ONGROUND(actor))
		player_sound(actor, CH_VOICE, SND_Banjo_Flight, ATTN_NORM);
	actor.banjo_landed = false;
#endif

	float fuel_cost = 100;
	float maxspeed_up = 10;
	float maxspeed_side = 300;
	float accel_side = 260;
	float accel_up = 15;
	float antigrav = 0.2;
	float fuel_scale = 100;
	bool do_vertical_scale = true;
	jetpack_physics(actor, 1, dt, fuel_cost, maxspeed_up, maxspeed_side, accel_side, accel_up, antigrav, fuel_scale, do_vertical_scale);
	return true;
}

#ifdef CSQC
string Banjo_PickFace(int frm)
{
	switch(frm)
	{
		default:
		case 4: return "gfx/quake/banjo_face1";
		case 3: return "gfx/quake/banjo_face2";
		case 2: return "gfx/quake/banjo_face3";
		case 1: return "gfx/quake/banjo_face4";
		case 0: return "gfx/quake/banjo_face5";
	}
}

METHOD(BanjoKazooie, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	int f = bound(0, rint(STAT(HEALTH) / 20), 4);
	string pic = Banjo_PickFace(f);
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
