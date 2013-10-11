#define ISF_LOCATION 2
#define ISF_MODEL    4
#define ISF_STATUS   8
    #define ITS_STAYWEP   1
    #define ITS_ANIMATE1  2
    #define ITS_ANIMATE2  4
    #define ITS_AVAILABLE 8
    #define ITS_ALLOWFB   16
    #define ITS_ALLOWSI   32
    #define ITS_POWERUP   64
#define ISF_COLORMAP 16
#define ISF_DROP 32
#define ISF_ANGLES 64

.float ItemStatus;

#ifdef CSQC

var float  autocvar_cl_animate_items = 1;
var float  autocvar_cl_ghost_items = 0.45;
var vector autocvar_cl_ghost_items_color = '-1 -1 -1';
var float  autocvar_cl_fullbright_items = 0;
var vector autocvar_cl_weapon_stay_color = '2 0.5 0.5';
var float  autocvar_cl_weapon_stay_alpha = 0.75;
var float  autocvar_cl_simple_items = 0;
var string autocvr_cl_simpleitems_postfix = "_simple";
.float  spawntime;
.float  gravity;
.vector colormod;
void ItemDraw()
{    
    if(self.gravity)
    {        
        Movetype_Physics_MatchServer(autocvar_cl_projectiles_sloppy);
        if(self.move_flags & FL_ONGROUND) 
        { // For some reason move_avelocity gets set to '0 0 0' here ...
            self.oldorigin = self.origin;
            self.gravity = 0;

            if(autocvar_cl_animate_items)   
            { // ... so reset it if animations are requested. 
                if(self.ItemStatus & ITS_ANIMATE1)
                    self.move_avelocity = '0 180 0';
                
                if(self.ItemStatus & ITS_ANIMATE2)
                    self.move_avelocity = '0 -90 0';
            }
        }
    }
    else if (autocvar_cl_animate_items)
    {        
        if(self.ItemStatus & ITS_ANIMATE1)
        {
            self.angles += self.move_avelocity * frametime;
            setorigin(self, '0 0 10' + self.oldorigin + '0 0 8' * sin(time * 2));        
        }    
        
        if(self.ItemStatus & ITS_ANIMATE2)
        {
            self.angles += self.move_avelocity * frametime;
            setorigin(self, '0 0 8' + self.oldorigin + '0 0 4' * sin(time * 3));        
        }
    }
}

void ItemDrawSimple()
{
    if(self.gravity)
    {        
        Movetype_Physics_MatchServer(autocvar_cl_projectiles_sloppy);    
        
        if(self.move_flags & FL_ONGROUND)
            self.gravity = 0;
    }
}

void ItemRead(float _IsNew)
{
    float sf = ReadByte();

    if(sf & ISF_LOCATION)
    {
        self.origin_x = ReadCoord();
        self.origin_y = ReadCoord();
        self.origin_z = ReadCoord();
        setorigin(self, self.origin);
        self.oldorigin = self.origin;
    }
    
    if(sf & ISF_ANGLES) 
    {
        self.angles_x = ReadCoord();
        self.angles_y = ReadCoord();
        self.angles_z = ReadCoord();        
        self.move_angles = self.angles;
    }
    
    if(sf & ISF_STATUS) // need to read/write status frist so model can handle simple, fb etc.
    {
        self.ItemStatus = ReadByte();    
        
        if(self.ItemStatus & ITS_AVAILABLE)
        {
            self.alpha = 1;
            self.colormod = self.glowmod = '1 1 1';
        }
        else
        {
            if (autocvar_cl_ghost_items_color)
            {
                self.alpha = autocvar_cl_ghost_items;
                self.colormod = self.glowmod = autocvar_cl_ghost_items_color;
            }
            else
                self.alpha = -1;
        }    
        
        if(autocvar_cl_fullbright_items)
            if(self.ItemStatus & ITS_ALLOWFB)
                self.effects |= EF_FULLBRIGHT;
            
        if(self.ItemStatus & ITS_STAYWEP)
        {
            self.colormod = self.glowmod = autocvar_cl_weapon_stay_color;
            self.alpha = autocvar_cl_weapon_stay_alpha;
            
        }
        
        if(self.ItemStatus & ITS_POWERUP)
        {
            if(self.ItemStatus & ITS_AVAILABLE)
                self.effects |= (EF_ADDITIVE | EF_FULLBRIGHT);
            else
                 self.effects &= ~(EF_ADDITIVE | EF_FULLBRIGHT);
        }
    }
    
    if(sf & ISF_MODEL)
    {
        self.drawmask  = MASK_NORMAL;
        self.movetype  = MOVETYPE_NOCLIP;
        self.draw       = ItemDraw;
        
        if(self.mdl)
            strunzone(self.mdl);
        
        self.mdl = "";
        string _fn = ReadString();
        
        if(autocvar_cl_simple_items && (self.ItemStatus & ITS_ALLOWSI))
        {
            string _fn2 = substring(_fn, 0 , strlen(_fn) -4);
            self.draw = ItemDrawSimple;
                    
            
            
            if(fexists(sprintf("%s%s.md3", _fn2, autocvr_cl_simpleitems_postfix)))
                self.mdl = strzone(sprintf("%s%s.md3", _fn2, autocvr_cl_simpleitems_postfix));
            else if(fexists(sprintf("%s%s.dpm", _fn2, autocvr_cl_simpleitems_postfix)))
                self.mdl = strzone(sprintf("%s%s.dpm", _fn2, autocvr_cl_simpleitems_postfix));
            else if(fexists(sprintf("%s%s.iqm", _fn2, autocvr_cl_simpleitems_postfix)))
                self.mdl = strzone(sprintf("%s%s.iqm", _fn2, autocvr_cl_simpleitems_postfix));
            else if(fexists(sprintf("%s%s.obj", _fn2, autocvr_cl_simpleitems_postfix)))
                self.mdl = strzone(sprintf("%s%s.obj", _fn2, autocvr_cl_simpleitems_postfix));
            else
            {
                self.draw = ItemDraw;
                dprint("Simple item requested for ", _fn, " but no model exsist for it\n");
            }
        }
        
        if(self.draw != ItemDrawSimple)        
            self.mdl = strzone(_fn);                
        
        
        if(self.mdl == "")
            dprint("^1WARNING!^7 self.mdl is unset for item ", self.classname, " tell tZork aboute this!\n");
        
        precache_model(self.mdl);
        setmodel(self, self.mdl);
    }
    
    if(sf & ISF_COLORMAP)
        self.colormap = ReadShort();
    
    if(sf & ISF_DROP)
    {
        self.gravity = 1;
        self.move_angles = '0 0 0';
        self.move_movetype = MOVETYPE_TOSS;
        self.move_velocity_x = ReadCoord();
        self.move_velocity_y = ReadCoord();
        self.move_velocity_z = ReadCoord();
        self.velocity = self.move_velocity;
        self.move_origin = self.oldorigin;
        
        if(!self.move_time)
        {
            self.move_time = time;
            self.spawntime = time;
        }
        else
            self.move_time = max(self.move_time, time);
    }
        
    if(autocvar_cl_animate_items)
    {        
        if(self.ItemStatus & ITS_ANIMATE1)
            self.move_avelocity = '0 180 0';
                
        if(self.ItemStatus & ITS_ANIMATE2)
            self.move_avelocity = '0 -90 0';
    }
}

#endif

