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

void fishmissile(entity this);
void fishcharge(entity this);
void player_fish12(entity this) { set_anim(this, 12, player_run); this.weaponentity.m_frame = 12; }
void player_fish11(entity this) { set_anim(this, 11, player_fish12); this.weaponentity.m_frame = 11; }
void player_fish10(entity this) { set_anim(this, 10, player_fish11); this.weaponentity.m_frame = 10; }
void player_fish9(entity this) { set_anim(this, 9, player_fish10); this.weaponentity.m_frame = 9; fishmissile(this); }
void player_fish8(entity this) { set_anim(this, 8, player_fish9); this.weaponentity.m_frame = 8; }
void player_fish7(entity this) { set_anim(this, 7, player_fish8); this.weaponentity.m_frame = 7; }
void player_fish6(entity this) { set_anim(this, 6, player_fish7); this.weaponentity.m_frame = 6; }
void player_fish5(entity this)
{
	set_anim(this, 5, player_fish6);
	this.weaponentity.m_frame = 5;
	if(this.weaponentity.fish_time < SUPERFISHTIME)
		_sound(this, CH_WEAPON_SINGLE, "weapons/whush.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/mega.wav", 1, ATTN_NORM);
}
void player_fish4(entity this) { set_anim(this, 4, fishcharge); fishcharge(this); }
void player_fish3(entity this) { set_anim(this, 3, player_fish4); this.weaponentity.m_frame = 3; }
void player_fish2(entity this) { set_anim(this, 2, player_fish3); this.weaponentity.m_frame = 2; }
void player_fish1(entity this) { set_anim(this, 1, player_fish2); this.weaponentity.m_frame = 1; }

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

void shockwave(vector point, float radius, float kick)
{
	float damgidx = kick / radius;
	entity e = findradius(point, radius);
	while(e)
	{
		if(e.move_movetype != MOVETYPE_NONE && e.classname != "door")
		{
			vector temp = e.origin - point;
			if(vdist(temp, <, radius))
			{
				float punch = kick - (damgidx * vlen(temp));
				temp = normalize(temp);
				temp = temp * punch;
				UNSET_ONGROUND(e);
				e.velocity = e.velocity + temp;
			}
		}
		e = e.chain;
	}
}

void fishtouch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float hurt = 0;
	if(this.fish_time == SUPERFISHTIME)
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
		shockwave(shockorg, 500, 2000);
		return;
	}

	if(this.fish_time > 2.4)
	{
		if(toucher.takedamage)
		{
			set_movetype(this, MOVETYPE_BOUNCE);
			//this.solid = SOLID_BBOX;
			
			hurt = 23 * (1.4 + this.fish_time);
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
		hurt = 13* (1 + this.fish_time);
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

void fishmissile(entity this)
{
	this.ammo_rockets -= 1;

	entity fish = spawn();
	fish.owner = this;
	fish.projectiledeathtype = WEP_FISH.m_id;
	fish.model = "feesh.mdl";
	if(this.fish_time > 4 && this.fish_time < SUPERFISHTIME)
		this.fish_time = 4;
	if(this.fish_time >= SUPERFISHTIME)
		this.fish_time = SUPERFISHTIME;
	set_movetype(fish, MOVETYPE_FLYMISSILE);
	fish.solid = SOLID_BBOX;
	if(this.fish_time == SUPERFISHTIME)
	{
		fish.skin = 1;
		fish.effects |= EF_DIMLIGHT;
	}
	makevectors(this.v_angle);
	fish.velocity = qc_aim(this, 450 + (250 * this.fish_time));
	fish.velocity = fish.velocity * (450 + (250 * this.fish_time));
	if(this.fish_time == 20)
		fish.velocity *= 0.5;
	fish.angles = vectoangles(fish.velocity);
	fish.angles_x = crandom()*360;
	fish.avelocity_x = -400 - (200 * this.fish_time);
	if(this.fish_time == 20)
		fish.avelocity_x *= 0.5;
	fish.movedir = fish.velocity;
	_setmodel(fish, "progs/feesh.mdl");
	setsize(fish, '0 0 0','0 0 0');
	settouch(fish, fishtouch);
	vector org = this.origin + '0 0 20'; // v_forward * 40, not used because it goes through mobs!
	setorigin(fish, org);
	fish.fish_time = this.fish_time;
	this.fish_time = 0;
	fish.cnt = time + 10;
	setthink(fish, fishthink);
	fish.nextthink = time + 0.01;
}

void fishcharge(entity this)
{
	if(this.health < 1 || intermission_running)
		return;

	if(this.fish_time > (SUPERFISHTIME + 3))
		this.fish_time = SUPERFISHTIME + 3;
	this.fish_time += 0.1;
	this.weaponentity.m_frame = 4;
	this.nextthink = time + 0.1;
	this.attack_finished = time + 0.5;
	if(this.button0)
		setthink(this, fishcharge);
	else
		setthink(this, player_fish5);
}

void fishthrow(entity this)
{
	if(this.weaponentity.m_frame != 4)
		player_fish1(this);
}

METHOD(Fish, wr_think, void(entity thiswep, entity actor, int fire))
{
	// TODO: blake sound when switching to the fish?

	if(fire & 1)
	//if(thiswep.wr_checkammo1(thiswep, actor))
	{
		_sound(actor, CH_WEAPON_SINGLE, "weapons/ax1.wav", 1, ATTN_NORM);
		actor.weaponentity.m_frame = 1;
		player_fish1(actor);
		actor.attack_finished = time + 1;
	}
}
METHOD(Fish, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(Fish, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
