string unique_itemmodel(float it)
{
	if(it == IT_ITHAELS_ROBE)
		return "progs/leath.mdl";
	else if(it == IT_STONEFLESH)
		return "progs/leath.mdl";
	else if(it == IT_ICEBINK)
		return "progs/leath.mdl";
	else if(it == IT_GRUESKIN)
		return "progs/leath.mdl";
	else if(it == IT_THE_GUARDIAN)
		return "progs/mail.mdl";
	else if(it == IT_BLACKMAIL)
		return "progs/mail.mdl";
	else if(it == IT_HELLPLATE)
		return "progs/mail.mdl";
	else if(it == IT_SOULSHEATH)
		return "progs/mail.mdl";
	else if(it == IT_WIZARDSPIKE)
		return "progs/knife.mdl";
	else if(it == IT_FINGERBONE)
		return "progs/knife.mdl";
	else if(it == IT_THROATSLITTER)
		return "progs/dagger.mdl";
	else if(it == IT_BITTER_SPIKE)
		return "progs/dagger.mdl";
	else if(it == IT_BRANWENS_BANE)
		return "progs/sabre.mdl";
	else if(it == IT_BONESCRAPE)
		return "progs/sabre.mdl";
	else if(it == IT_THE_SKEWER_OF_ANTHEG)
		return "progs/rapier.mdl";
	else if(it == IT_RIPSAW)
		return "progs/rapier.mdl";
	else if(it == IT_DOOMBRINGER)
		return "progs/brdsword.mdl";
	else if(it == IT_DRAGON_HEWER)
		return "progs/brdsword.mdl";
	else if(it == IT_NIGHTCLUB)
		return "progs/club.mdl";
	else if(it == IT_POINTY_STICK)
		return "progs/club.mdl";
	else if(it == IT_CRUSHER)
		return "progs/mace.mdl";
	else if(it == IT_BASHER)
		return "progs/mace.mdl";
	else if(it == IT_THE_GNARLED_BRANCH)
		return "progs/staff.mdl";
	else if(it == IT_KNOTTED_SPIRE)
		return "progs/staff.mdl";
	else if(it == IT_THE_FIREPOKER)
		return "progs/scepter.mdl";
	else if(it == IT_THUNDERCLAP)
		return "progs/scepter.mdl";
	else if(it == IT_THE_MANGLER)
		return "progs/hatchet.mdl";
	else if(it == IT_CADFAELS_CLEAVER)
		return "progs/hatchet.mdl";
	else if(it == IT_SKULLSPLITTER)
		return "progs/axe.mdl";
	else if(it == IT_BLADED_TERROR)
		return "progs/axe.mdl";
	else if(it == IT_DEATHS_EMISSARY)
		return "progs/waraxe.mdl";
	else if(it == IT_COLDCUTTER)
		return "progs/waraxe.mdl";
	else if(it == IT_FLESHSTINGER)
		return "progs/shortbow.mdl";
	else if(it == IT_ELVEN_BOW)
		return "progs/shortbow.mdl";
	else if(it == IT_ASSASIN_BOW)
		return "progs/longbow.mdl";
	else if(it == IT_WITCHSTRING)
		return "progs/longbow.mdl";
	else if(it == IT_WRAITHWEAVER)
		return "progs/warbow.mdl";
	else if(it == IT_BLIGHT_BOW)
		return "progs/warbow.mdl";
	else if(it == IT_DRAGON_TEETH)
		return "progs/thrwknfe.mdl";
	else if(it == IT_RAJAS_SILVER)
		return "progs/thrwknfe.mdl";
	else if(it == IT_THE_WARD)
		return "progs/buckler.mdl";
	else if(it == IT_DEMON_GUARD)
		return "progs/buckler.mdl";
	else if(it == IT_DYLANS_DEFENDER)
		return "progs/ashield.mdl";
	else if(it == IT_STORMSHIELD)
		return "progs/ashield.mdl";
	else if(it == IT_AGELESS_AEGIS_OF_THE_AGES)
		return "progs/aegis.mdl";
	else if(it == IT_SPIKEWALL)
		return "progs/aegis.mdl";
	else if(it == IT_PRETTY_HAT)
		return "progs/helm.mdl";
	else if(it == IT_HEADBUCKET)
		return "progs/helm.mdl";
	else if(it == IT_STEELSKULL)
		return "progs/helm.mdl";
	else if(it == IT_HASCERON)
		return "progs/helm.mdl";
	else if(it == IT_DEMONHEAD)
		return "progs/helm.mdl";
	else if(it == IT_BANEDINS_CROWN)
		return "progs/helm.mdl";
	else if(it == IT_FOOTGARDE)
		return "progs/boots.mdl";
	else if(it == IT_GORERIDER)
		return "progs/boots.mdl";
	else if(it == IT_IRONHEEL)
		return "progs/greaves.mdl";
	else if(it == IT_BYRONS_BANE)
		return "progs/greaves.mdl";
	else if(it == IT_PANDORA_PENDANT)
		return "progs/amulet.mdl";
	else if(it == IT_MINDS_EYE)
		return "progs/amulet.mdl";
	else if(it == IT_DREADSPIKE_ARROWS)
		return "progs/quiver.mdl";
	else if(it == IT_SURESHOT_ARROWS)
		return "progs/quiver.mdl";
	else if(it == IT_IMPALER_SPEARS)
		return "progs/spear.mdl";
	else if(it == IT_WARSTRIKE_SPEARS)
		return "progs/spear.mdl";
	else if(it == IT_NAMUS_RELIC)
		return "progs/amulet.mdl";
	else if(it == IT_ARIANNAS_BLESSING)
		return "progs/amulet.mdl";
	else
	{
		entity q = get_questitem(it);
		if(q)
			return q.model;
		else
			return "progs/scroll.mdl";
	}
}