#ifdef SVQC
float autocvar_sv_simple_items;
float ItemSend(entity to, float sf)
{
    if(self.gravity)
        sf |= ISF_DROP;
    else
        sf &= ~ISF_DROP;
	
	WriteByte(MSG_ENTITY, ENT_CLIENT_ITEM);	
	WriteByte(MSG_ENTITY, sf);

	//WriteByte(MSG_ENTITY, self.cnt);
    if(sf & ISF_LOCATION)
    {
        WriteCoord(MSG_ENTITY, self.origin_x);
        WriteCoord(MSG_ENTITY, self.origin_y);
        WriteCoord(MSG_ENTITY, self.origin_z);
    }
    
    if(sf & ISF_ANGLES)
    {
        WriteCoord(MSG_ENTITY, self.angles_x);
        WriteCoord(MSG_ENTITY, self.angles_y);
        WriteCoord(MSG_ENTITY, self.angles_z);
    }

    if(sf & ISF_STATUS)
        WriteByte(MSG_ENTITY, self.ItemStatus);

    if(sf & ISF_MODEL)
    {
        
        if(self.mdl == "")
            dprint("^1WARNING!^7 self.mdl is unset for item ", self.classname, "exspect a crash just aboute now\n");
        
        WriteString(MSG_ENTITY, self.mdl);
    }
        
        
    if(sf & ISF_COLORMAP)
        WriteShort(MSG_ENTITY, self.colormap);

    if(sf & ISF_DROP)
    {
        WriteCoord(MSG_ENTITY, self.velocity_x);
        WriteCoord(MSG_ENTITY, self.velocity_y);
        WriteCoord(MSG_ENTITY, self.velocity_z);
    }
        
    return TRUE;
}

void ItemUpdate(entity item)
{
	item.SendFlags |= ISF_LOCATION;
}

float have_pickup_item(void)
{
	if(self.flags & FL_POWERUP)
	{
		if(autocvar_g_powerups > 0)
			return TRUE;
		if(autocvar_g_powerups == 0)
			return FALSE;
	}
	else
	{
		if(autocvar_g_pickup_items > 0)
			return TRUE;
		if(autocvar_g_pickup_items == 0)
			return FALSE;
		if(g_weaponarena)
			if(self.weapons || (self.items & IT_AMMO))
				return FALSE;
	}
	return TRUE;
}

#define ITEM_RESPAWN_TICKS 10

#define ITEM_RESPAWNTIME(i)         ((i).respawntime + crandom() * (i).respawntimejitter)
	// range: respawntime - respawntimejitter .. respawntime + respawntimejitter
#define ITEM_RESPAWNTIME_INITIAL(i) (ITEM_RESPAWN_TICKS + random() * ((i).respawntime + (i).respawntimejitter - ITEM_RESPAWN_TICKS))
	// range: 10 .. respawntime + respawntimejitter

floatfield Item_CounterField(float it)
{
	switch(it)
	{
		case IT_SHELLS:      return ammo_shells;
		case IT_NAILS:       return ammo_nails;
		case IT_ROCKETS:     return ammo_rockets;
		case IT_CELLS:       return ammo_cells;
		case IT_FUEL:        return ammo_fuel;
		case IT_5HP:         return health;
		case IT_25HP:        return health;
		case IT_HEALTH:      return health;
		case IT_ARMOR_SHARD: return armorvalue;
		case IT_ARMOR:       return armorvalue;
		// add more things here (health, armor)
		default:             error("requested item has no counter field");
	}
#ifdef GMQCC
	// should never happen
	return health;
#endif
}

string Item_CounterFieldName(float it)
{
	switch(it)
	{
		case IT_SHELLS:      return "shells";
		case IT_NAILS:       return "nails";
		case IT_ROCKETS:     return "rockets";
		case IT_CELLS:       return "cells";
		case IT_FUEL:        return "fuel";

		// add more things here (health, armor)
		default:             error("requested item has no counter field name");
	}
#ifdef GMQCC
	// should never happen
	return string_null;
#endif
}

.float max_armorvalue;
.float pickup_anyway;
/*
float Item_Customize()
{
	if(self.spawnshieldtime)
		return TRUE;
	if(self.weapons & ~other.weapons)
	{
		self.colormod = '0 0 0';
		self.glowmod = self.colormod;
		self.alpha = 0.5 + 0.5 * g_ghost_items; // halfway more alpha
		return TRUE;
	}
	else
	{
		if(g_ghost_items)
		{
			self.colormod = stov(autocvar_g_ghost_items_color);
			self.glowmod = self.colormod;
			self.alpha = g_ghost_items;
			return TRUE;
		}
		else
			return FALSE;
	}
}
*/

void Item_Show (entity e, float mode)
{    
	e.effects &= ~(EF_ADDITIVE | EF_STARDUST | EF_FULLBRIGHT | EF_NODEPTHTEST);
	e.ItemStatus &= ~ITS_STAYWEP;
	if (mode > 0)
	{
		// make the item look normal, and be touchable
		e.model = e.mdl;
		e.solid = SOLID_TRIGGER;
		e.spawnshieldtime = 1;
		e.ItemStatus |= ITS_AVAILABLE;
	}
	else if (mode < 0)
	{
		// hide the item completely
		e.model = string_null;
		e.solid = SOLID_NOT;
		e.spawnshieldtime = 1;
		e.ItemStatus &= ~ITS_AVAILABLE;
	}
	else if((e.flags & FL_WEAPON) && !(e.flags & FL_NO_WEAPON_STAY) && g_weapon_stay)
	{
		// make the item translucent and not touchable
		e.model = e.mdl;
		e.solid = SOLID_TRIGGER; // can STILL be picked up!
		e.effects |= EF_STARDUST;
		e.spawnshieldtime = 0; // field indicates whether picking it up may give you anything other than the weapon
		e.ItemStatus |= (ITS_AVAILABLE | ITS_STAYWEP);
	}
	else
	{
		//setmodel(e, "null");
		e.solid = SOLID_NOT;
		e.colormod = '0 0 0';
		e.glowmod = e.colormod;
		e.spawnshieldtime = 1;
		e.ItemStatus &= ~ITS_AVAILABLE;
	}
	
	if (e.items & IT_STRENGTH || e.items & IT_INVINCIBLE)
	    e.ItemStatus |= ITS_POWERUP;    		
	
	if (autocvar_g_nodepthtestitems)
		e.effects |= EF_NODEPTHTEST;
		
    
    if (autocvar_g_fullbrightitems)
		e.ItemStatus |= ITS_ALLOWFB;
	
	if (autocvar_sv_simple_items)
        e.ItemStatus |= ITS_ALLOWSI;

	// relink entity (because solid may have changed)
	setorigin(e, e.origin);
    e.SendFlags |= ISF_STATUS;
}

void Item_Think()
{
	self.nextthink = time;
	if(self.origin != self.oldorigin)
	{
		self.oldorigin = self.origin;
		ItemUpdate(self);
	}
}

void Item_Respawn (void)
{
	Item_Show(self, 1);
	// this is ugly...
	if(self.items == IT_STRENGTH)
		sound (self, CH_TRIGGER, "misc/strength_respawn.wav", VOL_BASE, ATTEN_NORM);	// play respawn sound
	else if(self.items == IT_INVINCIBLE)
		sound (self, CH_TRIGGER, "misc/shield_respawn.wav", VOL_BASE, ATTEN_NORM);	// play respawn sound
	else
		sound (self, CH_TRIGGER, "misc/itemrespawn.wav", VOL_BASE, ATTEN_NORM);	// play respawn sound
	setorigin (self, self.origin);
	
	self.think = Item_Think;
	self.nextthink = time;

	//pointparticles(particleeffectnum("item_respawn"), self.origin + self.mins_z * '0 0 1' + '0 0 48', '0 0 0', 1);
	pointparticles(particleeffectnum("item_respawn"), self.origin + 0.5 * (self.mins + self.maxs), '0 0 0', 1);
}

