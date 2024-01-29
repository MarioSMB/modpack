#include "waypointsprites.qh"

REGISTER_NET_LINKED(waypointsprites)

#ifdef SVQC
bool WaypointSprite_SendEntity(entity this, entity to, float sendflags)
{
    WriteHeader(MSG_ENTITY, waypointsprites);

    sendflags = sendflags & 0x7F;

    if (this.max_health || (this.pain_finished && (time < this.pain_finished + 0.25)))
        sendflags |= 0x80;

    int hide_flags = 0;
    if(this.currentammo == 1) hide_flags |= 1; // hideable
    else if(this.currentammo == 2) hide_flags |= 2; // radar only
    if(this.exteriormodeltoclient == to) hide_flags |= 2; // my own

    WriteByte(MSG_ENTITY, sendflags);
    WriteShort(MSG_ENTITY, this.wp_extra);
    WriteByte(MSG_ENTITY, this.wp_extra2);

    if (sendflags & 0x80)
    {
        if (this.max_health)
        {
            WriteByte(MSG_ENTITY, (this.health / this.max_health) * 191.0);
        }
        else
        {
            float dt = this.pain_finished - time;
            dt = bound(0, dt * 32, 16383);
            WriteByte(MSG_ENTITY, (dt & 0xFF00) / 256 + 192);
            WriteByte(MSG_ENTITY, (dt & 0x00FF));
        }
    }

    if (sendflags & 64)
    {
        WriteVector(MSG_ENTITY, this.origin);
    }

    if (sendflags & 1)
    {
        WriteByte(MSG_ENTITY, this.rule);
    }

    if (sendflags & 2)
        WriteString(MSG_ENTITY, this.model1);

    if (sendflags & 4)
        WriteString(MSG_ENTITY, this.model2);

    if (sendflags & 8)
        WriteString(MSG_ENTITY, this.model3);

    if (sendflags & 16)
    {
        WriteCoord(MSG_ENTITY, this.fade_time);
        WriteCoord(MSG_ENTITY, this.teleport_time);
        WriteShort(MSG_ENTITY, bound(0, this.fade_rate, 32767)); // maxdist
        WriteByte(MSG_ENTITY, hide_flags);
    }

    if (sendflags & 32)
    {
        if (WaypointSprite_isteammate(this.owner, WaypointSprite_getviewentity(to)))
        {
            float dt = bound(0, (this.waypointsprite_helpmetime - time) / 0.1, 255);
            WriteByte(MSG_ENTITY, dt);
        }
        else
            WriteByte(MSG_ENTITY, 0);
    }

    return true;
}
#endif

#ifdef CSQC
void Ent_WaypointSprite(entity this, bool isnew);
NET_HANDLE(waypointsprites, bool isnew) {
    Ent_WaypointSprite(this, isnew);
    return true;
}

void Ent_RemoveWaypointSprite(entity this)
{
    strfree(this.netname);
    strfree(this.netname2);
    strfree(this.netname3);
}

void Ent_WaypointSprite(entity this, bool isnew)
{
    int sendflags = ReadByte();
    this.wp_extra = ReadShort();
    this.wp_extra2 = ReadByte();

    if (!this.spawntime)
        this.spawntime = time;

    this.draw2d = Draw_WaypointSprite;
    if (isnew) {
		IL_PUSH(g_drawables_2d, this);
    }

    InterpolateOrigin_Undo(this);
    this.iflags |= IFLAG_ORIGIN;

    if (sendflags & 0x80)
    {
        int t = ReadByte();
        if (t < 192)
        {
            this.health = t / 191.0;
            this.build_finished = 0;
        }
        else
        {
            t = (t - 192) * 256 + ReadByte();
            this.build_started = servertime;
            if (this.build_finished)
                this.build_starthealth = bound(0, this.health, 1);
            else
                this.build_starthealth = 0;
            this.build_finished = servertime + t / 32;
        }
    }
    else
    {
        this.health = -1;
        this.build_finished = 0;
    }

    if (sendflags & 64)
    {
        // unfortunately, this needs to be exact (for the 3D display)
        this.origin = ReadVector();
        setorigin(this, this.origin);
    }

    if (sendflags & 1)
    {
        this.rule = ReadByte();
    }

    if (sendflags & 2)
    {
        strcpy(this.netname, ReadString());
    }

    if (sendflags & 4)
    {
        strcpy(this.netname2, ReadString());
    }

    if (sendflags & 8)
    {
        strcpy(this.netname3, ReadString());
    }

    if (sendflags & 16)
    {
        this.lifetime = ReadCoord();
        this.fadetime = ReadCoord();
        this.maxdistance = ReadShort();
        this.hideflags = ReadByte();
    }

    if (sendflags & 32)
    {
        this.helpme = ReadByte() * 0.1;
        if (this.helpme > 0)
            this.helpme += servertime;
    }

    InterpolateOrigin_Note(this);

    this.entremove = Ent_RemoveWaypointSprite;
}
#endif

