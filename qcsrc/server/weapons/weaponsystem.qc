/*
===========================================================================

  CLIENT WEAPONSYSTEM CODE
  Bring back W_Weaponframe

===========================================================================
*/

.float weapon_frametime;

float W_WeaponRateFactor()
{
	float t;
	t = 1.0 / g_weaponratefactor;

	weapon_rate = t;
	MUTATOR_CALLHOOK(WeaponRateFactor);
	t = weapon_rate;

	return t;
}

// VorteX: static frame globals
const float WFRAME_DONTCHANGE = -1;
const float WFRAME_FIRE1 = 0;
const float WFRAME_FIRE2 = 1;
const float WFRAME_IDLE = 2;
const float WFRAME_RELOAD = 3;
.float wframe;

void(float fr, float t, void() func) weapon_thinkf;

float CL_Weaponentity_CustomizeEntityForClient()
{
	self.viewmodelforclient = self.owner;
	if(IS_SPEC(other))
		if(other.enemy == self.owner)
			self.viewmodelforclient = other;
	return TRUE;
}

/*
 * supported formats:
 *
 * 1. simple animated model, muzzle flash handling on h_ model:
 *    h_tuba.dpm, h_tuba.dpm.framegroups - invisible model controlling the animation
 *      tags:
 *        shot = muzzle end (shot origin, also used for muzzle flashes)
 *        shell = casings ejection point (must be on the right hand side of the gun)
 *        weapon = attachment for v_tuba.md3
 *    v_tuba.md3 - first and third person model
 *    g_tuba.md3 - pickup model
 *
 * 2. simple animated model, muzzle flash handling on v_ model:
 *    h_tuba.dpm, h_tuba.dpm.framegroups - invisible model controlling the animation
 *      tags:
 *        weapon = attachment for v_tuba.md3
 *    v_tuba.md3 - first and third person model
 *      tags:
 *        shot = muzzle end (shot origin, also used for muzzle flashes)
 *        shell = casings ejection point (must be on the right hand side of the gun)
 *    g_tuba.md3 - pickup model
 *
 * 3. fully animated model, muzzle flash handling on h_ model:
 *    h_tuba.dpm, h_tuba.dpm.framegroups - animated first person model
 *      tags:
 *        shot = muzzle end (shot origin, also used for muzzle flashes)
 *        shell = casings ejection point (must be on the right hand side of the gun)
 *        handle = corresponding to the origin of v_tuba.md3 (used for muzzle flashes)
 *    v_tuba.md3 - third person model
 *    g_tuba.md3 - pickup model
 *
 * 4. fully animated model, muzzle flash handling on v_ model:
 *    h_tuba.dpm, h_tuba.dpm.framegroups - animated first person model
 *      tags:
 *        shot = muzzle end (shot origin)
 *        shell = casings ejection point (must be on the right hand side of the gun)
 *    v_tuba.md3 - third person model
 *      tags:
 *        shot = muzzle end (for muzzle flashes)
 *    g_tuba.md3 - pickup model
 */

