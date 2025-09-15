#include "fish.qh"

#ifdef SVQC
PRECACHE(Fish)
{
	precache_model("progs/v_feesh.mdl");
	precache_model("progs/g_feesh.mdl");

	precache_model("progs/feesh.mdl");
	precache_sound("weapons/whush.wav");
	precache_sound("weapons/mega.wav");
	precache_sound("weapons/hit1.wav");
	precache_sound("weapons/hit2.wav");
	precache_sound("weapons/ax1.wav");
	precache_sound("weapons/boom.wav");
	precache_sound("weapons/shink.wav");
	precache_sound("weapons/fly.wav");
}

const float SUPERFISHTIME = 7.1; // time to fire super rocket megafish
.float fish_time;

void fishmissile(entity this, .entity weaponentity);
void fishcharge(entity this);
void player_fish12(entity this) { set_anim(this, 12, player_run); }
void player_fish11(entity this) { set_anim(this, 11, player_fish12); }
void player_fish10(entity this) { set_anim(this, 10, player_fish11); }
void player_fish9(entity this) { set_anim(this, 9, player_fish10); }
void player_fish8(entity this) { set_anim(this, 8, player_fish9); }
void player_fish7(entity this) { set_anim(this, 7, player_fish8); }
void player_fish6(entity this) { set_anim(this, 6, player_fish7); }
void player_fish5(entity this) { set_anim(this, 5, player_fish6); }
void player_fish4(entity this) { set_anim(this, 4, player_fish5);}
void player_fish3(entity this) { set_anim(this, 3, player_fish4); }
void player_fish2(entity this) { set_anim(this, 2, player_fish3); }
void player_fish1(entity this) { set_anim(this, 1, player_fish2); }

void wep_fish_fish12(entity this) { wep_set_anim(this, 12, w_ready); }
void wep_fish_fish11(entity this) { wep_set_anim(this, 11, wep_fish_fish12); }
void wep_fish_fish10(entity this) { wep_set_anim(this, 10, wep_fish_fish11); }
void wep_fish_fish9(entity this) { wep_set_anim(this, 9, wep_fish_fish10); fishmissile(this.owner, this.weaponentity_fld); }
void wep_fish_fish8(entity this) { wep_set_anim(this, 8, wep_fish_fish9); }
void wep_fish_fish7(entity this) { wep_set_anim(this, 7, wep_fish_fish8); }
void wep_fish_fish6(entity this) { wep_set_anim(this, 6, wep_fish_fish7); }
void wep_fish_fish5(entity this)
{
	wep_set_anim(this, 5, wep_fish_fish6);
	if(this.fish_time < SUPERFISHTIME || deathmatch)
		_sound(this.owner, CH_WEAPON_SINGLE, "weapons/whush.wav", 1, ATTN_NORM);
	else
		_sound(this.owner, CH_WEAPON_SINGLE, "weapons/mega.wav", 1, ATTN_NORM);
}
void wep_fish_fish4(entity this) { wep_set_anim(this, 4, fishcharge); }
void wep_fish_fish3(entity this) { wep_set_anim(this, 3, wep_fish_fish4); }
void wep_fish_fish2(entity this) { wep_set_anim(this, 2, wep_fish_fish3); }
void wep_fish_fish1(entity this) { wep_set_anim(this, 1, wep_fish_fish2); }

