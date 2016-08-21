#ifndef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_dotc_drones_dead_csqc, bool, false, "");
AUTOCVAR(g_dotc_drones_dead_upspeed1, float, 120, "");
AUTOCVAR(g_dotc_drones_dead_upspeed2, float, 30, "");
AUTOCVAR(g_dotc_drones_dead_side1speed1, float, 10, "");
AUTOCVAR(g_dotc_drones_dead_side1speed2, float, 30, "");
AUTOCVAR(g_dotc_drones_dead_side2speed1, float, 20, "");
AUTOCVAR(g_dotc_drones_dead_side2speed2, float, 10, "");
AUTOCVAR(g_dotc_drones_dead_spinnspeed, float, 5, "");

#elif defined(CSQC)

AUTOCVAR(cl_dotc_gib_upspeed, float, 250, "");
AUTOCVAR(cl_dotc_gib_side1speed1, float, 400, "");
AUTOCVAR(cl_dotc_gib_side1speed2, float, 800, "");
AUTOCVAR(cl_dotc_gib_side2speed1, float, 400, "");
AUTOCVAR(cl_dotc_gib_side2speed2, float, 800, "");

//AUTOCVAR(cl_dotc_deaddrone_simple, float, 0, "");
AUTOCVAR(cl_dotc_deaddrone_upspeed1, float, 250, "");
AUTOCVAR(cl_dotc_deaddrone_upspeed2, float, 150, "");
AUTOCVAR(cl_dotc_deaddrone_side1speed1, float, 200, "");
AUTOCVAR(cl_dotc_deaddrone_side1speed2, float, 400, "");
AUTOCVAR(cl_dotc_deaddrone_side2speed1, float, 200, "");
AUTOCVAR(cl_dotc_deaddrone_side2speed2, float, 400, "");
AUTOCVAR(cl_dotc_deaddrone_spinnspeed, float, 360, "");

#endif

MODEL(DOTC_GIB_1,                       "models/dotc/gib1.md3");
MODEL(DOTC_GIB_2,                       "models/dotc/gib2.md3");
MODEL(DOTC_GIB_3,                       "models/dotc/gib3.md3");
MODEL(DOTC_GIB_4,                       "models/dotc/gib4.md3");
MODEL(DOTC_GIB_5,                       "models/dotc/gib5.md3");
Model MDL_DOTC_GIB_RANDOM() {
    int i = floor(random() * 5);
    return Models_from(MDL_DOTC_GIB_1.m_id + i);
}

#else

#ifdef CSQC
void DOTC_GibsDraw(entity this)
{
	Movetype_Physics_MatchTicrate(this, autocvar_cl_gibs_ticrate, autocvar_cl_gibs_sloppy);
	if(wasfreed(this))
		return;

	this.alpha = bound(0, this.nextthink - time, 1);
	if(this.alpha < ALPHA_MIN_VISIBLE)
	{
		remove(this);
	}
	
	if (this.traileffect)
		Projectile_DrawTrail(this, this.origin);
}

.int dotc_bouncecnt;
void DOTC_GibTouch(entity this, entity toucher)
{
	this.dotc_bouncecnt -= 1;
	if(this.dotc_bouncecnt >= 0)
		return;
		
	sound (this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
	pointparticles(EFFECT_ROCKET_EXPLODE, this.origin, '0 0 0', 1);    
	
	remove(this);
}

void DOTC_DroneCorpseTouch(entity this, entity toucher)
{
	int i;

	sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);
	pointparticles(EFFECT_ROCKET_EXPLODE, this.origin, '0 0 0', 1);
	
	for(i = 1; i < (random() * 5); ++i)
	{
		entity gib = spawn();
		setmodel(gib, MDL_DOTC_GIB_RANDOM());
		setorigin(gib, this.origin);
		setsize(gib, '-1 -1 -1', '1 1 1');
		
		gib.velocity 	= ('0 0 1' * (autocvar_cl_dotc_gib_upspeed + random() * autocvar_cl_dotc_gib_upspeed)) 
						+ ('0 1 0' * (-autocvar_cl_dotc_gib_side1speed1 + random() * autocvar_cl_dotc_gib_side1speed2)) 
						+ ('0 0 1' * (-autocvar_cl_dotc_gib_side2speed1 + random() * autocvar_cl_dotc_gib_side2speed2));
		
		gib.solid 		    = SOLID_CORPSE;
		set_movetype(gib, MOVETYPE_BOUNCE);
		gib.avelocity 	    = randomvec() * 160;
	
		gib.move_time 		= time;
		
		// dotc_bouncecnt = bounce how many times before exploding.
		gib.dotc_bouncecnt         = rint(random() * 5);
		settouch(gib, DOTC_GibTouch);
		
		// Failsafe.
		setthink(gib, SUB_Remove);
		gib.nextthink   = time + 6;	
		gib.drawmask = MASK_NORMAL;	
		
		gib.draw = DOTC_GibsDraw;
		IL_PUSH(g_drawables, gib);
		
		if(random() < 0.3)
		{
			gib.traileffect = particleeffectnum(EFFECT_TR_ROCKET);
			gib.effects = EF_FLAME;
			gib.dotc_bouncecnt = rint(random() * 2);			
		}
				
	}

	remove(this);
}

