void W_TriggerReload()
{
    weapon_action(self.weapon, WR_RELOAD);
}

// switch between weapons
void W_SwitchWeapon(float imp)
{
	if (self.switchweapon != imp)
	{
		if (client_hasweapon(self, imp, TRUE, TRUE))
			W_SwitchWeapon_Force(self, imp);
		else
			self.selectweapon = imp; // update selectweapon ANYWAY
	}
	else
	{
		W_TriggerReload();
	}
}

.float weaponcomplainindex;
float W_GetCycleWeapon(entity pl, string weaponorder, float dir, float imp, float complain, float skipmissing)
{
	// We cannot tokenize in this function, as GiveItems calls this
	// function. Thus we must use car/cdr.
	float weaponwant, first_valid, prev_valid, switchtonext, switchtolast, c;
	string rest;
	switchtonext = switchtolast = 0;
	first_valid = prev_valid = 0;
	float weaponcur;

	if(skipmissing || pl.selectweapon == 0)
		weaponcur = pl.switchweapon;
	else
		weaponcur = pl.selectweapon;

	if(dir == 0)
		switchtonext = 1;

	c = 0;

	rest = weaponorder;
	while(rest != "")
	{
		weaponwant = stof(car(rest)); rest = cdr(rest);
		if(imp >= 0)
			if((get_weaponinfo(weaponwant)).impulse != imp)
				continue;

		++c;

		if(!skipmissing || client_hasweapon(pl, weaponwant, TRUE, FALSE))
		{
			if(switchtonext)
				return weaponwant;
			if(!first_valid)
				first_valid = weaponwant;
			if(weaponwant == weaponcur)
			{
				if(dir >= 0)
					switchtonext = 1;
				else if(prev_valid)
					return prev_valid;
				else
					switchtolast = 1;
			}
			prev_valid = weaponwant;
		}
	}
	if(first_valid)
	{
		if(switchtolast)
			return prev_valid;
		else
			return first_valid;
	}
	// complain (but only for one weapon on the button that has been pressed)
	if(complain)
	{
		self.weaponcomplainindex += 1;
		c = mod(self.weaponcomplainindex, c) + 1;
		rest = weaponorder;
		while(rest != "")
		{
			weaponwant = stof(car(rest)); rest = cdr(rest);
			if(imp >= 0)
				if((get_weaponinfo(weaponwant)).impulse != imp)
					continue;

			--c;
			if(c == 0)
			{
				client_hasweapon(pl, weaponwant, TRUE, TRUE);
				break;
			}
		}
	}
	return 0;
}

void W_CycleWeapon(string weaponorder, float dir)
{
	float w;
	w = W_GetCycleWeapon(self, weaponorder, dir, -1, 1, TRUE);
	if(w > 0)
		W_SwitchWeapon(w);
}

void W_NextWeaponOnImpulse(float imp)
{
	float w;
	w = W_GetCycleWeapon(self, self.cvar_cl_weaponpriority, +1, imp, 1, (self.cvar_cl_weaponimpulsemode == 0));
	if(w > 0)
		W_SwitchWeapon(w);
}

// next weapon
void W_NextWeapon(float list)
{
	if(list == 0)
		W_CycleWeapon(weaponorder_byid, -1);
	else if(list == 1)
		W_CycleWeapon(self.weaponorder_byimpulse, -1);
	else if(list == 2)
		W_CycleWeapon(self.cvar_cl_weaponpriority, -1);
}

// prev weapon
void W_PreviousWeapon(float list)
{
	if(list == 0)
		W_CycleWeapon(weaponorder_byid, +1);
	else if(list == 1)
		W_CycleWeapon(self.weaponorder_byimpulse, +1);
	else if(list == 2)
		W_CycleWeapon(self.cvar_cl_weaponpriority, +1);
}

// previously used if exists and has ammo, (second) best otherwise
void W_LastWeapon()
{
	if(client_hasweapon(self, self.cnt, TRUE, FALSE))
		W_SwitchWeapon(self.cnt);
	else
		W_SwitchToOtherWeapon(self);
}

float w_getbestweapon(entity e)
{
	return W_GetCycleWeapon(e, e.cvar_cl_weaponpriority, 0, -1, FALSE, TRUE);
}

