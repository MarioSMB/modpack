//FEATURE: Player glowy trails in CTS

#include "polytrails.qh"
#include "polytrails_weapons.qh"

#define POLYTRAIL_SEEK(_p, _rel) ((POLYTRAIL_BUFSIZE + (_p).polytrail_bufidx + (_rel)) % POLYTRAIL_BUFSIZE)
void Trail_draw(entity this)
{
    if (wasfreed(this.polytrail_follow))
        this.polytrail_follow = NULL;

    // NOTE: need an internal reset distance for warpzones to work properly TODO?
    float reset_distance = 200;

    if (!this.polytrail_follow) {
        float when = this.polytrail_buftime[this.polytrail_bufidx];
        if (time - when > this.polytrail_lifetime) {
            delete(this);
            return;
        }
    } else if(reset_distance > 0 && this.polytrail_cnt > 0 && vdist(this.origin - this.polytrail_follow.origin, >, reset_distance)) {
        Trail_recreate(this);
    } else {
        setorigin(this, this.polytrail_follow.origin);
        if (this.polytrail_cnt < 0 || vdist(this.origin - this.polytrail_bufpos[this.polytrail_bufidx], >=, this.polytrail_segmentsize)) {
            int i = POLYTRAIL_SEEK(this, 1);
            this.polytrail_bufpos[i] = this.origin;
            float f = this.polytrail_noise;
            // TODO: alternate noise functions (none, chaotic, helix, zigzag, waves, ...)
            switch(this.polytrail_noisefunc)
            {
                default:
                case "none": this.polytrail_bufnoise[i] = '0 0 0'; break;
                case "chaotic": this.polytrail_bufnoise[i] = randompos(f * '-1 -1 -1', f * '1 1 1'); break;
            }
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
        vector rgb = lerpv3ratio(this.polytrail_head_color, this.polytrail_body_color, this.polytrail_tail_color, rtime);
        float a = lerp3ratio(this.polytrail_head_alpha, this.polytrail_body_alpha, this.polytrail_tail_alpha, rtime);
        int thickness = lerp3ratio(this.polytrail_head_thickness, this.polytrail_body_thickness, this.polytrail_tail_thickness, rtime);
        vector thickdir = normalize(cross(normalize(to - from), view_origin - from)) * (thickness / 2);
        vector A = from + thickdir;
        vector B = from - thickdir;
        vector C = to + thickdir;
        vector D = to - thickdir;
        R_BeginPolygon(this.polytrail_tex, DRAWFLAG_SCREEN, false);
        R_PolygonVertex(B, '0 0 0', rgb, a);
        R_PolygonVertex(A, '0 1 0', rgb, a);
        R_PolygonVertex(C, '1 1 0', rgb, a);
        R_PolygonVertex(D, '1 0 0', rgb, a);
        R_EndPolygon();
        from = to;
    }
}
#undef POLYTRAIL_SEEK

void Trail_recreate(entity this)
{
    PolyTrail t = NEW(PolyTrail);
    t.polytrail_follow = this.polytrail_follow;
    IL_PUSH(g_drawables, t);
    t.polytrail_teamcolor = this.polytrail_teamcolor;
    t.polytrail_tex = this.polytrail_tex;
    t.polytrail_head_alpha = this.polytrail_head_alpha;
    t.polytrail_head_color = this.polytrail_head_color;
    t.polytrail_head_thickness = this.polytrail_head_thickness;
    t.polytrail_body_alpha = this.polytrail_body_alpha;
    t.polytrail_body_color = this.polytrail_body_color;
    t.polytrail_body_thickness = this.polytrail_body_thickness;
    t.polytrail_tail_alpha = this.polytrail_tail_alpha;
    t.polytrail_tail_color = this.polytrail_tail_color;
    t.polytrail_tail_thickness = this.polytrail_tail_thickness;
    t.polytrail_lifetime = this.polytrail_lifetime;
    t.polytrail_segmentsize = this.polytrail_segmentsize;
    t.polytrail_noise = this.polytrail_noise;
    t.polytrail_noisefunc = this.polytrail_noisefunc;

    this.polytrail_follow = NULL;
}

void PolyTrail_Spawn(entity this, entity _follow)
{
    this.polytrail_follow = _follow;
    IL_PUSH(g_drawables, this);

    if((autocvar_cl_polytrails_teamcolor || this.polytrail_teamcolor) && _follow.colormap > 0)
    {
        vector teamcolor = colormapPaletteColor(_follow.colormap & 0x0F, true);
        // keep original head color so it matches projectile
        this.polytrail_body_color = teamcolor;
        this.polytrail_tail_color = teamcolor;
    }
}

REGISTER_MUTATOR(polytrails, true);

MUTATOR_HOOKFUNCTION(polytrails, EditProjectile) {
    return = false;
    if (!autocvar_cl_polytrails) return;
    entity proj = M_ARGV(0, entity);
    
    switch(proj.cnt)
    {
        case PROJECTILE_BLASTER:
            if(autocvar_cl_polytrails_blaster_bolt)
            {
                setmodel(proj, MDL_Null);
                proj.mins = '0 0 0';
                proj.maxs = '0 0 0';
                PolyTrail_Spawn(NEW(BlasterBoltTrail), proj);
            }
            break;
        case PROJECTILE_ELECTRO:
            if(autocvar_cl_polytrails_electro_orb)
            {
                proj.traileffect = EFFECT_Null.m_id;
                PolyTrail_Spawn(NEW(ElectroOrbTrail), proj);
            }
            break;
        case PROJECTILE_CRYLINK_BOUNCING:
            if(autocvar_cl_polytrails_crylink_bouncing)
            {
                proj.traileffect = EFFECT_Null.m_id;
                PolyTrail_Spawn(NEW(CrylinkBouncingTrail), proj);
            }
            break;
         case PROJECTILE_ELECTRO_BEAM:
            if(autocvar_cl_polytrails_electro_bolt)
            {
                proj.traileffect = EFFECT_Null.m_id;
                PolyTrail_Spawn(NEW(ElectroBoltTrail), proj);
            }
            break;
        case PROJECTILE_CRYLINK:
            if(autocvar_cl_polytrails_crylink_bolt)
            {
                proj.traileffect = EFFECT_Null.m_id;
                PolyTrail_Spawn(NEW(CrylinkBoltTrail), proj);
            }
            break;
    }
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
        player.ptrail = NEW(PolyTrail);
        PolyTrail_Spawn(player.ptrail, player);
    }
    switch(autocvar_cl_glowtrails_texture)
    {
        default:
        case 0: player.ptrail.polytrail_tex = "gfx/trails/plain.tga"; break;
        case 1: player.ptrail.polytrail_tex = "particles/lgbeam.tga"; break;
        case 2: player.ptrail.polytrail_tex = "particles/gauntletbeam.tga"; break;
    }

    player.ptrail.polytrail_head_thickness = autocvar_cl_glowtrails_thickness_max;
    player.ptrail.polytrail_body_thickness = autocvar_cl_glowtrails_thickness_med;
    player.ptrail.polytrail_tail_thickness = autocvar_cl_glowtrails_thickness_min;

    float myalpha = ((autocvar_cl_glowtrails_usealpha) ? ((player.alpha == 0 || player.alpha == 1) ? autocvar_cl_glowtrails_usealpha : player.alpha) : 1);
    player.ptrail.polytrail_head_alpha = myalpha;
    player.ptrail.polytrail_body_alpha = myalpha * 0.5;
    player.ptrail.polytrail_tail_alpha = 0;

    if(gametype == MAPINFO_TYPE_CTS)
    {
        float myspeed = vlen(player.velocity);
        myspeed = bound(0, myspeed * autocvar_cl_glowtrails_scale, 200);

        player.ptrail.polytrail_head_color = polytrails_get_color(myspeed, 200);
        player.ptrail.polytrail_body_color = polytrails_get_color(myspeed * 0.75, 200);
        player.ptrail.polytrail_tail_color = polytrails_get_color(myspeed * 0.5, 200);
    }
    else
    {
        int pnum = player.entnum - 1;
        vector col;
        if(teamplay)
            col = Team_ColorRGB(entcs_GetTeam(pnum));
        else
            col = entcs_GetColor(pnum);

        player.ptrail.polytrail_head_color = col;
        player.ptrail.polytrail_body_color = col;
        player.ptrail.polytrail_tail_color = col;
    }
}
