#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ PORTO,
/* function  */ W_Porto,
/* ammotype  */ ammo_none,
/* impulse   */ 0,
/* flags     */ WEP_TYPE_OTHER | WEP_FLAG_SUPERWEAPON,
/* rating    */ 0,
/* color     */ '0.5 0.5 0.5',
/* modelname */ "porto",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairporto 0.6",
/* wepimg    */ "weaponporto",
/* refname   */ "porto",
/* wepname   */ _("Port-O-Launch")
);

#define PORTO_SETTINGS(w_cvar,w_prop) PORTO_SETTINGS_LIST(w_cvar, w_prop, PORTO, porto)
#define PORTO_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, lifetime) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, BOTH, speed) \
	w_cvar(id, sn, NONE, secondary) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
PORTO_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.entity porto_current;
.vector porto_v_angle; // holds "held" view angles
.float porto_v_angle_held;
.vector right_vector;
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_porto(void) { weapon_defaultspawnfunc(WEP_PORTO); }

void W_Porto_Success(void)
{
	if(self.realowner == world)
	{
		objerror("Cannot succeed successfully: no owner\n");
		return;
	}

	self.realowner.porto_current = world;
	remove(self);
}

string W_ThrowNewWeapon(entity own, float wpn, float doreduce, vector org, vector velo);
void W_Porto_Fail(float failhard)
{
	if(self.realowner == world)
	{
		objerror("Cannot fail successfully: no owner\n");
		return;
	}

	// no portals here!
	if(self.cnt < 0)
	{
		Portal_ClearWithID(self.realowner, self.portal_id);
	}

	self.realowner.porto_current = world;

	if(self.cnt < 0 && !failhard && self.realowner.playerid == self.playerid && self.realowner.deadflag == DEAD_NO && !(self.realowner.weapons & WEPSET_PORTO))
	{
		setsize(self, '-16 -16 0', '16 16 32');
		setorigin(self, self.origin + trace_plane_normal);
		if(move_out_of_solid(self))
		{
			self.flags = FL_ITEM;
			self.velocity = trigger_push_calculatevelocity(self.origin, self.realowner, 128);
			tracetoss(self, self);
			if(vlen(trace_endpos - self.realowner.origin) < 128)
			{
				W_ThrowNewWeapon(self.realowner, WEP_PORTO, 0, self.origin, self.velocity);
				centerprint(self.realowner, "^1Portal deployment failed.\n\n^2Catch it to try again!");
			}
		}
	}
	remove(self);
}

void W_Porto_Remove(entity p)
{
	if(p.porto_current.realowner == p && p.porto_current.classname == "porto")
	{
		entity oldself;
		oldself = self;
		self = p.porto_current;
		W_Porto_Fail(1);
		self = oldself;
	}
}

void W_Porto_Think(void)
{
	trace_plane_normal = '0 0 0';
	if(self.realowner.playerid != self.playerid)
		remove(self);
	else
		W_Porto_Fail(0);
}

