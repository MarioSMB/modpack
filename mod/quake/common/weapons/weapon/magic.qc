#include "magic.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void wep_magic_shot4(entity this) { wep_set_anim(this, 9, w_ready); }
void wep_magic_shot3(entity this) { wep_set_anim(this, 8, wep_magic_shot4); }
void wep_magic_shot2(entity this) { wep_set_anim(this, 7, wep_magic_shot3); }
void wep_magic_shot1(entity this) { wep_set_anim(this, 6, wep_magic_shot2); this.owner.effects |= EF_MUZZLEFLASH; }

PRECACHE(Magic)
{
	precache_model("progs/g_magic.mdl");
	precache_model("progs/v_magic.mdl");

	precache_model("progs/v_magic_fire.mdl");
	precache_model("progs/v_magic_stormcloud.mdl");
	precache_model("progs/v_magic_bubble.mdl");

	precache_sound("weapons/magic_switch.wav");
	precache_sound("weapons/boobies.wav");

	precache_sound("weapons/magic_fire_shoot1.wav");
	precache_sound("weapons/magic_fire_shoot2.wav");
	precache_sound("weapons/magic_fire_shoot3.wav");
    precache_sound("weapons/magic_fire_explode.wav");

    precache_model("progs/stormcloud.mdl");
    precache_sound("weapons/magic_stormcloud_hit.wav");
    precache_sound("weapons/magic_stormcloud_shoot1.wav");
    precache_sound("weapons/magic_stormcloud_shoot2.wav");

    precache_model("progs/magic_bubble.mdl");
    precache_sound("weapons/magic_bubble_shoot.wav");
    precache_sound("weapons/magic_bubble_deflect.wav");
    precache_sound("weapons/magic_bubble_pop1.wav");
    precache_sound("weapons/magic_bubble_pop2.wav");
    precache_sound("weapons/magic_bubble_pop3.wav");
}

float W_Magic_AttackRate(entity actor, .entity weaponentity)
{
	int magictype = STAT(MAGIC_TYPE, actor);
	float attack_delay = 0.5;
	switch(magictype)
	{
		default:
		case 0: attack_delay = 0.75; break;
		case 1: attack_delay = 1; break;
		case 2: attack_delay = 1.25; break;
	}
	return attack_delay;
}

void magic_fire_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = (this.dmg) ? this.dmg : 15;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.takedamage)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		if(Damage_ValidTarget(toucher, this.owner))
		{
			float burntime = 4;
			// only add more burn time if there isn't already a longer timer running!
			float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, toucher);
			if((time + burntime) > curtime)
				StatusEffects_apply(STATUSEFFECT_Burning, toucher, time + burntime, 0);
		}
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	if(this.noise && this.noise != "")
		_sound(this, CH_WEAPON_SINGLE, this.noise, 1, ATTN_NORM);

	this.origin = this.origin - 8 * normalize(this.velocity);

	//Send_Effect(EFFECT_MAGIC_FIRE, this.origin, '0 0 0', 1);
	te_explosion2(this.origin, 230, 5);

	delete(this);
}

void magic_fire_launch(entity this, .entity weaponentity)
{
	vector org = W_Shotorg(this, weaponentity) - '0 0 12';
	vector dir = qc_aim(this, 800);

	entity newmis = launch_spike(this, org, dir);
	newmis.scale = 2;
	//setmodel(newmis, MDL_LAVABALL);
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.dmg = 25;
	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	newmis.velocity = dir * 800;
	newmis.weaponentity_fld = weaponentity;
	newmis.projectiledeathtype = WEP_MAGIC.m_id;

	newmis.noise = "weapons/magic_fire_explode.wav";
	float r = random();
	if(r < 0.33)
		_sound(this, CH_WEAPON_SINGLE, "weapons/magic_fire_shoot1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(this, CH_WEAPON_SINGLE, "weapons/magic_fire_shoot2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/magic_fire_shoot3.wav", 1, ATTN_NORM);
	settouch(newmis, magic_fire_touch);
	newmis.avelocity = randomvec() * 180;

	CSQCProjectile(newmis, true, PROJECTILE_MAGIC_FIREBALL, true);
}

void magic_stormcloud_think(entity this)
{
	if(time >= this.wait)
	{
		Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 0', 1);
		delete(this);
		return;
	}
	this.nextthink = time + 0.1;

	this.frame += 1;
	if(this.frame > 9)
		this.frame = 0;

	int cont = Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(this.origin));
	if(cont & DPCONTENTS_LIQUIDSMASK)
	{
		Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 0', 1);
		T_RadiusDamage(this, this.owner, 50, this.projectiledeathtype, NULL);
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return;
	}

	bool hitenemy = false;
	FOREACH_ENTITY_RADIUS(this.origin, 100, true,
	{
		vector org = (it.absmin + it.absmax) * 0.5;
		if(org.z > this.origin_z || it.health <= 0 || !it.takedamage || it == this.owner || !Damage_ValidTarget(it, this.owner))
			continue;
		//SendCSQCLightningBeam(this.origin, it.origin);
		// may cause heavy lag when fired near water!
		//LightningDamage(this.origin, it.origin, this, 15, WEP_MAGIC.m_id);
		T_Damage(it, this, this.owner, 8, this.projectiledeathtype);
		hitenemy = true;
	});

	Send_Effect(EFFECT_STORMCLOUD, this.origin, '0 0 -250', 1);

	if(hitenemy) //&& random() < 0.8)
	{
		vector pos = this.origin + randomvec() * (random() * 20);
		vector newpos = pos;
		newpos.z -= random() * 80;
		SendCSQCLightningBeam(pos, newpos);
		_sound(this, CH_WEAPON_SINGLE, "weapons/magic_stormcloud_hit.wav", 0.5, ATTN_NORM);
	}
}

