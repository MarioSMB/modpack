float(float g) spell_range =
{
	local float lev;
	
	lev = GetSpellLevel(self.owner, g);
	g = g & 63;
	if (g == SP_FIREBALL)
		return 150 + lev * 10;
	else if (g == SP_ZAP)
		return 100 + lev * 15;
	else if (g == SP_ICEBLAST)
		return 180;
	else if (g == SP_LEECH)
		return 90 + lev * 20;
	else if (g == SP_REPEL)
		return 120;
	else if (g == SP_NOVA)
		return 70;
	else if (g == SP_GOTO)
		return 52;
	else if (g == SP_THROW_CHAKRAM)
		return 200;
	else if (g == SP_GOTO2)
		return 128;
	else if (g == SP_ACTIVATE)
		return 55;
	else if (g == SP_ACTIVATE_SELF)
		return 55;
	else if (g == SP_FIGHT_MELEE)
		return 70; // LordHavoc 20040418 increased from 59, this is about 2 units bigger than a large monster box corner to corner with a player box
	else if (g == SP_FOLLOW)
		return 80;
	else if (g == SP_BRIBE)
		return 90;
	else if (g == SP_BRAWL)
		return 70; // LordHavoc 20040418 increased from 59, this is about 2 units bigger than a large monster box corner to corner with a player box
	else if (g == SP_SPRINT)
		return 70; // LordHavoc 20040418 increased from 59, this is about 2 units bigger than a large monster box corner to corner with a player box
	else if (g == SP_FRENZY)
		return 70; // LordHavoc 20040418 increased from 59, this is about 2 units bigger than a large monster box corner to corner with a player box
	else if (g == SP_FREEZE)
		return 210;
	else if (g == SP_AWAKEMONSTERS)
		return 128;
	return BIG_DISTANCE;
};

float(float sp) cast_aground =
{
	sp = sp & 63;
	if (sp == SP_FIREBALL)
		return FALSE;
	else if (sp == SP_ZAP)
		return FALSE;
	else if (sp == SP_POISONBALL)
		return FALSE;
	else if (sp == SP_LEECH)
		return FALSE;
	else if (sp == SP_ACTIVATE)
		return FALSE;
	else if (sp == SP_FIGHT_MELEE)
		return FALSE;
	else if (sp == SP_FIGHT_BOW)
		return FALSE;
	else if (sp == SP_THROW)
		return FALSE;
	else if (sp == SP_THROW_CHAKRAM)
		return FALSE;
	else if (sp == SP_BRAWL)
		return FALSE;
	else if (sp == SP_BRIBE)
		return FALSE;
	else if (sp == SP_FLAME_ARROW)
		return FALSE;	
	else if (sp == SP_SPRINT)
		return FALSE;
	else if (sp == SP_FRENZY)
		return FALSE;
	else if (sp == SP_TRANSMUTE)
		return 2;
	else if (sp == SP_IDENTIFY)
		return 2;
	else if (sp == SP_FIGHT_CBOW)
		return FALSE;
	return TRUE;
};

float (float sp, float lv) mana_for_spell =
{
	if (sp & SP_ITEM_CAST)
		return 0;
		
	sp = sp & 63;
	if (sp == SP_WARP)
		return 10 - ceil(lv * 1.25);
	else if (sp == SP_TELEPORT)
		return 17 - lv * 2;
	else if (sp == SP_SHIELD)
		return 7 + lv * 2;
	else if (sp == SP_EVILE)
		return 15 + lv * 5;
	else if (sp == SP_METEOR)
		return 10 + lv * 6;
	else if (sp == SP_TWISTER)
		return 8 + ceil(lv * 7.5);
	else if (sp <= 16)
		return floor((sp + lv) * 0.8 + ((16 - sp) * (lv / 7)) - 2);
	else if (sp == SP_FLAME_ARROW)
		return lv;
	else if (sp == SP_SPRINT)
		return lv;
	else if (sp == SP_BRAWL)
		return lv;
	else if (sp == SP_FRENZY)
		return lv;
	else if (sp == SP_IDENTIFY)
		return ceil(12 / lv);
	else if (sp == SP_AWAKEMONSTERS)
		return 1;
	return 0;
};