string unique_itemsound(float it)
{
	if(it == IT_ITHAELS_ROBE)
		return "items/cloth.wav";
	else if(it == IT_STONEFLESH)
		return "items/cloth.wav";
	else if(it == IT_ICEBINK)
		return "items/cloth.wav";
	else if(it == IT_GRUESKIN)
		return "items/cloth.wav";
	else if(it == IT_THE_GUARDIAN)
		return "items/armor1.wav";
	else if(it == IT_BLACKMAIL)
		return "items/armor1.wav";
	else if(it == IT_HELLPLATE)
		return "items/armor1.wav";
	else if(it == IT_SOULSHEATH)
		return "items/armor1.wav";
	else if(it == IT_WIZARDSPIKE)
		return "items/sword.wav";
	else if(it == IT_FINGERBONE)
		return "items/sword.wav";
	else if(it == IT_THROATSLITTER)
		return "items/sword.wav";
	else if(it == IT_BITTER_SPIKE)
		return "items/sword.wav";
	else if(it == IT_BRANWENS_BANE)
		return "items/sword.wav";
	else if(it == IT_BONESCRAPE)
		return "items/sword.wav";
	else if(it == IT_THE_SKEWER_OF_ANTHEG)
		return "items/sword.wav";
	else if(it == IT_RIPSAW)
		return "items/sword.wav";
	else if(it == IT_DOOMBRINGER)
		return "items/sword.wav";
	else if(it == IT_DRAGON_HEWER)
		return "items/sword.wav";
	else if(it == IT_NIGHTCLUB)
		return "items/club.wav";
	else if(it == IT_POINTY_STICK)
		return "items/club.wav";
	else if(it == IT_CRUSHER)
		return "items/club.wav";
	else if(it == IT_BASHER)
		return "items/club.wav";
	else if(it == IT_THE_GNARLED_BRANCH)
		return "items/club.wav";
	else if(it == IT_KNOTTED_SPIRE)
		return "items/club.wav";
	else if(it == IT_THE_FIREPOKER)
		return "items/club.wav";
	else if(it == IT_THUNDERCLAP)
		return "items/club.wav";
	else if(it == IT_THE_MANGLER)
		return "player/axhit2.wav";
	else if(it == IT_CADFAELS_CLEAVER)
		return "player/axhit2.wav";
	else if(it == IT_SKULLSPLITTER)
		return "player/axhit2.wav";
	else if(it == IT_BLADED_TERROR)
		return "player/axhit2.wav";
	else if(it == IT_DEATHS_EMISSARY)
		return "player/axhit2.wav";
	else if(it == IT_COLDCUTTER)
		return "player/axhit2.wav";
	else if(it == IT_FLESHSTINGER)
		return "items/bow.wav";
	else if(it == IT_ELVEN_BOW)
		return "items/bow.wav";
	else if(it == IT_ASSASIN_BOW)
		return "items/bow.wav";
	else if(it == IT_WITCHSTRING)
		return "items/bow.wav";
	else if(it == IT_WRAITHWEAVER)
		return "items/bow.wav";
	else if(it == IT_BLIGHT_BOW)
		return "items/bow.wav";
	else if(it == IT_DRAGON_TEETH)
		return "items/sword.wav";
	else if(it == IT_RAJAS_SILVER)
		return "items/sword.wav";
	else if(it == IT_THE_WARD)
		return "items/shield.wav";
	else if(it == IT_DEMON_GUARD)
		return "items/shield.wav";
	else if(it == IT_DYLANS_DEFENDER)
		return "items/shield.wav";
	else if(it == IT_STORMSHIELD)
		return "items/shield.wav";
	else if(it == IT_AGELESS_AEGIS_OF_THE_AGES)
		return "items/shield.wav";
	else if(it == IT_SPIKEWALL)
		return "items/shield.wav";
	else if(it == IT_PRETTY_HAT)
		return "items/helm.wav";
	else if(it == IT_HEADBUCKET)
		return "items/helm.wav";
	else if(it == IT_STEELSKULL)
		return "items/helm.wav";
	else if(it == IT_HASCERON)
		return "items/helm.wav";
	else if(it == IT_DEMONHEAD)
		return "items/helm.wav";
	else if(it == IT_BANEDINS_CROWN)
		return "items/helm.wav";
	else if(it == IT_FOOTGARDE)
		return "items/booties.wav";
	else if(it == IT_GORERIDER)
		return "items/booties.wav";
	else if(it == IT_IRONHEEL)
		return "items/helm.wav";
	else if(it == IT_BYRONS_BANE)
		return "items/helm.wav";
	else if(it == IT_PANDORA_PENDANT)
		return "items/amulet.wav";
	else if(it == IT_MINDS_EYE)
		return "items/amulet.wav";
	else if(it == IT_DREADSPIKE_ARROWS)
		return "items/arrows.wav";
	else if(it == IT_SURESHOT_ARROWS)
		return "items/arrows.wav";
	else if(it == IT_IMPALER_SPEARS)
		return "items/arrows.wav";
	else if(it == IT_WARSTRIKE_SPEARS)
		return "items/arrows.wav";
	else if(it == IT_NAMUS_RELIC)
		return "items/amulet.wav";
	else if(it == IT_ARIANNAS_BLESSING)
		return "items/amulet.wav";
	else
	{
		entity q = get_questitem(it);
		if(q)
			return q.noise;
		else
			return "items/scroll.wav";
	}
}


