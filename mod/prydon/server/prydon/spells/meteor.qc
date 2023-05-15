
void() meteor_hit =
{
	local entity e, oself;
	local float n;
	n = 35 * self.frags * self.frags + 60;
	oself = self;
	
	e = findradius(self.origin, n);
	while(e)
	{
		if (e.takedamage)
		{
			if (!friendly(e, oself))
			{
				oself.fire = (n - vlen(e.origin - oself.origin) * 0.3) + 5;
				// ugh
				
				MagicHit(oself, e);
			}
		}
		e = e.chain;
	}
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, oself.origin_x);
	WriteCoord (MSG_BROADCAST, oself.origin_y);
	WriteCoord (MSG_BROADCAST, oself.origin_z);
	remove(oself);
}

void() meteor_go =
{
	setmodel(self, "progs/meteor.mdl");
	self.avelocity = (random() *  '3000 0 0' + random() * '0 3000 0' + random() * '0 0 3000') - '1500 1500 1500';
	setsize(self, '0 0 0', '0 0 0');
	self.velocity = self.finalangle;
	self.movetype = MOVETYPE_FLY;
	self.solid = SOLID_BBOX;
	self.touch = meteor_hit;
	self.think = meteor_hit;
	self.nextthink = self.ac + 2;
	self.enemy = self.owner;
};