// Shield
//

// ===================
// shield_think
// ===================
void shield_think(entity this)
{
	if(this.owner.shield_death_time < time)
	{
		this.owner.shield_entity = NULL;
		delete(this);
		return;
	}
	
	if((this.owner.shield_death_time - 0.25) <= time)
		this.model = string_null;
	else
	{
		setorigin(this, this.owner.origin);	
		this.v_angle = this.owner.v_angle;
		this.angles = this.owner.angles;
	}
	
	setthink(this, shield_think);
	this.nextthink = time + 0.05;
}

// ===================
// shield_spawn
// ===================
void shield_spawn(entity shieldOwner, vector dir)
{
	if(shieldOwner.shield_death_time > time)
		return;

	entity newShield = new(power_shield);
	newShield.owner = shieldOwner;
	newShield.solid = SOLID_NOT;
	newShield.takedamage = DAMAGE_NO;
	set_movetype(newShield, MOVETYPE_NONE);
	
	// time for shield to live
//	shieldOwner.shield_death_time = time + 0.5;
	shieldOwner.shield_death_time = time + 0.3;
	shieldOwner.shield_entity = newShield;
		
	newShield.v_angle = shieldOwner.v_angle;
	newShield.angles = shieldOwner.angles;
	setorigin(newShield, shieldOwner.origin);
	_setmodel(newShield, "progs/p_shield.mdl");
	setsize(newShield, '0 0 0', '0 0 0');

	newShield.nextthink = time + 0.1; 		
	setthink(newShield, shield_think);
}


// ===================
// shield_hit
// ===================
float shield_hit(entity targ, entity inflictor, entity attacker, float damage)
{
	vector dir = inflictor.origin - targ.origin;
	float save = vectoyaw(dir);
	makevectors (targ.angles);
	float hitAngle = save - vectoyaw ( v_forward );

	if(hitAngle > 90 && hitAngle < 270)
		return damage;
	else if(hitAngle < -90 && hitAngle > -270 )
		return damage;
	
	shield_spawn(targ, dir);			 

	if(targ.shieldSoundTime < time)
	{
		_sound(targ, CHAN_ITEM, "shield/hit.wav", 1, ATTN_NORM);
		targ.shieldSoundTime = time + 0.5;
	}

	if (inflictor.classname == "lava_spike")
		save = damage * 0.70;
	else
		save = damage * 0.30;

	return save;
}
