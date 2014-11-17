#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ TUBA,
/* function  */ W_Tuba,
/* ammotype  */ ammo_none,
/* impulse   */ 1,
/* flags     */ WEP_FLAG_HIDDEN | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* color     */ '0 1 0',
/* modelname */ "tuba",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairtuba",
/* wepimg    */ "weapontuba",
/* refname   */ "tuba",
/* xgettext:no-c-format */
/* wepname   */ _("@!#%'n Tuba")
);

#define TUBA_SETTINGS(w_cvar,w_prop) TUBA_SETTINGS_LIST(w_cvar, w_prop, TUBA, tuba)
#define TUBA_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, animtime) \
	w_cvar(id, sn, NONE, attenuation) \
	w_cvar(id, sn, NONE, damage) \
	w_cvar(id, sn, NONE, edgedamage) \
	w_cvar(id, sn, NONE, fadetime) \
	w_cvar(id, sn, NONE, force) \
	w_cvar(id, sn, NONE, pitchstep) \
	w_cvar(id, sn, NONE, radius) \
	w_cvar(id, sn, NONE, refire) \
	w_cvar(id, sn, NONE, volume) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
TUBA_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
float W_Tuba_MarkClientOnlyFieldsAsUsed() {
	// These variables are only used by client/tuba.qc. TODO: move client/tuba.qc code here.
	return WEP_CVAR(tuba, fadetime) + WEP_CVAR(tuba, pitchstep) + WEP_CVAR(tuba, volume);
}

.entity tuba_note;
.float tuba_smoketime;
.float tuba_instrument;

#define MAX_TUBANOTES 32
.float tuba_lastnotes_last;
.float tuba_lastnotes_cnt; // over
.vector tuba_lastnotes[MAX_TUBANOTES];
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_tuba(void) { weapon_defaultspawnfunc(WEP_TUBA); }

float W_Tuba_HasPlayed(entity pl, string melody, float instrument, float ignorepitch, float mintempo, float maxtempo)
{
	float i, j, mmin, mmax, nolength;
	float n = tokenize_console(melody);
	if(n > pl.tuba_lastnotes_cnt)
		return FALSE;
	float pitchshift = 0;

	if(instrument >= 0)
		if(pl.tuba_instrument != instrument)
			return FALSE;

	// verify notes...
	nolength = FALSE;
	for(i = 0; i < n; ++i)
	{
		vector v = pl.(tuba_lastnotes[mod(pl.tuba_lastnotes_last - i + MAX_TUBANOTES, MAX_TUBANOTES)]);
		float ai = stof(argv(n - i - 1));
		float np = floor(ai);
		if(ai == np)
			nolength = TRUE;
		// n counts the last played notes BACKWARDS
		// _x is start
		// _y is end
		// _z is note pitch
		if(ignorepitch && i == 0)
		{
			pitchshift = np - v_z;
		}
		else
		{
			if(v_z + pitchshift != np)
				return FALSE;
		}
	}

	// now we know the right NOTES were played
	if(!nolength)
	{
		// verify rhythm...
		float ti = 0;
		if(maxtempo > 0)
			mmin = 240 / maxtempo; // 60 = "0.25 means 1 sec", at 120 0.5 means 1 sec, at 240 1 means 1 sec
		else
			mmin = 0;
		if(mintempo > 0)
			mmax = 240 / mintempo; // 60 = "0.25 means 1 sec", at 120 0.5 means 1 sec, at 240 1 means 1 sec
		else
			mmax = 240; // you won't try THAT hard... (tempo 1)
		//printf("initial tempo rules: %f %f\n", mmin, mmax);

		for(i = 0; i < n; ++i)
		{
			vector vi = pl.(tuba_lastnotes[mod(pl.tuba_lastnotes_last - i + MAX_TUBANOTES, MAX_TUBANOTES)]);
			float ai = stof(argv(n - i - 1));
			ti -= 1 / (ai - floor(ai));
			float tj = ti;
			for(j = i+1; j < n; ++j)
			{
				vector vj = pl.(tuba_lastnotes[mod(pl.tuba_lastnotes_last - j + MAX_TUBANOTES, MAX_TUBANOTES)]);
				float aj = stof(argv(n - j - 1));
				tj -= (aj - floor(aj));

				// note i should be at m*ti+b
				// note j should be at m*tj+b
				// so:
				// we have a LINE l, so that
				// vi_x <= l(ti) <= vi_y
				// vj_x <= l(tj) <= vj_y
				// what is m?

				// vi_x <= vi_y <= vj_x <= vj_y
				// ti <= tj
				//printf("first note: %f to %f, should be %f\n", vi_x, vi_y, ti);
				//printf("second note: %f to %f, should be %f\n", vj_x, vj_y, tj);
				//printf("m1 = %f\n", (vi_x - vj_y) / (ti - tj));
				//printf("m2 = %f\n", (vi_y - vj_x) / (ti - tj));
				mmin = max(mmin, (vi_x - vj_y) / (ti - tj)); // lower bound
				mmax = min(mmax, (vi_y - vj_x) / (ti - tj)); // upper bound
			}
		}

		if(mmin > mmax) // rhythm fail
			return FALSE;
	}

	pl.tuba_lastnotes_cnt = 0;

	return TRUE;
}

