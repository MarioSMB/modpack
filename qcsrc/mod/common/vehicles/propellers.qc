#ifdef SVQC
#include "propellers.qh"

.entity bomb12;

void helicopter_rotor_donothing()
{
	//print("doing nothing\n");
}

void helicopter_rotor_die(entity hitbox)
{
	hitbox.event_damage       = func_null;
	hitbox.takedamage         = DAMAGE_NO;
	hitbox.touch              = func_null;
	hitbox.think              = helicopter_rotor_donothing;
	hitbox.deadflag           = DEAD_DEAD;
	hitbox.movetype           = MOVETYPE_NONE;
	hitbox.solid      = SOLID_NOT;
}

void helicopter_rotor_touch()
{
	//This is for helicopter rotor kill boxes. //This is mostly the same as above but whatever is set as self.subordinate
	if(self.owner)
	{
		if(other != world)
		if(vehicles_crushable(other))
		{
			if((self.bomb1.gun1.avelocity_y > 200) || (self.bomb1.gun1.avelocity_y < -200)) {
				float dmgalgo = 0;
			if (self.bomb1.gun1.avelocity_y > 1)
				dmgalgo = 202 + bound(0, (autocvar_g_vehicles_crush_dmg * (self.bomb1.gun1.avelocity_y / 2090)), autocvar_g_vehicles_crush_dmg*1.5);
			else if (self.bomb1.gun1.avelocity_y < -1)
				dmgalgo = 202 + bound(0, (autocvar_g_vehicles_crush_dmg * ((self.bomb1.gun1.avelocity_y * -1) / 2090)), autocvar_g_vehicles_crush_dmg*1.5);
			
					Damage(other, self, self.owner, autocvar_g_vehicles_crush_dmg + dmgalgo, DEATH_VH_CRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
		}

			return; // Dont do selfdamage when hitting "soft targets".
	}
	
		if(self.play_time < time)
			VEH_ACTION(self.vehicleid, VR_IMPACT);

		return;
	}

	if(!IS_PLAYER(other))
		return;

	if(other.deadflag != DEAD_NO)
		return;

	if(other.vehicle != world)
		return;

	return;
}


void helicopter_rotor_touch_hitbox()
{
	//print("rotor touched something\n");
	if (!other.rotor_is)
	if (other != self.owner) {
		//print("rotor touched not its owner and not another rotor, something else\n");
		self = self.owner;
		helicopter_rotor_touch(); //This way self.subordinate is tested for max_z rather than self
	}
}

void helicopter_rotor_impact_hitbox()
{
	//print("here2\n");
	self = self.owner;
	VEH_ACTION(self.vehicleid, VR_IMPACT);
}

void helicopter_rotor_think()
{
	//print (self.owner.model, " my mster\n");
	
	//Information on why it's not simply makevectors(self.angles);
	//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
	//	have inverted pitch
	//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
	//	if the entity is bsp or sprite, but not if it is a model
	//18:36 <@LordHavoc> inverting the pitch is necessary on models
	//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
	//	where they are correct pitch for models but not for bsp or 
	//	sprite :P
	makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 1');
	setorigin(self, (self.owner.origin + (v_forward * self.rotoroffset_x) + (v_right * self.rotoroffset_y) + (v_up * self.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
}

void helicopter_rotor_think_noz()
{
	//For this version, No spin for z:
	makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 0');
	setorigin(self, (self.owner.origin + (v_forward * self.rotoroffset_x) + (v_right * self.rotoroffset_y) + (v_up * self.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
}

void helicopter_rotor_spawn_hitbox(float rotortype, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s)
{
	hitbox.owner              = vehic;
	
	hitbox.touch              = helicopter_rotor_touch_hitbox;
	hitbox.rotor_is = 1; //We are a rotor. Other rotors will ignore touching us. Brothers in arms.

	hitbox.bot_attack         = FALSE;
	hitbox.iscreature         = TRUE;
	hitbox.teleportable       = FALSE; // no teleporting for vehicles, too buggy
	hitbox.movetype           = MOVETYPE_NONE;
	hitbox.solid              = SOLID_TRIGGER;
	hitbox.deadflag           = DEAD_NO;
	hitbox.flags              = FL_NOTARGET;
	
	if (rotortype == 1)
		hitbox.think              = helicopter_rotor_think_noz; //For plane props
	else
		hitbox.think              = helicopter_rotor_think;
	
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

void aeroplane_prop_think_right()
{
	//For this version, No spin for z:
	local vector vorg;
		vorg = gettaginfo(self.owner, gettagindex(self.owner, "engine_right"));
	
	makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 0');
	setorigin(self, (vorg + (v_forward * self.rotoroffset_x) + (v_right * self.rotoroffset_y) + (v_up * self.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
}

void aeroplane_prop_think_left()
{
	//For this version, No spin for z:
	local vector vorg;
		vorg = gettaginfo(self.owner, gettagindex(self.owner, "engine_left"));
	
	makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 0');
	setorigin(self, (vorg + (v_forward * self.rotoroffset_x) + (v_right * self.rotoroffset_y) + (v_up * self.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
}



void aeroplane_prop_spawn_hitbox(float rotortype, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s)
{
	hitbox.owner              = vehic;
	
	hitbox.touch              = helicopter_rotor_touch_hitbox;
	hitbox.rotor_is = 1; //We are a rotor. Other rotors will ignore touching us. Brothers in arms.

	hitbox.bot_attack         = FALSE;
	hitbox.iscreature         = TRUE;
	hitbox.teleportable       = FALSE; // no teleporting for vehicles, too buggy
	hitbox.movetype           = MOVETYPE_NONE;
	hitbox.solid              = SOLID_TRIGGER;
	hitbox.deadflag           = DEAD_NO;
	hitbox.flags              = FL_NOTARGET;
	
	local vector vorg;

	if (rotortype == 1) {
		hitbox.think              = aeroplane_prop_think_left;
	vorg = gettaginfo(vehic, gettagindex(vehic, "engine_left"));
	} else {
		hitbox.think              = aeroplane_prop_think_right;
	vorg = gettaginfo(vehic, gettagindex(vehic, "engine_right"));
	}
	
	hitbox.nextthink = time;
	hitbox.netname = hitbox.owner.netname;
	setsize(hitbox, min_s, max_s);
		
	makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
	
	setorigin(hitbox, (vorg + (v_forward * fwd_s) + (v_right * right_s) + (v_up * up_s))); //Forward X qunits, up_s
	hitbox.rotoroffset_x = fwd_s;
	hitbox.rotoroffset_y = right_s;
	hitbox.rotoroffset_z = up_s;
	
	hitbox.damageforcescale = 0.03;
	//hitbox.ballistics_density = autocvar_g_ballistics_density_metal;
}



// not really propeller stuff, but lazy
void helicopter_delugegun_add (entity vehic, string mountspot) {
	if (vehic.spawnflags & 32) {
		//delugegun
		vehic.bomb11 = spawn();
		vehic.bomb11.colormap = vehic.colormap;
		_setmodel(vehic.bomb11,"models/mountedguns/delugegun.iqm");
		setattachment(vehic.bomb11, vehic, mountspot);
		
		vehic.bomb11.angles_z = -90; //So ammo hose travels into fuselage
	}
}

void helicopter_delugegun_add2 (entity vehic, string mountspot) {
	if (vehic.spawnflags & 32) {
		//delugegun
		vehic.bomb12 = spawn();
		vehic.bomb12.colormap = vehic.colormap;
		_setmodel(vehic.bomb12,"models/mountedguns/delugegun.iqm");
		setattachment(vehic.bomb12, vehic, mountspot);
		
		vehic.bomb12.angles_z = 90; //So ammo hose travels into fuselage
	}
}


void helicopter_delugegun(entity gun, entity pilot, entity gunmount)
{
   if (gun.spawnflags & 32) {
	if(pilot.BUTTON_ATCK)
		{
			mg_deluge_fire(gun, pilot, gunmount);
		} else {
			vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_mountedgun_deluge_machinegun_ammo_max,
											   autocvar_g_mountedgun_deluge_machinegun_ammo_regen_pause,
											   autocvar_g_mountedgun_deluge_machinegun_ammo_regen, frametime, false);
		}
   }
}
#endif
