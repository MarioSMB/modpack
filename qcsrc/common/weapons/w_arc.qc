#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ ARC,
/* function  */ W_Arc,
/* ammotype  */ ammo_cells,
/* impulse   */ 3,
/* flags     */ WEP_FLAG_NORMAL,
/* rating    */ BOT_PICKUP_RATING_HIGH,
/* color     */ '1 1 1',
/* modelname */ "shotguncannon",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairhlac 0.7",
/* wepimg    */ "weaponhlac",
/* refname   */ "arc",
/* wepname   */ _("Arc")
);

#define ARC_SETTINGS(w_cvar,w_prop) ARC_SETTINGS_LIST(w_cvar, w_prop, ARC, arc)
#define ARC_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, beam_ammo) \
	w_cvar(id, sn, NONE, beam_animtime) \
	w_cvar(id, sn, NONE, beam_botaimspeed) \
	w_cvar(id, sn, NONE, beam_botaimlifetime) \
	w_cvar(id, sn, NONE, beam_damage) \
	w_cvar(id, sn, NONE, beam_degreespersegment) \
	w_cvar(id, sn, NONE, beam_distancepersegment) \
	w_cvar(id, sn, NONE, beam_falloff_halflifedist) \
	w_cvar(id, sn, NONE, beam_falloff_maxdist) \
	w_cvar(id, sn, NONE, beam_falloff_mindist) \
	w_cvar(id, sn, NONE, beam_force) \
	w_cvar(id, sn, NONE, beam_healing_amax) \
	w_cvar(id, sn, NONE, beam_healing_aps) \
	w_cvar(id, sn, NONE, beam_healing_hmax) \
	w_cvar(id, sn, NONE, beam_healing_hps) \
	w_cvar(id, sn, NONE, beam_maxangle) \
	w_cvar(id, sn, NONE, beam_nonplayerdamage) \
	w_cvar(id, sn, NONE, beam_range) \
	w_cvar(id, sn, NONE, beam_refire) \
	w_cvar(id, sn, NONE, beam_returnspeed) \
	w_cvar(id, sn, NONE, beam_tightness) \
	w_cvar(id, sn, NONE, burst_ammo) \
	w_cvar(id, sn, NONE, burst_damage) \
	w_cvar(id, sn, NONE, burst_healing_aps) \
	w_cvar(id, sn, NONE, burst_healing_hps) \
	w_cvar(id, sn, NONE, overheat_max)/* maximum heat before jamming */ \
	w_cvar(id, sn, NONE, overheat_min)/* minimum heat to wait for cooldown */ \
	w_cvar(id, sn, NONE, beam_heat)   /* heat increase per second (primary) */ \
	w_cvar(id, sn, NONE, burst_heat)  /* heat increase per second (secondary) */ \
	w_cvar(id, sn, NONE, cooldown)    /* heat decrease per second when resting */ \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifndef MENUQC
#define ARC_MAX_SEGMENTS 20
vector arc_shotorigin[4];
.vector beam_start;
.vector beam_dir;
.vector beam_wantdir;
.float beam_type;

#define ARC_BT_MISS        0x00
#define ARC_BT_WALL        0x01
#define ARC_BT_HEAL        0x02
#define ARC_BT_HIT         0x03
#define ARC_BT_BURST_MISS  0x10
#define ARC_BT_BURST_WALL  0x11
#define ARC_BT_BURST_HEAL  0x12
#define ARC_BT_BURST_HIT   0x13
#define ARC_BT_BURSTMASK   0x10

#define ARC_SF_SETTINGS    1
#define ARC_SF_START       2
#define ARC_SF_WANTDIR     4
#define ARC_SF_BEAMDIR     8
#define ARC_SF_BEAMTYPE    16
#define ARC_SF_LOCALMASK   14
#endif
#ifdef SVQC
ARC_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.entity arc_beam;
.float arc_BUTTON_ATCK_prev; // for better animation control
.float beam_prev;
.float beam_initialized;
.float beam_bursting;
.float beam_teleporttime;
.float beam_heat; // (beam) amount of heat produced
.float arc_overheat; // (dropped arc/player) time during which it's too hot
.float arc_cooldown; // (dropped arc/player) cooling speed
.float arc_heat_percent; // (player) arc heat in [0,1] (stat)
#endif
#ifdef CSQC
void Ent_ReadArcBeam(float isnew);

.vector beam_color;
.float beam_alpha;
.float beam_thickness;
.float beam_traileffect;
.float beam_hiteffect;
.float beam_hitlight[4]; // 0: radius, 123: rgb
.float beam_muzzleeffect;
.float beam_muzzlelight[4]; // 0: radius, 123: rgb
.string beam_image;

.entity beam_muzzleentity;

.float beam_degreespersegment;
.float beam_distancepersegment;
.float beam_usevieworigin;
.float beam_initialized;
.float beam_maxangle;
.float beam_range;
.float beam_returnspeed;
.float beam_tightness;
.vector beam_shotorigin;

entity Draw_ArcBeam_callback_entity;
float Draw_ArcBeam_callback_last_thickness;
vector Draw_ArcBeam_callback_last_top; // NOTE: in same coordinate system as player.
vector Draw_ArcBeam_callback_last_bottom; // NOTE: in same coordinate system as player.
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_arc(void) { weapon_defaultspawnfunc(WEP_ARC); }