#ifdef CSQC
float spritelookupblinkvalue(entity this, string s)
{
    return 1;
}

vector spritelookupcolor(entity this, string s, vector def)
{
    return def;
}

string spritelookuptext(entity this, string s)
{
	if(autocvar_g_waypointsprite_spam && waypointsprite_count >= autocvar_g_waypointsprite_spam)
		return "Spam"; // no need to translate this debug string
    if (s == WP_Weapon.netname) return REGISTRY_GET(Weapons, this.wp_extra).m_name;
    if (s == WP_Exit.netname) return strcat(WP_Exit.m_name, ((this.wp_extra) ? sprintf(" (%d/%d)", this.wp_extra, this.wp_extra2) : ""));
    if (s == WP_Entity.netname) return strcat("Entity ", ftos(this.wp_extra));

    // need to loop, as our netname could be one of three
    FOREACH(Waypoints, it.netname == s, {
        return it.m_name;
    });

    return s;
}

string spritelookupicon(entity this, string s)
{
    if (s == WP_Weapon.netname) return REGISTRY_GET(Weapons, this.wp_extra).model2;

    // need to loop, as our netname could be one of three
    FOREACH(Waypoints, it.netname == s, {
        return it.m_icon;
    });

    return s;
}
#endif

#ifdef CSQC
void drawrotpic(vector org, float rot, string pic, vector sz, vector hotspot, vector rgb, float a, float f)
{
    vector v1, v2, v3, v4;

    hotspot = -1 * hotspot;

    // hotspot-relative coordinates of the corners
    v1 = hotspot;
    v2 = hotspot + '1 0 0' * sz.x;
    v3 = hotspot + '1 0 0' * sz.x + '0 1 0' * sz.y;
    v4 = hotspot                  + '0 1 0' * sz.y;

    // rotate them, and make them absolute
    rot = -rot; // rotate by the opposite angle, as our coordinate system is reversed
    v1 = Rotate(v1, rot) + org;
    v2 = Rotate(v2, rot) + org;
    v3 = Rotate(v3, rot) + org;
    v4 = Rotate(v4, rot) + org;

    // draw them
    R_BeginPolygon(pic, f, true);
    R_PolygonVertex(v1, '0 0 0', rgb, a);
    R_PolygonVertex(v2, '1 0 0', rgb, a);
    R_PolygonVertex(v3, '1 1 0', rgb, a);
    R_PolygonVertex(v4, '0 1 0', rgb, a);
    R_EndPolygon();
}

void drawquad(vector o, vector ri, vector up, string pic, vector rgb, float a, float f)
{
    R_BeginPolygon(pic, f, true);
    R_PolygonVertex(o, '0 0 0', rgb, a);
    R_PolygonVertex(o + ri, '1 0 0', rgb, a);
    R_PolygonVertex(o + up + ri, '1 1 0', rgb, a);
    R_PolygonVertex(o + up, '0 1 0', rgb, a);
    R_EndPolygon();
}

void drawhealthbar(vector org, float rot, float h, vector sz, vector hotspot, float width, float theheight, float margin, float border, float align, vector rgb, float a, vector hrgb, float ha, float f)
{
    vector o, ri, up;
    float owidth; // outer width

    hotspot = -1 * hotspot;

    // hotspot-relative coordinates of the healthbar corners
    o = hotspot;
    ri = '1 0 0';
    up = '0 1 0';

    rot = -rot; // rotate by the opposite angle, as our coordinate system is reversed
    o = Rotate(o, rot) + org;
    ri = Rotate(ri, rot);
    up = Rotate(up, rot);

    owidth = width + 2 * border;
    o = o - up * (margin + border + theheight) + ri * (sz.x - owidth) * 0.5;

    drawquad(o - up * border,                               ri * owidth,    up * border,    "", rgb,  a,  f);
    drawquad(o + up * theheight,                            ri * owidth,    up * border,    "", rgb,  a,  f);
    drawquad(o,                                             ri * border,    up * theheight, "", rgb,  a,  f);
    drawquad(o + ri * (owidth - border),                    ri * border,    up * theheight, "", rgb,  a,  f);
    drawquad(o + ri * (border + align * ((1 - h) * width)), ri * width * h, up * theheight, "", hrgb, ha, f);
}

