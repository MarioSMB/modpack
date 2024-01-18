#include "weaponsystem.qh"

bool CL_Weaponentity_CustomizeEntityForClient(entity this, entity client)
{
	this.viewmodelforclient = this.owner;
	return false;
}

.float m_alpha;
.string w_weaponname;
.int w_dmg;
.int w_deadflag;

void CL_Weaponentity_Think(entity this)
{
	this.nextthink = time;
	.entity weaponentity = this.weaponentity_fld;
	if (this.owner.(weaponentity) != this)
	{
		// owner has new gun; remove old one
		delete(this);
		return;
	}
	bool hideweapon = false;
	if (this.owner.m_champion && this.owner.m_champion.m_hideweapon)
	{
		if (this.owner.m_champion.m_hideweapon(this.owner.m_champion, this.owner))
			hideweapon = true;
	}
	if (this.owner.health <= 0 || STAT(SKATING, this.owner) || hideweapon)
	{
		// owner died; disappear
		this.model = "";
		return;
	}
	if (this.w_weaponname != this.weaponname || this.w_dmg != this.modelindex || this.w_deadflag != this.deadflag)
	{
		// owner changed weapons; update appearance
		this.w_weaponname = this.weaponname;
		this.w_dmg = this.modelindex;
		this.w_deadflag = this.deadflag;

		CL_WeaponEntity_SetModel(this, this.weaponname);
	}

	this.alpha = -1;  // TODO: don't render this entity at all
}

// Weapon subs
void w_ready(entity w_ent)
{
	w_ent.weapon_think = func_null;
	w_ent.weapon_nextthink = 0;
	w_ent.misc_bulletcounter = 0;
}

// spawning weaponentity for client
void CL_SpawnWeaponentity(entity actor, .entity weaponentity)
{
	entity w_ent = actor.(weaponentity) = new(weaponentity);
	w_ent.solid = SOLID_NOT;
	w_ent.owner = actor;
	setmodel(w_ent, MDL_Null);  // precision set when changed
	setorigin(w_ent, '0 0 0');
	w_ent.weaponentity_fld = weaponentity;
	setthink(w_ent, CL_Weaponentity_Think);
	w_ent.nextthink = time;
	w_ent.viewmodelforclient = actor;
	setcefc(w_ent, CL_Weaponentity_CustomizeEntityForClient);

	wepent_link(w_ent);
}

void W_ResetGunAlign(entity player, int preferred_alignment)
{
	if(W_DualWielding(player))
		preferred_alignment = 3; // right align, the second gun will default to left

	// clear current weapon slots' alignments so we can redo the calculations!
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if (player.(weaponentity))
			player.(weaponentity).m_gunalign = 0;
	}

	// now set the new values
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if (player.(weaponentity))
			player.(weaponentity).m_gunalign = W_GunAlign(player.(weaponentity), preferred_alignment);
	}
}

void weapon_prepareattack(Weapon thiswep, entity actor, .entity weaponentity, float attacktime)
{
	entity this = actor.(weaponentity);
	if (this == NULL) return;

	// if the weapon hasn't been firing continuously, reset the timer
	if (attacktime >= 0)
	{
		if (ATTACK_FINISHED(actor, weaponentity) < time - this.weapon_frametime * 1.5)
		{
			ATTACK_FINISHED(actor, weaponentity) = time;
			// dprint("resetting attack finished to ", ftos(time), "\n");
		}
		float arate = 1;
		if(actor.m_champion && actor.m_champion.qcc_attackrate)
			arate *= actor.m_champion.qcc_attackrate;
		ATTACK_FINISHED(actor, weaponentity) = ATTACK_FINISHED(actor, weaponentity) + attacktime * arate;

		if(autocvar_g_weaponswitch_debug_alternate && W_DualWielding(actor))
		{
			int slot = weaponslot(weaponentity);
			for(int wepslot = 0; wepslot < MAX_WEAPONSLOTS; ++wepslot)
			{
				if(slot == wepslot)
					continue;
				.entity wepent = weaponentities[wepslot];
				if(actor.(wepent) && actor.(wepent).m_weapon != WEP_Null)
				{
					if(ATTACK_FINISHED(actor, wepent) > time + actor.(wepent).weapon_frametime * 0.5)
						continue; // still cooling down!
					if (ATTACK_FINISHED(actor, wepent) < time - actor.(wepent).weapon_frametime * 1.5)
						ATTACK_FINISHED(actor, wepent) = time;
					ATTACK_FINISHED(actor, wepent) = ATTACK_FINISHED(actor, wepent) + (attacktime * arate) / MAX_WEAPONSLOTS;
				}
			}
		}
	}
}

vector W_Shotorg(entity ent, .entity weaponentity)
{
	float nudge = 1; // added to traceline target and subtracted from result  TOOD(divVerent): do we still need this? Doesn't the engine do this now for us?
	vector md = ent.(weaponentity).movedir;
	vector vecs = md;
	vector mi = '0 0 0', ma = '0 0 0'; // quake assume zero hitbox size

	// NOTE: quake specific hack, gun shots are offsetted to their "center"
	vector viewofs = (IS_PLAYER(ent) ? (ent.view_ofs - '0 0 8') : '0 0 16');
	vector dv = v_right * -vecs.y + v_up * vecs.z;
	if(IS_PLAYER(ent))
		dv += v_forward * -12;
	vector w_shotorg = ent.origin + viewofs;
	tracebox(w_shotorg, mi, ma, w_shotorg + dv, MOVE_NORMAL, ent);
	w_shotorg = trace_endpos;

	// now move the shotorg forward as much as requested if possible
	tracebox(w_shotorg, mi, ma, w_shotorg + v_forward * (vecs.x + nudge), MOVE_NORMAL, ent);
	w_shotorg = trace_endpos - v_forward * nudge;
	return w_shotorg;
}

void W_TakeAmmo(entity ent, .float ammotype, float ammoamount)
{
	if(StatusEffects_active(STATUSEFFECT_SharpShooter, ent))
		return;

	if(ent.m_champion && ent.m_champion.m_takeammo)
	{
		if(ent.m_champion.m_takeammo(ent.m_champion, ent))
			return;
	}
	ent.(ammotype) -= ammoamount;
}

void W_TakeMana(entity ent, float amount)
{
	if(StatusEffects_active(STATUSEFFECT_SharpShooter, ent))
		return;
	STAT(MANA, ent) -= amount;
	ent.mana_regen_pause = time + 1.5;
}
