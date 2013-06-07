#ifdef SVQC 
.vector moveto;

/**
    Simulate drag
    self.velocity = movelib_dragvec(self.velocity,0.02,0.5);
**/
vector movelib_dragvec(float drag, float exp_)
{
    float lspeed,ldrag;

    lspeed = vlen(self.velocity);
    ldrag = lspeed * drag;
    ldrag = ldrag * (drag * exp_);
    ldrag = 1 - (ldrag / lspeed);

    return self.velocity * ldrag;
}

/**
    Simulate drag
    self.velocity *= movelib_dragflt(somespeed,0.01,0.7);
**/
float movelib_dragflt(float fspeed,float drag,float exp_)
{
    float ldrag;

    ldrag = fspeed * drag;
    ldrag = ldrag * ldrag * exp_;
    ldrag = 1 - (ldrag / fspeed);

    return ldrag;
}

/**
    Do a inertia simulation based on velocity.
    Basicaly, this allows you to simulate loss of steering with higher speed.
    self.velocity = movelib_inertmove_byspeed(self.velocity,newvel,1000,0.1,0.9);
**/
vector movelib_inertmove_byspeed(vector vel_new, float vel_max,float newmin,float oldmax)
{
    float influense;

    influense = vlen(self.velocity) * (1 / vel_max);

    influense = bound(newmin,influense,oldmax);

    return (vel_new * (1 - influense)) + (self.velocity * influense);
}

vector movelib_inertmove(vector new_vel,float new_bias)
{
    return new_vel * new_bias + self.velocity * (1-new_bias);
}

.float  movelib_lastupdate;
void movelib_move(vector force,float max_velocity,float drag,float theMass,float breakforce)
{
    float deltatime;
    float acceleration;
    float mspeed;
    vector breakvec;

    deltatime = time - self.movelib_lastupdate;
    if (deltatime > 0.15) deltatime = 0;
    self.movelib_lastupdate = time;
    if (!deltatime) return;

    mspeed = vlen(self.velocity);

    if (theMass)
        acceleration = vlen(force) / theMass;
    else
        acceleration = vlen(force);

    if (self.flags & FL_ONGROUND)
    {
        if (breakforce)
        {
            breakvec = (normalize(self.velocity) * (breakforce / theMass) * deltatime);
            self.velocity = self.velocity - breakvec;
        }

        self.velocity = self.velocity + force * (acceleration * deltatime);
    }

    if (drag)
        self.velocity = movelib_dragvec(drag, 1);

    if (self.waterlevel > 1)
    {
        self.velocity = self.velocity + force * (acceleration * deltatime);
        self.velocity = self.velocity + '0 0 0.05' * autocvar_sv_gravity * deltatime;
    }
    else
        self.velocity = self.velocity + '0 0 -1' * autocvar_sv_gravity * deltatime;

    mspeed = vlen(self.velocity);

    if (max_velocity)
        if (mspeed > max_velocity)
            self.velocity = normalize(self.velocity) * (mspeed - 50);//* max_velocity;
}

void movelib_move_simple_gravity(vector newdir,float velo,float blendrate)
{
    float z_speed = self.velocity_z;
    self.movelib_lastupdate = time;
    self.velocity = self.velocity * (1 - blendrate) + (newdir * blendrate) * velo;
    self.velocity_z = z_speed;
}

void movelib_jump_simple(float power){
    self.velocity_z=power;
    self.movelib_lastupdate = time;
}

/*
.float mass;
.float side_friction;
.float ground_friction;
.float air_friction;
.float water_friction;
.float buoyancy;
float movelib_deltatime;

void movelib_startupdate()
{
    movelib_deltatime = time - self.movelib_lastupdate;

    if (movelib_deltatime > 0.5)
        movelib_deltatime = 0;

    self.movelib_lastupdate = time;
}

void movelib_update(vector dir,float force)
{
    vector acceleration;
    float old_speed;
    float ffriction,v_z;

    vector breakvec;
    vector old_dir;
    vector ggravity;
    vector old;

    if(!movelib_deltatime)
        return;
    v_z = self.velocity_z;
    old_speed    = vlen(self.velocity);
    old_dir      = normalize(self.velocity);

    //ggravity      =  (autocvar_sv_gravity / self.mass) * '0 0 100';
    acceleration =  (force / self.mass) * dir;
    //acceleration -= old_dir * (old_speed / self.mass);
    acceleration -= ggravity;

    if(self.waterlevel > 1)
    {
        ffriction = self.water_friction;
        acceleration += self.buoyancy * '0 0 1';
    }
    else
        if(self.flags & FL_ONGROUND)
            ffriction = self.ground_friction;
        else
            ffriction = self.air_friction;

    acceleration *= ffriction;
    //self.velocity = self.velocity * (ffriction * movelib_deltatime);
    self.velocity += acceleration * movelib_deltatime;
    self.velocity_z = v_z;

}
*/

/*
void movelib_move_simple(vector newdir,float velo,float blendrate)
{
    self.velocity = self.velocity * (1 - blendrate) + (newdir * blendrate) * velo;
}
*/
#define movelib_move_simple(newdir,velo,blendrate) \
    self.velocity = self.velocity * (1 - blendrate) + (newdir * blendrate) * velo

void movelib_beak_simple(float force)
{
    float mspeed;
    vector mdir;
    float vz;

    mspeed = max(0,vlen(self.velocity) - force);
    mdir   = normalize(self.velocity);
    vz = self.velocity_z;
    self.velocity = mdir * mspeed;
    self.velocity_z = vz;
}

/**
Pitches and rolls the entity to match the gound.
Yed need to set v_up and v_forward (generally by calling makevectors) before calling this.
**/
#endif

void movelib_groundalign4point(float spring_length, float spring_up, float blendrate, float _max)
{
    vector a, b, c, d, e, r, push_angle, ahead, side;

    push_angle_y = 0;
    r = (self.absmax + self.absmin) * 0.5 + (v_up * spring_up);
    e = v_up * spring_length;

    // Put springs slightly inside bbox
    ahead = v_forward * (self.maxs_x * 0.8);
    side  = v_right   * (self.maxs_y * 0.8);

    a = r + ahead + side;
    b = r + ahead - side;
    c = r - ahead + side;
    d = r - ahead - side;

    traceline(a, a - e,MOVE_NORMAL,self);
    a_z =  (1 - trace_fraction);
    r = trace_endpos;

    traceline(b, b - e,MOVE_NORMAL,self);
    b_z =  (1 - trace_fraction);
    r += trace_endpos;

    traceline(c, c - e,MOVE_NORMAL,self);
    c_z =  (1 - trace_fraction);
    r += trace_endpos;

    traceline(d, d - e,MOVE_NORMAL,self);
    d_z =  (1 - trace_fraction);
    r += trace_endpos;

    a_x = r_z;
    r = self.origin;
    r_z = r_z;

    push_angle_x = (a_z - c_z) * _max;
    push_angle_x += (b_z - d_z) * _max;

    push_angle_z = (b_z - a_z) * _max;
    push_angle_z += (d_z - c_z) * _max;

    //self.angles_x += push_angle_x * 0.95;
    //self.angles_z += push_angle_z * 0.95;

    self.angles_x = ((1-blendrate) *  self.angles_x)  + (push_angle_x * blendrate);
    self.angles_z = ((1-blendrate) *  self.angles_z)  + (push_angle_z * blendrate);

    //a = self.origin;
    setorigin(self,r);
}

