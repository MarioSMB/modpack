#ifdef VEHICLES_CSQC
// SendFlags
float VSF_SETUP       = 1;          /// Send vehicle type etc
float VSF_ORIGIN      = 2;          /// Send location
float VSF_MOVEMENT    = 4;          /// Send movement update (and angles)
float VSF_AVEL        = 8;          /// Send Angular velocity
float VSF_STATS       = 16;         /// Send ammo, health etc
float VSF_EXTRA       = 32;         /// Send additional data (turret rotations etc). Handeld per vehicle type.
float VSF_ANIMINFO    = 64;         /// Animation info
float VSF_FULL_UPDATE = 16777215;    /// Send everything

float VSX_FAR   = 1;
float VSX_OWNER = 2;
float VSX_GUN1  = 4;
float VSX_GUN2  = 8;

#ifdef SVQC
#define VSX_FARDISTANCE 2000
float send_vehile(entity to, float sf)
{
	float dist, xf;

    var void WriteFunc(float, float);

    dist = vlen(self.origin - to.origin);
    if(to == self.owner)
        xf |= VSX_OWNER;
    else if(dist > VSX_FARDISTANCE)
        xf |= VSX_FAR;

	// Always send a movement and origin to owner
	if(to == self.owner)
	    sf |= VSF_ORIGIN | VSF_MOVEMENT;

	WriteByte(MSG_ENTITY, ENT_CLIENT_VEHICLE);

	// We need to know client-side what was sent
	WriteByte(MSG_ENTITY, sf);
	WriteByte(MSG_ENTITY, xf);

	if(sf & VSF_SETUP)
	{
        WriteByte(MSG_ENTITY,  self.hud);        //vehicle type = hud
        WriteByte(MSG_ENTITY,  self.team);
        WriteShort(MSG_ENTITY, self.colormap);
        WriteShort(MSG_ENTITY, self.vehicle_flags);
	}

    if(sf & VSF_ORIGIN)
    {
        WriteFunc = ((xf & VSX_FAR) ? WriteShort : WriteCoord);
        WriteFunc(MSG_ENTITY, self.origin_x);
        WriteFunc(MSG_ENTITY, self.origin_y);
        WriteFunc(MSG_ENTITY, self.origin_z);
    }

    if(sf & VSF_MOVEMENT)
    {
        WriteFunc = ((xf & VSX_FAR) ? WriteShort : WriteCoord);
        WriteFunc(MSG_ENTITY, self.velocity_x);
        WriteFunc(MSG_ENTITY, self.velocity_y);
        WriteFunc(MSG_ENTITY, self.velocity_z);

        WriteFunc = ((xf & VSX_FAR) ? WriteShort : WriteAngle);
        WriteFunc(MSG_ENTITY, self.angles_x);
        WriteFunc(MSG_ENTITY, self.angles_y);
        WriteFunc(MSG_ENTITY, self.angles_z);
    }

    if(sf & VSF_AVEL)
    {
        WriteFunc = ((xf & VSX_FAR) ? WriteShort : WriteCoord);
        WriteFunc(MSG_ENTITY, self.avelocity_x);
        WriteFunc(MSG_ENTITY, self.avelocity_y);
        WriteFunc(MSG_ENTITY, self.avelocity_z);
    }

    if(sf & VSF_STATS)
    {
        WriteByte(MSG_ENTITY, self.vehicle_health);
        if(xf & VSX_OWNER)
        {
            WriteByte(MSG_ENTITY, self.vehicle_shield);
            WriteByte(MSG_ENTITY, self.vehicle_energy);

            WriteByte(MSG_ENTITY, self.vehicle_ammo1);
            WriteByte(MSG_ENTITY, self.vehicle_reload1);

            WriteByte(MSG_ENTITY, self.vehicle_ammo2);
            WriteByte(MSG_ENTITY, self.vehicle_reload2);

        }
    }

    if(sf & VSF_EXTRA)
        self.vehile_send_exta(to, sf);

    return TRUE;
}

void net_link_vehile()
{
    self.SendFlags = 0xFFFFFF;
    Net_LinkEntity(self, FALSE, 0, send_vehile);
}
#endif // SVQC

#ifdef CSQC
void vehicle_spiderbot_assemble()
{

}

void vehicle_raptor_assemble()
{

}

void vehicle_bumblebee_assemble()
{

}

.float lastupdate;
void read_vehicle(float bIsNew)
{
    float sf, xf;
    var float ReadFunc();

    sf = ReadByte();
    xf = ReadByte();

    if(xf & VSX_OWNER)
        vehicle = self;

	if(sf & VSF_SETUP)
	{
        self.vehicle_hud   = ReadByte();
        self.team          = ReadByte();
        self.colormap      = ReadShort();
        self.vehicle_flags = ReadShort();

        switch(self.vehicle_hud)
        {
            case HUD_WAKIZASHI:
                vehicle_racer_assemble();
                break;
            case HUD_SPIDERBOT:
                vehicle_spiderbot_assemble();
                break;
            case HUD_RAPTOR:
                vehicle_raptor_assemble();
                break;
            case HUD_BUMBLEBEE:
                vehicle_bumblebee_assemble();
                break;
            default:
                break;
        }
	}

	if(self.vehicle_hud == HUD_WAKIZASHI && xf & VSX_OWNER)
	{

        vehicle_hudmodel.owner  = self;
	}

    //if(xf & VSX_FAR)
    //    dprint("Client vehicle faaar set\n");

    if(sf & VSF_ORIGIN)
    {
        ReadFunc = ((xf & VSX_FAR) ? ReadShort : ReadCoord);
        self.origin_x = ReadFunc();
        self.origin_y = ReadFunc();
        self.origin_z = ReadFunc();

        setorigin(self, self.origin);
        //self.lastupdate = time;
    }

    if(sf & VSF_MOVEMENT)
    {
        ReadFunc = ((xf & VSX_FAR) ? ReadShort : ReadCoord);
        self.velocity_x  = ReadFunc();
        self.velocity_y  = ReadFunc();
        self.velocity_z  = ReadFunc();

        ReadFunc = ((sf & VSX_FAR) ? ReadShort : ReadAngle);
        self.angles_x = ReadFunc();
        self.angles_y = ReadFunc();
        self.angles_z = ReadFunc();

        //self.lastupdate = time;
        // self.move_velocity  = self.velocity;
        // self.move_angles    = self.angles;
    }

    if(sf & VSF_AVEL)
    {
        ReadFunc = ((xf & VSX_FAR) ? ReadShort : ReadCoord);
        self.avelocity_x = ReadFunc();
        self.avelocity_y = ReadFunc();
        self.avelocity_z = ReadFunc();

        // self.move_avelocity  = self.avelocity;
    }

    if(sf & VSF_STATS)
    {
        self.vehicle_health = ReadByte();
        if(xf & VSX_OWNER)
        {
            self.vehicle_shield  = ReadByte();
            self.vehicle_energy  = ReadByte();
            self.vehicle_ammo1   = ReadByte();
            self.vehicle_reload1 = ReadByte();
            self.vehicle_ammo2   = ReadByte();
            self.vehicle_reload2 = ReadByte();
        }
    }

    if(sf & VSF_EXTRA)
        self.vehile_read_exta(sf);

}

#endif // CSQC
#else
#ifdef CSQC
.float lastupdate;
void read_vehicle(float bIsNew)
{

}
#endif
#endif // VEHICLES_CSQC
