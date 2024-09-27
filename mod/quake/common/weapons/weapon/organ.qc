#include "organ.qh"

#ifdef SVQC
const int organ_anim_idle = 1; // frame 0 is a skin pose
const int organ_anim_die = 2; //'2 31 0'
const int organ_anim_dead = 33;

PRECACHE(Organ)
{
	precache_model("progs/v_organ.mdl");
	precache_model("progs/g_organ.mdl");
}

void organ_deadthink(entity this)
{
	this.frame += 1;
	if(this.frame > 32)
	{
		this.frame = organ_anim_dead;
		SUB_SetFade(this, time + 0.1, 3);
		return;
	}

	this.nextthink = time + 0.05;
	setthink(this, organ_deadthink);
}

void organ_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.solid = SOLID_NOT;
	this.takedamage = DAMAGE_NO;
	this.monster_attack = false;
	this.frame = organ_anim_die;
	setthink(this, organ_deadthink);
	this.nextthink = time;
	Send_Effect(EFFECT_SMOKE_RING, this.origin + '0 0 8', '0 0 50', 1);
	sound(this, CH_VOICE, SND_ORGAN_EXPLODE, 1, ATTN_NORM);

	music_reset(this);
}

void organ_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 1;

	sound(this, CH_VOICE, SND_ORGAN_LAND, 1, ATTN_NORM);
}

void organ_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 17;
	float damg = mydmg + random() * mydmg;
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	//sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	//this.origin = this.origin - 8 * normalize(this.velocity);
	this.origin = findbetterlocation(this.origin, 8);

	BecomeCartoonExplosion(this);
}

void organ_note_spreadout(entity this)
{
	if(time > this.count)
	{
		BecomeCartoonExplosion(this);
		return;
	}
	entity selected = W_PickNearbyTarget(this, 500, false, false);
	if(selected)
	{
		vector targ_pos = (selected.absmin + selected.absmax) * 0.5;
		vector dir = normalize(targ_pos - this.origin);
		this.velocity = dir * 800;
		this.avelocity = '0 0 0';
		setthink(this, BecomeCartoonExplosion);
		this.nextthink = time + 5;
	}
	else
		this.nextthink = time + 0.15;
}

void organ_note_think(entity this)
{
	if(time > this.wait)
	{
		organ_note_spreadout(this);
		return;
	}

	this.avelocity = '0 45 45';

	// Randomly drift upwards and slow down forward movement
	if(vdist(this.velocity, >, 50))
	{
		//this.velocity_z += 2 + (random() * 10);
		this.velocity -= (this.movedir * 0.125);
	}
	this.nextthink = time + 0.1;
}

void organ_fire(entity this)
{
	vector neworg = this.origin + '0 0 8';
	float organ_count = 6;
	makevectors(this.angles);
	for(int j = 0; j < organ_count; ++j)
	{
		// copied from piano
		entity musicnote = spawn();
		musicnote.owner = this.realowner;
		set_movetype(musicnote, MOVETYPE_FLYMISSILE);
		//musicnote.solid = SOLID_BBOX;
		musicnote.effects = EF_FULLBRIGHT;
		musicnote.solid = SOLID_CORPSE;
		musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
		musicnote.classname = "tubanote";
		musicnote.projectiledeathtype = WEP_ORGAN.m_id;

		musicnote.angles = '0 1 0' * this.angles_y;

		musicnote.count = time + 3; // lifetime of the floating projectile
		musicnote.wait = time + 1.75; // Spreadout time
		musicnote.nextthink = time + 0.1;
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, organ_note_think);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = '0.95 0.90 0.85';
		setsize(musicnote, '0 0 0', '0 0 0');

		setorigin(musicnote, neworg);
		settouch(musicnote, organ_note_touch);

		vector dir = v_forward + (((j + 0.5) / organ_count) * 2 - 1) * v_right;
		vector spread_dir = dir;
		musicnote.movedir = spread_dir * 150 + v_up * 20;
		musicnote.velocity = musicnote.movedir;
	}

	float r = W_Music_PitchFromAngles(this.v_angle_x, bound(0.8, random() * 2, 1.3));
	r *= 1; // TODO: per-instrument offsets
	sound7(this, CH_WEAPON_SINGLE, SND(ORGAN_FIRE), 1, ATTN_NORM, r, 0);
}

