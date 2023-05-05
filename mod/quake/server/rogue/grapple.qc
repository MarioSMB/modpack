// Rogue Grapple Implementation
// Jan'97 by ZOID <zoid@threewave.com>
// Under contract to id software for Rogue Entertainment

// prototypes for WEAPONS.QC functions
//float crandom();
void SpawnBlood(vector org, vector vel, float damage, entity targ);

void GrappleTrail(entity h, entity player)
{
	// draw a line to the hook
	te_beam(h, h.origin, player.origin + vec3(0, 0, 16));
}

void GrappleReset(entity this)
{
	this.owner.on_hook = false;
	this.owner.hook_out = false;
	this.owner.weaponentity.m_frame = 0;
	this.owner.attack_finished = time +0.25;
	
	delete(this);
}

void GrappleTrack(entity this)
{
	// Release dead targets
	if(IS_PLAYER(this.enemy) && this.enemy.health <= 0)
		this.owner.on_hook = false;

	// drop the hook if owner is dead or has released the button
	if(!this.owner.on_hook || this.owner.health <= 0) {
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
		
//		_sound(this, CH_WEAPON_SINGLE, "blob/land1.wav", 1, ATTN_NORM);
		_sound(this, CH_WEAPON_SINGLE, "pendulum/hit.wav", 1, ATTN_NORM);
		T_Damage(this.enemy, this, this.owner, 1);
		makevectors(this.v_angle);
		vector spray;
		spray.x = 100 * crandom();
		spray.y = 100 * crandom();
		spray.z = 100 * crandom() + 50;
		SpawnBlood(this.origin, spray, 20, this.enemy);
	}
	if(this.enemy.solid == SOLID_SLIDEBOX) {
		this.velocity = '0 0 0';
		setorigin(this, this.enemy.origin + this.enemy.mins + this.enemy.size * 0.5);
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

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		GrappleReset(this);
		return;
	}

	if(IS_PLAYER(toucher)) 
	{
		// glance off of teammates
		if(toucher.steam == this.owner.steam)
		{
			GrappleReset(this);		// PGM - fix drift after teammate hit  01/20/97
			return;
		}

		player_sound(this, CH_WEAPON_SINGLE, "axhit1.wav", ATTN_NORM);
		T_Damage(toucher, this, this.owner, 10);
	}
	else
	{
		_sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);

		// One point of damage inflicted upon impact. Subsequent
		// damage will only be done to PLAYERS... this way secret
		// doors and triggers will only be damaged once.
		if(toucher.takedamage)
			T_Damage(toucher, this, this.owner, 1);

		this.velocity = '0 0 0';
		this.avelocity = '0 0 0';
	}

	this.frame = 2; // anchored

	_sound(this.owner, CH_WEAPON_SINGLE, "weapons/tink1.wav", 1, ATTN_NORM);

	if(!this.owner.button0)
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
	this.owner.lefty = true;

	this.enemy = toucher;// remember this guy!
	setthink(this, GrappleTrack);
	this.nextthink = time;
	this.solid = SOLID_NOT;
	settouch(this, func_null);
}

void W_FireGrapple(entity this)
{
	if(this.hook_out)// reject subsequent calls from player.qc
		return;

	this.punchangle_x = -2; // bump him

	// chain out sound (loops)
	_sound(this, CH_WEAPON_SINGLE, "weapons/chain1.wav", 1, ATTN_NORM);

	entity newmis = new(hook);
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;
	newmis.owner = this;		// newmis belongs to me
	this.hook = newmis;			// This is my newmis

	makevectors (this.v_angle);
	newmis.velocity = v_forward * 800;
//	newmis.avelocity = '0 0 -500';
	newmis.angles = vectoangles(v_forward);

	settouch(newmis, GrappleAnchor);
	setthink(newmis, GrappleReset);
	// grapple only lives for two seconds, this gives max range on it
	newmis.nextthink = time + 2;
	newmis.frame = 1; // hook spread

	_setmodel(newmis,"progs/hook.mdl");
	setorigin(newmis, this.origin + v_forward * 16 + '0 0 16');
	setsize(newmis, '0 0 0' , '0 0 0 ');

	this.hook_out = true;
}

// called each frame by CLIENT.QC if client has hook_out
void GrappleService(entity this)
{
	if(!this.on_hook)
	{
		// just draw a line to the hook
		if(vdist(this.hook.origin - this.origin, >, 50))
			GrappleTrail(this.hook, this);
		return;
	}

	// drop the hook if player lets go of button
	if((!this.button0 && this.weaponentity.m_weapon == WEP_GRAPPLE) || this.teleport_time > time) 
	{ // release when we get 'ported
		GrappleReset(this.hook);
		return;
	}
	
	makevectors(this.angles);
	vector vel = this.hook.origin - ( this.origin + (v_up * 16 *
			(!this.button2)) + (v_forward * 16));

	float v = vlen(vel);

	if(v <= 100)
		vel = normalize(vel) * v * 10;  
	else
		vel = normalize(vel) * 1000;

	this.velocity = vel;

	if(vdist(this.hook.origin - this.origin, <=, 50))
	{
		if(this.lefty)
		{ // cancel chain sound
			// If there is a chain, ditch it now. We're
			// close enough. Having extra entities lying around
			// is never a good idea.
//			if(this.hook.goalentity) { 
//					this.hook.goalentity.think = GrappleRemoveChain;
//					this.hook.goalentity.nextthink = time;
//			}

			this.lefty = false;// we've reset the sound channel.
		}
	}
	else
		GrappleTrail(this.hook, this);
}
