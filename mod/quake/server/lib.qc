float anglemod(float v)
{
	while(v >= 360)
		v = v - 360;
	while(v < 0)
		v = v + 360;
	return v;
}

float crandom()
{
	return 2*(random() - 0.5);
}

bool EntitiesTouching(entity e1, entity e2)
{
	if((e1.mins.x > e2.maxs.x)
	|| (e1.mins.y > e2.maxs.y)
	|| (e1.mins.z > e2.maxs.z)
	|| (e1.maxs.x < e2.mins.x)
	|| (e1.maxs.y < e2.mins.y)
	|| (e1.maxs.z < e2.mins.z)
	) return false;

	return true;
}
