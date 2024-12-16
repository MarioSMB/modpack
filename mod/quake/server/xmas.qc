#include "xmas.qh"

#include "monsters/monsters.qh"

const int XMAS_PRESENT_HEAL = 0;
const int XMAS_PRESENT_WEAPON = 1;
const int XMAS_PRESENT_EXPLODE = 2;
const int XMAS_PRESENT_MONSTER = 3;

PRECACHE(Xmas_Presents)
{
	precache_model("progs/kebby_xjgift.mdl");
	precache_model("progs/balxj_tree_a.mdl");
	precache_model("progs/balxj_tree_baubles.mdl");

	precache_sound("items/health1.wav");
	precache_sound("weapons/pkup.wav");
}

void xmas_present_heal(entity this, entity toucher)
{
	T_Heal(toucher, 50, true);

	_sound(toucher, CH_TRIGGER_SINGLE, "items/health1.wav", 1, ATTN_NORM);
}

void xmas_present_weapon(entity this, entity toucher)
{
	RandomSelection_Init();

	FOREACH(Weapons, it.spawnflags & WEP_FLAG_MANA,
	{
		RandomSelection_AddEnt(it, 1, 1);
	});

	.entity weaponentity = weaponentities[0]; // TODO?
	Weapon wep = RandomSelection_chosen_ent;
	bool doswap = false;

	if(!(STAT(WEAPONS, toucher) & wep.m_wepset))
	{
		doswap = true;
		Send_Notification(NOTIF_ONE, toucher, MSG_INFO, INFO_ITEM_WEAPON_PICKUP);
	}

	_sound(toucher, CH_TRIGGER_SINGLE, "weapons/pkup.wav", 1, ATTN_NORM);

	if(toucher.m_champion && toucher.m_champion.m_pickup_weapon)
		toucher.m_champion.m_pickup_weapon(toucher.m_champion, toucher, this);

	if((STAT(WEAPONS, toucher) & wep.m_wepset) && (coop || deathmatch == 2))
		STAT(DUAL_WEAPONS, toucher) |= wep.m_wepset;
	else
		STAT(WEAPONS, toucher) |= wep.m_wepset;

	if(toucher.cvar_cl_autoswitch && doswap)
	{
		if(!deathmatch)
			W_SwitchWeapon(toucher, wep, weaponentity);
		else
			Deathmatch_Weapon(toucher, wep, weaponentity);
	}
}

void xmas_present_ammo(entity this, entity toucher)
{
	toucher.ammo_shells += 30; SendItemPickup(toucher, IT_SHELLS, 30);
	toucher.ammo_nails += 60; SendItemPickup(toucher, IT_NAILS, 60);
	toucher.ammo_rockets += 20; SendItemPickup(toucher, IT_ROCKETS, 20);
	toucher.ammo_cells += 30; SendItemPickup(toucher, IT_CELLS, 30);
	toucher.ammo_lava_nails += 60; SendItemPickup(toucher, IT_LAVA_NAILS, 60);
	toucher.ammo_multi_rockets += 20; SendItemPickup(toucher, IT_MULTI_ROCKETS, 20);
	toucher.ammo_plasma += 40; SendItemPickup(toucher, IT_PLASMA_AMMO, 40);
	bound_other_ammo(toucher);
}

void xmas_present_monster(entity this, entity toucher)
{
	horn_spawnmonster(this.origin, NULL, MON_ELF);
}

void xmas_present_touch(entity this, entity toucher)
{
	if(toucher.exptime != 0)
		return;
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.tank)
		return;
	if(toucher.clockwork)
		return;
	if(toucher.m_transform)
		return;

	float r = random();
	if(r < 0.25)
		xmas_present_heal(this, toucher);
	else if(r < 0.50)
		xmas_present_weapon(this, toucher);
	else if(r < 0.75)
		xmas_present_ammo(this, toucher);
	else
		xmas_present_monster(this, toucher);

	particle(this.origin + '0 0 24', '0 0 50', floor(random() * 10) * 10, 100);

	SUB_UseTargets(this, toucher, NULL);

	delete(this);
}

void xmas_decor_think(entity this)
{
	this.nextthink = time + 0.1;
	setorigin(this, this.owner.origin);
	this.angles = this.owner.angles;
}

bool xmas_replace(entity this, Monster mon)
{
	if(this.targetname && this.targetname != "")
		return false;
	if(mon.spawnflags & MONSTER_TYPE_BOSS)
		return false;
	if((mon.spawnflags & MONSTER_TYPE_SWIM) || (mon.spawnflags & MONSTER_TYPE_FLY))
		return false;
	// but allow targets (we can just redirect it)
	if(random() > 0.35)
		return false;
	//if(!Monsters_SeasonLocked())
		//return false;

	// probably a shambler, spawn a tree!
	if(mon.m_maxs_z >= 48 && (!this.target || this.target == "") && random() > 0.5)
	{
		entity tree = new(tree);
		tree.solid = SOLID_NOT;
		tree.angles = this.angles;
		set_movetype(tree, MOVETYPE_TOSS);
		setorigin(tree, this.origin);
		_setmodel(tree, "progs/balxj_tree_a.mdl");
		setsize(tree, '-16 -16 0', '16 16 16');
		tree.frame = 0;

		entity decor = new(tree_decor);
		decor.owner = tree;
		decor.solid = SOLID_NOT;
		decor.angles = this.angles;
		set_movetype(decor, MOVETYPE_NONE);
		setorigin(decor, this.origin);
		_setmodel(decor, "progs/balxj_tree_baubles.mdl");
		setsize(decor, '-16 -16 -16', '16 16 16');
		decor.frame = 0;
		setthink(decor, xmas_decor_think);
		decor.nextthink = time + 0.1;
		return true;
	}

	entity present = new(present);
	present.solid = SOLID_TRIGGER;
	present.target = this.target;
	present.target2 = this.target2;
	present.target3 = this.target3;
	present.target4 = this.target4;
	present.killtarget = this.killtarget;
	present.angles = this.angles;
	set_movetype(present, MOVETYPE_TOSS);
	present.frame = floor(random() * 10);
	present.skin = floor(random() * 10);
	_setmodel(present, "progs/kebby_xjgift.mdl");
	setsize(present, '-16 -16 0', '16 16 56');
	setorigin(present, this.origin);
	settouch(present, xmas_present_touch);
	return true;
}