// writes:
//   self.origin, self.angles
//   self.weaponentity
//   self.movedir, self.view_ofs
//   attachment stuff
//   anim stuff
// to free:
//   call again with ""
//   remove the ent
void CL_WeaponEntity_SetModel(string name)
{
	float v_shot_idx;
	if (name != "")
	{
		// if there is a child entity, hide it until we're sure we use it
		if (self.weaponentity)
			self.weaponentity.model = "";
		setmodel(self, strcat("models/weapons/v_", name, ".md3")); // precision set below
		v_shot_idx = gettagindex(self, "shot"); // used later
		if(!v_shot_idx)
			v_shot_idx = gettagindex(self, "tag_shot");

		setmodel(self, strcat("models/weapons/h_", name, ".iqm")); // precision set below
		// preset some defaults that work great for renamed zym files (which don't need an animinfo)
		self.anim_fire1  = animfixfps(self, '0 1 0.01', '0 0 0');
		self.anim_fire2  = animfixfps(self, '1 1 0.01', '0 0 0');
		self.anim_idle   = animfixfps(self, '2 1 0.01', '0 0 0');
		self.anim_reload = animfixfps(self, '3 1 0.01', '0 0 0');

		// if we have a "weapon" tag, let's attach the v_ model to it ("invisible hand" style model)
		// if we don't, this is a "real" animated model
		if(gettagindex(self, "weapon"))
		{
			if (!self.weaponentity)
				self.weaponentity = spawn();
			setmodel(self.weaponentity, strcat("models/weapons/v_", name, ".md3")); // precision does not matter
			setattachment(self.weaponentity, self, "weapon");
		}
		else if(gettagindex(self, "tag_weapon"))
		{
			if (!self.weaponentity)
				self.weaponentity = spawn();
			setmodel(self.weaponentity, strcat("models/weapons/v_", name, ".md3")); // precision does not matter
			setattachment(self.weaponentity, self, "tag_weapon");
		}
		else
		{
			if(self.weaponentity)
				remove(self.weaponentity);
			self.weaponentity = world;
		}

		setorigin(self,'0 0 0');
		self.angles = '0 0 0';
		self.frame = 0;
		self.viewmodelforclient = world;

		float idx;

		if(v_shot_idx) // v_ model attached to invisible h_ model
		{
			self.movedir = gettaginfo(self.weaponentity, v_shot_idx);
		}
		else
		{
			idx = gettagindex(self, "shot");
			if(!idx)
				idx = gettagindex(self, "tag_shot");
			if(idx)
				self.movedir = gettaginfo(self, idx);
			else
			{
				print("WARNING: weapon model ", self.model, " does not support the 'shot' tag, will display shots TOTALLY wrong\n");
				self.movedir = '0 0 0';
			}
		}

		if(self.weaponentity) // v_ model attached to invisible h_ model
		{
			idx = gettagindex(self.weaponentity, "shell");
			if(!idx)
				idx = gettagindex(self.weaponentity, "tag_shell");
			if(idx)
				self.spawnorigin = gettaginfo(self.weaponentity, idx);
		}
		else
			idx = 0;
		if(!idx)
		{
			idx = gettagindex(self, "shell");
			if(!idx)
				idx = gettagindex(self, "tag_shell");
			if(idx)
				self.spawnorigin = gettaginfo(self, idx);
			else
			{
				print("WARNING: weapon model ", self.model, " does not support the 'shell' tag, will display casings wrong\n");
				self.spawnorigin = self.movedir;
			}
		}

		if(v_shot_idx)
		{
			self.oldorigin = '0 0 0'; // use regular attachment
		}
		else
		{
			if(self.weaponentity)
			{
				idx = gettagindex(self, "weapon");
				if(!idx)
					idx = gettagindex(self, "tag_weapon");
			}
			else
			{
				idx = gettagindex(self, "handle");
				if(!idx)
					idx = gettagindex(self, "tag_handle");
			}
			if(idx)
			{
				self.oldorigin = self.movedir - gettaginfo(self, idx);
			}
			else
			{
				print("WARNING: weapon model ", self.model, " does not support the 'handle' tag and neither does the v_ model support the 'shot' tag, will display muzzle flashes TOTALLY wrong\n");
				self.oldorigin = '0 0 0'; // there is no way to recover from this
			}
		}

		self.viewmodelforclient = self.owner;
	}
	else
	{
		self.model = "";
		if(self.weaponentity)
			remove(self.weaponentity);
		self.weaponentity = world;
		self.movedir = '0 0 0';
		self.spawnorigin = '0 0 0';
		self.oldorigin = '0 0 0';
		self.anim_fire1  = '0 1 0.01';
		self.anim_fire2  = '0 1 0.01';
		self.anim_idle   = '0 1 0.01';
		self.anim_reload = '0 1 0.01';
	}

	self.view_ofs = '0 0 0';

	if(self.movedir_x >= 0)
	{
		vector v0;
		v0 = self.movedir;
		self.movedir = shotorg_adjust(v0, FALSE, FALSE);
		self.view_ofs = shotorg_adjust(v0, FALSE, TRUE) - v0;
	}
	self.owner.stat_shotorg = compressShotOrigin(self.movedir);
	self.movedir = decompressShotOrigin(self.owner.stat_shotorg); // make them match perfectly

	self.spawnorigin += self.view_ofs; // offset the casings origin by the same amount

	// check if an instant weapon switch occurred
	setorigin(self, self.view_ofs);
	// reset animstate now
	self.wframe = WFRAME_IDLE;
	setanim(self, self.anim_idle, TRUE, FALSE, TRUE);
}