float W_Arc_Beam_Send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_ARC_BEAM);

	// Truncate information when this beam is displayed to the owner client
	// - The owner client has no use for beam start position or directions,
	//    it always figures this information out for itself with csqc code.
	// - Spectating the owner also truncates this information.
	float drawlocal = ((to == self.owner) || ((to.enemy == self.owner) && IS_SPEC(to)));
	if(drawlocal) { sf &= ~ARC_SF_LOCALMASK; }

	WriteByte(MSG_ENTITY, sf);

	if(sf & ARC_SF_SETTINGS) // settings information
	{
		WriteShort(MSG_ENTITY, WEP_CVAR(arc, beam_degreespersegment));
		WriteShort(MSG_ENTITY, WEP_CVAR(arc, beam_distancepersegment));
		WriteShort(MSG_ENTITY, WEP_CVAR(arc, beam_maxangle));
		WriteCoord(MSG_ENTITY, WEP_CVAR(arc, beam_range));
		WriteShort(MSG_ENTITY, WEP_CVAR(arc, beam_returnspeed));
		WriteByte(MSG_ENTITY, WEP_CVAR(arc, beam_tightness) * 10);

		WriteByte(MSG_ENTITY, drawlocal);
	}
	if(sf & ARC_SF_START) // starting location
	{
		WriteCoord(MSG_ENTITY, self.beam_start_x);
		WriteCoord(MSG_ENTITY, self.beam_start_y);
		WriteCoord(MSG_ENTITY, self.beam_start_z);
	}
	if(sf & ARC_SF_WANTDIR) // want/aim direction
	{
		WriteCoord(MSG_ENTITY, self.beam_wantdir_x);
		WriteCoord(MSG_ENTITY, self.beam_wantdir_y);
		WriteCoord(MSG_ENTITY, self.beam_wantdir_z);
	}
	if(sf & ARC_SF_BEAMDIR) // beam direction
	{
		WriteCoord(MSG_ENTITY, self.beam_dir_x);
		WriteCoord(MSG_ENTITY, self.beam_dir_y);
		WriteCoord(MSG_ENTITY, self.beam_dir_z);
	}
	if(sf & ARC_SF_BEAMTYPE) // beam type
	{
		WriteByte(MSG_ENTITY, self.beam_type);
	}

	return TRUE;
}

void Reset_ArcBeam(entity player, vector forward)
{
	if (!player.arc_beam) {
		return;
	}
	player.arc_beam.beam_dir = forward;
	player.arc_beam.beam_teleporttime = time;
}

float Arc_GetHeat_Percent(entity player)
{	
	if ( WEP_CVAR(arc, overheat_max) <= 0 ||  WEP_CVAR(arc, overheat_max) <= 0 )
	{
		player.arc_overheat = 0;
		return 0;
	}
	
	if ( player.arc_beam )
		return player.arc_beam.beam_heat/WEP_CVAR(arc, overheat_max);
	
	if ( player.arc_overheat > time )
	{
		return (player.arc_overheat-time) / WEP_CVAR(arc, overheat_max) 
			* player.arc_cooldown;
	}
	
	return 0;
}
void Arc_Player_SetHeat(entity player)
{
	player.arc_heat_percent = Arc_GetHeat_Percent(player);
	//dprint("Heat: ",ftos(player.arc_heat_percent*100),"%\n");
}

