#ifndef IMPLEMENTATION
#include "cl_conquest.qh"
#endif

#ifdef IMPLEMENTATION
#include <client/teamradar.qh>
#include <common/ent_cs.qh>
#include <common/mutators/mutator/waypoints/all.qh>

AUTOCVAR(cl_conquest_capture_ring_size_min, float, 32, "");
AUTOCVAR(cl_conquest_capture_ring_size_max, float, 128, "");
AUTOCVAR(cl_conquest_capture_ring_hud, bool, false, "");
AUTOCVAR(cl_conquest_capture_text_align, int, 0, "");

.float scale;

.float cq_factor;
void conquest_controlpoint_draw2d(entity this)
{
	if(this.cq_capdistance > 0)
		if(vdist(this.origin - view_origin, >, this.cq_capdistance))
			return;

	string img = "gfx/crosshair_ring.tga";
	vector psize = draw_getimagesize(img);
	vector loc = project_3d_to_2d(this.origin + '0 0 128'); // - 0.5 * psize;
	vector textloc = loc;
	if(!(loc_z < 0 || loc_x < 0 || loc_y < 0 || loc_x > vid_conwidth || loc_y > vid_conheight) || autocvar_cl_conquest_capture_ring_hud)
	{
		loc_z = psize_z = textloc_z = 0;
		float imgsize = autocvar_cl_conquest_capture_ring_size_min;
		vector textsize;
		if(autocvar_cl_conquest_capture_ring_hud)
		{
			loc = eX * 0.5 * vid_conwidth + eY * 0.6 * vid_conheight;
			textloc = eY * 0.64 * vid_conheight;
			textsize = eX * vid_conwidth + eY * 0.025 * vid_conheight;
			imgsize = 0.1 * vid_conheight;
		}
		else
		{
			imgsize = max(autocvar_cl_conquest_capture_ring_size_min, (1 - vlen(this.origin - view_origin) / this.cq_capdistance) * autocvar_cl_conquest_capture_ring_size_max);
			textsize = '4 2 0' * autocvar_cl_conquest_capture_ring_size_min;
			if(autocvar_cl_conquest_capture_text_align == 1)
				textloc_x -= textsize_x / 2;
			else if(autocvar_cl_conquest_capture_text_align == 2)
				textloc_x -= textsize_x;
		}

		//drawstring_aspect(eY * 0.64 * vid_conheight, _("Capture progress"), eX * vid_conwidth + eY * 0.025 * vid_conheight, '1 1 1', 1, DRAWFLAG_NORMAL);
		int player_team = (entcs_GetTeam(player_localnum) + 1);
		string msg = "";
		if(this.team == player_team)
		{
			switch(this.cq_status)
			{
				default:
				case CP_NEUTRAL: msg = sprintf(_("Capturing %s"), this.netname); break;
				case CP_CAPTURED: msg = sprintf(_("Defending %s"), this.netname); break;
			}
		}
		else if(spectatee_status)
			msg = sprintf(_("Observing %s"), this.netname);
		else if(this.team && this.cq_status == CP_CAPTURED)
			msg = sprintf(_("Liberating %s"), this.netname);

		if(msg != "")
		{
			drawstring_aspect(textloc, msg, textsize, '1 1 1', 1, DRAWFLAG_NORMAL);
			DrawCircleClippedPic(loc, imgsize, img, this.cq_factor, this.teamradar_color, 1, DRAWFLAG_ADDITIVE);
		}
	}
}

.float cq_rate;
void conquest_controlpoint_predraw(entity this)
{
	this.enemy.angles_y += 32 * frametime;
	float step = this.cq_rate * frametime;
	if ( this.cq_factor < GetResourceAmount(this, RESOURCE_HEALTH) - step/2 )
		this.cq_factor += step;
	else if ( this.cq_factor > GetResourceAmount(this, RESOURCE_HEALTH) + step/2 )
		this.cq_factor -= step;
	setorigin(this.enemy, this.origin + '0 0 1' * (50 + (this.cq_factor * 140)));
}

void conquest_controlpoint_remove(entity this)
{
	if(this.enemy)
		delete(this.enemy);

	if(this.netname)
		strunzone(this.netname);
}

NET_HANDLE(ENT_CLIENT_CONQUEST_CONTROLPOINT, bool is_new)
{
	int sf = ReadByte();

	if(sf & CQSF_SETUP)
	{
		this.origin = ReadVector();
		setorigin(this, this.origin);
		this.drawmask = MASK_NORMAL;

		this.angles_y = ReadCoord();
		
		this.cq_capdistance = ReadLong();

		setmodel(this, MDL_CQ_STAND);
		setsize(this, CP_MIN, CP_MAX);
		setpredraw(this, conquest_controlpoint_predraw);
		this.draw2d = conquest_controlpoint_draw2d;
		if(is_new) IL_PUSH(g_drawables_2d, this);
		this.cq_rate = 0.2;

		this.teamradar_icon = RADARICON_CONTROLPOINT.m_radaricon;
		if(is_new)
			IL_PUSH(g_radaricons, this);

		if(!this.enemy)
			this.enemy = spawn();

		setmodel(this.enemy, MDL_CQ_FLAG);
		this.enemy.drawmask = MASK_NORMAL;
		this.enemy.scale = 1.5;
		this.entremove = conquest_controlpoint_remove;
	}

	if(sf & CQSF_STATE)
	{
		this.cq_status = ReadByte();
	}

	if(sf & CQSF_TEAM)
	{
		this.team = ReadByte();
		this.teamradar_color = Team_ColorRGB(this.team - 1);

		if(this.cq_status == CP_CAPTURED)
			this.enemy.colormap = this.colormap = 1024 + (this.team - 1) * 17;
		else
			this.enemy.colormap = this.colormap = 1024 * 17;
	}

	if(sf & CQSF_HEALTH)
	{
		float newhealth = ReadByte();
		if(newhealth != 0) { newhealth /= 255; }
		SetResourceAmountExplicit(this, RESOURCE_HEALTH, newhealth);
		this.cq_rate = ReadLong() / 100 * 0.2;
		this.teamradar_color = Team_ColorRGB(this.team - 1) * GetResourceAmount(this, RESOURCE_HEALTH) + '1 1 1' * (1-GetResourceAmount(this, RESOURCE_HEALTH));
	}

	if(sf & CQSF_NAME)
	{
		if(this.netname)
			strunzone(this.netname);

		this.netname = strzone(ReadString());
	}

	return true;
}

#endif
