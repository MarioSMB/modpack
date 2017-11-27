// lib
// TOOD: get this stuff in master!
float lerpratio(float f0, float f1, float ratio) { return f0 * (1 - ratio) + f1 * ratio; }
vector lerpvratio(vector f0, vector f1, float ratio) { return f0 * (1 - ratio) + f1 * ratio; }

vector lerpv3ratio(vector f0, vector f1, vector f2, float ratio)
{
	int mid = 0.5;
	return ratio < mid ? lerpvratio(f0, f1, ratio / mid) : ratio > mid ? lerpvratio(f1, f2, (ratio - mid) / mid) : f1;
}

float lerp3ratio(float f0, float f1, float f2, float ratio)
{
	int mid = 0.5;
	return ratio < mid ? lerpratio(f0, f1, ratio / mid) : ratio > mid ? lerpratio(f1, f2, (ratio - mid) / mid) : f1;
}

AUTOCVAR(cl_polytrails, bool, false, "");
AUTOCVAR(cl_polytrail_segmentsize, float, 10, "");
AUTOCVAR(cl_polytrail_lifetime, float, .2, "");
AUTOCVAR(cl_polytrail_noise, float, 0, "");

CLASS(PolyTrail, Object)
    ATTRIB(PolyTrail, polytrail_follow, entity, NULL);
    ATTRIB(PolyTrail, polytrail_tex, string, string_null);
    /** Lifetime per segment */
    ATTRIB(PolyTrail, polytrail_lifetime, float, autocvar_cl_polytrail_lifetime);
    ATTRIBARRAY(PolyTrail, polytrail_rgb, vector, 3);
    ATTRIBARRAY(PolyTrail, polytrail_alpha, float, 3);
    ATTRIBARRAY(PolyTrail, polytrail_thickness, float, 3);

    /**
     * Increase as necessary if the buffer is overflowing
     * symptom: tail of trail is wrong
     * cause: projectiles are too fast for the segment size
     */
    const int POLYTRAIL_BUFSIZE = 1 << 7;
    /** One or more positional points */
    ATTRIBARRAY(PolyTrail, polytrail_bufpos, vector, POLYTRAIL_BUFSIZE);
    /** Noise for ending position */
    ATTRIBARRAY(PolyTrail, polytrail_bufnoise, vector, POLYTRAIL_BUFSIZE);
    /** Time of input */
    ATTRIBARRAY(PolyTrail, polytrail_buftime, float, POLYTRAIL_BUFSIZE);
    /** Current read index */
    ATTRIB(PolyTrail, polytrail_bufidx, float, -1);
    /** Counts positions stored */
    ATTRIB(PolyTrail, polytrail_cnt, float, 0);
    #define POLYTRAIL_SEEK(_p, _rel) ((POLYTRAIL_BUFSIZE + (_p).polytrail_bufidx + (_rel)) % POLYTRAIL_BUFSIZE)

    void Trail_draw(entity this);
    ATTRIB(PolyTrail, draw, void(entity this), Trail_draw);
    void Trail_draw(entity this) {
        if (wasfreed(this.polytrail_follow))
            this.polytrail_follow = NULL;

        if (!this.polytrail_follow) {
            float when = this.polytrail_buftime[this.polytrail_bufidx];
            if (time - when > this.polytrail_lifetime) {
                delete(this);
                return;
            }
        } else {
            setorigin(this, this.polytrail_follow.origin);
            if (this.polytrail_cnt < 0 || vdist(this.origin - this.polytrail_bufpos[this.polytrail_bufidx], >=, autocvar_cl_polytrail_segmentsize)) {
                int i = POLYTRAIL_SEEK(this, 1);
                this.polytrail_bufpos[i] = this.origin;
                float f = autocvar_cl_polytrail_noise;
                this.polytrail_bufnoise[i] = randompos(f * '-1 -1 -1', f * '1 1 1');
                this.polytrail_buftime[i] = time;
                this.polytrail_bufidx = i;
                this.polytrail_cnt = bound(this.polytrail_cnt, i + 1, POLYTRAIL_BUFSIZE);
            }
        }

        vector from = this.origin;
        int count = this.polytrail_cnt;
        for (int i = 0; i < count; ++i) {
            int idx = POLYTRAIL_SEEK(this, -i);
            float when = this.polytrail_buftime[idx];
            // head: 0, tail: 1
            float rtime = (time - when) / this.polytrail_lifetime;
            if (rtime >= 1) {
                break;
            }
            vector to = this.polytrail_bufpos[idx];
            to += lerpvratio('0 0 0', this.polytrail_bufnoise[idx], rtime);
            vector rgb = lerpv3ratio(this.polytrail_rgb[0], this.polytrail_rgb[1], this.polytrail_rgb[2], rtime);
            float a = lerp3ratio(this.polytrail_alpha[0], this.polytrail_thickness[1], this.polytrail_alpha[2], rtime);
            int thickness = lerp3ratio(this.polytrail_thickness[0], this.polytrail_thickness[1], this.polytrail_thickness[2], rtime);
            vector thickdir = normalize(cross(normalize(to - from), view_origin - from)) * (thickness / 2);
            vector A = from + thickdir;
            vector B = from - thickdir;
            vector C = to + thickdir;
            vector D = to - thickdir;
            R_BeginPolygon(this.polytrail_tex, DRAWFLAG_SCREEN);
            R_PolygonVertex(B, '0 0 0', rgb, a);
            R_PolygonVertex(A, '0 1 0', rgb, a);
            R_PolygonVertex(C, '1 1 0', rgb, a);
            R_PolygonVertex(D, '1 0 0', rgb, a);
            R_EndPolygon();
            from = to;
        }
    }
    CONSTRUCTOR(PolyTrail, entity _follow) {
        CONSTRUCT(PolyTrail);
        this.polytrail_follow = _follow;
    }