void W_Arc_Beam_Think(void)
{
	if(self != self.owner.arc_beam)
	{
		remove(self);
		return;
	}
	
	
	float burst = 0;
	if( self.owner.BUTTON_ATCK2 || self.beam_bursting)
	{
		if(!self.beam_bursting)
			self.beam_bursting = TRUE;
		burst = ARC_BT_BURSTMASK;
	}

	if(
		!IS_PLAYER(self.owner)
		||
		(self.owner.WEP_AMMO(ARC) <= 0 && !(self.owner.items & IT_UNLIMITED_WEAPON_AMMO))
		||
		self.owner.deadflag != DEAD_NO
		||
		(!self.owner.BUTTON_ATCK && !burst )
		||
		self.owner.frozen
		||
		self.owner.jb_isprisoned
		||
		(WEP_CVAR(arc, overheat_max) > 0 && self.beam_heat >= WEP_CVAR(arc, overheat_max))
	)
	{
		if ( WEP_CVAR(arc, cooldown) > 0 )
		{
			float cooldown_speed = 0;
			if ( self.beam_heat > WEP_CVAR(arc, overheat_min) && WEP_CVAR(arc, cooldown) > 0 )
			{
				cooldown_speed = WEP_CVAR(arc, cooldown);
			}
			else if ( !burst )
			{
				cooldown_speed = self.beam_heat / WEP_CVAR(arc, beam_refire);
			}
			
			if ( cooldown_speed )
			{
				self.owner.arc_overheat = time + self.beam_heat / cooldown_speed;
				self.owner.arc_cooldown = cooldown_speed;
			}
			
			if ( WEP_CVAR(arc, overheat_max) > 0 && self.beam_heat >= WEP_CVAR(arc, overheat_max) )
				pointparticles( particleeffectnum("TE_SPIKE"),
					self.beam_start, self.beam_wantdir, 24 );
		}
		
		if(self == self.owner.arc_beam) { self.owner.arc_beam = world; }
		entity oldself = self;
		self = self.owner;
		if(!WEP_ACTION(WEP_ARC, WR_CHECKAMMO1) && !WEP_ACTION(WEP_ARC, WR_CHECKAMMO2))
		{
			// note: this doesn't force the switch
			W_SwitchToOtherWeapon(self);
		}
		self = oldself;
		remove(self);
		return;
	}
	
	// decrease ammo
	float coefficient = frametime;
	if(!(self.owner.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		float rootammo;
		if(burst)
			{ rootammo = WEP_CVAR(arc, burst_ammo); }
		else
			{ rootammo = WEP_CVAR(arc, beam_ammo); }

		if(rootammo)
		{
			coefficient = min(coefficient, self.owner.WEP_AMMO(ARC) / rootammo);
			self.owner.WEP_AMMO(ARC) = max(0, self.owner.WEP_AMMO(ARC) - (rootammo * frametime));
		}
	}
	float heat_speed = burst ? WEP_CVAR(arc, burst_heat) : WEP_CVAR(arc, beam_heat);
	self.beam_heat = min( WEP_CVAR(arc, overheat_max), self.beam_heat + heat_speed*frametime );

	makevectors(self.owner.v_angle);

	W_SetupShot_Range(
		self.owner,
		TRUE,
		0,
		"",
		0,
		WEP_CVAR(arc, beam_damage) * coefficient,
		WEP_CVAR(arc, beam_range)
	);

	// After teleport, "lock" the beam until the teleport is confirmed.
	if (time < self.beam_teleporttime + ANTILAG_LATENCY(self.owner)) {
		w_shotdir = self.beam_dir;
	}

	// network information: shot origin and want/aim direction
	if(self.beam_start != w_shotorg)
	{
		self.SendFlags |= ARC_SF_START;
		self.beam_start = w_shotorg;
	}
	if(self.beam_wantdir != w_shotdir)
	{
		self.SendFlags |= ARC_SF_WANTDIR;
		self.beam_wantdir = w_shotdir;
	}

	if(!self.beam_initialized)
	{
		self.beam_dir = w_shotdir;
		self.beam_initialized = TRUE;
	}

	// WEAPONTODO: Detect player velocity so that the beam curves when moving too
	// idea: blend together self.beam_dir with the inverted direction the player is moving in
	// might have to make some special accomodation so that it only uses view_right and view_up

	// note that if we do this, it'll always be corrected to a maximum angle by beam_maxangle handling

	float segments; 
	if(self.beam_dir != w_shotdir)
	{
		// calculate how much we're going to move the end of the beam to the want position
		// WEAPONTODO (server and client):
		// blendfactor never actually becomes 0 in this situation, which is a problem
		// regarding precision... this means that self.beam_dir and w_shotdir approach
		// eachother, however they never actually become the same value with this method.
		// Perhaps we should do some form of rounding/snapping?
		float angle = vlen(w_shotdir - self.beam_dir) * RAD2DEG;
		if(angle && (angle > WEP_CVAR(arc, beam_maxangle)))
		{
			// if the angle is greater than maxangle, force the blendfactor to make this the maximum factor
			float blendfactor = bound(
				0,
				(1 - (WEP_CVAR(arc, beam_returnspeed) * frametime)),
				min(WEP_CVAR(arc, beam_maxangle) / angle, 1)
			);
			self.beam_dir = normalize((w_shotdir * (1 - blendfactor)) + (self.beam_dir * blendfactor));
		}
		else
		{
			// the radius is not too far yet, no worries :D
			float blendfactor = bound(
				0,
				(1 - (WEP_CVAR(arc, beam_returnspeed) * frametime)),
				1
			);
			self.beam_dir = normalize((w_shotdir * (1 - blendfactor)) + (self.beam_dir * blendfactor));
		}

		// network information: beam direction
		self.SendFlags |= ARC_SF_BEAMDIR;

		// calculate how many segments are needed
		float max_allowed_segments;

		if(WEP_CVAR(arc, beam_distancepersegment))
		{
			max_allowed_segments = min(
				ARC_MAX_SEGMENTS,
				1 + (vlen(w_shotdir / WEP_CVAR(arc, beam_distancepersegment)))
			);
		}
		else { max_allowed_segments = ARC_MAX_SEGMENTS; }

		if(WEP_CVAR(arc, beam_degreespersegment))
		{
			segments = bound(
				1, 
				(
					min(
						angle,
						WEP_CVAR(arc, beam_maxangle)
					)
					/
					WEP_CVAR(arc, beam_degreespersegment)
				),
				max_allowed_segments
			);
		}
		else { segments = 1; }
	}
	else { segments = 1; }

	vector beam_endpos = (w_shotorg + (self.beam_dir * WEP_CVAR(arc, beam_range)));
	vector beam_controlpoint = w_shotorg + w_shotdir * (WEP_CVAR(arc, beam_range) * (1 - WEP_CVAR(arc, beam_tightness)));

	float i;
	float new_beam_type = 0;
	vector last_origin = w_shotorg;
	for(i = 1; i <= segments; ++i)
	{
		// WEAPONTODO (client):
		// In order to do nice fading and pointing on the starting segment, we must always
		// have that drawn as a separate triangle... However, that is difficult to do when
		// keeping in mind the above problems and also optimizing the amount of segments
		// drawn on screen at any given time. (Automatic beam quality scaling, essentially)

		vector new_origin = bezier_quadratic_getpoint(
			w_shotorg,
			beam_controlpoint,
			beam_endpos,
			i / segments);
		vector new_dir = normalize(new_origin - last_origin);

		WarpZone_traceline_antilag(
			self.owner,
			last_origin,
			new_origin,
			MOVE_NORMAL,
			self.owner,
			ANTILAG_LATENCY(self.owner)
		);

		// Do all the transforms for warpzones right now, as we already
		// "are" in the post-trace system (if we hit a player, that's
		// always BEHIND the last passed wz).
		last_origin = trace_endpos;
		w_shotorg = WarpZone_TransformOrigin(WarpZone_trace_transform, w_shotorg);
		beam_controlpoint = WarpZone_TransformOrigin(WarpZone_trace_transform, beam_controlpoint);
		beam_endpos = WarpZone_TransformOrigin(WarpZone_trace_transform, beam_endpos);
		new_dir = WarpZone_TransformVelocity(WarpZone_trace_transform, new_dir);

		float is_player = (
			trace_ent.classname == "player"
			||
			trace_ent.classname == "body"
			||
			(trace_ent.flags & FL_MONSTER)
		);

		if(trace_ent && trace_ent.takedamage && (is_player || WEP_CVAR(arc, beam_nonplayerdamage)))
		{
			// calculate our own hit origin as trace_endpos tends to jump around annoyingly (to player origin?)
			// NO. trace_endpos should be just fine. If not,
			// that's an engine bug that needs proper debugging.
			vector hitorigin = trace_endpos;

			float falloff = ExponentialFalloff(
				WEP_CVAR(arc, beam_falloff_mindist),
				WEP_CVAR(arc, beam_falloff_maxdist),
				WEP_CVAR(arc, beam_falloff_halflifedist),
				vlen(WarpZone_UnTransformOrigin(WarpZone_trace_transform, hitorigin) - w_shotorg)
			);

			if(is_player && SAME_TEAM(self.owner, trace_ent))
			{
				float roothealth, rootarmor;
				if(burst)
				{
					roothealth = WEP_CVAR(arc, burst_healing_hps);
					rootarmor = WEP_CVAR(arc, burst_healing_aps);
				}
				else
				{
					roothealth = WEP_CVAR(arc, beam_healing_hps);
					rootarmor = WEP_CVAR(arc, beam_healing_aps);
				}

				if(trace_ent.health <= WEP_CVAR(arc, beam_healing_hmax) && roothealth)
				{
					trace_ent.health = min(
						trace_ent.health + (roothealth * coefficient),
						WEP_CVAR(arc, beam_healing_hmax)
					);
				}
				if(trace_ent.armorvalue <= WEP_CVAR(arc, beam_healing_amax) && rootarmor)
				{
					trace_ent.armorvalue = min(
						trace_ent.armorvalue + (rootarmor * coefficient),
						WEP_CVAR(arc, beam_healing_amax)
					);
				}

				// stop rot, set visual effect
				if(roothealth || rootarmor)
				{
					trace_ent.pauserothealth_finished = max(
						trace_ent.pauserothealth_finished,
						time + autocvar_g_balance_pause_health_rot
					);
					trace_ent.pauserotarmor_finished = max(
						trace_ent.pauserotarmor_finished,
						time + autocvar_g_balance_pause_armor_rot
					);
					new_beam_type = ARC_BT_HEAL;
				}
			}
			else
			{
				float rootdamage;
				if(is_player)
				{
					if(burst)
						{ rootdamage = WEP_CVAR(arc, burst_damage); }
					else
						{ rootdamage = WEP_CVAR(arc, beam_damage); }
				}
				else
					{ rootdamage = WEP_CVAR(arc, beam_nonplayerdamage); }

				if(accuracy_isgooddamage(self.owner, trace_ent))
				{
					accuracy_add(
						self.owner,
						WEP_ARC,
						0,
						rootdamage * coefficient * falloff
					);
				}

				Damage(
					trace_ent,
					self.owner,
					self.owner,
					rootdamage * coefficient * falloff,
					WEP_ARC,
					hitorigin,
					WEP_CVAR(arc, beam_force) * new_dir * coefficient * falloff
				);

				new_beam_type = ARC_BT_HIT;
			}
			break; 
		}
		else if(trace_fraction != 1)
		{
			// we collided with geometry
			new_beam_type = ARC_BT_WALL;
			break;
		}
	}

	// te_explosion(trace_endpos);

	// if we're bursting, use burst visual effects
	new_beam_type |= burst;

	// network information: beam type
	if(new_beam_type != self.beam_type)
	{
		self.SendFlags |= ARC_SF_BEAMTYPE;
		self.beam_type = new_beam_type;
	}

	self.owner.beam_prev = time;
	self.nextthink = time;
}

void W_Arc_Beam(float burst)
{

	// only play fire sound if 1 sec has passed since player let go the fire button
	if(time - self.beam_prev > 1)
	{
		sound(self, CH_WEAPON_A, W_Sound("lgbeam_fire"), VOL_BASE, ATTN_NORM);
	}

	entity beam = self.arc_beam = spawn();
	beam.classname = "W_Arc_Beam";
	beam.solid = SOLID_NOT;
	beam.think = W_Arc_Beam_Think;
	beam.owner = self;
	beam.movetype = MOVETYPE_NONE;
	beam.bot_dodge = TRUE;
	beam.bot_dodgerating = WEP_CVAR(arc, beam_damage);
	beam.beam_bursting = burst;
	Net_LinkEntity(beam, FALSE, 0, W_Arc_Beam_Send);

	entity oldself = self;
	self = beam;
	self.think();
	self = oldself;
}

void Arc_Smoke()
{
	makevectors(self.v_angle);
	W_SetupShot_Range(self,TRUE,0,"",0,0,0);
	if ( self.arc_overheat > time )
	{
		if ( self.arc_heat_percent > 0.75 )
			pointparticles( particleeffectnum("morphed_damage_hit"), w_shotorg, '0 0 0', 1 );
		if ( random() < self.arc_heat_percent )
			pointparticles( particleeffectnum("pipe_smoke"), w_shotorg, '0 0 1', 1 );
	}
	else if ( self.arc_beam && WEP_CVAR(arc, overheat_max) > 0 &&
			self.arc_beam.beam_heat > WEP_CVAR(arc, overheat_min) )
	{
		if ( random() < (self.arc_beam.beam_heat-WEP_CVAR(arc, overheat_min)) / 
				( WEP_CVAR(arc, overheat_max)-WEP_CVAR(arc, overheat_min) ) )
			pointparticles( particleeffectnum("pipe_smoke"), w_shotorg, '0 0 1', 1 );
	}
}

float W_Arc(float req)
{
	switch(req)
	{
		case WR_AIM:
		{
			if(WEP_CVAR(arc, beam_botaimspeed))
			{
				self.BUTTON_ATCK = bot_aim(
					WEP_CVAR(arc, beam_botaimspeed),
					0,
					WEP_CVAR(arc, beam_botaimlifetime),
					FALSE
				);
			}
			else
			{
				self.BUTTON_ATCK = bot_aim(
					1000000,
					0,
					0.001,
					FALSE
				);
			}
			return TRUE;
		}
		case WR_THINK:
		{
			Arc_Player_SetHeat(self);
			Arc_Smoke();
			
			if ( self.arc_overheat <= time )
			if(self.BUTTON_ATCK || self.BUTTON_ATCK2 || self.arc_beam.beam_bursting )
			{
			
				if(self.arc_BUTTON_ATCK_prev)
				{
					#if 0
					if(self.animstate_startframe == self.anim_shoot_x && self.animstate_numframes == self.anim_shoot_y)
						weapon_thinkf(WFRAME_DONTCHANGE, autocvar_g_balance_arc_primary_animtime, w_ready);
					else
					#endif
						weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(arc, beam_animtime), w_ready);
				}

				if((!self.arc_beam) || wasfreed(self.arc_beam))
				{
					if(weapon_prepareattack(!!self.BUTTON_ATCK2, 0))
					{
						W_Arc_Beam(!!self.BUTTON_ATCK2);
						
						if(!self.arc_BUTTON_ATCK_prev)
						{
							weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(arc, beam_animtime), w_ready);
							self.arc_BUTTON_ATCK_prev = 1;
						}
					}
				}
				
				return TRUE;
			}
			
			if(self.arc_BUTTON_ATCK_prev != 0)
			{
				weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(arc, beam_animtime), w_ready);
				ATTACK_FINISHED(self) = time + WEP_CVAR(arc, beam_refire) * W_WeaponRateFactor();
			}
			self.arc_BUTTON_ATCK_prev = 0;

			#if 0
			if(self.BUTTON_ATCK2)
			if(weapon_prepareattack(1, autocvar_g_balance_arc_secondary_refire))
			{
				W_Arc_Attack2();
				self.arc_count = autocvar_g_balance_arc_secondary_count;
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_arc_secondary_animtime, w_arc_checkattack);
				self.arc_secondarytime = time + autocvar_g_balance_arc_secondary_refire2 * W_WeaponRateFactor();
			}
			#endif

			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_shotguncannon.md3");
			precache_model("models/weapons/v_shotguncannon.md3");
			precache_model("models/weapons/h_shotguncannon.iqm");
			precache_sound(W_Sound("lgbeam_fire"));
			if(!arc_shotorigin[0])
			{
				arc_shotorigin[0] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_ARC), FALSE, FALSE, 1);
				arc_shotorigin[1] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_ARC), FALSE, FALSE, 2);
				arc_shotorigin[2] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_ARC), FALSE, FALSE, 3);
				arc_shotorigin[3] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_ARC), FALSE, FALSE, 4);
			}
			ARC_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			return ((!WEP_CVAR(arc, beam_ammo)) || (self.WEP_AMMO(ARC) > 0));
		}
		case WR_CHECKAMMO2:
		{
			return WEP_CVAR(arc, overheat_max) > 0 &&
				((!WEP_CVAR(arc, burst_ammo)) || (self.WEP_AMMO(ARC) > 0));
		}
		case WR_CONFIG:
		{
			ARC_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_KILLMESSAGE:
		{
			return WEAPON_ARC_MURDER;
		}
		case WR_DROP:
		{
			weapon_dropevent_item.arc_overheat = self.arc_overheat;
			weapon_dropevent_item.arc_cooldown = self.arc_cooldown;
			self.arc_overheat = 0;
			self.arc_cooldown = 0;
			return TRUE;
		}
		case WR_PICKUP:
		{
			if ( !client_hasweapon(self, WEP_ARC, FALSE, FALSE) &&
				weapon_dropevent_item.arc_overheat > time )
			{
				self.arc_overheat = weapon_dropevent_item.arc_overheat;
				self.arc_cooldown = weapon_dropevent_item.arc_cooldown;
			}
			return TRUE;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
void Draw_ArcBeam_callback(vector start, vector hit, vector end)
{
	entity beam = Draw_ArcBeam_callback_entity;
	vector transformed_view_org;
	transformed_view_org = WarpZone_TransformOrigin(WarpZone_trace_transform, view_origin);

	// Thickdir shall be perpendicular to the beam and to the view-to-beam direction (WEAPONTODO: WHY)
	// WEAPONTODO: Wouldn't it be better to be perpendicular to the beam and to the view FORWARD direction?
	vector thickdir = normalize(cross(normalize(start - hit), transformed_view_org - start));

	vector hitorigin;

	// draw segment
	#if 0
	if(trace_fraction != 1)
	{
		// calculate our own hit origin as trace_endpos tends to jump around annoyingly (to player origin?)
		hitorigin = start + (Draw_ArcBeam_callback_new_dir * Draw_ArcBeam_callback_segmentdist * trace_fraction);
		hitorigin = WarpZone_TransformOrigin(WarpZone_trace_transform, hitorigin);
	}
	else
	{
		hitorigin = hit;
	}
	#else
	hitorigin = hit;
	#endif

	// decide upon thickness
	float thickness = beam.beam_thickness;

	// draw primary beam render
	vector top    = hitorigin + (thickdir * thickness);
	vector bottom = hitorigin - (thickdir * thickness);
	
	vector last_top = WarpZone_TransformOrigin(WarpZone_trace_transform, Draw_ArcBeam_callback_last_top);
	vector last_bottom = WarpZone_TransformOrigin(WarpZone_trace_transform, Draw_ArcBeam_callback_last_bottom);

	R_BeginPolygon(beam.beam_image, DRAWFLAG_NORMAL); // DRAWFLAG_ADDITIVE
	R_PolygonVertex(
		top,
		'0 0.5 0' + ('0 0.5 0' * (thickness / beam.beam_thickness)),
		beam.beam_color,
		beam.beam_alpha
	);
	R_PolygonVertex(
		last_top,
		'0 0.5 0' + ('0 0.5 0' * (Draw_ArcBeam_callback_last_thickness / beam.beam_thickness)),
		beam.beam_color,
		beam.beam_alpha
	);
	R_PolygonVertex(
		last_bottom,
		'0 0.5 0' * (1 - (Draw_ArcBeam_callback_last_thickness / beam.beam_thickness)),
		beam.beam_color,
		beam.beam_alpha
	);
	R_PolygonVertex(
		bottom,
		'0 0.5 0' * (1 - (thickness / beam.beam_thickness)),
		beam.beam_color,
		beam.beam_alpha
	);
	R_EndPolygon();

	// draw trailing particles
	// NOTES:
	//  - Don't use spammy particle counts here, use a FEW small particles around the beam
	//  - We're not using WarpZone_TrailParticles here because we will handle warpzones ourselves.
	if(beam.beam_traileffect)
	{
		trailparticles(beam, beam.beam_traileffect, start, hitorigin);
	}

	// set up for the next 
	Draw_ArcBeam_callback_last_thickness = thickness;
	Draw_ArcBeam_callback_last_top = WarpZone_UnTransformOrigin(WarpZone_trace_transform, top);
	Draw_ArcBeam_callback_last_bottom = WarpZone_UnTransformOrigin(WarpZone_trace_transform, bottom);
}

void Reset_ArcBeam(void)
{
	entity e;
	for (e = world; (e = findfloat(e, beam_usevieworigin, 1)); ) {
		e.beam_initialized = FALSE;
	}
	for (e = world; (e = findfloat(e, beam_usevieworigin, 2)); ) {
		e.beam_initialized = FALSE;
	}
}

void Draw_ArcBeam(void)
{
	if(!self.beam_usevieworigin)
	{
		InterpolateOrigin_Do();
	}

	// origin = beam starting origin
	// v_angle = wanted/aim direction
	// angles = current direction of beam

	vector start_pos;
	vector wantdir; //= view_forward;
	vector beamdir; //= self.beam_dir;

	float segments;
	if(self.beam_usevieworigin)
	{
		// WEAPONTODO:
		// Currently we have to replicate nearly the same method of figuring
		// out the shotdir that the server does... Ideally in the future we
		// should be able to acquire this from a generalized function built
		// into a weapon system for client code. 

		// find where we are aiming
		makevectors(warpzone_save_view_angles);
		vector forward = v_forward;
		vector right = v_right;
		vector up = v_up;

		// decide upon start position
		if(self.beam_usevieworigin == 2)
			{ start_pos = warpzone_save_view_origin; }
		else
			{ start_pos = self.origin; }

		// trace forward with an estimation
		WarpZone_TraceLine(
			start_pos,
			start_pos + forward * self.beam_range,
			MOVE_NOMONSTERS,
			self
		);

		// untransform in case our trace went through a warpzone
		vector end_pos = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);

		// un-adjust trueaim if shotend is too close
		if(vlen(end_pos - start_pos) < g_trueaim_minrange)
			end_pos = start_pos + (forward * g_trueaim_minrange);

		// move shot origin to the actual gun muzzle origin
		vector origin_offset =
			  right * -self.beam_shotorigin_y 
			+ up * self.beam_shotorigin_z;

		start_pos = start_pos + origin_offset;

		// Move it also forward, but only as far as possible without hitting anything. Don't poke into walls!
		traceline(start_pos, start_pos + forward * self.beam_shotorigin_x, MOVE_NORMAL, self);
		start_pos = trace_endpos;

		// calculate the aim direction now
		wantdir = normalize(end_pos - start_pos);

		if(!self.beam_initialized)
		{
			self.beam_dir = wantdir;
			self.beam_initialized = TRUE;
		}

		if(self.beam_dir != wantdir)
		{
			// calculate how much we're going to move the end of the beam to the want position
			// WEAPONTODO (server and client):
			// blendfactor never actually becomes 0 in this situation, which is a problem
			// regarding precision... this means that self.beam_dir and w_shotdir approach
			// eachother, however they never actually become the same value with this method.
			// Perhaps we should do some form of rounding/snapping?
			float angle = vlen(wantdir - self.beam_dir) * RAD2DEG;
			if(angle && (angle > self.beam_maxangle))
			{
				// if the angle is greater than maxangle, force the blendfactor to make this the maximum factor
				float blendfactor = bound(
					0,
					(1 - (self.beam_returnspeed * frametime)),
					min(self.beam_maxangle / angle, 1)
				);
				self.beam_dir = normalize((wantdir * (1 - blendfactor)) + (self.beam_dir * blendfactor));
			}
			else
			{
				// the radius is not too far yet, no worries :D
				float blendfactor = bound(
					0,
					(1 - (self.beam_returnspeed * frametime)),
					1
				);
				self.beam_dir = normalize((wantdir * (1 - blendfactor)) + (self.beam_dir * blendfactor));
			}

			// calculate how many segments are needed
			float max_allowed_segments;

			if(self.beam_distancepersegment)
			{
				max_allowed_segments = min(
					ARC_MAX_SEGMENTS,
					1 + (vlen(wantdir / self.beam_distancepersegment))
				);
			}
			else { max_allowed_segments = ARC_MAX_SEGMENTS; }

			if(self.beam_degreespersegment)
			{
				segments = bound(
					1, 
					(
						min(
							angle,
							self.beam_maxangle
						)
						/
						self.beam_degreespersegment
					),
					max_allowed_segments
				);
			}
			else { segments = 1; }
		}
		else { segments = 1; }

		// set the beam direction which the rest of the code will refer to
		beamdir = self.beam_dir;

		// finally, set self.angles to the proper direction so that muzzle attachment points in proper direction
		self.angles = fixedvectoangles2(forward, up); // TODO(Samual): is this == warpzone_save_view_angles?
	}
	else
	{
		// set the values from the provided info from the networked entity
		start_pos = self.origin;
		wantdir = self.v_angle;
		beamdir = self.angles;

		if(beamdir != wantdir)
		{
			float angle = vlen(wantdir - beamdir) * RAD2DEG;

			// calculate how many segments are needed
			float max_allowed_segments;

			if(self.beam_distancepersegment)
			{
				max_allowed_segments = min(
					ARC_MAX_SEGMENTS,
					1 + (vlen(wantdir / self.beam_distancepersegment))
				);
			}
			else { max_allowed_segments = ARC_MAX_SEGMENTS; }

			if(self.beam_degreespersegment)
			{
				segments = bound(
					1, 
					(
						min(
							angle,
							self.beam_maxangle
						)
						/
						self.beam_degreespersegment
					),
					max_allowed_segments
				);
			}
			else { segments = 1; }
		}
		else { segments = 1; }
	}

	setorigin(self, start_pos);
	self.beam_muzzleentity.angles_z = random() * 360; // WEAPONTODO: use avelocity instead?

	vector beam_endpos = (start_pos + (beamdir * self.beam_range));
	vector beam_controlpoint = start_pos + wantdir * (self.beam_range * (1 - self.beam_tightness));

	Draw_ArcBeam_callback_entity = self;
	Draw_ArcBeam_callback_last_thickness = 0;
	Draw_ArcBeam_callback_last_top = start_pos;
	Draw_ArcBeam_callback_last_bottom = start_pos;

	vector last_origin = start_pos;
	vector original_start_pos = start_pos;

	float i;
	for(i = 1; i <= segments; ++i)
	{
		// WEAPONTODO (client):
		// In order to do nice fading and pointing on the starting segment, we must always
		// have that drawn as a separate triangle... However, that is difficult to do when
		// keeping in mind the above problems and also optimizing the amount of segments
		// drawn on screen at any given time. (Automatic beam quality scaling, essentially)

		vector new_origin = bezier_quadratic_getpoint(
			start_pos,
			beam_controlpoint,
			beam_endpos,
			i / segments);

		WarpZone_TraceBox_ThroughZone(
			last_origin,
			'0 0 0',
			'0 0 0',
			new_origin,
			MOVE_NORMAL,
			world,
			world,
			Draw_ArcBeam_callback
		);

		// Do all the transforms for warpzones right now, as we already "are" in the post-trace
		// system (if we hit a player, that's always BEHIND the last passed wz).
		last_origin = trace_endpos;
		start_pos = WarpZone_TransformOrigin(WarpZone_trace_transform, start_pos);
		beam_controlpoint = WarpZone_TransformOrigin(WarpZone_trace_transform, beam_controlpoint);
		beam_endpos = WarpZone_TransformOrigin(WarpZone_trace_transform, beam_endpos);
		beamdir = WarpZone_TransformVelocity(WarpZone_trace_transform, beamdir);
		Draw_ArcBeam_callback_last_top = WarpZone_TransformOrigin(WarpZone_trace_transform, Draw_ArcBeam_callback_last_top);
		Draw_ArcBeam_callback_last_bottom = WarpZone_TransformOrigin(WarpZone_trace_transform, Draw_ArcBeam_callback_last_bottom);

		if(trace_fraction < 1) { break; }
	}

	// visual effects for startpoint and endpoint
	if(self.beam_hiteffect)
	{
		// FIXME we really should do this on the server so it actually
		// matches gameplay. What this client side stuff is doing is no
		// more than guesswork.
		pointparticles(
			self.beam_hiteffect,
			last_origin,
			beamdir * -1,
			frametime * 2
		);
	}
	if(self.beam_hitlight[0])
	{
		adddynamiclight(
			last_origin,
			self.beam_hitlight[0],
			vec3(
				self.beam_hitlight[1],
				self.beam_hitlight[2],
				self.beam_hitlight[3]
			)
		);
	}
	if(self.beam_muzzleeffect)
	{
		pointparticles(
			self.beam_muzzleeffect,
			original_start_pos + wantdir * 20,
			wantdir * 1000,
			frametime * 0.1
		);
	}
	if(self.beam_muzzlelight[0])
	{
		adddynamiclight(
			original_start_pos + wantdir * 20,
			self.beam_muzzlelight[0],
			vec3(
				self.beam_muzzlelight[1],
				self.beam_muzzlelight[2],
				self.beam_muzzlelight[3]
			)
		);
	}

	// cleanup
	Draw_ArcBeam_callback_entity = world;
	Draw_ArcBeam_callback_last_thickness = 0;
	Draw_ArcBeam_callback_last_top = '0 0 0';
	Draw_ArcBeam_callback_last_bottom = '0 0 0';
}

void Remove_ArcBeam(void)
{
	remove(self.beam_muzzleentity);
	sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTEN_NORM);
}