// returns location of sprite text
vector drawspritearrow(vector o, float ang, vector rgb, float a, float t)
{
    float size   = 9.0 * t;
    float border = 1.5 * t;
    float margin = 4.0 * t;

    float borderDiag = border * M_SQRT2;
    vector arrowX  = eX * size;
    vector arrowY  = eY * (size+borderDiag);
    vector borderX = eX * (size+borderDiag);
    vector borderY = eY * (size+borderDiag+border);

    R_BeginPolygon("", DRAWFLAG_NORMAL, true);
    R_PolygonVertex(o,                                  '0 0 0', '0 0 0', a);
    R_PolygonVertex(o + Rotate(arrowY  - borderX, ang), '0 0 0', '0 0 0', a);
    R_PolygonVertex(o + Rotate(borderY - borderX, ang), '0 0 0', '0 0 0', a);
    R_PolygonVertex(o + Rotate(borderY + borderX, ang), '0 0 0', '0 0 0', a);
    R_PolygonVertex(o + Rotate(arrowY  + borderX, ang), '0 0 0', '0 0 0', a);
    R_EndPolygon();

    R_BeginPolygon("", DRAWFLAG_ADDITIVE, true);
    R_PolygonVertex(o + Rotate(eY * borderDiag, ang), '0 0 0', rgb, a);
    R_PolygonVertex(o + Rotate(arrowY - arrowX, ang), '0 0 0', rgb, a);
    R_PolygonVertex(o + Rotate(arrowY + arrowX, ang), '0 0 0', rgb, a);
    R_EndPolygon();

    return o + Rotate(eY * (borderDiag+size+margin), ang);
}

// returns location of sprite healthbar
vector drawsprite_TextOrIcon(bool is_text, vector o, float ang, float minwidth, vector rgb, float a, vector sz, string str)
{
    float algnx, algny;
    float sw, w, h;
    float aspect, sa, ca;

    if (is_text)
        sw = stringwidth(str, false, sz);
    else
        sw = sz.x;

    if (sw > minwidth)
        w = sw;
    else
        w = minwidth;
    h = sz.y;

    // how do corners work?
    aspect = vid_conwidth / vid_conheight;
    sa = sin(ang);
    ca = cos(ang) * aspect;
    if (fabs(sa) > fabs(ca))
    {
        algnx = (sa < 0);
        float f = fabs(sa);
        algny = 0.5 - 0.5 * (f ? (ca / f) : 0);
    }
    else
    {
        float f = fabs(ca);
        algnx = 0.5 - 0.5 * (f ? (sa / f) : 0);
        algny = (ca < 0);
    }

    // align
    o.x -= w * algnx;
    o.y -= h * algny;

    // we want to be onscreen
    if (o.x < 0)
        o.x = 0;
    if (o.y < 0)
        o.y = 0;
    if (o.x > vid_conwidth - w)
        o.x = vid_conwidth - w;
    if (o.y > vid_conheight - h)
        o.y = vid_conheight - h;

    o.x += 0.5 * (w - sw);

    if (is_text)
        drawstring(o, str, sz, rgb, a, DRAWFLAG_NORMAL);
    else
        drawpic(o, str, sz, rgb, a, DRAWFLAG_NORMAL);

    o.x += 0.5 * sw;
    o.y += 0.5 * h;

    return o;
}

vector fixrgbexcess_move(vector rgb, vector src, vector dst)
{
    vector yvec = '0.299 0.587 0.114';
    return rgb + dst * ((src * yvec) / (dst * yvec)) * ((rgb - '1 1 1') * src);
}

vector fixrgbexcess(vector rgb)
{
    if (rgb.x > 1) {
        rgb = fixrgbexcess_move(rgb, '1 0 0', '0 1 1');
        if (rgb.y > 1) {
            rgb = fixrgbexcess_move(rgb, '0 1 0', '0 0 1');
            if (rgb.z > 1) rgb.z = 1;
        } else if (rgb.z > 1) {
            rgb = fixrgbexcess_move(rgb, '0 0 1', '0 1 0');
            if (rgb.y > 1) rgb.y = 1;
        }
    } else if (rgb.y > 1) {
        rgb = fixrgbexcess_move(rgb, '0 1 0', '1 0 1');
        if (rgb.x > 1) {
            rgb = fixrgbexcess_move(rgb, '1 0 0', '0 0 1');
            if (rgb.z > 1) rgb.z = 1;
        } else if (rgb.z > 1) {
            rgb = fixrgbexcess_move(rgb, '0 0 1', '1 0 0');
            if (rgb.x > 1) rgb.x = 1;
        }
    } else if (rgb.z > 1) {
        rgb = fixrgbexcess_move(rgb, '0 0 1', '1 1 0');
        if (rgb.x > 1) {
            rgb = fixrgbexcess_move(rgb, '1 0 0', '0 1 0');
            if (rgb.y > 1) rgb.y = 1;
        } else if (rgb.y > 1) {
            rgb = fixrgbexcess_move(rgb, '0 1 0', '1 0 0');
            if (rgb.x > 1) rgb.x = 1;
        }
    }
    return rgb;
}

