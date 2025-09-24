#include "grapple.qh"

PRECACHE(Grapple)
{
	precache_model("progs/hook.mdl");

	precache_sound("weapons/chain1.wav");
}

void GrappleReset(entity this)
{
	if(!this)
		return;

	entity actor = this.owner;

	if(actor)
	{
		actor.on_hook = false;
		actor.hook_out = false;
		actor.hook = NULL;
		//stopsound(actor, CH_SHOTS_SINGLE);
	}

	delete(this);
}

void GrappleTrail(entity h, entity player)
{
	makevectors(player.angles);
	vector player_org = player.origin + '0 0 16' + v_forward * 16 + v_right * -16;

	// draw a line to the hook
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_BEAM);
	WriteEntity(MSG_BROADCAST, h);
	WriteCoord(MSG_BROADCAST, h.origin_x);
	WriteCoord(MSG_BROADCAST, h.origin_y);
	WriteCoord(MSG_BROADCAST, h.origin_z);
	WriteCoord(MSG_BROADCAST, player_org.x);
	WriteCoord(MSG_BROADCAST, player_org.y);
	WriteCoord(MSG_BROADCAST, player_org.z);
}

void GrappleTrack(entity this)
{
	entity actor = this.owner;

	// Release dead targets
	if(IS_PLAYER(this.enemy) && this.enemy.health <= 0)
		actor.on_hook = false;

	// drop the hook if owner is dead or has released the button
	if(!actor || !actor.on_hook || actor.health <= 0)
	{
		GrappleReset(this);
		return;
	}

	if(IS_PLAYER(this.enemy))
	{
		if(this.enemy.teleport_time > time)
		{
			GrappleReset(this);
			return;
		}
		
		// move the hook along with the player.  It's invisible, but
		// we need this to make the sound come from the right spot
		setorigin(this, this.enemy.origin);
		
//		sound (this, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);
		_sound(this, CH_WEAPON_SINGLE, "pendulum/hit.wav", 1, ATTN_NORM);
		T_Damage(this.enemy, this, actor, 1, DEATH_TRAP.m_id);
		makevectors(this.v_angle);
		vector spray;
		spray.x = 100 * crandom();
		spray.y = 100 * crandom();
		spray.z = 100 * crandom() + 50;
		SpawnBlood(this.origin, spray, 20, this.enemy);
	}
	if(this.enemy.solid == SOLID_SLIDEBOX)
	{
		this.velocity = '0 0 0';
		setorigin(this, (this.enemy.absmin + this.enemy.absmax) * 0.5);
	}
	else
		this.velocity = this.enemy.velocity;

	this.nextthink = time + 0.1;
}

// Tries to anchor the grapple to whatever it touches
void GrappleAnchor(entity this, entity toucher)
{
	if(toucher == this.owner) // don't hook the guy that fired it
		return;

	if(!this.owner || pointcontents(this.origin) == CONTENT_SKY)
	{
		GrappleReset(this);
		return;
	}

	if(IS_PLAYER(toucher)) 
	{
		// glance off of teammates
		if(!Damage_ValidTarget(toucher, this.owner))
		{
			GrappleReset(this);		// PGM - fix drift after teammate hit  01/20/97
			return;
		}

		_sound(this, CH_WEAPON_SINGLE, "player/axhit1.wav", 1, ATTN_NORM);
		T_Damage(toucher, this, this.owner, 10, DEATH_TRAP.m_id);
	}
	else
	{
		_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);

		// One point of damage inflicted upon impact. Subsequent
		// damage will only be done to PLAYERS... this way secret
		// doors and triggers will only be damaged once.
		if(toucher.takedamage)
			T_Damage(toucher, this, this.owner, 1, DEATH_TRAP.m_id);

		this.velocity = '0 0 0';
		this.avelocity = '0 0 0';
	}

	this.frame = 2; // anchored

	_sound(this.owner, CH_WEAPON_SINGLE, "weapons/tink1.wav", 1, ATTN_NORM);

	if(!this.owner.button3)
	{
		GrappleReset(this);
		return;
	}

	this.owner.on_hook = true;
	UNSET_ONGROUND(this.owner);

	// CHAIN2 is a looping sample. Use LEFTY as a flag so that client.qc
	// will know to only play the tink sound ONCE to clear the weapons
	// sound channel. (Lefty is a leftover from AI.QC, so I reused it to
	// avoid adding a field)
	this.lefty = true;

	this.enemy = toucher;// remember this guy!
	setthink(this, GrappleTrack);
	this.nextthink = time;
	this.solid = SOLID_NOT;
	settouch(this, func_null);
}