void W_Tuba_NoteOff(void)
{
	// we have a note:
	//   on: self.spawnshieldtime
	//   off: time
	//   note: self.cnt
	if(self.owner.tuba_note == self)
	{
		self.owner.tuba_lastnotes_last = mod(self.owner.tuba_lastnotes_last + 1, MAX_TUBANOTES);
		self.owner.(tuba_lastnotes[self.owner.tuba_lastnotes_last]) = eX * self.spawnshieldtime + eY * time + eZ * self.cnt;
		self.owner.tuba_note = world;
		self.owner.tuba_lastnotes_cnt = bound(0, self.owner.tuba_lastnotes_cnt + 1, MAX_TUBANOTES);

		string s;
		s = trigger_magicear_processmessage_forallears(self.owner, 0, world, string_null);
		if(s != "")
		{
			// simulate a server message
			switch(self.tuba_instrument)
			{
				default:
				case 0: // Tuba
					bprint(strcat("\{1}\{13}* ^3", self.owner.netname, "^3 played on the @!#%'n Tuba: ^7", s, "\n"));
					break;
				case 1:
					bprint(strcat("\{1}\{13}* ^3", self.owner.netname, "^3 played on the @!#%'n Accordeon: ^7", s, "\n"));
					break;
				case 2:
					bprint(strcat("\{1}\{13}* ^3", self.owner.netname, "^3 played on the @!#%'n Klein Bottle: ^7", s, "\n"));
					break;
			}
		}
	}
	remove(self);
}

float W_Tuba_GetNote(entity pl, float hittype)
{
	float note;
	float movestate;
	movestate = 5;
	if(pl.movement_x < 0) movestate -= 3;
	if(pl.movement_x > 0) movestate += 3;
	if(pl.movement_y < 0) movestate -= 1;
	if(pl.movement_y > 0) movestate += 1;
#ifdef GMQCC
	note = 0;
#endif
	switch(movestate)
	{
	// layout: originally I wanted
	//   eb e  e#=f
	//   B  c  d
	//   Gb G  G#
	// but then you only use forward and right key. So to make things more
	// interesting, I swapped B with e#. Har har har...
	//   eb e  B
	// f=e# c  d
	//   Gb G  G#
		case 1: note = -6; break; // Gb
		case 2: note = -5; break; // G
		case 3: note = -4; break; // G#
		case 4: note = +5; break; // e#
		default:
		case 5: note =  0; break; // c
		case 6: note = +2; break; // d
		case 7: note = +3; break; // eb
		case 8: note = +4; break; // e
		case 9: note = -1; break; // B
	}
	if(pl.BUTTON_CROUCH)
		note -= 12;
	if(pl.BUTTON_JUMP)
		note += 12;
	if(hittype & HITTYPE_SECONDARY)
		note += 7;

	// we support two kinds of tubas, those tuned in Eb and those tuned in C
	// kind of tuba currently is player slot number, or team number if in
	// teamplay
	// that way, holes in the range of notes are "plugged"
	if(teamplay)
	{
		if(pl.team == NUM_TEAM_2 || pl.team == NUM_TEAM_4)
			note += 3;
	}
	else
	{
		if(pl.clientcolors & 1)
			note += 3;
	}

	// total range of notes:
	//                       0
	//                 ***  ** ****
	//                        ***  ** ****
	//     ***  ** ****
	//            ***  ** ****
	//     ***  ********************* ****
	//     -18.........................+12
	//        ***  ********************* ****
	//     -18............................+15
	//     with jump: ... +24
	//     ... +27
	return note;
}