void uniquestat()
{
	if(stat_it == IT_ITHAELS_ROBE)
	{
		stat_loc = BODY | DURABILITY | EQUIPABLE;
		stat_price = 0;
		stat_def = 3;
		stat_max_dur = 6;
		stat_action = 3; // skin hack
	}
	else if(stat_it == IT_STONEFLESH)
	{
		stat_loc = BODY | DURABILITY | EQUIPABLE;
		stat_price = 800 + floor(stat_dur * 2.5);
		stat_def = 15;
		stat_req_lvl = 7;
		stat_max_dur = 200;
		stat_action = 1; // skin hack
		stat_resist_all = 10;
	}
	else if(stat_it == IT_ICEBINK)
	{
		// aketon
		stat_loc = BODY | DURABILITY | EQUIPABLE;
		stat_price = 2500 + floor(stat_dur * 3);
		stat_max_dur = 40;
		stat_def = 22;
		stat_req_lvl = 20;
		stat_req_str = 20;
		stat_action = 1; // skin hack
		stat_resist_cold = 85;
		stat_cold = 40;
	}
	else if(stat_it == IT_GRUESKIN)
	{
		// aketon
		stat_loc = BODY | DURABILITY | EQUIPABLE;
		stat_price = 2800 + floor(stat_dur * 3);
		stat_max_dur = 45;
		stat_def = 35;
		stat_req_str = 18;
		stat_req_lvl = 10;
		stat_action = 1; // skin hack
		stat_visibility = -50;
		stat_misc = EF_NODRAW;
	}
	else if(stat_it == IT_THE_GUARDIAN)
	{
		// chain mail
		stat_loc = BODY | EQUIPABLE;
		stat_price = 3600;
		stat_def = 60;
		stat_req_str = 40;
		stat_dodge = 25;
		stat_req_lvl = 20;
		stat_spec = SPEC_INDESTRUCTIBLE;
		stat_action = 2; // skin hack
	}
	else if(stat_it == IT_BLACKMAIL)
	{
		// chain mail
		stat_loc = BODY | DURABILITY | EQUIPABLE;
		stat_price = 4000 + floor(stat_dur * 7.5);
		stat_max_dur = 100;
		stat_def = 30;
		stat_req_lvl = 20;
		stat_visibility = -20;
		stat_spell = SP_EVILE;
		stat_action = 2; // skin hack
	}
	else if(stat_it == IT_HELLPLATE)
	{
		// breastplate
		stat_loc = BODY | DURABILITY | EQUIPABLE;
		stat_price = 3000 + stat_dur * 5;
		stat_max_dur = 125;
		stat_fire = 15;
		stat_resist_fire = 30;
		stat_def = 40;
		stat_misc = EF_RED;
		stat_req_str = 50;
		stat_action = 2; // skin hack
	}
	else if(stat_it == IT_SOULSHEATH)
	{
		// breastplate
		stat_loc = BODY | DURABILITY | EQUIPABLE;
		stat_price = 1800 + stat_dur * 20;
		stat_max_dur = 150;
		stat_resist_magic = 40;
		stat_def = 50;
		stat_attacker_dam = stat_attacker_dam + 50;
		stat_req_str = 35;
		stat_spell = SP_SHIELD;
		stat_action = 2; // skin hack
	}
	else if(stat_it == IT_WIZARDSPIKE)
	{
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 30;
		stat_daml = 10;
		stat_dama = 3;
		stat_price = 1000 + floor(stat_dur * 2);
		stat_mag = 12;
		stat_skill = SKILL_SPELLS;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_FINGERBONE)
	{
		stat_loc = RIGHTARM  | EQUIPABLE;
		stat_daml = 10;
		stat_dama = 5;
		stat_price = 1800 + floor(stat_dur * 2);
		stat_action = SP_FIGHT_MELEE;
		stat_spec = SPEC_STEAL_LIFE | SPEC_INDESTRUCTIBLE;
	}
	else if(stat_it == IT_THROATSLITTER)
	{
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 40;
		stat_daml = 20;
		stat_dama = 6;
		stat_price = 950 + floor(stat_dur * 3);
		stat_req_dex = 10;
		stat_action = SP_FIGHT_MELEE;
		stat_critical = 67;
		stat_tohit = 40;
	}
	else if(stat_it == IT_BITTER_SPIKE)
	{
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 30;
		stat_daml = 18;
		stat_dama = 6;
		stat_poison = 50;
		stat_price = 1730 + floor(stat_dur * 3);
		stat_req_dex = 10;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_BRANWENS_BANE)
	{
		// sabre
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 12;
		stat_daml = 1;
		stat_dama = 1;
		stat_price = 3776 + floor(stat_dur * 2);
		stat_req_dex = 10;
		stat_req_lvl = 20;
		stat_cold = 14;
		stat_lit = 14;
		stat_poison = 14;
		stat_fire = 14;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_BONESCRAPE)
	{
		// sabre
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 12;
		stat_daml = 20;
		stat_dama = 20;
		stat_price = 2600 + floor(stat_dur * 2);
		stat_req_dex = 5;
		stat_action = SP_BRAWL;
	}
	else if(stat_it == IT_THE_SKEWER_OF_ANTHEG)
	{
		// rapier
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 20;
		stat_daml = 15;
		stat_dama = 10;
		stat_price = 660 + floor(stat_dur * 2.5);
		stat_aspeed = stat_aspeed + 15;
		stat_req_dex = 12;
		stat_req_str = 14;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_RIPSAW)
	{
		// rapier
		stat_spec = SPEC_MORTAL_WOUND;
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 20;
		stat_daml = 15;
		stat_dama = 7;
		stat_price = 3300 + floor(stat_dur * 2.7);
		stat_req_dex = 12;
		stat_req_str = 14;
		stat_action = SP_FIGHT_MELEE;
		stat_critical = 50;
	}
	else if(stat_it == IT_DOOMBRINGER)
	{
		// broadsword
		stat_spec = SPEC_MORTAL_WOUND;
		stat_skill = SKILL_SPRINT;
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 40;
		stat_daml = 30;
		stat_dama = 14;
		stat_price = 1970 + floor(stat_dur * 6);
		stat_req_dex = 30;
		stat_req_str = 48;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_DRAGON_HEWER)
	{
		// broadsword
		stat_spec = SPEC_TWO_HITS;
		stat_skill = SKILL_EXPERIENCE;
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 40;
		stat_daml = 30;
		stat_dama = 15;
		stat_price = 2670 + floor(stat_dur * 6);
		stat_req_dex = 35;
		stat_req_str = 48;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_NIGHTCLUB)
	{
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 10;
		stat_daml = 6;
		stat_dama = 4;
		stat_price = 800 + floor(stat_dur * 2);
		stat_action = SP_FIGHT_MELEE;
		stat_spec = SPEC_DAZE;
		stat_misc = EF_NODRAW;
	}
	else if(stat_it == IT_POINTY_STICK)
	{
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 8;
		stat_daml = 4;
		stat_dama = 3;
		stat_critical = 90;
		stat_price = 400 + floor(stat_dur * 2);
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_CRUSHER)
	{
		stat_spec = SPEC_MORTAL_WOUND;
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 50;
		stat_daml = 50;
		stat_dama = 20;
		stat_price = 1996 + floor(stat_dur * 3);
		stat_req_str = 60;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_BASHER)
	{
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 50;
		stat_daml = 30;
		stat_dama = 18;
		stat_price = 1985 + floor(stat_dur * 3);
		stat_req_str = 60;
		stat_action = SP_FIGHT_MELEE;
		stat_skill = SKILL_FRENZY;
	}
	else if(stat_it == IT_THE_GNARLED_BRANCH)
	{
		// staff
		stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
		stat_max_dur = 13;
		stat_daml = 9;
		stat_dama = 5;
		stat_price = 5449 + floor(stat_dur * 5);
		stat_req_mag = 5;
		stat_action = SP_FIGHT_MELEE;
		stat_skill = SKILL_SPELLS;
		stat_mana_regen = 25;
		stat_mana = 30;
	}
	else if(stat_it == IT_KNOTTED_SPIRE)
	{
		stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
		stat_max_dur = 13;
		stat_daml = 22;
		stat_dama = 10;
		stat_price = 6000 + floor(stat_dur * 5);
		stat_req_mag = 10;
		stat_action = SP_FIGHT_MELEE;
		stat_skill = SKILL_SPELLS;
		stat_mana_regen = 30;
		stat_mana = 50;
	}
	else if(stat_it == IT_THE_FIREPOKER)
	{
		stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
		stat_max_dur = 100;
		stat_daml = 1;
		stat_dama = 1;
		stat_fire = 40;
		stat_resist_fire = 50;
		stat_aspeed = 50;
		stat_price = 3500 + floor(stat_dur * 5);
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_THUNDERCLAP)
	{
		// scepter
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 30;
		stat_daml = 22;
		stat_dama = 7;
		stat_lit = 55;
		stat_aspeed = 25;
		stat_price = 3300 + floor(stat_dur * 5);
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_THE_MANGLER)
	{
		// hatchet
		stat_spec = SPEC_MORTAL_WOUND | SPEC_TWO_HITS;
		stat_loc = RIGHTARM | DURABILITY | EQUIPABLE;
		stat_max_dur = 13;
		stat_daml = 10;
		stat_dama = 5;
		stat_price = 2560 + floor(stat_dur * 1);
		stat_req_str = 15;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_CADFAELS_CLEAVER)
	{
		// hatchet
		stat_spec = SPEC_INDESTRUCTIBLE;
		stat_critical = 40;
		stat_loc = RIGHTARM | EQUIPABLE;
		stat_daml = 10;
		stat_dama = 5;
		stat_price = 1900;
		stat_req_str = 15;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_SKULLSPLITTER)
	{
		// axe
		stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
		stat_max_dur = 60;
		stat_daml = 20;
		stat_dama = 20;
		stat_spec = SPEC_MORTAL_WOUND;
		stat_price = 2400 + floor(stat_dur * 1.5);
		stat_req_str = 30;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_BLADED_TERROR)
	{
		// axe
		stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
		stat_max_dur = 50;
		stat_daml = 10;
		stat_dama = 30;
		stat_spec = SPEC_TWO_HITS | SPEC_DAZE;
		stat_price = 2400 + floor(stat_dur * 1.5);
		stat_req_str = 30;
		stat_action = SP_FRENZY;
	}
	else if(stat_it == IT_DEATHS_EMISSARY)
	{
		// war axe
		stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
		stat_max_dur = 50;
		stat_daml = 22;
		stat_dama = 10;
		stat_price = 2800 + floor(stat_dur * 0.5);
		stat_req_dex = 20;
		stat_req_str = 60;
		stat_spec = SPEC_MORTAL_WOUND;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_COLDCUTTER)
	{
		// war axe
		stat_loc = TWO_HAND | DURABILITY | EQUIPABLE;
		stat_max_dur = 47;
		stat_daml = 1;
		stat_dama = 30;
		stat_cold = 55;
		stat_price = 2500 + floor(stat_dur * 0.5);
		stat_req_dex = 5;
		stat_req_str = 40;
		stat_action = SP_FIGHT_MELEE;
	}
	else if(stat_it == IT_FLESHSTINGER)
	{
		// short bow
		stat_tohit = -4;
		stat_loc = RIGHTARM | EQUIPABLE;
		stat_daml = 6;
		stat_dama = 9;
		stat_price = 760;
		stat_req_dex = 5;
		stat_action = SP_FIGHT_BOW;
		stat_spec = SPEC_TWO_HITS;
	}
	else if(stat_it == IT_ELVEN_BOW)
	{
		// short bow
		stat_tohit = -2;
		stat_loc = RIGHTARM | EQUIPABLE;
		stat_daml = 5;
		stat_dama = 18;
		stat_price = 760;
		stat_req_dex = 5;
		stat_action = SP_FIGHT_BOW;
		stat_skill = SKILL_RELOAD;
	}
	else if(stat_it == IT_ASSASIN_BOW)
	{
		// long bow
		stat_tohit = 2;
		stat_loc = RIGHTARM | EQUIPABLE;
		stat_daml = 7;
		stat_dama = 7;
		stat_critical = 70;
		stat_price = 1400;
		stat_req_dex = 35;
		stat_action = SP_FIGHT_BOW;
		stat_visibility = -10;
	}
	else if(stat_it == IT_WITCHSTRING)
	{
		// long bow
		stat_tohit = -4;
		stat_loc = RIGHTARM | EQUIPABLE;
		stat_daml = 7;
		stat_dama = 5;
		stat_price = 1600;
		stat_req_dex = 20;
		stat_req_mag = 10;
		stat_mana_regen = 15;
		stat_action = SP_FIGHT_BOW;
	}
	else if(stat_it == IT_WRAITHWEAVER)
	{
	
	}
	else
	{
		entity q = get_questitem(stat_it);
		if(!q)
		{
			stat_id = 2;
			return;
		}
		// nasty
		stat_max_dur = q.max_health;

		stat_loc = q.ai;
		stat_str = q.str;
		stat_dex = q.dex;
		stat_mag = q.mag;
		stat_vit = q.vit;
		stat_luck = q.luck;
		stat_agil = q.agil;
		stat_toall = q.ptd;
		stat_daml = q.daml;
		stat_dama = q.dama;
		stat_tohit = q.tohit;
		stat_mana = q.currentammo;
		stat_health = q.health;
		stat_def = q.ac;
		stat_spell = q.spell;
		stat_action = q.gotstuff;
		stat_fire = q.fire;
		stat_magic = q.magic;
		stat_poison = q.poidam;
		stat_lit = q.lit;
		stat_spec = q.spec;
		stat_skill = q.skill;
		stat_misc = q.misc;
		stat_resist_fire = q.res_fire;
		stat_resist_lit = q.res_lit;
		stat_resist_poison = q.res_poison;
		stat_resist_magic = q.res_mag;
		stat_resist_cold = q.res_cold;
		stat_block = q.block;
		stat_mana_regen = q.mana_regen;
		stat_critical = q.critical;
		stat_aspeed = q.aspeed;
		stat_health_regen = q.health_regen;
		stat_attacker_dam = q.attacker_dam;
		stat_attacker_fire = q.attacker_fire;
		stat_attacker_lit = q.attacker_lit;
		stat_attacker_cold = q.attacker_cold;
		stat_attacker_poison = q.attacker_poison;
		stat_piercing = q.piercing;
		stat_visibility = q.visibility;
		if(q.req_lvl)
			stat_req_lvl = q.req_lvl;
		else
			stat_req_lvl = q.frags;
		stat_req_str = q.req_str;
		stat_req_dex = q.req_dex;
		stat_req_mag = q.req_mag;
		stat_req_vit = q.req_vit;
		stat_req_luck = q.req_luck;
		stat_req_agil = q.req_agil;
		stat_req_class = q.req_class;
		
		stat_damage_reduced = q.damage_reduced;
		stat_magic_reduced = q.magic_reduced;
		
		stat_price = q.menu;
		if(q.target)
			stat_target = q;
	}
}
