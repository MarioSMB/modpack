
bool canuse(vector it)
{
	it_simplestat(it);
	it_itemstat();
	
	if((stat_dur) <= 0 && (stat_loc & (DURABILITY | STACKABLE)))
		return false;
	else if(stat_req_str && this.str < stat_req_str)
		return false;
	else if(stat_req_mag && this.mag < stat_req_mag)
		return false;
	else if(stat_req_dex && this.dex < stat_req_dex)
		return false;
	else if(stat_req_luck && this.luck < stat_req_luck)
		return false;
	else if(stat_req_agil && this.agil < stat_req_agil)
		return false;
	else if(stat_req_vit && this.vit < stat_req_vit)
		return false;
	else if(stat_req_lvl && this.lvl < stat_req_lvl)
		return false;
	else if(stat_req_class != '0 0 0' && this.title_y != stat_req_class_y)
		return false;
	else if(!stat_id)
		return false;
	if(!stat_loc & SPELL) // ugly hack
	{
		if(stat_spell)
		{
			if(stat_it == IT_BOOK)
				if((GetSpellLevel(this, stat_spell) + stat_spell_level) > 7)
					return false;
		}
	}
	if(stat_it == IT_ARROWS)
	{
		if((this.altaction & 63) == SP_FIGHT_BOW)
			return true;
		if((this.altaction & 63) == SP_FIGHT_CBOW)
			return true;
		return false;
	}
	return true;
}

