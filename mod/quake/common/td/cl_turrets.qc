#include "cl_turrets.qh"

PRECACHE(cl_turrets)
{
	precache_pic("gfx/quake/tur_level1");
	precache_pic("gfx/quake/tur_level2");
	precache_pic("gfx/quake/tur_level3");
	precache_pic("gfx/quake/tur_level4");
	precache_pic("gfx/quake/tur_level5");
}

void turret_remove(entity this)
{
	delete(this.tur_head);
	this.tur_head = NULL;
}

.float anim_finished;
void turret_anim(entity this)
{
	if(time < this.anim_finished)
		return;

	this.anim_finished = time + 0.1;

	vector myanim = (this.clientframe == TANIM_SHOOT) ? this.anim_shoot : this.anim_idle;

	int next_frame = this.frame + 1;

	if(next_frame < myanim.x)
		next_frame = myanim.x;
	else if(next_frame > myanim.y)
	{
		// if we don't loop, just stop at the end
		next_frame = (myanim.z) ? myanim.y : myanim.x;
	}

	if(next_frame != this.frame)
	{
		CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
		this.frame = next_frame;
		CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
	}
}

void turret_draw(entity this)
{
	float dt = time - this.move_time;
	this.move_time = time;
	if (dt <= 0)
		return;

	this.tur_head.angles += dt * this.tur_head.avelocity;

	float mhealth = (this.max_health > 0) ? this.max_health : 255;

	if (this.health < (mhealth * 0.5))
	{
		dt = random();

		if (dt < 0.03)
			te_spark(this.origin + '0 0 40', randomvec() * 256 + '0 0 256', 16);
	}

	if (this.health < (mhealth * 0.33)
	&& dt < 0.01)
		pointparticles(EFFECT_SMOKE_LARGE, (this.origin + (randomvec() * 80)), '0 0 0', 1);

	if (this.health < (mhealth * 0.12)
	&& dt < 0.015)
		pointparticles(EFFECT_SMOKE_SMALL, (this.origin + (randomvec() * 80)), '0 0 0', 1);

	turret_anim(this);

	Turret tur = this.turretdef;
	if(tur.tr_think)
		tur.tr_think(tur, this);

	CSQCModel_InterpolateAnimation_Do(this);
}