void Draw_WaypointSprite(entity this)
{
    if (this.lifetime > 0)
        this.alpha = (bound(0, (this.fadetime - time) / this.lifetime, 1) ** waypointsprite_timealphaexponent);
    else
        this.alpha = 1;

    if (this.hideflags & 2)
        return; // radar only

    if (autocvar_cl_hidewaypoints >= 2)
        return;

    if ((this.hideflags & 1) && autocvar_cl_hidewaypoints)
        return; // fixed waypoint

    InterpolateOrigin_Do(this);

    string spriteimage = "";

    // choose the sprite
    switch (this.rule)
    {
        case SPRITERULE_DEFAULT:
            spriteimage = this.netname;
            break;
        default:
            error("Invalid waypointsprite rule!");
            break;
    }

    if (spriteimage == "")
        return;

    ++waypointsprite_newcount;

    float dist = vlen(this.origin - view_origin);
    float a = this.alpha * 1;

    if(this.maxdistance > 0)
    {
        // restrict maximum normal distance to the waypoint's maximum distance to prevent exploiting cvars
        float maxnormdistance = bound(0, waypointsprite_normdistance, this.maxdistance - 1);
        a *= (bound(0, (this.maxdistance - dist) / (this.maxdistance - maxnormdistance), 1) ** waypointsprite_distancealphaexponent);
    }

    vector rgb = spritelookupcolor(this, spriteimage, '1 0 0');
    if (rgb == '0 0 0')
    {
        LOG_INFOF("WARNING: sprite of name %s has no color, using pink so you notice it", spriteimage);
    }

    float health_val = this.health;
    float blink_time = (health_val >= 0) ? (health_val * 10) : time;
    if (blink_time - floor(blink_time) > 0.5)
    {
        if (this.helpme && time < this.helpme)
            a *= SPRITE_HELPME_BLINK;
        else if (!this.lifetime) // fading out waypoints don't blink
            a *= spritelookupblinkvalue(this, spriteimage);
    }

    if (a > 1)
    {
        rgb *= a;
        a = 1;
    }

    if (a <= 0.003)
        return;

    rgb = fixrgbexcess(rgb);

    vector o;
    float ang;

    o = project_3d_to_2d(this.origin);
    if (o.z < 0
    || o.x < (vid_conwidth * waypointsprite_edgeoffset_left)
    || o.y < (vid_conheight * waypointsprite_edgeoffset_top)
    || o.x > (vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right))
    || o.y > (vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)))
    {
        // scale it to be just in view
        vector d;

        d = o - '0.5 0 0' * vid_conwidth - '0 0.5 0' * vid_conheight;
        ang = atan2(-d.x, -d.y);
        if (o.z < 0)
            ang += M_PI;

		float f1 = d.x / vid_conwidth;
		float f2 = d.y / vid_conheight;
		if (f1 == 0) { f1 = 0.000001; }
		if (f2 == 0) { f2 = 0.000001; }

        if (max(f1, -f1) > max(f2, -f2)) {
            if (d.z * f1 > 0) {
                // RIGHT edge
                d = d * ((0.5 - waypointsprite_edgeoffset_right) / f1);
            } else {
                // LEFT edge
                d = d * (-(0.5 - waypointsprite_edgeoffset_left) / f1);
            }
        } else {
            if (d.z * f2 > 0) {
                // BOTTOM edge
                d = d * ((0.5 - waypointsprite_edgeoffset_bottom) / f2);
            } else {
                // TOP edge
                d = d * (-(0.5 - waypointsprite_edgeoffset_top) / f2);
            }
        }

        o = d + '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
    }
    else
    {
#if 1
        ang = M_PI;
#else
        vector d;
        d = o - '0.5 0 0' * vid_conwidth - '0 0.5 0' * vid_conheight;
        ang = atan2(-d.x, -d.y);
#endif
    }
    o.z = 0;

    float edgedistance_min = min((o.y - (vid_conheight * waypointsprite_edgeoffset_top)),
    (o.x - (vid_conwidth * waypointsprite_edgeoffset_left)),
    (vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right)) - o.x,
    (vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)) - o.y);

    float crosshairdistance = sqrt( ((o.x - vid_conwidth/2) ** 2) + ((o.y - vid_conheight/2) ** 2) );

    float t = waypointsprite_scale;
    a *= waypointsprite_alpha;

    {
        a = a * (1 - (1 - waypointsprite_distancefadealpha) * (bound(0, dist/waypointsprite_distancefadedistance, 1)));
        t = t * (1 - (1 - waypointsprite_distancefadescale) * (bound(0, dist/waypointsprite_distancefadedistance, 1)));
    }
    if (edgedistance_min < waypointsprite_edgefadedistance) {
        a = a * (1 - (1 - waypointsprite_edgefadealpha) * (1 - bound(0, edgedistance_min/waypointsprite_edgefadedistance, 1)));
        t = t * (1 - (1 - waypointsprite_edgefadescale) * (1 - bound(0, edgedistance_min/waypointsprite_edgefadedistance, 1)));
    }
    if (crosshairdistance < waypointsprite_crosshairfadedistance) {
        a = a * (1 - (1 - waypointsprite_crosshairfadealpha) * (1 - bound(0, crosshairdistance/waypointsprite_crosshairfadedistance, 1)));
        t = t * (1 - (1 - waypointsprite_crosshairfadescale) * (1 - bound(0, crosshairdistance/waypointsprite_crosshairfadedistance, 1)));
    }

    if (this.build_finished)
    {
        if (time < this.build_finished + 0.25)
        {
            if (time < this.build_started)
                this.health = this.build_starthealth;
            else if (time < this.build_finished)
                this.health = (time - this.build_started) / (this.build_finished - this.build_started) * (1 - this.build_starthealth) + this.build_starthealth;
            else
                this.health = 1;
        }
        else
            this.health = -1;
    }

    o = drawspritearrow(o, ang, rgb, a, SPRITE_ARROW_SCALE * t);

	string pic = "";
	bool is_text = true;
	if (!autocvar_g_waypointsprite_text)
	{
		string spr_icon = spritelookupicon(this, spriteimage);
		pic = spr_icon;
		bool icon_found = !(!spr_icon || spr_icon == "");
		if (icon_found) // it's valid, but let's make sure it exists!
		{
			pic = strcat("gfx/hud/old", "/", spr_icon);
			if(precache_pic(pic) == "")
			{
				pic = strcat("gfx/hud/default/", spr_icon);
				if(!precache_pic(pic))
					icon_found = false;
			}
		}
		if (icon_found)
			is_text = false;
	}

	vector sz;
	vector col = rgb;
    string txt = string_null; // it will contain either the text or the icon path
    if (is_text)
    {
        txt = spritelookuptext(this, spriteimage);
        if (this.helpme && time < this.helpme)
            txt = sprintf(_("%s needing help!"), txt);
        if (autocvar_g_waypointsprite_uppercase)
            txt = strtoupper(txt);
        sz = waypointsprite_fontsize * '1 1 0';
    }
    else
    {
        txt = pic; // icon path
        if (autocvar_g_waypointsprite_iconcolor == 0)
        	col = '1 1 1';
        else if (autocvar_g_waypointsprite_iconcolor > 0 && autocvar_g_waypointsprite_iconcolor != 1)
        {
            col = rgb_to_hsv(col);
            col.y *= autocvar_g_waypointsprite_iconcolor; // scale saturation
            col = hsv_to_rgb(col);
        }
        sz = autocvar_g_waypointsprite_iconsize * '1 1 0';
    }

    float oldfont = drawfont;
    drawfont = 8;
    if (this.health >= 0)
    {
        float align = 0, marg;
        if (this.build_finished)
            align = 0.5;
        else
            align = 0;
        if (cos(ang) > 0)
            marg = -(SPRITE_HEALTHBAR_MARGIN + SPRITE_HEALTHBAR_HEIGHT + 2 * SPRITE_HEALTHBAR_BORDER) * t - 0.5 * sz.y;
        else
            marg = SPRITE_HEALTHBAR_MARGIN * t + 0.5 * sz.y;

        float minwidth = (SPRITE_HEALTHBAR_WIDTH + 2 * SPRITE_HEALTHBAR_BORDER) * t;
        o = drawsprite_TextOrIcon(is_text, o, ang, minwidth, col, a, sz, txt);
        drawhealthbar(
                o,
                0,
                this.health,
                '0 0 0',
                '0 0 0',
                SPRITE_HEALTHBAR_WIDTH * t,
                SPRITE_HEALTHBAR_HEIGHT * t,
                marg,
                SPRITE_HEALTHBAR_BORDER * t,
                align,
                rgb,
                a * SPRITE_HEALTHBAR_BORDERALPHA,
                rgb,
                a * SPRITE_HEALTHBAR_HEALTHALPHA,
                DRAWFLAG_NORMAL
                 );
    }
    else
    {
        drawsprite_TextOrIcon(is_text, o, ang, 0, col, a, sz, txt);
    }

    drawfont = oldfont;
}

