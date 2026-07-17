#include "multi_missile_launcher.qh"

#ifdef SVQC
PRECACHE(MultiMissileLauncher)
{
	precache_model("progs/v_mmml.mdl");
	precache_model("progs/g_mmml.mdl");

	precache_model("progs/s_explode_smoke_64x.spr");
	precache_model("progs/s_explode_fire_64x.spr");

	precache_sound("mmml/fire1.wav");
	precache_sound("mmml/fire2.wav");
	precache_sound("mmml/fire3.wav");
	precache_sound("mmml/fire4.wav");
	precache_sound("mmml/silo_latch.wav");
	precache_sound("mmml/silo_load.wav");
	precache_sound("mmml/silo_load2.wav");
	precache_sound("mmml/silo_clunk.wav");
	precache_sound("mmml/silo_clunk2.wav");

	precache_sound("weapons/r_exp3.wav");
}

void W_FireMultiMissileLauncher(entity this, vector offset, int ammo_amount, .entity weaponentity);
void wep_mmml_anim(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	if(actor.ammo_rockets < 1)
	{
		ATTACK_FINISHED(actor, weaponentity) = time + 1;
		W_SwitchWeapon(actor, w_getbestweapon(actor, weaponentity), weaponentity);
		return;
	}

	switch(this.m_frame)
	{
		case 12: W_FireMultiMissileLauncher(actor, '0 -2 -8', 1, weaponentity); break;
		case 14: W_FireMultiMissileLauncher(actor, '0 2 -8', 0, weaponentity); break;
		case 16: W_FireMultiMissileLauncher(actor, '0 6 -8', 1, weaponentity); break;
		case 18: W_FireMultiMissileLauncher(actor, '0 -6 -12', 0, weaponentity); break;
		case 20: W_FireMultiMissileLauncher(actor, '0 -2 -12', 1, weaponentity); break;
		case 22: W_FireMultiMissileLauncher(actor, '0 2 -12', 0, weaponentity); break;
		case 24:
		{
			W_FireMultiMissileLauncher(actor, '0 6 -12', 1, weaponentity);
			_sound(actor, CH_WEAPON_B, "mmml/silo_clunk.wav", 1, ATTN_NORM);
			_sound(actor, CH_WEAPON_B, "mmml/silo_clunk2.wav", 1, ATTN_NORM);
			break;
		}
		case 28: _sound(actor, CH_WEAPON_B, "mmml/silo_load.wav", 1, ATTN_NORM); break;
		case 30: _sound(actor, CH_WEAPON_B, "mmml/silo_load2.wav", 1, ATTN_NORM); break;
	}

	if(this.m_frame >= 42)
	{
		this.m_frame = 10;
		w_ready(this);
		return;
	}
	this.m_frame += 1;

	wep_set_anim(this, this.m_frame, wep_mmml_anim);
	this.weapon_nextthink = time + 0.05;
}

void BecomeMiniBlast(entity this, int blasttype)
{
	// no extra explosion effects for minis, too much spam, sprites only
	entity exp = spawn();
	exp.nextthink = time;
	setthink(exp, s_explode1);
	if(blasttype == 2)
		_setmodel(exp, "progs/s_explode_smoke_64x.spr");
	else
		_setmodel(exp, "progs/s_explode_fire_64x.spr");
	setsize(exp, '0 0 0', '0 0 0');
	setorigin(exp, this.origin);

	delete(this);
}

void spiralrocket_touch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
#if 0
		if(this.buddy)
			delete(this.buddy);
#endif
		delete(this);
		return;
	}

	float rdamg = 60;

	if(toucher.takedamage)
	{
		float damg = 50 + random() * 10;
		if(Resist_Explosions(toucher))
			damg *= 0.5;
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}
			
	// don't do radius damage to the toucher, because all the damage
	// was done in the impact.
	// Radius damage type will always be EXPLOSION
	vector prev_vel = this.velocity;
	//this.velocity = '0 0 0';
	T_RadiusDamage(this, this.owner, rdamg, this.projectiledeathtype, toucher);

	this.origin = this.origin - 8*normalize(prev_vel);

	_sound(this, CH_SHOTS, "weapons/r_exp3.wav", 1, ATTN_NORM);

	if(Resist_Explosions(toucher))
		BecomeMiniBlast(this, 2); // weak, no TE_effects
	else
		BecomeMiniBlast(this, 0); // normal, no TE_effects
}

