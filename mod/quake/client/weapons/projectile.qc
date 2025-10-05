#include "projectile.qh"

#include <lib/warpzone/anglestransform.qh>

.float alpha;
.float scale;
.vector colormod;

.int csqcprojectile_type;

void music_bounce(entity this, entity toucher)
{
	vector col = this.colormod;
	this.colormod.x = col.z;
	this.colormod.y = col.y;
	this.colormod.z = col.z;
	settouch(this, func_null);
}

void SUB_Stop(entity this, entity toucher)
{
	this.velocity = this.avelocity = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
}

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

	// force the effect even for stationary firemine
	//if (this.csqcprojectile_type == PROJECTILE_FIREMINE)
		//if (from == to)
			//from.z += 1;

	// Note: alpha value 0 actually means 1 on entities.
	// This can be relevant when coming from CSQCModel_Effects_Apply.
	float a = (this.alpha == 0) ? 1 : this.alpha;

	// TODO: Do we actually need alpha support? Consider removing this
	// support entirely and instead making necessary adjustments in
	// effectinfo.
	//
	// Right now (2024-12-30), only Crylink can generate alpha via
	// fade_rate/fade_time, and only PROJECTILE_PORTO_* set a fixed alpha
	// (and reuse the Arc's TE_WIZSPIKE).
	if (this.traileffect && a > 0)
	{
		float f = PARTICLES_DRAWASTRAIL;
		if (a < 1)
		{
			// Do some of the fading using particle count, and some of it using alpha.
			// Fading by particle count is less smooth but also cheaper to render.
			// A higher power here performs more of the fading using particle count.
			const float fade_power = 0.5;
			particles_fade = pow(a, fade_power);
			particles_alphamin = particles_alphamax = a / particles_fade;  // == pow(a, 1 - fade_power)
			f |= PARTICLES_USEALPHA | PARTICLES_USEFADE;
			//LOG_INFOF("particle fade: %f alpha: %f", particles_fade, particles_alphamin);
		}
		//else
		//	LOG_INFOF("particle fade skipped");

		if (this.colormod != '0 0 0')
		{
			particles_colormin = particles_colormax = this.colormod;
			f |= PARTICLES_USECOLOR;
		}
		else if (this.colormap > 0)
		{
			particles_colormin = colormapPaletteColor(floor(this.colormap / 16), false);
			particles_colormax = colormapPaletteColor(this.colormap % 16, true);
		}

		entity eff = REGISTRY_GET(Effects, this.traileffect);
		if(!SpawnParticles_list_full(strcat("cl_particle_", eff.eent_eff_name), from, to, this.velocity, this.velocity, 1, true, f | PARTICLES_USECOLOR))
			boxparticles(particleeffectnum(eff), this, from, to, this.velocity, this.velocity, 1, f);
	}
}

void Projectile_Draw(entity this)
{
	vector rot;
	vector trailorigin;
	int f;
	bool drawn;
	float t;
	float a;

	f = this.flags;

	if (this.count & 0x80)
	{
		// UNSET_ONGROUND(this);
		if (this.move_movetype == MOVETYPE_NONE || this.move_movetype == MOVETYPE_FLY)
			Movetype_Physics_NoMatchServer(this);
		// the trivial movetypes do not have to match the
		// server's ticrate as they are ticrate independent
		// NOTE: this assumption is only true if MOVETYPE_FLY
		// projectiles detonate on impact. If they continue
		// moving, we might still be ticrate dependent.
		else
			Movetype_Physics_MatchServer(this, autocvar_cl_projectiles_sloppy);
		if (!IS_ONGROUND(this))
			if (this.velocity != '0 0 0')
				this.angles = vectoangles(this.velocity);
	}
	else
	{
		InterpolateOrigin_Do(this);
	}

	if (this.count & 0x80)
	{
		drawn = (time >= this.spawntime - 0.02);
		t = max(time, this.spawntime);
	}
	else
	{
		drawn = (this.iflags & IFLAG_VALID);
		t = time;
	}

	if (!(f & FL_ONGROUND))
	{
		rot = this.avelocity;
		switch (this.csqcprojectile_type)
		{
			default: break;
			case PROJECTILE_ROCKET:
				rot = '0 0 720'; // spinning
				break;
			case PROJECTILE_CROSSBOW_BOLT:
				rot = '0 0 290'; // spinning
				break;
		}

		if (rot)
		{
			if (!rot.x && !rot.y)
			{
				// cheaper z-only rotation formula
				this.angles.z = (rot.z * (t - this.spawntime)) % 360;
				if (this.angles.z < 0)
					this.angles.z += 360;
			}
			else
				this.angles = AnglesTransform_ToAngles(AnglesTransform_Multiply(AnglesTransform_FromAngles(this.angles), rot * (t - this.spawntime)));
		}
	}

	// negation used to ensure a zero fade_(time/rate) does not affect opacity
	a = 1 - (time - this.fade_time) * this.fade_rate;
	this.alpha = bound(0, this.alphamod * a, 1);
	if (this.alpha <= 0)
		drawn = 0;
	this.renderflags = 0;

	vector ang = this.angles;
	ang.x = -ang.x;
	trailorigin = this.origin;
	switch (this.csqcprojectile_type)
	{
		default: break;
		//case PROJECTILE_GRENADE:
			//makevectors(ang);
			//trailorigin += v_right * 1 + v_forward * -10;
			//break;
	}

	if (drawn)
		Projectile_DrawTrail(this, trailorigin);
	else
		Projectile_ResetTrail(this, trailorigin);

	this.drawmask = 0;

	if (!drawn)
		return;

	switch (this.csqcprojectile_type)
	{
		// Possibly add dlights here.
		default:
			break;
	}

	this.drawmask = MASK_NORMAL;
}

