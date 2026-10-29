#include "csqcmodel_hooks.qh"

#include "../client/main.qh"
#include "../client/weapons/projectile.qh"
#include "../common/constants.qh"
#include "../common/effects/all.qh"
#include "../common/physics/player.qh"
#include "../common/sounds/all.qh"
#include "../common/ent_cs.qh"
// TODO: this is order dependent!
#include "../common/champions/_mod.qh"
#include <lib/csqcmodel/cl_model.qh>
#include <lib/csqcmodel/cl_player.qh>
#include <lib/csqcmodel/interpolate.qh>

.float alpha;

// FEATURE: forcemodel and model color selection (MUST be called BEFORE LOD!)
.int forceplayermodels_savecolormap;

.vector glowmod;

#ifdef CSQC
bool teamplay;
int myteam;
#endif

void CSQCPlayer_ModelAppearance_PreUpdate(entity this)
{
	this.colormap = this.forceplayermodels_savecolormap;
}
void CSQCPlayer_ModelAppearance_PostUpdate(entity this)
{
	this.forceplayermodels_savecolormap = this.colormap;
}
void CSQCPlayer_ModelAppearance_Apply(entity this, bool islocalplayer)
{
	int cm = this.forceplayermodels_savecolormap;
	cm = (cm >= 1024) ? cm : (entcs_GetClientColors(cm - 1) + 1024);

	bool forceplayercolors_enabled = false;
	#define fpc autocvar_cl_forceplayercolors
	if (teamplay)
	{
		if (((player_localnum + 1) == player_localentnum) && (fpc == 2 || fpc == 4 || fpc == 5))
			forceplayercolors_enabled = true;
	}
	else
	{
		if (fpc == 1 || fpc == 2)
			forceplayercolors_enabled = true;
	}

	// forceplayercolors too
	if(teamplay)
	{
		// own team's color is never forced
		int forcecolor_friend = 0, forcecolor_enemy = 0;
#if 0
		entity tm;
#endif

		if(autocvar_cl_forcemyplayercolors)
			forcecolor_friend = 1024 + autocvar_cl_forcemyplayercolors;

		if(forceplayercolors_enabled)
			forcecolor_enemy = 1024 + autocvar__cl_color;

		if(forcecolor_enemy && !forcecolor_friend)
		{
			// only enemy color is forced?
			// verify it is not equal to the friend color
			if(forcecolor_enemy == 1024 + 17 * myteam)
				forcecolor_enemy = 0;
		}
#if 0
		if(forcecolor_friend && !forcecolor_enemy)
		{
			// only friend color is forced?
			// verify it is not equal to the enemy color
			for(tm = teams.sort_next; tm; tm = tm.sort_next)
				// note: we even compare against our own team.
				// if we rejected because we matched our OWN team color,
				// this is not bad; we then simply keep our color as is
				// anyway.
				if(forcecolor_friend == 1024 + 17 * tm.team)
					forcecolor_friend = 0;
		}
#endif

		if(cm == 1024 + 17 * myteam)
		{
			if(forcecolor_friend)
				this.colormap = forcecolor_friend;
		}
		else
		{
			if(forcecolor_enemy)
				this.colormap = forcecolor_enemy;
		}
	}
	else if(deathmatch)
	{
		if(autocvar_cl_forcemyplayercolors && islocalplayer)
			this.colormap = 1024 + autocvar_cl_forcemyplayercolors;
		else if (autocvar_cl_forceuniqueplayercolors && !islocalplayer)
		{
			// Assign each enemy an unique color combination
			// pick colors from 0 to 14 since 15 is the rainbow color
			// pl01 0 1, pl02 1 2, ..., pl14 13 14, pl15 14 0
			// pl16 0 2, pl17 1 3, ..., pl29 13  0, pl30 14 1
			int num;
			if (this.isplayermodel & ISPLAYER_CLIENT)
				num = this.entnum - 1;
			else
				num = this.sv_entnum - 1;
			int c1 = num % 15;
			int q = floor(num / 15);
			int c2 = (c1 + 1 + q) % 15;
			this.colormap = 1024 + (c1 << 4) + c2;
		}
		else if(forceplayercolors_enabled)
			this.colormap = player_localnum + 1;
	}

	LABEL(skipforcecolors)

	this.glowmod = '0 0 0'; // don't override glow effects in quake

	//printf("CSQCPlayer_ModelAppearance_Apply(): state = %s, colormap = %f, glowmod = %s\n", (this.csqcmodel_isdead ? "DEAD" : "ALIVE"), this.colormap, vtos(this.glowmod));
}

