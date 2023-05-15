
float (float it) itemskin =
{
	local float n;
	
	if(it == IT_BOOK)
	{
		n = stat_suf - SF_SPELL;
		if(n < 1)
			n = 0;
		else if(n == SP_TELEPORT)
			n = SP_WARP;
		else if(n == SP_SUMMON)
			n = SP_WARP;
		else if(n == SP_METEOR)
			n = SP_FIREBALL;
		else if(n == SP_EVILE)
			n = SP_TELEPORT;
		return n;
	}
	else if(it == IT_NIGHTCLUB)
		return 1;
	return 0;
}


vector it_itemsize(float it)
{
	// should return x and y inventory size
	// z should be data flags
	
	if(it == IT_CLOTH)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_LAMMELLAR)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_CHAIN_MAIL)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_BREAST_PLATE)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_KNIFE)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_DAGGER)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SABRE)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR			
	else if(it == IT_RAPIER)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_BROADSWORD)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_CLUB)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_MACE)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_STAFF)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SCEPTER)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_HATCHET)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_AXE)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_WAR_AXE)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SHORT_BOW)
		return '1 3 6'; // ID_PREF | ID_SUF
	else if(it == IT_LONG_BOW)
		return '1 3 6'; // ID_PREF | ID_SUF		
	else if(it == IT_WAR_BOW)
		return '1 3 6'; // ID_PREF | ID_SUF
	else if(it == IT_THROWKNIFE)
		return '1 2 1'; // ID_DUR
	else if(it == IT_BUCKLER)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SHIELD)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR			
	else if(it == IT_AEGIS)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR	
	else if(it == IT_SKULL_CAP)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR							
	else if(it == IT_HELM)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR							
	else if(it == IT_GREAT_HELM)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR							
	// boots removed
	// amulet removed
	else if(it == IT_ARROWS)
		return '1 2 1'; // ID_DUR
	else if(it == IT_SPEARS)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR		
	else if(it == IT_ROBE)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_LEATHER)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_RING_MAIL)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SCALE_MAIL)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_ARMET)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SALLET)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_RONDACHE)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_KITE_SHIELD)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SCUTUM)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR				
	else if(it == IT_MATTOCK)
		return '2 2 7'; // FIXME
	else if(it == IT_HAMMER)
		return '2 2 7'; // FIXME
	else if(it == IT_FLAIL)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_FALCHION)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_KRIS)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_CROSSBOW)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_TRIDENT)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_LANCE)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_HALBERD)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SCYTHE)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_CLAW)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SLING)
		return '1 1 0'; // NOTHING!
	else if(it == IT_ROD)
		return '1 3 3'; // ID_SUF | ID_DUR
	else if(it == IT_WAND)
		return '1 3 3'; // ID_SUF | ID_DUR
	else if(it == IT_CHAKRAM)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_THROW_AXE)
		return '1 2 1'; // ID_DUR
	else if(it == IT_DART)
		return '1 2 1'; // ID_DUR
	else if(it == IT_JAVELIN)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_NAGINATA)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_KATANA)
		return '1 4 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SAI)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_NUNCHAKU)
		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else if(it == IT_SHIRUKEN)
		return '1 2 1'; // ID_DUR
	else if(it == IT_GOLD)
		return '2 1 1'; // ID_DUR FIXME		
	else if(it == IT_LESSER_HEAL)
		return '1 1 16'; // ID_MICRO
	else if(it == IT_HEAL_POTION)
		return '1 1 16'; // ID_MICRO
	else if(it == IT_GREATER_HEAL)
		return '1 1 16'; // ID_MICRO
	else if(it == IT_LESSER_MANA)
		return '1 1 16'; // ID_MICRO
	else if(it == IT_MANA_POTION)
		return '1 1 16'; // ID_MICRO
	else if(it == IT_GREATER_MANA)
		return '1 1 16'; // ID_MICRO
	else if(it == IT_CURE)
		return '1 1 16'; // ID_MICRO	
	else if(it == IT_BOOK)
		return '1 2 2'; // ID_SUF
	else if(it == IT_SCROLL)
		return '1 2 2'; // ID_SUF
	else if(it == IT_IDSCROLL)
		return '1 2 1'; // ID_DUR
	else if(it == IT_OIL_OF_REPAIR)
		return '1 2 1'; // ID_DUR
	else if(it == IT_OIL)
		return '1 2 2'; // ID_SUF
	else if(it == IT_OIL2)
		return '1 2 4'; // ID_PREF
	else if(it == IT_GOLD_ELIXIR)
		return '1 1 0';
	else if(it == IT_ELIXIR)
		return '2 1 2'; // ID_SUF
	else if(it == IT_ALE)
		return '1 2 1'; // ID_DUR
//	else if(it == IT_SICKLE)
//		return '2 2 7'; // ID_PREF | ID_SUF | ID_DUR
	else 
		return '2 2 7';

}

string itemmodel(float it)
{
	if(it < IT_ROBE) // speed improvement
	{
		if(!it)
			return "";
		else if(it == IT_CLOTH)
			return "progs/leath.mdl";
		else if(it == IT_LAMMELLAR)
			return "progs/leath.mdl";
		else if(it == IT_CHAIN_MAIL)
			return "progs/mail.mdl";
		else if(it == IT_BREAST_PLATE)
			return "progs/mail.mdl";
		else if(it == IT_KNIFE)
			return "progs/knife.mdl";
		else if(it == IT_DAGGER)
			return "progs/dagger.mdl";
		else if(it == IT_SABRE)
			return "progs/sabre.mdl";
		else if(it == IT_RAPIER)
			return "progs/rapier.mdl";
		else if(it == IT_BROADSWORD)
			return "progs/brdsword.mdl";
		else if(it == IT_CLUB)
			return "progs/club.mdl";
		else if(it == IT_MACE)
			return "progs/mace.mdl";
		else if(it == IT_STAFF)
			return "progs/staff.mdl";
		else if(it == IT_SCEPTER)
			return "progs/scepter.mdl";
		else if(it == IT_HATCHET)
			return "progs/hatchet.mdl";
		else if(it == IT_AXE)
			return "progs/axe.mdl";
		else if(it == IT_WAR_AXE)
			return "progs/waraxe.mdl";
		else if(it == IT_SHORT_BOW)
			return "progs/shortbow.mdl";
		else if(it == IT_LONG_BOW)
			return "progs/longbow.mdl";
		else if(it == IT_WAR_BOW)
			return "progs/warbow.mdl";
		else if(it == IT_THROWKNIFE)
			return "progs/thrwknfe.mdl";
		else if(it == IT_BUCKLER)
			return "progs/buckler.mdl";
		else if(it == IT_SHIELD)
			return "progs/ashield.mdl";
		else if(it == IT_AEGIS)
			return "progs/aegis.mdl";
		else if(it == IT_SKULL_CAP)
			return "progs/helm.mdl";
		else if(it == IT_HELM)
			return "progs/helm.mdl";
		else if(it == IT_GREAT_HELM)
			return "progs/helm.mdl";
		else if(it == IT_BOOTS)
			return "progs/boots.mdl";
		else if(it == IT_GREAVES)
			return "progs/greaves.mdl";
		else if(it == IT_AMULET)
			return "progs/amulet.mdl";
		else if(it == IT_ARROWS)
			return "progs/quiver.mdl";
		else if(it == IT_SPEARS)
			return "progs/spear.mdl";
	}
	else if(it < IT_GOLD)
	{
		if(it == IT_ROBE)
			return "progs/leath.mdl";
		else if(it == IT_LEATHER)
			return "progs/leath.mdl";
		else if(it == IT_RING_MAIL)
			return "progs/mail.mdl";
		else if(it == IT_SCALE_MAIL)
			return "progs/mail.mdl";
		else if(it == IT_ARMET)
			return "progs/helm.mdl";
		else if(it == IT_SALLET)
			return "progs/helm.mdl";
		else if(it == IT_RONDACHE)
			return "progs/rondache.mdl";
		else if(it == IT_KITE_SHIELD)
			return "progs/kite.mdl";
		else if(it == IT_SCUTUM)
			return "progs/tower.mdl";
		else if(it == IT_MATTOCK)
			return "progs/mattock.mdl";
		else if(it == IT_HAMMER)
			return "progs/hammer.mdl";
		else if(it == IT_FLAIL)
			return "progs/flail.mdl";
		else if(it == IT_FALCHION)
			return "progs/falchion.mdl";
		else if(it == IT_KRIS)
			return "progs/kris.mdl";
		else if(it == IT_CROSSBOW)
			return "progs/crossbow.mdl";
		else if(it == IT_TRIDENT)
			return "progs/trident.mdl";
		else if(it == IT_LANCE)
			return "progs/lance.mdl";
		else if(it == IT_HALBERD)
			return "progs/halberd.mdl";
		else if(it == IT_SCYTHE)
			return "progs/scythe.mdl";
		else if(it == IT_CLAW)
			return "progs/claw.mdl";
		else if(it == IT_SLING)
			return "progs/sling.mdl";
		else if(it == IT_ROD)
			return "progs/rod.mdl";
		else if(it == IT_WAND)
			return "progs/wand.mdl";
		else if(it == IT_CHAKRAM)
			return "progs/chakram.mdl";
		else if(it == IT_THROW_AXE)
			return "progs/throwaxe.mdl";
		else if(it == IT_DART)
			return "progs/dart.mdl";
		else if(it == IT_JAVELIN)
			return "progs/javelin.mdl";
		else if(it == IT_NAGINATA)
			return "progs/naginata.mdl";
		else if(it == IT_KATANA)
			return "progs/katana.mdl";
		else if(it == IT_SAI)
			return "progs/sai.mdl";
		else if(it == IT_NUNCHAKU)
			return "progs/nunchaku.mdl";
		else if(it == IT_SHIRUKEN)
			return "progs/shiruken.mdl";
	}
	else
	{
		if(it == IT_GOLD)
			return "progs/money.mdl";
		else if(it == IT_LESSER_HEAL)
			return "progs/hpot.mdl";
		else if(it == IT_HEAL_POTION)
			return "progs/hpot.mdl";
		else if(it == IT_GREATER_HEAL)
			return "progs/hpot.mdl";
		else if(it == IT_LESSER_MANA)
			return "progs/mpot.mdl";
		else if(it == IT_MANA_POTION)
			return "progs/mpot.mdl";
		else if(it == IT_GREATER_MANA)
			return "progs/mpot.mdl";
		else if(it == IT_ELIXIR)
			return "progs/elixir.mdl";
		else if(it == IT_BOOK)
			return "progs/book.mdl";
		else if(it == IT_SCROLL)
			return "progs/scroll.mdl";
		else if(it == IT_IDSCROLL)
			return "progs/scroll.mdl";
		else if(it == IT_OIL_OF_REPAIR)
			return "progs/oil.mdl";
		else if(it == IT_OIL)
			return "progs/oil.mdl";
		else if(it == IT_OIL2)
			return "progs/oil.mdl";
		else if(it == IT_GOLD_ELIXIR)
			return "progs/gelixir.mdl";
		else if(it == IT_CURE)
			return "progs/cpot.mdl";
		else if(it == IT_ALE)
			return "progs/mbottle.mdl";
	}
	return unique_itemmodel(it);

}

