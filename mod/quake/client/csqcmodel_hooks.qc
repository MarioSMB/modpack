#include "csqcmodel_hooks.qh"

#include "../common/effects/all.qh"
#include <lib/csqcmodel/cl_model.qh>
#include <lib/csqcmodel/cl_player.qh>
#include <lib/csqcmodel/interpolate.qh>

entityclass(Projectile);
classfield(Projectile).int traileffect;

classfield(Projectile).vector trail_oldorigin;
classfield(Projectile).float trail_oldtime;

classfield(Projectile).int cnt;   // sound index

.float alpha;

void Projectile_ResetTrail(entity this, vector to)
{
	this.trail_oldorigin = to;
	this.trail_oldtime = time;
}

void Projectile_DrawTrail(entity this, vector to)
{
	vector from = this.trail_oldorigin;
	// float t0 = this.trail_oldtime;
	this.trail_oldorigin = to;
	this.trail_oldtime = time;

	if (this.traileffect)
	{
		particles_alphamin = particles_alphamax = particles_fade = sqrt(this.alpha);
		boxparticles(particleeffectnum(REGISTRY_GET(Effects, this.traileffect)), this, from, to, this.velocity, this.velocity, 1, PARTICLES_USEALPHA | PARTICLES_USEFADE | PARTICLES_DRAWASTRAIL);
	}
}

void CSQCModel_Hook_PreDraw(entity this, bool isplayer);

.float death_time;
.int modelflags;

.bool isplayermodel;

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

	CSQCModel_Effects_Apply(this);
}

void CSQCModel_Hook_PreUpdate(entity this, bool isnew, bool isplayer, bool islocalplayer)
{
	// interpolate v_angle
	this.iflags |= IFLAG_V_ANGLE_X;
	// revert to values from server
	CSQCModel_Effects_PreUpdate(this);
}

void CSQCModel_Hook_PostUpdate(entity this, bool isnew, bool isplayer, bool islocalplayer)
{
	// is it a player model? (shared state)
	bool is_playermodel = (			substring(this.model, 0, 12) == "progs/player" || this.model == "progs/skater.mdl"
									|| substring(this.model, 0, 14) == "models/player/" || substring(this.model, 0, 17) == "models/ok_player/" || 
									(substring(this.model, 0, 16) == "models/monsters/" && (this.isplayermodel & BIT(1))));
	this.isplayermodel = BITSET(this.isplayermodel, ISPLAYER_MODEL, is_playermodel);

	CSQCModel_Effects_PostUpdate(this);

	if(isplayer && !is_playermodel)
		this.csqcmodel_isdead = true;
	else
		this.csqcmodel_isdead = false;
}