void SUB_SetFade(entity ent, float vanish_time, float fading_time);
.vector colormod;
.float aftereffect_time;
void CSQCModel_AfterEffect(entity this)
{
	if(time < this.aftereffect_time)
		return;
	if(vdist(this.velocity, <=, 100))
		return;

	float effrate = (this.isplayermodel) ? 1 : 3;
	this.aftereffect_time = time + effrate * PHYS_INPUT_TIMELENGTH;

	entity body = new(aftereffect);
	body.solid = SOLID_NOT;
	_setmodel(body, this.model);
	setsize(body, this.mins, this.maxs);
	setorigin(body, this.origin);
	body.angles = this.angles;
	//body.v_angle = this.v_angle;
	body.frame = this.frame;
	float myalpha = (this.alpha) ? this.alpha : 1;
	body.alpha = myalpha * 0.5;
	//body.colormod = '-1 -1 -1';
	body.colormap = this.colormap;
	body.effects = this.effects;
	body.effects &= ~EF_AFTEREFFECT; // lol no
	body.modelflags = this.modelflags;
	body.renderflags = RF_NOSHADOW | RF_ADDITIVE;
	body.drawmask = MASK_NORMAL;
	body.scale = this.scale;

	if(this.entnum == player_localentnum)
		body.renderflags |= RF_EXTERNALMODEL;
	else
		body.renderflags &= ~RF_EXTERNALMODEL;

	float efftime = (this.isplayermodel) ? 0.25 : 0.5;
	SUB_SetFade(body, time, efftime);
}

void CSQCModel_Hook_PreDraw(entity this, bool isplayer);

.float death_time;
.int modelflags;

.entity tag_entity;
.int tag_index;

void CSQCModel_Effects_PreUpdate(entity this)
{
	this.effects = this.csqcmodel_effects;
	this.modelflags = this.csqcmodel_modelflags;
	this.traileffect = this.csqcmodel_traileffect;
}
void CSQCModel_Effects_PostUpdate(entity this)
{
	this.csqcmodel_effects = this.effects;
	this.csqcmodel_modelflags = this.modelflags;
	this.csqcmodel_traileffect = this.traileffect;
	this.effects = 0;
	this.modelflags = 0;
	if(this.csqcmodel_teleported)
		Projectile_ResetTrail(this, this.origin);
}
void CSQCModel_Effects_Apply(entity this)
{
	int eff = this.csqcmodel_effects & ~CSQCMODEL_EF_RESPAWNGHOST;
	int tref = this.csqcmodel_traileffect;

	this.renderflags &= ~(RF_DEPTHHACK | RF_ADDITIVE | RF_FULLBRIGHT | EF_NOSHADOW | RF_USEAXIS);
	this.effects = 0;
	this.traileffect = 0;

	if(eff & EF_BRIGHTFIELD)
		tref = EFFECT_TR_NEXUIZPLASMA.m_id;
	// ignoring EF_MUZZLEFLASH
	if(eff & EF_BRIGHTLIGHT)
		adddynamiclight(this.origin, 400, '3 3 3');
	if(eff & EF_DIMLIGHT)
		adddynamiclight(this.origin, 200, '1.5 1.5 1.5');
	if((eff & EF_NODRAW) || (this.alpha < 0))
		this.drawmask = 0;
	if(eff & EF_ADDITIVE)
		this.renderflags |= RF_ADDITIVE;
	if(eff & EF_BLUE)
		adddynamiclight(this.origin, 200, '0.15 0.15 1.5');
	if(eff & EF_RED)
		adddynamiclight(this.origin, 200, '1.5 0.15 0.15');
	// ignoring EF_NOGUNBOB
	if(eff & EF_FULLBRIGHT)
		this.renderflags |= RF_FULLBRIGHT;
	if(eff & EF_FLAME)
		pointparticles(EFFECT_EF_FLAME, this.origin, '0 0 0', bound(0, frametime, 0.1));
	if(eff & EF_STARDUST)
		pointparticles(EFFECT_EF_STARDUST, this.origin, '0 0 0', bound(0, frametime, 0.1));
	if(eff & EF_NOSHADOW)
		this.renderflags |= RF_NOSHADOW;
	if(eff & EF_NODEPTHTEST)
		this.renderflags |= RF_DEPTHHACK;
	// ignoring EF_SELECTABLE
	if(eff & EF_DOUBLESIDED)
		this.effects |= EF_DOUBLESIDED;
	if(eff & EF_NOSELFSHADOW)
		this.effects |= EF_NOSELFSHADOW;
	if(eff & EF_DYNAMICMODELLIGHT)
		this.renderflags |= RF_DYNAMICMODELLIGHT;
	if(eff & EF_AFTEREFFECT)
		CSQCModel_AfterEffect(this);
	// ignoring EF_UNUSED18, EF_UNUSED19, EF_RESTARTANIM_BIT, EF_TELEPORT_BIT, EF_LOWPRECISION
	if(this.csqcmodel_modelflags & MF_ROCKET)
		tref = EFFECT_TR_ROCKET.m_id;
	if(this.csqcmodel_modelflags & MF_GRENADE)
		tref = EFFECT_TR_GRENADE.m_id;
	if(this.csqcmodel_modelflags & MF_GIB)
		tref = EFFECT_TR_BLOOD.m_id;
	if(this.csqcmodel_modelflags & MF_ROTATE)
	{
		this.renderflags |= RF_USEAXIS;
		makevectors(this.angles + '0 100 0' * fmod(time, 3.6));
	}
	if(this.csqcmodel_modelflags & MF_TRACER)
		tref = EFFECT_TR_WIZSPIKE.m_id;
	if(this.csqcmodel_modelflags & MF_ZOMGIB)
		tref = EFFECT_TR_SLIGHTBLOOD.m_id;
	if(this.csqcmodel_modelflags & MF_TRACER2)
		tref = EFFECT_TR_KNIGHTSPIKE.m_id;
	if(this.csqcmodel_modelflags & MF_TRACER3)
		tref = EFFECT_TR_VORESPIKE.m_id;

	this.traileffect = tref;

	if(this.drawmask)
		Projectile_DrawTrail(this, this.origin);
	else
		Projectile_ResetTrail(this, this.origin);

	if(this.csqcmodel_effects & CSQCMODEL_EF_RESPAWNGHOST)
		this.renderflags |= RF_ADDITIVE;
		// also special in CSQCPlayer_GlowMod_Apply

	if(this.csqcmodel_modelflags & MF_ROCKET)
	{
		if(!this.snd_looping)
		{
			sound(this, CH_TRIGGER_SINGLE, SND_JETPACK_FLY, VOL_BASE, autocvar_cl_jetpack_attenuation);
			this.snd_looping = CH_TRIGGER_SINGLE;
		}
	}
	else
	{
		if(this.snd_looping)
		{
			sound(this, this.snd_looping, SND_Null, VOL_BASE, autocvar_cl_jetpack_attenuation);
			this.snd_looping = 0;
		}
	}
}

