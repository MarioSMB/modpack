#define ANTILAG_MAX_ORIGINS 64
.vector antilag_origins[ANTILAG_MAX_ORIGINS];
.float antilag_times[ANTILAG_MAX_ORIGINS];
.float antilag_index;
.vector antilag_saved_origin;
.float antilag_takenback;

.float antilag_debug;

void antilag_record(entity e, float t)
{
    if (e.vehicle && e.vehicle.vehicle_flags == VHF_PLAYERSLOT)
        return;
        
    if(e.vehicle)
        antilag_record(e.vehicle, t);

	if(time < e.(antilag_times[e.antilag_index]))
		return;
	e.antilag_index = e.antilag_index + 1;
	if(e.antilag_index >= ANTILAG_MAX_ORIGINS)
		e.antilag_index = 0;
	e.(antilag_times[e.antilag_index]) = t;
	e.(antilag_origins[e.antilag_index]) = e.origin;

	if(e.antilag_debug)
		te_spark(antilag_takebackorigin(e, t - e.antilag_debug), '0 0 0', 32);

}

// finds the index BEFORE t
float antilag_find(entity e, float t)
{
	float i;

	for(i = e.antilag_index; i > 0; --i)
		if(e.(antilag_times[i]) >= t)
			if(e.(antilag_times[i - 1]) < t)
				return i - 1;

	if(e.(antilag_times[0]) >= t)
		if(e.(antilag_times[ANTILAG_MAX_ORIGINS - 1]) < t)
			return ANTILAG_MAX_ORIGINS - 1;

	for(i = ANTILAG_MAX_ORIGINS - 1; i > e.antilag_index + 1; --i)
		if(e.(antilag_times[i]) >= t)
			if(e.(antilag_times[i - 1]) < t)
				return i - 1;

	// if we get here, t is sandwiched nowhere, so let's assume it's in the present
	return -1;
}

vector lerpv(float t0, vector v0, float t1, vector v1, float t)
{
	return v0 + (v1 - v0) * ((t - t0) / (t1 - t0));
}

vector antilag_takebackorigin(entity e, float t)
{
	float i0, i1;

	i0 = antilag_find(e, t);
	if(i0 < 0)
	{
		// IN THE PRESENT
		if(e.antilag_takenback)
			return e.antilag_saved_origin;
		else
			return e.origin;
	}
	i1 = i0 + 1;
	if(i1 >= ANTILAG_MAX_ORIGINS)
		i1 = 0;

	return lerpv(e.(antilag_times[i0]), e.(antilag_origins[i0]), e.(antilag_times[i1]), e.(antilag_origins[i1]), t);
}

vector antilag_takebackavgvelocity(entity e, float t0, float t1)
{
	vector o0, o1;

	if(t0 >= t1)
		return '0 0 0';
	o0 = antilag_takebackorigin(e, t0);
	o1 = antilag_takebackorigin(e, t1);
	return (o1 - o0) * (1 / (t1 - t0));
}

void antilag_takeback(entity e, float t)
{

    if (e.vehicle && e.vehicle.vehicle_flags == VHF_PLAYERSLOT)
        return;

	if(e.vehicle)
		antilag_takeback(e.vehicle, t);

	if(!e.antilag_takenback)
		e.antilag_saved_origin = e.origin;

	setorigin(e, antilag_takebackorigin(e, t));
	e.antilag_takenback = TRUE;
}

void antilag_restore(entity e)
{
    if (e.vehicle && e.vehicle.vehicle_flags == VHF_PLAYERSLOT)
        return;

	if(e.vehicle)
		antilag_restore(e.vehicle);

	if(!e.antilag_takenback)
		return;

	setorigin(e, e.antilag_saved_origin);
	e.antilag_takenback = FALSE;
}

void antilag_clear(entity e)
{
	float i;

	antilag_restore(e);
	for(i = 0; i < ANTILAG_MAX_ORIGINS; ++i)
	{
		e.(antilag_times[i]) = -2342;
		e.(antilag_origins[i]) = e.origin;
	}
	e.antilag_index = ANTILAG_MAX_ORIGINS - 1; // next one is 0
}