// generic weapons table
// TODO should they be macros instead?
float weapon_action(float wpn, float wrequest)
{
	return (get_weaponinfo(wpn)).weapon_func(wrequest);
}

.float savenextthink;
void thrown_wep_think()
{
	self.nextthink = time;
	if(self.oldorigin != self.origin)
	{
		self.SendFlags |= ISF_LOCATION;
		self.oldorigin = self.origin;
	}
	self.owner = world;
	float timeleft = self.savenextthink - time;
	if(timeleft > 1)
		SUB_SetFade(self, self.savenextthink - 1, 1);
	else if(timeleft > 0)
		SUB_SetFade(self, time, timeleft);
	else
		SUB_VanishOrRemove(self);
}

// returns amount of ammo used as string, or -1 for failure, or 0 for no ammo count
string W_ThrowNewWeapon(entity own, float wpn, float doreduce, vector org, vector velo)
{
	entity oldself, wep;
	float wa, thisammo, i, j;
	string s;
	var .float ammofield;

	wep = spawn();

	setorigin(wep, org);
	wep.classname = "droppedweapon";
	wep.velocity = velo;
	wep.owner = wep.enemy = own;
	wep.flags |= FL_TOSSED;
	wep.colormap = own.colormap;

	if(WepSet_FromWeapon(wpn) & WEPSET_SUPERWEAPONS)
	{
		if(own.items & IT_UNLIMITED_SUPERWEAPONS)
		{
			wep.superweapons_finished = time + autocvar_g_balance_superweapons_time;
		}
		else
		{
			float superweapons = 1;
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
				if(WepSet_FromWeapon(i) & WEPSET_SUPERWEAPONS)
					if(own.weapons & WepSet_FromWeapon(i))
						++superweapons;
			if(superweapons <= 1)
			{
				wep.superweapons_finished = own.superweapons_finished;
				own.superweapons_finished = 0;
			}
			else
			{
				float timeleft = own.superweapons_finished - time;
				float weptimeleft = timeleft / superweapons;
				wep.superweapons_finished = time + weptimeleft;
				own.superweapons_finished -= weptimeleft;
			}
		}
	}

	wa = W_AmmoItemCode(wpn);
	if(wa == 0)
	{
		oldself = self;
		self = wep;
		weapon_defaultspawnfunc(wpn);
		self = oldself;
		if(startitem_failed)
			return string_null;
		wep.glowmod = own.weaponentity_glowmod;
		wep.think = thrown_wep_think;
		wep.savenextthink = wep.nextthink;
		wep.nextthink = min(wep.nextthink, time + 0.5);
		wep.pickup_anyway = TRUE; // these are ALWAYS pickable
		return "";
	}
	else
	{
		s = "";
		oldself = self;
		self = wep;
		weapon_defaultspawnfunc(wpn);
		self = oldself;
		if(startitem_failed)
			return string_null;
		if(doreduce && g_weapon_stay == 2)
		{
			for(i = 0, j = 1; i < 24; ++i, j *= 2)
			{
				if(wa & j)
				{
					ammofield = Item_CounterField(j);

					// if our weapon is loaded, give its load back to the player
					if(self.(weapon_load[self.weapon]) > 0)
					{
						own.ammofield += self.(weapon_load[self.weapon]);
						self.(weapon_load[self.weapon]) = -1; // schedule the weapon for reloading
					}

					wep.ammofield = 0;
				}
			}
		}
		else if(doreduce)
		{
			for(i = 0, j = 1; i < 24; ++i, j *= 2)
			{
				if(wa & j)
				{
					ammofield = Item_CounterField(j);

					// if our weapon is loaded, give its load back to the player
					if(self.(weapon_load[self.weapon]) > 0)
					{
						own.ammofield += self.(weapon_load[self.weapon]);
						self.(weapon_load[self.weapon]) = -1; // schedule the weapon for reloading
					}

					thisammo = min(own.ammofield, wep.ammofield);
					wep.ammofield = thisammo;
					own.ammofield -= thisammo;
					s = strcat(s, " and ", ftos(thisammo), " ", Item_CounterFieldName(j));
				}
			}
			s = substring(s, 5, -1);
		}
		wep.glowmod = own.weaponentity_glowmod;
		wep.think = thrown_wep_think;
		wep.savenextthink = wep.nextthink;
		wep.nextthink = min(wep.nextthink, time + 0.5);
		wep.pickup_anyway = TRUE; // these are ALWAYS pickable

		return s;
	}
}

