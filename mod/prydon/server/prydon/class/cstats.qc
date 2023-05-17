#include "cstats.qh"

void TitleStat(vector cl)
{
	float lv = cl.x + 1;
	
	it_clearstats();
	stat_id = 1;
	stat_it = stat_pref = stat_suf = 0;
	
	if(cl.y == CL_ADVENTURER)
	{
		stat_skill =  SKILL_EXPERIENCE;
	}
	else if(cl.y == CL_FIGHTER)
	{
		stat_skill = SKILL_MELEE;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL;
		stat_critical = cl.x * 3;
	}
	else if(cl.y == CL_BRAWLER)
	{
		stat_skill = SKILL_MELEE | SKILL_BRAWL;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FRENZY;
		stat_critical = cl.x * 4;
	}
	else if(cl.y == CL_BRUTE)
	{
		stat_skill = SKILL_MELEE | SKILL_BRAWL;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FRENZY;
		stat_spec = SPEC_KNOCKBACK;
		stat_critical = cl.x * 5;
	}
	else if(cl.y == CL_SLAYER)
	{
		stat_critical = 8 * lv;
		if(cl.x)
			stat_skill = SKILL_FLAME_ARROW | SKILL_THROW;
	}
	else if(cl.y == CL_WARRIOR)
	{
		stat_skill = SKILL_MELEE;
		stat_critical = 5 * lv;
		if(cl.x)
			stat_skill = SKILL_FLAME_ARROW | SKILL_BRAWL;
	}
	else if(cl.y == CL_KNIGHT)
	{
		stat_critical = 5 * lv;
		stat_skill = SKILL_MELEE | SKILL_BRAWL;
	}
	else if(cl.y == CL_HUNTSMAN)
	{
		stat_skill = SKILL_BOW;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW;
		stat_tohit = 5 * lv;
		stat_resist_poison = 20 * cl.x;
	}
	else if(cl.y == CL_ARCHER)
	{
		stat_skill = SKILL_BOW | SKILL_FLAME_ARROW;
		stat_tohit = 8 * lv;
		stat_critical = cl.x * 6;
	}
	else if(cl.y == CL_RANGER)
	{
		stat_skill = SKILL_BOW;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW;
		stat_tohit = 6 * lv;
		stat_resist_poison = 16 * lv;
	}
	else if(cl.y == CL_SPRINTER)
	{
		stat_skill = SKILL_SPRINT;
		stat_aspeed = 4 * cl.x;
	}
	else if(cl.y == CL_COURIER)
	{
		stat_skill = SKILL_SPRINT | SKILL_MELEE;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL;
		stat_critical = cl.x * 5;
	}
	else if(cl.y == CL_STALKER)
	{
		stat_skill = SKILL_SPRINT | SKILL_BRAWL;
		if(cl.x)
			stat_skill = stat_skill | SKILL_MELEE;
		stat_critical = cl.x * 5;
	}
	else if(cl.y == CL_ROBBER)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_SPRINT;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_THROW;
	}
	else if(cl.y == CL_ATHLETE)
	{
		stat_skill = SKILL_SPRINT;
		stat_dodge = 3 * lv;
		stat_tohit = 3 * lv;
		stat_aspeed = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_JUMP;
	}
	else if(cl.y == CL_ASSASSIN)
	{
		stat_critical = 10 * lv;
		stat_skill = SKILL_THROW;
		stat_tohit = 5 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW;
	}
	else if(cl.y == CL_LOOKOUT)
	{
		stat_skill = SKILL_SPRINT;
		stat_dodge = 5 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_JUMP;
	}
	else if(cl.y == CL_MOUNTAINEER)
	{
		stat_skill = SKILL_MELEE | SKILL_SPRINT;
		stat_resist_poison = 10 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL;
	}
	else if(cl.y == CL_WATCHMAN)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_SPRINT;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW;
		stat_dodge = 6 * lv;
	}
	else if(cl.y == CL_SCOUT)
	{
		stat_skill = SKILL_SPRINT;
		stat_aspeed = 3 * lv;
		stat_dodge = 6 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_JUMP;
	}
	else if(cl.y == CL_NEOPHYTE)
	{
		stat_mana_regen = 4 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY;
		if(cl.x > 1)
			stat_skill = stat_skill | SKILL_SPELLS;
	}
	else if(cl.y == CL_MONK)
	{
		stat_mana_regen = 3 * lv;
		stat_skill = SKILL_MELEE;
		if(cl.x)
			stat_skill = SKILL_IDENTIFY | SKILL_BRAWL;

	}
	else if(cl.y == CL_PALADIN)
	{
		stat_skill = SKILL_MELEE | SKILL_BRAWL;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_MAGESLAYER)
	{
		stat_mana_regen = 3 * lv;
		stat_critical = 5 * lv;
		if(cl.x)
			stat_skill = SKILL_FLAME_ARROW | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_AVENGER)
	{
		if(cl.x)
			stat_skill = SKILL_FLAME_ARROW | SKILL_IDENTIFY | SKILL_BRAWL;
		else
			stat_skill = SKILL_MELEE;
		stat_mana_regen = 3 * lv;
		stat_critical = 5 * lv;

	}
	else if(cl.y == CL_FLETCHER)
	{
		stat_skill = SKILL_RELOAD | SKILL_BOW;
		stat_mana_regen = 3 * lv;
		stat_tohit = 5 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_SWASHBUCKLER)
	{
		stat_skill = SKILL_SPRINT;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_HARBINGER)
	{
		stat_skill = SKILL_SPRINT | SKILL_MELEE;
		stat_mana_regen = 2 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_EXPLORER)
	{
		stat_skill = SKILL_SPRINT | SKILL_MELEE;
		stat_critical = 5 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_DESPERADO)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_SPRINT;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY;

	}
	else if(cl.y == CL_MAGE)
	{
		stat_skill = SKILL_SPELLS;
		stat_mana_regen = 4 * lv;
		stat_resist_magic = 4 * cl.x;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_THEURGIST)
	{
		stat_skill = SKILL_SPELLS | SKILL_MELEE;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY | SKILL_BRAWL;
	}
	else if(cl.y == CL_BARD)
	{
		stat_skill = SKILL_SPELLS;
		stat_mana_regen = 3 * lv;
		stat_critical = 4 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY | SKILL_FLAME_ARROW;
	}
	else if(cl.y == CL_DRUID)
	{
		stat_skill = SKILL_SPELLS | SKILL_SPRINT;
		stat_resist_poison = 16 * lv;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_WIZARD)
	{
		stat_skill = SKILL_IDENTIFY | SKILL_SPELLS;
		stat_mana_regen = 5 * lv;
		stat_resist_magic = 6 * cl.x;
	}
	else if(cl.y == CL_OUTLANDER)
	{
		stat_resist_magic = 10 * lv;
		if(cl.x)
			stat_skill = SKILL_POTION;
	}
	else if(cl.y == CL_GLADIATOR)
	{
		stat_skill = SKILL_MELEE;
		stat_resist_magic = 10 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL | SKILL_POTION;
	}
	else if(cl.y == CL_BARBARIAN)
	{
		stat_skill = SKILL_MELEE | SKILL_BRAWL;
		stat_resist_magic = 10 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL | SKILL_POTION;
		stat_critical = cl.x * 6;
	}
	else if(cl.y == CL_MAVERICK)
	{
		stat_resist_magic = 10 * lv;
		stat_critical = 5 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_POTION;
	}
	else if(cl.y == CL_SOLDIER)
	{
		stat_skill = SKILL_MELEE;
		stat_critical = 4 * lv;
		stat_resist_magic = 8 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_POTION | SKILL_BRAWL;
	}
	else if(cl.y == CL_COUNTRYMAN)
	{
		stat_resist_magic = 10 * lv;
		stat_skill = SKILL_BOW;
		stat_tohit = 5 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_POTION;

	}
	else if(cl.y == CL_PIRATE)
	{
		stat_skill = SKILL_SPRINT | SKILL_DISCOUNT;
		if(cl.x)
			stat_skill = stat_skill | SKILL_POTION;
	}
	else if(cl.y == CL_PIONEER)
	{
		stat_skill = SKILL_SPRINT | SKILL_MELEE;
		stat_resist_magic = 8 * lv;	
		if(cl.x)
			stat_skill = stat_skill | SKILL_POTION | SKILL_BRAWL;
	}
	else if(cl.y == CL_WANDERER)
	{
		stat_skill = SKILL_SPRINT | SKILL_BOW;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_POTION;
		stat_critical = 5 * lv;
	}
	else if(cl.y == CL_MARAUDER)
	{
		stat_skill = SKILL_SPRINT | SKILL_DISCOUNT;
		stat_dodge = 5 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_POTION;
	}
	else if(cl.y == CL_HERETIC)
	{
		stat_resist_magic = 12 * lv;
		stat_mana_regen = 4 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY | SKILL_POTION;
	}
	else if(cl.y == CL_TROOPER)
	{
		stat_skill = SKILL_MELEE;
		stat_resist_magic = 8 * lv;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY | SKILL_POTION | SKILL_BRAWL;
	}
	else if(cl.y == CL_SEER)
	{
		stat_critical = 5 * lv;
		stat_resist_magic = 10 * lv;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_IDENTIFY | SKILL_POTION;
	}
	else if(cl.y == CL_HOOLIGAN)
	{
		stat_skill = SKILL_SPRINT;
		stat_resist_magic = 10 * lv;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY | SKILL_POTION;
	}
	else if(cl.y == CL_ARCHMAGE)
	{
		stat_skill = SKILL_SPELLS;
		stat_mana_regen = 5 * lv;
		stat_resist_magic = 10 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY | SKILL_POTION;
	}
	else if(cl.y == CL_TRAVELER)
	{
		stat_resist_magic = 10 * lv;
		stat_def = lv * 5;
		stat_skill = SKILL_POTION;
		if(cl.x)
			stat_health_regen = stat_health_regen + 8 * cl.x;
	}
	else if(cl.y == CL_REAVER)
	{
		stat_resist_magic = 8 * lv;
		stat_def = lv * 4;
		stat_skill = SKILL_POTION | SKILL_MELEE;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL;
	}
	else if(cl.y == CL_WOODSMAN)
	{
		stat_resist_magic = 8 * lv;
		stat_resist_poison = 10 * lv;
		stat_def = lv * 4;
		stat_skill = SKILL_POTION;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW;
	}
	else if(cl.y == CL_CORSAIR)
	{
		stat_resist_magic = 8 * lv;
		stat_def = lv * 4;
		stat_skill = SKILL_POTION | SKILL_SPRINT;
		if(cl.x)
			stat_health_regen = stat_health_regen + 8 * cl.x;
	}
	else if(cl.y == CL_SEEKER)
	{
		stat_mana_regen = 4 * lv;
		stat_resist_magic = 8 * lv;
		stat_def = lv * 4;
		stat_spec = SKILL_POTION;
		if(cl.x)
			stat_spec = stat_spec | SKILL_IDENTIFY;
			
	}
	else if(cl.y == CL_JOURNEYMAN)
	{
		stat_resist_magic = 16 * lv;
		stat_def = lv * 8;
		stat_skill = SKILL_POTION;
		stat_health_regen = stat_health_regen + 8 * cl.x;
	}
	else if(cl.y == CL_GAMESTER)
	{
		stat_skill = SKILL_DISCOUNT;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRIBE;
	}
	else if(cl.y == CL_SCOUNDREL)
	{	
		if(cl.x)
			stat_skill = SKILL_DISCOUNT | SKILL_BRIBE | SKILL_BRAWL;
		else
			stat_skill = SKILL_DISCOUNT | SKILL_MELEE;
	}
	else if(cl.y == CL_MERCENARY)
	{
		stat_skill = SKILL_MELEE | SKILL_BRAWL | SKILL_DISCOUNT;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRIBE;
	}
	else if(cl.y == CL_THIEF)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_THROW;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRIBE;
	}
	else if(cl.y == CL_CONQUEROR)
	{
		if(cl.x)
			stat_skill = SKILL_DISCOUNT | SKILL_BRIBE | SKILL_FLAME_ARROW | SKILL_BRAWL;
		else
			stat_skill = SKILL_DISCOUNT | SKILL_THROW | SKILL_MELEE;
	}
	else if(cl.y == CL_ROGUE)
	{
		if(cl.x)
			stat_skill = SKILL_DISCOUNT | SKILL_BRIBE | SKILL_FLAME_ARROW;
		else
			stat_skill = SKILL_DISCOUNT | SKILL_THROW;
		stat_tohit = 5 * lv;

	}
	else if(cl.y == CL_BURGLAR)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_SPRINT;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRIBE;
		stat_aspeed = 4 * cl.x;
	}
	else if(cl.y == CL_DRIFTER)
	{
		if(cl.x)
			stat_skill = SKILL_SPRINT | SKILL_BRAWL | SKILL_BRIBE;
		else
			stat_skill = SKILL_DISCOUNT | SKILL_SPRINT | SKILL_MELEE;
	}
	else if(cl.y == CL_MUGGER)
	{

		stat_critical = 5 * lv;
		if(cl.x)
			stat_skill = SKILL_SPRINT | SKILL_FLAME_ARROW | SKILL_BRIBE;
		else
			stat_skill = SKILL_DISCOUNT | SKILL_SPRINT;
		stat_aspeed = 4 * cl.x;
	}
	else if(cl.y == CL_CUTTHROAT)
	{
		stat_skill = SKILL_SPRINT | SKILL_DISCOUNT;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRIBE;
		stat_dodge = 5 * lv;
		stat_aspeed = 4 * cl.x;
	}
	else if(cl.y == CL_TRICKSTER)
	{
		stat_skill = SKILL_DISCOUNT;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRIBE | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_WAYFARER)
	{
		if(cl.x)
			stat_skill = SKILL_BRAWL | SKILL_IDENTIFY | SKILL_BRIBE;
		else
			stat_skill = SKILL_DISCOUNT | SKILL_MELEE;
		stat_mana_regen = 4 * lv;
	}
	else if(cl.y == CL_STEWARD)
	{
		stat_skill = SKILL_DISCOUNT;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_IDENTIFY | SKILL_BRIBE;
	}
	else if(cl.y == CL_CHARMER)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_SPRINT;
		stat_mana_regen = 3 * lv;
		stat_aspeed = 4 * cl.x;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY | SKILL_BRIBE;
	}
	else if(cl.y == CL_DIVINER)
	{
		stat_skill = SKILL_SPELLS | SKILL_DISCOUNT;
		stat_mana_regen = 3 * lv;
	}
	else if(cl.y == CL_RUFFIAN)
	{
		stat_skill = SKILL_DISCOUNT;
		stat_resist_magic = 10 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_IDENTIFY | SKILL_BRIBE;
	}
	else if(cl.y == CL_DEFENDER)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_MELEE;
		stat_resist_magic = 10 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL | SKILL_POTION | SKILL_BRIBE;
	}
	else if(cl.y == CL_OUTLAW)
	{
		stat_skill = SKILL_DISCOUNT;
		stat_resist_magic = 8 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW | SKILL_POTION | SKILL_BRIBE;
	}
	else if(cl.y == CL_BANDIT)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_SPRINT;
		stat_resist_magic = 8 * lv;
		stat_aspeed = 4 * cl.x;
		if(cl.x)
			stat_skill = stat_skill | SKILL_POTION | SKILL_BRIBE;
	}
	else if(cl.y == CL_DIABOLIST)
	{
		stat_skill = SKILL_DISCOUNT;
		stat_mana_regen = 3 * lv;
		stat_resist_magic = 8 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_POTION | SKILL_BRIBE | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_VIKING)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_POTION;
		stat_resist_magic = 8 * lv;
		if(cl.x)
		{
			stat_skill = stat_skill | SKILL_BRIBE;
			stat_health_regen = stat_health_regen + 8 * cl.x;
		}
	}
	else if(cl.y == CL_GAMBLER)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_BRIBE;
		stat_critical = 4 * cl.x;
	}
	else if(cl.y == CL_VANDAL)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_BRIBE | SKILL_MELEE;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRAWL;
	}
	else if(cl.y == CL_PICKPOCKET)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_BRIBE;
		stat_critical = 5 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_FLAME_ARROW;
	}
	else if(cl.y == CL_LARCENIST)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_SPRINT;
		if(cl.x)
			stat_skill = stat_skill | SKILL_BRIBE;
		stat_aspeed = 4 * cl.x;
	}
	else if(cl.y == CL_ILLUSIONIST)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_BRIBE;
		stat_mana_regen = 3 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_SPELLS | SKILL_IDENTIFY;
	}
	else if(cl.y == CL_RAIDER)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_BRIBE;
		stat_resist_magic = 8 * lv;
		if(cl.x)
			stat_skill = stat_skill | SKILL_POTION;
	}
	else if(cl.y == CL_CHARLATAN)
	{
		stat_skill = SKILL_DISCOUNT | SKILL_BRIBE | SKILL_IDENTIFY;
		stat_critical = 5 * cl.x;
	}
}