bool UseItem(entity this, float sign)
{
	// itemstat must be done!
	// (normally canuse will do it)
	GenStat(-1);	
	if(stat_health)
		this.max_health = this.max_health + (stat_health * sign);
	if(stat_str)
		this.str = this.str + (stat_str * sign);
	if(stat_dex)
		this.dex = this.dex + (stat_dex * sign);
	if(stat_mag)
		this.mag = this.mag + (stat_mag * sign);
	if(stat_agil)
		this.agil = this.agil + (stat_agil * sign);
	if(stat_vit)
		this.vit = this.vit + (stat_vit * sign);
	if(stat_luck)
		this.luck = this.luck + (stat_luck * sign);
	if(stat_toall)
	{
		this.luck = this.luck + (stat_toall * sign);
		this.vit = this.vit + (stat_toall * sign);
		this.agil = this.agil + (stat_toall * sign);
		this.str = this.str + (stat_toall * sign);
		this.dex = this.dex + (stat_toall * sign);
		this.mag = this.mag + (stat_toall * sign);
	}
	if(stat_def)
		this.ac = this.ac + (stat_def * sign);
	if(stat_tohit)
		this.tohit = this.tohit + (stat_tohit * sign);
	if(stat_dodge)
		this.dodge = this.dodge + (stat_dodge * sign);
	if(stat_block)
		this.block = this.block + (stat_block * sign);

	if(stat_mana)
		this.max_mana = this.max_mana + (stat_mana * sign);
	if(stat_daml)
	{
		this.dama = this.dama + (stat_dama * sign);
		this.daml = this.daml + (stat_daml * sign);
	}
	if(stat_resist_all)
	{
		this.res_mag = this.res_mag + stat_resist_all * sign;
		this.res_fire = this.res_fire + stat_resist_all * sign;
		this.res_poison = this.res_poison + stat_resist_all * sign;
		this.res_cold = this.res_cold + stat_resist_all * sign;
	}
	if(stat_resist_magic)
		this.res_mag = this.res_mag + stat_resist_magic * sign;
	if(stat_resist_fire)
		this.res_fire = this.res_fire + stat_resist_fire * sign;
	if(stat_resist_poison)
		this.res_poison = this.res_poison + stat_resist_poison * sign;
	if(stat_resist_cold)
		this.res_cold = this.res_cold + stat_resist_cold * sign;
	if(stat_health_regen)
		this.health_regen = this.health_regen + stat_health_regen * sign;
	if(stat_mana_regen)
		this.mana_regen = this.mana_regen + stat_mana_regen * sign;
	if(stat_aspeed)
		this.aspeed = this.aspeed + stat_aspeed * sign;
	if(stat_critical)
		this.critical = this.critical + stat_critical * sign;
	if(stat_piercing)
		this.piercing = this.piercing + stat_piercing * sign;
	if(stat_visibility)
		this.visibility = this.visibility + stat_visibility  * sign;
	if(stat_attacker_dam)
		this.attacker_dam = this.attacker_dam + stat_attacker_dam * sign;
	if(stat_attacker_fire)
		this.attacker_fire = this.attacker_fire + stat_attacker_fire * sign;
	if(stat_attacker_lit)
		this.attacker_lit = this.attacker_lit + stat_attacker_lit * sign;
	if(stat_attacker_cold)
		this.attacker_cold = this.attacker_cold + stat_attacker_cold * sign;
	if(stat_attacker_poison)
		this.attacker_poison = this.attacker_poison + stat_attacker_poison * sign;
	if(stat_magic_reduced)
		this.magic_reduced = this.magic_reduced + stat_magic_reduced * sign;
	if(stat_damage_reduced)
		this.damage_reduced = this.damage_reduced + stat_damage_reduced * sign;
		
	if(stat_spec) // special effects
	{
		if(sign > 0)
			this.spec = this.spec | stat_spec;
		else
			this.spec = this.spec - (this.spec & stat_spec);
	}
	if(stat_skill) // special effects
	{
		if(sign > 0)
			this.skill = this.skill | stat_skill;
		else
			this.skill = this.skill - (this.skill & stat_skill);
	}
	if(stat_lit)
		this.lit = this.lit + stat_lit * sign;
	if(stat_fire)
		this.fire = this.fire + stat_fire * sign;
	if(stat_poison)
		this.poidam = this.poidam + stat_poison * sign;
	if(stat_cold)
		this.cold = this.cold + stat_cold * sign;
	if(stat_magic)
		this.magic = this.magic + stat_magic * sign;
	if(stat_misc)
	{
		int skn = stat_misc - (stat_misc & MISC_EFFECT_FLAGS);
		if(this.player)
		{
			if(sign > 0)
				this.player.misc = this.player.misc | skn;
			else
				this.player.misc = this.player.misc - (this.player.misc & skn);
			skn = (stat_misc & MISC_EFFECT_FLAGS);
			if(sign  < 0)
				this.player.effects = this.player.effects - (this.player.effects & skn);
			else
				this.player.effects = this.player.effects | skn;
		}
	}

	GenStat(1);
	if(stat_loc & BODY)
	{
		if(this.player)
		{
			if(sign == -1)
				this.player.oldskin = 0;
			else 
				this.player.oldskin = stat_action;
		}
	}
	else if(stat_it == IT_LESSER_HEAL)
	{
		// heal potion
		if(this.health >= this.max_health)
			return false;
		this.health = this.health + 15;
		boundstats(this);
	}
	else if(stat_it == IT_HEAL_POTION)
	{
		// heal potion
		if(this.health >= this.max_health)
			return false;
		this.health = this.health + 30;
		boundstats(this);
	}
	else if(stat_it == IT_GREATER_HEAL)
	{
		// heal potion
		if(this.health >= this.max_health)
			return false;
		this.health = this.health + 60;
		boundstats(this);
	}
	else if(stat_it == IT_LESSER_MANA)
	{
		// mana potion
		if(this.mana >= this.max_mana)
			return false;
		this.mana = this.mana + 10;
		boundstats(this);
	}
	else if(stat_it == IT_MANA_POTION)
	{
		// mana potion
		if(this.mana >= this.max_mana)
			return false;
		this.mana = this.mana + 25;
		boundstats(this);
	}
	else if(stat_it == IT_GREATER_MANA)
	{
		// mana potion
		if(this.mana >= this.max_mana)
			return false;
		this.mana = this.mana + 60;
		boundstats(this);
	}
	else if(stat_it == IT_GOLD_ELIXIR)
	{
		if(this.ptd <= 122)
			this.ptd = this.ptd + 5;
		else
			this.ptd = 127;
	}
	else if(stat_it == IT_CURE)
	{
		// mana potion
		this.health = this.health + 1;
		this.mana = this.mana + 1;
		this.player.misc = this.player.misc - (this.player.misc & MISC_BAD_EFFECTS);
		
		if(this.player)
		{
			this.player.poison_count = 0;
			this.player.poison_factor = 0;
			this.player.daze_time = 0;
			this.player.cold_time = 0;
			this.player.cold_factor = 1;
		}
		boundstats(this);
	}
	else if(stat_it == IT_ALE)
	{
		if(this.player)
			this.player.daze_time = time + 30;
	}
	else if(stat_loc & RIGHTARM)
	{
		if(sign == -1)
		{
			this.rightarm = IV_NULL;
			this.altaction = SP_FIGHT_MELEE;
		}
		else
		{
			this.rightarm = it_setstat();
			this.altaction = stat_action | SP_ITEM_CAST  | (stat_spell_level * 256); // fixme?
		}
		
	}
	else if(stat_loc & LEFTARM)
	{
		if(stat_it != IT_ARROWS)
		{
			if(sign == -1)
				this.leftarm = IV_NULL;
			else
				this.leftarm = it_setstat();
		}
	}
	else if(stat_action)
	{
		if(cast_aground(stat_action))
		{
			if(this.player)
			{
				spell_fire(this.player, (stat_action | SP_ITEM_CAST) | (stat_spell_level * 256));
			}
		}
	}
	if(stat_target)
	{
		Trigger(stat_target, this, this, 0);
	}
	if(stat_loc & AMMO)
	{
		if(sign == -1)
			this.armorvalue = 0;
		else
			this.armorvalue = stat_dur;
	}
	if(stat_loc & SPELL)
	{
		// scrolls
		if(sign == -1)
			this.spell = 0;
			
		else
		{
			if(stat_it == IT_SCROLL)
				stat_spell = stat_spell | SP_SCROLL_OF;
			this.spell = stat_spell | SP_ITEM_CAST | (stat_spell_level * 256);
		}
		return true;
	}
	if(stat_spell)
		AddSpellLevel(this, stat_spell, sign * stat_spell_level);

	return true;
}

bool Use(entity this, int slot)
{
	vector itslot = GetSlot(this, slot);
	
	if(canuse(itslot))
	{
		if(stat_loc & USE_ON_ITEM)
		{
			this.weapon = pow2(slot);
			openmenu(this, m_useon, this);
		}
		else if(stat_loc & USABLE)
		{
			if(UseItem(this, 1))
			{
				sound(this, CHAN_AUTO, itemsound(stat_it), 1, ATTN_NORM);	
				if(!(stat_loc & INFINITE))
				{
					if(stat_loc & STACKABLE)
					{
	
						stat_dur = stat_dur - 1;
						if(stat_dur > 0)
							itslot = it_setstat();
						else
							itslot = IV_NULL;
		
						SetSlot(this, slot, itslot);
	
					}
					else
						ClearSlot(this, slot);
				}
				boundstats(this);
			}
			return true;
		}
	}
	return false;
}