float W_IsWeaponThrowable(float w)
{
	float wa;

	if (!autocvar_g_pickup_items)
		return 0;
	if (g_weaponarena)
		return 0;
    if(w == 0)
        return 0;

	wa = W_AmmoItemCode(w);
	if(start_weapons & WepSet_FromWeapon(w))
	{
		// start weapons that take no ammo can't be dropped (this prevents dropping the laser, as long as it continues to use no ammo)
		if(start_items & IT_UNLIMITED_WEAPON_AMMO)
			return 0;
		if(wa == 0)
			return 0;
	}

	return 1;
}

// toss current weapon
void W_ThrowWeapon(vector velo, vector delta, float doreduce)
{
	float w;
	string a;

	w = self.weapon;
	if (w == 0)
		return; // just in case
	if(self.frozen)
		return;
	if(self.vehicle)
		return;
	if(MUTATOR_CALLHOOK(ForbidThrowCurrentWeapon))
		return;
	if(!autocvar_g_weapon_throwable)
		return;
	if(self.weaponentity.state != WS_READY)
		return;
	if(!W_IsWeaponThrowable(w))
		return;

	if(!(self.weapons & WepSet_FromWeapon(w)))
		return;
	self.weapons &= ~WepSet_FromWeapon(w);

	W_SwitchWeapon_Force(self, w_getbestweapon(self));
	a = W_ThrowNewWeapon(self, w, doreduce, self.origin + delta, velo);

	if (!a) return;
	Send_Notification(NOTIF_ONE, self, MSG_MULTI, ITEM_WEAPON_DROP, a, w);
}

float forbidWeaponUse(entity player)
{
	if(time < game_starttime && !autocvar_sv_ready_restart_after_countdown)
		return 1;
	if(player.player_blocked)
		return 3;
	if(player.weapon_blocked)
		return 4;
	if(player.frozen)
		return 5;
	if(round_handler_IsActive() && !round_handler_IsRoundStarted())
		return 2;
	return 0;
}

