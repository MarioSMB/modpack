void damage(entity targ, float amount, vector dir, entity dealer)
{
	if(!targ.takedamage)
		return;
	
	if(targ.health <= 0)
		return;
	
	targ.health -= amount;
	
	if(targ.health > 0)
	{
		if(targ.hurt)
			targ.hurt(targ, amount, dir, dealer);
	}
	else if(targ.die)
	{
		targ.die(targ, amount, dir, dealer);
	}
}

void radius_damage(vector origin, float radius, float mindmg, float maxdmg, entity dealer)
{
	if(radius <= 0)
		radius = 1;
	for(entity targ = findradius(origin, radius); targ; targ = targ.chain)
	{
		if(!targ.takedamage)
			continue;
		if(targ.health <= 0)
			continue;
		
		vector targetcenter = (targ.absmin + targ.absmax) * 0.5;
		traceline(origin, targetcenter, MOVE_NOMONSTERS, dealer);
		if(trace_fraction < 1)
			continue;
		
		float ratio = vlen(origin - targetcenter) / radius;
		float realdamage = (ratio * maxdmg) + (1 - ratio) * mindmg;
		damage(targ, realdamage, normalize(targetcenter - origin), dealer);
	}
}