// general functions
.int csqcmodel_predraw_run;
void CSQCModel_Hook_PreDraw(entity this, bool isplayer)
{
	if(this.csqcmodel_predraw_run == framecount)
		return;
	this.csqcmodel_predraw_run = framecount;

	if(!this.modelindex || this.model == "null")
	{
		this.drawmask = 0;
		return;
	}
	else
		this.drawmask = MASK_NORMAL;

	if((this.isplayermodel & ISPLAYER_MODEL) && this.drawmask) // this checks if it's a player MODEL!
		CSQCPlayer_ModelAppearance_Apply(this, (this.isplayermodel & ISPLAYER_LOCAL));

	CSQCModel_Effects_Apply(this);

	if(this.entnum >= 1 && this.entnum <= maxclients)
	{
		entity entcs = entcs_receiver(this.entnum - 1);
		Champions champ = entcs.m_champion;
		if(champ && champ.m_drawplayer)
			champ.m_drawplayer(champ, this);
	}
}

void CSQCModel_Hook_PreUpdate(entity this, bool isnew, bool isplayer, bool islocalplayer)
{
	// interpolate v_angle
	this.iflags |= IFLAG_V_ANGLE_X;
	// revert to values from server
	CSQCModel_Effects_PreUpdate(this);
	if((this.isplayermodel & ISPLAYER_MODEL))
		CSQCPlayer_ModelAppearance_PreUpdate(this);
}

void CSQCModel_Hook_PostUpdate(entity this, bool isnew, bool isplayer, bool islocalplayer)
{
	// is it a player model? (shared state)
	bool is_playermodel = (			substring(this.model, 0, 12) == "progs/player" || this.model == "progs/skater.mdl"
									|| substring(this.model, 0, 14) == "models/player/" || substring(this.model, 0, 17) == "models/ok_player/"
									|| this.model == "progs/eyes.mdl" || this.model == "progs/bolt2.mdl" || this.model == "progs/clockwork.mdl" || this.model == "progs/demon.mdl" || this.model == "progs/floyd.mdl"
									|| this.model == "progs/monkey.mdl" || this.model == "progs/mermaid.mdl"
									|| this.model == "models/player.iqm"
									|| (substring(this.model, 0, 16) == "models/monsters/" && (this.isplayermodel & BIT(1))));
	this.isplayermodel = BITSET(this.isplayermodel, ISPLAYER_MODEL, is_playermodel);

	// save values set by server
	if((this.isplayermodel & ISPLAYER_MODEL))
		CSQCPlayer_ModelAppearance_PostUpdate(this);

	CSQCModel_Effects_PostUpdate(this);

	if(isplayer && !is_playermodel)
		this.csqcmodel_isdead = true;
	else
		this.csqcmodel_isdead = false;
}
