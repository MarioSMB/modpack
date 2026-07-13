#include "slime.qh"

#ifdef SVQC
// animations handled as vectors

const int CLIPGROUP_SLIME = 25; // randomly picked! search for CLIPGROUP_ to find others used

const int MON_SLIME_UMBRELLA = BIT(1);

enum {
	SLIME_NORMAL,
	SLIME_UMBRELLA,
	SLIME_RAINBOW,
	SLIME_MOTHER,
	SLIME_BABY,
	SLIME_PINKY
};

void slime_hop(entity this)
{
	float dist = max(300, random() * 700);

	fixedmakevectors(this.angles);
	vector dir = v_forward * dist + v_up * (dist * 0.6);

	UNSET_ONGROUND(this);
	this.velocity = dir;
}

void slime_frame(entity this)
{
	this.nextthink = time + 0.1;

	if(this.state == 2)
	{
		this.frame = 76;
		if(!IS_ONGROUND(this))
			return;
		this.state = 1; // go back to landing and let animation finish
	}

	vector anim;
	if(this.state == 1)
		anim = '30 108 0';
	else if(this.state == 3)
		anim = '62 108 0';
	else if(this.enemy)
		anim = '109 127 0';
	else
		anim = '0 29 0';

	this.frame += 1;

	// boing!
	if(this.state && this.frame == 76)
	{
		slime_hop(this);
		this.state = 2;
		return;
	}

	if(this.frame < anim.x)
		this.frame = anim.x;
	else if(this.frame > anim.y)
	{
		this.frame = anim.x;
		if(this.state == 1)
			this.state = (this.variant == SLIME_RAINBOW || random() < 0.3) ? 3 : 0;
		else
			this.state = 1;
	}

	// call regular logic to track enemies
	if(this.enemy)
		ai_run(this, 0);
	else
		ai_walk(this, 0);
}

void slime_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 0.1;
	_sound(this, CH_VOICE, "eoc/pain.wav", 1, ATTN_NORM);
}

//===========================================================================

void slime_split(entity this, vector org)
{
	Monster mon = (this.monsterdef) ? this.monsterdef : MON_SLIME;

	entity monster = new(monster);
	monster.variant = SLIME_BABY;
	minion_spawn(this, org, monster, mon);
	monster.nextthink = time + random() * 1;
	UNSET_ONGROUND(monster);
	monster.velocity = randomvec() * 150;
	monster.velocity_z = 25 + (random() * 75);
}

vector slime_randompos(entity this)
{
	vector mypos = this.origin + randomvec() * 16;
	mypos.z = this.origin_z;
	traceline(this.origin, mypos, MOVE_NOMONSTERS, this);
	return trace_endpos;
}


void slime_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED: break; // fall through to regular death
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	if(this.variant == SLIME_MOTHER)
	{
		slime_split(this, slime_randompos(this));
		if(random() < 0.5)
			slime_split(this, slime_randompos(this));
		if(random() < 0.5)
			slime_split(this, slime_randompos(this));
	}

	_sound(this, CH_VOICE, "eoc/death.wav", 1, ATTN_NORM);
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void slime_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;
	if(toucher.monsterdef == this.monsterdef)
		return; // no slimy action ever
	if(!Damage_ValidTarget(toucher, this))
		return;

	if(toucher.takedamage && toucher.pain_finished < time)
	{
		float ldmg = 20 * random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_SLIME.m_id);
	}
}

/*QUAKED monster_slime (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_slime) { monster_start(this, true, MON_SLIME); }
#endif // SVQC

#ifdef SVQC
METHOD(Slime, mr_setup, bool(Slime this, entity actor))
{
	TC(Slime, this);

	precache_sound("eoc/death.wav");
	precache_sound("eoc/pain.wav");

	if(actor.spawnflags & MON_SLIME_UMBRELLA)
		actor.variant = SLIME_UMBRELLA;

	if(!actor.variant)
	{
		RandomSelection_Init();
		RandomSelection_AddFloat(SLIME_NORMAL, 1, 1);
		RandomSelection_AddFloat(SLIME_UMBRELLA, 0.2, 1);
		RandomSelection_AddFloat(SLIME_MOTHER, 0.2, 1);
		RandomSelection_AddFloat(SLIME_RAINBOW, 0.05, 1);
		RandomSelection_AddFloat(SLIME_PINKY, 0.05, 1);
		// never a baby
		actor.variant = RandomSelection_chosen_float;
	}

	//actor.solid = SOLID_CORPSE; // passes through, can still impact players
	if(!actor.clipgroup)
		actor.clipgroup = CLIPGROUP_SLIME;

	actor.health = 90;
	actor.th_stand = slime_frame;
	actor.th_walk = slime_frame;
	actor.th_run = slime_frame;
	actor.th_pain = slime_pain;
	actor.th_die = slime_die;

	settouch(actor, slime_touch);

	switch(actor.variant)
	{
		case SLIME_NORMAL:
		{
			float r = random();
			if(r < 0.2)
				actor.skin = 0;
			else if(r < 0.4)
				actor.skin = 1;
			else if(r < 0.6)
				actor.skin = 5;
			else if(r < 0.8)
				actor.skin = 6;
			else
				actor.skin = 7;
			actor.scale = bound(0.8, random() * 2, 1.5);
			break;
		}
		case SLIME_RAINBOW:
		{
			// TODO: more skins
			actor.skin = 2;
			actor.scale = 3;
			setsize(actor, this.m_mins * 3, this.m_maxs * 3);
			actor.colormap = 1024 + 255; // RENDER_COLORMAPPED
			actor.health = 500;
			break;
		}
		case SLIME_UMBRELLA:
		{
			precache_model("progs/mon_slime_umbrella.mdl");
			_setmodel(actor, "progs/mon_slime_umbrella.mdl");
			setsize(actor, this.m_mins * 1.5, this.m_maxs * 1.5);
			actor.gravity = 0.5;
			actor.health = 150;
			actor.scale = 1.5;
			break;
		}
		case SLIME_BABY:
		{
			actor.skin = 8;
			actor.scale = bound(0.75, random() * 2, 1.2);
			setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);
			break;
		}
		case SLIME_MOTHER:
		{
			actor.skin = 3;
			actor.scale = 2;
			actor.health = 200;
			setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);
			break;
		}
		case SLIME_PINKY:
		{
			// TODO: more skins
			actor.skin = 4;
			actor.scale = 0.5;
			setsize(actor, this.m_mins * 0.5, this.m_maxs * 0.5);
			actor.health = 800;
			break;
		}
	}

	return true;
}
#endif