void turret_draw2d(entity this)
{
	if (this.netname == "")
		return;
	if (!autocvar_g_waypointsprite_turrets || autocvar_cl_hidewaypoints)
		return;

	float dist = vlen(this.origin - view_origin);

	if (dist > this.maxdistance)
		return;

	string spriteimage = this.netname;
	float a = this.alpha * autocvar_sbar_alpha_fg;
	vector rgb = spritelookupcolor(this, spriteimage, '1 0 0');

	if (this.maxdistance > waypointsprite_normdistance)
		a *= (bound(0, (this.maxdistance - dist) / (this.maxdistance - waypointsprite_normdistance), 1) ** waypointsprite_distancealphaexponent);
	else if (this.maxdistance > 0)
		a *= (bound(0, (waypointsprite_fadedistance - dist) / (waypointsprite_fadedistance - waypointsprite_normdistance), 1) ** waypointsprite_distancealphaexponent) * (1 - waypointsprite_minalpha) + waypointsprite_minalpha;

	if (rgb == '0 0 0')
	{
		LOG_INFOF("WARNING: sprite of name %s has no color, using pink so you notice it", spriteimage);
	}

	string pic = "";
	if(this.tur_level > 0)
	{
		switch(this.tur_level)
		{
			case 1: pic = "gfx/quake/tur_level1"; break;
			case 2: pic = "gfx/quake/tur_level2"; break;
			case 3: pic = "gfx/quake/tur_level3"; break;
			case 4: pic = "gfx/quake/tur_level4"; break;
			case 5: pic = "gfx/quake/tur_level5"; break;
		}
	}

	if (time - floor(time) > 0.5)
	{
		if (this.helpme && time < this.helpme)
		{
			a *= SPRITE_HELPME_BLINK;
		}
		else
			a *= spritelookupblinkvalue(this, spriteimage);
	}

	if (a > 1)
	{
		rgb *= a;
		a = 1;
	}
	else if (a <= 0)
		return;

	rgb = fixrgbexcess(rgb);

	vector o = project_3d_to_2d(this.origin + '0 0 64');
	if (o.z < 0
	||  o.x < vid_conwidth * waypointsprite_edgeoffset_left
	||  o.y < vid_conheight * waypointsprite_edgeoffset_top
	||  o.x > vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right)
	||  o.y > vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom))
		return; // Dont draw wp's for turrets out of view

	o.z = 0;

	float edgedistance_min = min(
		o.y - (vid_conheight * waypointsprite_edgeoffset_top),
		o.x - (vid_conwidth  * waypointsprite_edgeoffset_left),
		vid_conwidth  - (vid_conwidth  * waypointsprite_edgeoffset_right)  - o.x,
		vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom) - o.y
	);

	float crosshairdistance = sqrt((o.x - vid_conwidth * 0.5) ** 2 + (o.y - vid_conheight * 0.5) ** 2);

	float t = waypointsprite_scale;
	a *= waypointsprite_alpha;

	{
		a *= 1 - (1 - waypointsprite_distancefadealpha) * (bound(0, dist / waypointsprite_distancefadedistance, 1));
		t *= 1 - (1 - waypointsprite_distancefadescale) * (bound(0, dist / waypointsprite_distancefadedistance, 1));
	}
	if (edgedistance_min < waypointsprite_edgefadedistance)
	{
		a *= 1 - (1 - waypointsprite_edgefadealpha) * (1 - bound(0, edgedistance_min / waypointsprite_edgefadedistance, 1));
		t *= 1 - (1 - waypointsprite_edgefadescale) * (1 - bound(0, edgedistance_min / waypointsprite_edgefadedistance, 1));
	}
	if (crosshairdistance < waypointsprite_crosshairfadedistance)
	{
		a *= 1 - (1 - waypointsprite_crosshairfadealpha) * (1 - bound(0, crosshairdistance / waypointsprite_crosshairfadedistance, 1));
		t *= 1 - (1 - waypointsprite_crosshairfadescale) * (1 - bound(0, crosshairdistance / waypointsprite_crosshairfadedistance, 1));
	}

	float mhealth = (this.max_health > 0) ? this.max_health : 255;
	bool draw_healthbar = ((this.helpme && time < this.helpme) || this.health < mhealth);

	if (this.tur_level > 0 && pic != "")
		o = drawsprite_TextOrIcon(false, o, M_PI, 0, '1 1 1', a, autocvar_g_waypointsprite_iconsize * '1 1 0', pic);
	if (draw_healthbar)
		drawhealthbar(
			o,
			0,
			this.health / mhealth,
			'0 0 0',
			'0 0 0',
			0.5 * t * SPRITE_HEALTHBAR_WIDTH,
			0.5 * t * SPRITE_HEALTHBAR_HEIGHT,
			t * SPRITE_HEALTHBAR_MARGIN + 0.5 * waypointsprite_fontsize,
			t * SPRITE_HEALTHBAR_BORDER,
			0,
			rgb,
			a * SPRITE_HEALTHBAR_BORDERALPHA,
			rgb,
			a * SPRITE_HEALTHBAR_HEALTHALPHA,
			DRAWFLAG_NORMAL
		);
}

