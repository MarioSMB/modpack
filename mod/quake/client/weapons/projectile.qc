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

// kirby stars TODO
.float idle_finished;
void Star_Spawn(vector org, vector ang);

void Nimbus_Rain(vector org)
{
	if(vdist(view_origin - org, >=, 1024))
		return; // reduce lag!

	te_particlerain(org - '16 16 24', org + '16 16 8', '0 0 -400', floor(1 * drawframetime + random()), 12);
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
			case PROJECTILE_JIM_ROCKET:
			case PROJECTILE_DRILL:
				rot = '0 0 720'; // spinning
				break;
			case PROJECTILE_CROSSBOW_BOLT:
				rot = '0 0 290'; // spinning
				break;
			case PROJECTILE_GHOST_SICKLE:
				rot = '720 0 0' * bound(1, (time - this.spawntime), 3); // spinning
				break;
			case PROJECTILE_DEMON_SICKLE:
				rot = '0 1024 0'; // spinning
				break;
			case PROJECTILE_CAT:
			case PROJECTILE_EGG_NORMAL:
			case PROJECTILE_EGG_FIRE:
			case PROJECTILE_EGG_GRENADE:
			case PROJECTILE_EGG_ICE:
			case PROJECTILE_EGG_CLOCKWORK:
			case PROJECTILE_EGG_GOLD:
				// these projectiles are big and spammy so fade them in
				this.alphamod = (time - this.spawntime) * 5;
				break;
			case PROJECTILE_FEATHER:
				rot = '0 0 128'; // spinning
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
		case PROJECTILE_GHOST_SICKLE:
			makevectors(ang);
			trailorigin += v_up * 8 + v_forward * 5;
			break;
		case PROJECTILE_STAR_BOMB:
			makevectors(ang);
			trailorigin += v_up * 14;
			break;
		case PROJECTILE_DEMON_SICKLE:
			trailorigin.x += crandom() * 24;
			trailorigin.y += crandom() * 24;
			trailorigin.z += crandom() * 12;
			break;
		case PROJECTILE_EGG_FIRE:
		case PROJECTILE_EGG_ICE:
			makevectors(ang);
			trailorigin += v_up * 16;
			break;
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
		case PROJECTILE_STAR_SMALL:
		case PROJECTILE_STAR_MEDIUM:
		case PROJECTILE_STAR_LARGE:
		case PROJECTILE_STAR_MEGA:
		{
			if(time >= this.idle_finished && this.velocity != '0 0 0')
			{
				Star_Spawn(trailorigin, ang);
				this.idle_finished = time + (random() * 0.5);
			}
			break;
		}
		case PROJECTILE_STARFURY:
			// hack to make them look right
			this.angles_x = 0;
			break;
		case PROJECTILE_SWARM:
		{
			if(time >= this.idle_finished)
			{
				this.idle_finished = time + 0.1;
				CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
				this.frame += 1;
				if(this.frame < 7 || this.frame > 20)
					this.frame = 7;
				CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
			}
			CSQCModel_InterpolateAnimation_Do(this);
			break;
		}
		case PROJECTILE_GREEK_FIRE:
		{
			// hack to make them look right
			this.angles_x = 0;
			if(time >= this.idle_finished)
			{
				this.idle_finished = time + 0.1;
				CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
				this.frame += 1;
				if(this.frame > 5)
					this.frame = 0;
				CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
			}
			CSQCModel_InterpolateAnimation_Do(this);
			break;
		}
		case PROJECTILE_MOSS_HORNET:
		{
			if(time >= this.idle_finished)
			{
				this.idle_finished = time + 0.1;
				CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
				this.frame += 1;
				if(this.frame > 33)
					this.frame = 0;
				CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
			}
			CSQCModel_InterpolateAnimation_Do(this);
			break;
		}
		case PROJECTILE_NIMBUS:
		{
			Nimbus_Rain(trailorigin);
			if(time >= this.idle_finished)
			{
				this.idle_finished = time + 0.1;
				CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
				this.frame += 1;
				if(this.frame > 28 || this.frame < 19)
					this.frame = 19;
				CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
			}
			CSQCModel_InterpolateAnimation_Do(this);
			break;
		}
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
		if (this.csqcprojectile_type >= PROJECTILE_LETTER_START && this.csqcprojectile_type <= PROJECTILE_LETTER_END)
		{
			int letter = (this.csqcprojectile_type - PROJECTILE_LETTER_START) + 1;
			switch(letter)
			{
				case 1:  _setmodel(this, "progs/s_sns_a.spr"); break;
				case 2:  _setmodel(this, "progs/s_sns_b.spr"); break;
				case 3:  _setmodel(this, "progs/s_sns_c.spr"); break;
				case 4:  _setmodel(this, "progs/s_sns_d.spr"); break;
				case 5:  _setmodel(this, "progs/s_sns_e.spr"); break;
				case 6:  _setmodel(this, "progs/s_sns_f.spr"); break;
				case 7:  _setmodel(this, "progs/s_sns_g.spr"); break;
				case 8:  _setmodel(this, "progs/s_sns_h.spr"); break;
				case 9:  _setmodel(this, "progs/s_sns_i.spr"); break;
				case 10: _setmodel(this, "progs/s_sns_j.spr"); break;
				case 11: _setmodel(this, "progs/s_sns_k.spr"); break;
				case 12: _setmodel(this, "progs/s_sns_l.spr"); break;
				case 13: _setmodel(this, "progs/s_sns_m.spr"); break;
				case 14: _setmodel(this, "progs/s_sns_n.spr"); break;
				case 15: _setmodel(this, "progs/s_sns_o.spr"); break;
				case 16: _setmodel(this, "progs/s_sns_p.spr"); break;
				case 17: _setmodel(this, "progs/s_sns_q.spr"); break;
				case 18: _setmodel(this, "progs/s_sns_r.spr"); break;
				case 19: _setmodel(this, "progs/s_sns_s.spr"); break;
				case 20: _setmodel(this, "progs/s_sns_t.spr"); break;
				case 21: _setmodel(this, "progs/s_sns_u.spr"); break;
				case 22: _setmodel(this, "progs/s_sns_v.spr"); break;
				case 23: _setmodel(this, "progs/s_sns_w.spr"); break;
				case 24: _setmodel(this, "progs/s_sns_x.spr"); break;
				case 25: _setmodel(this, "progs/s_sns_y.spr"); break;
				default:
				case 26: _setmodel(this, "progs/s_sns_z.spr"); break;
			}
			this.traileffect = EFFECT_Null.m_id;
		}
		else switch (this.csqcprojectile_type)
		{
#define HANDLE(id) case PROJECTILE_##id: setmodel(this, MDL_PROJECTILE_##id);
			HANDLE(ROCKET)             this.traileffect = EFFECT_TR_ROCKET.m_id; break;
			HANDLE(MERMAID_BUBBLE)     this.traileffect = EFFECT_TR_BUBBLES.m_id; break;
			HANDLE(MAGIC_FIREBALL)     this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(CROSSBOW_BOLT)      this.traileffect = EFFECT_TR_GRENADE.m_id; break;
			HANDLE(VORE_SPIKE)         this.traileffect = EFFECT_TR_VORESPIKE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(SCRAG_SPIKE)        this.traileffect = EFFECT_TR_WIZSPIKE.m_id; break;
			HANDLE(KNIGHT_SPIKE)       this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; this.avelocity = '0 0 1' * ((random() * 500) + 150); break;
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
			HANDLE(HIP_LASER)          this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(PIANO_MUSIC)        this.traileffect = EFFECT_Null.m_id; this.avelocity = ((random() > 0.5) ? '0 -90 0' : '0 90 0'); break;
			HANDLE(LASER)              this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(JIM_LASER)          this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(JIM_ROCKET)         this.traileffect = EFFECT_TR_ROCKET.m_id; break;
			HANDLE(SNOWBALL)           this.traileffect = EFFECT_SNOWBALL_TRAIL.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(GOLDY)              this.traileffect = EFFECT_Null.m_id; this.avelocity = ((random() > 0.5) ? '0 -256 0' : '0 256 0'); break;
			HANDLE(CRUMB)              this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(SKAARJ_BULLET)      this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(GUG_BILEBOMB)       this.traileffect = EFFECT_TR_WIZSPIKE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(GUG_BILEFRAG)       this.traileffect = EFFECT_TR_WIZSPIKE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(DROLE)              this.traileffect = EFFECT_TR_ROCKET.m_id; this.avelocity = randomvec() * 100; break;
			HANDLE(DROLE_POISON)       this.traileffect = EFFECT_TR_WIZSPIKE.m_id; this.avelocity = randomvec() * 100; break;
			HANDLE(MULTI_ROCKET)       this.traileffect = EFFECT_TR_ROCKET.m_id; break;
			HANDLE(LAVABALL)           this.traileffect = EFFECT_TR_ROCKET.m_id; this.avelocity = '200 100 300'; break;
			HANDLE(EE_P_SPHERE)        this.traileffect = EFFECT_TR_ROCKET.m_id; this.avelocity = '200 100 300'; break;
			HANDLE(BLAZE_FIREBALL)     this.traileffect = EFFECT_TR_ROCKET.m_id; this.avelocity = '200 100 300'; this.scale = 0.7; break;
			HANDLE(LAVAMAN_FIREBALL)   this.traileffect = EFFECT_TR_ROCKET.m_id; this.avelocity = '200 100 300'; break;
			HANDLE(PASSIVE_FIREBALL)   this.traileffect = EFFECT_TR_ROCKET.m_id; break;
			HANDLE(PASSIVE_PULSERIFLE) this.traileffect = EFFECT_TR_CRYLINKPLASMA.m_id; break;
			HANDLE(TANK_BIGROCKET)     this.traileffect = EFFECT_TR_ROCKET.m_id; break;
			HANDLE(GHOST_SICKLE)       this.traileffect = EFFECT_TR_SICKLE.m_id; this.avelocity = '720 0 0'; break;
			HANDLE(CACODEMON_FIREBALL) this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; break;
			HANDLE(MISSILE)            this.traileffect = EFFECT_TR_ROCKET.m_id; this.avelocity = '0 0 -540'; break;
			HANDLE(MANCUBUS_BOLT)      this.traileffect = EFFECT_Null.m_id; this.avelocity = '0 0 -540'; break;
			HANDLE(BULLETKIN_SHOT)     this.traileffect = EFFECT_Null.m_id; this.avelocity = '200 100 300'; break;
			HANDLE(HELLKNIGHT_BIGSHOT) this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; this.avelocity = '0 0 1' * ((random() * 500) + 150); break;
			HANDLE(HELLKNIGHT_SPINNER) this.traileffect = EFFECT_Null.m_id; this.avelocity = '720 0 0'; this.scale = 2; break;
			HANDLE(STAR_SMALL)         this.traileffect = EFFECT_TR_STAR.m_id; this.avelocity = '256 0 0'; this.scale = 1; break;
			HANDLE(STAR_MEDIUM)        this.traileffect = EFFECT_TR_STAR.m_id; this.avelocity = '184 0 0'; this.scale = 2.5; break;
			HANDLE(STAR_LARGE)         this.traileffect = EFFECT_TR_STAR.m_id; this.avelocity = '112 0 0'; this.scale = 5; break;
			HANDLE(STAR_MEGA)          this.traileffect = EFFECT_TR_STAR.m_id; this.avelocity = '64 0 0'; this.scale = 20; break;
			HANDLE(SPARK_UPZAP)        this.traileffect = EFFECT_TR_NEXUIZPLASMA.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(SEED)               this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(SEED_POISON)        this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(THORNBALL)          this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(STAR_BOMB)          this.traileffect = EFFECT_TR_GRENADE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(VORTEX_ROCKET)      this.traileffect = EFFECT_TR_VORTEX_ROCKET.m_id; break;
			HANDLE(FROSTSHARD)         this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(EOW_SPIT)           this.traileffect = EFFECT_TR_WIZSPIKE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(VIOLIN_MUSIC)       this.traileffect = EFFECT_Null.m_id; this.avelocity = '90 0 0'; break;
			HANDLE(STARFURY)           this.traileffect = EFFECT_TR_VORESPIKE.m_id; this.avelocity = '0 0 120'; break;
			HANDLE(BLIZZARD_SHARD)     this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(DEMON_SICKLE)       this.traileffect = EFFECT_TR_SICKLE.m_id; this.avelocity = '0 1024 0'; break;
			HANDLE(ICE_SPEAR)          this.traileffect = EFFECT_Null.m_id; this.avelocity = '0 0 -15'; break;
			HANDLE(ICICLE)             this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(MORTAR)             this.traileffect = EFFECT_TR_GRENADE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(SWARM)              this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(FROG_SPIT)          this.traileffect = EFFECT_TR_WIZSPIKE.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(BOWLING_BALL)       this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(COOKIE)             this.traileffect = EFFECT_TR_GRENADE.m_id; break;
			HANDLE(FLAK_CANNON)        this.traileffect = EFFECT_TR_GRENADE.m_id; this.scale = 0.5; break;
			HANDLE(RECYCLEBIN)         this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(MIME_BALL)          this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; this.scale = 0.75; break;
			HANDLE(GRAPE)              this.traileffect = EFFECT_Null.m_id; this.avelocity = randomvec() * 200; break;
			HANDLE(BOGLORD)            this.traileffect = EFFECT_TR_WIZSPIKE.m_id; this.frame = 7; break;
			HANDLE(BOGLORD_STRONG)     this.traileffect = EFFECT_TR_WIZSPIKE.m_id; this.frame = 7; break;
			HANDLE(DFURY_MAGICA)       this.traileffect = EFFECT_TR_WIZSPIKE.m_id; break;
			HANDLE(DFURY_MAGICB)       this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; this.avelocity = randomvec() * 200; break;
			HANDLE(GARGOYLE)           this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; break;
			HANDLE(GARGOYLE_POISON)    this.traileffect = EFFECT_TR_WIZSPIKE.m_id; break;
			HANDLE(GREEK_FIRE)         this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(FLAME_WOOD)         this.traileffect = EFFECT_TR_GRENADE.m_id; this.avelocity_z = random() * 90; break;
			HANDLE(PLASMA)             this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; break;
			HANDLE(MINOTAUR_PLASMA)    this.traileffect = EFFECT_SNOWBALL_TRAIL.m_id; break;
			HANDLE(MINOTAUR_BLOOD)     this.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; break;
			HANDLE(MINOTAUR_POISON)    this.traileffect = EFFECT_TR_WIZSPIKE.m_id; break;
			HANDLE(GAUNT_PLASMA)       this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(GAUNT_POISON)       this.traileffect = EFFECT_TR_WIZSPIKE.m_id; break;
			HANDLE(SMG)                this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(DRILL)              this.traileffect = EFFECT_TR_DRILL.m_id; break;
			HANDLE(EGG_NORMAL)         this.traileffect = EFFECT_Null.m_id; this.scale = 0.6; break;
			HANDLE(EGG_FIRE)           this.traileffect = EFFECT_TR_GRENADE.m_id; this.scale = 0.6; break;
			HANDLE(EGG_GRENADE)        this.traileffect = EFFECT_Null.m_id; this.scale = 0.6; break;
			HANDLE(EGG_ICE)            this.traileffect = EFFECT_TR_DRILL.m_id; this.scale = 0.6; break;
			HANDLE(EGG_CLOCKWORK)      this.traileffect = EFFECT_Null.m_id; this.scale = 0.6; break;
			HANDLE(EGG_GOLD)           this.traileffect = EFFECT_Null.m_id; this.scale = 0.6; break;
			HANDLE(FEATHER)            this.traileffect = EFFECT_Null.m_id; this.angles_z =  random() * 360; break;
			HANDLE(MOSS_HORNET)        this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(SLIME)              this.traileffect = EFFECT_Null.m_id; this.scale = 0.7; break;
			HANDLE(NIMBUS)             this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(CAN)                this.traileffect = EFFECT_Null.m_id; this.avelocity = '180 0 0'; break;
			HANDLE(CAN_SMALL)          this.traileffect = EFFECT_Null.m_id; this.scale = 0.25; this.avelocity = '360 0 0'; break;
			HANDLE(BULLET_BILL)        this.traileffect = EFFECT_TR_ROCKET.m_id; break;
			HANDLE(BULLSEYE_BILL)      this.traileffect = EFFECT_TR_ROCKET.m_id; break;
			HANDLE(MIMEJR_BALL)        this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; this.scale = 0.35; break;
			HANDLE(PEA)                this.traileffect = EFFECT_Null.m_id; this.avelocity = randomvec() * 200; break;
			HANDLE(SNOWPEA)            this.traileffect = EFFECT_SNOWBALL_TRAIL.m_id; this.avelocity = randomvec() * 200; break;
			HANDLE(PLASMA_CANNON)      this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(ALIEN_SNIPER)       this.traileffect = EFFECT_Null.m_id; break;
			HANDLE(COCONUT)            this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 0 0'; break;
			HANDLE(BFG)                this.traileffect = EFFECT_Null.m_id; this.avelocity = '300 300 300'; break;
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

		if (this.csqcprojectile_type >= PROJECTILE_LETTER_START && this.csqcprojectile_type <= PROJECTILE_LETTER_END)
		{
			set_movetype(this, MOVETYPE_BOUNCE);
			this.effects |= EF_FULLBRIGHT;
			settouch(this, func_null);
		}
		else switch (this.csqcprojectile_type)
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
			case PROJECTILE_HIP_LASER:
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
			case PROJECTILE_LASER:
			case PROJECTILE_JIM_LASER:
			case PROJECTILE_MANCUBUS_BOLT:
			case PROJECTILE_PLASMA_CANNON:
			case PROJECTILE_ALIEN_SNIPER:
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_DIMLIGHT;
				break;
			case PROJECTILE_SNOWBALL:
				this.gravity = 0.5;
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_GOLDY:
				this.gravity = 1;
				this.effects |= EF_FULLBRIGHT;
				this.mins = '-8 -8 -8';
				this.maxs = '8 8 8';
				break;
			case PROJECTILE_CRUMB:
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				this.gravity = 1;
				this.bouncefactor = 0.5;
				this.bouncestop = 0.125;
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_GUG_BILEFRAG:
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				break;
			case PROJECTILE_MULTI_ROCKET:
				this.frame = floor(random() * 4);
				break;
			case PROJECTILE_LAVAMAN_FIREBALL:
				set_movetype(this, MOVETYPE_TOSS);
				this.gravity = 1;
				break;
			case PROJECTILE_PASSIVE_FIREBALL:
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				this.mins = '-4 -4 -4';
				this.maxs = '4 4 4';
				this.bouncefactor = 1;
				break;
			case PROJECTILE_GHOST_SICKLE:
				set_movetype(this, MOVETYPE_FLYMISSILE);
				settouch(this, func_null);
				this.solid = SOLID_NOT;
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_ADDITIVE;
				this.dphitcontentsmask = DPCONTENTS_DONOTENTER;
				break;
			case PROJECTILE_KNIGHT_SPIKE:
			case PROJECTILE_BULLETKIN_SHOT:
			case PROJECTILE_HELLKNIGHT_SPINNER:
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_HELLKNIGHT_BIGSHOT:
				this.dphitcontentsmask = DPCONTENTS_SOLID;
				this.effects |= EF_FULLBRIGHT;
				//this.effects |= EF_ADDITIVE;
				this.solid = SOLID_TRIGGER;
				break;
			case PROJECTILE_STAR_SMALL:
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_DIMLIGHT;
				break;
			case PROJECTILE_STAR_MEDIUM:
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_DIMLIGHT;
				this.mins = '-4 -4 -4';
				this.maxs = '4 4 4';
				break;
			case PROJECTILE_STAR_LARGE:
				this.dphitcontentsmask = DPCONTENTS_SOLID;
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_BRIGHTLIGHT;
				//this.effects |= EF_ADDITIVE;
				this.solid = SOLID_TRIGGER;
				break;
			case PROJECTILE_STAR_MEGA:
				set_movetype(this, MOVETYPE_NOCLIP);
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_BRIGHTLIGHT;
				this.effects |= EF_ADDITIVE;
				this.effects |= EF_NODEPTHTEST;
				this.solid = SOLID_TRIGGER;
				settouch(this, func_null);
				break;
			case PROJECTILE_SPARK_UPZAP:
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_DIMLIGHT;
				break;
			case PROJECTILE_SEED_POISON:
				this.skin = 1;
			case PROJECTILE_SEED:
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_THORNBALL:
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				this.solid = SOLID_TRIGGER;
				this.mins = '-10 -10 -10';
				this.maxs = '10 10 10';
				this.bouncefactor = 0.7;
				this.bouncestop = 0.075;
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_STAR_BOMB:
				loopsound(this, CH_SHOTS_SINGLE, SND_BOMB_FUSE, VOL_BASE, ATTEN_NORM);
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				this.effects |= EF_FULLBRIGHT;
				this.mins = '-14 -14 -14';
				this.maxs = '14 14 14';
				this.bouncefactor = 0.25;
				this.bouncestop = 0.001;
				break;
			case PROJECTILE_VIOLIN_MUSIC:
				set_movetype(this, MOVETYPE_TOSS);
				this.gravity = -1;
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_STARFURY:
				this.effects |= EF_DIMLIGHT;
				this.solid = SOLID_NOT;
				set_movetype(this, MOVETYPE_NOCLIP);
				settouch(this, func_null);
				break;
			case PROJECTILE_BLIZZARD_SHARD:
				this.effects |= EF_FULLBRIGHT;
				this.solid = SOLID_NOT;
				set_movetype(this, MOVETYPE_NOCLIP);
				settouch(this, func_null);
				break;
			case PROJECTILE_DEMON_SICKLE:
				set_movetype(this, MOVETYPE_FLYMISSILE);
				settouch(this, func_null);
				this.solid = SOLID_TRIGGER;
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_ADDITIVE;
				this.dphitcontentsmask = DPCONTENTS_SOLID;
				break;
			case PROJECTILE_ICE_SPEAR:
				this.dphitcontentsmask = DPCONTENTS_SOLID;
				this.solid = SOLID_TRIGGER;
				set_movetype(this, MOVETYPE_TOSS);
				settouch(this, func_null);
				this.gravity = 0.45;
				break;
			case PROJECTILE_ICICLE:
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_MORTAR:
				set_movetype(this, MOVETYPE_TOSS);
				this.gravity = 1;
				break;
			case PROJECTILE_SWARM:
				set_movetype(this, MOVETYPE_FLYMISSILE);
				this.effects |= EF_FULLBRIGHT;
				this.solid = SOLID_TRIGGER;
				settouch(this, func_null);
				break;
			case PROJECTILE_BOWLING_BALL:
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				this.effects |= EF_FULLBRIGHT;
				this.bouncefactor = 0.99;
				this.bouncestop = 0.01;
				break;
			case PROJECTILE_RECYCLEBIN:
				set_movetype(this, MOVETYPE_TOSS);
				this.gravity = 1;
				break;
			case PROJECTILE_MIME_BALL:
			case PROJECTILE_MIMEJR_BALL:
				set_movetype(this, MOVETYPE_BOUNCE);
				settouch(this, func_null);
				this.bouncefactor = 1;
				this.bouncestop = 0.1;
				vector mimecolor;
				mimecolor.x = max(0.25, random() * 5);
				mimecolor.y = max(0.25, random() * 5);
				mimecolor.z = max(0.25, random() * 5);
				this.colormod = mimecolor;
				break;
			case PROJECTILE_GREEK_FIRE:
				set_movetype(this, MOVETYPE_TOSS);
				settouch(this, func_null);
				this.gravity = 0.3;
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_NOSELFSHADOW;
				this.effects |= EF_NOSHADOW;
				break;
			case PROJECTILE_FLAME_WOOD:
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_NOSELFSHADOW;
				this.effects |= EF_NOSHADOW;
				break;
			case PROJECTILE_PLASMA:
				loopsound(this, CH_SHOTS_SINGLE, SND_PLASMA_FLIGHT, VOL_BASE, ATTEN_NORM);
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_BRIGHTLIGHT;
				break;
			case PROJECTILE_MINOTAUR_PLASMA:
			case PROJECTILE_MINOTAUR_BLOOD:
			case PROJECTILE_MINOTAUR_POISON:
				this.effects |= EF_FULLBRIGHT;
				//this.effects |= EF_BRIGHTLIGHT;
				break;
			case PROJECTILE_GAUNT_PLASMA:
			case PROJECTILE_GAUNT_POISON:
				this.effects |= EF_FULLBRIGHT;
				//this.effects |= EF_BRIGHTLIGHT;
				break;
			case PROJECTILE_SMG:
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_DRILL:
				this.dphitcontentsmask = DPCONTENTS_SOLID;
				this.solid = SOLID_TRIGGER;
				set_movetype(this, MOVETYPE_FLYMISSILE);
				settouch(this, func_null);
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_EGG_NORMAL:
				this.skin = 0;
				break;
			case PROJECTILE_EGG_FIRE:
				this.skin = 1;
				break;
			case PROJECTILE_EGG_GRENADE:
				this.skin = 2;
				break;
			case PROJECTILE_EGG_ICE:
				this.skin = 3;
				break;
			case PROJECTILE_EGG_CLOCKWORK:
				this.skin = 4;
				set_movetype(this, MOVETYPE_TOSS);
				break;
			case PROJECTILE_EGG_GOLD:
				this.skin = 5;
				break;
			case PROJECTILE_MOSS_HORNET:
				set_movetype(this, MOVETYPE_FLYMISSILE);
				this.effects |= EF_FULLBRIGHT;
				this.solid = SOLID_TRIGGER;
				settouch(this, func_null);
				break;
			case PROJECTILE_SLIME:
				set_movetype(this, MOVETYPE_TOSS);
				this.gravity = 1;
				break;
			case PROJECTILE_NIMBUS:
				set_movetype(this, MOVETYPE_FLYMISSILE);
				this.effects |= EF_FULLBRIGHT;
				this.solid = SOLID_TRIGGER;
				settouch(this, func_null);
				break;
			case PROJECTILE_CAN:
				set_movetype(this, MOVETYPE_NOCLIP);
				setsize(this, '-48 -48 0', '48 48 48');
				this.solid = SOLID_TRIGGER;
				settouch(this, func_null);
				break;
			case PROJECTILE_CAN_SMALL:
				set_movetype(this, MOVETYPE_NOCLIP);
				setsize(this, '-12 -12 0', '12 12 12');
				this.solid = SOLID_TRIGGER;
				settouch(this, func_null);
				break;
			case PROJECTILE_COCONUT:
				this.effects |= EF_FULLBRIGHT;
				break;
			case PROJECTILE_BFG:
				this.effects |= EF_FULLBRIGHT;
				this.effects |= EF_DIMLIGHT;
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
