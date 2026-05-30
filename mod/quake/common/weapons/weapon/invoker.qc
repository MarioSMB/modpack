#include "invoker.qh"

#ifdef GAMEQC
REGISTER_NET_TEMP(TE_CSQC_INVOKERTRAIL)

const float INVOKER_RANGE = 8192;
const float INVOKER_SPREAD_MIN = 70;
const float INVOKER_SPREAD_MAX = 120;
#endif

#if defined(SVQC)
void SendCSQCInvokerTrail(vector start, vector dir)
{
	WriteHeader(MSG_BROADCAST, TE_CSQC_INVOKERTRAIL);
	WriteVector(MSG_BROADCAST, start);
	WriteAngleVector(MSG_BROADCAST, dir);
}
#elif defined(CSQC)
PRECACHE(Invoker)
{
	precache_model("progs/proj_chain.mdl");
}

// even more smooth:
float lerpCosine(float a, float b, float mix)
{
	if(mix <= 0) return a;
	if(mix >= 1) return b;

	float cmx = (1 - cos(mix * 180)) / 2;

	return (b * cmx + a * (1 - cmx));
}

#if 0
void InvokerTrail_Draw(entity this)
{
	this.alpha = bound(0.0001, lerpCosine(1, 0, 1 - (this.count - time) / 0.5), 1);

	if(time > this.count)
		delete(this);
}
#endif
void rail_fade(entity this)
{
	setthink(this, rail_fade);
	this.nextthink = time + this.count;

	//if(this.skin < 6)
	//	this.skin++;

	if(this.cnt >= 10)
		this.alpha = 0.9;
	else if(this.cnt == 9)
		this.alpha = 0.7;
	else if(this.cnt == 8)
		this.alpha = 0.5;
	else if(this.cnt == 7)
		this.alpha = 0.4;
	else if(this.cnt == 6)
		this.alpha = 0.3;
	else if(this.cnt == 5)
		this.alpha = 0.2;
	else if(this.cnt == 4)
		this.alpha = 0.15;
	else if(this.cnt == 3)
		this.alpha = 0.1;
	else if(this.cnt == 2)
		this.alpha = 0.07;
	else 
	{
		this.alpha = 0.05;
		setthink(this, SUB_Remove);
	}	
	
	this.cnt -= 1;
}

void InvokerTrail_Spawn(vector org, vector direction, bool isNew)
{
	// no need for all the excessive tracing the server side, we're just guessing here!
	traceline(org, org + direction * 8192, false, NULL);
	vector dest = trace_endpos;

	if(!(trace_dphitcontents & DPCONTENTS_SKY) && pointcontents(dest) != CONTENT_SKY)
		te_gunshot(dest);

	float len = vlen(dest - org);
	vector dir = normalize(dest - org);
	vector ang = vectoangles(dest - org);

	entity sg = NULL;
	float ct = (len) ? floor(len / 30) : 0;
	for(int i = 0; i < ct; i++)
	{
		sg = spawn();

		sg.solid = SOLID_NOT;
		_setmodel(sg, "progs/proj_chain.mdl");
		setsize(sg, '0 0 0', '0 0 0');
		setorigin(sg, org + dir * 30 * i);

		//sg.draw = InvokerTrail_Draw;
		if(isNew) IL_PUSH(g_drawables, sg);
		sg.drawmask = MASK_NORMAL;

		sg.classname = "lgsegment";
		sg.effects = EF_FULLBRIGHT;
		sg.angles = ang;
		sg.angles_z = random()*360;
		sg.count = 0.02 + (i * 0.0001);
		setthink(sg, rail_fade);
		sg.nextthink = time + sg.count;
		sg.alpha = 0.9;
		sg.cnt = 4 + i;
	}
	// add an effect to the impact site
	if(sg)
	{
		pointparticles(EFFECT_INVOKER_MUZZLEFLASH, sg.origin, dir * -1, 1);
		//sg.effects |= EF_MUZZLEFLASH;
	}
}