void W_WeaponFrame()
{
	vector fo, ri, up;

	if (frametime)
		self.weapon_frametime = frametime;

	if (!self.weaponentity || self.health < 1)
		return; // Dead player can't use weapons and injure impulse commands

	float forbid_weaponuse = forbidWeaponUse(self);

	if(forbid_weaponuse && (!g_minstagib || forbid_weaponuse != 2))
	if(self.weaponentity.state != WS_CLEAR)
	{
		w_ready();
		return;
	}

	if(!self.switchweapon)
	{
		self.weapon = 0;
		self.switchingweapon = 0;
		self.weaponentity.state = WS_CLEAR;
		self.weaponname = "";
		self.items &= ~IT_AMMO;
		return;
	}

	makevectors(self.v_angle);
	fo = v_forward; // save them in case the weapon think functions change it
	ri = v_right;
	up = v_up;

	// Change weapon
	if (self.weapon != self.switchweapon)
	{
		if (self.weaponentity.state == WS_CLEAR)
		{
			// end switching!
			self.switchingweapon = self.switchweapon;

			entity newwep = get_weaponinfo(self.switchweapon);

			//setanim(self, self.anim_draw, FALSE, TRUE, TRUE);
			self.weaponentity.state = WS_RAISE;
			weapon_action(self.switchweapon, WR_SETUP);

			// set our clip load to the load of the weapon we switched to, if it's reloadable
			if(newwep.spawnflags & WEP_FLAG_RELOADABLE && cvar(strcat("g_balance_", newwep.netname, "_reload_ammo"))) // prevent accessing undefined cvars
			{
				self.clip_load = self.(weapon_load[self.switchweapon]);
				self.clip_size = cvar(strcat("g_balance_", newwep.netname, "_reload_ammo"));
			}
			else
				self.clip_load = self.clip_size = 0;

			// VorteX: add player model weapon select frame here
			// setcustomframe(PlayerWeaponRaise);
			weapon_thinkf(WFRAME_IDLE, cvar(sprintf("g_balance_%s_switchdelay_raise", newwep.netname)), w_ready);
			//printf("W_WeaponFrame(): cvar: %s, value: %f\n", sprintf("g_balance_%s_switchdelay_raise", newwep.netname), cvar(sprintf("g_balance_%s_switchdelay_raise", newwep.netname)));
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');
		}
		else if (self.weaponentity.state == WS_DROP)
		{
			// in dropping phase we can switch at any time
			self.switchingweapon = self.switchweapon;
		}
		else if (self.weaponentity.state == WS_READY)
		{
			// start switching!
			self.switchingweapon = self.switchweapon;

			entity oldwep = get_weaponinfo(self.weapon);

#ifndef INDEPENDENT_ATTACK_FINISHED
			if(ATTACK_FINISHED(self) <= time + self.weapon_frametime * 0.5)
			{
#endif
			sound (self, CH_WEAPON_SINGLE, "weapons/weapon_switch.wav", VOL_BASE, ATTEN_NORM);
			self.weaponentity.state = WS_DROP;
			// set up weapon switch think in the future, and start drop anim
			weapon_thinkf(WFRAME_DONTCHANGE, cvar(sprintf("g_balance_%s_switchdelay_drop", oldwep.netname)), w_clear);
			//printf("W_WeaponFrame(): cvar: %s, value: %f\n", sprintf("g_balance_%s_switchdelay_drop", oldwep.netname), cvar(sprintf("g_balance_%s_switchdelay_drop", oldwep.netname)));
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);
#ifndef INDEPENDENT_ATTACK_FINISHED
			}
#endif
		}
	}

	// LordHavoc: network timing test code
	//if (self.button0)
	//	print(ftos(frametime), " ", ftos(time), " >= ", ftos(ATTACK_FINISHED(self)), " >= ", ftos(self.weapon_nextthink), "\n");

	float w;
	w = self.weapon;

	// call the think code which may fire the weapon
	// and do so multiple times to resolve framerate dependency issues if the
	// server framerate is very low and the weapon fire rate very high
	float c;
	c = 0;
	while (c < W_TICSPERFRAME)
	{
		c = c + 1;
		if(w && !(self.weapons & WepSet_FromWeapon(w)))
		{
			if(self.weapon == self.switchweapon)
				W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w = 0;
		}

		v_forward = fo;
		v_right = ri;
		v_up = up;

		if(w && self.weapon == self.switchweapon)
			weapon_action(self.weapon, WR_THINK);
		else
			weapon_action(self.weapon, WR_GONETHINK);

		if (time + self.weapon_frametime * 0.5 >= self.weapon_nextthink)
		{
			if(self.weapon_think)
			{
				v_forward = fo;
				v_right = ri;
				v_up = up;
				self.weapon_think();
			}
			else
				bprint("\{1}^1ERROR: undefined weapon think function for ", self.netname, "\n");
		}
	}

	// don't let attack_finished fall behind when not firing (must be after weapon_setup calls!)
	//if (ATTACK_FINISHED(self) < time)
	//	ATTACK_FINISHED(self) = time;

	//if (self.weapon_nextthink < time)
	//	self.weapon_nextthink = time;

	// update currentammo incase it has changed
#if 0
	if (self.items & IT_CELLS)
		self.currentammo = self.ammo_cells;
	else if (self.items & IT_ROCKETS)
		self.currentammo = self.ammo_rockets;
	else if (self.items & IT_NAILS)
		self.currentammo = self.ammo_nails;
	else if (self.items & IT_SHELLS)
		self.currentammo = self.ammo_shells;
	else
		self.currentammo = 1;
#endif
}

string W_Apply_Weaponreplace(string in)
{
	float n = tokenize_console(in);
	string out = "";
	float i;
	for(i = 0; i < n; ++i)
	{
		string s = argv(i);
		string r = cvar_string(strcat("g_weaponreplace_", s));
		if(r == "")
			out = strcat(out, " ", s);
		else if(r != "0")
			out = strcat(out, " ", r);
	}
	return substring(out, 1, -1);
}