float W_Tuba_NoteSendEntity(entity to, float sf)
{
	float f;

	msg_entity = to;
	if(!sound_allowed(MSG_ONE, self.realowner))
		return FALSE;

	WriteByte(MSG_ENTITY, ENT_CLIENT_TUBANOTE);
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
	{
		WriteChar(MSG_ENTITY, self.cnt);
		f = 0;
		if(self.realowner != to)
			f |= 1;
		f |= 2 * self.tuba_instrument;
		WriteByte(MSG_ENTITY, f);
	}
	if(sf & 2)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}
	return TRUE;
}

void W_Tuba_NoteThink(void)
{
	float dist_mult;
	float vol0, vol1;
	vector dir0, dir1;
	vector v;
	entity e;
	if(time > self.teleport_time)
	{
		W_Tuba_NoteOff();
		return;
	}
	self.nextthink = time;
	dist_mult = WEP_CVAR(tuba, attenuation) / autocvar_snd_soundradius;
	FOR_EACH_REALCLIENT(e)
	if(e != self.realowner)
	{
		v = self.origin - (e.origin + e.view_ofs);
		vol0 = max(0, 1 - vlen(v) * dist_mult);
		dir0 = normalize(v);
		v = self.realowner.origin - (e.origin + e.view_ofs);
		vol1 = max(0, 1 - vlen(v) * dist_mult);
		dir1 = normalize(v);
		if(fabs(vol0 - vol1) > 0.005) // 0.5 percent change in volume
		{
			setorigin(self, self.realowner.origin);
			self.SendFlags |= 2;
			break;
		}
		if(dir0 * dir1 < 0.9994) // 2 degrees change in angle
		{
			setorigin(self, self.realowner.origin);
			self.SendFlags |= 2;
			break;
		}
	}
}

void W_Tuba_NoteOn(float hittype)
{
	vector o;
	float n;

	W_SetupShot(self, FALSE, 2, "", 0, WEP_CVAR(tuba, damage));

	n = W_Tuba_GetNote(self, hittype);

	hittype = 0;
	if(self.tuba_instrument & 1)
		hittype |= HITTYPE_SECONDARY;
	if(self.tuba_instrument & 2)
		hittype |= HITTYPE_BOUNCE;

	if(self.tuba_note)
	{
		if(self.tuba_note.cnt != n || self.tuba_note.tuba_instrument != self.tuba_instrument)
		{
			entity oldself = self;
			self = self.tuba_note;
			W_Tuba_NoteOff();
			self = oldself;
		}
	}

	if(!self.tuba_note)
	{
		self.tuba_note = spawn();
		self.tuba_note.owner = self.tuba_note.realowner = self;
		self.tuba_note.cnt = n;
		self.tuba_note.tuba_instrument = self.tuba_instrument;
		self.tuba_note.think = W_Tuba_NoteThink;
		self.tuba_note.nextthink = time;
		self.tuba_note.spawnshieldtime = time;
		Net_LinkEntity(self.tuba_note, FALSE, 0, W_Tuba_NoteSendEntity);
	}

	self.tuba_note.teleport_time = time + WEP_CVAR(tuba, refire) * 2 * W_WeaponRateFactor(); // so it can get prolonged safely

	//sound(self, c, TUBA_NOTE(n), bound(0, VOL_BASE * cvar("g_balance_tuba_volume"), 1), autocvar_g_balance_tuba_attenuation);
	RadiusDamage(self, self, WEP_CVAR(tuba, damage), WEP_CVAR(tuba, edgedamage), WEP_CVAR(tuba, radius), world, world, WEP_CVAR(tuba, force), hittype | WEP_TUBA, world);

	o = gettaginfo(self.exteriorweaponentity, 0);
	if(time > self.tuba_smoketime)
	{
		Send_Effect(EFFECT_SMOKE_RING, o + v_up * 45 + v_right * -6 + v_forward * 8, v_up * 100, 1);
		self.tuba_smoketime = time + 0.25;
	}
}

