#ifndef IMPLEMENTATION

const int DDSF_SETUP = BIT(0);
const int DDSF_MOVE = BIT(1);
const int DDSF_AIM = BIT(2);
const int DDSF_FIRE = BIT(3);
const int DDSF_ANIMATE = BIT(4);
const int DDSF_HEALTH = BIT(5);
const int DDSF_DIE = BIT(6);
const int DDSF_TURN = BIT(7);

REGISTER_NET_LINKED(ENT_CLIENT_DOTC_DRONE)

REGISTER_NET_TEMP(TE_CSQC_DOTC_DRONEDIE)

#ifdef SVQC
AUTOCVAR(g_dotc_gib_upspeed, float, 250, "");
AUTOCVAR(g_dotc_gib_side1speed1, float, 40, "");
AUTOCVAR(g_dotc_gib_side1speed2, float, 800, "");
AUTOCVAR(g_dotc_gib_side2speed1, float, 400, "");
AUTOCVAR(g_dotc_gib_side2speed2, float, 800, "");

AUTOCVAR(g_dotc_squads_maxofdist, float, 100, "");
AUTOCVAR(g_dotc_squads_teletime, float, 1, "");

IntrusiveList g_dotc_drones;
STATIC_INIT(g_dotc_drones) { g_dotc_drones = IL_NEW(); }
#endif

.entity drone_gun;
.entity drone_turret;

#else

void dotc_drone_remove(entity this)
{
	if(this.drone_turret) { delete(this.drone_turret); this.drone_turret = NULL; }
	if(this.drone_gun) { delete(this.drone_gun); this.drone_gun = NULL; }
#ifdef SVQC
	WaypointSprite_Kill(this.waypointsprite_attached);
#endif
}

#ifdef SVQC

AUTOCVAR(g_dotc_waypointsprites_squads, bool, true, "");
AUTOCVAR(g_dotc_waypointsprites_drones, bool, false, "");