void loopsound(entity e, int ch, Sound samp, float vol, float attn)
{
	TC(int, ch);
	if (e.silent)
		return;

	sound(e, ch, samp, vol, attn);
	e.snd_looping = ch;
}

void Ent_RemoveProjectile(entity this)
{
	if (this.count & 0x80)
	{
		tracebox(this.origin, this.mins, this.maxs, this.origin + this.velocity * 0.05, MOVE_NORMAL, this);
		Projectile_DrawTrail(this, trace_endpos);
	}
}

NET_HANDLE(ENT_CLIENT_PROJECTILE, bool isnew)
{
	// projectile properties:
	//   kind (interpolated, or clientside)
	//
	//   modelindex
	//   origin
	//   scale
	//   if clientside:
	//     velocity
	//     gravity
	//   soundindex (hardcoded list)
	//   effects
	//
	// projectiles don't send angles, because they always follow the velocity

	int f = ReadByte();
	this.count = (f & 0x80);
	this.flags |= FL_PROJECTILE;
	this.iflags = (this.iflags & IFLAG_INTERNALMASK) | IFLAG_AUTOANGLES | IFLAG_ANGLES | IFLAG_ORIGIN;
	this.solid = SOLID_TRIGGER;
	// this.effects = EF_NOMODELFLAGS;

	// this should make collisions with bmodels more exact, but it leads to
	// projectiles no longer being able to lie on a bmodel
	this.move_nomonsters = MOVE_WORLDONLY;
	if (f & 0x40)
		SET_ONGROUND(this);
	else
		UNSET_ONGROUND(this);

	this.silent = (f & 4);

	if (!this.move_time)
	{
		// for some unknown reason, we don't need to care for
		// sv_gameplayfix_delayprojectiles here.
		this.move_time = time;
		this.spawntime = time;
	}
	else
	{
		this.move_time = max(this.move_time, time);
	}

	if (!(this.count & 0x80))
		InterpolateOrigin_Undo(this);

	if (f & 1)
	{
		this.origin = ReadVector();
		setorigin(this, this.origin);
		if (this.count & 0x80)
		{
			this.velocity = ReadVector();
			if (f & 0x10)
				this.gravity = ReadCoord();
			else
				this.gravity = 0;  // none
		}

		if (time == this.spawntime || (this.count & 0x80) || (f & 0x08))
		{
			this.trail_oldorigin = this.origin;
			if (!(this.count & 0x80))
				InterpolateOrigin_Reset(this);
		}

		if (f & 0x20)
		{
			float fadetime = ReadByte();
			float faderate = ReadByte();

			// workaround for division by 0
			// TODO: apply fade settings WITHOUT ticrate here and multiply during use cases
			if(ticrate <= 0)
			{
				this.fade_time = 0;
				this.fade_rate = 0;
			}
			else
			{
				this.fade_time = time + fadetime * ticrate;
				this.fade_rate = 1 / (faderate * ticrate);
			}
		}
		else
		{
			this.fade_time = 0;
			this.fade_rate = 0;
		}

		int proj_team = ReadByte();

		this.colormap = proj_team;
		// TODO: projectiles use glowmaps for their color, not teams
		#if 0
		if(this.colormap > 0)
			this.glowmod = colormapPaletteColor(this.colormap & 0x0F, true);
		else
			this.glowmod = '1 1 1';
		#endif
	}

	if (f & 2)
	{
		this.csqcprojectile_type = ReadByte();

		this.scale = 1;
		this.traileffect = 0;
		switch (this.csqcprojectile_type)
		{
#define HANDLE(id) case PROJECTILE_##id: setmodel(this, MDL_PROJECTILE_##id);
			HANDLE(ROCKET)             this.traileffect = EFFECT_TR_ROCKET.m_id; break;
			HANDLE(MERMAID_BUBBLE)     this.traileffect = EFFECT_TR_BUBBLES.m_id; break;
			HANDLE(MAGIC_FIREBALL)     this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(CROSSBOW_BOLT)      this.traileffect = EFFECT_TR_GRENADE.m_id; break;
			HANDLE(VORE_SPIKE)         this.traileffect = EFFECT_TR_VORESPIKE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(SCRAG_SPIKE)        this.traileffect = EFFECT_TR_WIZSPIKE.m_id; break;
			HANDLE(KNIGHT_SPIKE)       this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; break;
			HANDLE(SPELLBOOK_METEOR)   this.traileffect = EFFECT_TR_METEOR.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(CAT)                this.traileffect = EFFECT_MEOWMERE_TRAIL.m_id; break;
			HANDLE(BANJO_MUSIC)        this.traileffect = EFFECT_Null.m_id; this.avelocity = '0 90 90'; break;
			HANDLE(BULLET)             this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(SAWBLADE)           this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(SUPER_SPIKE)        this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(LAVA_NAIL)          this.traileffect = EFFECT_TR_GRENADE.m_id; break;
			HANDLE(BIOGUN_BONESHARD)   this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(GRENADE)            this.traileffect = EFFECT_TR_GRENADE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(MAYO)               this.traileffect = EFFECT_TR_GRENADE.m_id; this.avelocity = randomvec() * 320; this.scale = 0.5; break;
			HANDLE(OCARINA)            this.traileffect = EFFECT_Null.m_id; this.avelocity = '0 90 90'; this.scale = 0.5; break;
			HANDLE(SHOCKGUN_PLASMA)    this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(LASER)              this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(PIANO_MUSIC)        this.traileffect = EFFECT_Null.m_id; this.avelocity = ((random() > 0.5) ? '0 -90 0' : '0 90 0'); break;
#undef HANDLE
			default:
				error("Received invalid CSQC projectile, can't work with this!");
				break;
		}

		this.mins = '0 0 0';
		this.maxs = '0 0 0';
		this.colormod = '0 0 0';
		settouch(this, SUB_Stop);
		set_movetype(this, MOVETYPE_TOSS);
		this.alphamod = 1;

		switch (this.csqcprojectile_type)
		{
			// TODO?
			//case PROJECTILE_ROCKET:
				//loopsound(this, CH_SHOTS_SINGLE, SND_DEVASTATOR_FLY, VOL_BASE, ATTEN_NORM);
				//this.mins = '-3 -3 -3';
				//this.maxs = '3 3 3';
				//break;
			case PROJECTILE_CROSSBOW_BOLT:
				this.solid = SOLID_NOT;
				break;
			case PROJECTILE_CAT:
				this.dphitcontentsmask = DPCONTENTS_SOLID;
				this.solid = SOLID_TRIGGER;
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				this.bouncefactor = 1;
				this.bouncestop = 0.1;
				this.gravity = 0.25;
				break;
			case PROJECTILE_BANJO_MUSIC:
				this.colormod = (random() < 0.1) ? '0.8 0.35 0' : '0.9 0.22 0.24';
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_SAWBLADE:
				set_movetype(this, MOVETYPE_BOUNCEMISSILE);
				settouch(this, func_null);
				break;
			case PROJECTILE_GRENADE:
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				break;
			case PROJECTILE_OCARINA:
				this.colormod = '0.1 0.1 1';
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_SHOCKGUN_PLASMA:
				this.effects |= EF_DIMLIGHT;
				break;
			case PROJECTILE_LASER:
				set_movetype(this, MOVETYPE_BOUNCEMISSILE);
				settouch(this, func_null);
				break;
			case PROJECTILE_PIANO_MUSIC:
				this.effects |= EF_FULLBRIGHT;
				vector mycolor = '1 1 0';
				if(random() < 0.5)
				{
					mycolor.x = max(0.25, random() * 5);
					mycolor.y = max(0.25, random() * 5);
					mycolor.z = max(0.25, random() * 5);
				}
				this.colormod = mycolor;
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, music_bounce);
				break;
			default:
				break;
		}

		setsize(this, this.mins, this.maxs);
	}

	return = true;

	if (this.gravity)
	{
		if (this.move_movetype == MOVETYPE_FLY)
			set_movetype(this, MOVETYPE_TOSS);
		if (this.move_movetype == MOVETYPE_BOUNCEMISSILE)
			set_movetype(this, MOVETYPE_BOUNCE);
	}
	else
	{
		if (this.move_movetype == MOVETYPE_TOSS)
			set_movetype(this, MOVETYPE_FLY);
		if (this.move_movetype == MOVETYPE_BOUNCE)
			set_movetype(this, MOVETYPE_BOUNCEMISSILE);
	}

	if (!(this.count & 0x80))
		InterpolateOrigin_Note(this);

	this.draw = Projectile_Draw;
	if (isnew) IL_PUSH(g_drawables, this);
	this.entremove = Ent_RemoveProjectile;
}