void WaypointSprite_Load_Frames(string ext)
{
    int dh = search_begin(strcat("models/sprites/*_frame*", ext), false, false);
    if (dh < 0) return;
    int ext_len = strlen(ext);
    int n = search_getsize(dh);
    for (int i = 0; i < n; ++i)
    {
        string s = search_getfilename(dh, i);
        s = substring(s, 15, strlen(s) - 15 - ext_len); // strip models/sprites/ and extension

        int o = strstrofs(s, "_frame", 0);
        string sname = strcat("/spriteframes/", substring(s, 0, o));
        string sframes = substring(s, o + 6, strlen(s) - o - 6);
        int f = stof(sframes) + 1;
        db_put(tempdb, sname, ftos(max(f, stof(db_get(tempdb, sname)))));
    }
    search_end(dh);
}

void WaypointSprite_Load();
STATIC_INIT(WaypointSprite_Load) {
    WaypointSprite_Load();
    WaypointSprite_Load_Frames(".tga");
    WaypointSprite_Load_Frames(".jpg");
}
void WaypointSprite_Load()
{
    vector mi_scale = world.maxs - world.mins;
    waypointsprite_fadedistance = vlen(mi_scale);
    waypointsprite_normdistance = autocvar_g_waypointsprite_normdistance;
    waypointsprite_minscale = autocvar_g_waypointsprite_minscale;
    waypointsprite_minalpha = autocvar_g_waypointsprite_minalpha;
    waypointsprite_distancealphaexponent = autocvar_g_waypointsprite_distancealphaexponent;
    waypointsprite_timealphaexponent = autocvar_g_waypointsprite_timealphaexponent;
    waypointsprite_scale = autocvar_g_waypointsprite_scale;
    waypointsprite_fontsize = autocvar_g_waypointsprite_fontsize;
    waypointsprite_edgefadealpha = autocvar_g_waypointsprite_edgefadealpha;
    waypointsprite_edgefadescale = autocvar_g_waypointsprite_edgefadescale;
    waypointsprite_edgefadedistance = autocvar_g_waypointsprite_edgefadedistance;
    waypointsprite_edgeoffset_bottom = autocvar_g_waypointsprite_edgeoffset_bottom;
    waypointsprite_edgeoffset_left = autocvar_g_waypointsprite_edgeoffset_left;
    waypointsprite_edgeoffset_right = autocvar_g_waypointsprite_edgeoffset_right;
    waypointsprite_edgeoffset_top = autocvar_g_waypointsprite_edgeoffset_top;
    waypointsprite_crosshairfadealpha = autocvar_g_waypointsprite_crosshairfadealpha;
    waypointsprite_crosshairfadescale = autocvar_g_waypointsprite_crosshairfadescale;
    waypointsprite_crosshairfadedistance = autocvar_g_waypointsprite_crosshairfadedistance;
    waypointsprite_distancefadealpha = autocvar_g_waypointsprite_distancefadealpha;
    waypointsprite_distancefadescale = autocvar_g_waypointsprite_distancefadescale;
    waypointsprite_distancefadedistance = waypointsprite_fadedistance * autocvar_g_waypointsprite_distancefadedistancemultiplier;
    waypointsprite_alpha = autocvar_g_waypointsprite_alpha * (1 - autocvar__menu_alpha);

    waypointsprite_count = waypointsprite_newcount;
    waypointsprite_newcount = 0;
}
#endif

