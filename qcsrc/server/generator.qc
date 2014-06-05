float generator_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_GENERATOR);
	WriteByte(MSG_ENTITY, sf);
	if(sf & GSF_SETUP)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		WriteByte(MSG_ENTITY, self.health);
		WriteByte(MSG_ENTITY, self.max_health);
		WriteByte(MSG_ENTITY, self.count);
		WriteByte(MSG_ENTITY, self.team);
	}

	if(sf & GSF_STATUS)
	{
		WriteByte(MSG_ENTITY, self.team);

		if(self.health <= 0)
			WriteByte(MSG_ENTITY, 0);
		else
			WriteByte(MSG_ENTITY, ceil((self.health / self.max_health) * 255));
	}

	return TRUE;
}

void generator_link(void() spawnproc)
{
	Net_LinkEntity(self, TRUE, 0, generator_send);
	self.think		= spawnproc;
	self.nextthink	= time;
}