void magic_stormcloud_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	if(toucher.takedamage)
		return; // no reaction

	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 0', 1);

	delete(this);
}

void magic_stormcloud_launch(entity this, .entity weaponentity)
{
	vector org = W_Shotorg(this, weaponentity);
	vector dir = qc_aim(this, 50);

	entity newmis = launch_spike(this, org, dir);

	newmis.solid = SOLID_TRIGGER;
	newmis.dphitcontentsmask = DPCONTENTS_SOLID;
	settouch(newmis, magic_stormcloud_touch);
	newmis.wait = time + 10;
	newmis.projectiledeathtype = WEP_MAGIC.m_id;
	newmis.alpha = 0.8;
	newmis.velocity = dir * 50;
	newmis.angles_x = newmis.angles_z = 0; // only rotate on y axis
	_setmodel(newmis, "progs/stormcloud.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.frame = bound(0, floor(random() * 10), 10); // start at a random pos!
	setthink(newmis, magic_stormcloud_think);
	newmis.nextthink = time;

	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "weapons/magic_stormcloud_shoot1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/magic_stormcloud_shoot2.wav", 1, ATTN_NORM);
}

bool magic_bubble_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_MAGIC_BUBBLE);
	if(this.owner == to)
		sf |= BIT(0);
	else
		sf &= ~BIT(0);
	WriteByte(MSG_ENTITY, sf);

	if(sf & BIT(1))
	{
		WriteVector(MSG_ENTITY, this.origin);
	}

	return true;
}

void magic_bubble_deflect(entity this)
{
	entity player = this.owner;
	FOREACH_ENTITY_RADIUS(this.origin, 100, time > it.parry_time && time > it.parry_cooldown,
	{
		// no deflecting player projectiles in coop!
		if(coop && IS_PLAYER(player) && IS_PLAYER(it.owner))
			continue;
		if(!W_Projectile_CanParry(player, it))
			continue;
		entity oldown = it.owner;
		it.owner = player;
		it.realowner = player;
		it.enemy = oldown;
		it.parry_time = time;
		vector org = this.origin + randomvec() * 200 + '0 0 250';
		it.velocity = normalize(org - this.origin) * vlen(it.velocity);
		it.angles = vectoangles(it.velocity);

		this.cnt -= 1;
		_sound(this, CH_WEAPON_SINGLE, "weapons/magic_bubble_deflect.wav", 1, ATTN_NORM);
	});
}

.vector prevorigin;
void magic_bubble_think(entity this)
{
	if(!this.owner || this.owner.magic_bubble != this || time >= this.wait || this.owner.health <= 0)
	{
		delete(this);
		return;
	}

	// pop!
	if(this.cnt <= 0)
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_WEAPON_SINGLE, "weapons/magic_bubble_pop1.wav", 1, ATTN_NORM);
		else if(r < 0.66)
			_sound(this, CH_WEAPON_SINGLE, "weapons/magic_bubble_pop2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "weapons/magic_bubble_pop3.wav", 1, ATTN_NORM);
		delete(this);
		return;
	}

	this.nextthink = time;

	setorigin(this, this.owner.origin);

	if(this.origin != this.prevorigin)
	{
		this.prevorigin = this.origin;
		this.SendFlags |= BIT(1);
	}

	if(time >= this.delay)
	{
		magic_bubble_deflect(this);
		this.delay = time + 0.1;
	}
}