#ifdef SVQC
void WaypointSprite_UpdateSprites(entity e, entity _m1, entity _m2, entity _m3)
{
    string m1 = _m1.netname;
    string m2 = _m2.netname;
    string m3 = _m3.netname;
    if (m1 != e.model1)
    {
        e.model1 = m1;
        e.SendFlags |= 2;
    }
    if (m2 != e.model2)
    {
        e.model2 = m2;
        e.SendFlags |= 4;
    }
    if (m3 != e.model3)
    {
        e.model3 = m3;
        e.SendFlags |= 8;
    }
}

void WaypointSprite_UpdateHealth(entity e, float f)
{
    f = bound(0, f, e.max_health);
    float step = e.max_health / 40;
    if ((floor(f / step) != floor(e.health / step)) || e.pain_finished)
    {
        e.health = f;
        e.pain_finished = 0;
        e.SendFlags |= 0x80;
    }
}

void WaypointSprite_UpdateMaxHealth(entity e, float f)
{
    if (f != e.max_health || e.pain_finished)
    {
        e.max_health = f;
        e.pain_finished = 0;
        e.SendFlags |= 0x80;
    }
}

void WaypointSprite_UpdateBuildFinished(entity e, float f)
{
    if (f != e.pain_finished || e.max_health)
    {
        e.max_health = 0;
        e.pain_finished = f;
        e.SendFlags |= 0x80;
    }
}