vector CL_Weapon_GetShotOrg(float wpn)
{
	entity wi, oldself;
	vector ret;
	wi = get_weaponinfo(wpn);
	oldself = self;
	self = spawn();
	CL_WeaponEntity_SetModel(wi.mdl);
	ret = self.movedir;
	CL_WeaponEntity_SetModel("");
	remove(self);
	self = oldself;
	return ret;
}

void CL_Weaponentity_Think()
{
	float tb;
	self.nextthink = time;
	if (intermission_running)
		self.frame = self.anim_idle_x;
	if (self.owner.weaponentity != self)
	{
		if (self.weaponentity)
			remove(self.weaponentity);
		remove(self);
		return;
	}
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		if (self.weaponentity)
			self.weaponentity.model = "";
		return;
	}
	if (self.weaponname != self.owner.weaponname || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.weaponname = self.owner.weaponname;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;

		CL_WeaponEntity_SetModel(self.owner.weaponname);
	}

	tb = (self.effects & (EF_TELEPORT_BIT | EF_RESTARTANIM_BIT));
	self.effects = self.owner.effects & EFMASK_CHEAP;
	self.effects &= ~EF_LOWPRECISION;
	self.effects &= ~EF_FULLBRIGHT; // can mask team color, so get rid of it
	self.effects &= ~EF_TELEPORT_BIT;
	self.effects &= ~EF_RESTARTANIM_BIT;
	self.effects |= tb;

	if(self.owner.alpha == default_player_alpha)
		self.alpha = default_weapon_alpha;
	else if(self.owner.alpha != 0)
		self.alpha = self.owner.alpha;
	else
		self.alpha = 1;

	self.glowmod = self.owner.weaponentity_glowmod;
	self.colormap = self.owner.colormap;
	if (self.weaponentity)
	{
		self.weaponentity.effects = self.effects;
		self.weaponentity.alpha = self.alpha;
		self.weaponentity.colormap = self.colormap;
		self.weaponentity.glowmod = self.glowmod;
	}

	self.angles = '0 0 0';

	float f = (self.owner.weapon_nextthink - time);
	if (self.state == WS_RAISE && !intermission_running)
	{
		entity newwep = get_weaponinfo(self.owner.switchweapon);
		f = f * g_weaponratefactor / max(f, newwep.switchdelay_raise);
		self.angles_x = -90 * f * f;
	}
	else if (self.state == WS_DROP && !intermission_running)
	{
		entity oldwep = get_weaponinfo(self.owner.weapon);
		f = 1 - f * g_weaponratefactor / max(f, oldwep.switchdelay_drop);
		self.angles_x = -90 * f * f;
	}
	else if (self.state == WS_CLEAR)
	{
		f = 1;
		self.angles_x = -90 * f * f;
	}
}

void CL_ExteriorWeaponentity_Think()
{
	float tag_found;
	self.nextthink = time;
	if (self.owner.exteriorweaponentity != self)
	{
		remove(self);
		return;
	}
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		return;
	}
	if (self.weaponname != self.owner.weaponname || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.weaponname = self.owner.weaponname;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.weaponname != "")
			setmodel(self, strcat("models/weapons/v_", self.owner.weaponname, ".md3")); // precision set below
		else
			self.model = "";

		if((tag_found = gettagindex(self.owner, "tag_weapon")))
		{
			self.tag_index = tag_found;
			self.tag_entity = self.owner;
		}
		else
			setattachment(self, self.owner, "bip01 r hand");
	}
	self.effects = self.owner.effects;
	self.effects |= EF_LOWPRECISION;
	self.effects = self.effects & EFMASK_CHEAP; // eat performance
	if(self.owner.alpha == default_player_alpha)
		self.alpha = default_weapon_alpha;
	else if(self.owner.alpha != 0)
		self.alpha = self.owner.alpha;
	else
		self.alpha = 1;

	self.glowmod = self.owner.weaponentity_glowmod;
	self.colormap = self.owner.colormap;

	CSQCMODEL_AUTOUPDATE();
}