void W_Porto_Touch(void)
{
	vector norm;

	// do not use PROJECTILE_TOUCH here
	// FIXME but DO handle warpzones!

	if(other.classname == "portal")
		return; // handled by the portal

	norm = trace_plane_normal;
	if(trace_ent.iscreature)
	{
		traceline(trace_ent.origin, trace_ent.origin + '0 0 2' * PL_MIN_z, MOVE_WORLDONLY, self);
		if(trace_fraction >= 1)
			return;
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SLICK || trace_dphitcontents & DPCONTENTS_PLAYERCLIP)
			return;
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
			return;
	}

	if(self.realowner.playerid != self.playerid)
	{
		sound(self, CH_SHOTS, "porto/unsupported.wav", VOL_BASE, ATTEN_NORM);
		remove(self);
	}
	else if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SLICK || trace_dphitcontents & DPCONTENTS_PLAYERCLIP)
	{
		spamsound(self, CH_SHOTS, "porto/bounce.wav", VOL_BASE, ATTEN_NORM);
		// just reflect
		self.right_vector = self.right_vector - 2 * trace_plane_normal * (self.right_vector * trace_plane_normal);
		self.angles = vectoangles(self.velocity - 2 * trace_plane_normal * (self.velocity * trace_plane_normal));
	}
	else if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		sound(self, CH_SHOTS, "porto/unsupported.wav", VOL_BASE, ATTEN_NORM);
		W_Porto_Fail(0);
		if(self.cnt < 0)
			Portal_ClearAll_PortalsOnly(self.realowner);
	}
	else if(self.cnt == 0)
	{
		// in-portal only
		if(Portal_SpawnInPortalAtTrace(self.realowner, self.right_vector, self.portal_id))
		{
			sound(self, CH_SHOTS, "porto/create.wav", VOL_BASE, ATTEN_NORM);
			trace_plane_normal = norm;
			centerprint(self.realowner, "^1In^7-portal created.");
			W_Porto_Success();
		}
		else
		{
			sound(self, CH_SHOTS, "porto/unsupported.wav", VOL_BASE, ATTEN_NORM);
			trace_plane_normal = norm;
			W_Porto_Fail(0);
		}
	}
	else if(self.cnt == 1)
	{
		// out-portal only
		if(Portal_SpawnOutPortalAtTrace(self.realowner, self.right_vector, self.portal_id))
		{
			sound(self, CH_SHOTS, "porto/create.wav", VOL_BASE, ATTEN_NORM);
			trace_plane_normal = norm;
			centerprint(self.realowner, "^4Out^7-portal created.");
			W_Porto_Success();
		}
		else
		{
			sound(self, CH_SHOTS, "porto/unsupported.wav", VOL_BASE, ATTEN_NORM);
			trace_plane_normal = norm;
			W_Porto_Fail(0);
		}
	}
	else if(self.effects & EF_RED)
	{
		self.effects += EF_BLUE - EF_RED;
		if(Portal_SpawnInPortalAtTrace(self.realowner, self.right_vector, self.portal_id))
		{
			sound(self, CH_SHOTS, "porto/create.wav", VOL_BASE, ATTEN_NORM);
			trace_plane_normal = norm;
			centerprint(self.realowner, "^1In^7-portal created.");
			self.right_vector = self.right_vector - 2 * trace_plane_normal * (self.right_vector * norm);
			self.angles = vectoangles(self.velocity - 2 * trace_plane_normal * (self.velocity * norm));
			CSQCProjectile(self, TRUE, PROJECTILE_PORTO_BLUE, TRUE); // change type
		}
		else
		{
			sound(self, CH_SHOTS, "porto/unsupported.wav", VOL_BASE, ATTEN_NORM);
			trace_plane_normal = norm;
			Portal_ClearAll_PortalsOnly(self.realowner);
			W_Porto_Fail(0);
		}
	}
	else
	{
		if(self.realowner.portal_in.portal_id == self.portal_id)
		{
			if(Portal_SpawnOutPortalAtTrace(self.realowner, self.right_vector, self.portal_id))
			{
				sound(self, CH_SHOTS, "porto/create.wav", VOL_BASE, ATTEN_NORM);
				trace_plane_normal = norm;
				centerprint(self.realowner, "^4Out^7-portal created.");
				W_Porto_Success();
			}
			else
			{
				sound(self, CH_SHOTS, "porto/unsupported.wav", VOL_BASE, ATTEN_NORM);
				Portal_ClearAll_PortalsOnly(self.realowner);
				W_Porto_Fail(0);
			}
		}
		else
		{
			sound(self, CH_SHOTS, "porto/unsupported.wav", VOL_BASE, ATTEN_NORM);
			Portal_ClearAll_PortalsOnly(self.realowner);
			W_Porto_Fail(0);
		}
	}
}