ENDCLASS(PolyTrail)

REGISTER_MUTATOR(polytrails, true);

MUTATOR_HOOKFUNCTION(polytrails, EditProjectile) {
    return = false;
    if (!autocvar_cl_polytrails || warpzone_warpzones_exist) return;
    entity proj = M_ARGV(0, entity);
    PolyTrail t = NEW(PolyTrail, proj);
    t.polytrail_tex = "gfx/trails/plain.tga";
    t.polytrail_rgb[0] = '1 0 0';
    t.polytrail_rgb[1] = '0 1 0';
    t.polytrail_rgb[2] = '0 0 1';
    t.polytrail_alpha[0] = 1;
    t.polytrail_alpha[1] = 0.5;
    t.polytrail_alpha[2] = 0;
    t.polytrail_thickness[0] = 10;
    t.polytrail_thickness[1] = 5;
    t.polytrail_thickness[2] = 0;

    IL_PUSH(g_drawables, t);
}

AUTOCVAR(cl_glowtrails, int, 1, "Enable glowy trails (if set to 1, only in CTS, if higher any mode)");
AUTOCVAR(cl_glowtrails_usealpha, bool, true, "Account for player's transparency");
AUTOCVAR(cl_glowtrails_scale, float, 0.07, "Speed scale for player's velocity (to control the rate at which it becomes lighter)");
AUTOCVAR(cl_glowtrails_thickness_max, float, 12, "Width of the trails at their maximum");
AUTOCVAR(cl_glowtrails_thickness_med, float, 6, "Width of the trails at the half way point");
AUTOCVAR(cl_glowtrails_thickness_min, float, 0, "Width of the trails at the end");
AUTOCVAR(cl_glowtrails_texture, int, 0, "Texture of the trail, 0: plain, 1: lgbeam, 2: gauntletbeam");

const int polytrails_flashy_color_count = 6;
const float polytrails_flashy_color_frequency = 2;
vector polytrails_flashy_colors[polytrails_flashy_color_count] = {
    '0 0 1', // blue
    '1 1 0', // yellow
    '1 0 0', // red
    '0 1 1', // cyan
    '0 1 0', // green
    '1 1 1', // white
};

/*
 * Returns a flashy color, alternates polytrails_flashy_colors colors at
 * polytrails_flashy_color_frequency hertz
 */
vector polytrails_flashy_color()
{
    return polytrails_flashy_colors[
        floor(time*polytrails_flashy_color_frequency) % polytrails_flashy_color_count
    ];
}

