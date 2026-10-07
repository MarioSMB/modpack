#include "doom.qh"

#ifdef SVQC
METHOD(Doom, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Doom_Start, ATTN_NORM);
}

METHOD(Doom, m_takeammo, bool(Champions this, entity actor))
{
	return (random() < 0.2);
}

METHOD(Doom, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(attacker.m_champion == this && IS_MONSTER(targ))
		targ.health = -100;
}

METHOD(Doom, m_dealdamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	Weapon death_weapon = DEATH_WEAPONOF(deathtype);
	if(attacker.m_champion == this)
	{
		if(death_weapon.spawnflags & WEP_FLAG_MELEE)
			return 3;
		else if(death_weapon == WEP_SHOTGUN || death_weapon == WEP_SUPER_SHOTGUN)
			return 1.5;
		else
			return 1;
	}
	else
		return 1;
}
#endif

#ifdef CSQC
// the things we do to avoid tempstrings...
string Doom_PickFace(int frm, bool washurt, int curframe)
{
	switch(frm)
	{
		default:
		case 4:
		{
			if(washurt) 			return "gfx/quake/doom_face_p1";
			else if(curframe == 1) 	return "gfx/quake/doom_face1_1";
			else if(curframe == 2) 	return "gfx/quake/doom_face1_2";
			else 					return "gfx/quake/doom_face1_0";
		}
		case 3:
		{
			if(washurt) 			return "gfx/quake/doom_face_p2";
			else if(curframe == 1) 	return "gfx/quake/doom_face2_1";
			else if(curframe == 2) 	return "gfx/quake/doom_face2_2";
			else 					return "gfx/quake/doom_face2_0";
		}
		case 2:
		{
			if(washurt) 			return "gfx/quake/doom_face_p3";
			else if(curframe == 1) 	return "gfx/quake/doom_face3_1";
			else if(curframe == 2) 	return "gfx/quake/doom_face3_2";
			else 					return "gfx/quake/doom_face3_0";
		}
		case 1:
		{
			if(washurt) 			return "gfx/quake/doom_face_p4";
			else if(curframe == 1) 	return "gfx/quake/doom_face4_1";
			else if(curframe == 2) 	return "gfx/quake/doom_face4_2";
			else 					return "gfx/quake/doom_face4_0";
		}
		case 0:
		{
			if(washurt) 			return "gfx/quake/doom_face_p5";
			else if(curframe == 1) 	return "gfx/quake/doom_face5_1";
			else if(curframe == 2) 	return "gfx/quake/doom_face5_2";
			else 					return "gfx/quake/doom_face5_0";
		}
	}
}

float doom_facetime = 0;
int doom_face = -1;
METHOD(Doom, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	//int myitems = STAT(ITEMS); // changed field due to reaching bit limit
	//int mypowerups = STAT(POWERUPS);
	string pic = "";

	int myhealth = STAT(HEALTH);
	if(oldhealth != myhealth && myhealth < oldhealth && (oldhealth - myhealth) >= 3)
		health_gettime = time + 0.2;
	oldhealth = myhealth;

	if(time >= doom_facetime)
	{
		doom_face += 1;
		if(doom_face > 2)
			doom_face = 0;
		doom_facetime = time + ((doom_face == 0) ? 3 : 1);
	}

	if(StatusEffects_active(STATUSEFFECT_Invisibility, g_statuseffects) && StatusEffects_active(STATUSEFFECT_Invulnerability, g_statuseffects))
		pic = "gfx/quake/doom_face_inv2";
	else if(StatusEffects_active(STATUSEFFECT_Quad, g_statuseffects))
	{
		int f = rint(STAT(HEALTH) / 20);
		f = bound(0, f, 4);
		switch(f)
		{
			default:
			case 4: pic = "gfx/quake/doom_face_quad1"; break;
			case 3: pic = "gfx/quake/doom_face_quad2"; break;
			case 2: pic = "gfx/quake/doom_face_quad3"; break;
			case 1: pic = "gfx/quake/doom_face_quad4"; break;
			case 0: pic = "gfx/quake/doom_face_quad5"; break;
		}
	}
	else if(StatusEffects_active(STATUSEFFECT_Invisibility, g_statuseffects) || (StatusEffects_active(STATUSEFFECT_FieldGen, g_statuseffects) && STAT(FIELDGEN_HEALTH) > 0))
		pic = "gfx/quake/doom_face_invis";
	else if(StatusEffects_active(STATUSEFFECT_Invulnerability, g_statuseffects))
		pic = "gfx/quake/doom_face_invul2";
	else if(STAT(HEALTH) < 5)
		pic = "gfx/quake/doom_face_dead";
	else
	{
		int f = rint(STAT(HEALTH) / 20);
		f = bound(0, f, 4);
		bool washurt = (time <= health_gettime);
		pic = Doom_PickFace(f, washurt, doom_face);
	}
		
	drawpic_aspect(pos, "gfx/quake/backtile", icon_size, '1 1 1', autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	return true;
}
#endif
