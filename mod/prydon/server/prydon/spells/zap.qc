



void(float lev) zap_go =
{
	local entity e, laste;
	
	makevectors(self.angles);
	sound(self, CHAN_WEAPON, "spells/lit.wav", 1, ATTN_NORM);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING1);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, self.origin_x + v_forward_x * 8);
	WriteCoord(MSG_BROADCAST, self.origin_y + v_forward_y * 8);
	WriteCoord(MSG_BROADCAST, self.origin_z + 16);
	WriteCoord(MSG_BROADCAST, self.enemy.origin_x);
	WriteCoord(MSG_BROADCAST, self.enemy.origin_y);
	WriteCoord(MSG_BROADCAST, self.enemy.origin_z);
	if (lev == 0)
		LightningDamage(self, self.enemy, 6);	
	else
		LightningDamage(self, self.enemy, 10 + lev * lev);	
	lev = lev - 3;
	laste = self.enemy;
	
	while (lev > 0)
	{
		e = findradius(laste.origin, 100);
		while (e)
		{
			if (e != laste)
			{
				if (e.takedamage && (e.dmg_take != time))
				{
					if (!friendly(e, self))
					{
	
						WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
						WriteByte(MSG_BROADCAST, TE_LIGHTNING1);
						WriteEntity(MSG_BROADCAST, laste);
						WriteCoord(MSG_BROADCAST, laste.origin_x);
						WriteCoord(MSG_BROADCAST, laste.origin_y);
						WriteCoord(MSG_BROADCAST, laste.origin_z);
						WriteCoord(MSG_BROADCAST, e.origin_x);
						WriteCoord(MSG_BROADCAST, e.origin_y);
						WriteCoord(MSG_BROADCAST, e.origin_z);
						laste = e;
						e.dmg_take = time;
						LightningDamage(self, e, 15 + ceil(lev * lev * 1.4));
					}
				}
			}
			e = e.chain;
		}
		lev = lev - 2;	
	}
}