string it_itemicon(float it)
{
	if(it < IT_ROBE) // speed improvement
	{

		if(it == IT_CLOTH)
			return "gfx/leath.spr";
		else if(it == IT_LAMMELLAR)
			return "gfx/leath.spr";
		else if(it == IT_CHAIN_MAIL)
			return "gfx/mail.spr";
		else if(it == IT_BREAST_PLATE)
			return "gfx/mail.spr";
		else if(it == IT_KNIFE)
			return "gfx/knife.spr";
		else if(it == IT_DAGGER)
			return "gfx/dagger.spr";
		else if(it == IT_SABRE)
			return "gfx/sabre.spr";
		else if(it == IT_RAPIER)
			return "gfx/rapier.spr";
		else if(it == IT_BROADSWORD)
			return "gfx/sword.spr";
		else if(it == IT_CLUB)
			return "gfx/club.spr";
		else if(it == IT_MACE)
			return "gfx/mace.spr";
		else if(it == IT_STAFF)
			return "gfx/staff.spr";
		else if(it == IT_SCEPTER)
			return "gfx/scepter.spr";
		else if(it == IT_HATCHET)
			return "gfx/hatchet.spr";
		else if(it == IT_AXE)
			return "gfx/axe.spr";
		else if(it == IT_WAR_AXE)
			return "gfx/waraxe.spr";
		else if(it == IT_SHORT_BOW)
			return "gfx/shortbow.spr";
		else if(it == IT_LONG_BOW)
			return "gfx/longbow.spr";
		else if(it == IT_WAR_BOW)
			return "gfx/warbow.spr";
		else if(it == IT_THROWKNIFE)
			return "gfx/thrwknfe.spr";
		else if(it == IT_BUCKLER)
			return "gfx/buckler.spr";
		else if(it == IT_SHIELD)
			return "gfx/ashield.spr";
		else if(it == IT_AEGIS)
			return "gfx/aegis.spr";
		else if(it == IT_SKULL_CAP)
			return "gfx/helm.spr";
		else if(it == IT_HELM)
			return "gfx/helm.spr";
		else if(it == IT_GREAT_HELM)
			return "gfx/helm.spr";
		else if(it == IT_ARROWS)
			return "gfx/quiver.spr";
		else if(it == IT_SPEARS)
			return "gfx/spear.spr";
	}
	else if(it < IT_GOLD)
	{
		if(it == IT_ROBE)
			return "gfx/leath.spr";
		else if(it == IT_LEATHER)
			return "gfx/leath.spr";
		else if(it == IT_RING_MAIL)
			return "gfx/mail.spr";
		else if(it == IT_SCALE_MAIL)
			return "gfx/mail.spr";
		else if(it == IT_ARMET)
			return "gfx/helm.spr";
		else if(it == IT_SALLET)
			return "gfx/helm.spr";
		else if(it == IT_RONDACHE)
			return "gfx/rondache.spr";
		else if(it == IT_KITE_SHIELD)
			return "gfx/kite.spr";
		else if(it == IT_SCUTUM)
			return "gfx/tower.spr";
		else if(it == IT_MATTOCK)
			return "gfx/mattock.spr";
		else if(it == IT_HAMMER)
			return "gfx/hammer.spr";
		else if(it == IT_FLAIL)
			return "gfx/flail.spr";
		else if(it == IT_FALCHION)
			return "gfx/falchion.spr";
		else if(it == IT_KRIS)
			return "gfx/kris.spr";
		else if(it == IT_CROSSBOW)
			return "gfx/cbow.spr";
		else if(it == IT_TRIDENT)
			return "gfx/trident.spr";
		else if(it == IT_LANCE)
			return "gfx/lance.spr";
		else if(it == IT_HALBERD)
			return "gfx/halberd.spr";
		else if(it == IT_SCYTHE)
			return "gfx/scythe.spr";
		else if(it == IT_CLAW)
			return "gfx/claw.spr";
		else if(it == IT_SLING)
			return "gfx/sling.spr";
		else if(it == IT_ROD)
			return "gfx/rod.spr";
		else if(it == IT_WAND)
			return "gfx/wand.spr";
		else if(it == IT_CHAKRAM)
			return "gfx/chakram.spr";
		else if(it == IT_THROW_AXE)
			return "gfx/throwaxe.spr";
		else if(it == IT_DART)
			return "gfx/dart.spr";
		else if(it == IT_JAVELIN)
			return "gfx/javelin.spr";
		else if(it == IT_NAGINATA)
			return "gfx/naginata.spr";
		else if(it == IT_KATANA)
			return "gfx/katana.spr";
		else if(it == IT_SAI)
			return "gfx/sai.spr";
		else if(it == IT_NUNCHAKU)
			return "gfx/nunchaku.spr";
		else if(it == IT_SHIRUKEN)
			return "gfx/shiruken.spr";
	}
	else
	{
		if(it == IT_GOLD)
			return "gfx/money.spr";
		else if(it == IT_LESSER_HEAL)
			return "gfx/hpot.spr";
		else if(it == IT_HEAL_POTION)
			return "gfx/hpot.spr";
		else if(it == IT_GREATER_HEAL)
			return "gfx/hpot.spr";
		else if(it == IT_LESSER_MANA)
			return "gfx/mpot.spr";
		else if(it == IT_MANA_POTION)
			return "gfx/mpot.spr";
		else if(it == IT_GREATER_MANA)
			return "gfx/mpot.spr";
		else if(it == IT_ELIXIR)
			return "gfx/elixir.spr";
		else if(it == IT_BOOK)
			return "gfx/book.spr";
		else if(it == IT_SCROLL)
			return "gfx/scroll.spr";
		else if(it == IT_IDSCROLL)
			return "gfx/scroll.spr";
		else if(it == IT_OIL_OF_REPAIR)
			return "gfx/oil.spr";
		else if(it == IT_OIL)
			return "gfx/oil.spr";
		else if(it == IT_OIL2)
			return "gfx/oil.spr";
		else if(it == IT_GOLD_ELIXIR)
			return "gfx/cpot.spr"; // FIXME
		else if(it == IT_CURE)
			return "gfx/cpot.spr";
		else if(it == IT_ALE)
			return "gfx/oil.spr"; // FIXME
	
	}
	return "gfx/rondache.spr"; // unknown

}
const vector COLOR_RUST = '0.58 0.27 0';
const vector COLOR_SILVER = '1.25 1.25 1.25'; // brighter
const vector COLOR_ORANGE = '1 0.5 0';
const vector COLOR_GOLDEN = '1 0.82 0';
const vector COLOR_BLUE = '0 0 1';
const vector COLOR_GREEN = '0 1 0';
const vector COLOR_RED = '1 0 0';
const vector COLOR_ELBLUE = '0.5 1 1';