const int polytrails_color_count = 6;
vector polytrails_colors[polytrails_color_count] = {
    '0 0 1', // blue
    '0 1 0', // green
    '1 0 0', // red
    '1 1 0', // yellow
    '1 1 1', // white
    '-1 -1 -1', // flashy
};

/*
 * Returns a color from polytrails_colors, handling the flashy color
 */
vector polytrails_color(int index)
{
    vector color = polytrails_colors[index];
    if ( color.x < 0 )
        return polytrails_flashy_color();
    return color;
}

/*
 * Selects a color from polytrails_colors based on how far hp is in the range
 * [0, maxvalue], linerly interpolating between colors.
 */
vector polytrails_get_color(float hp, float maxvalue)
{
    float total_ratio = hp / maxvalue * polytrails_color_count;
    int color_index = floor(total_ratio);
    if ( color_index >= polytrails_color_count )
        return polytrails_color(polytrails_color_count - 1);
    return lerpvratio(polytrails_color(color_index),
                      polytrails_color(color_index+1),
                      total_ratio - color_index);
}

.PolyTrail ptrail;
MUTATOR_HOOKFUNCTION(polytrails, TagIndex_Update)
{
    return = false; // not needed?

    if(!STAT(POLYTRAILS_ALLOWED))
        return;
    if(STAT(POLYTRAILS_ALLOWED) == 2 && gametype != MAPINFO_TYPE_CTS)
        return;

    if(!autocvar_cl_glowtrails || (gametype != MAPINFO_TYPE_CTS && autocvar_cl_glowtrails == 1))
        return;

    entity player = M_ARGV(0, entity);

    if(!player.isplayermodel)
        return;
    if(!(player.entnum >= 1 && player.entnum <= maxclients))
        return;

    entity local_player = CSQCModel_server2csqc(player_localentnum - 1);
    if((player == local_player && !autocvar_chase_active) || (player == csqcplayer && local_player != csqcplayer)) // never draw our own while spectating
    {
        if(player.ptrail)
            player.ptrail.polytrail_follow = NULL;
        player.ptrail = NULL;
        return;
    }

    if(!player.ptrail || wasfreed(player.ptrail))
    {
        player.ptrail = NEW(PolyTrail, player);
        IL_PUSH(g_drawables, player.ptrail);
    }
    switch(autocvar_cl_glowtrails_texture)
    {
        default:
        case 0: player.ptrail.polytrail_tex = "gfx/trails/plain.tga"; break;
        case 1: player.ptrail.polytrail_tex = "particles/lgbeam.tga"; break;
        case 2: player.ptrail.polytrail_tex = "particles/gauntletbeam.tga"; break;
    }

    player.ptrail.polytrail_thickness[0] = autocvar_cl_glowtrails_thickness_max;
    player.ptrail.polytrail_thickness[1] = autocvar_cl_glowtrails_thickness_med;
    player.ptrail.polytrail_thickness[2] = autocvar_cl_glowtrails_thickness_min;

    float myalpha = ((autocvar_cl_glowtrails_usealpha) ? ((player.alpha == 0 || player.alpha == 1) ? autocvar_cl_glowtrails_usealpha : player.alpha) : 1);
    player.ptrail.polytrail_alpha[0] = myalpha;
    player.ptrail.polytrail_alpha[1] = myalpha * 0.5;
    player.ptrail.polytrail_alpha[2] = 0;

    if(gametype == MAPINFO_TYPE_CTS)
    {
        float myspeed = vlen(player.velocity);
        myspeed = bound(0, myspeed * autocvar_cl_glowtrails_scale, 200);

        player.ptrail.polytrail_rgb[0] = polytrails_get_color(myspeed, 200);
        player.ptrail.polytrail_rgb[1] = polytrails_get_color(myspeed * 0.75, 200);
        player.ptrail.polytrail_rgb[2] = polytrails_get_color(myspeed * 0.5, 200);
    }
    else
    {
        int pnum = player.entnum - 1;
        vector col;
        if(teamplay)
            col = Team_ColorRGB(entcs_GetTeam(pnum));
        else
            col = entcs_GetColor(pnum);

        player.ptrail.polytrail_rgb[0] = col;
        player.ptrail.polytrail_rgb[1] = col;
        player.ptrail.polytrail_rgb[2] = col;
    }
}
