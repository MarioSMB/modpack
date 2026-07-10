#include "util.qh"

#ifdef SVQC

/**
* Update this.tur_shotorg by getting up2date bone info
* NOTICE this func overwrites the global v_forward, v_right and v_up vectors.
*/
bool turret_tag_fire_update(entity this)
{
	if (!this.tur_head)
	{
		LOG_DEBUG("Call to turret_tag_fire_update with this.tur_head missing!");
		this.tur_shotorg = '0 0 0';
		return false;
	}

	// NOTE: Xonotic turrets use tags exclusively
	// for Quake, we need to be a bit creative...
	// defining .view_ofs on the turret will act as a shot origin offset
	// this applies when using .mdl models (.head_model may be set to "null" where needed)

	int tag = gettagindex(this.tur_head, "tag_fire");

	if(tag)
		this.tur_shotorg = gettaginfo(this.tur_head, tag);
	else
	{
		this.tur_shotorg = gettaginfo(this.tur_head, 0) + this.view_ofs;
		vector absang = fixedvectoangles2(v_forward, v_up);
		vector relang = AnglesTransform_ToAngles(absang);

		fixedmakevectors(relang);
	}

	v_forward = normalize(v_forward);

	return true;
}

#endif // SVQC