void turret_construct(entity this, bool isNew)
{
	entity tur = this.turretdef;

	if (!this.tur_head)
	{
		tur.tr_precache(tur);
		this.tur_head = spawn();

		precache_model(tur.mdl);
		if(tur.head_model != "")
			precache_model(tur.head_model);
	}

	this.netname = tur.m_name;

	setorigin(this, this.origin);
	_setmodel(this, tur.mdl);
	if(tur.head_model != "")
		_setmodel(this.tur_head, tur.head_model);
	this.solid = SOLID_BBOX; // before setsize so it will be linked to the area grid
	this.tur_head.solid = SOLID_NOT;
	setsize(this, tur.m_mins, tur.m_maxs);
	setsize(this.tur_head, '0 0 0', '0 0 0');

	setattachment(this.tur_head, this, "");

	this.tur_head.classname  = "turret_head";
	this.tur_head.owner      = this;
	if(tur.spawnflags & TUR_FLAG_FLOATING)
		set_movetype(this, MOVETYPE_FLY);
	else
		set_movetype(this, MOVETYPE_TOSS); // was noclip
	set_movetype(this.tur_head, this.move_movetype);
	this.tur_head.angles     = this.angles;
	//this.health = 255;
	this.health = this.max_health;
	this.draw                = turret_draw;
	this.entremove           = turret_remove;
	this.drawmask            = MASK_NORMAL;
	this.tur_head.drawmask   = MASK_NORMAL;
	//this.anim_start_time     = 0;
	this.draw2d = turret_draw2d;
	this.maxdistance = autocvar_g_waypointsprite_turrets_maxdist;
	this.alpha = 1;

	if (isNew)
	{
		IL_PUSH(g_drawables, this);
		IL_PUSH(g_drawables_2d, this);
	}

	tur.tr_setup(tur, this);
}

void turret_die(entity this)
{
	sound(this, CH_SHOTS, SND_ROCKET_EXPLOSION, VOL_BASE, ATTEN_NORM);
	pointparticles(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	setmodel(this, MDL_Null);
	setmodel(this.tur_head, MDL_Null);
}

NET_HANDLE(ENT_CLIENT_TURRET, bool isNew)
{
	int sf = ReadByte();

	if (sf & TNSF_SETUP)
	{
		this.turretdef = ReadRegistered(Turrets);
		this.max_health = ReadFloat();
		this.clipgroup = ReadByte();
		this.tur_units = ReadByte();

		setorigin(this, ReadVector());

		this.angles = ReadAngleVector2D();

		turret_construct(this, isNew);
	}

	if (sf & TNSF_ANG)
	{
		if (this.tur_head == NULL) // apparently this can happpen before TNSF_SETUP. great.
			this.tur_head = spawn();

		this.tur_head.angles.x = ReadShort();
		this.tur_head.angles.y = ReadShort();
		//this.tur_head.angles = this.angles + this.tur_head.angles;
	}

	if (sf & TNSF_AVEL)
	{
		if (this.tur_head == NULL) // apparently this can happpen before TNSF_SETUP. great.
			this.tur_head = spawn();

		this.tur_head.avelocity.x = ReadShort();
		this.tur_head.avelocity.y = ReadShort();
	}

	if (sf & TNSF_MOVE)
	{
		this.origin = ReadVector();
		setorigin(this, this.origin);

		this.velocity = ReadVector();
		this.angles.y = ReadShort();

		this.move_time = time;
	}

	if (sf & TNSF_ANIM)
	{
		this.clientframe = ReadByte();
		this.frame = 0;
		CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
		CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
		this.lerpfrac = 0; // reset frames
	}

	if (sf & TNSF_LEVEL)
	{
		this.tur_level = ReadByte();
		this.max_health = ReadFloat();
	}

	if (sf & TNSF_STATUS)
	{
		int _tmp = ReadFloat();
		float myhp = this.health;
		if (_tmp == 0 && myhp != 0)
			turret_die(this);
		else if (myhp && myhp > _tmp)
			this.helpme = servertime + 10;
		else if (myhp && myhp < _tmp)
			this.helpme = 0; // we're being healed, don't spam help me waypoints

		this.health = _tmp;
	}
	return true;
}
