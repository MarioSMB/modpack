#include "thunderbolt.qh"

#ifdef GAMEQC
REGISTER_NET_LINKED(ENT_CLIENT_THUNDERBOLT)
#endif

#ifdef SVQC
.vector hook_start, hook_end;
bool thunderbolt_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_THUNDERBOLT);
	sf &= 0x7F;
	if(!sound_allowed(MSG_BROADCAST, this.realowner))
		sf |= 0x80;
	if(this.count)
		sf |= 8;
	else
		sf &= ~8;
	WriteByte(MSG_ENTITY, sf);
	WriteByte(MSG_ENTITY, weaponslot(this.weaponentity_fld));
	if(sf & 1)
		WriteByte(MSG_ENTITY, etof(this.realowner));
	if (sf & 2)
		WriteVector(MSG_ENTITY, this.hook_start);
	if (sf & 4)
		WriteVector(MSG_ENTITY, this.hook_end);

	return true;
}

.float cnt;
void thunderbolt_think(entity this)
{
	entity wepent = this.owner;
	entity actor = this.realowner;
	.entity weaponentity = this.weaponentity_fld;

	if(this != wepent.thunderbolt)
	{
		delete(this);
		return;
	}

	if(actor.ammo_cells < 1)
	{
		if(this == wepent.thunderbolt)
			wepent.thunderbolt = NULL;
		delete(this);

		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;
		W_SwitchWeapon(actor, w_getbestweapon(actor, weaponentity), weaponentity);
		return;
	}

	// explode if underwater
	if(actor.waterlevel > 1)
	{
		if(wepent)
		{
			wepent.m_frame = 0;
			w_ready(wepent);
		}

		int cells = actor.ammo_cells;
		actor.ammo_cells = 0;
		W_SetCurrentAmmo(actor);
		discharged = true;
		T_RadiusDamage(actor, actor, 35 * cells, DEATH_DISCHARGE.m_id, NULL);
		discharged = false;
		return;
	}

	if (actor.health < 1 || actor.exptime != 0 || !PHYS_INPUT_BUTTON_ATCK(actor) || wepent.m_weapon != WEP_LIGHTNING || actor.is_frozen
		|| actor.tank || STAT(CLOCKWORK, actor) || actor.m_transform || STAT(CANNON, actor))
	{
		if(this == wepent.thunderbolt)
			wepent.thunderbolt = NULL;
		delete(this);
		if(wepent)
		{
			wepent.m_frame = 0;
			w_ready(wepent);
		}
		return;
	}

	bool is_attackframe = false;
	if(time >= this.cnt)
	{
		is_attackframe = true;
		this.cnt = time + FRAME_TIME;
	}

	// just keep it up to date until we stop firing!
	if(wepent)
	{
		ATTACK_FINISHED(actor, weaponentity) = time + 0.5; // prevent attacking again
		if(is_attackframe)
		{
			wepent.m_frame += 1;
			if(wepent.m_frame >= 5)
				wepent.m_frame = 1;
			//wep_set_anim(wepent, wepent.m_frame, w_ready);
		}
	}

	if(actor.t_width < time)
	{
		_sound(actor, CH_WEAPON_SINGLE, "weapons/lhit.wav", 1, ATTN_NORM);
		actor.t_width = time + 0.6;
	}

	if(is_attackframe)
		SuperDamageSound(actor);

	if(IS_PLAYER(actor) && is_attackframe)
		player_light1(actor);

	actor.effects |= EF_MUZZLEFLASH;

	float thunderbolt_range = 1024;
	//actor.punchangle_x = -2 * autocvar_sv_quake_recoil;
	if(is_attackframe)
		W_TakeAmmo(actor, IT_CELLS, 1);

	this.nextthink = time;

	makevectors(actor.v_angle);
	vector w_shotorg = W_Shotorg(actor, weaponentity);
	vector w_shotdir = v_forward;

	float lag = (IS_PLAYER(actor)) ? antilag_getlag(actor) : 0;
	if(lag)
		antilag_takeback_all(actor, lag);

	traceline(w_shotorg, w_shotorg + w_shotdir * thunderbolt_range, MOVE_NORMAL, actor);

	vector w_shotend = trace_endpos;
	bool didhit = (trace_ent || trace_fraction != 1.0);

	if(is_attackframe)
		LightningDamage(w_shotorg, w_shotend + v_forward*4, actor, 30, WEP_LIGHTNING.m_id);

	if(lag)
		antilag_restore_all(actor);

	// draw effect
	if(w_shotorg != this.hook_start)
	{
		this.SendFlags |= 2;
		this.hook_start = w_shotorg;
	}
	if(w_shotend != this.hook_end)
	{
		this.SendFlags |= 4;
		this.hook_end = w_shotend;
	}
	if(didhit != this.count)
	{
		this.SendFlags |= 8;
		this.count = didhit;
	}
}

