#include "papyrus.qh"

#ifdef SVQC
void BoneTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage == DAMAGE_AIM && Damage_ValidTarget(toucher, this.owner))
		T_Damage(toucher, this, this.owner, 30 * this.scale, this.projectiledeathtype);

	if(this.attack_finished < time)
		_sound(this, CH_WEAPON_SINGLE, "player_papyrus/lburn2.wav", 0.7, ATTN_NORM);	// bounce sound
	this.attack_finished = time + 0.1;
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

void Papyrus_ThrowBone(entity this)
{
	player_sound(this, CH_TRIGGER_SINGLE, "throw.wav", ATTN_NORM);

	.entity weaponentity = weaponentities[0]; // TODO?
	entity missile = new(bone);
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = DEATH_BONETROUSLE.m_id;
	missile.clipgroup = this.clipgroup;
	missile.bouncefactor = 1;
	missile.bouncestop = 0.1;
// set missile speed	

	makevectors(this.v_angle);

	if(this.v_angle_x)
		missile.velocity = v_forward*300 + v_up * 200;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 300;
		missile.velocity_z = 500;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, BoneTouch);
	
// set missile duration
	missile.scale = max(0.3, random() * 3);
	missile.nextthink = time + 4;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/bone.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, W_Shotorg(this, weaponentity));
}

void skull_fire(entity this)
{
	_sound(this, CH_WEAPON_B, "player_papyrus/laser_fire.wav", 1, ATTN_NORM);

	this.effects |= EF_MUZZLEFLASH;

	ai_face(this);

	vector org = this.origin;

	vector dir = this.enemy.origin + '0 0 16' - org;
	dir = normalize(dir);

	traceline(org, org + dir * 500, true, this);

	WriteHeader(MSG_BROADCAST, TE_CSQC_PAPYRUS_LASER);
	WriteVector(MSG_BROADCAST, org);
	WriteVector(MSG_BROADCAST, trace_endpos);

	LightningDamage(org, trace_endpos, this.owner, 50, DEATH_LASER_SKULL.m_id);

	setthink(this, SUB_Remove);
	this.nextthink = time + 0.5;
}

void Papyrus_ChargeLaser(entity this, entity targ)
{
	_sound(this, CH_WEAPON_B, "player_papyrus/laser_charge.wav", 1, ATTN_NORM);

	vector forward, right, up;
	MAKE_VECTORS(this.angles, forward, right, up);
	vector spot = this.origin + forward * 48 + v_right * ((random() > 0.5) ? 32 : -32) + v_up * 24;

	entity skull = spawn();
	skull.classname = "skull";
	_setmodel(skull, "progs/h_player_papyrus.mdl");
	setsize(skull, '0 0 0', '0 0 0');
	setorigin(skull, spot);
	skull.solid = SOLID_CORPSE;
	//set_movetype(skull, MOVETYPE_FLY);
	//SetMovetypeFollow(skull, this);
	setthink(skull, skull_fire);
	skull.nextthink = time + 0.7;
	skull.effects = EF_NOSHADOW;
	skull.owner = this;
	skull.realowner = this;
	skull.enemy = targ;

	vector dir = targ.origin + '0 0 16' - spot;
	dir = normalize(dir);
	skull.angles = vectoangles(dir);
	skull.angles_z = 90;
}

METHOD(Papyrus, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);

	SendPapyrusLine(actor, bound(1, ceil(random() * 5), 5));
}

METHOD(Papyrus, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.papyrus_cannon = true;
}

METHOD(Papyrus, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.papyrus_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.papyrus_cannon = false;
	return false;
}

METHOD(Papyrus, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		if(random() < 0.1)
			SendPapyrusLine(actor, bound(1, ceil(random() * 5), 5));
		entity selected = W_PickNearbyTarget(actor, actor, 700, true, false);
		if(selected)
		{
			Papyrus_ChargeLaser(actor, selected);
			STAT(QCC_ABILITYTIME, actor) = time + 3;
		}
		else
		{
			Papyrus_ThrowBone(actor);
			STAT(QCC_ABILITYTIME, actor) = time + 1;
		}
	}
}

// TODO: generic list of deathtypes that should never be blocked
bool Papyrus_forcedamage(int deathtype)
{
	switch(deathtype)
	{
		case DEATH_VOID.m_id:
		case DEATH_HURTTRIGGER.m_id:
		case DEATH_KILL.m_id:
		case DEATH_GENERIC.m_id:
		case DEATH_LAVA.m_id:
		case DEATH_CHECKPOINT.m_id:
			return true;
	}
	return false;
}

METHOD(Papyrus, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this && targ.health > 0 && damage > 0 && !(targ.flags & FL_GODMODE) && targ != attacker && !Papyrus_forcedamage(deathtype))
	{
		if(time < targ.papyrus_dmgtime)
			return ((deathmatch) ? 0.5 : 0);
		targ.papyrus_dmgtime = time + 0.5;
	}
	return 1;
}

