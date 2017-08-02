#ifdef IMPLEMENTATION

MODEL(MG_DELUGEGUN, "models/mountedguns/delugegun.iqm");

#ifdef SVQC
#include "propellers.qh"

.entity bomb12;

void helicopter_rotor_die(entity hitbox)
{
	if(!hitbox)
		return;

	hitbox.event_damage = func_null;
	hitbox.takedamage = DAMAGE_NO;
	settouch(hitbox, func_null);
	setthink(hitbox, func_null);
	hitbox.nextthink = 0;
	hitbox.deadflag = DEAD_DEAD;
	set_movetype(hitbox, MOVETYPE_NONE);
	hitbox.solid = SOLID_NOT;
}

void helicopter_rotor_touch(entity this, entity toucher)
{
	//This is for helicopter rotor kill boxes. //This is mostly the same as above but whatever is set as this.subordinate
	if(this.owner)
	{
		if(toucher != NULL)
		if(vehicles_crushable(toucher))
		{
			if((this.bomb1.gun1.avelocity_y > 200) || (this.bomb1.gun1.avelocity_y < -200))
			{
				float dmgalgo = 0;
				if (this.bomb1.gun1.avelocity_y > 1)
					dmgalgo = 50 + bound(0, (autocvar_g_vehicles_crush_dmg * (this.bomb1.gun1.avelocity_y / 2090)), autocvar_g_vehicles_crush_dmg*1.5);
				else if (this.bomb1.gun1.avelocity_y < -1)
					dmgalgo = 50 + bound(0, (autocvar_g_vehicles_crush_dmg * ((this.bomb1.gun1.avelocity_y * -1) / 2090)), autocvar_g_vehicles_crush_dmg*1.5);
			
				Damage(toucher, this, this.owner, autocvar_g_vehicles_crush_dmg + dmgalgo, DEATH_HELI_PROPELLER.m_id, '0 0 0', normalize(toucher.origin - this.origin) * autocvar_g_vehicles_crush_force);
			}

			return; // Dont do self damage when hitting "soft targets".
		}

		if(this.play_time < time)
		{
			Vehicle info = Vehicles_from(this.vehicleid);
			info.vr_impact(info, this);
		}
	}
}


void helicopter_rotor_touch_hitbox(entity this, entity toucher)
{
	if(!toucher.rotor_is && toucher != this.owner)
		helicopter_rotor_touch(this.owner, toucher); //This way this.subordinate is tested for max_z rather than this
}

void helicopter_rotor_think(entity this)
{
	//Information on why it's not simply makevectors(this.angles);
	//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
	//	have inverted pitch
	//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
	//	if the entity is bsp or sprite, but not if it is a model
	//18:36 <@LordHavoc> inverting the pitch is necessary on models
	//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
	//	where they are correct pitch for models but not for bsp or 
	//	sprite :P
	vector ownang = this.owner.angles;
	makevectors(vec3(ownang.x * -1, ownang.y, ownang.z));
	setorigin(this, (this.owner.origin + (v_forward * this.rotoroffset_x) + (v_right * this.rotoroffset_y) + (v_up * this.rotoroffset_z))); //Forward X qunits, up_s
	this.nextthink = time;
}

void helicopter_rotor_think_noz(entity this)
{
	//For this version, No spin for z:
	vector ownang = this.owner.angles;
	makevectors(vec2(ownang.x * -1, ownang.y));
	setorigin(this, (this.owner.origin + (v_forward * this.rotoroffset_x) + (v_right * this.rotoroffset_y) + (v_up * this.rotoroffset_z))); //Forward X qunits, up_s
	this.nextthink = time;
}

void helicopter_rotor_spawn_hitbox(float rotortype, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s)
{
	hitbox.owner = vehic;
	
	settouch(hitbox, helicopter_rotor_touch_hitbox);
	hitbox.rotor_is = 1; //We are a rotor. Other rotors will ignore touching us. Brothers in arms.

	hitbox.bot_attack         = false;
	hitbox.iscreature         = true;
	hitbox.teleportable       = false; // no teleporting for vehicles, too buggy
	set_movetype(hitbox, MOVETYPE_NONE);
	hitbox.solid              = SOLID_TRIGGER;
	hitbox.deadflag           = DEAD_NO;
	hitbox.flags              = FL_NOTARGET;
	
	if(rotortype == 1)
		setthink(hitbox, helicopter_rotor_think_noz);
	else
		setthink(hitbox, helicopter_rotor_think);
	
	hitbox.nextthink = time;
	hitbox.netname = hitbox.owner.netname;
	setsize(hitbox, min_s, max_s);
	makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
	setorigin(hitbox, (vehic.origin + (v_forward * fwd_s) + (v_right * right_s) + (v_up * up_s))); //Forward X qunits, up_s
	hitbox.rotoroffset_x = fwd_s;
	hitbox.rotoroffset_y = right_s;
	hitbox.rotoroffset_z = up_s;
	
	hitbox.damageforcescale = 0.03;
	//hitbox.ballistics_density = autocvar_g_ballistics_density_metal;
}
#endif

#endif
