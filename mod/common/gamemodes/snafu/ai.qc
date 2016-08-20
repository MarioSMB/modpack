#ifndef MENUQC

REGISTER_NET_LINKED(ENT_CLIENT_GAI)

const int GAIP_NONE = 0;
const int GAIP_WALK = 1;
const int GAIP_FLY = 2;
const int GAIP_SWIM = 3;
.int gai_physics_type;

const int GAIN_SETUP = 1;
const int GAIN_VELOCITY = 2;
const int GAIN_ORIGIN = 4;
const int GAIN_ANGLES = 8;
const int GAIN_FRAMES = 16;
//.SendFlags

.float  gai_physics_stepheight;
.float  gai_physics_hoverheight = gai_physics_stepheight;
.float  gai_physics_airfriction;
.float  gai_physics_waterfriction;
.float  gai_physics_slimefriction;
.float  gai_physics_lavafriction;
.float  gai_physics_minstep;
.float  gai_physics_maxstep;

.vector gai_physics_movement; // = movement;
.vector gai_physics_move_origin;
.float  gai_physics_lastupdate;
.void(entity this) gai_physics;

//#define _GAI_CSQC_DEBUG
#ifdef _GAI_CSQC_DEBUG
.entity gai_debug_target;
#endif

void gai_physics_walk(entity this)
{
    float _delta = time - this.gai_physics_lastupdate;
    if (_delta > this.gai_physics_maxstep)
    {
        LOG_DEBUG("^3WARNING:^7 Huge timestep (^5", ftos(_delta), "^7) in gai_physics_walk()");
        this.gai_physics_lastupdate = time;
        return;
    }

    if (_delta < this.gai_physics_minstep)
    { 
        //small step, use interpolation
        setorigin(this, this.gai_physics_move_origin + this.gai_physics_movement * _delta);
        return; 
    }

    int _cont_fric;
    switch(pointcontents(this.origin))
    {
        case CONTENT_SOLID: // unstick goes here
            _cont_fric = 1;
            break;
        case CONTENT_SLIME:
            _cont_fric = this.gai_physics_slimefriction;
            break;
        case CONTENT_LAVA:
            _cont_fric = this.gai_physics_lavafriction;
            break;
        case CONTENT_SKY: // hmmm
            _cont_fric = this.gai_physics_airfriction;
            break;
        case CONTENT_EMPTY:
            _cont_fric = this.gai_physics_airfriction;
            break;
        case CONTENT_WATER:
            _cont_fric = this.gai_physics_waterfriction;
            break;
    }

    vector _start = (this.gai_physics_move_origin + '0 0 1' * this.gai_physics_stepheight) * _delta;
    vector _forward = (_start + this.gai_physics_movement) * _delta;
    vector _down = ((_forward - '0 0 1.1' * this.gai_physics_stepheight) + ('0 0 -800')) * _delta;

    tracebox(_start, this.mins, this.maxs, _forward, MOVE_NORMAL, this);
    if(trace_fraction != 1.0)
    { // Colission
        return;
    }

    tracebox(_forward, this.mins, this.maxs, _down, MOVE_NORMAL, this);
    if(trace_fraction == 1.0)
    { // Falling
        return;
    }

    // Ground found
}