float W_Tuba(float req)
{
	switch(req)
	{
		case WR_AIM:
		{
			// bots cannot play the Tuba well yet
			// I think they should start with the recorder first
			if(vlen(self.origin - self.enemy.origin) < WEP_CVAR(tuba, radius))
			{
				if(random() > 0.5)
					self.BUTTON_ATCK = 1;
				else
					self.BUTTON_ATCK2 = 1;
			}
			
			return TRUE;
		}
		case WR_THINK:
		{
			if(self.BUTTON_ATCK)
			if(weapon_prepareattack(0, WEP_CVAR(tuba, refire)))
			{
				W_Tuba_NoteOn(0);
				//weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_tuba_animtime, w_ready);
				weapon_thinkf(WFRAME_IDLE, WEP_CVAR(tuba, animtime), w_ready);
			}
			if(self.BUTTON_ATCK2)
			if(weapon_prepareattack(1, WEP_CVAR(tuba, refire)))
			{
				W_Tuba_NoteOn(HITTYPE_SECONDARY);
				//weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_tuba_animtime, w_ready);
				weapon_thinkf(WFRAME_IDLE, WEP_CVAR(tuba, animtime), w_ready);
			}
			if(self.tuba_note)
			{
				if(!self.BUTTON_ATCK && !self.BUTTON_ATCK2)
				{
					entity oldself = self;
					self = self.tuba_note;
					W_Tuba_NoteOff();
					self = oldself;
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_tuba.md3");
			precache_model("models/weapons/v_tuba.md3");
			precache_model("models/weapons/h_tuba.iqm");
			precache_model("models/weapons/v_akordeon.md3");
			precache_model("models/weapons/h_akordeon.iqm");
			precache_model("models/weapons/v_kleinbottle.md3");
			precache_model("models/weapons/h_kleinbottle.iqm");
			TUBA_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_SETUP:
		{
			self.ammo_field = ammo_none;
			self.tuba_instrument = 0;
			return TRUE;
		}
		case WR_RELOAD:
		{
			// switch to alternate instruments :)
			if(self.weaponentity.state == WS_READY)
			{
				switch(self.tuba_instrument)
				{
					case 0:
						self.tuba_instrument = 1;
						self.weaponname = "akordeon";
						break;
					case 1:
						self.tuba_instrument = 2;
						self.weaponname = "kleinbottle";
						break;
					case 2:
						self.tuba_instrument = 0;
						self.weaponname = "tuba";
						break;
				}
				W_SetupShot(self, FALSE, 0, "", 0, 0);
				Send_Effect(EFFECT_TELEPORT, w_shotorg, '0 0 0', 1);
				self.weaponentity.state = WS_INUSE;
				weapon_thinkf(WFRAME_RELOAD, 0.5, w_ready);
			}
			
			return TRUE;
		}
		case WR_CHECKAMMO1:
		case WR_CHECKAMMO2:
		{
			return TRUE; // tuba has infinite ammo
		}
		case WR_CONFIG:
		{
			TUBA_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			if(w_deathtype & HITTYPE_BOUNCE)
				return WEAPON_KLEINBOTTLE_SUICIDE;
			else if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_ACCORDEON_SUICIDE;
			else
				return WEAPON_TUBA_SUICIDE;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_BOUNCE)
				return WEAPON_KLEINBOTTLE_MURDER;
			else if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_ACCORDEON_MURDER;
			else
				return WEAPON_TUBA_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Tuba(float req)
{
	// nothing to do here; particles of tuba are handled differently
	// WEAPONTODO

	switch(req)
	{
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