void Item_RespawnCountdown (void)
{
	if(self.count >= ITEM_RESPAWN_TICKS)
	{
		if(self.waypointsprite_attached)
			WaypointSprite_Kill(self.waypointsprite_attached);
		Item_Respawn();
	}
	else
	{
		self.nextthink = time + 1;
		self.count += 1;
		if(self.count == 1)
		{
			string name;
			vector rgb = '1 0 1';
			name = string_null;
			switch(self.items)
			{
				case IT_FUEL_REGEN: name = "item-fuelregen"; rgb = '1 0.5 0'; break;
				case IT_JETPACK:    name = "item-jetpack"; rgb = '0.5 0.5 0.5'; break;
				case IT_STRENGTH:   name = "item-strength"; rgb = '0 0 1'; break;
				case IT_INVINCIBLE: name = "item-shield"; rgb = '1 0 1'; break;
			}
			item_name = name;
			item_color = rgb;
			MUTATOR_CALLHOOK(Item_RespawnCountdown);
			name = item_name;
			rgb = item_color;
			if(self.flags & FL_WEAPON)
			{
				entity wi = get_weaponinfo(self.weapon);
				if(wi)
				{
					name = wi.model2;
					rgb = '1 0 0';
				}
			}
			if(name)
			{
				WaypointSprite_Spawn(name, 0, 0, self, '0 0 64', world, 0, self, waypointsprite_attached, TRUE, RADARICON_POWERUP, rgb);
				if(self.waypointsprite_attached)
					WaypointSprite_UpdateBuildFinished(self.waypointsprite_attached, time + ITEM_RESPAWN_TICKS);
			}
			else
			{
				print("Unknown powerup-marked item is wanting to respawn\n");
				localcmd(sprintf("prvm_edict server %d\n", num_for_edict(self)));
			}
		}
		sound (self, CH_TRIGGER, "misc/itemrespawncountdown.wav", VOL_BASE, ATTEN_NORM);	// play respawn sound
		if(self.waypointsprite_attached)
		{
			WaypointSprite_Ping(self.waypointsprite_attached);
			//WaypointSprite_UpdateHealth(self.waypointsprite_attached, self.count);
		}
	}
}

void Item_RespawnThink()
{
	self.nextthink = time;
	if(self.origin != self.oldorigin)
	{
		self.oldorigin = self.origin;
		ItemUpdate(self);
	}
	
	if(time >= self.wait)
		Item_Respawn();
}

void Item_ScheduleRespawnIn(entity e, float t)
{
	if((e.flags & FL_POWERUP) || (e.weapons & WEPSET_SUPERWEAPONS))
	{
		self.think = Item_RespawnCountdown;
		self.nextthink = time + max(0, t - ITEM_RESPAWN_TICKS);
		e.count = 0;
	}
	else
	{
		self.think = Item_RespawnThink;
		self.nextthink = time;
		self.wait = time + t;
	}
}

void Item_ScheduleRespawn(entity e)
{
	if(e.respawntime > 0)
	{
		Item_Show(e, 0);
		Item_ScheduleRespawnIn(e, ITEM_RESPAWNTIME(e));
	}
	else // if respawntime is -1, this item does not respawn
		Item_Show(e, -1);
}

void Item_ScheduleInitialRespawn(entity e)
{
	Item_Show(e, 0);
	Item_ScheduleRespawnIn(e, game_starttime - time + ITEM_RESPAWNTIME_INITIAL(e));
}

const float ITEM_MODE_NONE = 0;
const float ITEM_MODE_HEALTH = 1;
const float ITEM_MODE_ARMOR = 2;
const float ITEM_MODE_FUEL = 3;
float Item_GiveAmmoTo(entity item, entity player, .float ammofield, float ammomax, float mode)
{
	if (!item.ammofield)
		return FALSE;

	if (item.spawnshieldtime)
	{
		if ((player.ammofield < ammomax) || item.pickup_anyway)
		{
			player.ammofield = bound(player.ammofield, ammomax, player.ammofield + item.ammofield);
			goto YEAH;
		}
	}
	else if(g_weapon_stay == 2)
	{
		float mi = min(item.ammofield, ammomax);
		if (player.ammofield < mi)
		{
			player.ammofield = mi;
			goto YEAH;
		}
	}

	return FALSE;

:YEAH
	switch(mode)
	{
		case ITEM_MODE_FUEL:
			player.pauserotfuel_finished = max(player.pauserotfuel_finished, time + autocvar_g_balance_pause_fuel_rot);
			break;
		case ITEM_MODE_HEALTH:
			player.pauserothealth_finished = max(player.pauserothealth_finished, time + autocvar_g_balance_pause_health_rot);
			break;
		case ITEM_MODE_ARMOR:
			player.pauserotarmor_finished = max(player.pauserotarmor_finished, time + autocvar_g_balance_pause_armor_rot);
			break;
		default:
			break;
	}
	return TRUE;
}

float Item_GiveTo(entity item, entity player)
{
	float _switchweapon;
	float pickedup;
	float it;
	float i;

	// if nothing happens to player, just return without taking the item
	pickedup = FALSE;
	_switchweapon = FALSE;
	// in case the player has autoswitch enabled do the following:
	// if the player is using their best weapon before items are given, they
	// probably want to switch to an even better weapon after items are given
	if (player.autoswitch)
	if (player.switchweapon == w_getbestweapon(player))
		_switchweapon = TRUE;

	if not(player.weapons & WepSet_FromWeapon(player.switchweapon))
		_switchweapon = TRUE;

	pickedup |= Item_GiveAmmoTo(item, player, ammo_fuel, g_pickup_fuel_max, ITEM_MODE_FUEL);
	pickedup |= Item_GiveAmmoTo(item, player, ammo_shells, g_pickup_shells_max, ITEM_MODE_NONE);
	pickedup |= Item_GiveAmmoTo(item, player, ammo_nails, g_pickup_nails_max, ITEM_MODE_NONE);
	pickedup |= Item_GiveAmmoTo(item, player, ammo_rockets, g_pickup_rockets_max, ITEM_MODE_NONE);
	pickedup |= Item_GiveAmmoTo(item, player, ammo_cells, g_pickup_cells_max, ITEM_MODE_NONE);
	pickedup |= Item_GiveAmmoTo(item, player, health, item.max_health, ITEM_MODE_HEALTH);
	pickedup |= Item_GiveAmmoTo(item, player, armorvalue, item.max_armorvalue, ITEM_MODE_ARMOR);

	if (item.flags & FL_WEAPON)
	{
		WepSet it;
		it = item.weapons;
		it &= ~player.weapons;

		if (it || (item.spawnshieldtime && item.pickup_anyway))
		{
			pickedup = TRUE;
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
			if(it & WepSet_FromWeapon(i))
				W_GiveWeapon(player, i);
		}
	}

	if((it = (item.items - (item.items & player.items)) & IT_PICKUPMASK))
	{
		pickedup = TRUE;
		player.items |= it;
		Send_Notification(NOTIF_ONE, player, MSG_INFO, INFO_ITEM_WEAPON_GOT, item.netname);
	}

	if (item.strength_finished)
	{
		pickedup = TRUE;
		player.strength_finished = max(player.strength_finished, time) + item.strength_finished;
	}
	if (item.invincible_finished)
	{
		pickedup = TRUE;
		player.invincible_finished = max(player.invincible_finished, time) + item.invincible_finished;
	}
	if (item.superweapons_finished)
	{
		pickedup = TRUE;
		player.superweapons_finished = max(player.superweapons_finished, time) + item.superweapons_finished;
	}

:skip
	
	// always eat teamed entities
	if(item.team)
		pickedup = TRUE;

	if (!pickedup)
		return 0;

	if (_switchweapon)
		if (player.switchweapon != w_getbestweapon(player))
			W_SwitchWeapon_Force(player, w_getbestweapon(player));

	return 1;
}