void WaypointSprite_UpdateOrigin(entity e, vector o)
{
    if (o != e.origin)
    {
        setorigin(e, o);
        e.SendFlags |= 64;
    }
}

void WaypointSprite_UpdateRule(entity e, float t, float r)
{
    // no check, as this is never called without doing an actual change (usually only once)
    e.rule = r;
    e.SendFlags |= 1;
}

void WaypointSprite_Ping(entity e)
{
    // anti spam
    if (time < e.waypointsprite_pingtime) return;
    e.waypointsprite_pingtime = time + 0.3;
    // ALWAYS sends (this causes a radar circle), thus no check
    e.cnt |= BIT(7);
    e.SendFlags |= 32;
}

void WaypointSprite_HelpMePing(entity e)
{
    WaypointSprite_Ping(e);
    e.waypointsprite_helpmetime = time + waypointsprite_deployed_lifetime;
    e.SendFlags |= 32;
}

void WaypointSprite_FadeOutIn(entity e, float t)
{
    if (!e.fade_time)
    {
        e.fade_time = t;
        e.teleport_time = time + t;
    }
    else if (t < (e.teleport_time - time))
    {
        // accelerate the waypoint's dying
        // ensure:
        //   (e.teleport_time - time) / wp.fade_time stays
        //   e.teleport_time = time + fadetime
        float current_fadetime = e.teleport_time - time;
        e.teleport_time = time + t;
        if (e.fade_time < 0)
        	e.fade_time = -e.fade_time;
        e.fade_time = e.fade_time * t / current_fadetime;
    }

    e.SendFlags |= 16;
}

void WaypointSprite_Init()
{
    waypointsprite_limitedrange = autocvar_sv_waypointsprite_limitedrange;
    waypointsprite_deployed_lifetime = autocvar_sv_waypointsprite_deployed_lifetime;
    waypointsprite_deadlifetime = autocvar_sv_waypointsprite_deadlifetime;
}

void WaypointSprite_Kill(entity wp)
{
    if (!wp) return;
    if (wp.owner) wp.owner.(wp.owned_by_field) = NULL;
    delete(wp);
}

void WaypointSprite_Disown(entity wp, float fadetime)
{
    if (!wp) return;
    if (wp.classname != "sprite_waypoint")
    {
        backtrace("Trying to disown a non-waypointsprite");
        return;
    }
    if (wp.owner)
    {
        if (wp.exteriormodeltoclient == wp.owner)
            wp.exteriormodeltoclient = NULL;
        wp.owner.(wp.owned_by_field) = NULL;
        wp.owner = NULL;

        WaypointSprite_FadeOutIn(wp, fadetime);
    }
}

void WaypointSprite_Think(entity this)
{
    bool doremove = false;

    if (this.fade_time && time >= this.teleport_time)
    {
        doremove = true;
    }

    if (this.exteriormodeltoclient)
        WaypointSprite_UpdateOrigin(this, this.exteriormodeltoclient.origin + this.view_ofs);

    if (doremove)
        WaypointSprite_Kill(this);
    else
        this.nextthink = time; // WHY?!?
}

bool WaypointSprite_visible_for_player(entity this, entity player, entity view)
{
    // personal waypoints
    if (this.enemy && this.enemy != view)
        return false;

    // team waypoints
    if (this.rule == SPRITERULE_DEFAULT)
    {
        if (!IS_PLAYER(view))
            return false;
    }

    return true;
}

entity WaypointSprite_getviewentity(entity e)
{
    /* TODO idea (check this breaks nothing)
    else if (e.classname == "observer")
        e = NULL;
    */
    return e;
}

float WaypointSprite_isteammate(entity e, entity e2)
{
    if (coop)
        return IS_PLAYER(e2);
    return e2 == e;
}

bool WaypointSprite_Customize(entity this, entity client)
{
    // this is not in SendEntity because it shall run every frame, not just every update

    // make spectators see what the player would see
    entity e = WaypointSprite_getviewentity(client);

    return this.waypointsprite_visible_for_player(this, client, e);
}

bool WaypointSprite_SendEntity(entity this, entity to, float sendflags);

void WaypointSprite_Reset(entity this)
{
    // if a WP wants to time out, let it time out immediately; other WPs ought to be reset/killed by their owners

    if (this.fade_time)
        WaypointSprite_Kill(this);
}