void magic_bubble_launch(entity this, .entity weaponentity)
{
	entity shield = new(magic_bubble);

	this.magic_bubble = shield;
	shield.owner = this;
	//setcefc(shield, magic_bubble_customize);
	shield.effects = EF_ADDITIVE;
	set_movetype(shield, MOVETYPE_NOCLIP);
	shield.solid = SOLID_TRIGGER;
	shield.avelocity = '7 0 11';
	shield.scale = 0.5;
	shield.alpha = 0.1;
	shield.wait = time + 20;
	setthink(shield, magic_bubble_think);
	shield.nextthink = time;
	shield.cnt = 10; // deflection count
	Net_LinkEntity(shield, false, 0, magic_bubble_send);

	setorigin(shield, this.origin);
	_setmodel(shield, "progs/magic_bubble.mdl");
	setsize(shield, shield.scale * shield.mins, shield.scale * shield.maxs);

	_sound(this, CH_WEAPON_SINGLE, "weapons/magic_bubble_shoot.wav", 1, ATTN_NORM);
}

void W_Magic_Fire(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	int magictype = STAT(MAGIC_TYPE, this);
	switch(magictype)
	{
		default:
		case 0: magic_fire_launch(this, weaponentity); break;
		case 1: magic_stormcloud_launch(this, weaponentity); break;
		case 2: magic_bubble_launch(this, weaponentity); break;
	}

	if(random() < 0.33)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "player_shantae/attack1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "player_shantae/attack2.wav", 1, ATTN_NORM);
	}
}

METHOD(Magic, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(!(fire & 1))
		actor.(weaponentity).count = 0;

	// checking secondary first as a page swap prevents attacking
	if(fire & 2)
	if(!(time < actor.attack2_finished))
	{
		STAT(MAGIC_TYPE, actor) += 1;
		if(STAT(MAGIC_TYPE, actor) > 2)
			STAT(MAGIC_TYPE, actor) = 0;
		if(random() < 0.05)
		{
			float r = random() * (random() * 3);
			sound7(actor, CH_WEAPON_B, "weapons/boobies.wav", 1, ATTN_NORM, 100 / r, 0);
		}
		else
			_sound(actor, CH_WEAPON_B, "weapons/magic_switch.wav", 1, ATTN_NORM);
		ATTACK_FINISHED(actor, weaponentity) = max(ATTACK_FINISHED(actor, weaponentity), time + 0.25); // also prevent primary fire during this time
		actor.attack2_finished = time + 0.5; // slight delay between swapping, also prevents fireballs!
	}

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_magic_shot1(actor.(weaponentity));
		W_Magic_Fire(actor, weaponentity);
		float attack_delay = W_Magic_AttackRate(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, attack_delay);
	}
}
METHOD(Magic, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(Magic, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Magic, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
#ifdef CSQC
void magic_bubble_draw(entity this)
{
	InterpolateOrigin_Do(this);
	//Movetype_Physics_MatchTicrate(this, TICRATE, false);
	if(this.count && csqcplayer)
	{
		setorigin(this, csqcplayer.origin);
		this.angles_y = csqcplayer.angles_y;
	}
}

void magic_bubble_setup(entity shield)
{
	shield.effects = EF_ADDITIVE;
	set_movetype(shield, MOVETYPE_NOCLIP);
	shield.solid = SOLID_TRIGGER;
	shield.avelocity = '7 0 11';
	shield.scale = 0.5;
	shield.alpha = 0.1;

	_setmodel(shield, "progs/magic_bubble.mdl");
	setsize(shield, shield.scale * shield.mins, shield.scale * shield.maxs);
}

NET_HANDLE(ENT_CLIENT_MAGIC_BUBBLE, bool isnew)
{
	int sf = ReadByte();
	if(sf & BIT(0))
		this.count = true;
	else
		this.count = false;
	this.draw = magic_bubble_draw;
	if (isnew) IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	InterpolateOrigin_Undo(this);
	this.iflags |= IFLAG_ORIGIN; // interpolate origin too

	if(sf & BIT(1))
	{
		if(isnew)
			magic_bubble_setup(this);
		this.origin = ReadVector();
		setorigin(this, this.origin);
	}

	InterpolateOrigin_Note(this);

	return true;
}
#endif

#ifdef CSQC
METHOD(Magic, wr_viewmodel, string(entity this, entity wep))
{
	switch(STAT(MAGIC_TYPE))
	{
		case 0: return "magic_fire";
		case 1: return "magic_stormcloud";
		case 2: return "magic_bubble";
	}
	return "magic";
}
#endif