void Item_Touch (void)
{
	entity e, head;
	
	// remove the item if it's currnetly in a NODROP brush or hits a NOIMPACT surface (such as sky)
	if(self.classname == "droppedweapon")
	{
		if (ITEM_TOUCH_NEEDKILL())
		{
			remove(self);
			return;
		}
	}

	if not(IS_PLAYER(other))
		return;
	if (other.frozen)
		return;
	if (other.deadflag)
		return;
	if (self.solid != SOLID_TRIGGER)
		return;
	if (self.owner == other)
		return;
	if (time < self.item_spawnshieldtime)
		return;

	switch(MUTATOR_CALLHOOK(ItemTouch))
	{
		case MUT_ITEMTOUCH_RETURN: { return; }
		case MUT_ITEMTOUCH_PICKUP: { goto pickup; }
	}

	if (self.classname == "droppedweapon")
	{
		self.strength_finished = max(0, self.strength_finished - time);
		self.invincible_finished = max(0, self.invincible_finished - time);
		self.superweapons_finished = max(0, self.superweapons_finished - time);
	}

	if(!Item_GiveTo(self, other))
	{
		if (self.classname == "droppedweapon")
		{
			// undo what we did above
			self.strength_finished += time;
			self.invincible_finished += time;
			self.superweapons_finished += time;
		}
		return;
	}

	:pickup

	other.last_pickup = time;

	pointparticles(particleeffectnum("item_pickup"), self.origin, '0 0 0', 1);
	sound (other, CH_TRIGGER, self.item_pickupsound, VOL_BASE, ATTEN_NORM);

	if (self.classname == "droppedweapon")
		remove (self);
	else if not(self.spawnshieldtime)
		return;
	else
	{
		if(self.team)
		{
			RandomSelection_Init();
			for(head = world; (head = findfloat(head, team, self.team)); )
			{
				if(head.flags & FL_ITEM)
				{
					Item_Show(head, -1);
					RandomSelection_Add(head, 0, string_null, head.cnt, 0);
				}
			}
			e = RandomSelection_chosen_ent;

		}
		else
			e = self;
		Item_ScheduleRespawn(e);
	}
}

void Item_Reset()
{
	Item_Show(self, !self.state);
	setorigin (self, self.origin);

	if(self.classname != "droppedweapon")
	{
		self.think = Item_Think;
		self.nextthink = time;

		if(self.waypointsprite_attached)
			WaypointSprite_Kill(self.waypointsprite_attached);

		if((self.flags & FL_POWERUP) || (self.weapons & WEPSET_SUPERWEAPONS)) // do not spawn powerups initially!
			Item_ScheduleInitialRespawn(self);
	}
}

void Item_FindTeam()
{
	entity head, e;

	if(self.effects & EF_NODRAW)
	{
		// marker for item team search
		dprint("Initializing item team ", ftos(self.team), "\n");
		RandomSelection_Init();
		for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
			RandomSelection_Add(head, 0, string_null, head.cnt, 0);
		e = RandomSelection_chosen_ent;
		e.state = 0;
		Item_Show(e, 1);

		for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
		{
			if(head != e)
			{
				// make it a non-spawned item
				Item_Show(head, -1);
				head.state = 1; // state 1 = initially hidden item
			}
			head.effects &= ~EF_NODRAW;
		}

		Item_Reset();
	}
}

// Savage: used for item garbage-collection
// TODO: perhaps nice special effect?
void RemoveItem(void)
{
	remove(self);
}

// pickup evaluation functions
// these functions decide how desirable an item is to the bots

float generic_pickupevalfunc(entity player, entity item) {return item.bot_pickupbasevalue;}

float weapon_pickupevalfunc(entity player, entity item)
{
	float c, j, position;

	// See if I have it already
	if(item.weapons & ~player.weapons)
	{
		// If I can pick it up
		if(!item.spawnshieldtime)
			c = 0;
		else if(player.ammo_cells || player.ammo_shells || player.ammo_nails || player.ammo_rockets)
		{
			// Skilled bots will grab more
			c = bound(0, skill / 10, 1) * 0.5;
		}
		else
			c = 0;
	}
	else
		c = 1;

	// If custom weapon priorities for bots is enabled rate most wanted weapons higher
	if( bot_custom_weapon && c )
	{
		// Find the highest position on any range
		position = -1;
		for(j = 0; j < WEP_LAST ; ++j){
			if(
					bot_weapons_far[j] == item.weapon ||
					bot_weapons_mid[j] == item.weapon ||
					bot_weapons_close[j] == item.weapon
			  )
			{
				position = j;
				break;
			}
		}

		// Rate it
		if (position >= 0 )
		{
			position = WEP_LAST - position;
			// item.bot_pickupbasevalue is overwritten here
			return (BOT_PICKUP_RATING_LOW + ( (BOT_PICKUP_RATING_HIGH - BOT_PICKUP_RATING_LOW) * (position / WEP_LAST ))) * c;
		}
	}

	return item.bot_pickupbasevalue * c;
}

float commodity_pickupevalfunc(entity player, entity item)
{
	float c, i;
	float need_shells = FALSE, need_nails = FALSE, need_rockets = FALSE, need_cells = FALSE, need_fuel = FALSE;
	entity wi;
	c = 0;

	// Detect needed ammo
	for(i = WEP_FIRST; i <= WEP_LAST ; ++i)
	{
		wi = get_weaponinfo(i);

		if not(player.weapons & WepSet_FromWeapon(i))
			continue;

		if(wi.items & IT_SHELLS)
			need_shells = TRUE;
		else if(wi.items & IT_NAILS)
			need_nails = TRUE;
		else if(wi.items & IT_ROCKETS)
			need_rockets = TRUE;
		else if(wi.items & IT_CELLS)
			need_cells = TRUE;
		else if(wi.items & IT_FUEL)
			need_cells = TRUE;
	}

	// TODO: figure out if the player even has the weapon this ammo is for?
	// may not affect strategy much though...
	// find out how much more ammo/armor/health the player can hold
	if (need_shells)
	if (item.ammo_shells)
	if (player.ammo_shells < g_pickup_shells_max)
		c = c + max(0, 1 - player.ammo_shells / g_pickup_shells_max);
	if (need_nails)
	if (item.ammo_nails)
	if (player.ammo_nails < g_pickup_nails_max)
		c = c + max(0, 1 - player.ammo_nails / g_pickup_nails_max);
	if (need_rockets)
	if (item.ammo_rockets)
	if (player.ammo_rockets < g_pickup_rockets_max)
		c = c + max(0, 1 - player.ammo_rockets / g_pickup_rockets_max);
	if (need_cells)
	if (item.ammo_cells)
	if (player.ammo_cells < g_pickup_cells_max)
		c = c + max(0, 1 - player.ammo_cells / g_pickup_cells_max);
	if (need_fuel)
	if (item.ammo_fuel)
	if (player.ammo_fuel < g_pickup_fuel_max)
		c = c + max(0, 1 - player.ammo_fuel / g_pickup_fuel_max);
	if (item.armorvalue)
	if (player.armorvalue < item.max_armorvalue)
		c = c + max(0, 1 - player.armorvalue / item.max_armorvalue);
	if (item.health)
	if (player.health < item.max_health)
		c = c + max(0, 1 - player.health / item.max_health);

	return item.bot_pickupbasevalue * c;
}

void Item_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(ITEM_DAMAGE_NEEDKILL(deathtype))
		RemoveItem();
}