void itemapplyeffects(entity e)
{
// colormod support.
	vector c = '0 0 0';
	int colors = 0;
	
	setmodel(e, itemmodel(stat_it));
	
	if(stat_pref == PF_RUSTED)
	{
		c += COLOR_RUST;
		colors += 1;
	}
	else if(stat_pref == PF_SILVER)
	{
		c += COLOR_SILVER;
		colors += 1;
	}
	else if(stat_pref == PF_FIERY)
	{
		c += COLOR_ORANGE;
		colors += 1;
	}
	else if(stat_pref == PF_GOLDEN)
	{
		c += COLOR_GOLDEN;
		colors += 1;		
	}
	if(stat_suf == SF_FROST)
	{
		c += COLOR_BLUE;
		colors += 1;
	}
	else if(stat_suf == SF_POISON)
	{
		c += COLOR_GREEN;
		colors += 1;
	}
	else if(stat_suf == SF_FLAME)
	{
		c += COLOR_RED;
		colors += 1;
	}
	else if(stat_suf == SF_FIRE)
	{
		c += COLOR_ORANGE;
		colors += 1;
	}
	else if(stat_suf == SF_SHOCK)
	{
		c += COLOR_ELBLUE;
		colors += 1;
	}
	else if(stat_suf == SF_BLIGHT)
	{
		c += COLOR_GREEN;
		colors += 1;
	}
	e.skin = itemskin(stat_it);
	if(colors > 0)
	{
		e.colormod = c * (1/colors);

	}
	else
		e.colormod = '1 1 1';
}


string(float it) itemsound =
{

	if(it < IT_ROBE) // speed improvement
	{
		if(!it)
			return "";
		else if(it == IT_CLOTH)
			return "items/cloth.wav";
		else if(it == IT_LAMMELLAR)
			return "items/cloth.wav";
		else if(it == IT_CHAIN_MAIL)
			return "items/armor1.wav";
		else if(it == IT_BREAST_PLATE)
			return "items/armor1.wav";
		else if(it == IT_KNIFE)
			return "items/sword.wav";
		else if(it == IT_DAGGER)
			return "items/sword.wav";
		else if(it == IT_SABRE)
			return "items/sword.wav";
		else if(it == IT_RAPIER)
			return "items/sword.wav";
		else if(it == IT_BROADSWORD)
			return "items/sword.wav";
		else if(it == IT_CLUB)
			return "items/club.wav";
		else if(it == IT_MACE)
			return "items/club.wav";
		else if(it == IT_STAFF)
			return "items/club.wav";
		else if(it == IT_SCEPTER)
			return "items/club.wav";
		else if(it == IT_HATCHET)
			return "items/axe.wav";
		else if(it == IT_AXE)
			return "items/axe.wav";
		else if(it == IT_WAR_AXE)
			return "items/axe.wav";
		else if(it == IT_SHORT_BOW)
			return "items/bow.wav";
		else if(it == IT_LONG_BOW)
			return "items/bow.wav";
		else if(it == IT_WAR_BOW)
			return "items/bow.wav";
		else if(it == IT_THROWKNIFE)
			return "items/sword.wav";
		else if(it == IT_BUCKLER)
			return "items/shield.wav";
		else if(it == IT_SHIELD)
			return "items/shield.wav";
		else if(it == IT_AEGIS)
			return "items/shield.wav";
		else if(it == IT_SKULL_CAP)
			return "items/helm.wav";
		else if(it == IT_HELM)
			return "items/helm.wav";
		else if(it == IT_GREAT_HELM)
			return "items/helm.wav";
		else if(it == IT_BOOTS)
			return "items/booties.wav";
		else if(it == IT_GREAVES)
			return "items/helm.wav";
		else if(it == IT_AMULET)
			return "items/amulet.wav";
		else if(it == IT_ARROWS)
			return "items/arrows.wav";
		else if(it == IT_SPEARS)
			return "items/arrows.wav";
	}
	else if(it < IT_GOLD)
	{

		if(it == IT_ROBE)
			return "items/cloth.wav";
		else if(it == IT_LEATHER)
			return "items/cloth.wav";
		else if(it == IT_RING_MAIL)
			return "items/armor1.wav";
		else if(it == IT_SCALE_MAIL)
			return "items/armor1.wav";
		else if(it == IT_ARMET)
			return "items/helm.wav";
		else if(it == IT_SALLET)
			return "items/helm.wav";
		else if(it == IT_RONDACHE)
			return "items/shield.wav";
		else if(it == IT_KITE_SHIELD)
			return "items/shield.wav";
		else if(it == IT_SCUTUM)
			return "items/shield.wav";
		else if(it == IT_MATTOCK)
			return "items/axe.wav";
		else if(it == IT_HAMMER)
			return "items/axe.wav";
		else if(it == IT_FLAIL)
			return "items/axe.wav";
		else if(it == IT_FALCHION)
			return "items/sword.wav";
		else if(it == IT_KRIS)
			return "items/sword.wav";
		else if(it == IT_CROSSBOW)
			return "items/bow.wav";
		else if(it == IT_TRIDENT)
			return "items/club.wav";
		else if(it == IT_LANCE)
			return "items/club.wav";
		else if(it == IT_HALBERD)
			return "items/club.wav";
		else if(it == IT_SCYTHE)
			return "items/club.wav";
		else if(it == IT_CLAW)
			return "items/sword.wav";
		else if(it == IT_SLING)
			return "items/bow.wav";
		else if(it == IT_ROD)
			return "items/club.wav";
		else if(it == IT_WAND)
			return "items/club.wav";
		else if(it == IT_CHAKRAM)
			return "items/sword.wav";
		else if(it == IT_THROW_AXE)
			return "items/axe.wav";
		else if(it == IT_DART)
			return "items/sword.wav";
		else if(it == IT_JAVELIN)
			return "items/arrows.wav";
		else if(it == IT_NAGINATA)
			return "items/sword.wav";
		else if(it == IT_KATANA)
			return "items/sword.wav";
		else if(it == IT_SAI)
			return "items/sword.wav";
		else if(it == IT_NUNCHAKU)
			return "items/arrows.wav";
		else if(it == IT_SHIRUKEN)
			return "items/sword.wav";

	}
	else
	{
		if(it == IT_GOLD)
			return "items/gold.wav";
		else if(it == IT_LESSER_HEAL)
			return "items/potion.wav";
		else if(it == IT_HEAL_POTION)
			return "items/potion.wav";
		else if(it == IT_GREATER_HEAL)
			return "items/potion.wav";
		else if(it == IT_LESSER_MANA)
			return "items/potion.wav";
		else if(it == IT_MANA_POTION)
			return "items/potion.wav";
		else if(it == IT_GREATER_MANA)
			return "items/potion.wav";
		else if(it == IT_ELIXIR)
			return "items/potion.wav";
		else if(it == IT_BOOK)
			return "items/scroll.wav";
		else if(it == IT_SCROLL)
			return "items/scroll.wav";
		else if(it == IT_IDSCROLL)
			return "items/scroll.wav";
		else if(it == IT_OIL_OF_REPAIR)
			return "items/potion.wav";
		else if(it == IT_OIL)
			return "items/potion.wav";
		else if(it == IT_OIL2)
			return "items/potion.wav";
		else if(it == IT_GOLD_ELIXIR)
			return "items/potion.wav";
		else if(it == IT_CURE)
			return "items/potion.wav";
		else if(it == IT_ALE)
			return "items/potion.wav";
	}
	return unique_itemsound(it);
}

