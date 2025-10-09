#include "light_disc.qh"

#ifdef SVQC
void player_disc4(entity this) { set_animofs(this, anim_player_axatt1, 4, player_run); }
void player_disc3(entity this) { set_animofs(this, anim_player_axatt1, 3, player_disc4); }
void player_disc2(entity this) { set_animofs(this, anim_player_axatt1, 2, player_disc3); }
void player_disc1(entity this) { set_animofs(this, anim_player_axatt1, 1, player_disc2); }

void wep_disc_shot4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_disc_shot3(entity this) { wep_set_anim(this, 3, wep_disc_shot4); }
void wep_disc_shot2(entity this) { wep_set_anim(this, 2, wep_disc_shot3); }
void wep_disc_shot1(entity this) { wep_set_anim(this, 1, wep_disc_shot2); }

PRECACHE(LightDisc)
{
	precache_model("progs/light_disc.mdl");
	precache_model("progs/v_light_disc.mdl");
	precache_model("progs/g_light_disc.mdl");

	precache_sound("weapons/disc_throw.wav");
	precache_sound("weapons/disc_catch.wav");
}

void disc_touch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(toucher.takedamage)
	{
		if(time >= this.pain_finished)
		{
			float damg = (this.dmg) ? this.dmg : 40;
			spawn_touchblood(this, damg, toucher);
			T_Damage(toucher, this, this.realowner, damg, this.projectiledeathtype);
			this.pain_finished = time + 0.1; // prevent instakills on return trip!
		}
		//delete(this);
		this.count = time; // tell it to start going home
		return;
	}

	if(time > this.spamtime)
	{
		this.spamtime = time + 0.1;
		sound(this, CH_WEAPON_SINGLE, SND_LIGHT_DISC_BOUNCE, 1, ATTN_NORM);
		//te_gunshot(this.origin);
		Send_Effect(EFFECT_LIGHT_DISC_BOUNCE, this.origin, normalize(this.velocity) * 16, 1);
	}
}

void disc_think(entity this)
{
	this.nextthink = time;
	if(this.cnt < time || !this.owner || this.owner.health < 1)
	{
		delete(this);
		return;
	}

	if(time >= this.count)
	{
		vector vtemp = this.owner.origin + '0 0 10';
		if(vdist(vtemp - this.origin, <=, 24))
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/disc_catch.wav", 1, ATTN_NORM);
			delete(this);
			return;
		}
		vector dir = normalize(vtemp - this.origin);
		this.velocity = dir * this.speed;
		this.dphitcontentsmask &= ~DPCONTENTS_SOLID;
		//UpdateCSQCProjectile(this);
	}

	//UNSET_ONGROUND(this);
	//this.velocity = this.oldvelocity;
	this.angles = vectoangles(this.velocity);
}

void W_FireLightDisc(entity this, .entity weaponentity)
{
	//this.punchangle_x = -2;

	_sound(this, CH_WEAPON_SINGLE, "weapons/disc_throw.wav", 1, ATTN_NORM);

	entity disc = spawn();
	disc.flags = FL_PROJECTILE;
	disc.projectiledeathtype = WEP_LIGHT_DISC.m_id;
	disc.clipgroup = this.clipgroup;
	disc.owner = disc.realowner = this;
	set_movetype(disc, MOVETYPE_BOUNCEMISSILE);
	disc.solid = SOLID_BBOX;
	disc.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	disc.classname = "disc";
	disc.effects = EF_FULLBRIGHT;

	makevectors(this.v_angle);
	disc.speed = 700;
	vector dir = qc_aim(this, disc.speed);
	disc.velocity = dir * disc.speed;
	disc.oldvelocity = disc.velocity;
	disc.angles = vectoangles(disc.velocity);
	settouch(disc, disc_touch);
	disc.cnt = time + 8; // deletion time
	disc.count = time + 2; // return time
	disc.dmg = 30;
	disc.nextthink = time;
	setthink(disc, disc_think);

	_setmodel(disc, "progs/light_disc.mdl");
	setsize(disc, '0 0 0', '0 0 0');
	vector org = W_Shotorg(this, weaponentity); // v_forward * 8, not used because it goes through mobs!
	setorigin(disc, org);

	IL_PUSH(g_projectiles, disc);
}

// TODO: per weapon?!
int lightdisc_getcount(entity actor)
{
	int discs = 0;
	IL_EACH(g_projectiles, it.classname == "disc" && it.owner == actor,
	{
		discs += 1;
	});
	return discs;
}

METHOD(LightDisc, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	if(lightdisc_getcount(actor) < 5)
	{
		W_FireLightDisc(actor, weaponentity);
		if(IS_PLAYER(actor))
			player_disc1(actor);
		wep_disc_shot1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.3);
	}
}
METHOD(LightDisc, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // does not use ammo
}
METHOD(LightDisc, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(LightDisc, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