NET_HANDLE(TE_CSQC_INVOKERTRAIL, bool isNew)
{
	vector org = ReadVector();
	vector dir = ReadAngleVector();

	makevectors(dir);

	dir = v_forward;
	
	vector up = v_up;
	vector right = v_right;

	InvokerTrail_Spawn(org + (up * 32) + (right * -32), dir, isNew); // top left
	InvokerTrail_Spawn(org + (up * 32) + (right * 0), dir, isNew); // top center
	InvokerTrail_Spawn(org + (up * 32) + (right * 32), dir, isNew); // top right
	InvokerTrail_Spawn(org + (up * 0) + (right * -32), dir, isNew); // center left
	InvokerTrail_Spawn(org + (up * 0) + (right * 0), dir, isNew); // center
	InvokerTrail_Spawn(org + (up * 0) + (right * 32), dir, isNew); // center right
	InvokerTrail_Spawn(org + (up * -32) + (right * -32), dir, isNew); // bottom left
	InvokerTrail_Spawn(org + (up * -32) + (right * 0), dir, isNew); // bottom center
	InvokerTrail_Spawn(org + (up * -32) + (right * 32), dir, isNew); // bottom right

	// extra invisible traces to the sides of the crosshair to catch up rogue swarmers
	//InvokerTrail_Spawn(org + (up * 0) + (right * -12), dir, isNew); // left
	//InvokerTrail_Spawn(org + (up * 0) + (right * -24), dir, isNew); // left
	//InvokerTrail_Spawn(org + (up * 0) + (right * 12), dir, isNew); // right
	//InvokerTrail_Spawn(org + (up * 0) + (right * 24), dir, isNew); // right

	return true;
}
#endif

#ifdef SVQC
bool invoked_SendEntity(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_INVOKED);

	int f = 0;
	if(this.angles != '0 0 0')
		f |= BIT(0);

	WriteByte(MSG_ENTITY, f);
	WriteShort(MSG_ENTITY, this.modelindex);
	WriteByte(MSG_ENTITY, this.skin);
	WriteByte(MSG_ENTITY, this.frame);
	WriteVector(MSG_ENTITY, this.origin);
	if(f & BIT(0))
	{
		WriteAngleVector(MSG_ENTITY, this.angles);
	}

	return true;
}
#elif defined(CSQC)
void anim_invoked(entity this)
{
	float fade_rate = 0.05 - 0.33 * 0.03;
	
	this.alpha -= fade_rate;

	if(this.alpha <= 0.5 && this.alpha > 0.2)
	{
		vector amax = this.absmax;
		amax.z = min(amax.z * (this.alpha + 0.8), amax.z);
		te_particlecube(this.absmin, amax, '0 0 0', bound(20, vlen(this.mins + this.maxs), 150), 75, true, 0);
	}

	if(this.alpha <= 0)
	{
		delete(this);
		return;
	}
	
	setthink(this, anim_invoked);
	this.nextthink = time + 0.05;
}

NET_HANDLE(ENT_CLIENT_INVOKED, bool isnew)
{
	make_pure(this);

	int f = ReadByte();

	entity e = new(invokedeffect);
	e.model = "from network";
	e.modelindex = ReadShort();
	setmodelindex(e, e.modelindex); // pulls absmin/absmax
	e.skin = ReadByte();
	e.frame = ReadByte();
	e.frame1time = time;
	e.origin = ReadVector();
	setorigin(e, e.origin);
	if(f & BIT(0))
	{
		e.angles = ReadAngleVector();
	}

	e.alpha = 1;
	e.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_NOSHADOW | EF_NOSELFSHADOW;
	e.colormod = '1 0 0';
	setthink(e, anim_invoked);
	e.nextthink = time + 0.1;
	e.drawmask = MASK_NORMAL;

	if (!isnew) delete(e); // yes, this IS stupid, but I don't need to duplicate all the read* stuff then
	return true;
}
#endif

#ifdef SVQC
void wep_invoker_shot2(entity this) { wep_set_anim(this, 2, w_ready); }
void wep_invoker_shot1(entity this) { wep_set_anim(this, 1, wep_invoker_shot2); this.owner.effects |= EF_MUZZLEFLASH; }

PRECACHE(Invoker)
{
	precache_model("progs/v_invoker.mdl");
	precache_model("progs/g_invoker.mdl");

	precache_model("progs/proj_chain.mdl");
	precache_model("progs/fx/invoked_chain.mdl");

	precache_sound("invoker/magic07.wav");
	precache_sound("invoker/magic08.wav");
	precache_sound("invoker/magic21.wav");
	precache_sound("invoker/magic26.wav");

	precache_sound("invoker/invoker_firerail.wav");

	precache_sound("invoker/energy_charge.wav");
	precache_sound("invoker/energy_hit1.wav");
	precache_sound("invoker/energy_hit2.wav");
	precache_sound("invoker/energy_hit3.wav");
	precache_sound("invoker/energy_hit4.wav");
}