void it_itemstat(entity this)
{
	// fills stat_ with item specific info

	if(!stat_it)
		return;

	if(stat_it < IT_ROBE) // speed improvement
	{
		if(stat_it == IT_CLOTH)
		{
			// Cloth
			stat_loc = BODY | DURABILITY | EQUIPABLE;
			stat_price = 4 + floor(stat_dur * 0.25);
			stat_def = 5;
			stat_max_dur = 8;
			stat_action = 1; // skin hack
		}
		else if(stat_it == IT_LAMMELLAR)
		{
			// IT_LAMMELLAR
			stat_loc = BODY | DURABILITY | EQUIPABLE;
			stat_price = 20 + floor(stat_dur * 0.3);
			stat_max_dur = 40;
			stat_def = 13;
			stat_req_str = 15;
			stat_action = 1; // skin hack
		}
		else if(stat_it == IT_CHAIN_MAIL)
		{
			// chain mail
			stat_loc = BODY | DURABILITY | EQUIPABLE;
			stat_price = 100 + floor(stat_dur * 0.75);
			stat_max_dur = 100;
			stat_def = 30;
			stat_req_str = 50;
			stat_action = 2; // skin hack
		}
		else if(stat_it == IT_BREAST_PLATE)
		{
			// breastplate
			stat_loc = BODY | DURABILITY | EQUIPABLE;
			stat_price = 200 + stat_dur;
			stat_max_dur = 125;
			stat_def = 40;
			stat_req_str = 100;
			stat_action = 2; // skin hack
		}
		else if(stat_it == IT_KNIFE)
		{
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 10;
			stat_daml = 3;
			stat_dama = 1;
			stat_req_dex = 3;
			stat_req_str = 2;
			
			stat_price = 8 + floor(stat_dur * 0.2);
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_DAGGER)
		{
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 30;
			stat_daml = 9;
			stat_dama = 3;
			stat_price = 43 + floor(stat_dur * 0.3);
			stat_req_dex = 10;
			stat_req_str = 8;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_SABRE)
		{
			// sabre
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 12;
			stat_daml = 8;
			stat_dama = 3;
			stat_price = 15 + floor(stat_dur * 0.2);
			stat_req_dex = 5;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_RAPIER)
		{
			// rapier
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 20;
			stat_daml = 12;
			stat_dama = 6;
			stat_price = 25 + floor(stat_dur * 0.25);
			stat_req_dex = 12;
			stat_req_str = 14;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_BROADSWORD)
		{
			// broadsword
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 38;
			stat_daml = 30;
			stat_dama = 12;
			stat_price = 67 + floor(stat_dur * 0.5);
			stat_req_dex = 30;
			stat_req_str = 48;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_CLUB)
		{
			// club
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 8;
			stat_daml = 4;
			stat_dama = 6;
			stat_price = 6 + floor(stat_dur * 0.2);
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_MACE)
		{
			// mace
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 50;
			stat_daml = 25;
			stat_dama = 18;
			stat_price = 59 + floor(stat_dur * 0.3);
			stat_req_str = 60;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_STAFF)
		{
			// staff
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_max_dur = 13;
			stat_daml = 4;
			stat_dama = 3;
			stat_magic_quality = 2;
			stat_price = 28 + floor(stat_dur * 0.5);
			stat_req_mag = 10;
			stat_action = SP_FIGHT_MELEE;
			stat_misc = MISC_DOUBLEATTACK;
		}
		else if(stat_it == IT_SCEPTER)
		{
			// scepter
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 30;
			stat_daml = 22;
			stat_dama = 7;
			stat_magic_quality = 2;
			stat_price = 80 + floor(stat_dur * 0.5);
			stat_req_mag = 58;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_HATCHET)
		{
			// hatchet
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 13;
			stat_daml = 7;
			stat_dama = 3;
			stat_price = 16 + floor(stat_dur * 0.1);
			stat_req_str = 15;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_AXE)
		{
			// axe
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_max_dur = 30;
			stat_daml = 10;
			stat_dama = 8;
			stat_price = 30 + floor(stat_dur * 0.15);
			stat_req_str = 32;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_WAR_AXE)
		{
			// war axe
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_max_dur = 38;
			stat_daml = 30;
			stat_dama = 12;
			stat_price = 74 + floor(stat_dur * 0.5);
			stat_req_dex = 10;
			stat_req_str = 60;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_SHORT_BOW)
		{
			// short bow
			stat_tohit = -8;
			stat_loc = RIGHTARM | EQUIPABLE;
			stat_daml = 5;
			stat_dama = 8;
			stat_price = 18;
			stat_req_dex = 5;
			stat_action = SP_FIGHT_BOW;
		}
		else if(stat_it == IT_LONG_BOW)
		{
			// long bow
			stat_tohit = -4;
			stat_loc = RIGHTARM | EQUIPABLE;
			stat_daml = 9;
			stat_dama = 9;
			stat_price = 45;
			stat_req_dex = 25;
			stat_action = SP_FIGHT_BOW;
		}
		else if(stat_it == IT_WAR_BOW)
		{
			// war bow
			stat_loc = RIGHTARM | EQUIPABLE;
			stat_daml = 25;
			stat_dama = 20;
			stat_price = 82;
			stat_req_str = 15;
			stat_req_dex = 45;
			stat_action = SP_FIGHT_BOW;
		}
		else if(stat_it == IT_THROWKNIFE)
		{
			// spears
			stat_daml = 5;
			stat_dama = 11;
			stat_tohit = -8;
			stat_req_dex = 6;
			stat_loc = EQUIPABLE | RIGHTARM | STACKABLE | AMMO;
			stat_max_dur = 250;
			stat_price = ceil(stat_dur * 0.28);
			stat_action = SP_THROW;
		}
		else if(stat_it == IT_BUCKLER)
		{
			// buckler
			stat_loc = LEFTARM | EQUIPABLE | DURABILITY;
			stat_def = 3;
			stat_block = 2;
			stat_max_dur = 8;
			stat_price = 9 + floor(stat_dur * 0.5);
		}
		else if(stat_it == IT_SHIELD)
		{
			// shield
			stat_loc = LEFTARM | EQUIPABLE | DURABILITY;
			stat_def = 5;
			stat_block = 10;
			stat_max_dur = 18;
			stat_price = 26 + floor(stat_dur * 0.15);
			stat_req_str = 17;
		}
		else if(stat_it == IT_AEGIS)
		{
			// aegis
			stat_loc = LEFTARM | EQUIPABLE | DURABILITY;
			stat_def = 10;
			stat_block = 25;
			stat_max_dur = 45;
			stat_price = 55 + floor(stat_dur * 0.5);
			stat_req_str = 33;
		}
		else if(stat_it == IT_SKULL_CAP)
		{
			// skull cap
			stat_loc = HEAD | EQUIPABLE | DURABILITY;
			stat_def = 3;
			stat_max_dur = 10;
			stat_price = 8 + floor(stat_dur * 0.1);
		}
		else if(stat_it == IT_HELM)
		{
			// helm
			stat_loc = HEAD | EQUIPABLE | DURABILITY;
			stat_def = 7;
			stat_max_dur = 22;
			stat_price = 60 + floor(stat_dur * 0.3);
			stat_req_str = 16;
		}
		else if(stat_it == IT_GREAT_HELM)
		{
			// great helm
			stat_loc = HEAD | EQUIPABLE | DURABILITY;
			stat_def = 12;
			stat_max_dur = 30;
			stat_price = 90 + floor(stat_dur * 0.6);
			stat_req_str = 45;
		}
		else if(stat_it == IT_BOOTS)
		{
			// helm
			stat_loc = FEET | EQUIPABLE | DURABILITY;
			stat_def = 2;
			stat_max_dur = 12;
			stat_price = 5 + floor(stat_dur * 0.2);
		}
		else if(stat_it == IT_GREAVES)
		{
			// great helm
			stat_loc = FEET | EQUIPABLE | DURABILITY;
			stat_def = 8;
			stat_max_dur = 30;
			stat_price = 10 + floor(stat_dur * 0.4);
			stat_req_str = 18;
		}
		else if(stat_it == IT_AMULET)
		{
			// amulet
			if(stat_suf || stat_pref)
			{
				stat_magic_quality = 2;
				stat_loc = NECK | EQUIPABLE;
				stat_price = 50;
			}
		}
		else if(stat_it == IT_ARROWS)
		{
			// arrows
			stat_loc = AMMO | LEFTARM | STACKABLE | EQUIPABLE;
			stat_max_dur = 250;
			stat_price = ceil(stat_dur * 0.04);
		}
		else if(stat_it == IT_SPEARS)
		{
			// spears
			stat_daml = 10;
			stat_dama = 30;
			stat_tohit = -5;
			stat_req_dex = 14;
			stat_loc = AMMO | RIGHTARM | EQUIPABLE | STACKABLE;
			stat_max_dur = 250;
			stat_price = ceil(stat_dur * 0.34);
			stat_action = SP_THROW;
		}

	}
	else if(stat_it < IT_GOLD)
	{
		if(stat_it == IT_ROBE)
		{
			// Robe
			stat_loc = BODY | DURABILITY | EQUIPABLE;
			stat_price = 10 + floor(stat_dur * 0.3);
			stat_def = 6;
			stat_max_dur = 8;
			stat_req_mag = 10;
			stat_magic_quality = 2;
			stat_action = 3; // skin hack
		}
		else if(stat_it == IT_LEATHER)
		{
			stat_loc = BODY | DURABILITY | EQUIPABLE;
			stat_price = 11 + floor(stat_dur * 0.3);
			stat_max_dur = 30;
			stat_def = 9;
			stat_req_str = 8;
			stat_action = 1; // skin hack
		}
		else if(stat_it == IT_RING_MAIL)
		{
			// chain mail
			stat_loc = BODY | DURABILITY | EQUIPABLE;
			stat_price = 60 + floor(stat_dur * 0.5);
			stat_max_dur = 80;
			stat_def = 23;
			stat_req_str = 36;
			stat_action = 2; // skin hack
		}
		else if(stat_it == IT_SCALE_MAIL)
		{
			// breastplate
			stat_loc = BODY | DURABILITY | EQUIPABLE;
			stat_price = 150 + stat_dur;
			stat_max_dur = 110;
			stat_def = 35;
			stat_req_str = 80;
			stat_action = 2; // skin hack
		}
		else if(stat_it == IT_ARMET)
		{
			// great helm
			stat_loc = HEAD | EQUIPABLE | DURABILITY;
			stat_def = 15;
			stat_max_dur = 40;
			stat_price = 110 + floor(stat_dur * 0.6);
			stat_req_str = 50;
		}
		else if(stat_it == IT_SALLET)
		{
			// helm
			stat_loc = HEAD | EQUIPABLE | DURABILITY;
			stat_def = 5;
			stat_max_dur = 16;
			stat_price = 30 + floor(stat_dur * 0.3);
			stat_req_str = 8;
		}
		else if(stat_it == IT_RONDACHE)
		{
			// shield
			stat_loc = LEFTARM | EQUIPABLE | DURABILITY;
			stat_def = 7;
			stat_block = 15;
			stat_max_dur = 30;
			stat_price = 35 + floor(stat_dur * 0.17);
			stat_req_str = 23;
		}
		else if(stat_it == IT_KITE_SHIELD)
		{
			// aegis
			stat_loc = LEFTARM | EQUIPABLE | DURABILITY;
			stat_def = 12;
			stat_block = 30;
			stat_max_dur = 50;
			stat_price = 75 + floor(stat_dur * 0.7);
			stat_req_str = 37;
		}
		else if(stat_it == IT_SCUTUM)
		{
			// aegis
			stat_loc = LEFTARM | EQUIPABLE | DURABILITY;
			stat_def = 12;
			stat_block = 55;
			stat_max_dur = 50;
			stat_price = 90 + floor(stat_dur * 0.5);
			stat_req_str = 50;
		}
		else if(stat_it == IT_MATTOCK)
		{
			// axe
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_max_dur = 40;
			stat_daml = 20;
			stat_dama = 6;
			stat_piercing = 5;
			stat_price = 60 + floor(stat_dur * 0.2);
			stat_req_str = 44;
			stat_action = SP_FIGHT_MELEE;
			stat_misc = MISC_DOUBLEATTACK;
		}
		else if(stat_it == IT_HAMMER)
		{
			// mace
			stat_loc = DURABILITY | EQUIPABLE | TWO_HAND;
			stat_max_dur = 65;
			stat_daml = 90;
			stat_dama = 20;
			stat_aspeed = stat_aspeed - 10;
			stat_price = 200 + floor(stat_dur * 0.3);
			stat_req_str = 120;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_FLAIL)
		{
			// mace
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 50;
			stat_daml = 45;
			stat_dama = 20;
			stat_price = 110 + floor(stat_dur * 0.3);
			stat_req_str = 75;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_FALCHION)
		{
			// rapier
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 30;
			stat_daml = 25;
			stat_dama = 11;
			stat_price = 60 + floor(stat_dur * 0.3);
			stat_req_dex = 20;
			stat_req_str = 18;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_KRIS)
		{
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 25;
			stat_daml = 20;
			stat_dama = 5;
			stat_price = 60 + floor(stat_dur * 0.3);
			stat_req_dex = 17;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_CROSSBOW)
		{
			// long bow
			stat_tohit = -4;
			stat_loc = RIGHTARM | EQUIPABLE;
			stat_daml = 14;
			stat_aspeed = stat_aspeed - 25;
			stat_dama = 10;
			stat_price = 40;
			stat_req_dex = 10;
			stat_action = SP_FIGHT_CBOW;
		}
		else if(stat_it == IT_TRIDENT)
		{
			// mace
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_max_dur = 40;
			stat_daml = 60;
			stat_dama = 10;
			stat_aspeed = stat_aspeed - 5;
			stat_price = 200 + floor(stat_dur * 0.3);
			stat_req_str = 70;
			stat_action = SP_FIGHT_MELEE;
			stat_misc = MISC_DOUBLEATTACK;
		}
		else if(stat_it == IT_LANCE)
		{
			// mace
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_max_dur = 25;
			stat_daml = 40;
			stat_dama = 8;
			stat_aspeed = stat_aspeed - 5;
			stat_price = 200 + floor(stat_dur * 0.25);
			stat_req_str = 40;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_HALBERD)
		{
			// mace
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_max_dur = 35;
			stat_daml = 55;
			stat_dama = 10;
			stat_aspeed = stat_aspeed - 8;
			stat_price = 90 + floor(stat_dur * 0.5);
			stat_req_str = 40;
			stat_action = SP_FIGHT_MELEE;
			stat_misc = MISC_DOUBLEATTACK;
		}
		else if(stat_it == IT_SCYTHE)
		{
			// mace
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_max_dur = 17;
			stat_daml = 27;
			stat_dama = 5;
			stat_aspeed = stat_aspeed - 4;
			stat_price = 45 + floor(stat_dur * 0.25);
			stat_req_str = 27;
			stat_action = SP_FIGHT_MELEE;
			stat_misc = MISC_DOUBLEATTACK;
		}
		else if(stat_it == IT_CLAW)
		{
			// rapier
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_max_dur = 20;
			stat_daml = 15;
			stat_dama = 2;
			stat_price = 20 + floor(stat_dur * 0.4);
			stat_req_agil = 12;
			stat_action = SP_FIGHT_MELEE;
		}
		else if(stat_it == IT_SLING)
		{
			// short bow
			stat_tohit = -4;
			stat_loc = RIGHTARM | EQUIPABLE;
			stat_daml = 5;
			stat_dama = 3;
			stat_price = 10;
			stat_req_dex = 5;
			stat_action = SP_FIGHT_CBOW;
		}
		else if(stat_it == IT_ROD)
		{
			stat_loc = RIGHTARM | EQUIPABLE | CHARGES;
			stat_action = (stat_suf - SF_SPELL);
			stat_magic_quality = 2;
			if(stat_action < 0)
				stat_action = SP_FIGHT_MELEE;
				
			stat_req_mag = 10 + ceil(stat_action * 2);
			stat_max_dur = ceil(100 / stat_action);
			stat_price = 30 + floor(stat_action * 3.3);

		}
		else if(stat_it == IT_WAND)
		{
			stat_loc = RIGHTARM | EQUIPABLE | CHARGES;
			stat_action = (stat_suf - SF_SPELL);
			stat_magic_quality = 1;
			if(stat_action < 0)
				stat_action = SP_FIGHT_MELEE;
			stat_req_mag = 10 + ceil(stat_action * 1);
			stat_max_dur =  ceil(100 / stat_action);
			stat_price = 20 + floor(stat_action * 2.2);
		}
		else if(stat_it == IT_CHAKRAM)
		{
			// spears
			stat_daml = 5;
			stat_dama = 11;
			stat_tohit = -12;
			stat_req_dex = 7;
			stat_loc = EQUIPABLE | RIGHTARM;
			stat_max_dur = 1;
			stat_price = 42;
			stat_action = SP_THROW_CHAKRAM;
		}
		else if(stat_it == IT_THROW_AXE)
		{
			stat_loc = AMMO | RIGHTARM | EQUIPABLE | STACKABLE;
			stat_action = SP_THROW;
			stat_price = ceil(0.44 * stat_dur);
			stat_daml = 8;
			stat_tohit = -8;
			stat_dama = 15;
			stat_max_dur = 150;
			stat_req_dex = 11;
		}
		else if(stat_it == IT_DART)
		{
			stat_loc = AMMO | RIGHTARM | EQUIPABLE | STACKABLE;
			stat_action = SP_THROW;
			stat_price = ceil(0.56 * stat_dur);
			stat_daml = 10;
			stat_tohit = -8;
			stat_dama = 22;
			stat_max_dur = 200;
			stat_req_dex = 15;
		}
		else if(stat_it == IT_JAVELIN)
		{
			stat_loc = AMMO | RIGHTARM | EQUIPABLE | STACKABLE;
			stat_action = SP_THROW;
			stat_price = ceil(0.65 * stat_dur);
			stat_daml = 20;
			stat_dama = 60;
			stat_tohit = -10;
			stat_max_dur = 200;
			stat_req_dex = 35;
		}
		else if(stat_it == IT_NAGINATA)
		{
			stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
			stat_action = SP_FIGHT_MELEE;
			stat_price = ceil(0.4 * stat_dur) + 60;
			stat_daml = 40;
			stat_dama = 10;
			stat_max_dur = 50;
			stat_req_str = 30;
		}
		else if(stat_it == IT_KATANA)
		{
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_action = SP_FIGHT_MELEE;
			stat_price = ceil(0.25 * stat_dur) + 60;
			stat_daml = 27;
			stat_dama = 5;
			stat_max_dur = 33;
			stat_req_str = 19;
		}
		else if(stat_it == IT_SAI)
		{
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_action = SP_FIGHT_MELEE;
			stat_price = ceil(0.7 * stat_dur) + 4;
			stat_daml = 10;
			stat_dama = 10;
			stat_max_dur = 28;
			stat_req_str = 8;
			stat_req_dex = 6;
		}
		else if(stat_it == IT_NUNCHAKU)
		{
			stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
			stat_action = SP_FIGHT_MELEE;
			stat_price = ceil(0.15 * stat_dur) + 40;
			stat_daml = 20;
			stat_dama = 4;
			stat_max_dur = 20;
			stat_req_str = 5;
			stat_req_agil = 5;
			stat_req_dex = 5;
		}
		else if(stat_it == IT_SHIRUKEN)
		{
			stat_loc = STACKABLE | AMMO | RIGHTARM | EQUIPABLE;
			stat_action = SP_THROW;
			stat_price = ceil(0.9 * stat_dur);
			stat_daml = 10;
			stat_tohit = -12;
			stat_dama = 13;
			stat_max_dur = 200;
			stat_req_dex = 12;
		}
	}
	else
	{
		if(stat_it == IT_GOLD)
		{
			// Gold
			stat_loc = STACKABLE;
			stat_max_dur = 15000;
			stat_price = stat_dur;
		}
		else if(stat_it == IT_LESSER_HEAL)
		{
			// health potion
			stat_loc = USABLE | STACKABLE;
			stat_price = ceil(1.5 * stat_dur);
			stat_max_dur = 150;
		}
		else if(stat_it == IT_HEAL_POTION)
		{
			// health potion
			stat_loc = USABLE | STACKABLE;
			stat_price = 3 * stat_dur;
			stat_max_dur = 150;
		}
		else if(stat_it == IT_GREATER_HEAL)
		{
			// health potion
			stat_loc = USABLE | STACKABLE;
			stat_price = 5 * stat_dur;
			stat_max_dur = 150;
		}
		else if(stat_it == IT_LESSER_MANA)
		{
			// mana potion
			stat_loc = USABLE | STACKABLE;
			stat_price = 1 * stat_dur;
			stat_max_dur = 150;
		}
		else if(stat_it == IT_MANA_POTION)
		{
			// mana potion
			stat_loc = USABLE | STACKABLE;
			stat_price = 2 * stat_dur;
			stat_max_dur = 150;
		}
		else if(stat_it == IT_GREATER_MANA)
		{
			// mana potion
			stat_loc = USABLE | STACKABLE;
			stat_price = ceil(3.5 * stat_dur);
			stat_max_dur = 150;
		}
		else if(stat_it == IT_ELIXIR)
		{
			// elixir potion
			if(stat_suf)
			{
				stat_loc = USABLE;
				stat_price = 220;
			}
		}
		else if(stat_it == IT_BOOK)
		{
			// book
			if(stat_suf)
				stat_loc = USABLE;
		}
		else if(stat_it == IT_SCROLL)
		{
			if(stat_suf)
			{
				// scroll
				stat_loc = EQUIPABLE | STACKABLE | SPELL | AMMO;
				stat_max_dur = 50;
				stat_magic_quality = 7;
			}
		}
		else if(stat_it == IT_IDSCROLL)
		{
			// scroll
			stat_loc = USE_ON_ITEM | USABLE | STACKABLE;
			stat_max_dur = 50;
			stat_price = 2 * stat_dur;
		}
		else if(stat_it == IT_OIL_OF_REPAIR)
		{
			stat_price = ceil(5.5 * stat_dur);
			stat_max_dur = 50;
			stat_loc = USE_ON_ITEM | USABLE | STACKABLE;
		}
		else if(stat_it == IT_OIL)
		{
			stat_max_dur = 1;
			stat_price = 70;
			stat_loc = USE_ON_ITEM | USABLE;
		}
		else if(stat_it == IT_OIL2)
		{
			stat_max_dur = 1;
			stat_price = 80;
			stat_loc = USE_ON_ITEM | USABLE;
		}
		else if(stat_it == IT_GOLD_ELIXIR)
		{
			stat_max_dur = 1;
			stat_req_lvl = 20;
			//stat_toall = 1;
			stat_price = 600;
			stat_loc = USABLE;
		}
		else if(stat_it == IT_CURE)
		{
			stat_loc = USABLE | STACKABLE;
			stat_price = ceil(0.5 * stat_dur);
			stat_max_dur = 250;
		}
		else if(stat_it == IT_ALE)
		{
			stat_loc = USABLE | STACKABLE;
			stat_price = ceil(0.5 * stat_dur);
			stat_max_dur = 50;
		}
		else
		{
			uniquestat();
			return;
		}
	
	}
	if(!stat_id)
		return;
//==========================================================================
	if(stat_pref)
	{
		if(stat_pref == PF_BROKEN)
		{
			// broken
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 0.2);
				stat_dama = ceil(stat_dama * 0.2);
			}
			else if(stat_def)
				stat_def = ceil(stat_def * 0.2);
			stat_price = ceil(stat_price * 0.25);
		}
		else if(stat_pref == PF_DAMAGED)
		{
			// damaged
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 0.5);
				stat_dama = ceil(stat_dama * 0.5);
			}
			else if(stat_def)
				stat_def = ceil(stat_def * 0.5);
			stat_max_dur = ceil(stat_max_dur * 0.75);
			stat_price = ceil(stat_price * 0.3);
		}
		else if(stat_pref == PF_CURSED)
		{
			// cursed
			stat_luck = stat_luck - 20;
			stat_price = ceil(stat_price * 0.5);
		}
		else if(stat_pref == PF_FLAMMABLE)
		{
			// uselss
			stat_resist_fire = stat_resist_fire - 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 0.4);
		}
		else if(stat_pref == PF_RUSTED)
		{
			// rusted
			stat_max_dur = ceil(0.8 * stat_max_dur);
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 0.6);
				stat_dama = ceil(stat_dama * 0.6);
			}
			else if(stat_def)
				stat_def = ceil(stat_def * 0.6);
			stat_price = ceil(stat_price * 0.3);
		}
		else if(stat_pref == PF_BRITTLE)
		{
			// brittle
			stat_max_dur = ceil(stat_max_dur * 0.1);
			stat_price = ceil(stat_price * 0.35);
		}
		else if(stat_pref == PF_CHEAP)
		{
			// cheap
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 0.8);
				stat_dama = ceil(stat_dama * 0.8);
			}
			else if(stat_def)
				stat_def = ceil(stat_def * 0.8);
			stat_max_dur = ceil(stat_max_dur * 0.9);
			stat_price = ceil(stat_price * 0.5);
		}
		else if(stat_pref == PF_UNWIELDY)
		{
			// unwieldy
			if((stat_loc & LOC) == RIGHTARM)
				stat_loc = stat_loc | LEFTARM;
			if(stat_daml)
				stat_tohit = stat_tohit - 5;
			else if(stat_def)
				stat_dodge = stat_dodge - 5;
			stat_price = ceil(stat_price * 0.5);
			stat_req_dex = stat_req_dex + 12;
		}
		else if(stat_pref == PF_RUGGED)
		{
			// rugged
			stat_max_dur = ceil(stat_max_dur * 1.2);
			stat_price = ceil(stat_price * 1.1) + 22;
		}
		else if(stat_pref == PF_SHARP)
		{
			// sharp
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.5);
				stat_dama = ceil(stat_dama * 0.5);
			}
			stat_price = ceil(stat_price * 1.3) + 33;
		}
		else if(stat_pref == PF_QUALITY)
		{
			// quality
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.4);
				stat_dama = ceil(stat_dama * 1.4);
			}
			else if(stat_def)
				stat_def = ceil(stat_def * 1.8);
			stat_price = ceil(stat_price * 1.5) + 35;
		}
		else if(stat_pref == PF_LUCKY)
		{
			// lucky
			stat_luck = stat_luck + ceil(stat_max_dur * 0.25);
			if(!stat_luck)
				stat_luck = 5;
			else if(stat_luck > 15)
				stat_luck = 15;
			if(stat_daml)
				stat_tohit = stat_tohit + 20;
			if(stat_def)
				stat_dodge = stat_dodge + 20;
			stat_price = ceil(stat_price * 1.7) + 60;
		}
		else if(stat_pref == PF_SUPERIOR)
		{
			// superior
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.8);
				stat_dama = ceil(stat_dama * 1.1);
			}
			else if(stat_def)
				stat_def = ceil(stat_def * 2.2);

			stat_price = ceil(stat_price * 1.8) + 60;
		}
		else if(stat_pref == PF_WIZARDS)
		{
			// Wizard's
			stat_req_mag = stat_req_mag + 25;
			if(stat_loc & DURABILITY)
				stat_mana = stat_mana + ceil(stat_max_dur * 0.25);
			else
				stat_mana = stat_mana + 15;
			stat_price = ceil(stat_price * 1.2) + 32;
		}
		else if(stat_pref == PF_ACCURATE)
		{
			// accurate
			if(stat_loc & DURABILITY)
				stat_dex = stat_dex + ceil(stat_max_dur * 0.1);
			else
				stat_dex = stat_dex + 5;
			stat_price = ceil(stat_price * 1.25) + 44;
		}
		else if(stat_pref == PF_DEADLY)
		{
			// deadly
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 2.5);
			}
			stat_critical = stat_critical + 10;
			stat_price = ceil(stat_price * 1.6) + 54;
		}
		else if(stat_pref == PF_WARRIORS)
		{
			// warrior's
			stat_req_str = stat_req_str + 25;
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 2);
				stat_tohit = stat_tohit + 25;
			}
			else if(stat_def)
			{
				stat_def = ceil(stat_def * 2.4);
				stat_block = stat_block + 25;
			}
			else
				stat_tohit = stat_tohit + 25;
			stat_price = ceil(stat_price * 1.6) + 70;
		}
		else if(stat_pref == PF_ULTIMATE)
		{
			// ultimate
			stat_req_lvl = 30;
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 3);
				stat_tohit = stat_tohit + 80;
			}
			else if(stat_def)
			{
				stat_def = ceil(stat_def * 3);
				stat_block = stat_block + 80;
			}
			else
			{
				stat_fire = stat_fire + 10 * stat_magic_quality;
				stat_lit = stat_lit + 10 * stat_magic_quality;
				stat_poison = stat_poison + 20 * stat_magic_quality;
			}
			stat_price = ceil(stat_price * 3.5) + 200;
		}
		else if(stat_pref == PF_SILVER)
		{
			// silver
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.6);
				stat_dama = ceil(stat_dama * 1.6);
				stat_req_dex = stat_req_dex + 12;
			}
			else if(stat_def)
			{
				stat_def = ceil(stat_def * 1.8);
				stat_req_str = stat_req_str + 12;	
			}
			else
				stat_tohit = stat_tohit + 10;
			if(stat_max_dur <= 235)
				stat_max_dur = stat_max_dur + 10;
			stat_price = ceil(stat_price * 2) + 45;
		}
		else if(stat_pref == PF_VIGOROUS)
		{
			// vigorous
			if(stat_loc & DURABILITY)
				stat_health = stat_health + floor(stat_max_dur * 0.2)  * stat_magic_quality;
			else
				stat_health = stat_health + 10 * stat_magic_quality;
			stat_vit = stat_vit + 10  * stat_magic_quality;
			stat_price = ceil(stat_price * 1.2) + 71 * stat_magic_quality;
		}
		else if(stat_pref == PF_HEAVY)
		{
			// heavy
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.8);
				stat_dama = ceil(stat_dama * 1.8);
			}
			else if(stat_def)
				stat_def = ceil(stat_def * 1.4);
				
			stat_req_str = stat_req_str + 25;
			if(stat_max_dur <= 225)	
				stat_max_dur = stat_max_dur + 30;
			stat_price = ceil(stat_price * 1.8) + 40;
		}
		else if(stat_pref == PF_THIEFS)
		{
			// thief's
			stat_agil = stat_agil + 10;
			stat_req_dex = stat_req_dex + 5;
			stat_price = ceil(stat_price * 1.1) + 42;
		}
		else if(stat_pref == PF_BRUTAL)
		{
			// brutal
			if(stat_daml)
				stat_daml = ceil(stat_daml * 2);
			else
				stat_daml = 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.3) + 30;
		}
		else if(stat_pref == PF_FIERY)
		{
			// fiery 
			stat_fire = stat_fire + 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.4) + 21;
		}
		else if(stat_pref == PF_LIGHT)
		{
			// light
			// hmmm
			if(stat_req_str)
				stat_req_str = ceil(stat_req_str * 0.5);
			else if(stat_req_dex)
				stat_req_dex = ceil(stat_req_dex * 0.5);

			stat_dodge = stat_dodge + 10;
			stat_price = ceil(stat_price * 1.2) + 14;
		
		}
		else if(stat_pref == PF_RAPID)
		{
			// rapid (special case)
			stat_aspeed = stat_aspeed + 15;
			stat_price = ceil(stat_price * 1.35) + 29;
		}
		else if(stat_pref == PF_KOR)
		{
			if(stat_loc & DURABILITY)
				stat_resist_fire = stat_resist_fire + ceil(stat_max_dur/2.2) * stat_magic_quality * 2;
			else
				stat_resist_fire = stat_resist_fire + 30 * stat_magic_quality;
				
			stat_price = ceil(stat_price * 1.33) + (stat_resist_fire);
		}
		else if(stat_pref == PF_GOLDEN)
		{
			// golden
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 2.2);
				stat_dama = ceil(stat_dama * 0.5);
				stat_tohit = stat_tohit + 10;
			}
			else if(stat_def)
			{
				stat_def = ceil(stat_def * 1.7);
				stat_block = stat_block + 10;
			}
			else
				stat_dodge = stat_dodge + 10;
			stat_req_str = stat_req_str + 30;
			if(stat_max_dur <= 220)
				stat_max_dur = stat_max_dur + 35;
			stat_price = ceil(stat_price * 1.8) + 60;
		}
		else if(stat_pref == PF_THINKERS)
		{
			// thinker's
			stat_req_mag = stat_req_mag + 10 * stat_magic_quality;
			if(stat_loc & DURABILITY)
				stat_mana = stat_mana + ceil(stat_max_dur * 0.3) * stat_magic_quality;
			else
				stat_mana = stat_mana + 15 * stat_magic_quality;
			stat_mag = stat_mag + 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.2) + 48;
		}
		else if(stat_pref == PF_TITANS)
		{
			// titan's
			if(stat_loc & DURABILITY)
				stat_health = stat_health + ceil(stat_max_dur * 0.2) * stat_magic_quality;
			else
				stat_health = stat_health + 15 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.28) + 30;
		}
		else if(stat_pref == PF_GROUNDED)
		{
			if(stat_loc & DURABILITY)
				stat_resist_lit = ceil(stat_max_dur/2.2) * stat_magic_quality * 2;
			else
				stat_resist_lit = 30 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.2) + (stat_resist_lit);
		}
		else if(stat_pref == PF_TYRS)
		{
			if(stat_loc & DURABILITY)
				stat_resist_lit = stat_resist_lit + ceil(stat_max_dur/2.2) * stat_magic_quality * 2;
			else
				stat_resist_lit = stat_resist_lit + 30 * stat_magic_quality;
				
			stat_price = ceil(stat_price * 1.33) + (stat_resist_lit);
		}
		else if(stat_pref == PF_ORSHAS)
		{
			if(stat_loc & DURABILITY)
				stat_resist_cold = stat_resist_cold + ceil(stat_max_dur/2.2) * stat_magic_quality * 2;
			else
				stat_resist_cold = stat_resist_cold + 30 * stat_magic_quality;
				
			stat_price = ceil(stat_price * 1.33) + (stat_resist_cold);
		}
		else if(stat_pref == PF_IVES)
		{
			if(stat_loc & DURABILITY)
				stat_resist_poison = stat_resist_poison + ceil(stat_max_dur/1.5) * stat_magic_quality * 2;
			else
				stat_resist_poison = stat_resist_poison + 35 * stat_magic_quality;
				
			stat_price = ceil(stat_price * 1.33) + (stat_resist_poison);
		}
		else if(stat_pref == PF_NIYALS)
		{
			if(stat_loc & DURABILITY)
				stat_resist_magic = stat_resist_magic + ceil(stat_max_dur/2.5) * stat_magic_quality * 2;
			else
				stat_resist_magic = stat_resist_magic + 24 * stat_magic_quality;
				
			stat_price = ceil(stat_price * 1.5) + (stat_resist_magic);
		}
		else
			stat_pref = 0;
	}
	if(stat_suf)
	{
		if(stat_suf == SF_FOOL)
		{
			// of the fool
			stat_mag = stat_mag - 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 0.25);
			return;
		}
		else if(stat_suf == SF_WEAK)
		{
			// of the weak
			stat_str = stat_str - 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 0.25);
			return;
		}
		else if(stat_suf == SF_CLUMSY)
		{
			// of the clumsy
			stat_dex = stat_dex - 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 0.25);
			return;
		}
		else if(stat_suf == SF_SLOW)
		{
			// of the slow
			stat_agil = stat_agil - 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 0.25);
			return;
		}
		else if(stat_suf == SF_MISFORTUNE)
		{
			// of misfortune
			stat_luck = stat_luck - 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 0.25);
			return;
		}
		else if(stat_suf == SF_FRAGILITY)
		{
			// of fragility (-dur)
			stat_max_dur = ceil(stat_max_dur * 0.1);
			stat_price = ceil(stat_price * 0.1);
			return;
		}
		else if(stat_suf == SF_CORRUPTION)
		{
			// of corruption (-mana)
			stat_mana = stat_mana - ceil(stat_max_dur * 0.1)  * stat_magic_quality;
			stat_price = ceil(stat_price * 0.3);
			return;
		}
		else if(stat_suf == SF_PIT)
		{
			// of the pit
			stat_toall = stat_toall - 5  * stat_magic_quality;
			stat_price = ceil(stat_price * 0.01);
			return;
		}
		else if(stat_suf == SF_FROST)
		{
			stat_cold = stat_cold + 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.5) + 35 * stat_magic_quality;		
			return;
		}
		else if(stat_suf == SF_VITALITY)
		{
			// of vitality
			if(stat_it == IT_ELIXIR)
				stat_vit = stat_vit + 1;
			else
				stat_vit = stat_vit + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.05) + 20 * stat_magic_quality;
			return;
		}
		else if(stat_suf == SF_VAMPIRE)
		{
			// vampire
			stat_spec = stat_spec | SPEC_STEAL_LIFE;
			stat_price = ceil(stat_price * 2) + 45;
			return;
		}
		else if(stat_suf == SF_LUCK)
		{
			// of luck
			if(stat_it == IT_ELIXIR)
				stat_luck = stat_luck + 1;
			else
				stat_luck = stat_luck + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.05) + 20 * stat_magic_quality;
			return;
		}
		else if(stat_suf == SF_STRENGTH)
		{
			// of strength
			if(stat_it == IT_ELIXIR)
				stat_str = stat_str + 1;
			else
				stat_str = stat_str + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.05) + 22 * stat_magic_quality;
			return;
		}
		else if(stat_suf == SF_INTELLIGENCE)
		{
			// of intelligence
			if(stat_it == IT_ELIXIR)
				stat_mag = stat_mag + 1;
			else
				stat_mag = stat_mag + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.05) + 24 * stat_magic_quality;
			return;
		}
		else if(stat_suf == SF_AGILITY)
		{
			// of agility
			if(stat_it == IT_ELIXIR)
				stat_agil = stat_agil + 1;
			else
				stat_agil = stat_agil + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.05) + 19;
			return;
		}
		else if(stat_suf == SF_REGEN)
		{
			// of regen
			stat_health_regen = stat_health_regen + 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.8) + 50 * stat_magic_quality;
			return;
		}
		else if(stat_suf == SF_DEXTERITY)
		{
			// of dex
			if(stat_it == IT_ELIXIR)
				stat_dex = stat_dex + 1;
			else
				stat_dex = stat_dex + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.05) + 21;
			return;
		}
		else if(stat_suf == SF_POISON)
		{
			// of poison
			stat_poison = stat_poison + 30 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.65) + 73;
			return;
		}
		else if(stat_suf == SF_LEECH)
		{
			// of leech
			stat_spec = stat_spec | SPEC_STEAL_MANA;
			stat_price = ceil(stat_price * 1.9) + 68;
			return;
		}
		else if(stat_suf == SF_PROTECTION)
		{
			// protection
			if(stat_def)
				stat_def = stat_def * 2;
			else
				stat_def = 10;
			stat_price = ceil(stat_price * 1.7) + 41;
			return;
		}
		else if(stat_suf == SF_HEALTH)
		{
			// of health
			stat_health = stat_health + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.2) + 19;
			return;
		}
		else if(stat_suf == SF_GIANTS)
		{
			// of Giants
			if(stat_loc & DURABILITY)
				stat_health = stat_health + floor(stat_max_dur * 0.2)  * stat_magic_quality;	
			else
				stat_health = stat_health + 25  * stat_magic_quality;
			stat_str = stat_str + 15 * stat_magic_quality;
			stat_req_lvl = stat_req_lvl + 20;
			stat_price = ceil(stat_price * 1.8) + 49;
			return;
		}
		else if(stat_suf == SF_HEAVENS)
		{
			// of heavens
			stat_toall = stat_toall + 5  * stat_magic_quality;
			stat_req_lvl = stat_req_lvl + 10;
			stat_price = ceil(stat_price * 1.7) + 127;
			return;
		}
		else if(stat_suf == SF_STARS)
		{
			// of stars
			stat_toall = stat_toall + 7  * stat_magic_quality;
			stat_req_lvl = stat_req_lvl + 20;
			stat_price = ceil(stat_price * 2) + 180;
			return;
		}
		else if(stat_suf == SF_MANA)
		{
			// of mana
			stat_mana = stat_mana + 10  * stat_magic_quality;
			stat_price = ceil(stat_price * 1.1) + 16;
			return;
		}
		else if(stat_suf == SF_HERETIC)
		{
			if(stat_loc & DURABILITY)
				stat_resist_magic = stat_resist_magic + ceil(stat_max_dur/2.5) * stat_magic_quality;
			else
				stat_resist_magic = stat_resist_magic + 20 * stat_magic_quality;
				
			stat_price = ceil(stat_price * 1.4) + (stat_resist_magic * 3);
			return;
		}
		else if(stat_suf == SF_FLAME)
		{
			// of flame
			stat_fire = stat_fire + 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.2) + 31;
			return;
		}
		else if(stat_suf == SF_QUALITY)
		{
			// quality
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.4);
				stat_dama = ceil(stat_dama * 1.4);
			}
			else if(stat_def)
				stat_def = ceil(stat_def * 1.8);
			stat_max_dur = ceil(stat_max_dur * 1.4);
			if(stat_max_dur >= 255)
				stat_max_dur = 255;
			stat_price = ceil(stat_price * 1.5) + 43;
			return;
		}
		else if(stat_suf == SF_BEAR)
		{
			// bear
			stat_spec = stat_spec | SPEC_KNOCKBACK;
			stat_price = ceil(stat_price * 1.25) + 16;
			return;
		}
		else if(stat_suf == SF_WIZARDRY)
		{
			// wizardry
			stat_mag = stat_mag + 10 * stat_magic_quality;
			if(stat_loc & DURABILITY)
				stat_mana = stat_mana + ceil(stat_max_dur * 0.1) * stat_magic_quality;
			else
				stat_mana = stat_mana + 10 * stat_magic_quality;
			stat_price =  ceil(stat_price * 2.2) + 84;
			return;
		}
		else if(stat_suf == SF_BASHING)
		{
			// quality
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.8);
				stat_dama = ceil(stat_dama * 1.2);
			}
			else 
				stat_daml = 5;
				
			stat_price = ceil(stat_price * 1.5) + 49;
			return;
		}
		else if(stat_suf == SF_HASTE)
		{
			// haste
			stat_agil = stat_agil + 12 * stat_magic_quality;
			stat_dodge = stat_dodge + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.5) + 68;
			return;
		}
		else if(stat_suf == SF_FIGHTING)
		{
			// fighting
			stat_str = stat_str + 5;
			stat_tohit = stat_tohit + 5;
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.8);
				stat_dama = ceil(stat_dama * 1.2);
			}
			stat_price = ceil(stat_price * 2.1) + 45;
			return;
		}
		else if(stat_suf == SF_SLAUGHTER)
		{
			// slaughter
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 2.2);
				stat_dama = ceil(stat_dama * 1.3);
			}

			stat_price = ceil(stat_price * 1.89) + 47;
			return;
		}
		else if(stat_suf == SF_VIM)
		{
			// vim
			stat_vit = stat_vit + 12 * stat_magic_quality;
			stat_health = stat_health + 10;
			stat_price = ceil(stat_price * 1.6) + 64;
			return;
		}
		else if(stat_suf == SF_ACCURACY)
		{
			// accuracy
			stat_dex = stat_dex + 11 * stat_magic_quality;
			stat_tohit = stat_tohit + 10;
			stat_price = ceil(stat_price * 1.45) + 60;
			return;
		}
		else if(stat_suf == SF_MAGI)
		{
			// the apprentice
			stat_mana_regen = 5 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.4) + 22;
			return;
		}
		else if(stat_suf == SF_AGES)
		{
			// the ages
			stat_spec = stat_spec | SPEC_INDESTRUCTIBLE;
			stat_loc = stat_loc - (stat_loc & DURABILITY);
			stat_price = ceil(stat_price * 2.2) + 62;	
			return;
		}
		else if(stat_suf == SF_MEDICINE)
		{
			if(stat_loc & DURABILITY)
				stat_resist_poison = stat_resist_poison + ceil(stat_max_dur/3.33) * stat_magic_quality * 2;
			else
				stat_resist_poison = stat_resist_poison + 30 * stat_magic_quality;
				
			stat_price = ceil(stat_price * 1.33) + stat_resist_poison;
		}
		else if(stat_suf == SF_SPIKES)
		{
			// spikes
			stat_attacker_dam = stat_attacker_dam + 50;
			if(stat_def)
				stat_def = ceil(stat_def * 1.2);
			stat_price = ceil(stat_price * 1.7) + 18;
			return;
		}
		else if(stat_suf == SF_FIRE)
		{
			// of Fire
			stat_fire = stat_fire + 12 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.5) + 54;
			return;
		}
		else if(stat_suf == SF_SHOCK)
		{
			// of Lightning
			stat_lit = stat_lit + 25 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.36) + 88;
			return;
		}
		else if(stat_suf == SF_BOUNTY)
		{
			// bounty
			if(stat_loc & DURABILITY)
				stat_mana = stat_mana + ceil(stat_max_dur * 0.4) * stat_magic_quality;
			else
				stat_mana = stat_mana + 20;
			stat_price = ceil(stat_price * 1.87) + 21;
			return;
		}
		else if(stat_suf == SF_MIND)
		{
			// the mind
			stat_mag = stat_mag + 8 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.77) + 71;
			return;
		}
		else if(stat_suf == SF_POWER)
		{
			// of power
			stat_str = stat_str + 10 * stat_magic_quality;
			stat_price = ceil(stat_price * 1.77) + 60;
			return;
		}
		else if(stat_suf == SF_KINGS)
		{
			// kings
			if(stat_daml)
			{
				stat_daml = ceil(stat_daml * 1.8);
				stat_dama = ceil(stat_dama * 1.6);
				stat_req_dex = stat_req_dex + 16;
			}
			else if(stat_def)
			{
				stat_def = ceil(stat_def * 1.8);
				stat_req_str = stat_req_str + 16;	
			}
			else
			{
				stat_tohit = stat_tohit + 15;
			}
			stat_req_lvl = stat_req_lvl + 15;
			if(stat_max_dur <= 240)
				stat_max_dur = stat_max_dur + 15;
			stat_price = ceil(stat_price  * 2.3) + 90;
			return;
		}
		else if(stat_suf == SF_EASE)
		{
			// ease
			stat_req_lvl = ceil(stat_req_lvl * 0.5);
			stat_req_str = ceil(stat_req_str * 0.5);
			stat_req_dex = ceil(stat_req_dex * 0.5);
			stat_req_mag = ceil(stat_req_mag * 0.5);
			stat_price = ceil(stat_price * 1.6) + 13;

			return;
		}
		else if(stat_suf == SF_BLIGHT)
		{
			stat_price = ceil(stat_price * 1.5) + 30;
			stat_attacker_poison = stat_attacker_poison + 15 * stat_magic_quality;
		}
		else if(stat_suf > SF_SPELL)
		{
			if(stat_it != IT_ROD && stat_it != IT_WAND)
				stat_spell = (stat_suf - SF_SPELL);
			stat_spell_level = 1 * stat_magic_quality;

			stat_price = stat_price + ceil(stat_spell * 10) + 16;
			if(stat_it == IT_BOOK)
			{
				stat_price = 10 + ceil(stat_spell * 5);
				stat_req_mag = stat_req_mag + ceil((2 ** GetSpellLevel(this, stat_spell)) * 3.2 + stat_spell * 2.8 + 5);
			}
			else if(stat_it == IT_SCROLL)
			{
				stat_req_mag = floor((stat_spell + 8) / 2 * 1.25);
				stat_price = ceil((5 + 1.5 * stat_spell) * stat_dur);
			}
		}
		else
			stat_suf = 0;

	}
	if(stat_req_str > 255)
		stat_req_str = 255;
	if(stat_req_dex > 255)
		stat_req_dex = 255;
	if(stat_req_mag > 255)
		stat_req_mag = 255;		
}
