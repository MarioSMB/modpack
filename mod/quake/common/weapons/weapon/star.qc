#include "star.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void player_inhale2(entity this) { set_anim(this, 16, player_run); }
void player_inhale1(entity this) { set_anim(this, 14, player_inhale2); }

PRECACHE(Star)
{
	precache_model("progs/g_star.mdl");
	precache_model("progs/v_star.mdl");

	precache_model("progs/twister.mdl");

	precache_sound("kirby/wawa.wav");
}

void W_Star_Shambler_Clear(entity actor);
void W_Star_Clear(entity this)
{
	this.star_consumed = 0;
	STAT(KIRBY_STATE, this) = KIRBY_NORMAL;
	this.star_power = NULL;

	// TODO
	W_Star_Shambler_Clear(this);
}

void wep_star_frame(entity this, .entity weaponentity)
{
	Monster mon = REGISTRY_GET(Monsters, STAT(KIRBY_TYPE, this));

	if(mon && mon != MON_Null && mon.star_valid)
	{
		if(mon.star_frame)
			mon.star_frame(mon, this, weaponentity);
		return; // never fall through for abilities
	}

	// do nothing?
}

void star_twister_clear(entity this)
{
	if(this.star_twister)
		delete(this.star_twister);
	this.star_twister = NULL;
}

void star_twister_think(entity this)
{
	entity actor = this.owner;

	if(!actor.button0 || intermission_running || actor.star_twister != this || actor.m_champion != CHAMPION_Kirby || actor.health < 1 || (STAT(ITEMS, actor) & IT_TANK))
	{
		if(actor.star_twister == this)
			actor.star_twister = NULL;
		delete(this);
		return;
	}

	this.nextthink = time + 0.05;

	this.frame += 1;
	if(this.frame > 47)
		this.frame = 23;
}

void star_twister_summon(entity this)
{
	entity twister = spawn();
	twister.classname = "star_twister";
	twister.solid = SOLID_NOT;
	twister.owner = this;
	twister.realowner = this;
	_setmodel(twister, "progs/twister.mdl");
	setsize(twister, '0 0 0', '0 0 0');

	twister.alpha = 0.5;
	twister.origin = this.origin + '0 0 8';
	twister.angles = this.angles + '-90 0 0'; // TODO: adjust the model itself?
	//setattachment(twister, this, "");
	SetMovetypeFollow(twister, this);
	//setorigin(twister, this.origin);
	twister.effects = EF_LOWPRECISION | EF_NOSHADOW;

	setthink(twister, star_twister_think);
	twister.nextthink = time;
	twister.frame = 23;

	this.star_twister = twister;
}