.float is_item;
void StartItem (string itemmodel, string pickupsound, float defaultrespawntime, float defaultrespawntimejitter, string itemname, float itemid, float weaponid, float itemflags, float(entity player, entity item) pickupevalfunc, float pickupbasevalue)
{
	startitem_failed = FALSE;

	if(self.model == "")
		self.model = itemmodel;
	
	if(self.model == "")
    {
        error(strcat("^1Tried to spawn ", itemname, " with no model!\n"));
        return;
    }
        
	if(self.item_pickupsound == "")
		self.item_pickupsound = pickupsound;
	
	if(!self.respawntime) // both need to be set
	{
		self.respawntime = defaultrespawntime;
		self.respawntimejitter = defaultrespawntimejitter;
	}

	self.items = itemid;
	self.weapon = weaponid;

	if(weaponid)
		self.weapons = WepSet_FromWeapon(weaponid);
	
	self.flags = FL_ITEM | itemflags;

	if(MUTATOR_CALLHOOK(FilterItem)) // error means we do not want the item
	{
		startitem_failed = TRUE;
		remove(self);
		return;
	}

	// is it a dropped weapon?
	if (self.classname == "droppedweapon")
	{
		self.reset = SUB_Remove;
		// it's a dropped weapon
		self.movetype = MOVETYPE_TOSS;

		// Savage: remove thrown items after a certain period of time ("garbage collection")
		self.think = RemoveItem;
		self.nextthink = time + 20;

		self.takedamage = DAMAGE_YES;
		self.event_damage = Item_Damage;

		if(self.strength_finished || self.invincible_finished || self.superweapons_finished)
		/*
		if(self.items == 0)
		if(!(self.weapons & ~WEPSET_SUPERWEAPONS)) // only superweapons
		if(self.ammo_nails == 0)
		if(self.ammo_cells == 0)
		if(self.ammo_rockets == 0)
		if(self.ammo_shells == 0)
		if(self.ammo_fuel == 0)
		if(self.health == 0)
		if(self.armorvalue == 0)
		*/
		{
			// if item is worthless after a timer, have it expire then
			self.nextthink = max(self.strength_finished, self.invincible_finished, self.superweapons_finished);
		}

		// don't drop if in a NODROP zone (such as lava)
		traceline(self.origin, self.origin, MOVE_NORMAL, self);
		if (trace_dpstartcontents & DPCONTENTS_NODROP)
		{
			startitem_failed = TRUE;
			remove(self);
			return;
		}
	}
	else
	{
		if(!have_pickup_item())
		{
			startitem_failed = TRUE;
			remove (self);
			return;
		}
		
		if(self.angles != '0 0 0')
            self.SendFlags |= ISF_ANGLES;

		self.reset = Item_Reset;
		// it's a level item
		if(self.spawnflags & 1)
			self.noalign = 1;
		if (self.noalign)
			self.movetype = MOVETYPE_NONE;
		else
			self.movetype = MOVETYPE_TOSS;
		// do item filtering according to game mode and other things
		if (!self.noalign)
		{
			// first nudge it off the floor a little bit to avoid math errors
			setorigin(self, self.origin + '0 0 1');
			// set item size before we spawn a spawnfunc_waypoint
			if((itemflags & FL_POWERUP) || self.health || self.armorvalue)
				setsize (self, '-16 -16 0', '16 16 48');
			else
				setsize (self, '-16 -16 0', '16 16 32');
			// note droptofloor returns FALSE if stuck/or would fall too far
			droptofloor();
			waypoint_spawnforitem(self);
		}

		/*
		 * can't do it that way, as it would break maps
		 * TODO make a target_give like entity another way, that perhaps has
		 * the weapon name in a key
		if(self.targetname)
		{
			// target_give not yet supported; maybe later
			print("removed targeted ", self.classname, "\n");
			startitem_failed = TRUE;
			remove (self);
			return;
		}
		*/

		if(autocvar_spawn_debug >= 2)
		{
			entity otheritem;
			for(otheritem = findradius(self.origin, 3); otheritem; otheritem = otheritem.chain)
			{
			    // why not flags & fl_item?
				if(otheritem.is_item)
				{
					dprint("XXX Found duplicated item: ", itemname, vtos(self.origin));
					dprint(" vs ", otheritem.netname, vtos(otheritem.origin), "\n");
					error("Mapper sucks.");
				}
			}
			self.is_item = TRUE;
		}

		weaponsInMap |= WepSet_FromWeapon(weaponid);

		precache_model (self.model);
		precache_sound (self.item_pickupsound);

		precache_sound ("misc/itemrespawncountdown.wav");
		if(itemid == IT_STRENGTH)
			precache_sound ("misc/strength_respawn.wav");
		else if(itemid == IT_INVINCIBLE)
			precache_sound ("misc/shield_respawn.wav");
		else
			precache_sound ("misc/itemrespawn.wav");

		if((itemflags & (FL_POWERUP | FL_WEAPON)) || (itemid & (IT_HEALTH | IT_ARMOR | IT_KEY1 | IT_KEY2)))
			self.target = "###item###"; // for finding the nearest item using find()
	}

	self.bot_pickup = TRUE;
	self.bot_pickupevalfunc = pickupevalfunc;
	self.bot_pickupbasevalue = pickupbasevalue;
	self.mdl = self.model;
	self.netname = itemname;
	self.touch = Item_Touch;
	setmodel(self, "null"); // precision set below
	//self.effects |= EF_LOWPRECISION; 
	
	if((itemflags & FL_POWERUP) || self.health || self.armorvalue)
    {
        self.pos1 = '-16 -16 0';
        self.pos2 = '16 16 48';
    }
	else
    {
        self.pos1 = '-16 -16 0';
        self.pos2 = '16 16 32';
    }
    setsize (self, self.pos1, self.pos2);
    
    if(itemflags & FL_POWERUP) 
        self.ItemStatus |= ITS_ANIMATE1;
	
	if(self.armorvalue || self.health)
        self.ItemStatus |= ITS_ANIMATE2;
	
	if(itemflags & FL_WEAPON)
	{
		if (self.classname != "droppedweapon") // if dropped, colormap is already set up nicely
            self.colormap = 1024; // color shirt=0 pants=0 grey
        else
            self.gravity = 1;
            
		self.ItemStatus |= ITS_ANIMATE1;
		self.ItemStatus |= ISF_COLORMAP;
	}

	self.state = 0;
	if(self.team) // broken, no idea why.
	{
		if(!self.cnt)
			self.cnt = 1; // item probability weight
			
		self.effects |= EF_NODRAW; // marker for item team search
		InitializeEntity(self, Item_FindTeam, INITPRIO_FINDTARGET);
	}
	else
		Item_Reset();
        
    Net_LinkEntity(self, FALSE, 0, ItemSend);

	// call this hook after everything else has been done
	if(MUTATOR_CALLHOOK(Item_Spawn))
	{
		startitem_failed = TRUE;
		remove(self);
		return;
	}
}

float weaponswapping;
float internalteam;

void weapon_defaultspawnfunc(float wpn)
{
	entity e;
	float t;
	var .float ammofield;
	string s;
	entity oldself;
	float i, j;
	float f;

	if(self.classname != "droppedweapon" && self.classname != "replacedweapon")
	{
		e = get_weaponinfo(wpn);

		if(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
		{
			objerror("Attempted to spawn a mutator-blocked weapon rejected");
			startitem_failed = TRUE;
			return;
		}

		s = W_Apply_Weaponreplace(e.netname);
		ret_string = s;
		other = e;
		MUTATOR_CALLHOOK(SetWeaponreplace);
		s = ret_string;
		if(s == "")
		{
			remove(self);
			startitem_failed = TRUE;
			return;
		}
		t = tokenize_console(s);
		if(t >= 2)
		{
			self.team = --internalteam;
			oldself = self;
			for(i = 1; i < t; ++i)
			{
				s = argv(i);
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					e = get_weaponinfo(j);
					if(e.netname == s)
					{
						self = spawn();
						copyentity(oldself, self);
						self.classname = "replacedweapon";
						weapon_defaultspawnfunc(j);
						break;
					}
				}
				if(j > WEP_LAST)
				{
					print("The weapon replace list for ", oldself.classname, " contains an unknown weapon ", s, ". Skipped.\n");
				}
			}
			self = oldself;
		}
		if(t >= 1) // always the case!
		{
			s = argv(0);
			wpn = 0;
			for(j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if(e.netname == s)
				{
					wpn = j;
					break;
				}
			}
			if(j > WEP_LAST)
			{
				print("The weapon replace list for ", self.classname, " contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
		if(wpn == 0)
		{
			remove(self);
			startitem_failed = TRUE;
			return;
		}
	}

	e = get_weaponinfo(wpn);

	if(!self.respawntime)
	{
		if(e.weapons & WEPSET_SUPERWEAPONS)
		{
			self.respawntime = g_pickup_respawntime_superweapon;
			self.respawntimejitter = g_pickup_respawntimejitter_superweapon;
		}
		else
		{
			self.respawntime = g_pickup_respawntime_weapon;
			self.respawntimejitter = g_pickup_respawntimejitter_weapon;
		}
	}

	if(e.weapons & WEPSET_SUPERWEAPONS)
		if(!self.superweapons_finished)
			self.superweapons_finished = autocvar_g_balance_superweapons_time;

	if(e.items)
	{
		for(i = 0, j = 1; i < 24; ++i, j *= 2)
		{
			if(e.items & j)
			{
				ammofield = Item_CounterField(j);
				if(!self.ammofield)
					self.ammofield = cvar(strcat("g_pickup_", Item_CounterFieldName(j), "_weapon"));
			}
		}
	}

	// pickup anyway
	if(g_pickup_weapons_anyway)
		self.pickup_anyway = TRUE;

	f = FL_WEAPON;

	// no weapon-stay on superweapons
	if(e.weapons & WEPSET_SUPERWEAPONS)
		f |= FL_NO_WEAPON_STAY;

	// weapon stay isn't supported for teamed weapons
	if(self.team)
		f |= FL_NO_WEAPON_STAY;

	StartItem(e.model, "weapons/weaponpickup.wav", self.respawntime, self.respawntimejitter, e.message, 0, e.weapon, f, weapon_pickupevalfunc, e.bot_pickupbasevalue);
	if (self.modelindex) // don't precache if self was removed
		weapon_action(e.weapon, WR_PRECACHE);
}

void spawnfunc_weapon_shotgun (void);
void spawnfunc_weapon_uzi (void) {
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_SHOTGUN);
		return;
	}
	weapon_defaultspawnfunc(WEP_UZI);
}

void spawnfunc_weapon_shotgun (void) {
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_UZI);
		return;
	}
	weapon_defaultspawnfunc(WEP_SHOTGUN);
}