// spawning weaponentity for client
void CL_SpawnWeaponentity()
{
	self.weaponentity = spawn();
	self.weaponentity.classname = "weaponentity";
	self.weaponentity.solid = SOLID_NOT;
	self.weaponentity.owner = self;
	setmodel(self.weaponentity, ""); // precision set when changed
	setorigin(self.weaponentity, '0 0 0');
	self.weaponentity.angles = '0 0 0';
	self.weaponentity.viewmodelforclient = self;
	self.weaponentity.flags = 0;
	self.weaponentity.think = CL_Weaponentity_Think;
	self.weaponentity.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;
	self.weaponentity.nextthink = time;

	self.exteriorweaponentity = spawn();
	self.exteriorweaponentity.classname = "exteriorweaponentity";
	self.exteriorweaponentity.solid = SOLID_NOT;
	self.exteriorweaponentity.exteriorweaponentity = self.exteriorweaponentity;
	self.exteriorweaponentity.owner = self;
	setorigin(self.exteriorweaponentity, '0 0 0');
	self.exteriorweaponentity.angles = '0 0 0';
	self.exteriorweaponentity.think = CL_ExteriorWeaponentity_Think;
	self.exteriorweaponentity.nextthink = time;

	{
		entity oldself = self;
		self = self.exteriorweaponentity;
		CSQCMODEL_AUTOINIT();
		self = oldself;
	}
}

// Weapon subs
void w_clear()
{
	if (self.weapon != -1)
	{
		self.weapon = 0;
		self.switchingweapon = 0;
	}
	if (self.weaponentity)
	{
		self.weaponentity.state = WS_CLEAR;
		self.weaponentity.effects = 0;
	}
}

void w_ready()
{
	if (self.weaponentity)
		self.weaponentity.state = WS_READY;
	weapon_thinkf(WFRAME_IDLE, 1000000, w_ready);
}

.float prevdryfire;
.float prevwarntime;
float weapon_prepareattack_checkammo(float secondary)
{
	if (!(self.items & IT_UNLIMITED_WEAPON_AMMO))
	if (!WEP_ACTION(self.weapon, WR_CHECKAMMO1 + secondary))
	{
		// always keep the Mine Layer if we placed mines, so that we can detonate them
		entity mine;
		if(self.weapon == WEP_MINE_LAYER)
		for(mine = world; (mine = find(mine, classname, "mine")); ) if(mine.owner == self)
			return FALSE;

		if(self.weapon == self.switchweapon && time - self.prevdryfire > 1) // only play once BEFORE starting to switch weapons
		{
			sound (self, CH_WEAPON_A, W_Sound("dryfire"), VOL_BASE, ATTEN_NORM);
			self.prevdryfire = time;
		}

		if(WEP_ACTION(self.weapon, WR_CHECKAMMO2 - secondary)) // check if the other firing mode has enough ammo
		{
			if(time - self.prevwarntime > 1)
			{
				Send_Notification(
					NOTIF_ONE,
					self,
					MSG_MULTI,
					ITEM_WEAPON_PRIMORSEC,
					self.weapon,
					secondary,
					(1 - secondary)
				);
			}
			self.prevwarntime = time;
		}
		else // this weapon is totally unable to fire, switch to another one
		{
			W_SwitchToOtherWeapon(self);
		}

		return FALSE;
	}
	return TRUE;
}
.float race_penalty;
float weapon_prepareattack_check(float secondary, float attacktime)
{
	if(!weapon_prepareattack_checkammo(secondary))
		return FALSE;

	//if sv_ready_restart_after_countdown is set, don't allow the player to shoot
	//if all players readied up and the countdown is running
	if(time < game_starttime || time < self.race_penalty) {
		return FALSE;
	}

	if (timeout_status == TIMEOUT_ACTIVE) //don't allow the player to shoot while game is paused
		return FALSE;

	// do not even think about shooting if switching
	if(self.switchweapon != self.weapon)
		return FALSE;

	if(attacktime >= 0)
	{
		// don't fire if previous attack is not finished
		if (ATTACK_FINISHED(self) > time + self.weapon_frametime * 0.5)
			return FALSE;
		// don't fire while changing weapon
		if (self.weaponentity.state != WS_READY)
			return FALSE;
	}

	return TRUE;
}
float weapon_prepareattack_do(float secondary, float attacktime)
{
	self.weaponentity.state = WS_INUSE;

	self.spawnshieldtime = min(self.spawnshieldtime, time); // kill spawn shield when you fire

	// if the weapon hasn't been firing continuously, reset the timer
	if(attacktime >= 0)
	{
		if (ATTACK_FINISHED(self) < time - self.weapon_frametime * 1.5)
		{
			ATTACK_FINISHED(self) = time;
			//dprint("resetting attack finished to ", ftos(time), "\n");
		}
		ATTACK_FINISHED(self) = ATTACK_FINISHED(self) + attacktime * W_WeaponRateFactor();
	}
	self.bulletcounter += 1;
	//dprint("attack finished ", ftos(ATTACK_FINISHED(self)), "\n");
	return TRUE;
}
float weapon_prepareattack(float secondary, float attacktime)
{
	if(weapon_prepareattack_check(secondary, attacktime))
	{
		weapon_prepareattack_do(secondary, attacktime);
		return TRUE;
	}
	else
		return FALSE;
}