void W_Porto_Attack(float type)
{
	entity gren;

	W_SetupShot(self, FALSE, 4, "porto/fire.wav", CH_WEAPON_A, 0);
	// always shoot from the eye
	w_shotdir = v_forward;
	w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;

	gren = spawn ();
	gren.cnt = type;
	gren.owner = gren.realowner = self;
	gren.playerid = self.playerid;
	gren.classname = "porto";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = 200;
	gren.movetype = MOVETYPE_BOUNCEMISSILE;
	PROJECTILE_MAKETRIGGER(gren);
	gren.effects = EF_RED;
	gren.scale = 4;
	setorigin(gren, w_shotorg);
	setsize(gren, '0 0 0', '0 0 0');
	
	gren.nextthink = time + WEP_CVAR_BOTH(porto, (type <= 0), lifetime);
	gren.think = W_Porto_Think;
	gren.touch = W_Porto_Touch;

	W_SetupProjVelocity_Basic(gren, WEP_CVAR_BOTH(porto, (type <= 0), speed), 0);

	gren.angles = vectoangles(gren.velocity);
	gren.flags = FL_PROJECTILE;

	gren.portal_id = time;
	self.porto_current = gren;
	gren.playerid = self.playerid;
	fixedmakevectors(fixedvectoangles(gren.velocity));
	gren.right_vector = v_right;

	gren.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;

	if(type > 0)
		CSQCProjectile(gren, TRUE, PROJECTILE_PORTO_BLUE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_PORTO_RED, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

float w_nexball_weapon(float req); // WEAPONTODO
float W_Porto(float req)
{
	//vector v_angle_save;

	if(g_nexball) { return w_nexball_weapon(req); }
	
	switch(req)
	{
		case WR_AIM:
		{
			self.BUTTON_ATCK = FALSE;
			self.BUTTON_ATCK2 = FALSE;
			if(!WEP_CVAR(porto, secondary))
				if(bot_aim(WEP_CVAR_PRI(porto, speed), 0, WEP_CVAR_PRI(porto, lifetime), FALSE))
					self.BUTTON_ATCK = TRUE;
					
			return TRUE;
		}
		case WR_CONFIG:
		{
			PORTO_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_THINK:
		{
			if(WEP_CVAR(porto, secondary))
			{
				if(self.BUTTON_ATCK)
				if(!self.porto_current)
				if(!self.porto_forbidden)
				if(weapon_prepareattack(0, WEP_CVAR_PRI(porto, refire)))
				{
					W_Porto_Attack(0);
					weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(porto, animtime), w_ready);
				}

				if(self.BUTTON_ATCK2)
				if(!self.porto_current)
				if(!self.porto_forbidden)
				if(weapon_prepareattack(1, WEP_CVAR_SEC(porto, refire)))
				{
					W_Porto_Attack(1);
					weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(porto, animtime), w_ready);
				}
			}
			else
			{
				if(self.porto_v_angle_held)
				{
					if(!self.BUTTON_ATCK2)
					{
						self.porto_v_angle_held = 0;

						ClientData_Touch(self);
					}
				}
				else
				{
					if(self.BUTTON_ATCK2)
					{
						self.porto_v_angle = self.v_angle;
						self.porto_v_angle_held = 1;

						ClientData_Touch(self);
					}
				}
				if(self.porto_v_angle_held)
					makevectors(self.porto_v_angle); // override the previously set angles

				if(self.BUTTON_ATCK)
				if(!self.porto_current)
				if(!self.porto_forbidden)
				if(weapon_prepareattack(0, WEP_CVAR_PRI(porto, refire)))
				{
					W_Porto_Attack(-1);
					weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(porto, animtime), w_ready);
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_porto.md3");
			precache_model("models/weapons/v_porto.md3");
			precache_model("models/weapons/h_porto.iqm");
			precache_model("models/portal.md3");
			precache_sound("porto/bounce.wav");
			precache_sound("porto/create.wav");
			precache_sound("porto/expire.wav");
			precache_sound("porto/explode.wav");
			precache_sound("porto/fire.wav");
			precache_sound("porto/unsupported.wav");
			PORTO_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_SETUP:
		{
			self.ammo_field = ammo_none;
			return TRUE;
		}
		case WR_RESETPLAYER:
		{
			self.porto_current = world;
			return TRUE;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Porto(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			print("Since when does Porto send DamageInfo?\n");
			return TRUE;
		}
		case WR_INIT:
		{
			// nothing to do
			return TRUE;
		}
		case WR_ZOOMRETICLE:
		{
			// no weapon specific image for this weapon
			return FALSE;
		}
	}
	return FALSE;
}
#endif
#endif
