#ifdef POSITIVE_PITCH_IS_DOWN
vector fixedvectoangles(vector a)
{
	vector ang;
	ang = vectoangles(a);
	ang_x = -ang_x;
	return ang;
}
vector fixedvectoangles2(vector a, vector b)
{
	vector ang;
	ang = vectoangles2(a, b);
	ang_x = -ang_x;
	return ang;
}
#else
void fixedmakevectors(vector a)
{
	// a makevectors that actually inverts vectoangles
	a_x = -a_x;
	makevectors(a);
}
#endif

// angles transforms
// angles in fixedmakevectors/fixedvectoangles space
vector AnglesTransform_Apply(vector transform, vector v)
{
	fixedmakevectors(transform);
	return v_forward * v_x
		+ v_right   * (-v_y)
		+ v_up      * v_z;
}

vector AnglesTransform_Multiply(vector t1, vector t2)
{
	vector m_forward, m_up;
	fixedmakevectors(t2); m_forward = v_forward; m_up = v_up;
	m_forward = AnglesTransform_Apply(t1, m_forward); m_up = AnglesTransform_Apply(t1, m_up);
	return fixedvectoangles2(m_forward, m_up);
}

vector AnglesTransform_Invert(vector transform)
{
	vector i_forward, i_up;
	fixedmakevectors(transform);
	// we want angles that turn v_forward into '1 0 0', v_right into '0 1 0' and v_up into '0 0 1'
	// but these are orthogonal unit vectors!
	// so to invert, we can simply fixedvectoangles the TRANSPOSED matrix
	// TODO is this always -transform?
	i_forward_x = v_forward_x;
	i_forward_y = -v_right_x;
	i_forward_z = v_up_x;
	i_up_x = v_forward_z;
	i_up_y = -v_right_z;
	i_up_z = v_up_z;
	return fixedvectoangles2(i_forward, i_up);
}

vector AnglesTransform_TurnDirectionFR(vector transform)
{
	// turn 180 degrees around v_up
	// changes in-direction to out-direction
	//fixedmakevectors(transform);
	//return fixedvectoangles2(-1 * v_forward, 1 * v_up);
	transform_x = -transform_x;
	transform_y = 180 + transform_y;
	transform_z = -transform_z;
	// pitch: -s +c
	// yaw:   -s -c
	// roll:  -s +c
	return transform;
}

vector AnglesTransform_TurnDirectionFU(vector transform)
{
	// turn 180 degrees around v_up
	// changes in-direction to out-direction
	//fixedmakevectors(transform);
	//return fixedvectoangles2(-1 * v_forward, 1 * v_up);
	transform_x = -transform_x;
	transform_y = 180 + transform_y;
	transform_z = 180 - transform_z;
	return transform;
}

vector AnglesTransform_RightDivide(vector to_transform, vector from_transform)
{
	return AnglesTransform_Multiply(to_transform, AnglesTransform_Invert(from_transform));
}

vector AnglesTransform_LeftDivide(vector from_transform, vector to_transform)
{
	return AnglesTransform_Multiply(AnglesTransform_Invert(from_transform), to_transform);
}

vector AnglesTransform_Normalize(vector t, float minimize_roll)
{
	float need_flip;
	// first, bring all angles in their range...
	t_x = t_x - 360 * rint(t_x / 360);
	t_y = t_y - 360 * rint(t_y / 360);
	t_z = t_z - 360 * rint(t_z / 360);
	if(minimize_roll)
		need_flip = (t_z > 90 || t_z <= -90);
	else
		need_flip = (t_x > 90 || t_x < -90); // for pitch we prefer to allow exactly -90 degrees for looking straight down
	if(need_flip)
	{
		if(t_x >= 0) t_x = 180 - t_x; else t_x = -180 - t_x;
		if(t_y > 0) t_y -= 180; else t_y += 180;
		if(t_z > 0) t_z -= 180; else t_z += 180;
	}
	return t;
}

vector AnglesTransform_CancelRoll(vector t)
{
	const float epsilon = 30;
	float f;

	// constraints:
	// forward vector (NOT SO important)
	// right vector, up vector: screen rotation (MORE important)
	// choose best match among all pitch-yaw only rotations

	// FIXME find a better method

	f = fabs(t_x - (-90)) / epsilon;
	if(f < 1)
	{
		//t_x = -90;
		t_y += t_z;
		t_z = 0;
	}
	else
	{
		f = fabs(t_x - 90) / epsilon;
		if(f < 1)
		{
			//t_x = 90;
			t_y -= t_z;
			t_z = 0;
		}
	}
	return t;
}

#ifdef POSITIVE_PITCH_IS_DOWN
vector AnglesTransform_ApplyToAngles(vector transform, vector v)
{
	v_x = -v_x;
	v = AnglesTransform_Multiply(transform, v);
	v_x = -v_x;
	return v;
}
vector AnglesTransform_ApplyToVAngles(vector transform, vector v)
{
	v = AnglesTransform_Multiply(transform, v);
	return v;
}
vector AnglesTransform_FromAngles(vector v)
{
	v_x = -v_x;
	return v;
}
vector AnglesTransform_ToAngles(vector v)
{
	v_x = -v_x;
	return v;
}
vector AnglesTransform_FromVAngles(vector v)
{
	return v;
}
vector AnglesTransform_ToVAngles(vector v)
{
	return v;
}
#else
vector AnglesTransform_ApplyToAngles(vector transform, vector v)
{
	v = AnglesTransform_Multiply(transform, v);
	return v;
}
vector AnglesTransform_ApplyToVAngles(vector transform, vector v)
{
	v_x = -v_x;
	v = AnglesTransform_Multiply(transform, v);
	v_x = -v_x;
	return v;
}
vector AnglesTransform_FromAngles(vector v)
{
	return v;
}
vector AnglesTransform_ToAngles(vector v)
{
	return v;
}
vector AnglesTransform_FromVAngles(vector v)
{
	v_x = -v_x;
	return v;
}
vector AnglesTransform_ToVAngles(vector v)
{
	v_x = -v_x;
	return v;
}
#endif

vector AnglesTransform_Multiply_GetPostShift(vector t0, vector st0, vector t1, vector st1)
{
	// we want the result of:
	//   t0 * (t1 * p + st1) + st0
	//   t0 * t1 * p + t0 * st1 + st0
	return st0 + AnglesTransform_Apply(t0, st1);
}
vector AnglesTransform_PrePostShift_GetPostShift(vector sf, vector t, vector st)
{
	return st - AnglesTransform_Apply(t, sf);
}
