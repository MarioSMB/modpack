#include "jungle_golem.qh"

#ifdef SVQC
const int anim_jungle_golem = 0; // no actual animations!

.int bosswave;

.entity golem_fistl;
.entity golem_fistr;

..entity golem_field;

void jungle_golem_hop(entity this, float dist, float distz)
{
	fixedmakevectors(this.angles);
	vector dir = v_forward * dist + v_up * distz;

	UNSET_ONGROUND(this);
	this.velocity = dir;
}

void jungle_golem_fireball(entity this)
{
	if(this.bosswave >= 1)
		return;

	entity targ = this.enemy;
	_sound(this, CH_WEAPON_B, "items/fireball_fire.wav", 1, ATTN_NORM);
	vector org = this.origin + '0 0 75';
	vector dir = normalize(targ.origin - org);
	entity proj = Launch_Fireball(this, org, dir, 500);
	proj.projectiledeathtype = DEATH_MONSTER_JUNGLE_GOLEM.m_id;
}

void jungle_golem_stomp(entity this)
{
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	Send_Effect(EFFECT_SMOKE_LARGE, this.origin, '0 0 0', 1);
	T_RadiusDamage(this, this, 150, DEATH_MONSTER_JUNGLE_GOLEM.m_id, this);
}

float jungle_golem_thinkrate(entity this)
{
	return (this.bosswave >= 1) ? 0.5 : 1;
}

void jungle_golem_stand(entity this) { set_anim(this, anim_jungle_golem, jungle_golem_stand); ai_stand(this); }

void jungle_golem_walk1(entity this);
void jungle_golem_walk4(entity this)
{
	set_anim(this, anim_jungle_golem, jungle_golem_walk4);
	if(IS_ONGROUND(this))
	{
		jungle_golem_stomp(this);
		setthink(this, jungle_golem_walk1);
	}
}
void jungle_golem_walk3(entity this) { set_anim(this, anim_jungle_golem, jungle_golem_walk4); jungle_golem_hop(this, 400, 500); }
void jungle_golem_walk2(entity this) { set_anim(this, anim_jungle_golem, jungle_golem_walk3); this.nextthink = time + jungle_golem_thinkrate(this); }
void jungle_golem_walk1(entity this) { set_anim(this, anim_jungle_golem, jungle_golem_walk2); ai_walk(this, 0); this.nextthink = time + jungle_golem_thinkrate(this); }

void jungle_golem_run1(entity this);
void jungle_golem_run4(entity this)
{
	set_anim(this, anim_jungle_golem, jungle_golem_run4);
	if(IS_ONGROUND(this))
	{
		jungle_golem_stomp(this);
		setthink(this, jungle_golem_run1);
	}
}
void jungle_golem_run3(entity this) { set_anim(this, anim_jungle_golem, jungle_golem_run4); jungle_golem_hop(this, bound(200, vlen(this.enemy.origin - this.origin) * 1.2, 600), 600); }
void jungle_golem_run2(entity this) { set_anim(this, anim_jungle_golem, jungle_golem_run3); jungle_golem_fireball(this); this.nextthink = time + jungle_golem_thinkrate(this); }
void jungle_golem_run1(entity this) { set_anim(this, anim_jungle_golem, jungle_golem_run2); ai_run(this, 0); ai_face(this); this.nextthink = time + jungle_golem_thinkrate(this); }

//===========================================================================

void jungle_golem_pain(entity this, entity attacker, float damage, int deathtype)
{
	spamsound(this, CH_VOICE, SND_MECHBOSS_HIT, 1, ATTN_NORM);

	if(this.bosswave < 1 && this.health <= (this.max_health * 0.5))
	{
		this.bosswave = 1;
		vector cmin = this.mins;
		vector cmax = this.maxs;

		_setmodel(this, "progs/golem_phase2.mdl");
		setsize(this, cmin, cmax);

		this.golem_head = minion_spawn(this, this.origin + '0 0 78', new(monster), MON_GOLEM_HEAD);
	}
}

//===========================================================================

void jungle_golem_clearparts(entity this)
{
	if(this.golem_fistl) delete(this.golem_fistl);
	if(this.golem_fistr) delete(this.golem_fistr);
}

void jungle_golem_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "jungle_golem/explode.wav", 1, 0.5);
	Send_Effect(EFFECT_EXPLOSION_MEDIUM, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	if(this.golem_head && this.golem_head.health > 0)
		T_Damage(this.golem_head, this, this, this.golem_head.max_health, DEATH_GENERIC.m_id);

	jungle_golem_clearparts(this);

	delete(this);
}