void spawnfunc_weapon_nex (void)
{
	weapon_defaultspawnfunc(WEP_NEX);
}

void spawnfunc_weapon_minstanex (void)
{
	weapon_defaultspawnfunc(WEP_MINSTANEX);
}

void spawnfunc_weapon_rocketlauncher (void)
{
	weapon_defaultspawnfunc(WEP_ROCKET_LAUNCHER);
}

void spawnfunc_item_rockets (void) {
	if(!self.ammo_rockets)
		self.ammo_rockets = g_pickup_rockets;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/a_rockets.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "rockets", IT_ROCKETS, 0, 0, commodity_pickupevalfunc, 3000);
}

void spawnfunc_item_shells (void);
void spawnfunc_item_bullets (void) {
	if(!weaponswapping)
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weaponswapping = TRUE;
		spawnfunc_item_shells();
		weaponswapping = FALSE;
		return;
	}

	if(!self.ammo_nails)
		self.ammo_nails = g_pickup_nails;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/a_bullets.mdl", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "bullets", IT_NAILS, 0, 0, commodity_pickupevalfunc, 2000);
}

void spawnfunc_item_cells (void) {
	if(!self.ammo_cells)
		self.ammo_cells = g_pickup_cells;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/a_cells.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "cells", IT_CELLS, 0, 0, commodity_pickupevalfunc, 2000);
}

void spawnfunc_item_shells (void) {
	if(!weaponswapping)
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weaponswapping = TRUE;
		spawnfunc_item_bullets();
		weaponswapping = FALSE;
		return;
	}

	if(!self.ammo_shells)
		self.ammo_shells = g_pickup_shells;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/a_shells.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "shells", IT_SHELLS, 0, 0, commodity_pickupevalfunc, 500);
}

void spawnfunc_item_armor_small (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorsmall;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorsmall_max;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_armorsmall_anyway;
	StartItem ("models/items/item_armor_small.md3", "misc/armor1.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "5 Armor", IT_ARMOR_SHARD, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_armor_medium (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armormedium;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armormedium_max;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_armormedium_anyway;
	StartItem ("models/items/item_armor_medium.md3", "misc/armor10.wav", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "25 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_armor_big (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorbig;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorbig_max;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_armorbig_anyway;
	StartItem ("models/items/item_armor_big.md3", "misc/armor17_5.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "50 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, 20000);
}

void spawnfunc_item_armor_large (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorlarge;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorlarge_max;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_armorlarge_anyway;
	StartItem ("models/items/item_armor_large.md3", "misc/armor25.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "100 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
}

void spawnfunc_item_health_small (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthsmall_max;
	if(!self.health)
		self.health = g_pickup_healthsmall;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_healthsmall_anyway;
	StartItem ("models/items/g_h1.md3", "misc/minihealth.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "5 Health", IT_5HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_health_medium (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthmedium_max;
	if(!self.health)
		self.health = g_pickup_healthmedium;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_healthmedium_anyway;
	StartItem ("models/items/g_h25.md3", "misc/mediumhealth.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "25 Health", IT_25HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_health_large (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthlarge_max;
	if(!self.health)
		self.health = g_pickup_healthlarge;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_healthlarge_anyway;
	StartItem ("models/items/g_h50.md3", "misc/mediumhealth.wav", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "50 Health", IT_25HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_health_mega (void) {
		if(!self.max_health)
			self.max_health = g_pickup_healthmega_max;
		if(!self.health)
			self.health = g_pickup_healthmega;
		if(!self.pickup_anyway)
			self.pickup_anyway = g_pickup_healthmega_anyway;
		StartItem ("models/items/g_h100.md3", "misc/megahealth.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "100 Health", IT_HEALTH, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
}

// support old misnamed entities
void spawnfunc_item_armor1() { spawnfunc_item_armor_small(); }  // FIXME: in Quake this is green armor, in Xonotic maps it is an armor shard
void spawnfunc_item_armor25() { spawnfunc_item_armor_large(); }
void spawnfunc_item_health1() { spawnfunc_item_health_small(); }
void spawnfunc_item_health25() { spawnfunc_item_health_medium(); }
void spawnfunc_item_health100() { spawnfunc_item_health_mega(); }

void spawnfunc_item_strength (void) {
		precache_sound("weapons/strength_fire.wav");
		if(!self.strength_finished)
			self.strength_finished = autocvar_g_balance_powerup_strength_time;
		StartItem ("models/items/g_strength.md3", "misc/powerup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Strength Powerup", IT_STRENGTH, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
}

void spawnfunc_item_invincible (void) {
		if(!self.invincible_finished)
			self.invincible_finished = autocvar_g_balance_powerup_invincible_time;
		StartItem ("models/items/g_invincible.md3", "misc/powerup_shield.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Shield", IT_INVINCIBLE, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
}

// compatibility:
void spawnfunc_item_quad (void) {self.classname = "item_strength";spawnfunc_item_strength();}

float GiveItems(entity e, float beginarg, float endarg);
void target_items_use (void)
{
	if(activator.classname == "droppedweapon")
	{
		EXACTTRIGGER_TOUCH;
		remove(activator);
		return;
	}

	if not(IS_PLAYER(activator))
		return;
	if(activator.deadflag != DEAD_NO)
		return;
	EXACTTRIGGER_TOUCH;

	entity e;
	for(e = world; (e = find(e, classname, "droppedweapon")); )
		if(e.enemy == activator)
			remove(e);

	if(GiveItems(activator, 0, tokenize_console(self.netname)))
		centerprint(activator, self.message);
}

void spawnfunc_target_items (void)
{
	float n, i, j;
	entity e;

	self.use = target_items_use;
	if(!self.strength_finished)
		self.strength_finished = autocvar_g_balance_powerup_strength_time;
	if(!self.invincible_finished)
		self.invincible_finished = autocvar_g_balance_powerup_invincible_time;
	if(!self.superweapons_finished)
		self.superweapons_finished = autocvar_g_balance_superweapons_time;

	precache_sound("misc/itempickup.wav");
	precache_sound("misc/megahealth.wav");
	precache_sound("misc/armor25.wav");
	precache_sound("misc/powerup.wav");
	precache_sound("misc/poweroff.wav");
	precache_sound("weapons/weaponpickup.wav");

	n = tokenize_console(self.netname);
	if(argv(0) == "give")
	{
		self.netname = substring(self.netname, argv_start_index(1), argv_end_index(-1) - argv_start_index(1));
	}
	else
	{
		for(i = 0; i < n; ++i)
		{
			if     (argv(i) == "unlimited_ammo")         self.items |= IT_UNLIMITED_AMMO;
			else if(argv(i) == "unlimited_weapon_ammo")  self.items |= IT_UNLIMITED_WEAPON_AMMO;
			else if(argv(i) == "unlimited_superweapons") self.items |= IT_UNLIMITED_SUPERWEAPONS;
			else if(argv(i) == "strength")               self.items |= IT_STRENGTH;
			else if(argv(i) == "invincible")             self.items |= IT_INVINCIBLE;
			else if(argv(i) == "superweapons")           self.items |= IT_SUPERWEAPON;
			else if(argv(i) == "jetpack")                self.items |= IT_JETPACK;
			else if(argv(i) == "fuel_regen")             self.items |= IT_FUEL_REGEN;
			else
			{
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					e = get_weaponinfo(j);
					if(argv(i) == e.netname)
					{
						self.weapons |= WepSet_FromWeapon(j);
						if(self.spawnflags == 0 || self.spawnflags == 2)
							weapon_action(e.weapon, WR_PRECACHE);
						break;
					}
				}
				if(j > WEP_LAST)
					print("target_items: invalid item ", argv(i), "\n");
			}
		}

		string itemprefix, valueprefix;
		if(self.spawnflags == 0)
		{
			itemprefix = "";
			valueprefix = "";
		}
		else if(self.spawnflags == 1)
		{
			itemprefix = "max ";
			valueprefix = "max ";
		}
		else if(self.spawnflags == 2)
		{
			itemprefix = "min ";
			valueprefix = "min ";
		}
		else if(self.spawnflags == 4)
		{
			itemprefix = "minus ";
			valueprefix = "max ";
		}
		else
		{
			error("invalid spawnflags");
#ifdef GMQCC
			itemprefix = string_null;
			valueprefix = string_null;
#endif
		}

		self.netname = "";
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_UNLIMITED_WEAPON_AMMO), "unlimited_weapon_ammo");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_UNLIMITED_SUPERWEAPONS), "unlimited_superweapons");
		self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, self.strength_finished * !!(self.items & IT_STRENGTH), "strength");
		self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, self.invincible_finished * !!(self.items & IT_INVINCIBLE), "invincible");
		self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, self.superweapons_finished * !!(self.items & IT_SUPERWEAPON), "superweapons");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_JETPACK), "jetpack");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_FUEL_REGEN), "fuel_regen");
		if(self.ammo_shells != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_shells), "shells");
		if(self.ammo_nails != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_nails), "nails");
		if(self.ammo_rockets != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_rockets), "rockets");
		if(self.ammo_cells != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_cells), "cells");
		if(self.ammo_fuel != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_fuel), "fuel");
		if(self.health != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.health), "health");
		if(self.armorvalue != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.health), "armor");
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(e.weapon)
				self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.weapons & WepSet_FromWeapon(j)), e.netname);
		}
	}
	self.netname = strzone(self.netname);
	//print(self.netname, "\n");

	n = tokenize_console(self.netname);
	for(i = 0; i < n; ++i)
	{
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(argv(i) == e.netname)
			{
				weapon_action(e.weapon, WR_PRECACHE);
				break;
			}
		}
	}
}