void FX_Invoked(entity targ)
{
	// copied from modeleffect code
	entity e = new(invokedeffect);
	_setmodel(e, targ.model);
	e.frame = targ.frame;
	setorigin(e, targ.origin);
	e.angles = targ.angles;
	e.skin = targ.skin;
	setsize(e, targ.mins, targ.maxs);
	Net_LinkEntity(e, false, 0.1, invoked_SendEntity);
}
//==============================================

void anim_chains(entity this)
{
	this.alpha -= 0.10;
	this.frame ++;

	if(this.frame >= 6)
	{
		delete(this);
		return;
	}
	setthink(this, anim_chains);
	this.nextthink = time + 0.05;
}

void FX_Chains(vector org, vector dir)
{
	entity fx = new(impact);
	fx.solid = SOLID_NOT;
	set_movetype(fx, MOVETYPE_NONE);

	fx.angles = vectoangles(dir);
	fx.nextthink = time;
	setthink(fx, anim_chains);

	fx.frame = 0;
	fx.alpha = 1;

	setorigin(fx, org);
	_setmodel(fx, "progs/fx/invoked_chain.mdl");
	setsize(fx, '0 0 0', '0 0 0');
}

void sound_invoker_impact(entity this, float invokerhit_volume)
{
	int r = floor(random() * 4);
	switch(r)
	{
		case 0: _sound(this, CHAN_BODY, "invoker/energy_hit1.wav", invokerhit_volume, ATTN_NORM); break;
		case 1: _sound(this, CHAN_BODY, "invoker/energy_hit2.wav", invokerhit_volume, ATTN_NORM); break;
		case 2: _sound(this, CHAN_BODY, "invoker/energy_hit3.wav", invokerhit_volume, ATTN_NORM); break;
		default: _sound(this, CHAN_BODY, "invoker/energy_hit4.wav", invokerhit_volume, ATTN_NORM); break;
	}
}

//=============================================================================================

float invokerTrace_CheckSpread(vector targetorg, vector nearest_on_line, vector org, vector end)
{
	float distance_of_attack = vlen(org - end);
	float distance_from_line = vlen(targetorg - nearest_on_line);

	float spreadlimit = (distance_of_attack ? min(1, (vlen(org - nearest_on_line) / distance_of_attack)) : 1);
	spreadlimit = ((INVOKER_SPREAD_MIN * (1 - spreadlimit)) + (INVOKER_SPREAD_MAX * spreadlimit));

	if((spreadlimit && (distance_from_line <= spreadlimit)) && ((vlen(normalize(targetorg - org) - normalize(end - org)) * RAD2DEG) <= 90))
		return bound(0, (distance_from_line / spreadlimit), 1);
	else
		return 0;
}

bool invokerTrace_IsVisible(entity this, entity head, vector nearest_on_line, vector nearest_on_head, vector org, vector end)
{
	vector nearest_to_attacker = nearest_on_head;
	vector center = (head.origin + (head.mins + head.maxs) * 0.5);

	// STEP ONE: Check if the nearest point is clear
	if(invokerTrace_CheckSpread(nearest_to_attacker, nearest_on_line, org, end))
	{
		traceline(org, nearest_to_attacker, true, this);
		if(trace_fraction == 1) { return true; } // yes, the nearest point is clear and we can allow the damage
	}

	// STEP TWO: Check if shotorg to center point is clear
	if(invokerTrace_CheckSpread(center, nearest_on_line, org, end))
	{
		traceline(org, center, true, this);
		if(trace_fraction == 1) { return true; } // yes, the center point is clear and we can allow the damage
	}

	// STEP THREE: Check each corner to see if they are clear
	for(int i=1; i<=8; ++i)
	{
		vector corner = get_corner_position(head, i);
		if(invokerTrace_CheckSpread(corner, nearest_on_line, org, end))
		{
			traceline(org, corner, true, this);
			if(trace_fraction == 1) { return true; } // yes, this corner is clear and we can allow the damage
		}
	}

	return false;
}

