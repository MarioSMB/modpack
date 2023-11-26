#include "mjolnir.qh"

#ifdef SVQC
void player_hammer6(entity this) { set_anim(this, anim_player_axatt1 + 2, player_run); }
void player_hammer5(entity this) { set_anim(this, anim_player_axatt1 + 2, player_hammer6); }
void player_hammer4(entity this) { set_anim(this, anim_player_axatt1 + 2, player_hammer5); }
void player_hammer3(entity this) { set_anim(this, anim_player_axatt1 + 2, player_hammer4); }
void player_hammer2(entity this) { set_anim(this, anim_player_axatt1 + 1, player_hammer3); }
void player_hammer1(entity this) { set_anim(this, anim_player_axatt1 + 3, player_hammer2); }

void player_mjolnir6(entity this) { set_anim(this, anim_player_axatt1 + 2, player_run); }
void player_mjolnir5(entity this) { set_anim(this, anim_player_axatt1 + 2, player_mjolnir6); }
void player_mjolnir4(entity this) { set_anim(this, anim_player_axatt1 + 2, player_mjolnir5); }
void player_mjolnir3(entity this) { set_anim(this, anim_player_axatt1 + 2, player_mjolnir4); }
void player_mjolnir2(entity this) { set_anim(this, anim_player_axatt1 + 1, player_mjolnir3); }
void player_mjolnir1(entity this) { set_anim(this, anim_player_axatt1, player_mjolnir2); }

void wep_mjolnir_hammer6(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_mjolnir_hammer5(entity this) { wep_set_anim(this, 4, wep_mjolnir_hammer6); }
void wep_mjolnir_hammer4(entity this) { wep_set_anim(this, 4, wep_mjolnir_hammer5); HIP_FireMjolnir(this.owner, this.weaponentity_fld); }
void wep_mjolnir_hammer3(entity this) { wep_set_anim(this, 3, wep_mjolnir_hammer4); }
void wep_mjolnir_hammer2(entity this) { wep_set_anim(this, 2, wep_mjolnir_hammer3); }
void wep_mjolnir_hammer1(entity this)
{
	wep_set_anim(this, 1, wep_mjolnir_hammer2);
	if(this.owner.ammo_cells < 30)
		player_hammer1(this.owner);
	else
		player_mjolnir1(this.owner);
}

void HIP_HammerDamage(vector p1, vector p2, entity from, float damage)
{
	vector f = p2 - p1;
	normalize(f);
	f.x = 0 - f.y;
	f.y = f.x;
	f.z = 0;
	f = f*16;

	entity e1 = NULL, e2 = NULL;

	traceline(p1, p2, false, from);
//JIM
	if(trace_ent.takedamage && !trace_ent.wetsuit_finished )
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage, WEP_MJOLNIR.m_id);
		if(IS_PLAYER(from))
		{
			if(IS_PLAYER(trace_ent))
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline(p1 + f, p2 + f, false, from);
//JIM
	if(trace_ent != e1 && trace_ent.takedamage &&
		!trace_ent.wetsuit_finished )
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage, WEP_MJOLNIR.m_id);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, false, from);
//JIM
	if(trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage &&
		!trace_ent.wetsuit_finished )
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage, WEP_MJOLNIR.m_id);
	}
}

