#ifndef IMPLEMENTATION

#else

#ifdef SVQC

AUTOCVAR(g_dotc_squads_dont_chase, bool, true, "");

.float lastpushtime;

void dotc_dronesquad_think(entity this);
/*void SWITCH_IF_LESS(entity echeck, entity eset, .float ffld)
{
	if(echeck.ffld < eset.ffld)
		eset.ffld = echeck.ffld;
}*/

//#define SWITCH_IF(ec, es, cs, fl) if(ec.fl cs es.fl) es.fl = ec.fl

/*void SWITCH_IF_MORE(entity echeck, entity eset, .float ffld)
{
	if(echeck.ffld > eset.ffld)
		eset.ffld = echeck.ffld;
}*/

void dotc_squad_update(entity this)
{
	FOREACH_ENTITY_ENT(squad, this,
	{
		this.target_range = max(this.target_range, it.target_range);
		this.target_range_min = max(this.target_range_min, it.target_range_min);
		this.target_range_optimal = max(this.target_range_optimal, it.target_range_optimal);

		this.dotc_movespeed = min(this.dotc_movespeed, it.dotc_movespeed);
		this.dotc_turnspeed = min(this.dotc_turnspeed, it.dotc_turnspeed);
	});

	this.dotc_movespeed -= 50;   // or stragglers can never catch up
	this.target_range   += 100;  // A little extra range "for the chase" :)

	//dprint("squad selected speed:", ftos(this.dotc_movespeed), "\n");
	//dprint("squad target range:", ftos(this.target_range), "\n");
}

void dotc_dronesquad_remove(entity this)
{
	// TODO: remove drones here!
}

void dotc_dronesquad_reset(entity this)
{
	FOREACH_ENTITY_ENT(squad, this,
	{
		remove_ent(it);
	});

	remove_ent(this);
}

entity dotc_spawn_dronesquad(entity this, vector where, entity path)
{
	entity drone, sqd = spawn();

	sqd.classname		= "dotc_squad";
	set_movetype(sqd, MOVETYPE_FLY);
	setthink(sqd, dotc_dronesquad_think);
	sqd.nextthink 		= time;
	sqd.dotc_squadpath	= path;
	sqd.entremove		= dotc_dronesquad_remove;
	sqd.reset			= dotc_dronesquad_reset;

	sqd.team 			= this.team;
	sqd.owner			= this;

	sqd.target_range_min 		= 50;

	sqd.dotc_movespeed 			= 1000;
	sqd.dotc_turnspeed 			= 1000;

	sqd.dotc_unittype 			= DOTC_UF_SQUAD;
	sqd.dotc_targetflags		= DOTC_TARGET_TURRETS | DOTC_TARGET_DRONES;
	sqd.target_validate_flags 	= DOTC_TARGET_TURRETS | DOTC_TARGET_DRONES | DOTC_TARGET_PLAYERS;

	setorigin(sqd, where);

	sqd.netname = strzone(strcat(dotc_TeamColoredName(sqd.team), " squad"));

	entity core = dotc_GetCore(this.team);
	switch(core.dotc_corelevel)
	{
	case -1: // For testing
		drone = dotc_spawn_ltank(sqd, this);
		drone.dotc_formation_ofs = '0 0 0';

		drone = dotc_spawn_ltank(sqd, this);
		drone.dotc_formation_ofs = '-125 -100 0';

		drone = dotc_spawn_ltank(sqd, this);
		drone.dotc_formation_ofs = '125 -100 0';

		break;
	case 1:

		drone = dotc_spawn_scout(sqd, this);
		drone.dotc_formation_ofs = '-50 50 0';

		drone = dotc_spawn_scout(sqd, this);
		drone.dotc_formation_ofs = '50 50 0';

		drone = dotc_spawn_scout(sqd, this);
		drone.dotc_formation_ofs = '-50 -50 0';

		drone = dotc_spawn_scout(sqd, this);
		drone.dotc_formation_ofs = '50 -50 0';

		//drone = dotc_spawn_rart(sqd, this);
		//drone.dotc_formation_ofs = '0 -200 0';

		break;
	case 2:
		drone = dotc_spawn_ltank(sqd, this);
		drone.dotc_formation_ofs = '0 50 0';

		drone = dotc_spawn_ltank(sqd, this);
		drone.dotc_formation_ofs = '-75 -50 0';

		drone = dotc_spawn_ltank(sqd, this);
		drone.dotc_formation_ofs = '75 -50 0';

		break;
	case 3:
		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '0 50 0';

		drone = dotc_spawn_ltank(sqd, this);
		drone.dotc_formation_ofs = '-150 -50 0';

		drone = dotc_spawn_ltank(sqd, this);
		drone.dotc_formation_ofs = '150 -50 0';

		break;
	case 4:
		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '-90 0 0';

		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '90 0 0';

		break;
	case 5:
		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '-120 0 0';

		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '120 0 0';

		drone = dotc_spawn_rart(sqd, this);
		drone.dotc_formation_ofs = '0 -200 0';
		break;
	case 6:
		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '-120 0 0';

		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '120 0 0';

		drone = dotc_spawn_rart(sqd, this);
		drone.dotc_formation_ofs = '-100 -250 0';

		drone = dotc_spawn_rart(sqd, this);
		drone.dotc_formation_ofs = '100 -250 0';

		break;
	case 7:
		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '0 120 0';

		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '-120 0 0';

		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '120 0 0';

		drone = dotc_spawn_rart(sqd, this);
		drone.dotc_formation_ofs = '-100 -250 0';

		drone = dotc_spawn_rart(sqd, this);
		drone.dotc_formation_ofs = '100 -250 0';
		break;

	default:
		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '0 120 0';

		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '-120 0 0';

		drone = dotc_spawn_tank(sqd, this);
		drone.dotc_formation_ofs = '120 0 0';

		drone = dotc_spawn_rart(sqd, this);
		drone.dotc_formation_ofs = '-100 -250 0';

		drone = dotc_spawn_rart(sqd, this);
		drone.dotc_formation_ofs = '100 -250 0';

		break;
	}

	if(autocvar_g_dotc_waypointsprites_squads)
		dotc_sprite(this, WP_Squad, '0 0 50', sqd.cnt, sqd.cnt, '0 1 0', false);
		//dotc_sprite(sqd, string_null, '0 0 50', sqd.cnt, sqd.cnt, '0 1 0', false);
		//dotc_sprite(sqd, "dotc-squad", '0 0 50', sqd.cnt, sqd.cnt, '0 1 0', false);

	sqd.angles = vectoangles(normalize(path.enemy.origin - path.origin));
	fixedmakevectors(sqd.angles);
	dotc_formation_force(sqd);
	dotc_squad_update(sqd);

	return sqd;
}

