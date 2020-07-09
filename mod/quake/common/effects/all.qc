#include "all.qh"

REGISTER_NET_TEMP(net_effect)
#ifdef CSQC
NET_HANDLE(net_effect, bool isNew)
{
	int net_name = (Effects_COUNT >= 255) ? ReadShort() : ReadByte();

	entity eff = REGISTRY_GET(Effects, net_name);

	vector vel = '0 0 0';
	int eff_cnt = 1;
	bool eff_trail = eff.eent_eff_trail;
	vector v;
	v_x = ReadCoord();
	v_y = ReadCoord();
	v_z = ReadCoord();

	bool use_vel = ReadByte();
	if(use_vel)
	{
		vel_x = ReadCoord();
		vel_y = ReadCoord();
		vel_z = ReadCoord();
	}

	if(!eff_trail)
		eff_cnt = ReadByte();

	if(eff_trail)
		trailparticles(NULL, eff, v, vel);
	else
		pointparticles(eff, v, vel, eff_cnt);
	return true;
}
#endif

#ifdef SVQC
bool Net_Write_Effect(entity this, entity client, int sf)
{
	int channel = MSG_ONE;
	msg_entity = client;
	WriteHeader(channel, net_effect);
	(Effects_COUNT >= 255)
	? WriteShort(channel, this.m_id)
	: WriteByte(channel, this.m_id);
	WriteCoord(channel, this.eent_net_location_x);
	WriteCoord(channel, this.eent_net_location_y);
	WriteCoord(channel, this.eent_net_location_z);

	// attempt to save a tiny bit more bandwidth by not sending velocity if it isn't set
	if(this.eent_net_velocity)
	{
		WriteByte(channel, true);
		WriteCoord(channel, this.eent_net_velocity_x);
		WriteCoord(channel, this.eent_net_velocity_y);
		WriteCoord(channel, this.eent_net_velocity_z);
	}
	else { WriteByte(channel, false); }

	if(!this.eent_eff_trail) { WriteByte(channel, this.eent_net_count); }
	return true;
}

void Send_Effect(entity eff, vector eff_loc, vector eff_vel, int eff_cnt)
{
	if(!eff) { return; }
	if(!eff.eent_eff_trail && !eff_cnt) { return; } // effect has no count!
	entity net_eff = new_pure(net_effect);
	net_eff.owner = eff;
	//net_eff.eent_broadcast = broadcast;
	net_eff.m_id = eff.m_id;
	net_eff.eent_net_velocity = eff_vel;
	net_eff.eent_net_location = eff_loc;
	net_eff.eent_net_count = eff_cnt;
	net_eff.eent_eff_trail = eff.eent_eff_trail;

	FOREACH_CLIENT(IS_REAL_CLIENT(it), Net_Write_Effect(net_eff, it, 0));
	delete(net_eff);
}

void Send_Effect_(string eff_name, vector eff_loc, vector eff_vel, int eff_cnt)
{
	// problem with this is, we might not have all the available effects for it
	FOREACH(Effects, it.eent_eff_name == eff_name, {
		Send_Effect(it, eff_loc, eff_vel, eff_cnt);
		return;
	});
	// revert to engine handling
	__pointparticles(_particleeffectnum(eff_name), eff_loc, eff_vel, eff_cnt);
}
#endif