void Ent_ReadArcBeam(float isnew)
{
	float sf = ReadByte();
	entity flash;

	if(isnew)
	{
		// calculate shot origin offset from gun alignment
		float gunalign = autocvar_cl_gunalign;
		if(gunalign != 1 && gunalign != 2 && gunalign != 4)
			gunalign = 3; // default value
		--gunalign;

		self.beam_shotorigin = arc_shotorigin[gunalign];

		// set other main attributes of the beam
		self.draw = Draw_ArcBeam;
		self.entremove = Remove_ArcBeam;
		sound(self, CH_SHOTS_SINGLE, "weapons/lgbeam_fly.wav", VOL_BASE, ATTEN_NORM);

		flash = spawn();
		flash.owner = self;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT;
		flash.drawmask = MASK_NORMAL;
		flash.solid = SOLID_NOT;
		flash.avelocity_z = 5000;
		setattachment(flash, self, "");
		setorigin(flash, '0 0 0');

		self.beam_muzzleentity = flash;
	}
	else
	{
		flash = self.beam_muzzleentity;
	}

	if(sf & ARC_SF_SETTINGS) // settings information
	{
		self.beam_degreespersegment = ReadShort();
		self.beam_distancepersegment = ReadShort();
		self.beam_maxangle = ReadShort();
		self.beam_range = ReadCoord();
		self.beam_returnspeed = ReadShort();
		self.beam_tightness = (ReadByte() / 10);

		if(ReadByte())
		{
			if(autocvar_chase_active)
				{ self.beam_usevieworigin = 1; }
			else // use view origin
				{ self.beam_usevieworigin = 2; }
		}
		else
		{
			self.beam_usevieworigin = 0;
		}
	}

	if(!self.beam_usevieworigin)
	{
		// self.iflags = IFLAG_ORIGIN | IFLAG_ANGLES | IFLAG_V_ANGLE; // why doesn't this work?
		self.iflags = IFLAG_ORIGIN;

		InterpolateOrigin_Undo();
	}

	if(sf & ARC_SF_START) // starting location
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}
	else if(self.beam_usevieworigin) // infer the location from player location
	{
		if(self.beam_usevieworigin == 2)
		{
			// use view origin
			self.origin = view_origin;
		}
		else
		{
			// use player origin so that third person display still works
			self.origin = getplayerorigin(player_localnum) + ('0 0 1' * getstati(STAT_VIEWHEIGHT));
		}
	}

	setorigin(self, self.origin);

	if(sf & ARC_SF_WANTDIR) // want/aim direction
	{
		self.v_angle_x = ReadCoord();
		self.v_angle_y = ReadCoord();
		self.v_angle_z = ReadCoord();
	}

	if(sf & ARC_SF_BEAMDIR) // beam direction
	{
		self.angles_x = ReadCoord();
		self.angles_y = ReadCoord();
		self.angles_z = ReadCoord();
	}

	if(sf & ARC_SF_BEAMTYPE) // beam type
	{
		self.beam_type = ReadByte();
		switch(self.beam_type)
		{
			case ARC_BT_MISS:
			{
				self.beam_color = '-1 -1 1';
				self.beam_alpha = 0.5;
				self.beam_thickness = 8;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = particleeffectnum("electro_lightning");
				self.beam_hitlight[0] = 0;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 1;
				self.beam_hitlight[3] = 1;
				self.beam_muzzleeffect = -1; //particleeffectnum("nex_muzzleflash");
				self.beam_muzzlelight[0] = 0;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 1;
				self.beam_muzzlelight[3] = 1;
				if(self.beam_muzzleeffect >= 0)
				{
					self.beam_image = "particles/lgbeam";
					setmodel(flash, "models/flash.md3");
					flash.alpha = self.beam_alpha;
					flash.colormod = self.beam_color;
					flash.scale = 0.5;
				}
				break;
			}
			case ARC_BT_WALL: // grenadelauncher_muzzleflash healray_muzzleflash
			{
				self.beam_color = '0.5 0.5 1';
				self.beam_alpha = 0.5;
				self.beam_thickness = 8;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = particleeffectnum("electro_lightning");
				self.beam_hitlight[0] = 0;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 1;
				self.beam_hitlight[3] = 1;
				self.beam_muzzleeffect = -1; // particleeffectnum("grenadelauncher_muzzleflash");
				self.beam_muzzlelight[0] = 0;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 1;
				self.beam_muzzlelight[3] = 1;
				self.beam_image = "particles/lgbeam";
				if(self.beam_muzzleeffect >= 0)
				{
					setmodel(flash, "models/flash.md3");
					flash.alpha = self.beam_alpha;
					flash.colormod = self.beam_color;
					flash.scale = 0.5;
				}
				break;
			}
			case ARC_BT_HEAL:
			{
				self.beam_color = '0 1 0';
				self.beam_alpha = 0.5;
				self.beam_thickness = 8;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = particleeffectnum("healray_impact"); 
				self.beam_hitlight[0] = 0;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 1;
				self.beam_hitlight[3] = 1;
				self.beam_muzzleeffect = -1; //particleeffectnum("nex_muzzleflash");
				self.beam_muzzlelight[0] = 0;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 1;
				self.beam_muzzlelight[3] = 1;
				self.beam_image = "particles/lgbeam";
				if(self.beam_muzzleeffect >= 0)
				{
					self.beam_image = "particles/lgbeam";
					setmodel(flash, "models/flash.md3");
					flash.alpha = self.beam_alpha;
					flash.colormod = self.beam_color;
					flash.scale = 0.5;
				}
				break;
			}
			case ARC_BT_HIT:
			{
				self.beam_color = '1 0 1';
				self.beam_alpha = 0.5;
				self.beam_thickness = 8;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = particleeffectnum("electro_lightning"); 
				self.beam_hitlight[0] = 20;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 0;
				self.beam_hitlight[3] = 0;
				self.beam_muzzleeffect = -1; //particleeffectnum("nex_muzzleflash");
				self.beam_muzzlelight[0] = 50;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 0;
				self.beam_muzzlelight[3] = 0;
				self.beam_image = "particles/lgbeam";
				if(self.beam_muzzleeffect >= 0)
				{
					self.beam_image = "particles/lgbeam";
					setmodel(flash, "models/flash.md3");
					flash.alpha = self.beam_alpha;
					flash.colormod = self.beam_color;
					flash.scale = 0.5;
				}
				break;
			}
			case ARC_BT_BURST_MISS:
			{
				self.beam_color = '-1 -1 1';
				self.beam_alpha = 0.5;
				self.beam_thickness = 14;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = particleeffectnum("electro_lightning"); 
				self.beam_hitlight[0] = 0;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 1;
				self.beam_hitlight[3] = 1;
				self.beam_muzzleeffect = -1; //particleeffectnum("nex_muzzleflash");
				self.beam_muzzlelight[0] = 0;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 1;
				self.beam_muzzlelight[3] = 1;
				self.beam_image = "particles/lgbeam";
				setmodel(flash, "models/flash.md3");
				flash.alpha = self.beam_alpha;
				flash.colormod = self.beam_color;
				flash.scale = 0.5;
				break;
			}
			case ARC_BT_BURST_WALL:
			{
				self.beam_color = '0.5 0.5 1';
				self.beam_alpha = 0.5;
				self.beam_thickness = 14;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = particleeffectnum("electro_lightning"); 
				self.beam_hitlight[0] = 0;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 1;
				self.beam_hitlight[3] = 1;
				self.beam_muzzleeffect = -1; //particleeffectnum("nex_muzzleflash");
				self.beam_muzzlelight[0] = 0;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 1;
				self.beam_muzzlelight[3] = 1;
				self.beam_image = "particles/lgbeam";
				if(self.beam_muzzleeffect >= 0)
				{
					self.beam_image = "particles/lgbeam";
					setmodel(flash, "models/flash.md3");
					flash.alpha = self.beam_alpha;
					flash.colormod = self.beam_color;
					flash.scale = 0.5;
				}
				break;
			}
			case ARC_BT_BURST_HEAL:
			{
				self.beam_color = '0 1 0';
				self.beam_alpha = 0.5;
				self.beam_thickness = 14;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = particleeffectnum("electro_lightning"); 
				self.beam_hitlight[0] = 0;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 1;
				self.beam_hitlight[3] = 1;
				self.beam_muzzleeffect = -1; //particleeffectnum("nex_muzzleflash");
				self.beam_muzzlelight[0] = 0;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 1;
				self.beam_muzzlelight[3] = 1;
				self.beam_image = "particles/lgbeam";
				if(self.beam_muzzleeffect >= 0)
				{
					self.beam_image = "particles/lgbeam";
					setmodel(flash, "models/flash.md3");
					flash.alpha = self.beam_alpha;
					flash.colormod = self.beam_color;
					flash.scale = 0.5;
				}
				break;
			}
			case ARC_BT_BURST_HIT:
			{
				self.beam_color = '1 0 1';
				self.beam_alpha = 0.5;
				self.beam_thickness = 14;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = particleeffectnum("electro_lightning"); 
				self.beam_hitlight[0] = 0;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 1;
				self.beam_hitlight[3] = 1;
				self.beam_muzzleeffect = -1; //particleeffectnum("nex_muzzleflash");
				self.beam_muzzlelight[0] = 0;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 1;
				self.beam_muzzlelight[3] = 1;
				self.beam_image = "particles/lgbeam";
				if(self.beam_muzzleeffect >= 0)
				{
					self.beam_image = "particles/lgbeam";
					setmodel(flash, "models/flash.md3");
					flash.alpha = self.beam_alpha;
					flash.colormod = self.beam_color;
					flash.scale = 0.5;
				}
				break;
			}

			// shouldn't be possible, but lets make it colorful if it does :D
			default:
			{
				self.beam_color = randomvec();
				self.beam_alpha = 1;
				self.beam_thickness = 8;
				self.beam_traileffect = FALSE;
				self.beam_hiteffect = FALSE; 
				self.beam_hitlight[0] = 0;
				self.beam_hitlight[1] = 1;
				self.beam_hitlight[2] = 1;
				self.beam_hitlight[3] = 1;
				self.beam_muzzleeffect = -1; //particleeffectnum("nex_muzzleflash");
				self.beam_muzzlelight[0] = 0;
				self.beam_muzzlelight[1] = 1;
				self.beam_muzzlelight[2] = 1;
				self.beam_muzzlelight[3] = 1;
				self.beam_image = "particles/lgbeam";
				if(self.beam_muzzleeffect >= 0)
				{
					self.beam_image = "particles/lgbeam";
					setmodel(flash, "models/flash.md3");
					flash.alpha = self.beam_alpha;
					flash.colormod = self.beam_color;
					flash.scale = 0.5;
				}
				break;
			}
		}
	}

	if(!self.beam_usevieworigin)
	{
		InterpolateOrigin_Note();
	}
}

float W_Arc(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			// todo
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/lgbeam_fly.wav");
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
