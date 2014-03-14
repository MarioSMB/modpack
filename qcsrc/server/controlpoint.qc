float cpicon_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_CONTROLPOINT_ICON);
	WriteByte(MSG_ENTITY, sf);
	if(sf & CPSF_SETUP)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		WriteByte(MSG_ENTITY, self.health);
		WriteByte(MSG_ENTITY, self.max_health);
		WriteByte(MSG_ENTITY, self.count);
		WriteByte(MSG_ENTITY, self.team);
		WriteByte(MSG_ENTITY, self.owner.iscaptured);
	}

	if(sf & CPSF_STATUS)
	{
		WriteByte(MSG_ENTITY, self.team);

		if(self.health <= 0)
			WriteByte(MSG_ENTITY, 0);
		else
			WriteByte(MSG_ENTITY, ceil((self.health / self.max_health) * 255));
	}

	return TRUE;
}

void onslaught_controlpoint_icon_link(entity e, void() spawnproc)
{
	Net_LinkEntity(e, TRUE, 0, cpicon_send);
	e.think		= spawnproc;
	e.nextthink	= time * sys_frametime;
}