NET_HANDLE(TE_CSQC_DOTC_DRONEDIE, bool isNew)
{
	vector loc, vel, ang;
	int drone_type;
	vector vadd;
	
	drone_type = ReadByte();
	loc = ReadVector();
	vel = ReadVector();
	ang = ReadVector();

	if(drone_type < 1 || drone_type > DOTC_DRONETYPE_LAST)
	{
		LOG_DEBUG("^1Invalid drone type in Net_ReadDOTCDroneDie, aborting\n");
		return false;
	}
		
	entity e = spawn();
	setorigin(e, loc);

	sound(e, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);
	pointparticles(EFFECT_ROCKET_EXPLODE, e.origin, '0 0 0', 1);
	
	// Client requests minimal death sequence, just do particles & sound.
	/*if(autocvar_cl_dotc_deaddrone_simple)	
	{
		remove(e);
		return false;
	}*/

	switch(drone_type)
	{		
		case DOTC_DRONETYPE_SCOUT:
			setmodel(e, MDL_DOTC_DRONE_SCOUT_DEAD);
			setsize(e, '-30 -30 -5', '30 30 25');
			break;
		case DOTC_DRONETYPE_LTANK:
			setmodel(e, MDL_DOTC_DRONE_LIGHT_DEAD);
			setsize(e, drone_size_small_min, drone_size_small_max);
			break;
		case DOTC_DRONETYPE_TANK:
			setsize(e, drone_size_medium_min, drone_size_medium_max * 1.25);
			setmodel(e, MDL_DOTC_DRONE_TANK_DEAD);
			break;
		case DOTC_DRONETYPE_HTANK: // FIXME
			setsize(e, drone_size_medium_min, drone_size_medium_max * 1.25);
			setmodel(e, MDL_DOTC_DRONE_RART_DEAD);
			break;
		case DOTC_DRONETYPE_RART:
			setsize(e, drone_size_small_min, drone_size_small_max);
			setmodel(e, MDL_DOTC_DRONE_GART_DEAD);
			break;
		case DOTC_DRONETYPE_GART:
			setsize(e, drone_size_small_min, drone_size_small_max);
			setmodel(e, MDL_DOTC_DRONE_GART_DEAD);
			break;
		case DOTC_DRONETYPE_GUARD: // FIXME
			setsize(e, drone_size_small_min, drone_size_small_max);
			setmodel(e, MDL_DOTC_DRONE_GART_DEAD);
			break;
	}	
		
	vadd = ('0 0 1' * (autocvar_cl_dotc_deaddrone_upspeed1 + random() * autocvar_cl_dotc_deaddrone_upspeed2)) 
		 + ('0 1 0' * (-autocvar_cl_dotc_deaddrone_side1speed1 + random() * autocvar_cl_dotc_deaddrone_side1speed2)) 
		 + ('0 0 1' * (-autocvar_cl_dotc_deaddrone_side2speed1 + random() * autocvar_cl_dotc_deaddrone_side2speed2));
	
	
	e.solid 	     = SOLID_CORPSE;
	settouch(e, DOTC_DroneCorpseTouch);
	e.drawmask       = MASK_NORMAL;
	e.draw           = DOTC_GibsDraw;
	IL_PUSH(g_drawables, e);
	e.nextthink      = time + 6;	    
	e.angles = ang;		
	e.velocity  = vel + vadd;
	e.avelocity = randomvec() * autocvar_cl_dotc_deaddrone_spinnspeed;
	e.move_time 	 = time;
	set_movetype(e, MOVETYPE_BOUNCE);

	if(random() < 0.25)
		e.traileffect = particleeffectnum(EFFECT_TR_ROCKET);

	return true;
}

#endif

#endif
