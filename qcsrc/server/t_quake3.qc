//***********************
//QUAKE 3 ENTITIES - So people can play quake3 maps with the xonotic weapons
//***********************

// NOTE: for best experience, you need to swap MGs with SGs in the map or it won't have a MG

// SG -> SG
void spawnfunc_ammo_shells()         { spawnfunc_item_shells();         }

// MG -> MG
void spawnfunc_weapon_machinegun()   { spawnfunc_weapon_uzi();          }
void spawnfunc_ammo_bullets()        { spawnfunc_item_bullets();        }

// GL -> Mortar
void spawnfunc_ammo_grenades()       { spawnfunc_item_rockets();        }

// LG -> Electro
void spawnfunc_weapon_lightning()    { spawnfunc_weapon_electro();      }
void spawnfunc_ammo_lightning()      { spawnfunc_item_cells();          }

// Plasma -> Hagar
void spawnfunc_weapon_plasmagun()    { spawnfunc_weapon_hagar();        }
void spawnfunc_ammo_cells()          { spawnfunc_item_rockets();        }

// Rail -> Nex
void spawnfunc_weapon_railgun()      { spawnfunc_weapon_nex();          }
void spawnfunc_ammo_slugs()          { spawnfunc_item_cells();          }

// BFG -> Crylink
void spawnfunc_weapon_bfg()          { spawnfunc_weapon_crylink();      }
void spawnfunc_ammo_bfg()            { spawnfunc_item_cells();          }

// RL -> RL
void spawnfunc_ammo_rockets()        { spawnfunc_item_rockets();        }

// Armor
void spawnfunc_item_armor_body()     { spawnfunc_item_armor_large();    }
void spawnfunc_item_armor_combat()   { spawnfunc_item_armor_big();      }
void spawnfunc_item_armor_shard()    { spawnfunc_item_armor_small();    }
void spawnfunc_item_enviro()         { spawnfunc_item_invincible();     }

// weapon remove ent from df
void target_init_verify()
{
	entity trigger, targ;
	for(trigger = world; (trigger = find(trigger, classname, "trigger_multiple")); )
		for(targ = world; (targ = find(targ, targetname, trigger.target)); )
			if (targ.classname == "target_init" || targ.classname == "target_give" || targ.classname == "target_items")
			{
				trigger.wait = 0;
				trigger.delay = 0;
				targ.wait = 0;
				targ.delay = 0;

				//setsize(targ, trigger.mins, trigger.maxs);
				//setorigin(targ, trigger.origin);
				//remove(trigger);
			}
}

void spawnfunc_target_init()
{
	self.spawnflags = 0; // remove all weapons except the ones listed below
	self.netname = "shotgun"; // keep these weapons through the remove trigger
	spawnfunc_target_items();
	InitializeEntity(self, target_init_verify, INITPRIO_FINDTARGET);
}

// weapon give ent from defrag
void target_give_init()
{
	entity targ;
	for (targ = world; (targ = find(targ, targetname, self.target)); ) {
		if (targ.classname == "weapon_rocketlauncher") {
			self.ammo_rockets += targ.count * autocvar_g_balance_rocketlauncher_ammo;
			self.netname = "rocketlauncher";
		}
		else if (targ.classname == "weapon_plasmagun") {
			self.ammo_rockets += targ.count * autocvar_g_balance_hagar_primary_ammo;
			if(self.netname == "")
				self.netname = "hagar";
			else
				self.netname = strcat(self.netname, " hagar");
		}
		else if (targ.classname == "weapon_bfg") {
			self.ammo_cells += targ.count * autocvar_g_balance_crylink_primary_ammo;
			if(self.netname == "")
				self.netname = "crylink";
			else
				self.netname = strcat(self.netname, " crylink");
		}
		else if (targ.classname == "weapon_grenadelauncher") {
			self.ammo_rockets += targ.count * autocvar_g_balance_grenadelauncher_primary_ammo;
			if(self.netname == "")
				self.netname = "grenadelauncher";
			else
				self.netname = strcat(self.netname, " grenadelauncher");
		}
		else if (targ.classname == "item_armor_body")
			self.armorvalue = 100;
		else if (targ.classname == "item_health_mega")
			self.health = 200;
		//remove(targ); // removing ents in init functions causes havoc, workaround:
        targ.think = SUB_Remove;
        targ.nextthink = time;
	}
	self.spawnflags = 2;
	spawnfunc_target_items();
	InitializeEntity(self, target_init_verify, INITPRIO_FINDTARGET);
}

void spawnfunc_target_give()
{
	InitializeEntity(self, target_give_init, INITPRIO_FINDTARGET);
}

//void spawnfunc_item_flight()       /* not supported */
//void spawnfunc_item_haste()        /* not supported */
//void spawnfunc_item_health()       /* handled in t_quake.qc */
//void spawnfunc_item_health_large() /* handled in t_items.qc */
//void spawnfunc_item_health_small() /* handled in t_items.qc */
//void spawnfunc_item_health_mega()  /* handled in t_items.qc */
//void spawnfunc_item_invis()        /* not supported */
//void spawnfunc_item_regen()        /* not supported */

// CTF spawnfuncs handled in mutators/gamemode_ctf.qc now

void spawnfunc_item_flight()         { spawnfunc_item_jetpack();       }

.float notteam;
.float notsingle;
.float notfree;
.float notq3a;
.float notta;
.string gametype;
float DoesQ3ARemoveThisEntity()
{
	// Q3 style filters (DO NOT USE, THIS IS COMPAT ONLY)

	if(self.notq3a)
		if(!teamplay || g_tdm || g_ctf)
			return 1;

	if(self.notta)
		if not(!teamplay || g_tdm || g_ctf)
			return 1;

	if(self.notsingle)
		if(maxclients == 1)
			return 1;

	if(self.notteam)
		if(teamplay)
			return 1;

	if(self.notfree)
		if(!teamplay)
			return 1;

	if(self.gametype)
	{
		string gametypename;
		// static char *gametypeNames[] = {"ffa", "tournament", "single", "team", "ctf", "oneflag", "obelisk", "harvester", "teamtournament"}
		gametypename = "ffa";
		if(teamplay)
			gametypename = "team";
		if(g_arena)
			gametypename = "tournament";
		if(g_ctf)
			gametypename = "ctf";
		if(maxclients == 1)
			gametypename = "single";
		// we do not have the other types (oneflag, obelisk, harvester, teamtournament)
		if(strstrofs(self.gametype, gametypename, 0) < 0)
			return 1;
	}

	return 0;
}