void W_FireGrapple(entity actor)
{
	if(actor.hook_out)
		return;

	//actor.punchangle_x = -2; // bump them

	_sound(actor, CH_SHOTS_SINGLE, "weapons/chain1.wav", 1, ATTN_NORM);

	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;
	newmis.owner = actor;
	newmis.realowner = actor;
	newmis.classname = "hook";

	makevectors(actor.v_angle);
	newmis.velocity = v_forward * autocvar_sv_quake_hook_speed;
	newmis.angles = vectoangles(v_forward);

	settouch(newmis, GrappleAnchor);
	setthink(newmis, GrappleReset);
	// grapple only lives for two seconds, this gives max range on it
	newmis.nextthink = time + 2;
	newmis.frame = 1; // hook spread

	_setmodel(newmis, "progs/hook.mdl");
	setorigin(newmis, actor.origin + v_forward * 16 + v_right * -16); // roughly offhand
	setsize(newmis, '0 0 0', '0 0 0');

	actor.hook = newmis;
	actor.hook_out = true;
}

.float hook_length;
void GrappleHook_Pull(entity this)
{
	float spd, dist;

	makevectors(this.realowner.v_angle);
	vector vs = v_forward * 16 + v_right * -14;
	vector org = this.realowner.origin + this.realowner.view_ofs + vs;
	vector myorg = org;

	if(this.hook_length < 0)
		this.hook_length = vlen(myorg - this.origin);

	float pullspeed = 2000;
	// speed the rope is pulled with

	float rubberforce = 2000;
	// force the rope will use if it is stretched

	float rubberforce_overstretch = 1000;
	// force the rope will use if it is stretched

	float minlength = 50;
	// minimal rope length
	// if the rope goes below this length, it isn't pulled any more

	float ropestretch = 50;
	// if the rope is stretched by more than this amount, more rope is
	// given to you again

	float ropeairfriction = 0.2;
	// while hanging on the rope, this friction component will help you a
	// bit to control the rope

	vector dir = this.origin - myorg;
	dist = vlen(dir);

	int tarzan = 2;
	entity pull_entity = this.realowner;

	// TODO: Consider changing this back to `dir / dist` after https://github.com/graphitemaster/gmqcc/issues/210.
	dir = (dist ? dir * (1 / dist) : '0 0 0'); // same as dir = normalize(dir); but cheaper

	vector v, v0;
	v = v0 = pull_entity.velocity;

	// first pull the rope...
	float newlength = max(this.hook_length - pullspeed * frametime, minlength);

	if(newlength < dist - ropestretch) // overstretched?
	{
		newlength = dist - ropestretch;
		if(v * dir < 0) // only if not already moving in hook direction
			v = v + frametime * dir * rubberforce_overstretch;
	}

	this.hook_length = newlength;

	if(pull_entity.move_movetype == MOVETYPE_FLY)
		set_movetype(pull_entity, MOVETYPE_WALK);

	// then pull the player
	spd = bound(0, (dist - this.hook_length) / ropestretch, 1);
	v = v * (1 - frametime * ropeairfriction);
	v = v + frametime * dir * spd * rubberforce;

	vector dv = ((v - v0) * dir) * dir;
	if(tarzan >= 2)
	{
		if(this.enemy.move_movetype == MOVETYPE_WALK)
		{
			entity aim_ent = this.enemy;
			v = v - dv * 0.5;
			this.enemy.velocity = this.enemy.velocity - dv * 0.5;
			UNSET_ONGROUND(this.enemy);
			if(this.enemy.flags & FL_PROJECTILE)
				UpdateCSQCProjectile(this.enemy);
			aim_ent.pusher = this.realowner;
			aim_ent.pushltime = time + autocvar_g_maxpushtime;
		}
	}

	UNSET_ONGROUND(pull_entity);

	if(!(this.enemy.flags & FL_PROJECTILE))
		pull_entity.velocity = v;
}

void GrappleHook_Pull_Classic(entity this)
{
	makevectors(this.angles);
	vector vel = this.hook.origin - (this.origin + (v_up * 16 * (!PHYS_INPUT_BUTTON_JUMP(this))) + (v_forward * 16));

	float v = vlen(vel);
	if(v <= 100)
		vel = normalize(vel) * v * 10;
	else
		vel = normalize(vel) * 1000;
	this.velocity = vel;
}

// merged with GrappleService
void GrappleHookFrame(entity this)
{
	if(!this.button3 || !(this.items & IT_GRAPPLE) || STAT(CANNON, this) || this.tank || this.clockwork || this.m_transform 
		|| STAT(SKATING, this) || STAT(SLIDE_ON, this) || this.teleport_time > time)
	{
		if(this.hook)
			delete(this.hook);
		this.hook = NULL;
		this.hook_out = false;
		this.on_hook = false;
		//stopsound(this, CH_SHOTS_SINGLE);
		return;
	}

	if(this.hook_out)
	{
		if(!this.on_hook)
		{
			// just draw a line to the hook
			if(vdist(this.hook.origin - this.origin, >, 50))
				GrappleTrail(this.hook, this);
			return;
		}

		if(autocvar_sv_quake_hook_classic)
			GrappleHook_Pull_Classic(this);
		else
			GrappleHook_Pull(this.hook);

		if(vdist(this.hook.origin - this.origin, <=, 50))
		{
			if(this.hook.lefty)
			{
				//stopsound(this, CH_SHOTS_SINGLE);
				this.hook.lefty = false;
			}
		}
		else
			GrappleTrail(this.hook, this);
	}
	else
	{
		W_FireGrapple(this);
	}
}