//void(entity prev, entity owner, float dst) HIP_SpawnMjolnirLightning;
void HIP_LightningThink(entity this)
{
	if(time > this.delay)
	{
		if(this.enemy != NULL)
			this.enemy.struck_by_mjolnir = false;
		delete(this);
		return;
	}
	int oldstate = this.state;
	if(this.state == 0)
	{
		// look in our immediate vicinity
		this.enemy = NULL;
		entity selected = NULL;
		entity head = findradius(this.owner.origin, this.distance);
		while(head)
		{
			if(!(head.flags & FL_NOTARGET) && ((IS_MONSTER(head) && !head.charmed) || (!autocvar_g_friendlyfire_virtual && IS_PLAYER(head))))
			{
//            if(visible(head) &&(head!=this.owner.owner) &&(head.health>0))
				if((head!=this.owner.owner) &&(head.health>0) && (visible(this, head)))
				{
					float cur_dist = this.distance;
					float head_dist = vlen(head.origin - this.lastvictim.origin);
					if((head_dist < cur_dist) && !head.struck_by_mjolnir)
					{
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}
		if(selected != NULL)
		{
			this.state = 1;
			this.enemy = selected;
			this.enemy.struck_by_mjolnir = true;
		}
		else
		{
			makevectors(this.v_angle);
			vector owner_org = this.owner.origin;
			vector end = owner_org + v_forward * 200;
			end = end +(((400 * random()) - 200) * v_right);

			traceline(owner_org, end, true, this);

			//te_lightning2(NULL, owner_org, trace_endpos); // should be this, bug in te_lightning
			SendCSQCLightningBeam(owner_org, trace_endpos);

			this.nextthink = time + 0.1;
	//      setthink(this, HIP_DiversionLightningThink);
	//      this.nextthink = time;
	//		this.delay = time + 0.30;
	//		this.origin = this.owner.origin;
	//		getthink(this)(this);
			return;
		}
	}
	vector org = this.lastvictim.origin;
	vector dst = this.enemy.absmin + 0.25 *(this.enemy.absmax - this.enemy.absmin);
	dst = dst +(random() * 0.5 *(this.enemy.absmax - this.enemy.absmin));
	traceline(org, dst, true, this.owner.owner);

	if(trace_fraction != 1.0 || this.enemy.health<=0)
	{
		this.enemy.struck_by_mjolnir = false;
		this.state = 0;
		this.nextthink = time + 0.1;
		return;
	}
	//te_lightning2(NULL, org, trace_endpos);
	SendCSQCLightningBeam(org, trace_endpos);
	vector vec = normalize(this.enemy.origin - this.owner.origin);
	float dot = vec * this.owner.movedir;
	float dam =((oldstate == 0) ? 80 : 30);
	entity own = this.owner.owner;
	if(dot > 0.3)
		HIP_HammerDamage(org, trace_endpos, own, dam);
	else
		HIP_HammerDamage(org, trace_endpos, own, dam*0.5);

	this.nextthink = time + 0.2;
}

void HIP_SpawnMjolnirLightning(entity this, entity prev, entity own, float dst)
{
	// spawn actual lightning
	entity light = spawn();
	light.delay = time + 0.8;
	light.state = 0;
	light.lastvictim = prev;
	light.distance = dst;
	light.owner = own;
	light.v_angle = this.angles;
	light.v_angle_x = 0;
	light.v_angle_z = 0;
	light.origin = own.origin;
	setthink(light, HIP_LightningThink);
	light.nextthink = time;
}

void HIP_SpawnMjolnirBase(entity this)
{
	// spawn lightning base
	entity light = spawn();
//   light.origin = this.origin - '0 0 24' +(32*v_forward);
	light.origin = trace_endpos;
	light.flags = 0;
	light.owner = this;
	light.struck_by_mjolnir = true;
	setthink(light, SUB_Remove);
	light.nextthink = time + 1;
	_sound(light, CHAN_AUTO, "hipweap/mjolslap.wav", 1, ATTN_NORM);
	_sound(light, CH_WEAPON_SINGLE, "hipweap/mjolhit.wav", 1, ATTN_NORM);
	makevectors(this.v_angle);
	light.movedir = v_forward;
	HIP_SpawnMjolnirLightning(this, light, light, 350);
	HIP_SpawnMjolnirLightning(this, light, light, 350);
	HIP_SpawnMjolnirLightning(this, light, light, 350);
	HIP_SpawnMjolnirLightning(this, light, light, 350);
}

void HIP_FireMjolnirLightning(entity this)
{
// explode if under water
	if(this.waterlevel > 1)
	{
		int cells = this.ammo_cells;
		this.ammo_cells = 0;
		discharged = true;
		T_RadiusDamage(this, this, 35 * cells, DEATH_DISCHARGE.m_id, NULL);
		discharged = false;
		W_SetCurrentAmmo(this);
		return;
	}

//   if(this.t_width < time)
//   {
//      _sound(this, CH_WEAPON_SINGLE, "weapons/lhit.wav", 1, ATTN_NORM);
//      this.t_width = time + 0.6;
//   }
//   this.punchangle_x = 12;

	this.ammo_cells = this.ammo_cells - 15;

	HIP_SpawnMjolnirBase(this);
}

void HIP_FireMjolnir(entity this, .entity weaponentity)
{
	ATTACK_FINISHED(this, weaponentity) = time + 0.4;
	vector source = W_Shotorg(this, weaponentity);

	makevectors(this.v_angle);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	traceline(source, source + v_forward*32, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0 &&(this.ammo_cells >= 15))
	{
		source = source + v_forward*32;
		traceline(source , source - v_up*50, false, this);
//      dprint("fraction = ");
//      dprint(ftos(trace_fraction));
//      dprint("\n");
		if(trace_fraction > 0.3 && trace_fraction< 1.0)
		{
			HIP_FireMjolnirLightning(this);
			this.attack_finished = time + 1.5;
			return;
		}
	}
	vector org = trace_endpos - v_forward*4;

	if(trace_ent.takedamage)
	{
		float damage = 50;
		if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
			damage = 70;
		trace_ent.axhitme = true;
		SpawnBlood(org, v_forward, damage, trace_ent);
		T_Damage(trace_ent, this, this, damage, WEP_MJOLNIR.m_id);
	}
	else
	{  // hit wall
		if(trace_fraction != 1.0)
		{
//         _sound(this, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
			_sound(this, CH_WEAPON_SINGLE, "hipweap/mjoltink.wav", 1, ATTN_NORM);
			te_gunshot(org);
		}
		else
		{
			_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
		}
	}
	ATTACK_FINISHED(this, weaponentity) = time + 0.4;
}

METHOD(Mjolnir, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		wep_mjolnir_hammer1(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.8);
	}
}
METHOD(Mjolnir, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// while weapon does use ammo, also works fine without!
	return true;
}
METHOD(Mjolnir, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