void organ_think(entity this)
{
	setthink(this, organ_think);
	this.nextthink = time;

	if(this.wait && time > this.wait)
	{
		organ_die(this, NULL, NULL, DEATH_GENERIC.m_id);
		return;
	}

	.entity weaponentity = weaponentities[0];
	if(IS_PLAYER(this.realowner) && this.realowner.(weaponentity) && this.realowner.(weaponentity).music_song != this.(weaponentity).music_song)
	{
		this.(weaponentity).music_pos = this.realowner.(weaponentity).music_pos;
		this.(weaponentity).music_speed = this.realowner.(weaponentity).music_speed;
		this.(weaponentity).music_nextnote = this.realowner.(weaponentity).music_nextnote;
		this.(weaponentity).music_repeatstart = this.realowner.(weaponentity).music_repeatstart;
		this.(weaponentity).music_repeatend = this.realowner.(weaponentity).music_repeatend;
		this.(weaponentity).music_starttime = time;
		strcpy(this.(weaponentity).music_song, this.realowner.(weaponentity).music_song);
	}

	if(time < this.attack_finished)
		return;

	bool found = false;
	FOREACH_ENTITY_RADIUS(this.origin, 800, IS_MONSTER(it) || (IS_PLAYER(it) && it != this.realowner && !autocvar_g_friendlyfire_virtual),
	{
		if(it.takedamage && it.health > 0)
		{
			found = true;
			break;
		}
	});

	if(found)
	{
		this.attack_finished = time + 1;
		organ_fire(this);
	}
	else
		this.attack_finished = time + 0.5; // only scan sometimes
}

void organ_setup(entity this)
{
	FOREACH_ENTITY_CLASS("organ", it.realowner == this.realowner && it.takedamage,
	{
		organ_die(it, NULL, NULL, DEATH_GENERIC.m_id);
	});

	this.classname = "organ";
	//set_movetype(this, MOVETYPE_NONE);
	this.owner = NULL; // to allow collisions
	setthink(this, organ_think);
	this.nextthink = time + 0.1;
	this.solid = SOLID_TRIGGER;
	this.health = 120;
	this.frame = organ_anim_idle;
	this.takedamage = DAMAGE_AIM;
	this.monster_attack = true;
	this.th_die = organ_die;
	this.th_pain = organ_pain;
	this.attack_finished = time + 1;

	// hack so music can work
	.entity weaponentity = weaponentities[0];
	this.(weaponentity) = this;
	this.(weaponentity).m_weapon = WEP_ORGAN;
	this.v_angle = this.angles;
	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;
}

void organ_projectile_touch(entity this, entity toucher)
{
	if(toucher && toucher.solid != SOLID_BSP)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	// TODO: bumping sound?
}

void organ_projectile_think(entity this)
{
	this.nextthink = time;
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	if(!IS_ONGROUND(this))
		return;

	sound(this, CH_WEAPON_B, SND_ORGAN_LAND, 1, ATTN_NORM);
	organ_setup(this);
	this.wait = time + 60;
}

void W_DropOrgan(entity this, .entity weaponentity)
{
	if(!StatusEffects_active(STATUSEFFECT_SharpShooter, this))
	{
		// add a delay to every weapon slot when dropping a organ to prevent instant fires
		for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity w_ent = weaponentities[slot];
			if(this.(w_ent) && slot != weaponslot(weaponentity))
				ATTACK_FINISHED(this, w_ent) = time + 0.5;
		}
		STAT(WEAPONS, this) &= ~WEP_ORGAN.m_wepset;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
	}

	sound(this, CH_WEAPON_B, SND_ORGAN_DROP, 1, ATTN_NORM);

	entity organ = spawn();
	organ.classname = "organ_projectile";
	organ.owner = this;
	organ.realowner = this;
	set_movetype(organ, MOVETYPE_TOSS);
	organ.solid = SOLID_BBOX;
	setmodel(organ, MDL_ORGAN);
	//setsize(organ, '-8 -8 -16', '8 8 8');
	vector cmin = this.mins, cmax = this.maxs;
	// some basic sanity, but otherwise use player's hitbox to avoid exploits
	cmin.z = -16;
	cmax.z = 32;
	setsize(organ, cmin, cmax);
	settouch(organ, organ_projectile_touch);
	setthink(organ, organ_projectile_think);
	organ.wait = time + 3;
	organ.nextthink = time;
	organ.frame = organ_anim_idle;

	vector org = this.origin + (this.view_ofs * 0.75);
	setorigin(organ, org);
	organ.angles = this.angles;
	organ.pos2 = organ.angles;
	makevectors(this.angles);
	organ.velocity = v_forward * 200 + v_up * 20;
}

METHOD(Organ, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_DropOrgan(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1.5);
	}
}
METHOD(Organ, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // no ammo
}
METHOD(Organ, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
