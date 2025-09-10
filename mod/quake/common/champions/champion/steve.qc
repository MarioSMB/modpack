#include "steve.qh"

#ifdef SVQC
METHOD(Steve, m_activate, void(Steve this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);

	if(!CHAMPION_Mario.m_condition(CHAMPION_Mario, actor))
		actor.skin = 2;
	else if(!CHAMPION_Goat.m_condition(CHAMPION_Goat, actor))
		actor.skin = 1;
}

METHOD(Steve, m_playerspawn, void(Champions this, entity actor))
{
	if(!CHAMPION_Mario.m_condition(CHAMPION_Mario, actor))
		actor.skin = 2;
	else if(!CHAMPION_Goat.m_condition(CHAMPION_Goat, actor))
		actor.skin = 1;
}

void steve_block_break(entity this)
{
	sound(this, CH_TRIGGER_SINGLE, SND_Steve_BlockBreak, 1, ATTN_NORM);
	particle(this.origin + '0 0 16', '0 0 0', 75, 255);
	setmodel(this, MDL_Null);
	setsize(this, '0 0 0', '0 0 0');
	setorigin(this, this.origin + '0 0 16');
	setthink(this, SUB_Remove);
	this.nextthink = time;
	this.takedamage = DAMAGE_NO;

	CSQCMODEL_AUTOUPDATE(this);
}

void steve_block_think(entity this)
{
	this.nextthink = time;

	if(time >= this.count)
	{
		steve_block_break(this);
		return;
	}

	CSQCMODEL_AUTOUPDATE(this);
}

void steve_block_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	vector oldorg = this.origin;

	steve_block_break(this);

	if(this.skin == 3 && this.realowner)
	{
		entity mon = horn_spawnmonster(oldorg, this.realowner, MON_GOATLING);
		if(!mon)
			return; // dunno how but just incase!
		mon.angles_y += random() * 359;
		mon.health = 100; // slight buffer since their health ticks down fast
		mon.max_health = mon.health;
		SpawnChunk(mon.origin, oldorg * 400, 0, 10);
	}
}

void Steve_PlaceBlock(entity this)
{
	makevectors(this.v_angle);
	traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * 100, MOVE_NORMAL, this);
	if(trace_startsolid)
		return;
	sound(this, CH_WEAPON_B, SND_Steve_BlockPlace, 1, ATTN_NORM);

	vector org = trace_endpos - '0 0 16';
	float grid_size = 16;
	org = vsnap(org, grid_size);

	entity block = new(block);
	block.realowner = this;
	setorigin(block, org);
	block.solid = SOLID_BBOX;
	setmodel(block, MDL_Steve_Block);
	setsize(block, '-16 -16 0', '16 16 32');
	set_movetype(block, MOVETYPE_NONE);
	block.takedamage = DAMAGE_AIM;
	block.health = 5;
	block.count = time + 30;
	setthink(block, steve_block_think);
	block.nextthink = time;
	block.th_die = steve_block_die;
	block.skin = (random() <= 0.5) ? 0 : 1;
	if(random() < 0.1)
	{
		if(random() <= 0.5)
			block.skin = 2;
		else
			block.skin = 3;
	}

	player_shot1(this);

	CSQCMODEL_AUTOINIT(block);
	IL_PUSH(g_blocks, block);
}

METHOD(Steve, m_clear, void(Steve this, entity actor))
{
	IL_EACH(g_blocks, it.realowner == actor && it.takedamage,
	{
		setthink(it, steve_block_break);
		it.nextthink = time + (1 * random());
	});
}

METHOD(Steve, m_playerthink, void(Steve this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		int blocklimit = 5;
		int blockcount = 0;
		if(autocvar_sv_cheats || actor.maycheat)
			blocklimit = 100;
		IL_EACH(g_blocks, it.realowner == actor,
		{
			++blockcount;
		});
		if(blockcount >= blocklimit)
			return;

		Steve_PlaceBlock(actor);
		STAT(QCC_ABILITYTIME, actor) = time + 0.33;
	}
}

METHOD(Steve, m_takedamage, float(Steve this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this && targ.armorvalue > 0)
		return 0.66;
	return 1;
}
#endif