#if 0
void spiralrocket_think(entity this)
{
	if(time > this.cnt)
	{
		if(this.buddy)
			delete(this.buddy);
		delete(this);
		return;
	}

	entity ptr = this.buddy;
	float interval = PHYS_INPUT_FRAMETIME;
	if(interval == 0)
		interval = 0.025;

	ptr.ideal_yaw += 36;

	vector dest = ptr.origin + ptr.velocity * interval + cos(ptr.ideal_yaw)*ptr.dest1*6 + sin(ptr.ideal_yaw)*ptr.dest2*6;

	this.velocity = (dest - this.origin)/interval;
	this.avelocity_z = -540;

	this.nextthink = time;

	UpdateCSQCProjectile(this);
}
#endif

void W_FireMultiMissileLauncher(entity this, vector offset, int ammo_amount, .entity weaponentity)
{
	this.punchangle_x = -2 * autocvar_sv_quake_recoil;
	this.effects |= EF_MUZZLEFLASH;

	W_TakeAmmo(this, IT_ROCKETS, ammo_amount);

	makevectors(this.v_angle);
	vector org = W_Shotorg(this, weaponentity) + v_up * offset.z + v_right * offset.y;
	vector dir = qc_aim(this, 1000);

	float r = random();
	if(r < 0.25)
		_sound(this, CH_WEAPON_A, "mmml/fire1.wav", 1, ATTN_NORM);
	else if(r < 0.5)
		_sound(this, CH_WEAPON_A, "mmml/fire2.wav", 1, ATTN_NORM);
	else if(r < 0.75)
		_sound(this, CH_WEAPON_A, "mmml/fire3.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_A, "mmml/fire4.wav", 1, ATTN_NORM);

#if 0
	// for direction
	// TODO: better way to do this?
	entity pointer = new(spiralrocket_pointer);
	pointer.owner = pointer.realowner = this;
	set_movetype(pointer, MOVETYPE_NOCLIP);
	pointer.solid = SOLID_NOT;
	setorigin(pointer, org);
	setthink(pointer, SUB_Remove);
	pointer.nextthink = time + 6;
	pointer.velocity = dir * 1000;
	vector ang = vectoangles(dir);
	makevectors(vec3(-ang.x, ang.y, ang.z));
	pointer.dest1 = v_right;
	pointer.dest2 = v_up;
#endif

	entity newmis = spawn();
	newmis.flags = FL_PROJECTILE;
	newmis.projectiledeathtype = WEP_MMML.m_id;
	newmis.clipgroup = (this.clipgroup) ? this.clipgroup : etof(this);
	newmis.owner = newmis.realowner = this;
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;
	newmis.classname = "missile";

	newmis.velocity = dir * 1000;
	newmis.angles = vectoangles(dir);
	settouch(newmis, spiralrocket_touch);
#if 0
	newmis.cnt = time + 5;
	newmis.nextthink = time + 0.1;
	setthink(newmis, spiralrocket_think);
#else
	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
#endif

	//_setmodel(newmis, "progs/proj_missile.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);

#if 0
	newmis.buddy = pointer;
	pointer.buddy = newmis;
#endif

	IL_PUSH(g_projectiles, newmis);

#if 0
	CSQCProjectile(newmis, false, PROJECTILE_MISSILE, true);
#else
	CSQCProjectile(newmis, true, PROJECTILE_MISSILE, true);
#endif
}

METHOD(MultiMissileLauncher, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		actor.(weaponentity).m_frame = 10; // will be increased by 1 instantly
		wep_mmml_anim(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 1.6);
	}
}
METHOD(MultiMissileLauncher, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	bool ammo_amount = actor.ammo_rockets >= 4;
	return ammo_amount;
}
METHOD(MultiMissileLauncher, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(MultiMissileLauncher, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