void invokerTrace(entity this, vector org, vector dir)
{
	float lag = (IS_PLAYER(this)) ? antilag_getlag(this) : 0;
	if(lag)
		antilag_takeback_all(this, lag);

	float force = 400;

	vector attack_endpos = org + (dir * INVOKER_RANGE);
	traceline(org, attack_endpos, true, this);

	FOREACH_ENTITY_RADIUS(org, INVOKER_RANGE, it != this && it.takedamage && Damage_ValidTarget(it, this),
	{
			vector center = CENTER_OR_VIEWOFS(it);

			// find the closest point on the enemy to the center of the attack
			float h; // hypotenuse, which is the distance between attacker to it
			float a; // adjacent side, which is the distance between attacker and the point on dir that is closest to it.origin

			h = vlen(center - this.origin);
			a = h * (normalize(center - this.origin) * dir);

			vector nearest_on_line = (org + a * dir);
			//vector nearest_to_attacker = NearestPointOnBoundingBox(center + it.mins, center + it.maxs, nearest_on_line);

			vector p = NearestPointOnBoundingBox(it.origin + it.mins, it.origin + it.maxs, org);

			if(vlen(p) <= INVOKER_RANGE && invokerTrace_IsVisible(this, it, nearest_on_line, p, org, attack_endpos))
			{
				// figure out the direction of force
				vector final_force = normalize(center - (nearest_on_line - dir));

				// now multiply the direction by force units
				final_force *= force;

				// queue damage with this calculated info
				SpawnBlood(center, final_force*0.2, 400, it);

				it.effects |= EF_MUZZLEFLASH;

				FX_Chains(center, dir);

				sound_invoker_impact(it, 1);

				int oldmovetype = it.move_movetype;

				float damage = (IS_MONSTER(it) ? 666 : 333);

				T_Damage(it, this, this, damage, WEP_INVOKER.m_id | HITTYPE_MAGIC);

				// ded
				if(it && it.health <= 0 && (IS_MONSTER(it) || IS_PLAYER(it)))
				{
					// if we have the right amount of health add some velocity if we're not gibbing
					if(!(oldmovetype != it.move_movetype && it.move_movetype == MOVETYPE_BOUNCE)) // rough gib check
					{
						if(!(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(it.monsterdef.spawnflags & MON_FLAG_STATIONARY))
						{
							// zero out the velocity and give it some z velocity so its off ground
							it.velocity = '0 0 175';
							// also set the flag
							UNSET_ONGROUND(it);
						}
					}
				}
			}
	});

	if(lag)
		antilag_restore_all(this);
}

void W_FireInvoker(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	vector org = W_Shotorg(this, weaponentity);
	vector dir = qc_aim(this, 8192);
	
	//vector up = v_up;
	//vector right = v_right;

	//float damage = 333; // TODO: double against monsters?
	//int deathtype = WEP_INVOKER.m_id | HITTYPE_MAGIC;

	invokerTrace(this, org, dir);

	SendCSQCInvokerTrail(org, this.v_angle);
}

void weaponanim_invoker_loop(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(intermission_running)
		return;

	if(this.m_frame == 41)
		_sound(actor, CH_WEAPON_A, "invoker/magic07.wav", 1, ATTN_NORM);
	else if(this.m_frame == 77)
		_sound(actor, CH_WEAPON_A, "invoker/energy_charge.wav", 1, ATTN_NORM);

	// keep playing attack animation so player doesn't cancel attacks
	// TODO: weapon attack animation locking
	if(IS_PLAYER(actor))
		player_shot1(actor);

	if(this.m_frame >= 64 && this.m_frame <= 94)
	{ /* TODO: weapon locking */ }
	else
	{ /* TODO */ }

	if(this.m_frame == 78)
	{
		actor.effects |= EF_MUZZLEFLASH;
		W_TakeMana(actor, 100);

		SuperDamageSound(actor);
		W_FireInvoker(actor, weaponentity);
	}

	if(this.m_frame >= 110) // added post-fire + ready to fire --> idle padding
	{
		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;
		this.m_frame = 95;
		w_ready(this);
		return;
	}

	wep_set_anim(this, this.m_frame + 1, weaponanim_invoker_loop);
	this.weapon_nextthink = time + 0.025;
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

void weaponanim_invoker(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	_sound(actor, CH_WEAPON_A, "invoker/magic21.wav", 1, ATTN_NORM);
	_sound(actor, CH_WEAPON_A, "invoker/magic26.wav", 1, ATTN_NORM);

	wep_set_anim(this, 11, weaponanim_invoker_loop);
	this.weapon_nextthink = time + 0.025;
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

METHOD(Invoker, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	//if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	if(STAT(MANA, actor) >= 100)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		weaponanim_invoker(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 5);
	}
}
METHOD(Invoker, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // uses mana
}
METHOD(Invoker, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Invoker, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
