#include "encode.qh"

#include "../subs/parms.qh"

vector it_setstat()
{
	vector v;
	v.x = stat_it;
	v.y = encode(stat_pref, stat_suf, stat_id);
	v.z = stat_dur;
	return v;	
}

void it_simplestat(entity this, vector itslot)
{
	it_clearstats();
	stat_it = itslot.x;
	stat_pref = decode(itslot.y, 1);
	stat_suf = decode(itslot.y, 2);
	stat_id = decode(itslot.y, 3);
	stat_size = it_itemsize(stat_it);
	if(!stat_it)
		stat_id = 1;
	stat_dur = itslot.z;
}

void it_clearstats()
{
	stat_price = stat_loc = stat_piercing = 0;
	stat_max_dur = 255;
	stat_misc = stat_skill = stat_action = 0;
	stat_req_str = stat_req_mag = stat_req_dex = stat_req_lvl = stat_req_agil = stat_req_luck = 0;
	stat_str = stat_mag = stat_dex = stat_vit = stat_luck = stat_agil = 0;
	stat_daml = stat_dama = stat_tohit = stat_dodge = stat_mana =
	stat_health = stat_def = stat_spec = stat_toall = 0;
	stat_spell = stat_fire = stat_lit = stat_poison = stat_cold = stat_magic = 0;
	stat_resist_fire = stat_resist_lit = stat_resist_poison = stat_resist_magic = stat_resist_cold = stat_resist_all = 0;
	stat_block = stat_mana_regen = stat_aspeed = stat_critical = stat_visibility = 0;
	stat_spell_level = stat_magic_quality = 1;
	stat_health_regen = stat_attacker_dam = stat_attacker_fire = stat_attacker_lit = stat_attacker_cold = stat_attacker_poison = stat_magic_reduced = stat_damage_reduced =  0;
	stat_target = NULL;
}

//  496 in parms

vector decodeitem()
{
	stat_id = parm_load(2);
	stat_it = parm_load(64);
	stat_pref = parm_load(128);
	stat_suf = parm_load(128);
	stat_dur = parm_load(256);

	if(stat_it == 0)
	{
		if(stat_pref)
		{
			stat_it = stat_pref + 63;
			stat_pref = 0;
		}
		else if(stat_suf)
		{
			stat_it = stat_suf + 191;
			stat_pref = stat_suf = 0;
		}		
	}

	if(stat_it == IT_OIL2)
	{
		stat_pref = stat_suf;
		stat_suf = 0;
	}
	return it_setstat();
}

void encodeitem(entity this, vector itslot)
{
	it_simplestat(this, itslot);
	parm_save(stat_id != 0, 2);
	if(stat_it > 63)
	{
		parm_save(0, 64); // item value
		
		if(stat_it > 191)
		{
			parm_save(0, 128);
			parm_save(stat_it - 191, 128);
		}
		else if(stat_it == IT_OIL2)
		{
			parm_save(IT_OIL2 - 63, 128);
			parm_save(stat_pref, 128);
		}
		else
		{
			parm_save(stat_it - 63, 128);
			parm_save(stat_suf, 128);
		}
	}
	else
	{
		parm_save(stat_it, 64); // item value
		parm_save(stat_pref, 128); // prefix
		parm_save(stat_suf, 128); // suffix
	}
	parm_save(stat_dur, 256); // durability
}