void _gai_physics_walk(entity this)
{
#ifdef CSQC
    LOG_DEBUG("^5 --------- gai_physics_walk");
#endif
    float _delta = time - this.gai_physics_lastupdate;
    
    if (_delta > this.gai_physics_maxstep)
    {
        LOG_DEBUG("^3WARNING:^7 Huge timestep (^5", ftos(_delta), "^7) in gai_physics_walk()");
        this.gai_physics_lastupdate = time;
        return;
    }    
    
    if (_delta < this.gai_physics_minstep) 
    { 
        //LOG_DEBUG("^3WARNING:^7 Tiny timestep (^5", ftos(_delta), "^7) in gai_physics_walk(), using interpolation");
        setorigin(this, this.gai_physics_move_origin + this.gai_physics_movement * _delta);
        return; 
    }

    vector _v_tmp;
    vector _gravity = '0 0 800' * _delta;
    vector _move = this.gai_physics_movement * _delta;
    
    tracebox(this.origin, this.mins, this.maxs, this.origin + _move - _gravity, MOVE_NORMAL, this);    
    if(trace_fraction == 1.0)
    {
        LOG_DEBUG("Falling");
        setorigin(this, trace_endpos);
        this.gai_physics_move_origin = this.origin;
        this.gai_physics_lastupdate = time;
        return;
    }
    
    // Allow minor bumps in up/down movement over gound
#define _nudge_up '0 0 1'
#define _nudge_down '0 0 2'

    // Lift slightly off floor and trace along movement
    tracebox(this.origin + _nudge_up, this.mins, this.maxs, this.origin + _move + _nudge_up, MOVE_NORMAL, this);    
    _v_tmp = trace_endpos;
    if(trace_fraction == 1.0)
    {    
        tracebox(trace_endpos, this.mins, this.maxs, trace_endpos - _nudge_down, MOVE_NORMAL, this);
        if(trace_fraction != 1.0)
        { // Walkign on ground
            LOG_DEBUG("Walking on ground");
            setorigin(this, trace_endpos);
            this.gai_physics_move_origin = this.origin;
            this.gai_physics_lastupdate = time;
            return;
        }
    }
    
    _move = (this.gai_physics_movement - _gravity) * _delta;
        
    // At this point we'r eigther walking a slope, a stair or in-air/water/lava
    
    // Can step down?
    vector _step_down = '0 0 1' * this.gai_physics_stepheight;    
    tracebox(_v_tmp, this.mins, this.maxs, _v_tmp - _step_down, MOVE_NORMAL, this);
    if(trace_fraction != 1.0)
    {   // Walk down a step
        LOG_DEBUG("Walk down a step");
        setorigin(this, trace_endpos);
        this.gai_physics_move_origin = this.origin;
        this.gai_physics_lastupdate = time;
        return;
    }
    else
    { // fall/swim/burn
        LOG_DEBUG("fall/swim/burn");
        
        tracebox(_v_tmp, this.mins, this.maxs, _v_tmp - _step_down, MOVE_NORMAL, this);
        
        setorigin(this, this.origin + _move - '0 0 800' * _delta);
        this.gai_physics_move_origin = this.origin;
        this.gai_physics_lastupdate = time;
        return;
    }
    
    /*// Can step up?
    vector _step_up = '0 0 1' * this.gai_physics_stepheight;
    tracebox(_v_tmp, this.mins, this.maxs, _v_tmp + _step_up, MOVE_NORMAL, this);
    if(trace_fraction != 1.0)
    {   // Walk up a step
        LOG_DEBUG("Walk up a step");
        setorigin(this, trace_endpos);
        this.gai_physics_move_origin = this.origin;
        this.gai_physics_lastupdate = time;
        return;
    }
    
    // This is not good...
    LOG_DEBUG("This is not good....");
    this.gai_physics_move_origin = this.origin;
    this.gai_physics_lastupdate = time;*/
}

void gai_physics_none(entity this)
{
    
}
void gai_physics_hover(entity this)
{
    
}
void gai_physics_swim(entity this)
{
    
}


void gai_physics_fly(entity this)
{
    float _delta = time - this.gai_physics_lastupdate;
    
    if (_delta > this.gai_physics_maxstep)
    {
        LOG_DEBUG("^3WARNING:^7 Huge timestep (^5", ftos(_delta), "^7) in gai_physics_fly()");
        this.gai_physics_lastupdate = time;
        return;
    }    
    
    if (_delta < this.gai_physics_minstep) 
    { 
        setorigin(this, this.gai_physics_move_origin + this.gai_physics_movement * _delta);
        return; 
    }
    
    vector _move = this.gai_physics_movement * _delta;    
    tracebox(this.gai_physics_move_origin, this.mins, this.maxs, 
             this.gai_physics_move_origin + _move, MOVE_NORMAL, this);

    // Did not hit anything
    if(trace_fraction == 1.0 && !trace_startsolid)
        setorigin(this, this.gai_physics_move_origin + _move);
    else
    {
        setorigin(this, trace_endpos + 0.1 * (trace_plane_normal * vlen((this.gai_physics_move_origin + _move) - trace_endpos)));
        
#ifdef SVQC        
        // Collission with entity unknown to csqc
        if(trace_ent)
        if(!getSendEntity(trace_ent))
            this.SendFlags |= GAIN_ORIGIN;
#ifdef _GAI_CSQC_DEBUG
    if(this.gai_debug_target)
        setorigin(this.gai_debug_target, this.origin);
#endif
#endif
        
    }
    
    this.gai_physics_move_origin = this.origin;
    this.gai_physics_lastupdate = time;
    
}

#ifdef CSQC
void gai_draw(entity this)
{
    this.gai_physics(this);
}