void SendPapyrusLine(entity this, int liner)
{
	if(!liner || !IS_REAL_CLIENT(this))
		return;

	msg_entity = this;
	WriteHeader(MSG_ONE, TE_CSQC_PAPYRUS_LINE);
	WriteByte(MSG_ONE, liner);
}
#endif

#ifdef CSQC
string Sbar_PapyrusLine(int liner)
{
	switch(liner)
	{
		case 1: return "sb_pap_line1";
		case 2: return "sb_pap_line2";
		case 3: return "sb_pap_line3";
		case 4: return "sb_pap_line4";
		case 5: return "sb_pap_line5";
	}

	return string_null;
}

void Sbar_Papyrus_Push(int liner)
{
	string icon = Sbar_PapyrusLine(liner);
	if(!icon)
		return;

	++papyrus_count;
	--papyrus_index;

	if (papyrus_index == -1)
		papyrus_index = PAPYRUS_MAX_ENTRIES-1;

	// Free old strings
	if (papyrus_icons[papyrus_index])
		strunzone(papyrus_icons[papyrus_index]);

	// Allocate new strings
	papyrus_icons[papyrus_index] = strzone(icon);
	papyrus_times[papyrus_index] = time;
}

void Sbar_DrawPapyrus()
{
	if(papyrus_count == 0)
		return;

	vector pos, size;
	// hardcoded values from Xonotic, TODO
	vector panel_pos = vec2(0.13 * vid_conwidth, 0.80 * vid_conheight);
	vector panel_size = vec2(0.265 * vid_conwidth, 0.20 * vid_conheight);
	pos  = panel_pos;
	size = panel_size;

	float fade_start = max(0, 3); // 3 was autocvar_sbar_papyrus_time
	if(intermission) // fade out in half the time
		fade_start -= (time - intermission_time);
	float fade_time = max(0, 0.1); // 0.1 was autocvar_sbar_notify_fadetime
	float icon_aspect = 1;

	int entry_count = bound(1, floor(PAPYRUS_MAX_ENTRIES * size.y / size.x), PAPYRUS_MAX_ENTRIES);
	float entry_height = size.y / entry_count;

	float panel_width_half = size.x * 0.5;
	float icon_width_half = entry_height * icon_aspect / 2;

	vector icon_size = vec2(icon_aspect * 1.5, 1) * entry_height;
	vector icon_left = eX * (panel_width_half - icon_width_half);

	vector icon_pos;
	string icon;
	int i, j, count, step, limit;
	float alpha;

	// Order items from the bottom up
	i = entry_count - 1;
	step = -1;
	limit = -1;

	for(j = papyrus_index, count = 0; i != limit; i += step, ++j, ++count)
	{
		if (j == PAPYRUS_MAX_ENTRIES)
			j = 0;

		if(papyrus_times[j] + fade_start > time)
			alpha = 1;
		else if(fade_time != 0)
		{
			alpha = bound(0, (papyrus_times[j] + fade_start + fade_time - time) / fade_time, 1);
			if (alpha == 0)
				break;
		}
		else
			break;

		icon = papyrus_icons[j];

		if (icon != "")
		{
			icon_pos = pos + icon_left + eY * i * entry_height;
			drawpic(icon_pos, strcat("gfx/quake/", icon), icon_size, '1 1 1', alpha, DRAWFLAG_NORMAL);
		}
	}

	papyrus_count = count;
}

METHOD(Papyrus, m_overlay, void(Champions this))
{
	if(intermission || STAT(HEALTH) == -666)
		return;

	Sbar_DrawPapyrus();
}

NET_HANDLE(TE_CSQC_PAPYRUS_LINE, bool isNew)
{
	int liner = ReadByte();
	Sbar_Papyrus_Push(liner);

	_sound(NULL, CH_INFO, "player_papyrus/talk.wav", VOL_BASE, ATTEN_NONE);
	return true;
}

.vector vorg1, vorg2;
void Laser_Draw(entity this)
{
	string tex;
	tex = "particles/lgbeam";
	//tex = "particles/gauntletbeam";

	// NOTE: '1.1 1.1 1.1' rgb is used as a temporary workaround for #419
	Draw_CylindricLine(this.vorg1, this.vorg2, 32, tex, 0.25, -time * 3, '1.1 1.1 1.1', 1, DRAWFLAG_NORMAL, view_origin);
}

NET_HANDLE(TE_CSQC_PAPYRUS_LASER, bool isNew)
{
	Net_Accept(gaster);
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.25;
	this.draw = Laser_Draw;
	if (isNew) IL_PUSH(g_drawables, this);
	this.drawmask = MASK_NORMAL;

	this.vorg1 = ReadVector();
	this.vorg2 = ReadVector();

	return true;
}
#endif
