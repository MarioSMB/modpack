#include "particles.qh"

#ifdef CSQC
const float RAND_MAX = 2147483647;
#define lhrandom(MIN,MAX) (((floor(random() * RAND_MAX) + 0.5) / (RAND_MAX + 1)) * ((MAX)-(MIN)) + (MIN))

const int PARTICLEEFFECT_UNDERWATER = 1;
const int PARTICLEEFFECT_NOTUNDERWATER = 2;
const int PARTICLEEFFECT_FORCENEAREST = 4;

vector hexcolors_to_rgb(int hexValue)
{
	vector rgb;
	rgb.x = ((hexValue >> 16) & 0xFF);
	rgb.y = ((hexValue >> 8) & 0xFF);
	rgb.z = ((hexValue) & 0xFF);

	return rgb;
}

int hexcolor_to_int(string hex)
{
	int result = 0;
	int len = strlen(hex);
	for(int j = 0; j < len; ++j)
	{
		int c = str2chr(hex, j);
		int v = (c & 0xF) + (c >> 6) | ((c >> 3) & 0x8);
		result = (result << 4) | v;
	}

	return result;
}

bool pcvar_valid(string input)
{
	return ((cvar_type(input) & CVAR_TYPEFLAG_EXISTS) && cvar_string(input) != "");
}

int Particle_BlendFromType(int input)
{
	switch(input)
	{
		case PT_ALPHASTATIC: return PBLEND_ALPHA;
		case PT_STATIC: return PBLEND_ADD;
		case PT_SPARK: return PBLEND_ADD;
		case PT_BEAM: return PBLEND_ADD;
		case PT_RAIN: return PBLEND_ADD;
		case PT_RAINDECAL: return PBLEND_ADD;
		case PT_SNOW: return PBLEND_ADD;
		case PT_BUBBLE: return PBLEND_ADD;
		case PT_BLOOD: return PBLEND_INVMOD;
		case PT_SMOKE: return PBLEND_ADD;
		case PT_DECAL: return PBLEND_INVMOD;
		case PT_ENTITYPARTICLE: return PBLEND_ALPHA;
	}

	// shouldn't be able to get here!
	return PBLEND_ALPHA;
}

int Particle_OrientationFromType(int input)
{
	switch(input)
	{
		case PT_ALPHASTATIC: return PARTICLE_BILLBOARD;
		case PT_STATIC: return PARTICLE_BILLBOARD;
		case PT_SPARK: return PARTICLE_SPARK;
		case PT_BEAM: return PARTICLE_BEAM;
		case PT_RAIN: return PARTICLE_SPARK;
		case PT_RAINDECAL: return PARTICLE_ORIENTED_DOUBLESIDED;
		case PT_SNOW: return PARTICLE_BILLBOARD;
		case PT_BUBBLE: return PARTICLE_BILLBOARD;
		case PT_BLOOD: return PARTICLE_BILLBOARD;
		case PT_SMOKE: return PARTICLE_BILLBOARD;
		case PT_DECAL: return PARTICLE_ORIENTED_DOUBLESIDED;
		case PT_ENTITYPARTICLE: return PARTICLE_BILLBOARD;
	}

	// shouldn't be able to get here!
	return PARTICLE_BILLBOARD;
}

vector Particle_RGBFromString(string input)
{
	// handle as a hexcode?
	if(substring(input, 0, 2) == "0x")
	{
		// 0xFFFFFF
		vector rgb = hexcolors_to_rgb(hexcolor_to_int(substring(input, 2, -1)));
		if(rgb.x) rgb.x = rgb.x / 255;
		if(rgb.y) rgb.y = rgb.y / 255;
		if(rgb.z) rgb.z = rgb.z / 255;
		return rgb;
	}
	// handle as xonotic color code?
	if(substring(input, 0, 1) == "^")
	{
		string ch2 = substring(input, 1, 1);
		if(IS_DIGIT(ch2))
		{
			switch(stof(ch2))
			{
				case 0: return '0 0 0';
				case 1: return '1 0 0';
				case 2: return '0 1 0';
				case 3: return '1 1 0';
				case 4: return '0 0 1';
				case 5: return '0 1 1';
				case 6: return '1 0 1';
				case 7: return '1 1 1';
				case 8: return '0.5 0.5 0.5';
				case 9: return '0.5 0.5 0.5';
			}
			// broken color code?
			return '1 1 1';
		}
		vector tcol = '1 1 1';
		tcol.x = HEXDIGIT_TO_DEC(substring(input, 2, 1)); if(tcol.x) tcol.x /= 15;
		tcol.y = HEXDIGIT_TO_DEC(substring(input, 3, 1)); if(tcol.y) tcol.y /= 15;
		tcol.z = HEXDIGIT_TO_DEC(substring(input, 4, 1)); if(tcol.z) tcol.z /= 15;
		return tcol;
	}
	return stov(input);
}