float autocvar_sv_quake_kirby_eatprojectiles;
void W_Star_Inhale(entity this, .entity weaponentity)
{
	if(!this.star_twister)
		star_twister_summon(this);

	_sound(this, CH_WEAPON_SINGLE, "player_kirby/inhale.wav", 1, ATTN_NORM);

	makevectors(this.v_angle);

	vector myorg = CENTER_OR_VIEWOFS(this);
	vector org = myorg + v_forward * 100;
	FOREACH_ENTITY_RADIUS(org, 110, it != this,
	{
		if(!(it.flags & FL_PROJECTILE))
		{
			if(!it.takedamage || it.health < 1 || !Damage_ValidTarget(it, this))
				continue;
		}
		else if(it.classname != "cat" && it.classname != "thornball")
		{
			if(autocvar_sv_quake_kirby_eatprojectiles <= 0 || it.lefty > time || (it.owner && !Damage_ValidTarget(it.owner, this)))
				continue;
			if(random() < autocvar_sv_quake_kirby_eatprojectiles)
			{
				// failed this time, don't try again instantly
				it.lefty = time + 0.5;
				continue;
			}
		}

		vector dir = normalize(this.origin - it.origin);
		if(!(it.flags & FL_PROJECTILE) && !(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(it.monsterdef.spawnflags & MON_FLAG_STATIONARY))
		{
			float pushforce = 100 / vlen(it.maxs - it.mins);

			// don't nullify falling
			vector vel = dir * (100 * pushforce);
			it.velocity_x = vel.x;
			it.velocity_y = vel.y;

			if(IS_ONGROUND(it))
			{
				it.velocity_z = (25 * pushforce);
				UNSET_ONGROUND(it);
			}
		}

		// TODO: flag for enemies that can't be inhaled
		float hplimit = 90;
		if(gametype == GAMETYPE_TD)
			hplimit *= 0.5; // prevent easy consumption
		if(it.monsterdef == MON_EOW_PART)
			hplimit = 20; // parts have low health, must compensate
		else if(IS_PLAYER(it))
			hplimit = 50; // TODO: armor calculation?
		if(!(it.flags & FL_PROJECTILE) && (it.health > hplimit || it.monsterdef == MON_SHUB))
		{
			T_Damage(it, this, this, 3, WEP_STAR.m_id);
			continue;
		}

		vector p = NearestPointOnBoundingBox(it.absmin, it.absmax, myorg);
		vector myp = NearestPointOnBoundingBox(this.absmin, this.absmax, p);
		// bosses can be eaten from a range!
		if((it.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || vdist(p - myp, <=, 32))
		{
			if(it.monsterdef && it.monsterdef != MON_Null && it.monsterdef.star_valid)
				this.star_power = it.monsterdef; // store it until we swallow (or spit!)
			else
			{
				// maybe it's a player with an ability?
				Monster mon = REGISTRY_GET(Monsters, STAT(KIRBY_TYPE, it));
				if(mon && mon != MON_Null && mon.star_valid)
					this.star_power	= mon;
				else if(IS_PLAYER(it))
				{
					// give them a random valid ability!
					RandomSelection_Init();
					FOREACH(Monsters, it != MON_Null && it.star_valid && !(it.spawnflags & MONSTER_TYPE_BOSS) && it != MON_GOAT,
					{
						RandomSelection_AddEnt(it, 1, 1);
					});
					this.star_power = RandomSelection_chosen_ent;
				}
			}
			if(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
				this.star_consumed += 5;
			else
				this.star_consumed += 1;
			float sndpitch = 100 * bound(0.5, 0.5 + (0.1 * this.star_consumed), 1.5);
			sound7(this, CH_WEAPON_B, "player_kirby/eat.wav", 1, ATTN_NORM, sndpitch, 0);
			STAT(KIRBY_STATE, this) = KIRBY_FULL;
			if(it.flags & FL_PROJECTILE)
			{
				settouch(it, func_null);
				setthink(it, SUB_Remove);
				it.nextthink = time;
				it.solid = SOLID_NOT;
			}
			else
			{
				it.health = 0;
				Killed(it, this, this, DEATH_SWALLOW.m_id);
			}
			continue;
		}
	});
}

void wep_star_inhale(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(intermission_running)
		return;

	if(IS_PLAYER(actor))
		player_inhale1(actor);

	if(!actor.button0 || STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
	{
		star_twister_clear(actor);
		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	W_Star_Inhale(actor, weaponentity);

	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
	wep_set_anim(this, 0, wep_star_inhale);
}

void star_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	if(toucher.takedamage)
	{
		float damg = ((this.dmg) ? this.dmg : 30);
		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	if(this.noise && this.noise != "")
		_sound(this, CH_SHOTS, this.noise, 1, ATTN_NORM);

	vector org = findbetterlocation(this.origin, 8);
	te_explosion2(org, 110, 1);

	delete(this);
}

void star_big_touch(entity this, entity toucher)
{
	if(toucher.solid == SOLID_TRIGGER)
		return;
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	if(toucher && toucher.solid != SOLID_BSP)
	{
		// handled by hack
	}
	else
	{
		vector org = findbetterlocation(this.origin, 8);
		te_explosion2(org, 110, 1);

		if(this.noise && this.noise != "")
			_sound(this, CH_SHOTS, this.noise, 1, ATTN_NORM);
		//te_gunshot(org);
		delete(this);
		return;
	}
}

.float star_dmgtime;
void star_think(entity this)
{
	if(this.count < time)
	{
		delete(this);
		return;
	}

	this.nextthink = time;

	if(!this.state)
		return; // only big stars hit area

	FOREACH_ENTITY_RADIUS(this.origin, this.cnt, it.takedamage && it != this.owner,
	{
		if(time < it.star_dmgtime)
			continue;
		if(it.clipgroup && it.clipgroup == this.clipgroup)
			continue;
		float damg = ((this.dmg) ? this.dmg : 40);
		if(it.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			damg = 120;
		spawn_touchblood(this, damg, it);
		T_Damage(it, this, this.owner, damg, this.projectiledeathtype);

		_sound(this, CH_WEAPON_SINGLE, "player_kirby/star_hit.wav", 1, ATTN_NORM);

		it.star_dmgtime = time + 0.5; // prevent instant death
	});
}

void W_Star_Spit(entity this, .entity weaponentity)
{
	int consumed = this.star_consumed;
	if(deathmatch)
		consumed = 1; // no biggie

	makevectors(this.v_angle);
	vector dir = v_forward;
	entity newmis = launch_spike(this, this.origin + this.view_ofs, dir);
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.classname = "star_spit";
	newmis.dmg = 50 * max(1, this.star_consumed); // uncapped ;)
	newmis.avelocity = '-256 0 0';
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.noise = "player_kirby/star_impact.wav";
	settouch(newmis, spike_touch);
	newmis.projectiledeathtype = WEP_STAR.m_id;
	newmis.clipgroup = this.clipgroup;
	newmis.flags = FL_PROJECTILE;
	setthink(newmis, star_think);
	newmis.nextthink = time;
	newmis.count = time + 7;
	newmis.state = 0;
	settouch(newmis, star_touch);

	if(this.star_consumed >= 30)
	{
		sound7(this, CH_WEAPON_SINGLE, "player_kirby/spit_large.wav", 1, 0.1, 50, 0); // TODO: custom sound
		newmis.velocity = dir * 300;
		newmis.state = 2; // mega star!
		newmis.cnt = 768;
		newmis.solid = SOLID_TRIGGER;
		newmis.effects |= EF_NODEPTHTEST;
		set_movetype(newmis, MOVETYPE_NOCLIP);
		settouch(newmis, func_null);
		CSQCProjectile(newmis, true, PROJECTILE_STAR_MEGA, false);
	}
	else if(this.star_consumed >= 6)
	{
		_sound(this, CH_WEAPON_SINGLE, "player_kirby/spit_large.wav", 1, ATTN_NORM);
		newmis.velocity = dir * 600;
		newmis.state = 1; // big star!
		newmis.cnt = 64;
		newmis.solid = SOLID_TRIGGER;
		newmis.dphitcontentsmask = DPCONTENTS_SOLID;
		settouch(newmis, star_big_touch);
		CSQCProjectile(newmis, true, PROJECTILE_STAR_LARGE, true);
	}
	else if(this.star_consumed >= 3)
	{
		setsize(newmis, '16 16 16', '16 16 16');
		_sound(this, CH_WEAPON_SINGLE, "player_kirby/spit_medium.wav", 1, ATTN_NORM);
		newmis.velocity = dir * 800;
		CSQCProjectile(newmis, true, PROJECTILE_STAR_MEDIUM, true);
	}
	else
	{
		_sound(this, CH_WEAPON_SINGLE, "player_kirby/spit.wav", 1, ATTN_NORM);
		newmis.velocity = dir * 1500;
		CSQCProjectile(newmis, true, PROJECTILE_STAR_SMALL, true);
	}

	W_Star_Clear(this);
}

void W_Star_Exhale(entity this, .entity weaponentity)
{
	makevectors(this.angles);
	Send_Effect(EFFECT_SMOKE_RING, this.origin + v_forward * 32, v_forward * 256, 1);

	player_sound(this, CH_VOICE, "exhale.wav", ATTN_NORM);

	FOREACH_ENTITY_RADIUS(this.origin, 120, it.takedamage && it.health > 0,
	{
		if(!Damage_ValidTarget(it, this))
			continue;
		vector targ_org = (it.absmin + it.absmax) * 0.5;
		vector vec = normalize(targ_org - this.origin);
		float dot = vec * v_forward;
		if(dot < 0.3)
			continue;

		T_Damage(it, this, this, 20, WEP_STAR.m_id);
	});

	STAT(KIRBY_STATE, this) = KIRBY_NORMAL;
}

void W_Star_Fire(entity actor, .entity weaponentity)
{
	int mystate = STAT(KIRBY_STATE, actor);

	// exhaling overrides abilities!!
	if(mystate == KIRBY_FLYING)
	{
		W_Star_Exhale(actor, weaponentity);
		weapon_prepareattack(actor.(weaponentity), actor, weaponentity, 0.2);
		return;
	}

	Monster mon = REGISTRY_GET(Monsters, STAT(KIRBY_TYPE, actor));

	if(mon && mon != MON_Null && mon.star_valid)
	{
		if(mon.star_fire)
			mon.star_fire(mon, actor, weaponentity);
		return; // never fall through for abilities
	}

	// default moveset
	switch(mystate)
	{
		case KIRBY_NORMAL:
		{
			wep_star_inhale(actor.(weaponentity));
			weapon_prepareattack(actor.(weaponentity), actor, weaponentity, 0.2);
			return;
		}
		case KIRBY_FULL:
		{
			W_Star_Spit(actor, weaponentity);
			weapon_prepareattack(actor.(weaponentity), actor, weaponentity, 0.5);
			return;
		}
		default: return;
	}
}

void W_Star_Swallow(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_SINGLE, "player_kirby/swallow.wav", 1, ATTN_NORM);

	if(actor.star_power == MON_FLOYD)
	{
		actor.star_consumed -= 1; // don't give health too
		// special case: eating floyd turns you into floyd!
		te_teleport(actor.origin);
		actor.transform_limited = time + 20;
		actor.transform_health = 200;
		actor.m_transform = CHAMPION_FloydChamp;
	}
	else if(actor.star_power == MON_KIWI)
	{
		actor.star_consumed -= 1; // don't give health too
		// special case: eating floyd turns you into floyd!
		te_teleport(actor.origin);
		actor.transform_limited = time + 20;
		actor.transform_health = 120;
		actor.m_transform = CHAMPION_KiwiChamp;
	}
	else if(actor.star_power == MON_GOATLING || actor.star_power == MON_GOAT)
	{
		actor.star_consumed -= 1; // don't give health too
		// goats are also special
		_sound(actor, CH_WEAPON_B, "kirby/wawa.wav", 1, ATTN_NORM);
		T_Damage(actor, actor, NULL, 20, DEATH_GENERIC.m_id);
		if(IS_REAL_CLIENT(actor))
			centerprint(actor, "THOU SHALL NOT EAT THE HOLY ONE\n");
		if(actor.health < 1)
			return; // be smitten!
	}
	else if(actor.star_power)
	{
		actor.star_consumed -= 1; // don't give health too
		te_explosion2(actor.origin, 110, 1);
		STAT(KIRBY_TYPE, actor) = actor.star_power.monsterid;
		_sound(actor, CH_WEAPON_B, "player_kirby/ability.wav", 1, ATTN_NORM);
	}

	float healamount = 5 * actor.star_consumed;
	if(healamount > 0 && T_Heal(actor, healamount, true))
		actor.healthrot_nextcheck = time + 5;

	STAT(KIRBY_STATE, actor) = KIRBY_NORMAL;
	actor.star_consumed = 0;
	actor.star_power = NULL;

	ATTACK_FINISHED(actor, weaponentity) = max(ATTACK_FINISHED(actor, weaponentity), time + 0.25); // also prevent primary fire during this time

	actor.attack2_finished = time + 0.25;
}

void W_Star_Discard(entity actor, .entity weaponentity)
{
	te_explosion2(actor.origin, 111, 5);
	_sound(actor, CH_WEAPON_B, "player_kirby/ability_lost.wav", 1, ATTN_NORM);

	// return the ability to kirby's mouth
	Monster mon = REGISTRY_GET(Monsters, STAT(KIRBY_TYPE, actor));
	// don't need to check validity, but might as well!
	if(mon != MON_Null && mon.star_valid)
	{
		actor.star_power = mon;
		actor.star_consumed += 1;
		STAT(KIRBY_STATE, actor) = KIRBY_FULL;
	}

	// add a delay to attacks as well
	ATTACK_FINISHED(actor, weaponentity) = max(ATTACK_FINISHED(actor, weaponentity), time + 0.25);
	actor.attack2_finished = time + 1;

	// now discard the ability
	STAT(KIRBY_DISCARD, actor) = 0;
	STAT(KIRBY_TYPE, actor) = 0;
}

void W_Star_Fire2(entity actor, .entity weaponentity)
{
	Monster mon = REGISTRY_GET(Monsters, STAT(KIRBY_TYPE, actor));

	if(mon && mon != MON_Null && mon.star_valid)
	{
		actor.attack2_finished = time;
		STAT(KIRBY_DISCARD, actor) += PHYS_INPUT_FRAMETIME * 0.7;
		if(STAT(KIRBY_DISCARD, actor) >= 1)
			W_Star_Discard(actor, weaponentity);

		return; // never fall through for abilities
	}

	if(!(time < ATTACK_FINISHED(actor, weaponentity)) && STAT(KIRBY_STATE, actor) == KIRBY_FULL)
		W_Star_Swallow(actor, weaponentity);
	else
		actor.attack2_finished = time + 0.1; // prevent spam
}

void Star_Amalgam_Frame(entity actor, .entity weaponentity, int fire);
void Star_Bender_Frame(entity actor, .entity weaponentity, int fire);
METHOD(Star, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(!(fire & 1))
		actor.(weaponentity).count = 0; // for combos
	if(!(fire & 2) || (fire & 1))
		STAT(KIRBY_DISCARD, actor) = 0;
	// TODO: do wr_think handles properly
	if(IS_ONGROUND(actor))
	{
		actor.(weaponentity).star_knight_inair = false;
		actor.(weaponentity).star_kangaroo_inair = false;
	}

	Star_Amalgam_Frame(actor, weaponentity, fire);
	Star_Bender_Frame(actor, weaponentity, fire);

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		W_Star_Fire(actor, weaponentity);
	}

	// not while attacking
	if(fire & 2)
	//if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(!(time < actor.attack2_finished))
	{
		W_Star_Fire2(actor, weaponentity);
	}
}
METHOD(Star, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Star, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Star, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef CSQC
PRECACHE(Star)
{
	precache_model("progs/v_star_full.mdl");
}

void Star_Spawn(vector org, vector ang)
{
	entity star = new(star);
	star.solid = SOLID_NOT;
	star.alpha = 0.7;
	star.scale = bound(0.1, random(), 0.5);
	star.skin = 1;
	setmodel(star, MDL_PROJECTILE_STAR_SMALL);
	setsize(star, '0 0 0', '0 0 0');
	setorigin(star, org + (randomvec() * 24));
	star.drawmask = MASK_NORMAL;
	star.effects = EF_NOSHADOW | EF_FULLBRIGHT | EF_ADDITIVE;

	star.angles = ang;
	//star.angles_x = random() * 360;

	SUB_SetFade(star, time + 1, 1);
}

METHOD(Star, wr_viewmodel, string(entity this, entity wep))
{
	Monster mon = REGISTRY_GET(Monsters, STAT(KIRBY_TYPE));
	if(mon && mon != MON_Null && mon.star_viewmodel && mon.star_viewmodel != "")
		return mon.star_viewmodel;
	else if(STAT(KIRBY_STATE) == KIRBY_FULL)
		return "star_full";
	return "star";
}
#endif