entity WaypointSprite_Spawn(
    entity spr, // sprite
    float _lifetime, float maxdistance, // lifetime, max distance
    entity ref, vector ofs, // position
    entity showto, float t, // show to whom? Use a flag to indicate a team
    entity own, .entity ownfield, // remove when own gets killed
    float hideable, // true when it should be controlled by cl_hidewaypoints
    entity icon // initial icon
)
{
    entity wp = new(sprite_waypoint);
    wp.fade_time = _lifetime; // if negative tells client not to fade it out
    if(_lifetime < 0)
    	_lifetime = -_lifetime;
    wp.teleport_time = time + _lifetime;
    wp.exteriormodeltoclient = ref;
    if (ref)
    {
        wp.view_ofs = ofs;
        setorigin(wp, ref.origin + ofs);
    }
    else
        setorigin(wp, ofs);
    wp.enemy = showto;
    wp.owner = own;
    wp.currentammo = hideable;
    if (own)
    {
        if (own.(ownfield))
            delete(own.(ownfield));
        own.(ownfield) = wp;
        wp.owned_by_field = ownfield;
    }
    wp.fade_rate = maxdistance;
    setthink(wp, WaypointSprite_Think);
    wp.nextthink = time;
    wp.model1 = spr.netname;
    setcefc(wp, WaypointSprite_Customize);
    wp.waypointsprite_visible_for_player = WaypointSprite_visible_for_player;
    wp.cnt = icon.m_id;
    wp.colormod = spr.m_color;
    Net_LinkEntity(wp, false, 0, WaypointSprite_SendEntity);
    return wp;
}

entity WaypointSprite_SpawnFixed(
    entity spr,
    vector ofs,
    entity own,
    .entity ownfield,
    entity icon // initial icon
)
{
    return WaypointSprite_Spawn(spr, 0, 0, NULL, ofs, NULL, 0, own, ownfield, true, icon);
}

entity WaypointSprite_DeployFixed(
    entity spr,
    bool limited_range,
    entity player,
    vector ofs,
    entity icon // initial icon
)
{
    float t;
    t = 0;
    float maxdistance;
    if (limited_range)
        maxdistance = waypointsprite_limitedrange;
    else
        maxdistance = 0;
    return WaypointSprite_Spawn(spr, waypointsprite_deployed_lifetime, maxdistance, NULL, ofs, NULL, t, player, waypointsprite_deployed_fixed, false, icon);
}

entity WaypointSprite_DeployPersonal(
    entity spr,
    entity player,
    vector ofs,
    entity icon // initial icon
)
{
    return WaypointSprite_Spawn(spr, 0, 0, NULL, ofs, NULL, 0, player, waypointsprite_deployed_personal, false, icon);
}

entity WaypointSprite_Attach(
    entity spr,
    entity player,
    bool limited_range,
    entity icon // initial icon
)
{
    float t;
    if (player.waypointsprite_attachedforcarrier)
        return NULL; // can't attach to FC
    t = 0;
    float maxdistance;
    if (limited_range)
        maxdistance = waypointsprite_limitedrange;
    else
        maxdistance = 0;
    return WaypointSprite_Spawn(spr, waypointsprite_deployed_lifetime, maxdistance, player, '0 0 64', NULL, t, player, waypointsprite_attached, false, icon);
}

entity WaypointSprite_AttachCarrier(
    entity spr,
    entity carrier,
    entity icon // initial icon and color
)
{
    WaypointSprite_Kill(carrier.waypointsprite_attached); // FC overrides attached
    entity e = WaypointSprite_Spawn(spr, 0, 0, carrier, '0 0 64', NULL, 0, carrier, waypointsprite_attachedforcarrier, false, icon);
    if (carrier.health)
    {
        WaypointSprite_UpdateMaxHealth(e, carrier.max_health);
        WaypointSprite_UpdateHealth(e, carrier.health);
    }
    return e;
}

void WaypointSprite_DetachCarrier(entity carrier)
{
    WaypointSprite_Disown(carrier.waypointsprite_attachedforcarrier, waypointsprite_deadlifetime);
}

void WaypointSprite_ClearPersonal(entity this)
{
    WaypointSprite_Kill(this.waypointsprite_deployed_personal);
}

void WaypointSprite_ClearOwned(entity this)
{
    WaypointSprite_Kill(this.waypointsprite_deployed_fixed);
    WaypointSprite_Kill(this.waypointsprite_deployed_personal);
    WaypointSprite_Kill(this.waypointsprite_attached);
}

void WaypointSprite_PlayerDead(entity this)
{
    WaypointSprite_Disown(this.waypointsprite_attached, waypointsprite_deadlifetime);
    WaypointSprite_DetachCarrier(this);
}

void WaypointSprite_PlayerGone(entity this)
{
    WaypointSprite_Disown(this.waypointsprite_deployed_fixed, waypointsprite_deadlifetime);
    WaypointSprite_Kill(this.waypointsprite_deployed_personal);
    WaypointSprite_Disown(this.waypointsprite_attached, waypointsprite_deadlifetime);
    WaypointSprite_DetachCarrier(this);
}
#endif