NET_HANDLE(ENT_CLIENT_GAI, bool isnew)
{
    int sf = ReadByte();

	if(sf & GAIN_SETUP)
	{	    
	    this.gai_physics_type = ReadByte();	    
	    this.gai_physics_stepheight   = ReadCoord();
	    this.gai_physics_airfriction   = ReadCoord();
	    this.gai_physics_waterfriction = ReadCoord();
	    this.gai_physics_minstep       = ReadCoord();
	    this.gai_physics_maxstep       = ReadCoord();	    
	    this.mdl                       = strzone(ReadString());
        this.mins_x                    = ReadCoord();
        this.mins_y                    = ReadCoord();
        this.mins_z                    = ReadCoord();
        this.maxs_x                    = ReadCoord();
        this.maxs_y                    = ReadCoord();
        this.maxs_z                    = ReadCoord();

	    this.gai_physics_minstep = 1 / 120;
	    this.gai_physics_maxstep = 1 / 5;
	    
	    _setmodel(this, this.mdl);
	    setsize(this, this.mins, this.maxs);
	    
	    switch(this.gai_physics_type)
	    {
            case GAIP_NONE:
                this.gai_physics = gai_physics_none;
                break;
            case GAIP_WALK:
                this.gai_physics = gai_physics_walk;
                break;
            case GAIP_FLY:
                this.gai_physics = gai_physics_fly;
                break;
            case GAIP_SWIM:
                this.gai_physics = gai_physics_swim;
                break;
	    }

        this.solid                  = SOLID_BBOX;
        set_movetype(this, MOVETYPE_NONE);
        this.draw                   = gai_draw;
        this.drawmask               = MASK_NORMAL;
	}
	
	if(sf & GAIN_VELOCITY)
	{
        this.gai_physics_movement_x = ReadCoord();
        this.gai_physics_movement_y = ReadCoord();
        this.gai_physics_movement_z = ReadCoord();	    
	}
	
	if(sf & GAIN_ORIGIN)
	{
	    this.gai_physics_move_origin_x = ReadCoord();
	    this.gai_physics_move_origin_y = ReadCoord();
	    this.gai_physics_move_origin_z = ReadCoord();
	    
	    setorigin(this, this.gai_physics_move_origin);
	    this.gai_physics_lastupdate = time;
	}
	
	if(sf & GAIN_ANGLES)
	{
	    this.angles_x = ReadAngle();
	    this.angles_y = ReadAngle();
	    this.angles_z = ReadAngle();
	}
	
	if(sf & GAIN_FRAMES)
	{
        this.frame      = ReadByte();
        this.frame1time = time;	    
	}

    return true;
}
#endif

#ifdef SVQC
bool gai_write(entity this, entity _to, int _flags)
{
    WriteHeader(MSG_ENTITY, ENT_CLIENT_GAI);    
    WriteByte(MSG_ENTITY, _flags);

	if(_flags & GAIN_SETUP)
	{	    
	    WriteByte(MSG_ENTITY, this.gai_physics_type);
	    
	    WriteCoord(MSG_ENTITY, this.gai_physics_stepheight);
	    WriteCoord(MSG_ENTITY, this.gai_physics_airfriction);
	    WriteCoord(MSG_ENTITY, this.gai_physics_waterfriction);
	    WriteCoord(MSG_ENTITY, this.gai_physics_minstep);
	    WriteCoord(MSG_ENTITY, this.gai_physics_maxstep);
	    WriteString(MSG_ENTITY, this.model);	    
        WriteCoord(MSG_ENTITY, this.mins_x);
        WriteCoord(MSG_ENTITY, this.mins_y);
        WriteCoord(MSG_ENTITY, this.mins_z);
        WriteCoord(MSG_ENTITY, this.maxs_x);
        WriteCoord(MSG_ENTITY, this.maxs_y);
        WriteCoord(MSG_ENTITY, this.maxs_z);
	}
	
	if(_flags & GAIN_VELOCITY)
	{
        WriteCoord(MSG_ENTITY, this.gai_physics_movement_x);
        WriteCoord(MSG_ENTITY, this.gai_physics_movement_y);
        WriteCoord(MSG_ENTITY, this.gai_physics_movement_z);
	}
	
	if(_flags & GAIN_ORIGIN)
	{
	    WriteCoord(MSG_ENTITY, this.gai_physics_move_origin_x);
	    WriteCoord(MSG_ENTITY, this.gai_physics_move_origin_y);
	    WriteCoord(MSG_ENTITY, this.gai_physics_move_origin_z);
	}
	
	if(_flags & GAIN_ANGLES)
	{
	    WriteAngle(MSG_ENTITY, this.angles_x);
	    WriteAngle(MSG_ENTITY, this.angles_y);
	    WriteAngle(MSG_ENTITY, this.angles_z);
	}
	
	if(_flags & GAIN_FRAMES)
	{
        WriteByte(MSG_ENTITY, this.frame);
	}

    return true;
}

