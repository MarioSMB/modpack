#include "mshake.qh"

#ifdef SVQC
METHOD(MasterShake, m_activate, void(MasterShake this, entity actor))
{
	int sndnum = bound(1, floor(random() * 7) + 1, 7);
	string thesnd = strcat("start", ftos(sndnum), ".wav");

	player_sound(actor, CH_VOICE, thesnd, ATTN_NORM);
}

METHOD(MasterShake, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.mshake_cannon = true;
}

METHOD(MasterShake, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.mshake_cannon)
		return false;
	player_sound(actor, CH_TRIGGER_SINGLE, "pain3.wav", ATTN_NORM);
	actor.mshake_cannon = false;
	actor.jump_flag = 0;
	return true;
}

void mshake_milk_touch(entity this, entity toucher)
{
	// generic health item checks
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.tank)
		return;
	if(toucher.m_transform)
		return;
	if(toucher.m_champion && toucher.m_champion.qcc_health_nopickup && this.healtype != 2)
		return;

	if(toucher != this.realowner)
		return; // TODO: allow teammates to pick up juices?
	if(time < this.cnt)
		return;

	if(!T_Heal(toucher, this.healamount, true))
		return;

	_sound(toucher, CH_TRIGGER_SINGLE, "player_mshake/slurp.wav", 1, ATTN_NORM);

	this.solid = SOLID_NOT;
	delete(this);
}

void mshake_milk_think(entity this)
{
	setthink(this, mshake_milk_think);
	this.nextthink = time + 0.1;
	this.walkframe += 1;
	if(this.walkframe < 10)
		this.frame = this.walkframe;
	else
		delete(this);
}

void mshake_milk_pool(entity this)
{
	vector vel_norm = normalize(this.velocity);
	vector vec = this.origin - vel_norm;
	traceline(vec, vec + vel_norm * 16, false, this);
	if(trace_fraction < 1)
	{
		_sound(this, CH_TRIGGER_SINGLE, "weapons/grape_impact.wav", 0.5, ATTN_NORM);
		//te_explosion2(this.origin, 10, 10);
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_TRIGGER;
		_setmodel(this, "progs/s_milkpool.mdl");
		setsize(this, '-20 -20 0', '20 20 4');
		setorigin(this, trace_endpos);

		vec = trace_plane_normal;
		this.scale = 1.5;
		this.angles = vectoangles(vec);
		this.angles_x -= 90;
		settouch(this, mshake_milk_touch);
		this.frame = 0;
		this.cnt = time + 0.2;
		this.nextthink = time + 4.1;
		setthink(this, mshake_milk_think);
	}
}

void mshake_milk_proj_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owne

	if(toucher.takedamage)
		return;

	mshake_milk_pool(this);
}

void mshake_DropMilk(entity this, float amount)
{
	_sound(this, CH_WEAPON_B, "weapons/jarsmash.wav", 1, ATTN_NORM);

	entity proj = new(milk);
	//proj.flags = FL_PROJECTILE;
	proj.owner = this;
	proj.realowner = this;
	proj.projectiledeathtype = DEATH_GENERIC.m_id; // dummy deathtype
	proj.clipgroup = this.clipgroup;
	set_movetype(proj, MOVETYPE_BOUNCE);
	proj.solid = SOLID_BBOX;
	proj.scale = 0.75;

	int col = (this.colormap >= 1024) ? this.colormap - 1024 : this.clientcolors;
	proj.colormod = colormapPaletteColor(col % 16, true);

	proj.velocity = randomvec() * 300 + '0 0 150';

	proj.avelocity = randomvec() * 320;
	proj.angles = vectoangles(proj.velocity);

	settouch(proj, mshake_milk_proj_touch);
	proj.healamount = min(amount, 100);

	setthink(proj, SUB_Remove);
	proj.nextthink = time + 2.5;

	_setmodel(proj, "progs/s_milk.mdl");
	setsize(proj, '0 0 0', '0 0 0');
	setorigin(proj, CENTER_OR_VIEWOFS(this));
}

METHOD(MasterShake, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion != this || targ.tank || targ.clockwork || (targ.flags & FL_GODMODE))
		return 1;
	float edmg = damage * 1.5; // give a bit more healing back!
	if(attacker && edmg >= 10)
		mshake_DropMilk(targ, damage);
	return 1;
}

bool mshake_FreezeEnemies(entity this)
{
	bool hitenemy = false;
	FOREACH_ENTITY_RADIUS(this.origin, 600, it != this && it.health > 0 && Damage_ValidTarget(it, this) && checkpvs(this.origin, it),
	{
		if(it.monsterdef && (it.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
			continue;

		StatusEffects_apply(STATUSEFFECT_Slowness, it, time + 3, 0);
		StatusEffects_apply(STATUSEFFECT_Confused, it, time + 3, 0);
		hitenemy = true;
	});

	return hitenemy;
}

METHOD(MasterShake, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		player_sound(actor, CH_VOICE, "forbidden.wav", ATTN_NORM);

		if(mshake_FreezeEnemies(actor))
			STAT(QCC_ABILITYTIME, actor) = time + 10;
		else
			STAT(QCC_ABILITYTIME, actor) = time + 3;
	}
}
#endif

#ifdef CSQC
METHOD(MasterShake, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/mshake_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
