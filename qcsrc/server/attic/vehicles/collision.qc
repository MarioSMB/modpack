vector collision_force;
vector collision_angle;

vector bb1[9];
vector bb2[9];

float collision_run()
{
    vector vtmp, vmin, vmax, vrot, vforce, vtmp2, vtmp3;
    float i, fvel, bcol;


    // Extract the 8 bbox corners from mins/maxs for self
    vmax = self.maxs;
    vmin = self.mins;
    bb1[0] = vmax;
    vtmp   = vmax; vtmp_x = vmin_x; bb1[1] = vtmp;
    vtmp   = vmax; vtmp_y = vmin_y; bb1[2] = vtmp;
    vtmp   = vmin; vtmp_z = vmax_z; bb1[3] = vtmp;
    bb1[4] = vmin;
    vtmp   = vmin; vtmp_x = vmax_x; bb1[5] = vtmp;
    vtmp   = vmin; vtmp_y = vmax_y; bb1[6] = vtmp;
    vtmp   = vmax; vtmp_z = vmin_z; bb1[7] = vtmp;

    makevectors(self.angles + '-2 0 0' * self.angles_x);
    bcol = 0;

    // Pass1: Transform by rotation, ajust points by impact/s
    for(i = 8; i >= 0; --i)
    {
        vtmp = bb1[i];
        vtmp = self.origin + vtmp_x * v_forward - vtmp_y * v_right + vtmp_z * v_up;
        traceline(self.origin, vtmp, MOVE_WORLDONLY, self);
        te_lightning1(world,self.origin,vtmp);
        if(trace_fraction != 1.0)
        {
            vforce += (trace_endpos - vtmp);
            vtmp3 = self.origin + self.velocity * frametime;
            vtmp2 =  vectoangles(normalize(vtmp - vtmp3));
            vrot   += (vectoangles(normalize(trace_endpos - vtmp3)) - vtmp2);
            bcol += 1;
        }
    }

    if(bcol)
    {

        vtmp = self.origin + self.velocity * frametime;
        self.angles += vrot * frametime;
        self.velocity += vforce * frametime;

    }

}