void W_FireLightning(entity this, .entity weaponentity)
{
	entity beam = spawn();
	beam.classname = "thunderbolt";
	beam.solid = SOLID_NOT;
	setthink(beam, thunderbolt_think);
	beam.owner = this.(weaponentity);
	beam.realowner = this;
	set_movetype(beam, MOVETYPE_NONE);
	beam.shot_spread = 0;
	Net_LinkEntity(beam, false, 0, thunderbolt_send);
	beam.weaponentity_fld = weaponentity;

	this.(weaponentity).thunderbolt = beam;

	thunderbolt_think(beam);
}

METHOD(Thunderbolt, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		W_FireLightning(actor, weaponentity);
		ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
		_sound(actor, CH_WEAPON_A, "weapons/lstart.wav", 1, ATTN_NORM);
	}
}
METHOD(Thunderbolt, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_cells >= 1;
	return ammo_amount;
}
METHOD(Thunderbolt, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Thunderbolt, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

#ifdef CSQC
PRECACHE(Thunderbolt)
{
	precache_pic("particles/gauntletbeam");

	//precache_sound("weapons/thunderbolt_loop.wav");
}

.int beam_slot;
.float teleport_time;
void Draw_Thunderbolt(entity this)
{
	vector a, b;

	if (this.teleport_time && time > this.teleport_time)
	{
		sound(this, CH_SHOTS_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM); // safeguard
		this.teleport_time = 0;
	}

	InterpolateOrigin_Do(this);

	vector vs = '24 0 -12';

	if (this.owner.sv_entnum == (player_localentnum - 1) && ((player_localnum + 1) == player_localentnum))
	{
		if (autocvar_chase_active)
		{
			a = csqcplayer.origin + csqcplayer.view_ofs;
			b = this.velocity;
		}
		else
		{
			entity wepent = viewmodels[this.beam_slot];
			if(wepent)
			{
				vs.y += wepent.movedir_y;
				vs.z += wepent.movedir_z;
			}
			a = view_origin + view_forward * vs.x + view_right * -vs.y + view_up * vs.z;
			b = view_origin + view_forward * vlen(this.velocity - this.origin);
		}
	}
	else
	{
		a = this.origin;
		b = this.velocity;
	}

	float intensity = 1;
	float offset = Noise_Brown(this, frametime) * 10;
	vector rgb = '1 1 1';
	string tex = "particles/gauntletbeam";

	Draw_CylindricLine(a, b, 8, tex, 0.25, offset, rgb, min(1, intensity), DRAWFLAG_NORMAL, view_origin);

	setorigin(this, a);

	//pointparticles(EFFECT_THUNDERBOLT_MUZZLEFLASH, a, normalize(b - a) * 50, bound(0, frametime, 0.1));

	//if(this.count)
		//pointparticles(EFFECT_THUNDERBOLT_IMPACT, b, normalize(a - b), 0.2);
}

void Remove_Thunderbolt(entity this)
{
	sound(this, CH_SHOTS_SINGLE, SND_Null, VOL_BASE, ATTEN_NORM);
}

NET_HANDLE(ENT_CLIENT_THUNDERBOLT, bool isNew)
{
	int sf = ReadByte();
	int slot = ReadByte();
	this.silent = (sf & 0x80);
	this.count = (sf & 8);

	this.beam_slot = slot;

	this.iflags = IFLAG_VELOCITY | IFLAG_ORIGIN;

	InterpolateOrigin_Undo(this);

	if (sf & 1)
	{
		this.sv_entnum = ReadByte();
		this.owner = playerslots[this.sv_entnum - 1];
	}
	if (sf & 2)
	{
		this.origin = ReadVector();
		setorigin(this, this.origin);
	}
	if (sf & 4)
		this.velocity = ReadVector();

	InterpolateOrigin_Note(this);

	if (isNew || !this.teleport_time)
	{
		this.draw = Draw_Thunderbolt;
		if (!IL_CONTAINS(g_drawables, this))
			IL_PUSH(g_drawables, this);
		this.entremove = Remove_Thunderbolt;

		//if(!this.silent)
			//_sound(this, CH_SHOTS_SINGLE, "weapons/thunderbolt_loop.wav", 1, ATTEN_NORM);
	}

	this.teleport_time = time + 10;
	return true;
}
#endif