void fist_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		this.count = time;
		return;
	}
	
	if(toucher.takedamage)
	{
		if(time >= this.pain_finished)
		{
			if(time < this.count)
				_sound(this, CH_WEAPON_SINGLE, "player_goat/bonk.wav", 1, ATTN_NORM);
			float damg = (this.dmg) ? this.dmg : 40;
			spawn_touchblood(this, damg, toucher);
			T_Damage(toucher, this, this.realowner, damg, this.projectiledeathtype);
			this.pain_finished = time + 0.1; // prevent instakills on return trip!
		}
		this.count = time; // tell it to start going home
	}
}

void fist_launch(entity this, entity targ)
{
	makevectors(this.owner.angles);
	vector offset = v_forward * this.pos1_x + v_right * -this.pos1_y + v_up * this.pos1_z;
	vector org = this.owner.origin + offset;
	vector dir = normalize(targ.origin - org);

	set_movetype(this, MOVETYPE_FLYMISSILE);
	setattachment(this, NULL, "");
	setorigin(this, org);
	settouch(this, fist_touch);
	this.count = time + 1;
	this.velocity = dir * 1000;
	this.angles = vectoangles(this.velocity);
	this.cnt = 1;
}

void fist_reattach(entity this)
{
	set_movetype(this, MOVETYPE_NONE);
	setattachment(this, this.owner, "");
	setorigin(this, this.pos1);
	settouch(this, func_null);
	this.velocity = '0 0 0';
	this.angles = '0 0 0';
	this.cnt = 0;
}

void fist_think(entity this)
{
	this.nextthink = time;

	if(this.owner.health <= 0 || wasfreed(this.owner))
	{
		delete(this);
		return;
	}

	// unattached: draw beam!
	if(this.cnt)
	{
		makevectors(this.owner.angles);
		vector offset = v_forward * this.pos1_x + v_right * -this.pos1_y + v_up * this.pos1_z;
		te_beam(this, this.origin, this.owner.origin + offset);

		if(time >= this.count)
		{
			vector vtemp = this.owner.origin + offset;
			if(vdist(vtemp - this.origin, <=, 32))
			{
				this.attack_finished = time + 1 + (2 * random()); // put them on cooldown again!
				fist_reattach(this);
				return;
			}
			vector dir = normalize(vtemp - this.origin);
			this.velocity = dir * 1000;
			this.dphitcontentsmask &= ~DPCONTENTS_SOLID;
		}
	}
	else if(time > this.attack_finished && this.owner.enemy)
	{
		// TODO: attack random players?
		this.attack_finished = time + 2 + (2 * random());
		fist_launch(this, this.owner.enemy);
	}
}

void fist_delete(entity this)
{
	if(this.owner)
		this.owner.(this.golem_field) = NULL;
	delete_fn(this);
}

entity jungle_golem_spawnfist(entity this, string fistmdl, vector offset, .entity fld)
{
	entity fist = new(golem_fist);
	fist.solid = SOLID_BBOX;
	_setmodel(fist, fistmdl);
	setsize(fist, '-24 -24 -16', '24 24 24');
	set_movetype(fist, MOVETYPE_NONE);
	fist.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	fist.pos1 = offset;
	fist.clipgroup = this.clipgroup;
	fist.projectiledeathtype = DEATH_MONSTER_JUNGLE_GOLEM.m_id;
	fist.owner = this;
	fist.realowner = this;
	setthink(fist, fist_think);
	fist.nextthink = time;
	fist.dmg = 30;
	fist.golem_field = fld;
	fist.attack_finished = time + 1 + (2 * random());
	fist.cnt = 0; // attached state
	fist.dtor = fist_delete;

	setattachment(fist, this, "");
	setorigin(fist, offset);
	//fist.angles = this.angles;

	this.(fld) = fist;
	
	return fist;
}

void jungle_golem_spawnparts(entity this)
{
	jungle_golem_spawnfist(this, "progs/golem_fist_l.mdl", '20 50 50', golem_fistl);

	jungle_golem_spawnfist(this, "progs/golem_fist_r.mdl", '20 -50 50', golem_fistr);
}

/*QUAKED monster_jungle_golem (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_jungle_golem) { monster_start(this, true, MON_JUNGLE_GOLEM); }
#endif // SVQC

#ifdef SVQC
METHOD(JungleGolem, mr_setup, bool(JungleGolem this, entity actor))
{
	TC(JungleGolem, this);

	precache_model("progs/golem_phase2.mdl");
	precache_model("progs/golem_fist_l.mdl");
	precache_model("progs/golem_fist_r.mdl");
	precache_sound("items/fireball_fire.wav");
	precache_sound("player_goat/bonk.wav");
	precache_sound("jungle_golem/explode.wav");
	precache_sound("jungle_golem/hit.wav");

	actor.yaw_speed = 90;

	actor.health = 2000;
	actor.th_stand = jungle_golem_stand;
	actor.th_walk = jungle_golem_walk1;
	actor.th_run = jungle_golem_run1;
	actor.th_pain = jungle_golem_pain;
	actor.th_die = jungle_golem_die;

	jungle_golem_spawnparts(actor);

	return true;
}
#endif