vector move_target;
vector aim_target;

bool dotc_squad_enemyframe(entity this)
{
	if(!this.enemy || wasfreed(this.enemy)) { return false; }

	if(vdist(this.enemy.origin - this.origin, <, this.target_range_min))
		move_target = this.origin + steerlib_push(this, this.enemy.origin) * this.target_range_optimal;
	else if (vdist(this.enemy.origin - this.origin, >, this.target_range_optimal))
		move_target = this.origin + steerlib_pull(this, this.enemy.origin) * this.target_range_optimal;
	else
		move_target = this.origin;

	aim_target = this.enemy.origin;

	return true;
}

bool dotc_squad_pathframe(entity this)
{
	if(vdist(this.dotc_squadpath.origin - this.origin, <=, 64))
		this.dotc_squadpath = this.dotc_squadpath.enemy;

	if(!this.dotc_squadpath)
		return false;

	move_target = this.dotc_squadpath.origin;

	if(!this.enemy)
		aim_target = this.dotc_squadpath.origin;

	return true;
}


bool dotc_squad_roamframe(entity this)
{
	fixedmakevectors(this.angles);

	move_target = this.origin + steerlib_beamsteer(this, v_forward, 512, 32, 32, 64) * 256;

	if(!this.enemy)
		aim_target = move_target;

	return true;
}

void dotc_dronesquad_think(entity this)
{
	vector vf, vr, vu, form_loc;
	float deltatime, dist, spd;

	if(gameover)
	{
		this.enemy = NULL;
		this.velocity = '0 0 0';
		FOREACH_ENTITY_ENT(squad, this,
		{
			// blow up all drones
			it.event_damage(it, NULL, NULL, it.health + it.max_health + 10, DEATH_KILL.m_id, '0 0 0', '0 0 0');
		});

		return;
	}

	// Squad destroyed
	if (this.cnt <= 0)
	{
		if(this.waypointsprite_attached)
			WaypointSprite_Kill(this.waypointsprite_attached);

		this.owner.cnt -= 1;
		delete(this);
		return;
	}

	// Always locate the squad ent 32 qu above gound
	traceline(this.origin + '0 0 64', this.origin - '0 0 1024', MOVE_WORLDONLY, this);
	setorigin(this, trace_endpos + '0 0 32');

	// Deltatime for smooth movement
	deltatime = time - this.lastpushtime;
	if (deltatime > 0.25) deltatime = 0;
	this.lastpushtime = time;

	#if 1
		// 10 fps !todo: investigate dynamic ticrate
		this.nextthink = time + 0.1;
	#else
	if(this.enemy)
		this.nextthink = time + 0.05;
	else
		this.nextthink = time + 0.2;
	#endif

	if(dotc_ai_valid_target(this, this.enemy) <= 0)
		this.enemy = dotc_ai_acquire_target(this);

	bool dpf = true;

	if(this.enemy != NULL)
		dpf = false;

	if(autocvar_g_dotc_squads_dont_chase != 0)
		dpf = true;

	if(dpf)
		if(!dotc_squad_pathframe(this))
			dotc_squad_roamframe(this);

	if(!autocvar_g_dotc_squads_dont_chase)
		dotc_squad_enemyframe(this);

	// Turn to face aim_target
	aim_target = normalize(aim_target - this.origin);
	this.angles = vectoangles(aim_target);

	dist = vlen(move_target - this.origin);
	if(this.enemy)
		spd = bound(0, (dist / this.target_range_optimal * 0.5 ) * this.dotc_movespeed, this.dotc_movespeed);
	else
		spd = bound(150, (dist / this.target_range_optimal * 0.5 ) * this.dotc_movespeed, this.dotc_movespeed);

	this.velocity = aim_target * spd;

	// If no deltatime, theres no use in doing anything else here.
	if(!deltatime)
		return;

	// Store v_*'s for squad so we can do the formation transform for each drone w/o having to re-call fixedmakevectors()
	fixedmakevectors(this.angles);
	vf = v_forward;
	vr = v_right;
	vu = v_up;

	// Loop through the drones, calc their formation location relative to squad, and call their frame function.
	FOREACH_ENTITY_ENT(squad, this,
	{
		// Update this drones formation location. It's up to the individual drone how/if they get here.
		form_loc = this.origin + (it.dotc_formation_ofs_x * vr) + (it.dotc_formation_ofs_y * vf);
		it.drone_frame(it, form_loc, deltatime);

		if (it.punchvector != '0 0 0')
		{
			dpf = vlen(it.punchvector) - 30 * deltatime;
			if (dpf > 0)
				it.punchvector = normalize(it.punchvector) * dpf;
			else
				it.punchvector = '0 0 0';

			it.velocity += it.punchvector;
		}
	});
}
#endif

#endif
