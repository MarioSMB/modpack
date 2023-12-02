#include "dusk.qh"

#ifdef SVQC
bool Dusk_Reap_Monster(entity this, entity targ)
{
	vector org = targ.origin + (targ.mins + targ.maxs) * 0.5;
	te_explosion2(org, 2, 7);
	targ.dusk_revived = true;
	entity newmon = horn_spawnmonster(targ.origin, this, targ.monsterdef);
	newmon.dusk_revived = true;
	newmon.health = min(200, newmon.health);
	delete(targ);
	return true;
}

bool Dusk_Reap_Item(entity this, entity targ)
{
	if(time >= this.nextthink)
		return false;
	if(targ.dusk_revived)
		return false;
	if(targ.solid != SOLID_NOT)
		return false;
	if(targ.classname == "")
		return false; // probably a sigil, no touchy!
	if(targ.powerups)
		return false; // lol no
	if(targ.healamount)
		return false; // no reviving health!
	vector org = (targ.absmin + targ.absmax) * 0.5;
	te_explosion2(org, 2, 7);
	setthink(targ, SUB_regen);
	targ.nextthink = time;
	targ.dusk_revived = true;

	return true;
}

bool Dusk_Reap_Player(entity this, entity targ)
{
	if(targ.health > 0 || targ.dusk_revived)
		return false;
	vector org = targ.origin + (targ.mins + targ.maxs) * 0.5;
	te_explosion2(org, 2, 7);
	targ.dusk_spawnpoint = targ.origin;
	targ.dusk_spawnangle = targ.angles;
	targ.dusk_revived = true;
	//respawn(targ);
	return true;
}

void Dusk_Reap(entity this)
{
	vector org = this.origin + (this.mins + this.maxs) * 0.5;
	te_explosion2(org, 0, 5);

	float reap_range = 300;
	bool found = false;
	FOREACH_ENTITY_RADIUS(this.origin, reap_range, true,
	{
		if(it.flags & FL_ITEM)
			found += Dusk_Reap_Item(this, it);
		else if(it.classname == "dusk_wisp")
			found += Dusk_Reap_Monster(this, it);
		else if(IS_PLAYER(it))
			found += Dusk_Reap_Player(this, it);
	});

	if(found)
	{
		STAT(QCC_ABILITYTIME, this) = time + 3;
		player_sound(this, CH_WEAPON_B, "fastfire.wav", ATTN_NORM);
		T_Damage(this, this, NULL, 25, DEATH_GENERIC.m_id);
	}
	else
	{
		STAT(QCC_ABILITYTIME, this) = time + 1;
		player_sound(this, CH_WEAPON_B, "fastfirestart.wav", ATTN_NORM);
	}
}

void Dusk_MakeWisp(entity targ)
{
	entity wisp = new(dusk_wisp);
	set_movetype(wisp, MOVETYPE_NONE);
	setorigin(wisp, targ.origin);
	setthink(wisp, SUB_Remove);
	wisp.nextthink = time + 10;
	wisp.monsterdef = targ.monsterdef;
}

METHOD(Dusk, m_activate, void(Dusk this, entity actor))
{
	player_sound(actor, CH_VOICE, "sicklestart.wav", ATTN_NORM);
}

METHOD(Dusk, m_playerthink, void(Dusk this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor) && actor.health > 25)
		Dusk_Reap(actor);
}

METHOD(Dusk, m_clear, void(Dusk this, entity actor))
{
	FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
	{
		if(it.charmed && it.charmer == actor && it.dusk_revived && it.health > 20)
			it.health = 20;
	});
}

void Dusk_Killed(entity targ, entity inflictor, entity attacker, int deathtype)
{
	if(!IS_MONSTER(targ) || targ.monsterdef == MON_Null || (targ.monsterdef.spawnflags & MONSTER_TYPE_DECOY) || targ.charmed)
		return;
	Dusk_MakeWisp(targ);
}

void Dusk_PlayerSpawn(entity actor)
{
	if(actor.dusk_revived && actor.dusk_spawnpoint != '0 0 0')
	{
		setorigin(actor, actor.dusk_spawnpoint);
		actor.angles = actor.v_angle = actor.dusk_spawnangle;
		actor.angles_z = 0; // never spawn tilted even if the spot says to
		actor.fixangle = true;
	}
	actor.dusk_spawnpoint = '0 0 0';
	actor.dusk_spawnangle = '0 0 0';
	actor.dusk_revived = false;
}
#endif