void weapon_thinkf(float fr, float t, void() func)
{
	vector a;
	vector of, or, ou;
	float restartanim;

	if(fr == WFRAME_DONTCHANGE)
	{
		fr = self.weaponentity.wframe;
		restartanim = FALSE;
	}
	else if (fr == WFRAME_IDLE)
		restartanim = FALSE;
	else
		restartanim = TRUE;

	of = v_forward;
	or = v_right;
	ou = v_up;

	if (self.weaponentity)
	{
		self.weaponentity.wframe = fr;
		a = '0 0 0';
		if (fr == WFRAME_IDLE)
			a = self.weaponentity.anim_idle;
		else if (fr == WFRAME_FIRE1)
			a = self.weaponentity.anim_fire1;
		else if (fr == WFRAME_FIRE2)
			a = self.weaponentity.anim_fire2;
		else // if (fr == WFRAME_RELOAD)
			a = self.weaponentity.anim_reload;
		a_z *= g_weaponratefactor;
		setanim(self.weaponentity, a, restartanim == FALSE, restartanim, restartanim);
	}

	v_forward = of;
	v_right = or;
	v_up = ou;

	if(self.weapon_think == w_ready && func != w_ready && self.weaponentity.state == WS_RAISE)
	{
		backtrace("Tried to override initial weapon think function - should this really happen?");
	}

	t *= W_WeaponRateFactor();

	// VorteX: haste can be added here
	if (self.weapon_think == w_ready)
	{
		self.weapon_nextthink = time;
		//dprint("started firing at ", ftos(time), "\n");
	}
	if (self.weapon_nextthink < time - self.weapon_frametime * 1.5 || self.weapon_nextthink > time + self.weapon_frametime * 1.5)
	{
		self.weapon_nextthink = time;
		//dprint("reset weapon animation timer at ", ftos(time), "\n");
	}
	self.weapon_nextthink = self.weapon_nextthink + t;
	self.weapon_think = func;
	//dprint("next ", ftos(self.weapon_nextthink), "\n");

	if((fr == WFRAME_FIRE1 || fr == WFRAME_FIRE2) && t)
	{
		if((self.weapon == WEP_SHOCKWAVE || self.weapon == WEP_SHOTGUN) && fr == WFRAME_FIRE2)
			animdecide_setaction(self, ANIMACTION_MELEE, restartanim);
		else
			animdecide_setaction(self, ANIMACTION_SHOOT, restartanim);
	}
	else
	{
		if(self.anim_upper_action == ANIMACTION_SHOOT || self.anim_upper_action == ANIMACTION_MELEE)
			self.anim_upper_action = 0;
	}
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

	if(forbidWeaponUse(self))
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
		//self.items &= ~IT_AMMO;
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

			// the two weapon entities will notice this has changed and update their models
			self.weapon = self.switchweapon;
			self.weaponname = newwep.mdl;
			self.bulletcounter = 0;
			//self.ammo_field = newwep.ammo_field;
			WEP_ACTION(self.switchweapon, WR_SETUP);
			self.weaponentity.state = WS_RAISE;

			// set our clip load to the load of the weapon we switched to, if it's reloadable
			if(newwep.spawnflags & WEP_FLAG_RELOADABLE && newwep.reloading_ammo) // prevent accessing undefined cvars
			{
				self.clip_load = self.(weapon_load[self.switchweapon]);
				self.clip_size = newwep.reloading_ammo;
			}
			else
				self.clip_load = self.clip_size = 0;

			weapon_thinkf(WFRAME_IDLE, newwep.switchdelay_raise, w_ready);
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

			// set up weapon switch think in the future, and start drop anim
			#ifndef INDEPENDENT_ATTACK_FINISHED
			if(ATTACK_FINISHED(self) <= time + self.weapon_frametime * 0.5)
			{
			#endif
				sound(self, CH_WEAPON_SINGLE, W_Sound("weapon_switch"), VOL_BASE, ATTN_NORM);
				self.weaponentity.state = WS_DROP;
				weapon_thinkf(WFRAME_DONTCHANGE, oldwep.switchdelay_drop, w_clear);
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

		if(w)
			WEP_ACTION(self.weapon, WR_THINK);
		else
			WEP_ACTION(self.weapon, WR_GONETHINK);

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
}

void W_AttachToShotorg(entity flash, vector offset)
{
	entity xflash;
	flash.owner = self;
	flash.angles_z = random() * 360;

	if(gettagindex(self.weaponentity, "shot"))
		setattachment(flash, self.weaponentity, "shot");
	else
		setattachment(flash, self.weaponentity, "tag_shot");
	setorigin(flash, offset);

	xflash = spawn();
	copyentity(flash, xflash);

	flash.viewmodelforclient = self;

	if(self.weaponentity.oldorigin_x > 0)
	{
		setattachment(xflash, self.exteriorweaponentity, "");
		setorigin(xflash, self.weaponentity.oldorigin + offset);
	}
	else
	{
		if(gettagindex(self.exteriorweaponentity, "shot"))
			setattachment(xflash, self.exteriorweaponentity, "shot");
		else
			setattachment(xflash, self.exteriorweaponentity, "tag_shot");
		setorigin(xflash, offset);
	}
}

void W_DecreaseAmmo(float ammo_use)
{
	entity wep = get_weaponinfo(self.weapon);

	if(cvar("g_overkill"))
	if(self.ok_use_ammocharge)
	{
		ok_DecreaseCharge(self, self.weapon);
		return; // TODO
	}

	if((self.items & IT_UNLIMITED_WEAPON_AMMO) && !wep.reloading_ammo)
		return;

	// if this weapon is reloadable, decrease its load. Else decrease the player's ammo
	if(wep.reloading_ammo)
	{
		self.clip_load -= ammo_use;
		self.(weapon_load[self.weapon]) = self.clip_load;
	}
	else if(wep.ammo_field != ammo_none)
	{
		self.(wep.ammo_field) -= ammo_use;
		if(self.(wep.ammo_field) < 0)
		{
			backtrace(sprintf(
				"W_DecreaseAmmo(%.2f): '%s' subtracted too much %s from '%s', resulting with '%.2f' left... "
				"Please notify Samual immediately with a copy of this backtrace!\n",
				ammo_use,
				wep.netname,
				GetAmmoPicture(wep.ammo_field),
				self.netname,
				self.(wep.ammo_field)
			));
		}
	}
}

// weapon reloading code

.float reload_ammo_amount, reload_ammo_min, reload_time;
.float reload_complain;
.string reload_sound;

void W_ReloadedAndReady()
{
	// finish the reloading process, and do the ammo transfer

	self.clip_load = self.old_clip_load; // restore the ammo counter, in case we still had ammo in the weapon before reloading

	// if the gun uses no ammo, max out weapon load, else decrease ammo as we increase weapon load
	if(!self.reload_ammo_min || self.items & IT_UNLIMITED_WEAPON_AMMO || self.ammo_field == ammo_none)
		self.clip_load = self.reload_ammo_amount;
	else
	{
		while(self.clip_load < self.reload_ammo_amount && self.(self.ammo_field)) // make sure we don't add more ammo than we have
		{
			self.clip_load += 1;
			self.(self.ammo_field) -= 1;
		}
	}
	self.(weapon_load[self.weapon]) = self.clip_load;

	// do not set ATTACK_FINISHED in reload code any more. This causes annoying delays if eg: You start reloading a weapon,
	// then quickly switch to another weapon and back. Reloading is canceled, but the reload delay is still there,
	// so your weapon is disabled for a few seconds without reason

	//ATTACK_FINISHED(self) -= self.reload_time - 1;

	w_ready();
}

void W_Reload(float sent_ammo_min, string sent_sound)
{
	if(self.frozen || self.deadflag != DEAD_NO)
		return; // don't reload while dead/frozen

	// set global values to work with
	entity e;
	e = get_weaponinfo(self.weapon);

	if(cvar("g_overkill"))
	if(self.ok_use_ammocharge)
		return; // TODO

	self.reload_ammo_min = sent_ammo_min;
	self.reload_ammo_amount = e.reloading_ammo;;
	self.reload_time = e.reloading_time;
	self.reload_sound = sent_sound;

	// don't reload weapons that don't have the RELOADABLE flag
	if (!(e.spawnflags & WEP_FLAG_RELOADABLE))
	{
		dprint("Warning: Attempted to reload a weapon that does not have the WEP_FLAG_RELOADABLE flag. Fix your code!\n");
		return;
	}

	// return if reloading is disabled for this weapon
	if(!self.reload_ammo_amount)
		return;

	// our weapon is fully loaded, no need to reload
	if (self.clip_load >= self.reload_ammo_amount)
		return;

	// no ammo, so nothing to load
	if(self.ammo_field != ammo_none)
	if(!self.(self.ammo_field) && self.reload_ammo_min)
	if (!(self.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		if(IS_REAL_CLIENT(self) && self.reload_complain < time)
		{
			play2(self, W_Sound("unavailable"));
			sprint(self, strcat("You don't have enough ammo to reload the ^2", WEP_NAME(self.weapon), "\n"));
			self.reload_complain = time + 1;
		}
		// switch away if the amount of ammo is not enough to keep using this weapon
		if (!(WEP_ACTION(self.weapon, WR_CHECKAMMO1) + WEP_ACTION(self.weapon, WR_CHECKAMMO2)))
		{
			self.clip_load = -1; // reload later
			W_SwitchToOtherWeapon(self);
		}
		return;
	}

	if (self.weaponentity)
	{
		if (self.weaponentity.wframe == WFRAME_RELOAD)
			return;

		// allow switching away while reloading, but this will cause a new reload!
		self.weaponentity.state = WS_READY;
	}

	// now begin the reloading process

	sound(self, CH_WEAPON_SINGLE, self.reload_sound, VOL_BASE, ATTEN_NORM);

	// do not set ATTACK_FINISHED in reload code any more. This causes annoying delays if eg: You start reloading a weapon,
	// then quickly switch to another weapon and back. Reloading is canceled, but the reload delay is still there,
	// so your weapon is disabled for a few seconds without reason

	//ATTACK_FINISHED(self) = max(time, ATTACK_FINISHED(self)) + self.reload_time + 1;

	weapon_thinkf(WFRAME_RELOAD, self.reload_time, W_ReloadedAndReady);

	if(self.clip_load < 0)
		self.clip_load = 0;
	self.old_clip_load = self.clip_load;
	self.clip_load = self.(weapon_load[self.weapon]) = -1;
}

entity weapon_dropevent_item;
void W_DropEvent(float event, entity player, float weapon_type, entity weapon_item)
{
	entity oldself = self;
	self = player;
	weapon_dropevent_item = weapon_item;
	WEP_ACTION(weapon_type, event);
	self = oldself;
}
