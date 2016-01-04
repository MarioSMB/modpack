#ifdef IMPLEMENTATION
#ifdef SVQC
#include "tankt27.qh"

void tankt27_vehicles_damage_hitboxft(entity this, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(this.vehicle_health <= 0)
	{
		//print("FWD DMG\n");
		this.event_damage       = func_null;
		this.takedamage         = DAMAGE_NO;
			this.touch              = func_null;
			this.think              = func_null;
			this.deadflag           = DEAD_DEAD;
			this.solid      = SOLID_NOT;
	} else {
		this.dmg_time = time;
	
		//damage = vehicles_evaldamage(damage, deathtype);
		
		//if(this.vehicle_tankresists == 1) {
				//damage = vehicles_evaltankdamage(damage, deathtype);
			//}
		
		this.vehicle_health -= damage;
		
		//if(sound_allowed(MSG_BROADCAST, attacker))
					//spamsound (this, CH_PAIN, "object/impact_metal_3.ogg", VOL_BASE, ATTN_NORM);
			
		//print("DMG\n");
	}
}

void vehicles_damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force);
void tankt27_vehicles_damage_hitboxbk(entity this, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(this.vehicle_health <= 0)
	{
		this.event_damage       = func_null;
		this.takedamage         = DAMAGE_NO;
			this.touch              = func_null;
			this.think              = func_null;
			this.deadflag           = DEAD_DEAD;
			this.solid      = SOLID_NOT;
	} else {
		//float ardamage; //Damage to armor
		this.dmg_time = time;
		//ardamage = vehicles_evaldamage(damage, deathtype);
		this.vehicle_health -= damage;
		
		//if(sound_allowed(MSG_BROADCAST, attacker))
					//spamsound (this, CH_PAIN, "object/impact_metal_4.ogg", VOL_BASE, ATTN_NORM);
		
		this = this.owner;
		vehicles_damage(this, inflictor, attacker, damage, deathtype, hitloc, force);
		
		//print("BKDMG\n");
	}
}

void tankt27_vehicles_touch_hitbox()
{
	self = self.owner;
	self.touch();
	//tankt27_vehicles_touch2(); //This way self.subordinate is tested for max_z rather than self
}

void tankt27_impact_hitbox()
{
	self = self.owner;
	if(self.play_time < time) {
		Vehicle info = Vehicles_from(self.vehicleid);
		info.vr_impact(info, self);
	}
	//self.vehicle_impact();
}

void tankt27_hitbox_die(entity hitbox)
{
    hitbox.health             = 0;
    hitbox.event_damage       = func_null;
    hitbox.takedamage         = DAMAGE_NO;
    hitbox.touch              = func_null;
    hitbox.think              = func_null;
    hitbox.deadflag           = DEAD_DEAD;
    hitbox.movetype           = MOVETYPE_NONE;
    hitbox.solid      = SOLID_NOT;
}

void follow_sameorigin(entity e, entity to);
void tankt27_spawn_hitbox(float position, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float vehic_health)
{
    hitbox.owner              = vehic;
    if (position == 1) {
    	//Back armor
    	hitbox.touch              = tankt27_vehicles_touch_hitbox;
    	hitbox.event_damage       = tankt27_vehicles_damage_hitboxbk;
    } else {
    	//Front armor
    	hitbox.touch              = tankt27_vehicles_touch_hitbox;
    	hitbox.event_damage       = tankt27_vehicles_damage_hitboxft;
	//hitbox.vehicle_tankresists = 1; //Front armor gets extra protections
    }
   // hitbox.buff_wont_ignite = vehic.buff_wont_ignite;
    //hitbox.bot_attack         = true;
    hitbox.iscreature         = true;
    hitbox.teleportable       = false; // no teleporting for vehicles, too buggy
    hitbox.damagedbycontents	= true;
    hitbox.movetype           = MOVETYPE_WALK;
    hitbox.solid              = SOLID_SLIDEBOX;
    hitbox.takedamage         = DAMAGE_AIM;
    hitbox.deadflag           = DEAD_NO;
    //hitbox.bot_attack         = true;
    hitbox.flags              = FL_NOTARGET;
    hitbox.think              = func_null;
    hitbox.vehicle_health = vehic_health;
    setsize(hitbox, min_s, max_s);
    makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
    setorigin(hitbox, (vehic.origin + v_forward * fwd_s)); //Forward X qunits
    follow_sameorigin(hitbox, vehic); //Follow vehic
    
    hitbox.damageforcescale = 0.03;
    //hitbox.ballistics_density = autocvar_g_ballistics_density_metal;
}

#endif
#endif