void Particle_Parse_cvar(string input, vector org_from, vector org_to, vector dir_from, vector dir_to, float pcount, bool wanttrail, int eff_flags)
{
	// CL_Particles_ParseEffectInfo

	int info_flags = 0;
	//float info_particleaccumulator = 0;
	float info_countabsolute = 0;
	float info_countmultiplier = 0;
	float info_trailspacing = 0;
	int info_particletype = PT_ALPHASTATIC;
	int info_blendmode = PBLEND_ALPHA;
	int info_orientation = PARTICLE_BILLBOARD;
	vector info_color_min = '1 1 1';
	vector info_color_max = '1 1 1';
	vector info_tex = '63 63 0';
	vector info_size = '1 1 0';
	vector info_alpha = '0 256 256';
	vector info_time = '16777216 16777216 0';
	float info_gravity = 0;
	float info_bounce = 0;
	float info_airfriction = 0;
	float info_liquidfriction = 0;
	float info_stretchfactor = 1;
	vector info_originoffset = '0 0 0';
	vector info_relativeoriginoffset = '0 0 0';
	vector info_velocityoffset = '0 0 0';
	vector info_relativevelocityoffset = '0 0 0';
	vector info_originjitter = '0 0 0';
	vector info_velocityjitter = '0 0 0';
	float info_velocitymultiplier = 0;
	float info_lightradiusstart = 0;
	float info_lightradiusfade = 0;
	float info_lighttime = 16777216;
	vector info_lightcolor = '1 1 1';
	bool info_lightshadow = true;
	int info_lightcubemapnum = 0;
	vector info_lightcorona = '1 0.25 0';
	vector info_staincolor_min = '0 0 0';
	vector info_staincolor_max = '0 0 0';
	vector info_staintex = '-1 -1 0';
	vector info_stainalpha = '1 1 0';
	vector info_stainsize = '2 2 0';
	// rotate has 4 parts
	vector info_startangle = '0 360 0';
	vector info_spin = '0 0 0';

	// unique to QC particle system
	float delayspawn = 0;
	float delaycollision = 0;
	int teamcolor = 0;
	int lightteamcolor = 0;

	string s = "";

	s = strcat(input, "_countabsolute"); if(pcvar_valid(s)) info_countabsolute = cvar(s);
	s = strcat(input, "_count"); if(pcvar_valid(s)) info_countmultiplier = cvar(s);
	s = strcat(input, "_type");
	if(pcvar_valid(s))
	{
		s = cvar_string(s);
		switch(s)
		{
			case "alphastatic": info_particletype = PT_ALPHASTATIC; break;
			case "static": info_particletype = PT_STATIC; break;
			case "spark": info_particletype = PT_SPARK; break;
			case "beam": info_particletype = PT_BEAM; break;
			case "rain": info_particletype = PT_RAIN; break;
			case "raindecal": info_particletype = PT_RAINDECAL; break;
			case "snow": info_particletype = PT_SNOW; break;
			case "bubble": info_particletype = PT_BUBBLE; break;
			case "blood": info_particletype = PT_BLOOD; info_gravity = 1; break;
			case "smoke": info_particletype = PT_SMOKE; break;
			case "decal": info_particletype = PT_DECAL; break;
			case "entityparticle": info_particletype = PT_ENTITYPARTICLE; break;
		}

		info_blendmode = Particle_BlendFromType(info_particletype);
		info_orientation = Particle_OrientationFromType(info_particletype);
	}
	s = strcat(input, "_blend");
	if(pcvar_valid(s))
	{
		s = cvar_string(s);
		switch(s)
		{
			case "alpha": info_blendmode = PBLEND_ALPHA; break;
			case "add": info_blendmode = PBLEND_ADD; break;
			case "invmod": info_blendmode = PBLEND_INVMOD; break;
			// TODO: warn about invalid?
		}
	}
	s = strcat(input, "_orientation");
	if(pcvar_valid(s))
	{
		s = cvar_string(s);
		switch(s)
		{
			case "billboard": info_orientation = PARTICLE_BILLBOARD; break;
			case "spark": info_orientation = PARTICLE_SPARK; break;
			case "oriented": info_orientation = PARTICLE_ORIENTED_DOUBLESIDED; break;
			case "beam": info_orientation = PARTICLE_BEAM; break;
			// TODO: warn about invalid?
		}
	}
	s = strcat(input, "_color");
	if(pcvar_valid(s))
	{
		s = cvar_string(s);
		info_color_min = Particle_RGBFromString(car(s));
		s = cdr(s);
		info_color_max = Particle_RGBFromString(car(s));
	}
	s = strcat(input, "_color_min"); if(pcvar_valid(s)) info_color_min = Particle_RGBFromString(cvar_string(s));
	s = strcat(input, "_color_max"); if(pcvar_valid(s)) info_color_max = Particle_RGBFromString(cvar_string(s));
	s = strcat(input, "_tex"); if(pcvar_valid(s)) info_tex = stov(cvar_string(s));
	s = strcat(input, "_size"); if(pcvar_valid(s)) info_size = stov(cvar_string(s));
	s = strcat(input, "_sizeincrease"); if(pcvar_valid(s)) info_size.z = cvar(s);
	s = strcat(input, "_alpha"); if(pcvar_valid(s)) info_alpha = stov(cvar_string(s));
	s = strcat(input, "_time"); if(pcvar_valid(s)) info_time = stov(cvar_string(s));
	s = strcat(input, "_gravity"); if(pcvar_valid(s)) info_gravity = cvar(s);
	s = strcat(input, "_bounce"); if(pcvar_valid(s)) info_bounce = cvar(s);
	s = strcat(input, "_airfriction"); if(pcvar_valid(s)) info_airfriction = cvar(s);
	s = strcat(input, "_liquidfriction"); if(pcvar_valid(s)) info_liquidfriction = cvar(s);
	s = strcat(input, "_originoffset"); if(pcvar_valid(s)) info_originoffset = stov(cvar_string(s));
	s = strcat(input, "_relativeoriginoffset"); if(pcvar_valid(s)) info_relativeoriginoffset = stov(cvar_string(s));
	s = strcat(input, "_velocityoffset"); if(pcvar_valid(s)) info_velocityoffset = stov(cvar_string(s));
	s = strcat(input, "_relativevelocityoffset"); if(pcvar_valid(s)) info_relativevelocityoffset = stov(cvar_string(s));
	s = strcat(input, "_originjitter"); if(pcvar_valid(s)) info_originjitter = stov(cvar_string(s));
	s = strcat(input, "_velocityjitter"); if(pcvar_valid(s)) info_velocityjitter = stov(cvar_string(s));
	s = strcat(input, "_velocitymultiplier"); if(pcvar_valid(s)) info_velocitymultiplier = cvar(s);
	s = strcat(input, "_lightradius"); if(pcvar_valid(s)) info_lightradiusstart = cvar(s);
	s = strcat(input, "_lightradiusfade"); if(pcvar_valid(s)) info_lightradiusfade = cvar(s);
	s = strcat(input, "_lighttime"); if(pcvar_valid(s)) info_lighttime = cvar(s);
	s = strcat(input, "_lightcolor"); if(pcvar_valid(s)) info_lightcolor = Particle_RGBFromString(cvar_string(s));
	s = strcat(input, "_lightshadow"); if(pcvar_valid(s)) info_lightshadow = InterpretBoolean(cvar_string(s));
	s = strcat(input, "_lightcubemapnum"); if(pcvar_valid(s)) info_lightcubemapnum = cvar(s);
	s = strcat(input, "_lightcorona"); if(pcvar_valid(s)) info_lightcorona = stov(cvar_string(s));
	s = strcat(input, "_underwater"); if(pcvar_valid(s) && InterpretBoolean(cvar_string(s))) info_flags |= PARTICLEEFFECT_UNDERWATER;
	s = strcat(input, "_notunderwater"); if(pcvar_valid(s) && InterpretBoolean(cvar_string(s))) info_flags |= PARTICLEEFFECT_NOTUNDERWATER;
	s = strcat(input, "_trailspacing"); if(pcvar_valid(s)) { info_trailspacing = cvar(s); if(info_trailspacing > 0) info_countmultiplier = 1 / info_trailspacing; }
	s = strcat(input, "_stretchfactor"); if(pcvar_valid(s)) info_stretchfactor = cvar(s);
	// NOTE: color support has been split to work with other inputs
	//s = strcat(input, "_staincolor");
	s = strcat(input, "_staincolor_min"); if(pcvar_valid(s)) info_staincolor_min = Particle_RGBFromString(cvar_string(s));
	s = strcat(input, "_staincolor_max"); if(pcvar_valid(s)) info_staincolor_max = Particle_RGBFromString(cvar_string(s));
	s = strcat(input, "_stainalpha"); if(pcvar_valid(s)) info_stainalpha = stov(cvar_string(s));
	s = strcat(input, "_stainsize"); if(pcvar_valid(s)) info_stainsize = stov(cvar_string(s));
	s = strcat(input, "_staintex"); if(pcvar_valid(s)) info_staintex = stov(cvar_string(s));
	s = strcat(input, "_stainless");
	if(pcvar_valid(s) && InterpretBoolean(cvar_string(s)))
	{
		info_staincolor_min = '0 0 0';
		info_staincolor_max = '0 0 0';
		info_stainalpha = '1 1 0';
		info_stainsize = '2 2 0';
	}
	s = strcat(input, "_rotate");
	if(pcvar_valid(s))
	{
		s = cvar_string(s);
		string sa;
		sa = car(s); if(sa != "") info_startangle.x = stof(sa);
		s = cdr(s);
		sa = car(s); if(sa != "") info_startangle.y = stof(sa);
		s = cdr(s);
		sa = car(s); if(sa != "") info_spin.x = stof(sa);
		s = cdr(s);
		sa = car(s); if(sa != "") info_spin.y = stof(sa);
	}
	s = strcat(input, "_startangle"); if(pcvar_valid(s)) info_startangle = stov(cvar_string(s));
	s = strcat(input, "_spin"); if(pcvar_valid(s)) info_spin = stov(cvar_string(s));
	// NOTE: unused
	s = strcat(input, "_forcenearest"); if(pcvar_valid(s) && InterpretBoolean(cvar_string(s))) info_flags |= PARTICLEEFFECT_FORCENEAREST;

	// unique to QC particle system, subject to change
	s = strcat(input, "_delayspawn"); if(pcvar_valid(s)) delayspawn = cvar(s);
	s = strcat(input, "_delaycollision"); if(pcvar_valid(s)) delaycollision = cvar(s);
	// NOTE: requires particles_colormin and particles_colormax to be set along with PARTICLES_USECOLOR!
	// TODO: use them anyway?
	s = strcat(input, "_teamcolor"); if(pcvar_valid(s)) teamcolor = cvar(s);
	s = strcat(input, "_lightteamcolor"); if(pcvar_valid(s)) lightteamcolor = cvar(s);

	// quake has no use for team colors
	if(teamcolor < 3)
		teamcolor = 0;
	if(lightteamcolor < 3)
		lightteamcolor = 0;

	if(((teamcolor == 1) || teamcolor == 2) && (eff_flags & PARTICLES_USECOLOR))
	{
		info_color_min = particles_colormin;
		info_color_max = particles_colormax;
	}

	if(((lightteamcolor == 1) || lightteamcolor == 2) && (eff_flags & PARTICLES_USECOLOR))
		info_lightcolor = particles_colormin + 0.5 * (particles_colormax - particles_colormin);
	else if(lightteamcolor == 3)
	{
		info_lightcolor.x = random();
		info_lightcolor.y = random();
		info_lightcolor.z = random();
	}

	// CL_NewParticlesFromEffectinfo

	vector originmins = org_from;
	vector originmaxs = org_to;
	vector velocitymins = dir_from;
	vector velocitymaxs = dir_to;

	// TODO: trailparticles is weird
	// FIXME: where did this line even come from? seems to just break!
	//if(wanttrail)
		//originmaxs = dir_to;

	int supercontents;
	int tex, staintex;
	vector center;
	vector traildir;
	vector trailpos;
	vector rvec;
	vector pangles;
	vector pvelocity;
	vector forward;
	vector right;
	vector up;
	float traillen;
	float trailstep;
	bool underwater;
	// TODO? immediatebloodstain
	// TODO? tint, handling it separately currently!

	center = originmins + 0.5 * (originmaxs - originmins);
	supercontents = Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(center));
	underwater = (supercontents & DPCONTENTS_LIQUIDSMASK);
	traildir = originmaxs - originmins;
	traillen = vlen(traildir);
	traildir = normalize(traildir);

	bool definedastrail = (info_trailspacing > 0);

	bool drawastrail = (wanttrail || (eff_flags & PARTICLES_DRAWASTRAIL));
	if(autocvar_cl_particles_forcetraileffects)
		drawastrail = (drawastrail || definedastrail);

	if((info_flags & PARTICLEEFFECT_UNDERWATER) && !underwater)
		return;
	if((info_flags & PARTICLEEFFECT_NOTUNDERWATER) && underwater)
		return;

	resetparticle();

	if(info_lighttime > 0 && info_lightradiusfade > 0)
	{
		vector light_org;
		if(drawastrail)
			light_org = originmaxs;
		else
			light_org = center;
		//particle_lightradius /= 256;
		//info_lightradiusfade /= 1000; // convert to miliseconds
		// NOTE: custom flashes don't support separating lifetime from fade rate
		te_customflash(light_org, info_lightradiusstart, info_lightradiusstart / info_lightradiusfade, info_lightcolor);
	}

	// spawn particles
	tex = info_tex.x;
	if(info_tex.y > info_tex.x)
	{
		tex = rint(lhrandom(info_tex.x, info_tex.y));
		tex = min(tex, info_tex.y - 1);
	}
	if(info_staintex.x < 0)
		staintex = info_staintex.x;
	else
	{
		staintex = rint(lhrandom(info_staintex.x, info_staintex.y));
		staintex = min(staintex, info_staintex.y - 1);
	}
	if(info_particletype == PT_DECAL)
	{
		// TODO: decal system doesn't appear to be exposed to QC, may need custom entities
		info_airfriction = 0;
		info_time.x = autocvar_cl_decals_time + autocvar_cl_decals_fadetime;
		info_time.y = autocvar_cl_decals_time + autocvar_cl_decals_fadetime;
		if(autocvar_cl_decals_fadetime)
			info_alpha.z = 256 / autocvar_cl_decals_fadetime;
	}
	/*else*/ if(info_orientation == PARTICLE_BEAM)
	{
		if(!drawastrail)
			return;

		pangles = vectoangles(traildir);
		MAKE_VECTORS(pangles, forward, right, up);
		trailpos = info_relativeoriginoffset.x * forward + info_relativeoriginoffset.y * right + info_relativeoriginoffset.z * up;

		particle_type = info_particletype;
		particle_color1 = info_color_max;
		particle_color2 = info_color_min;
		particle_tex = tex;
		particle_size = lhrandom(info_size.x, info_size.y);
		particle_sizeincrease = info_size.z;
		particle_alpha = lhrandom(info_alpha.x, info_alpha.y);
		particle_alphafade = info_alpha.z;
		particle_gravity = 0;
		particle_bounce = 0;
		particle_airfriction = 0;
		particle_liquidfriction = 0;
		particle_originjitter = 0;
		particle_velocityjitter = 0;
		particle_qualityreduction = false;
		particle_time = lhrandom(info_time.x, info_time.y);
		particle_stretch = info_stretchfactor;
		particle_blendmode = info_blendmode;
		particle_orientation = info_orientation;
		particle_staincolor1 = info_staincolor_min;
		particle_staincolor2 = info_staincolor_max;
		particle_staintex = staintex;
		particle_stainalpha = lhrandom(info_stainalpha.x, info_stainalpha.y);
		particle_stainsize = lhrandom(info_stainsize.x, info_stainsize.y);
		particle_angle = 0;
		particle_spin = 0;
		// unique to QC particle system
		particle_delayspawn = delayspawn;
		particle_delaycollision = delaycollision;

		particle_color1 *= 255;
		particle_color2 *= 255;

		if(particle_alpha)
			particle_alpha /= 255;
		if(particle_alphafade)
			particle_alphafade /= 255;
		if(particle_stainalpha)
			particle_stainalpha /= 256;

		vector org;
		org.x = originmins.x + trailpos.x;
		org.y = originmins.y + trailpos.y;
		org.z = originmins.z + trailpos.z;
		vector vel = originmaxs;

		spawnparticle(org, vel);
	}
	else
	{
		switch(info_particletype)
		{
			case PT_SMOKE: if(!autocvar_cl_particles_smoke) return; break;
			case PT_SPARK: if(!autocvar_cl_particles_sparks) return; break;
			case PT_BUBBLE: if(!autocvar_cl_particles_bubbles) return; break;
			case PT_BLOOD: if(!autocvar_cl_particles_blood) return; break;
			case PT_RAIN: if(!autocvar_cl_particles_rain) return; break;
			case PT_SNOW: if(!autocvar_cl_particles_snow) return; break;
		}

		int pcnt = info_countabsolute;
		pcnt += (pcount * info_countmultiplier) * autocvar_cl_particles_quality;
		// if drawastrail is not set, we will
		// use the regular cnt-based random
		// particle spawning at the center; so
		// do NOT apply trailspacing then!
		if(drawastrail && definedastrail)
			pcnt += (traillen / info_trailspacing) * autocvar_cl_particles_quality;
		if(eff_flags & PARTICLES_USEFADE)
			pcnt *= particles_fade;
		// workaround for accumulative methods used by the engine not applying here
		if(pcnt > 0 && pcnt < 1)
		{
			if(random() <= pcnt)
				pcnt = 1;
			else
				pcnt = 0;
		}
		if(pcnt == 0)
			return; // nothing to draw

		//info_particleaccumulator += pcnt;

		if(drawastrail)
		{
			trailpos = originmins;
			trailstep = traillen / pcnt;
		}
		else
		{
			trailpos = center;
			trailstep = 0;
		}

		if(trailstep == 0)
		{
			//pvelocity = 0.5 * velocitymins + 0.5 * velocitymaxs;
			pvelocity.x = 0.5 * velocitymins.x + 0.5 * velocitymaxs.x;
			pvelocity.y = 0.5 * velocitymins.y + 0.5 * velocitymaxs.y;
			pvelocity.z = 0.5 * velocitymins.z + 0.5 * velocitymaxs.z;

			pangles = vectoangles(pvelocity);
		}
		else
			pangles = vectoangles(traildir);

		MAKE_VECTORS(pangles, forward, right, up);
		// TODO: verify that the shorthand version produces matching results
		//trailpos = 1 * trailpos + info_relativeoriginoffset.x * forward + info_relativeoriginoffset.y * right + info_relativeoriginoffset.z * up;
		//pvelocity = info_relativevelocityoffset.x * forward + info_relativevelocityoffset.y * right + info_relativevelocityoffset.z * up;

		trailpos.x = 1.0 * trailpos.x + info_relativeoriginoffset.x * forward.x + info_relativeoriginoffset.y * right.x + info_relativeoriginoffset.z * up.x;
		trailpos.y = 1.0 * trailpos.y + info_relativeoriginoffset.x * forward.y + info_relativeoriginoffset.y * right.y + info_relativeoriginoffset.z * up.y;
		trailpos.z = 1.0 * trailpos.z + info_relativeoriginoffset.x * forward.z + info_relativeoriginoffset.y * right.z + info_relativeoriginoffset.z * up.z;

		pvelocity.x = info_relativevelocityoffset.x * forward.x + info_relativevelocityoffset.y * right.x + info_relativevelocityoffset.z * up.x;
		pvelocity.y = info_relativevelocityoffset.x * forward.y + info_relativevelocityoffset.y * right.y + info_relativevelocityoffset.z * up.y;
		pvelocity.z = info_relativevelocityoffset.x * forward.z + info_relativevelocityoffset.y * right.z + info_relativevelocityoffset.z * up.z;

		pcnt = bound(0, pcnt, 16384);
		//for( ; info_particleaccumulator >= 1; info_particleaccumulator--)
		for(int j = 0; j < pcnt; ++j)
		{
			if(info_tex.y > info_tex.x)
			{
				tex = rint(lhrandom(info_tex.x, info_tex.y));
				tex = min(tex, info_tex.y - 1);
			}
			if(!(drawastrail || definedastrail))
			{
				trailpos.x = lhrandom(originmins.x, originmaxs.x);
				trailpos.y = lhrandom(originmins.y, originmaxs.y);
				trailpos.z = lhrandom(originmins.z, originmaxs.z);
			}
			rvec = randomvec();

			particle_type = info_particletype;
			particle_color1 = info_color_min;
			particle_color2 = info_color_max;
			particle_tex = tex;
			particle_size = lhrandom(info_size.x, info_size.y);
			particle_sizeincrease = info_size.z;
			particle_alpha = lhrandom(info_alpha.x, info_alpha.y);
			particle_alphafade = info_alpha.z;
			particle_gravity = info_gravity;
			particle_bounce = info_bounce;
			particle_airfriction = info_airfriction;
			particle_liquidfriction = info_liquidfriction;
			particle_originjitter = 0;
			particle_velocityjitter = 0;
			particle_qualityreduction = (info_countabsolute <= 0);
			particle_time = lhrandom(info_time.x, info_time.y);
			particle_stretch = info_stretchfactor;
			particle_blendmode = info_blendmode;
			particle_orientation = info_orientation;
			particle_staincolor1 = info_staincolor_min;
			particle_staincolor2 = info_staincolor_max;
			particle_staintex = staintex;
			particle_stainalpha = lhrandom(info_stainalpha.x, info_stainalpha.y);
			particle_stainsize = lhrandom(info_stainsize.x, info_stainsize.y);
			particle_angle = lhrandom(info_startangle.x, info_startangle.y);
			particle_spin = lhrandom(info_spin.x, info_spin.y);

			// unique to QC particle system
			particle_delayspawn = delayspawn;
			particle_delaycollision = delaycollision;
			if(teamcolor == 4)
			{
				particle_color1.x = random();
				particle_color1.y = random();
				particle_color1.z = random();

				particle_color2.x = random();
				particle_color2.y = random();
				particle_color2.z = random();
			}

			if(particle_alpha)
				particle_alpha /= 256;
			if(particle_alphafade)
				particle_alphafade /= 256;
			if(particle_stainalpha)
				particle_stainalpha /= 256;

			particle_color1 *= 255;
			particle_color2 *= 255;

			vector org;
			org.x = trailpos.x + info_originoffset.x + info_originjitter.x * rvec.x;
			org.y = trailpos.y + info_originoffset.y + info_originjitter.y * rvec.y;
			org.z = trailpos.z + info_originoffset.z + info_originjitter.z * rvec.z;

			vector vel;
			vel.x = lhrandom(velocitymins.x, velocitymaxs.x) * info_velocitymultiplier + info_velocityoffset.x + info_velocityjitter.x * rvec.x + pvelocity.x;
			vel.y = lhrandom(velocitymins.y, velocitymaxs.y) * info_velocitymultiplier + info_velocityoffset.y + info_velocityjitter.y * rvec.y + pvelocity.y;
			vel.z = lhrandom(velocitymins.z, velocitymaxs.z) * info_velocitymultiplier + info_velocityoffset.z + info_velocityjitter.z * rvec.z + pvelocity.z;

			// workaround for the lack of a decal system
			if(info_particletype == PT_DECAL)
				vel = normalize(velocitymaxs);

			//printparticle();
			spawnparticle(org, vel);

			if(trailstep)
				trailpos = trailpos + trailstep * traildir;
		}
	}
}

bool SpawnParticles_list_full(string input, vector org_from, vector org_to, vector dir_from, vector dir_to, float countmultiplier, bool istrail, int eff_flags)
{
	if(autocvar_cl_particle_disable || autocvar_cl_particles_quake || !autocvar_cl_particles)
		return false;
	// TODO: fallback?
	if(!pcvar_valid(input))
		return false;
	string list = cvar_string(input);
	if(list == "")
		return false;

	if(!initparticlespawner(16))
		return false;

	FOREACH_WORD(list, true,
	{
		Particle_Parse_cvar(strcat(input, "_", it), org_from, org_to, dir_from, dir_to, countmultiplier, istrail, eff_flags);
	});

	return true;
}

bool SpawnParticles_list(string input, vector org, vector vel, bool istrail)
{
	return SpawnParticles_list_full(input, org, org, vel, vel, 1, istrail, PARTICLES_USECOLOR);
}

#undef lhrandom
#endif
