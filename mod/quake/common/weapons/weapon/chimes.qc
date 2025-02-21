#include "chimes.qh"

#ifdef SVQC
const int chimes_anim_rear = 0; //'0 64 0'
const int chimes_anim_wind = 65; //'65 81 0'
const int chimes_anim_shock = 82; //'82 115 0'
const int chimes_anim_wack = 116; //'116 131 0'

PRECACHE(Chimes)
{
	precache_model("progs/v_chimes.mdl");
	precache_model("progs/g_chimes.mdl");

	precache_sound("skullwiz/skull1.wav");
	precache_sound("skullwiz/skull2.wav");

	precache_sound("weapons/chimes_idle1.wav");
	precache_sound("weapons/chimes_idle2.wav");
	precache_sound("weapons/chimes_idle3.wav");
	precache_sound("weapons/chimes_idle4.wav");
}

void chimes_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.solid = SOLID_NOT;
	this.takedamage = DAMAGE_NO;
	this.monster_attack = false;
	this.frame = 0;
	setthink(this, SUB_Remove);
	this.nextthink = time;
	//Send_Effect(EFFECT_EXPLOSION, this.origin + '0 0 16', '0 0 0', 1);
	particle(this.origin + ('0 0 1' * this.maxs_z), '0 0 40', 15, 100);
	sound(this, CH_VOICE, SND_CHIMES_EXPLODE, 1, ATTN_NORM);

	music_reset(this);
}

void chimes_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	this.frame = chimes_anim_wind;
	this.pain_finished = time + 1.7;
}

void chimes_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 15;
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

void chimes_fire(entity this, entity targ)
{
	vector neworg = this.origin + ('0 0 1' * this.maxs_z);
	this.angles_y = vectoyaw(targ.origin - this.origin);
	vector dir = normalize(targ.origin - neworg);
	float chimes_count = 1;
	for(int j = 0; j < chimes_count; ++j)
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
		musicnote.projectiledeathtype = WEP_CHIMES.m_id;

		musicnote.angles = '0 1 0' * this.angles_y;

		musicnote.scale = 0.5;
		musicnote.nextthink = time + 3;
		//musicnote.think = SUB_Remove; 
		setthink(musicnote, BecomeCartoonExplosion);
		_setmodel(musicnote, "progs/piano_musicnote_white.mdl");
		musicnote.colormod = '0.96 0.14 0.05';
		setsize(musicnote, '0 0 0', '0 0 0');

		setorigin(musicnote, neworg);
		settouch(musicnote, chimes_note_touch);

		musicnote.velocity = dir * 600;
	}

	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "skullwiz/skull1.wav", 0.7, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "skullwiz/skull2.wav", 0.7, ATTN_NORM);

	this.frame = chimes_anim_wack;
	this.count = time + 1.6; // rough animation matching TODO
}

void chimes_think(entity this)
{
	setthink(this, chimes_think);
	this.nextthink = time;

	if((this.wait && time > this.wait) || wasfreed(this.realowner))
	{
		chimes_die(this, NULL, NULL, DEATH_GENERIC.m_id);
		return;
	}

	if(time >= this.cnt)
	{
		this.frame += 1;
		float maxframe = 64;
		if(this.pain_finished > time)
			maxframe = 81;
		else if(this.count > time)
			maxframe = 131;

		// since the other animations don't loop we can safely just reset to 0
		if(this.frame > maxframe)
			this.frame = 0;
		this.cnt = time + 0.1; // anim framerate
	}

	if(time > this.delay && time > this.pain_finished && time > this.count && random() < 0.2)
	{
		this.delay = time + 4;
		float r = random();
		if(r <= 0.25)
			_sound(this, CH_VOICE, "weapons/chimes_idle1.wav", 1, ATTN_NORM);
		else if(r <= 0.50)
			_sound(this, CH_VOICE, "weapons/chimes_idle2.wav", 1, ATTN_NORM);
		else if(r <= 0.75)
			_sound(this, CH_VOICE, "weapons/chimes_idle3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "weapons/chimes_idle4.wav", 1, ATTN_NORM);
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

	entity selected = W_PickNearbyTarget(this, this.realowner, 700, false, false);
	if(selected)
		chimes_fire(this, selected);

	this.attack_finished = time + 0.7;
}

void chimes_setup(entity this)
{
	FOREACH_ENTITY_CLASS("chimes", it.realowner == this.realowner && it.monster_attack,
	{
		chimes_die(it, NULL, NULL, DEATH_GENERIC.m_id);
	});

	this.classname = "chimes";
	//set_movetype(this, MOVETYPE_NONE);
	this.owner = NULL;
	setthink(this, chimes_think);
	this.nextthink = time + 0.1;
	this.solid = SOLID_TRIGGER;
	this.health = 120;
	this.frame = chimes_anim_rear;
	this.takedamage = DAMAGE_NO;
	this.monster_attack = true;
	this.th_die = chimes_die;
	this.th_pain = chimes_pain;
	this.attack_finished = time + 1;
	this.cnt = time + 0.1;
	this.delay = time + 1;

	// hack so music can work
	.entity weaponentity = weaponentities[0];
	this.(weaponentity) = this;
	this.(weaponentity).m_weapon = WEP_CHIMES;
	this.v_angle = this.angles;
	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;
}

void chimes_projectile_touch(entity this, entity toucher)
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

void chimes_projectile_think(entity this)
{
	this.nextthink = time;
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	if(!IS_ONGROUND(this))
		return;

	chimes_setup(this);
	this.wait = time + 300;
}

void W_DropChimes(entity this, .entity weaponentity)
{
	if(!StatusEffects_active(STATUSEFFECT_SharpShooter, this))
	{
		// add a delay to every weapon slot when dropping a chimes to prevent instant fires
		for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity w_ent = weaponentities[slot];
			if(this.(w_ent) && slot != weaponslot(weaponentity))
				ATTACK_FINISHED(this, w_ent) = time + 0.5;
		}
		STAT(WEAPONS, this) &= ~WEP_CHIMES.m_wepset;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
	}

	sound(this, CH_WEAPON_B, SND_CHIMES_DROP, 1, ATTN_NORM);

	entity chimes = spawn();
	chimes.classname = "chimes_projectile";
	chimes.owner = this;
	chimes.realowner = this;
	set_movetype(chimes, MOVETYPE_TOSS);
	chimes.solid = SOLID_BBOX;
	setmodel(chimes, MDL_CHIMES);
	//setsize(chimes, '-8 -8 -16', '8 8 8');
	vector cmin = this.mins, cmax = this.maxs;
	// some basic sanity, but otherwise use player's hitbox to avoid exploits
	cmin.z = -16;
	cmax.z = 32;
	setsize(chimes, cmin, cmax);
	settouch(chimes, chimes_projectile_touch);
	setthink(chimes, chimes_projectile_think);
	chimes.wait = time + 3;
	chimes.nextthink = time;
	chimes.frame = chimes_anim_rear;

	vector org = this.origin + (this.view_ofs * 0.75);
	setorigin(chimes, org);
	chimes.angles = this.angles;
	chimes.pos2 = chimes.angles;
	makevectors(this.angles);
	chimes.velocity = v_forward * 200 + v_up * 20;
}

METHOD(Chimes, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_DropChimes(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1.5);
	}
}
METHOD(Chimes, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // no ammo
}
METHOD(Chimes, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Chimes, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