void gai_generic_damage(entity this, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
}

void gai_fly_think(entity this)
{
    this.nextthink = time;
    this.gai_physics(this);
    if(!this.enemy)
    {
        this.enemy = findradius(this.origin, 2048);
        while(this.enemy)
        {
            if(IS_PLAYER(this.enemy))
            if(this.enemy.deadflag == DEAD_NO)
                break;
            
            this.enemy = this.enemy.chain;
        }
    }
    
    if(this.enemy)
    {
        this.gai_physics_movement = 0.5 * (this.movement + normalize(this.enemy.origin - this.origin) * 200);
        this.SendFlags |= GAIN_VELOCITY;
    }        
    else
        this.gai_physics_movement = '0 0 0';
    
    this.angles = normalize(this.gai_physics_movement);
}

entity gai_fly_start(vector _where, vector _mins, vector _maxs, entity _model, float _health, float _csqc)
{
    entity _ai = spawn();
    
    setmodel(_ai, _model);
    setsize(_ai, _mins, _maxs);    
    setorigin(_ai, _where);
    
    set_movetype(_ai, MOVETYPE_NOCLIP);
    _ai.solid            = SOLID_BBOX;
    _ai.takedamage       = DAMAGE_AIM;
    _ai.event_damage     = gai_generic_damage;
    _ai.health           = _health;
    _ai.gai_physics_type = GAIP_FLY;
    _ai.gai_physics      = gai_physics_fly;
    setthink(_ai, gai_fly_think);
    _ai.nextthink        = time;
    _ai.gai_physics_minstep = 1 / 20;
    _ai.gai_physics_maxstep = 1; // / 10;
    _ai.gai_physics_move_origin = _ai.origin;
    
    if(_csqc)
    {
#ifdef _GAI_CSQC_DEBUG
        entity _ai_debug = spawn();        
        setmodel(_ai_debug, _model);
        setsize(_ai_debug, _mins, _maxs);    
        setorigin(_ai_debug, _where);
        _ai.gai_debug_target = _ai_debug;
        _ai_debug.colormod = '0.2 0.2 1.6';
#endif
        
        //Net_LinkEntity(_ai, FALSE, 0, gai_write);
        setSendEntity(_ai, gai_write);
        _ai.SendFlags = 0xFFFFFF;

    }
    return _ai;
}

void gai_walk_think(entity this)
{
    this.nextthink = time;
    this.gai_physics(this);
    if(!this.enemy)
    {
        this.enemy = findradius(this.origin, 2048);
        while(this.enemy)
        {
            if(IS_PLAYER(this.enemy))
            if(this.enemy.deadflag == DEAD_NO)
                break;
            
            this.enemy = this.enemy.chain;
        }
    }
    
    if(this.enemy)
    {
        this.gai_physics_movement = 0.5 * (this.movement + normalize(this.enemy.origin - this.origin) * 200);
        this.SendFlags |= GAIN_VELOCITY;
    }        
    else
        this.gai_physics_movement = '0 0 0';
    
    this.angles = normalize(this.gai_physics_movement);
}    

entity gai_walk_start(vector _where, vector _mins, vector _maxs, entity _model, float _health, float _csqc)
{
    entity _ai = spawn();
    
    setmodel(_ai, _model);
    setsize(_ai, _mins, _maxs);    
    setorigin(_ai, _where);
    
    set_movetype(_ai, MOVETYPE_NOCLIP);
    _ai.solid            = SOLID_BBOX;
    _ai.takedamage       = DAMAGE_AIM;
    _ai.event_damage     = gai_generic_damage;
    _ai.health           = _health;
    
    _ai.gai_physics_type = GAIP_WALK;
    _ai.gai_physics      = gai_physics_walk;
    setthink(_ai, gai_walk_think);
    _ai.nextthink        = time;
    
    _ai.gai_physics_minstep = 1 / 20;
    _ai.gai_physics_maxstep = 1; // / 10;
    _ai.gai_physics_move_origin = _ai.origin;
    _ai.gai_physics_stepheight = 32;
    
    if(_csqc)
    {
#ifdef _GAI_CSQC_DEBUG
        entity _ai_debug = spawn();        
        setmodel(_ai_debug, _model);
        setsize(_ai_debug, _mins, _maxs);    
        setorigin(_ai_debug, _where);
        _ai.gai_debug_target = _ai_debug;
        _ai_debug.colormod = '0.2 0.2 1.6';
#endif
        
        //Net_LinkEntity(_ai, FALSE, 0, gai_write);
        setSendEntity(_ai, gai_write);
        _ai.SendFlags = 0xFFFFFF;

    }
    return _ai;
}
#endif

#endif