void spawnfunc_item_fuel(void)
{
	if(!self.ammo_fuel)
		self.ammo_fuel = g_pickup_fuel;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/g_fuel.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "Fuel", IT_FUEL, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_fuel_regen(void)
{
	if(start_items & IT_FUEL_REGEN)
	{
		spawnfunc_item_fuel();
		return;
	}
	StartItem ("models/items/g_fuelregen.md3", "misc/itempickup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Fuel regenerator", IT_FUEL_REGEN, 0, FL_POWERUP, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_jetpack(void)
{
	if(g_grappling_hook)
		return; // sorry, but these two can't coexist (same button); spawn fuel instead
	if(!self.ammo_fuel)
		self.ammo_fuel = g_pickup_fuel_jetpack;
	if(start_items & IT_JETPACK)
	{
		spawnfunc_item_fuel();
		return;
	}
	StartItem ("models/items/g_jetpack.md3", "misc/itempickup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Jet pack", IT_JETPACK, 0, FL_POWERUP, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}


#define OP_SET 0
#define OP_MIN 1
#define OP_MAX 2
#define OP_PLUS 3
#define OP_MINUS 4

float GiveWeapon(entity e, float wpn, float op, float val)
{
	WepSet v0, v1;
	v0 = (e.weapons & WepSet_FromWeapon(wpn));
	switch(op)
	{
		case OP_SET:
			if(val > 0)
				e.weapons |= WepSet_FromWeapon(wpn);
			else
				e.weapons &= ~WepSet_FromWeapon(wpn);
			break;
		case OP_MIN:
		case OP_PLUS:
			if(val > 0)
				e.weapons |= WepSet_FromWeapon(wpn);
			break;
		case OP_MAX:
			if(val <= 0)
				e.weapons &= ~WepSet_FromWeapon(wpn);
			break;
		case OP_MINUS:
			if(val > 0)
				e.weapons &= ~WepSet_FromWeapon(wpn);
			break;
	}
	v1 = (e.weapons & WepSet_FromWeapon(wpn));
	return (v0 != v1);
}

float GiveBit(entity e, .float fld, float bit, float op, float val)
{
	float v0, v1;
	v0 = (e.fld & bit);
	switch(op)
	{
		case OP_SET:
			if(val > 0)
				e.fld |= bit;
			else
				e.fld &= ~bit;
			break;
		case OP_MIN:
		case OP_PLUS:
			if(val > 0)
				e.fld |= bit;
			break;
		case OP_MAX:
			if(val <= 0)
				e.fld &= ~bit;
			break;
		case OP_MINUS:
			if(val > 0)
				e.fld &= ~bit;
			break;
	}
	v1 = (e.fld & bit);
	return (v0 != v1);
}

float GiveValue(entity e, .float fld, float op, float val)
{
	float v0, v1;
	v0 = e.fld;
	switch(op)
	{
		case OP_SET:
			e.fld = val;
			break;
		case OP_MIN:
			e.fld = max(e.fld, val); // min 100 cells = at least 100 cells
			break;
		case OP_MAX:
			e.fld = min(e.fld, val);
			break;
		case OP_PLUS:
			e.fld += val;
			break;
		case OP_MINUS:
			e.fld -= val;
			break;
	}
	v1 = e.fld;
	return (v0 != v1);
}

void GiveSound(entity e, float v0, float v1, float t, string snd_incr, string snd_decr)
{
	if(v1 == v0)
		return;
	if(v1 <= v0 - t)
	{
		if(snd_decr != "")
			sound (e, CH_TRIGGER, snd_decr, VOL_BASE, ATTEN_NORM);
	}
	else if(v0 >= v0 + t)
	{
		if(snd_incr != "")
			sound (e, CH_TRIGGER, snd_incr, VOL_BASE, ATTEN_NORM);
	}
}

void GiveRot(entity e, float v0, float v1, .float rotfield, float rottime, .float regenfield, float regentime)
{
	if(v0 < v1)
		e.rotfield = max(e.rotfield, time + rottime);
	else if(v0 > v1)
		e.regenfield = max(e.regenfield, time + regentime);
}

#define PREGIVE_WEAPONS(e) WepSet save_weapons; save_weapons = e.weapons
#define PREGIVE(e,f) float save_##f; save_##f = (e).f
#define POSTGIVE_WEAPON(e,b,snd_incr,snd_decr) GiveSound((e), !!(save_weapons & WepSet_FromWeapon(b)), !!(e.weapons & WepSet_FromWeapon(b)), 0, snd_incr, snd_decr)
#define POSTGIVE_BIT(e,f,b,snd_incr,snd_decr) GiveSound((e), save_##f & (b), (e).f & (b), 0, snd_incr, snd_decr)
#define POSTGIVE_VALUE(e,f,t,snd_incr,snd_decr) GiveSound((e), save_##f, (e).f, t, snd_incr, snd_decr)
#define POSTGIVE_VALUE_ROT(e,f,t,rotfield,rottime,regenfield,regentime,snd_incr,snd_decr) GiveRot((e), save_##f, (e).f, rotfield, rottime, regenfield, regentime); GiveSound((e), save_##f, (e).f, t, snd_incr, snd_decr)

float GiveItems(entity e, float beginarg, float endarg)
{
	float got, i, j, val, op;
	float _switchweapon;
	entity wi;
	string cmd;

	val = 999;
	op = OP_SET;

	got = 0;

	_switchweapon = FALSE;
	if (e.autoswitch)
		if (e.switchweapon == w_getbestweapon(e))
			_switchweapon = TRUE;

	e.strength_finished = max(0, e.strength_finished - time);
	e.invincible_finished = max(0, e.invincible_finished - time);
	e.superweapons_finished = max(0, e.superweapons_finished - time);
	
	PREGIVE(e, items);
	PREGIVE_WEAPONS(e);
	PREGIVE(e, strength_finished);
	PREGIVE(e, invincible_finished);
	PREGIVE(e, superweapons_finished);
	PREGIVE(e, ammo_nails);
	PREGIVE(e, ammo_cells);
	PREGIVE(e, ammo_shells);
	PREGIVE(e, ammo_rockets);
	PREGIVE(e, ammo_fuel);
	PREGIVE(e, armorvalue);
	PREGIVE(e, health);

	for(i = beginarg; i < endarg; ++i)
	{
		cmd = argv(i);

		if(cmd == "0" || stof(cmd))
		{
			val = stof(cmd);
			continue;
		}
		switch(cmd)
		{
			case "no":
				op = OP_MAX;
				val = 0;
				continue;
			case "max":
				op = OP_MAX;
				continue;
			case "min":
				op = OP_MIN;
				continue;
			case "plus":
				op = OP_PLUS;
				continue;
			case "minus":
				op = OP_MINUS;
				continue;
			case "ALL":
				got += GiveBit(e, items, IT_FUEL_REGEN, op, val);
				got += GiveValue(e, strength_finished, op, val);
				got += GiveValue(e, invincible_finished, op, val);
				got += GiveValue(e, superweapons_finished, op, val);
				got += GiveBit(e, items, IT_UNLIMITED_AMMO, op, val);
			case "all":
				got += GiveBit(e, items, IT_JETPACK, op, val);
				got += GiveValue(e, health, op, val);
				got += GiveValue(e, armorvalue, op, val);
			case "allweapons":
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					wi = get_weaponinfo(j);
					if(wi.weapon)
						if not(wi.spawnflags & WEP_FLAG_MUTATORBLOCKED)
							got += GiveWeapon(e, j, op, val);
				}
			case "allammo":
				got += GiveValue(e, ammo_cells, op, val);
				got += GiveValue(e, ammo_shells, op, val);
				got += GiveValue(e, ammo_nails, op, val);
				got += GiveValue(e, ammo_rockets, op, val);
				got += GiveValue(e, ammo_fuel, op, val);
				break;
			case "unlimited_ammo":
				got += GiveBit(e, items, IT_UNLIMITED_AMMO, op, val);
				break;
			case "unlimited_weapon_ammo":
				got += GiveBit(e, items, IT_UNLIMITED_WEAPON_AMMO, op, val);
				break;
			case "unlimited_superweapons":
				got += GiveBit(e, items, IT_UNLIMITED_SUPERWEAPONS, op, val);
				break;
			case "jetpack":
				got += GiveBit(e, items, IT_JETPACK, op, val);
				break;
			case "fuel_regen":
				got += GiveBit(e, items, IT_FUEL_REGEN, op, val);
				break;
			case "strength":
				got += GiveValue(e, strength_finished, op, val);
				break;
			case "invincible":
				got += GiveValue(e, invincible_finished, op, val);
				break;
			case "superweapons":
				got += GiveValue(e, superweapons_finished, op, val);
				break;
			case "cells":
				got += GiveValue(e, ammo_cells, op, val);
				break;
			case "shells":
				got += GiveValue(e, ammo_shells, op, val);
				break;
			case "nails":
			case "bullets":
				got += GiveValue(e, ammo_nails, op, val);
				break;
			case "rockets":
				got += GiveValue(e, ammo_rockets, op, val);
				break;
			case "health":
				got += GiveValue(e, health, op, val);
				break;
			case "armor":
				got += GiveValue(e, armorvalue, op, val);
				break;
			case "fuel":
				got += GiveValue(e, ammo_fuel, op, val);
				break;
			default:
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					wi = get_weaponinfo(j);
					if(cmd == wi.netname)
					{
						got += GiveWeapon(e, j, op, val);
						break;
					}
				}
				if(j > WEP_LAST)
					print("give: invalid item ", cmd, "\n");
				break;
		}
		val = 999;
		op = OP_SET;
	}

	POSTGIVE_BIT(e, items, IT_FUEL_REGEN, "misc/itempickup.wav", string_null);
	POSTGIVE_BIT(e, items, IT_UNLIMITED_SUPERWEAPONS, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_BIT(e, items, IT_UNLIMITED_WEAPON_AMMO, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_BIT(e, items, IT_JETPACK, "misc/itempickup.wav", string_null);
	for(j = WEP_FIRST; j <= WEP_LAST; ++j)
	{
		wi = get_weaponinfo(j);
		if(wi.weapon)
		{
			POSTGIVE_WEAPON(e, j, "weapons/weaponpickup.wav", string_null);
			if not(save_weapons & WepSet_FromWeapon(j))
				if(e.weapons & WepSet_FromWeapon(j))
					weapon_action(wi.weapon, WR_PRECACHE);
		}
	}
	POSTGIVE_VALUE(e, strength_finished, 1, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_VALUE(e, invincible_finished, 1, "misc/powerup_shield.wav", "misc/poweroff.wav");
	POSTGIVE_VALUE(e, ammo_nails, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_cells, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_shells, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_rockets, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE_ROT(e, ammo_fuel, 1, pauserotfuel_finished, autocvar_g_balance_pause_fuel_rot, pauseregen_finished, autocvar_g_balance_pause_fuel_regen, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE_ROT(e, armorvalue, 1, pauserotarmor_finished, autocvar_g_balance_pause_armor_rot, pauseregen_finished, autocvar_g_balance_pause_health_regen, "misc/armor25.wav", string_null);
	POSTGIVE_VALUE_ROT(e, health, 1, pauserothealth_finished, autocvar_g_balance_pause_health_rot, pauseregen_finished, autocvar_g_balance_pause_health_regen, "misc/megahealth.wav", string_null);

	if(e.superweapons_finished <= 0)
		if(self.weapons & WEPSET_SUPERWEAPONS)
			e.superweapons_finished = autocvar_g_balance_superweapons_time;

	if(e.strength_finished <= 0)
		e.strength_finished = 0;
	else
		e.strength_finished += time;
	if(e.invincible_finished <= 0)
		e.invincible_finished = 0;
	else
		e.invincible_finished += time;
	if(e.superweapons_finished <= 0)
		e.superweapons_finished = 0;
	else
		e.superweapons_finished += time;

	if not(e.weapons & WepSet_FromWeapon(e.switchweapon))
		_switchweapon = TRUE;
	if(_switchweapon)
		W_SwitchWeapon_Force(e, w_getbestweapon(e));

	return got;
}
#endif