void gib_groundboom(entity this, entity toucher)
{
	this.cnt = this.cnt -1;

	if(this.cnt > 0)
		return;

	sound (this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
	Send_Effect(EFFECT_ROCKET_EXPLODE, this.origin, '0 0 0', 1);

	delete(this);
}

void dotc_sv_gibshower(entity this, vector where)
{
	int i;
	entity gib;

	sound (this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
	Send_Effect(EFFECT_ROCKET_EXPLODE, where, '0 0 0', 1);

	for(i = 1; i < (random() * 5); ++i)
	{
		gib = spawn();
		setmodel(gib, MDL_DOTC_GIB_RANDOM());
		setorigin(gib, where);

		gib.velocity 	= ('0 0 1' * ( autocvar_g_dotc_gib_upspeed 	 + random() * autocvar_g_dotc_gib_upspeed))
						+ ('0 1 0' * (-autocvar_g_dotc_gib_side1speed1 + random() * autocvar_g_dotc_gib_side1speed2))
						+ ('0 0 1' * (-autocvar_g_dotc_gib_side2speed1 + random() * autocvar_g_dotc_gib_side2speed2));

		gib.gravity 	= 1;
		gib.solid 		= SOLID_CORPSE;
		set_movetype(gib, MOVETYPE_BOUNCE);
		gib.avelocity 	= randomvec() * 160;

		// cnt = bounce how many times before exploding.
		gib.cnt         = rint(random() * 5);
		settouch(gib, gib_groundboom);

		// Failsafe.
		SUB_SetFade(gib, time + 5, 2);
		setthink(gib, SUB_Remove);
		gib.nextthink   = time + 6;

		if(random() < 0.3)
		{
			//gib.effects = EF_FLAME;
			gib.modelflags |= MF_ROCKET;
			settouch(gib, gib_groundboom);
			gib.cnt = rint(random() * 2);
		}

		gib.effects |= EF_LOWPRECISION;
	}
}

void ghost_groundboom(entity this)
{
	if(this.lip > time)
	{
		this.cnt -= 1;
		if(this.cnt >= 0)
			return;
	}

	dotc_sv_gibshower(this, this.origin);
	delete(this);
}

void ghost_groundboom_touch(entity this, entity toucher)
{
	ghost_groundboom(this);
}

void te_csqc_dronedie(entity this)
{
	WriteHeader(MSG_BROADCAST, TE_CSQC_DOTC_DRONEDIE);

	WriteByte(MSG_BROADCAST, this.dotc_dronetype);
	
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);

	WriteCoord(MSG_BROADCAST, this.velocity_x);
	WriteCoord(MSG_BROADCAST, this.velocity_y);
	WriteCoord(MSG_BROADCAST, this.velocity_z);
	
	WriteCoord(MSG_BROADCAST, this.angles_x);	
	WriteCoord(MSG_BROADCAST, this.angles_y);
	WriteCoord(MSG_BROADCAST, this.angles_z);
}

void dotc_drone_die(entity this, bool silent)
{
	if(!silent)
	{
		if(autocvar_g_dotc_drones_dead_csqc)
			te_csqc_dronedie(this);
		else
		{

			//if(random() < 0.25)
			//	dotc_sv_gibshower(this.origin);
			if(this.mdl != "")
			{
				sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
				Send_Effect(EFFECT_ROCKET_EXPLODE, this.origin, '0 0 0', 1);

				entity ghost = spawn();
				setorigin(ghost, this.origin);
				_setmodel(ghost, this.mdl);

				vector vadd = ('0 0 1' * (autocvar_g_dotc_drones_dead_upspeed1 + random() * autocvar_g_dotc_drones_dead_upspeed2))
					 		+ ('0 1 0' * (-autocvar_g_dotc_drones_dead_side1speed1 + random() * autocvar_g_dotc_drones_dead_side1speed2))
					 		+ ('0 0 1' * (-autocvar_g_dotc_drones_dead_side2speed1 + random() * autocvar_g_dotc_drones_dead_side2speed2));

				ghost.velocity 	= this.velocity + vadd;
				ghost.avelocity = randomvec() * autocvar_g_dotc_drones_dead_spinnspeed;
				ghost.gravity 	= 0.5;

				ghost.solid 	= SOLID_CORPSE;
				set_movetype(ghost, MOVETYPE_BOUNCE);
				ghost.angles 	= this.angles;

				settouch(ghost, ghost_groundboom_touch);
				setthink(ghost, ghost_groundboom);
				ghost.lip = ghost.nextthink = time + (random() * 5);

				if(random() < 0.25)
				{
					ghost.effects = EF_FLAME;
					ghost.cnt = 1;
				}
				else
					ghost.cnt = 1 + rint(random() * 3);

				ghost.effects |= EF_LOWPRECISION;
			}
		}
	}

	WaypointSprite_Kill(this.waypointsprite_attached);

	if(this.squad)
	{
		this.squad.cnt -= 1;
		if(this.squad.waypointsprite_attached)
			WaypointSprite_UpdateHealth(this.squad.waypointsprite_attached, this.squad.cnt);
	}

	// unlink!
	this.squad = NULL;
	this.dotc_targetflags	    = DOTC_TARGET_NOT;
	this.target_validate_flags  = DOTC_TARGET_NOT;
	this.dotc_unittype 			= DOTC_UF_NONE;

	this.event_damage           = func_null;
	this.takedamage             = DAMAGE_NO;
	this.deadflag 				= DEAD_DEAD;

	setthink(this, SUB_Remove); // gun and turret already deleted
	this.nextthink = time + 0.1;

	if(this.drone_gun)
		delete(this.drone_gun);

	if(this.drone_turret)
		delete(this.drone_turret);

}

#define dotc_bob(t,s,l) (t).velocity_z += sin(((t).cnt + time) * s) * l

/*void _dotc_bob(entity this, float bob_speed, float bob_length)
{
	this.velocity_z += sin((this.cnt + time) * bob_speed) * bob_length;
}*/

float dotc_hoverforce(entity this, float spring_length, float spring_force)
{
	tracebox(this.origin + '0 0 16', this.mins, this.maxs, this.origin - '0 0 1' * spring_length, MOVE_NORMAL, this);
	return -800 + ((1 - trace_fraction) * spring_force);
}

void dotc_droneyaw(entity this)
{
	if(this.squad.enemy)
		dotc_ai_track_targetoffset = dotc_ai_moveangle(this, '0 0 0', vectoangles(normalize(this.squad.enemy.origin - this.origin)) , '360 360 360');
	else
		dotc_ai_track_targetoffset = dotc_ai_moveangle(this, '0 0 0', this.squad.angles, '360 360 360');

	this.avelocity_y = bound(this.dotc_turnspeed * -1, dotc_ai_track_targetoffset_y, this.dotc_turnspeed);
	this.SendFlags |= DDSF_TURN| DDSF_MOVE;
}


void dotc_drone_teleto(entity this, vector v_dest)
{
	//sound (this, CHAN_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTN_NORM);
	//pointparticles(particleeffectnum("teleport"), this.origin, '0 0 0', 1);
	//pointparticles(particleeffectnum("teleport"), v_dest, '0 0 0', 1);

	setorigin(this, v_dest);
}

#if 0
/*
  Unused, perhaps related to debugging
*/
.vector step_move_pos;
.float step_move_time;

int dotc_step_move_testloc(entity this, vector _loc)
{
	tracebox(this.origin, this.mins, this.maxs, _loc, MOVE_NORMAL, this);
	if(trace_fraction <= 0.9)
		return -1;

	return 0;
}

bool dotc_step_move(entity this)
{
	float best = 0;
	if(this.step_move_time < time || vdist(this.origin - this.moveto, <, 64))
	{
		this.step_move_time = time + 5;
		vector dir = normalize(this.origin - this.moveto);
		vector loc = dir * 256 + this.origin;
		if(!dotc_step_move_testloc(this, loc))
		{
			dist = vlen2(this.origin - this.moveto);
			if(!best || best > dist)
			{
				best = dist;
				this.step_move_pos = loc;
			}
		}
	}
	return false;
}
#endif

vector dotc_drone_move(entity this, vector move_where, float speed_min, float dist_max, bool blend)
{
	vector dist = move_where - this.origin;

	if(this.lip < time && vdist(dist, >, autocvar_g_dotc_squads_maxofdist))
		this.lip = time + autocvar_g_dotc_squads_teletime;
	else
		this.lip = 0;

	vector mdir = normalize(move_where - this.origin);
	mdir = steerlib_beamsteer(this, mdir, 128, 8, 8, 256);

	return mdir * bound(speed_min, (vlen(dist) / dist_max) * this.dotc_movespeed, this.dotc_movespeed);
}

void dotc_drone_damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{
	if(DOTC_FFCHECK(this, attacker))
		return;

	// track dmg by player ...
	if(IS_CLIENT(attacker))
		this.dmgtime = time + 2;

	if ((this.health -= damage) <= 0)
	{
		if(this.dmgtime >= time)
		{
			dotc_CreditSpawn(this, CENTER_OR_VIEWOFS(this), this.dotc_deathcredits);
			// ... and drop a credit if drone was hurt by a player recently
			if(IS_CLIENT(attacker))
			{
				// But only give player score for acctuall kill shots.
				PlayerScore_Add(attacker, SP_DOTC_DRONE_KILLS, 1);
				PlayerScore_Add(attacker, SP_SCORE, this.dotc_deathcredits);
			}
		}
		dotc_drone_die(this, false);
	}
	this.punchvector = force;
}

/*void dotc_drone_touch()
{
	//dprint("^3Drone touch!\n");
}*/

bool dotc_drone_send(entity this, entity to, int sf);
entity dotc_spawn_drone( entity sqd, entity own,
						 Model body_model,
						 Model turret_model,
						 Model gun_model,
						 Model dead_model,
						 entity explodeffect,
						 void(entity this, entity thesquad, vector formation_loc, float tdelta) fp_framefunc,
						 void(entity this) fp_firefunc,
						 float dronetype)
{
	entity drone = spawn();
	drone.classname = "dotc_drone";
	drone.squad 	= sqd;
	drone.team 		= sqd.team;
	drone.owner		= own;
	drone.colormap 	= 1024 + (drone.team - 1) * 17;
	IL_PUSH(g_dotc_drones, drone);

	drone.dotc_dronetype = dronetype;
	//drone.touch = dotc_drone_touch;
	drone.reset = dotc_drone_remove;
	drone.entremove = dotc_drone_remove;

	// setorigin(drone, sqd.origin);

	drone.dotc_targetflags		= DOTC_TARGET_TURRETS | DOTC_TARGET_DRONES;
	drone.target_validate_flags = DOTC_TARGET_TURRETS | DOTC_TARGET_DRONES;

	drone.solid 			= SOLID_SLIDEBOX;
	set_movetype(drone, MOVETYPE_BOUNCE);
	drone.takedamage 		= DAMAGE_AIM;
	drone.deadflag 			= DEAD_NO;
	drone.dotc_unittype 	= DOTC_UF_DRONE;

	drone.event_damage 		= dotc_drone_damage;

	//drone.cvar_basename 	= cvar_base_name;
	//fp_initfunc(drone);

	drone.drone_fire = fp_firefunc;
	drone.drone_frame = fp_framefunc;

	setmodel(drone, body_model);

	drone.glowmod = (drone.team) ? Team_ColorRGB(drone.team) : '1 1 1';

	drone.mdl = dead_model.model_str();

	if(turret_model != MDL_Null)
	{
		drone.drone_turret = spawn();
		setmodel(drone.drone_turret, turret_model);
		setattachment(drone.drone_turret, drone, "turret");

		set_movetype(drone.drone_turret, MOVETYPE_NOCLIP);
		drone.drone_turret.flags 		= FL_NOTARGET;
		drone.drone_turret.colormap 	= drone.colormap;
		drone.drone_turret.glowmod      = drone.glowmod;
		if(gun_model != MDL_Null)
		{
			drone.drone_gun = spawn();
			setmodel(drone.drone_gun, gun_model);
			setattachment(drone.drone_gun, drone.drone_turret, "gun");

			set_movetype(drone.drone_gun, MOVETYPE_NOCLIP);
			drone.drone_gun.flags 		= FL_NOTARGET;
			drone.drone_gun.colormap 	= drone.colormap;
			drone.drone_gun.glowmod     = drone.glowmod;
		}
	}

	// use to offset stuff like hover-bobbing etc.
	drone.cnt = random();
	drone.explode_fx = explodeffect;

	// Update squad unit count
	sqd.cnt += 1;

	// Make it appear on the minimap
	
	if(autocvar_g_dotc_waypointsprites_drones)
	{
		entity wp = WaypointSprite_Spawn(WP_Null, 0, 1024, drone, '0 0 64', NULL, drone.team, drone, waypointsprite_attached, 2, RADARICON_Drone);
		wp.colormod = ((drone.team) ? Team_ColorRGB(drone.team) : '1 1 1');
		WaypointSprite_UpdateTeamRadar(drone.waypointsprite_attached, RADARICON_Drone, ((drone.team) ? colormapPaletteColor(drone.team - 1, false) : '1 1 1'));
	}

	drone.dotc_dronetype = dronetype;
	Net_LinkEntity(drone, true, 0, dotc_drone_send);
	drone.SendFlags = DDSF_SETUP;
	return drone;
}

bool dotc_drone_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_DOTC_DRONE);
	WriteByte(MSG_ENTITY, sf);

	if(sf & DDSF_SETUP)
	{

		WriteByte(MSG_ENTITY, this.dotc_dronetype);
		WriteByte(MSG_ENTITY, this.team);
	}

	if(sf & DDSF_MOVE)
	{
		WriteCoord(MSG_ENTITY, this.origin_x);
		WriteCoord(MSG_ENTITY, this.origin_y);
		WriteCoord(MSG_ENTITY, this.origin_z);

		WriteCoord(MSG_ENTITY, this.velocity_x);
		WriteCoord(MSG_ENTITY, this.velocity_y);
		WriteCoord(MSG_ENTITY, this.velocity_z);
	}

	if(sf & DDSF_TURN)
	{
		WriteCoord(MSG_ENTITY, this.angles_x);
		WriteCoord(MSG_ENTITY, this.angles_y);
		//WriteCoord(MSG_ENTITY, this.angles_z);
	}

	if(sf & DDSF_AIM)
	{
		if(this.drone_gun)
			WriteCoord(MSG_ENTITY, this.drone_gun.angles_x);
		else
			WriteCoord(MSG_ENTITY, this.drone_turret.angles_x);

		WriteCoord(MSG_ENTITY, this.drone_turret.angles_y);
		//WriteCoord(MSG_ENTITY, this.tur_head.angles_z);
	}

	if(sf & DDSF_FIRE)
	{
		//WriteCoord(MSG_ENTITY, time);
	}

	if(sf & DDSF_ANIMATE)
	{
		WriteCoord(MSG_ENTITY, time);
		WriteByte(MSG_ENTITY, this.frame);
	}

	return true;

}
#elif defined(CSQC)

