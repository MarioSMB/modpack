.float skeleton_info_modelindex;
.float skeleton_info_skin;
#define BONETYPE_LOWER 0
#define BONETYPE_UPPER 1
#define MAX_BONES 128
.float skeleton_bonetype[MAX_BONES];
.float skeleton_numbones;

void skeleton_loadinfo(entity e)
{
	float i;
	if(e.skeleton_info_modelindex == e.modelindex && e.skeleton_info_skin == e.skin)
		return;
	e.bone_upperbody = 0;
	e.bone_weapon = gettagindex(e, "weapon");
	e.bone_hat = gettagindex(e, "head");
	if(!e.bone_hat)
		e.bone_hat = gettagindex(e, "tag_head");
	if(!e.bone_hat)
		e.bone_hat = gettagindex(e, "bip01 head");
	if(!e.bone_weapon)
		e.bone_weapon = gettagindex(e, "tag_weapon");
	if(!e.bone_weapon)
		e.bone_weapon = gettagindex(e, "bip01 r hand");
	for(i = 0; i < MAX_AIM_BONES; ++i)
	{
		e.(bone_aim[i]) = 0;
		e.(bone_aimweight[i]) = 0;
	}
	e.fixbone = 0;
	if(get_model_parameters(e.model, e.skin))
	{
		if(get_model_parameters_bone_upperbody)
			e.bone_upperbody = gettagindex(e, get_model_parameters_bone_upperbody);
		if(e.bone_upperbody)
			e.fixbone = get_model_parameters_fixbone;
		if(get_model_parameters_bone_weapon)
			e.bone_weapon = gettagindex(e, get_model_parameters_bone_weapon);
		for(i = 0; i < MAX_AIM_BONES; ++i)
		{
			if(get_model_parameters_bone_aim[i])
				e.(bone_aim[i]) = gettagindex(e, get_model_parameters_bone_aim[i]);
			if(e.bone_aim[i])
				e.(bone_aimweight[i]) = get_model_parameters_bone_aimweight[i];
		}
	}
	else
		dprint("No model parameters for ", e.model, "\n");
	//dprint(e.model, " uses ", ftos(e.bone_upperbody), " ", ftos(e.fixbone), "\n");
	get_model_parameters(string_null, 0);
	e.skeleton_info_modelindex = e.modelindex;
	e.skeleton_info_skin = e.skin;
	if(e.skeletonindex)
	{
		skel_delete(e.skeletonindex);
		e.skeletonindex = 0;
	}
}

void skeleton_markbones(entity e)
{
	float s = e.skeletonindex;
	float n = (e.skeleton_numbones = skel_get_numbones(s));
	float i;
	for(i = 1; i <= n; ++i)
	{
		float t = BONETYPE_LOWER;
		float p = skel_get_boneparent(s, i);
		if(p > 0)
			t = e.(skeleton_bonetype[p-1]);
		if(i == e.bone_upperbody)
			t = BONETYPE_UPPER;
		e.(skeleton_bonetype[i-1]) = t;
	}
}

void skel_set_boneabs(float s, float bone, vector absorg)
{
	vector absang = fixedvectoangles2(v_forward, v_up);

	vector parentorg = skel_get_boneabs(s, skel_get_boneparent(s, bone));
	vector parentang = fixedvectoangles2(v_forward, v_up);

	vector relang = AnglesTransform_LeftDivide(parentang, absang);
	vector relorg = AnglesTransform_Apply(AnglesTransform_Invert(parentang), absorg - parentorg);

	fixedmakevectors(relang);
	skel_set_bone(s, bone, relorg);

	/*
	vector neworg = skel_get_boneabs(s, bone);
	print(sprintf("ANG: want: %v, got: %v\n", absang, fixedvectoangles2(v_forward, v_up)));
	print(sprintf("ORG: want: %v, got: %v\n", absorg, neworg));
	*/
}

void free_skeleton_from_frames(entity e)
{
	if(e.skeletonindex)
	{
		skel_delete(e.skeletonindex);
		e.skeletonindex = 0;
	}
}

void skeleton_from_frames(entity e, float is_dead)
{
	float i;
	float m = e.modelindex;
	if(!e.skeletonindex)
	{
		e.skeletonindex = skel_create(m);
		skeleton_markbones(e);
	}
	float s = e.skeletonindex;
	if(!s)
		return;
	float bone;
	float n = e.skeleton_numbones;
	float savelerpfrac = e.lerpfrac;
	float savelerpfrac3 = e.lerpfrac3;
	float savelerpfrac4 = e.lerpfrac4;

	vector fixbone_oldangles = '0 0 0';
	if(e.fixbone)
	{
		// make all bones BONETYPE_UPPER
		e.lerpfrac = 0;
		e.lerpfrac3 = savelerpfrac3 * 2;
		e.lerpfrac4 = 0;
		// build skeleton
		skel_build(s, e, m, 0, 1, n);
		// get hip bone
		skel_get_boneabs(s, e.bone_upperbody);
		fixbone_oldangles = fixedvectoangles2(v_forward, v_up);
	}

	for(bone = 0; bone < n; )
	{
		float firstbone = bone;
		float bonetype = e.skeleton_bonetype[bone];
		for(++bone; (bone < n) && (e.skeleton_bonetype[bone] == bonetype); ++bone)
			;
		if(bonetype == BONETYPE_UPPER)
		{
			// only show frames 1+3 (upper body)
			e.lerpfrac = 0;
			e.lerpfrac3 = savelerpfrac3 * 2;
			e.lerpfrac4 = 0;
		}
		else
		{
			// only show frames 2+4 (lower body)
			e.lerpfrac = savelerpfrac * 2;
			e.lerpfrac3 = 0;
			e.lerpfrac4 = savelerpfrac4 * 2;
		}
		//print(sprintf("Run: bone %d to %d, type %d\n", firstbone + 1, bone, bonetype));
		//print(sprintf("frame %d %d %d %d lerpfrac * %d %d %d\n", e.frame, e.frame2, e.frame3, e.frame4, e.lerpfrac, e.lerpfrac3, e.lerpfrac4));
		skel_build(s, e, m, 0, firstbone + 1, bone);
	}
	e.lerpfrac = savelerpfrac;
	e.lerpfrac3 = savelerpfrac3;
	e.lerpfrac4 = savelerpfrac4;

	if(e.fixbone)
	{
		// FIX IT
		vector org = skel_get_boneabs(s, e.bone_upperbody);
		fixedmakevectors(fixbone_oldangles);
		skel_set_boneabs(s, e.bone_upperbody, org);
	}

	if(!is_dead)
	{
		for(i = 0; i < MAX_AIM_BONES; ++i)
		{
			if(e.(bone_aim[i]))
			{
				vector aim = '1 0 0' * bound(-90, self.v_angle_x, 90) * e.(bone_aimweight[i]);
				vector org = skel_get_boneabs(s, e.(bone_aim[i]));
				vector ang_cur = fixedvectoangles2(v_forward, v_up);
				vector ang = AnglesTransform_Multiply(aim, ang_cur);
				fixedmakevectors(ang);
				skel_set_boneabs(s, e.(bone_aim[i]), org);
			}
		}
	}
}
