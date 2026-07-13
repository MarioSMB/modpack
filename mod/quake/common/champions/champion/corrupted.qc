#include "corrupted.qh"

#ifdef SVQC
// NOTE: this hack is needed because transformations don't call regular weapon animation code
void corrupted_wepanim(entity this)
{
	if(STAT(CANNON, this) || this.tank)
		return;

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		Weapon wep = this.(weaponentity).m_weapon;

		// TODO wr for this too?
		if(wep == WEP_CORRUPTED_CLAWS)
		{
			this.(weaponentity).m_frame += 1;
			if(this.(weaponentity).m_frame > 7)
				this.(weaponentity).m_frame = 0;
		}
	}
}

METHOD(Corrupted, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Corrupted_Start_Random(), ATTN_NORM);

	// original weapon added to prevent loss (TODO?)
	Inventory_add(WEP_BLADEOFGRASS, actor, ITEM_OWNED);

	Inventory_add(WEP_CORRUPTED_CLAWS, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // WEAPONTODO
	W_SwitchWeapon_Force(actor, WEP_CORRUPTED_CLAWS, weaponentity);
}

METHOD(Corrupted, m_playerthink, void(Champions this, entity actor))
{
	if(actor.health > 0 && STAT(CORRUPTION, actor) < 10)
		STAT(CORRUPTION, actor) += (PHYS_INPUT_FRAMETIME * 0.5); // TODO: why do we need to divide it?

	if(actor.m_transform == this && PHYS_INPUT_BUTTON_CROUCH(actor) && time >= STAT(QCC_ABILITYTIME, actor)) //&& QCC_CanCastAbility(actor))
	{
		actor.dryad_transformtime = time + 0.5; // prevent player voices on transform
		player_sound(actor, CH_VOICE, SND_Dryad_Transform, ATTN_NORM);
		te_explosion2(actor.origin, 85, 5);
		QCC_ClearTransform(actor);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		return;
	}

	if(time >= actor.corrupted_dmgtime && STAT(CORRUPTION, actor) >= 10)
	{
		player_sound(actor, CH_VOICE, SND_Corrupted_Damage_Random(), ATTN_NORM);
		actor.corrupted_dmgtime = time + 0.5;
		T_Damage(actor, NULL, NULL, 5, DEATH_GENERIC.m_id);
	}
}

METHOD(Corrupted, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_CORRUPTED_CLAWS, actor, ITEM_OWNED);
}

METHOD(Corrupted, m_playerrun, bool(Champions this, entity actor))
{
	corrupted_wepanim(actor);

	return false;
}
METHOD(Corrupted, m_playerstand, bool(Champions this, entity actor))
{
	corrupted_wepanim(actor);

	return false;
}
#endif

#ifdef SVQC
METHOD(Corrupted, m_touch, void(Champions this, entity actor, entity toucher))
{
	if(StatusEffects_active(STATUSEFFECT_PowerShield, actor))
		return; // better version
	if(time < actor.corrupted_bash_time)
		return;
	if(actor.velocity == '0 0 0')
		return;
	if(time > actor.corrupted_bash)
		return;

	if(IS_PLAYER(toucher) || (IS_MONSTER(toucher) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_DECOY)))
	{
		makevectors(actor.angles);
		vector vec = normalize(toucher.origin - actor.origin);
		float dot = vec * v_forward;
		if(dot < 0.3)
			return;

		if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
		{
			float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

			makevectors(actor.angles);
			toucher.velocity = v_forward * (300 * pushforce);
			toucher.velocity_z = (125 * pushforce);
		}

		te_explosion2(toucher.origin, 70, 10);

		float thedamage = 60;
		if(toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			thedamage = 120;

		T_Damage(toucher, actor, actor, thedamage, WEP_CORRUPTED_CLAWS.m_id);

		sound(toucher, CH_SHOTS, SND_Corrupted_Hit, 1, ATTN_NORM);

		actor.corrupted_bash_time = time + 0.5;
	}
}
#endif

METHOD(Corrupted, m_physics, bool(Champions this, entity actor, float dt))
{
	if(vdist(actor.velocity, <, PHYS_MAXSPEED(actor) * 0.6) && PHYS_INPUT_BUTTON_ATCK2(actor) && IS_ONGROUND(actor) && !(STAT(ITEMS, actor) & IT_TANK) && !QCC_HasSpellbook(actor))
	{
	#ifdef SVQC
		player_sound(actor, CH_WEAPON_SINGLE, SND_Corrupted_Pain, ATTN_NORM);
		actor.corrupted_bash = time + 0.7;
		.entity weaponentity = weaponentities[0];
		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;
		if(IS_PLAYER(actor))
			corrupted_lunge1(actor);
		wep_corrupted_lunge1(actor.(weaponentity));
	#endif
		vector vang = PHYS_INPUT_ANGLES(actor);
		makevectors('0 1 0' * vang.y);
		actor.velocity += v_forward * 700;
		actor.velocity_z += 100;
		UNSET_ONGROUND(actor);
	}
	return false;
}

#ifdef CSQC
PRECACHE(Corrupted)
{
	precache_pic("gfx/blood");
}

METHOD(Corrupted, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/dryad_face_corrupted";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}

METHOD(Corrupted, m_overlay, void(Champions this))
{
	if(intermission || STAT(HEALTH) <= 0 || sb_showscores)
		return;

	float oldfont = drawfont;
	drawfont = 8;

	// TODO: generic loading bar position?
	vector panel_pos = stov(cvar_string("sbar_dryad_pos"));
	vector panel_size = stov(cvar_string("sbar_dryad_size"));

	HUD_Panel_ScalePosSize();

	vector pos = panel_pos;

	vector mySize = panel_size;

	vector col = '0.5 0 0.5';

	float charge = STAT(CORRUPTION);
	if(charge)
		charge /= 10; // total duration

	drawpic('0 0 0', "gfx/blood", vec2(vid_conwidth, vid_conheight), '0.5 0 0.5', bound(0, charge * 0.5, 0.7), DRAWFLAG_NORMAL);

	if(charge >= 1)
	{
		vector blinkcolor = (time % 1 >= 0.5) ? '1 0 0' : '1 1 0';
		float theAlpha = 0.8 + 0.1 * sin(6 * time); // blink
		string s;
		s = sprintf(_("Press %s"), getcommandkey(_("(Crouch)"), "+crouch"));
		drawstring_aspect(pos - vec2(0, mySize.y * 0.5), s, vec2(mySize.x, mySize.y * 0.25), blinkcolor, autocvar_sbar_alpha_fg * theAlpha, DRAWFLAG_NORMAL);
	}

	HUD_Panel_DrawProgressBar(pos + vec2(mySize.x * 0.07, mySize.y * 0.5), vec2(mySize.x * 0.85, mySize.y * 0.33), "progressbar", charge, false, 0, col, 0.6, DRAWFLAG_NORMAL);
	drawpic(pos, "gfx/quake/dryad_corruptbar", mySize, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	drawfont = oldfont;
}
#endif