REGISTER_MUTATOR(cl_drones, true);

MUTATOR_HOOKFUNCTION(cl_drones, Ent_Projectile)
{
	entity proj = M_ARGV(0, entity);

#define HANDLE(id) case PROJECTILE_##id: setmodel(proj, MDL_PROJECTILE_##id);
	switch(proj.cnt)
	{
		HANDLE(DOTC_DRONE_SCOUT)   proj.traileffect = EFFECT_Null.m_id; return true;
		HANDLE(DOTC_DRONE_LTANK)   proj.traileffect = EFFECT_Null.m_id; return true;
		HANDLE(DOTC_DRONE_TANK)    proj.traileffect = EFFECT_Null.m_id; return true;
		HANDLE(DOTC_DRONE_HTANK)   proj.traileffect = EFFECT_Null.m_id; return true;
		HANDLE(DOTC_DRONE_RART)    proj.traileffect = EFFECT_RACER_ROCKET_TRAIL.m_id; return true;
		HANDLE(DOTC_DRONE_GART)    proj.traileffect = EFFECT_Null.m_id; return true;
	}
#undef HANDLE
}

MUTATOR_HOOKFUNCTION(cl_drones, EditProjectile)
{
	entity proj = M_ARGV(0, entity);

	switch(proj.cnt)
	{
		case PROJECTILE_DOTC_DRONE_SCOUT:
			break;
		case PROJECTILE_DOTC_DRONE_LTANK:
			loopsound(proj, CH_SHOTS_SINGLE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
			proj.mins = '0 0 -4';
			proj.maxs = '0 0 -4';
			break;
		case PROJECTILE_DOTC_DRONE_TANK:
			loopsound(proj, CH_SHOTS_SINGLE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
			proj.mins = '0 0 -4';
			proj.maxs = '0 0 -4';
			break;
		case PROJECTILE_DOTC_DRONE_HTANK:
			loopsound(proj, CH_SHOTS_SINGLE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
			proj.mins = '0 0 -4';
			proj.maxs = '0 0 -4';
			break;
		case PROJECTILE_DOTC_DRONE_RART:
			loopsound(proj, CH_SHOTS_SINGLE, "weapons/rocket_fly.wav", VOL_BASE, ATTN_NORM);
			proj.mins = '-3 -3 -3';
			proj.maxs = '3 3 3';
			break;
		case PROJECTILE_DOTC_DRONE_GART:
			break;
	}
}


void dotc_drone_predraw(entity this)
{
	if(this.velocity)
		setorigin(this, this.oldorigin + this.velocity * (time - this.move_time));
	//InterpolateOrigin_Do();
}

void dotc_drone_construct(entity this, bool is_new)
{
	switch(this.dotc_dronetype)
	{
		case DOTC_DRONETYPE_SCOUT:
			this.drone_turret = spawn();
			setmodel(this, MDL_DOTC_DRONE_SCOUT_BODY);
			setmodel(this.drone_turret, MDL_DOTC_DRONE_SCOUT_TURRET);
			setsize(this, '-30 -30 -5', '30 30 25');
			break;

		case DOTC_DRONETYPE_LTANK:
			this.drone_turret = spawn();
			setmodel(this, MDL_DOTC_DRONE_LIGHT_BODY);
			setmodel(this.drone_turret, MDL_DOTC_DRONE_LIGHT_TURRET);
			setsize(this, drone_size_small_min, drone_size_small_max);
			break;

		case DOTC_DRONETYPE_TANK:
			this.drone_gun = spawn();
			this.drone_turret = spawn();
			setmodel(this, MDL_DOTC_DRONE_TANK_BODY);
			setmodel(this.drone_turret, MDL_DOTC_DRONE_TANK_TURRET);
			setmodel(this.drone_gun, MDL_DOTC_DRONE_TANK_GUN);
			setsize(this, drone_size_medium_min, drone_size_medium_max);
			break;

		case DOTC_DRONETYPE_HTANK: // FIXME
			this.drone_gun = spawn();
			this.drone_turret = spawn();
			setmodel(this, MDL_DOTC_DRONE_TANK_BODY);
			setmodel(this.drone_turret, MDL_DOTC_DRONE_TANK_TURRET);
			setmodel(this.drone_gun, MDL_DOTC_DRONE_TANK_GUN);
			setsize(this, drone_size_medium_min, drone_size_medium_max);
			break;

		case DOTC_DRONETYPE_RART:
			this.drone_gun = spawn();
			this.drone_turret = spawn();
			setmodel(this, MDL_DOTC_DRONE_RART_BODY);
			setmodel(this.drone_turret, MDL_DOTC_DRONE_RART_TURRET);
			setmodel(this.drone_gun, MDL_DOTC_DRONE_RART_GUN);
			setsize(this, drone_size_medium_min, drone_size_medium_max);
			break;

		case DOTC_DRONETYPE_GART:
			this.drone_gun = spawn();
			this.drone_turret = spawn();
			setmodel(this, MDL_DOTC_DRONE_GART_BODY);
			setmodel(this.drone_turret, MDL_DOTC_DRONE_GART_TURRET);
			setmodel(this.drone_gun, MDL_DOTC_DRONE_GART_GUN);
			setsize(this, drone_size_medium_min, drone_size_medium_max);
			break;

		case DOTC_DRONETYPE_GUARD: // FIXME
			this.drone_gun = spawn();
			this.drone_turret = spawn();
			setmodel(this, MDL_DOTC_DRONE_RART_BODY);
			setmodel(this.drone_turret, MDL_DOTC_DRONE_RART_TURRET);
			setmodel(this.drone_gun, MDL_DOTC_DRONE_RART_GUN);
			setsize(this, drone_size_medium_min, drone_size_medium_max);
			break;
		default:
			LOG_DEBUGF("Warning: Unknown drone type %d", this.dotc_dronetype);
			return;
	}

	this.solid = SOLID_SLIDEBOX;
	this.iflags |= IFLAG_ANGLES;
	this.drawmask = MASK_NORMAL;
	//setpredraw(this, dotc_drone_predraw);
	this.draw = dotc_drone_predraw;
	if (is_new) IL_PUSH(g_drawables, this);
	this.entremove = dotc_drone_remove;
	this.colormap = 1024 + this.team * 17;
	this.glowmod = (this.team) ? Team_ColorRGB(this.team) : '1 1 1';

	setattachment(this.drone_turret, this, "turret");

	if(this.drone_gun)
		setattachment(this.drone_gun, this.drone_turret, "gun");
}

NET_HANDLE(ENT_CLIENT_DOTC_DRONE, bool isnew)
{
	int sf = ReadByte();

	//InterpolateOrigin_Undo();
	//dprint("DT :", ftos(this.drone_type), "\n");
	if(sf & DDSF_SETUP)
	{
		this.dotc_dronetype = ReadByte();
		this.team = ReadByte() - 1;
		dotc_drone_construct(this, isnew);

	}

	if(sf & DDSF_MOVE)
	{
		this.oldorigin_x = ReadCoord();
		this.oldorigin_y = ReadCoord();
		this.oldorigin_z = ReadCoord();

		this.velocity_x = ReadCoord();
		this.velocity_y = ReadCoord();
		this.velocity_z = ReadCoord();

		setorigin(this, this.oldorigin);
		this.move_time = time;
		//dprint("Origin ", vtos(this.origin), "\n");
	}

	if(sf & DDSF_TURN)
	{
		this.angles_x = ReadCoord();
		this.angles_y = ReadCoord();
		//this.angles_z = ReadCoord();
	}

	if(sf & DDSF_AIM)
	{
		if(this.drone_gun)
			this.drone_gun.angles_x = ReadCoord();
		else
			this.drone_turret.angles_x = ReadCoord();

		this.drone_turret.angles_y = ReadCoord();
		//this.drone_turret.angles_z = ReadCoord();
	}

	if(sf & DDSF_FIRE)
	{
		//float _t = ReadCoord();
	}

	if(sf & DDSF_ANIMATE)
	{
		this.frame1time = ReadCoord();
		this.frame = ReadByte();
	}

	//InterpolateOrigin_Note();

	return true;
}
#endif

#endif