void fishbounce(entity this, entity toucher)
{
	if(toucher.health)
	{
		float hurt = 10* (1 + this.fish_time);
		spawn_touchblood(this, hurt, toucher);
		T_Damage(toucher, this, this.owner, hurt, this.projectiledeathtype);
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/hit1.wav", 0.8, ATTN_NORM);
}

void shockwave(entity proj, vector point, float radius, float kick)
{
	float damgidx = kick / radius;
	FOREACH_ENTITY_RADIUS(point, radius, it.takedamage && it.move_movetype != MOVETYPE_NONE && it.classname != "door",
	{
		if(it != proj.owner && it.clipgroup && it.clipgroup == proj.clipgroup)
			continue;
		vector temp = it.origin - point;
		if(vdist(temp, <, radius))
		{
			float punch = kick - (damgidx * vlen(temp));
			temp = normalize(temp);
			temp = temp * punch;
			UNSET_ONGROUND(it);
			it.velocity += temp;
		}
	});
}

void fishtouch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float hurt = 0;
	if(this.fish_time == SUPERFISHTIME && !deathmatch)
	{
		hurt = 300;
		T_Damage(toucher, this, this.owner, hurt, this.projectiledeathtype);
		T_RadiusDamage(this, this.owner, hurt, this.projectiledeathtype, toucher);

		te_explosion(this.origin);
		_sound(this, CH_WEAPON_SINGLE, "weapons/boom.wav", 1, ATTN_NORM);
		BecomeExplosion(this);
		//setthink(this, SUB_Remove);
		//this.nextthink = 0.2;
		vector shockorg = this.origin - '0 0 30';
		shockwave(this, shockorg, 500, 2000);
		return;
	}

	if(this.fish_time > 2.4)
	{
		if(toucher.takedamage)
		{
			set_movetype(this, MOVETYPE_BOUNCE);
			//this.solid = SOLID_BBOX;
			
			hurt = 50 * (1.4 + this.fish_time);
			spawn_touchblood(this, hurt * 90, toucher);
			T_Damage(toucher, this, this.owner, hurt, this.projectiledeathtype);
			//this.velocity = this.movedir;
			return;
		}
		else
		{
			_sound(this, 3, "weapons/shink.wav", 1, ATTN_NORM);
			this.velocity = '0 0 0';
			this.avelocity = '0 0 0';
			this.nextthink = time + 60;
			setthink(this, SUB_Remove);
			settouch(this, missile_touchremove);
		}
		return;
	}
	if(toucher.takedamage)
	{
		hurt = 50* (1 + this.fish_time);
		spawn_touchblood(this, hurt, toucher);
		T_Damage(toucher, this, this.owner, hurt, this.projectiledeathtype);
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/hit2.wav", 1, ATTN_NORM);
	set_movetype(this, MOVETYPE_BOUNCE);
	this.avelocity_x = this.avelocity_x + crandom() * 200;
	this.avelocity_y = this.avelocity_y + crandom() * 200;
	this.avelocity_z = this.avelocity_z + crandom() * 200;
	//this.nextthink = time + 3;
	//setthink(this, SUB_Remove);
	settouch(this, fishbounce);
}

void fishthink(entity this)
{
	if(time > this.cnt)
	{
		delete(this);
		return;
	}

	if(this.avelocity != '0 0 0')
		_sound(this, CH_WEAPON_SINGLE, "weapons/fly.wav", 1, ATTN_NORM);
	this.nextthink = time + 0.396;
	if(this.move_movetype == MOVETYPE_NOCLIP) // how and why?
		set_movetype(this, MOVETYPE_FLYMISSILE);
}

void fishmissile(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, ammo_rockets, 1);

	entity fish = spawn();
	fish.flags = FL_PROJECTILE;
	fish.owner = this;
	fish.fish_time = this.(weaponentity).fish_time;
	fish.projectiledeathtype = WEP_FISH.m_id;
	fish.clipgroup = this.clipgroup;
	fish.model = "feesh.mdl";
	if(fish.fish_time > 4 && fish.fish_time < SUPERFISHTIME)
		fish.fish_time = 4;
	if(fish.fish_time >= SUPERFISHTIME)
		fish.fish_time = SUPERFISHTIME;
	set_movetype(fish, MOVETYPE_FLYMISSILE);
	fish.solid = SOLID_BBOX;
	if(!deathmatch && fish.fish_time == SUPERFISHTIME)
	{
		fish.skin = 1;
		fish.effects |= EF_DIMLIGHT;
	}
	makevectors(this.v_angle);
	fish.velocity = qc_aim(this, 450 + (250 * fish.fish_time));
	fish.velocity = fish.velocity * (450 + (250 * fish.fish_time));
	if(fish.fish_time == 20)
		fish.velocity *= 0.5;
	fish.angles = vectoangles(fish.velocity);
	fish.angles_x = crandom()*360;
	fish.avelocity_x = -400 - (200 * fish.fish_time);
	if(fish.fish_time == 20)
		fish.avelocity_x *= 0.5;
	fish.movedir = fish.velocity;
	fish.weaponentity_fld = weaponentity;
	_setmodel(fish, "progs/feesh.mdl");
	setsize(fish, '0 0 0','0 0 0');
	settouch(fish, fishtouch);
	vector org = W_Shotorg(this, weaponentity); // v_forward * 40, not used because it goes through mobs!
	setorigin(fish, org);
	this.(weaponentity).fish_time = 0;
	fish.cnt = time + 10;
	setthink(fish, fishthink);
	fish.nextthink = time + 0.01;

	IL_PUSH(g_projectiles, fish);
}

void fishcharge(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(actor.health < 1 || intermission_running)
		return;

	if(this.fish_time > (SUPERFISHTIME + 3))
		this.fish_time = SUPERFISHTIME + 3;
	this.fish_time += 0.1;
	this.m_frame = 4;
	ATTACK_FINISHED(actor, weaponentity) = time + 1;
	if(actor.button0)
		wep_set_anim(this, 4, fishcharge);
	else
		wep_set_anim(this, 4, wep_fish_fish5);
}

METHOD(Fish, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	// TODO: blake sound when switching to the fish?

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		_sound(actor, CH_WEAPON_SINGLE, "weapons/ax1.wav", 1, ATTN_NORM);
		actor.(weaponentity).m_frame = 1;
		actor.(weaponentity).fish_time = 0;
		if(IS_PLAYER(actor))
			player_fish1(actor);
		wep_fish_fish1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 1);
	}
}
METHOD(Fish, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(Fish, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Fish, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
