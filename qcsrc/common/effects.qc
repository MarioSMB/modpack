void Create_Effect_Entity(float eff_name, string eff_string, float eff_trail)
{
	entity eff;
	effects_ent[eff_name - 1] = eff = spawn();

	eff.classname = "effect_entity";
	eff.eent_net_name = eff_name;
	eff.eent_eff_name = eff_string;
	eff.eent_eff_trail = eff_trail;
}

#ifdef CSQC
void Read_Effect(float is_new)
{
#if EFFECTS_COUNT >= 255
	float net_name = ReadShort();
#else
	float net_name = ReadByte();
#endif

	entity eff = effects_ent[net_name - 1];

	vector v, vel = '0 0 0';
	float eff_cnt = 1;
	float eff_trail = eff.eent_eff_trail;
	v_x = ReadCoord();
	v_y = ReadCoord();
	v_z = ReadCoord();

	float use_vel = ReadByte();
	if(use_vel)
	{
		vel_x = ReadCoord();
		vel_y = ReadCoord();
		vel_z = ReadCoord();
	}
	
	if(!eff_trail)
		eff_cnt = ReadByte();

	if(is_new)
	if(eff_trail)
		WarpZone_TrailParticles(world, particleeffectnum(eff.eent_eff_name), v, vel);
	else
		pointparticles(particleeffectnum(eff.eent_eff_name), v, vel, eff_cnt);
}
#endif

#ifdef SVQC
float Net_Write_Effect(entity client, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_EFFECT);
#if EFFECTS_COUNT >= 255
	WriteShort(MSG_ENTITY, self.eent_net_name);
#else
	WriteByte(MSG_ENTITY, self.eent_net_name);
#endif
	WriteCoord(MSG_ENTITY, self.eent_net_location_x);
	WriteCoord(MSG_ENTITY, self.eent_net_location_y);
	WriteCoord(MSG_ENTITY, self.eent_net_location_z);

	// attempt to save a tiny bit more bandwidth by not sending velocity if it isn't set
	if(self.eent_net_velocity)
	{
		WriteByte(MSG_ENTITY, TRUE);
		WriteCoord(MSG_ENTITY, self.eent_net_velocity_x);
		WriteCoord(MSG_ENTITY, self.eent_net_velocity_y);
		WriteCoord(MSG_ENTITY, self.eent_net_velocity_z);
	}
	else { WriteByte(MSG_ENTITY, FALSE); }

	if(!self.eent_eff_trail) { WriteByte(MSG_ENTITY, self.eent_net_count); }
	return TRUE;
}

// problem with this is, we might not have all the available effects for it
/*float Effect_NameToID(string eff_name)
{
	float i;
	for(i = EFFECT_FIRST; i < EFFECT_MAX; ++i)
	{
		if((effects_ent[i - 1]).eent_eff_name == eff_name)
			return (effects_ent[i - 1]).eent_net_name;
	}

	return 0;
} */

void Send_Effect(float eff_name, vector eff_loc, vector eff_vel, float eff_cnt)
{
	entity eff = effects_ent[eff_name - 1];
	if(!eff) { return; }
	if(!eff.eent_eff_trail && !eff_cnt) { return; } // effect has no count!
	entity net_eff = spawn();
	net_eff.owner = eff;
	net_eff.classname = "net_effect";
	//net_eff.eent_broadcast = broadcast;
	net_eff.eent_net_name = eff_name;
	net_eff.eent_net_velocity = eff_vel;
	net_eff.eent_net_location = eff_loc;
	net_eff.eent_net_count = eff_cnt;
	net_eff.eent_eff_trail = eff.eent_eff_trail;

	net_eff.think = SUB_Remove;
	net_eff.nextthink = time + 0.2; // don't need to keep this long

	Net_LinkEntity(net_eff, FALSE, 0, Net_Write_Effect);
}
#endif