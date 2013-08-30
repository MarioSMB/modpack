..entity owned_by_field;
.float rule;
.string model1;
.string model2;
.string model3;

.float(entity) waypointsprite_visible_for_player;

void WaypointSprite_UpdateSprites(entity e, string m1, string m2, string m3)
{
	if(m1 != e.model1)
	{
		e.model1 = m1;
		e.SendFlags |= 2;
	}
	if(m2 != e.model2)
	{
		e.model2 = m2;
		e.SendFlags |= 4;
	}
	if(m3 != e.model3)
	{
		e.model3 = m3;
		e.SendFlags |= 8;
	}
}

void WaypointSprite_UpdateHealth(entity e, float f)
{
	f = bound(0, f, e.max_health);
	if(f != e.health || e.pain_finished)
	{
		e.health = f;
		e.pain_finished = 0;
		e.SendFlags |= 0x80;
	}
}

void WaypointSprite_UpdateMaxHealth(entity e, float f)
{
	if(f != e.max_health || e.pain_finished)
	{
		e.max_health = f;
		e.pain_finished = 0;
		e.SendFlags |= 0x80;
	}
}

void WaypointSprite_UpdateBuildFinished(entity e, float f)
{
	if(f != e.pain_finished || e.max_health)
	{
		e.max_health = 0;
		e.pain_finished = f;
		e.SendFlags |= 0x80;
	}
}

void WaypointSprite_UpdateOrigin(entity e, vector o)
{
	if(o != e.origin)
	{
		setorigin(e, o);
		e.SendFlags |= 64;
	}
}

void WaypointSprite_UpdateRule(entity e, float t, float r)
{
	// no check, as this is never called without doing an actual change (usually only once)
	e.rule = r;
	e.team = t;
	e.SendFlags |= 1;
}

void WaypointSprite_UpdateTeamRadar(entity e, float icon, vector col)
{
	// no check, as this is never called without doing an actual change (usually only once)
	e.cnt = (icon & 0x7F) | (e.cnt & 0x80);
	e.colormod = col;
	e.SendFlags |= 32;
}

.float waypointsprite_pingtime;
.float waypointsprite_helpmetime;
void WaypointSprite_Ping(entity e)
{
	// anti spam
	if(time < e.waypointsprite_pingtime)
		return;
	e.waypointsprite_pingtime = time + 0.3;
	// ALWAYS sends (this causes a radar circle), thus no check
	e.cnt |= 0x80;
	e.SendFlags |= 32;
}

float waypointsprite_limitedrange, waypointsprite_deployed_lifetime, waypointsprite_deadlifetime;

void WaypointSprite_HelpMePing(entity e)
{
	WaypointSprite_Ping(e);
	e.waypointsprite_helpmetime = time + waypointsprite_deployed_lifetime;
	e.SendFlags |= 32;
}

void WaypointSprite_FadeOutIn(entity e, float t)
{
	if(!e.fade_time)
	{
		e.fade_time = t;
		e.teleport_time = time + t;
	}
	else if(t < (e.teleport_time - time))
	{
		// accelerate the waypoint's dying
		// ensure:
		//   (e.teleport_time - time) / wp.fade_time stays
		//   e.teleport_time = time + fadetime
		float current_fadetime;
		current_fadetime = e.teleport_time - time;
		e.teleport_time = time + t;
		e.fade_time = e.fade_time * t / current_fadetime;
	}

	e.SendFlags |= 16;
}

void WaypointSprite_Init()
{
	waypointsprite_limitedrange = autocvar_sv_waypointsprite_limitedrange;
	waypointsprite_deployed_lifetime = autocvar_sv_waypointsprite_deployed_lifetime;
	waypointsprite_deadlifetime = autocvar_sv_waypointsprite_deadlifetime;
}
void WaypointSprite_InitClient(entity e)
{
}

void WaypointSprite_Kill(entity wp)
{
	if(!wp)
		return;
	if(wp.owner)
		wp.owner.(wp.owned_by_field) = world;
	remove(wp);
}

void WaypointSprite_Disown(entity wp, float fadetime)
{
	if(!wp)
		return;
	if(wp.classname != "sprite_waypoint")
	{
		backtrace("Trying to disown a non-waypointsprite");
		return;
	}
	if(wp.owner)
	{
		if(wp.exteriormodeltoclient == wp.owner)
			wp.exteriormodeltoclient = world;
		wp.owner.(wp.owned_by_field) = world;
		wp.owner = world;

		WaypointSprite_FadeOutIn(wp, fadetime);
	}
}

void WaypointSprite_Think()
{
	float doremove;

	doremove = FALSE;

	if(self.fade_time)
	{
		if(time >= self.teleport_time)
			doremove = TRUE;
	}

	if(self.exteriormodeltoclient)
		WaypointSprite_UpdateOrigin(self, self.exteriormodeltoclient.origin + self.view_ofs);

	if(doremove)
		WaypointSprite_Kill(self);
	else
		self.nextthink = time; // WHY?!?
}

float WaypointSprite_visible_for_player(entity e)
{
	// personal waypoints
	if(self.enemy)
		if(self.enemy != e)
			return FALSE;

	// team waypoints
	if(self.team && self.rule == SPRITERULE_DEFAULT)
	{
		if(self.team != e.team)
			return FALSE;
		if not(IS_PLAYER(e))
			return FALSE;
	}

	return TRUE;
}

entity WaypointSprite_getviewentity(entity e)
{
	if(IS_SPEC(e))
		e = e.enemy;
	/* TODO idea (check this breaks nothing)
	else if(e.classname == "observer")
		e = world;
	*/
	return e;
}

float WaypointSprite_isteammate(entity e, entity e2)
{
	if(teamplay)
	{
		if(e2.team != e.team)
			return FALSE;
	}
	else
	{
		if(e2 != e)
			return FALSE;
	}
	return TRUE;
}

float WaypointSprite_Customize()
{
	// this is not in SendEntity because it shall run every frame, not just every update

	// make spectators see what the player would see
	entity e;
	e = WaypointSprite_getviewentity(other);

	if(MUTATOR_CALLHOOK(CustomizeWaypoint))
		return FALSE;

	return self.waypointsprite_visible_for_player(e);
}

float WaypointSprite_SendEntity(entity to, float sendflags)
{
	float dt;

	WriteByte(MSG_ENTITY, ENT_CLIENT_WAYPOINT);

	sendflags = sendflags & 0x7F;
	
	if(g_nexball)
		sendflags &= ~0x80;
	else if(self.max_health || (self.pain_finished && (time < self.pain_finished + 0.25)))
		sendflags |= 0x80;

	WriteByte(MSG_ENTITY, sendflags);

	if(sendflags & 0x80)
	{
		if(self.max_health)
		{
			WriteByte(MSG_ENTITY, (self.health / self.max_health) * 191.0);
		}
		else
		{
			dt = self.pain_finished - time;
			dt = bound(0, dt * 32, 16383);
			WriteByte(MSG_ENTITY, (dt & 0xFF00) / 256 + 192);
			WriteByte(MSG_ENTITY, (dt & 0x00FF));
		}
	}

	if(sendflags & 64)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}

	if(sendflags & 1)
	{
		WriteByte(MSG_ENTITY, self.team);
		WriteByte(MSG_ENTITY, self.rule);
	}

	if(sendflags & 2)
		WriteString(MSG_ENTITY, self.model1);

	if(sendflags & 4)
		WriteString(MSG_ENTITY, self.model2);

	if(sendflags & 8)
		WriteString(MSG_ENTITY, self.model3);

	if(sendflags & 16)
	{
		WriteCoord(MSG_ENTITY, self.fade_time);
		WriteCoord(MSG_ENTITY, self.teleport_time);
		WriteShort(MSG_ENTITY, self.fade_rate); // maxdist
		float f;
		f = 0;
		if(self.currentammo)
			f |= 1; // hideable
		if(self.exteriormodeltoclient == to)
			f |= 2; // my own
		WriteByte(MSG_ENTITY, f);
	}

	if(sendflags & 32)
	{
		WriteByte(MSG_ENTITY, self.cnt); // icon on radar
		WriteByte(MSG_ENTITY, self.colormod_x * 255.0);
		WriteByte(MSG_ENTITY, self.colormod_y * 255.0);
		WriteByte(MSG_ENTITY, self.colormod_z * 255.0);

		if(WaypointSprite_isteammate(self.owner, WaypointSprite_getviewentity(to)))
		{
			dt = (self.waypointsprite_helpmetime - time) / 0.1;
			if(dt < 0)
				dt = 0;
			if(dt > 255)
				dt = 255;
			WriteByte(MSG_ENTITY, dt);
		}
		else
			WriteByte(MSG_ENTITY, 0);
	}

	return TRUE;
}

void WaypointSprite_Reset()
{
	// if a WP wants to time out, let it time out immediately; other WPs ought to be reset/killed by their owners

	if(self.fade_time) // there was there before: || g_keyhunt, do we really need this?
		WaypointSprite_Kill(self);
}

entity WaypointSprite_Spawn(
	string spr, // sprite
	float lifetime, float maxdistance, // lifetime, max distance
	entity ref, vector ofs, // position
	entity showto, float t, // show to whom? Use a flag to indicate a team
	entity own, .entity ownfield, // remove when own gets killed
	float hideable, // true when it should be controlled by cl_hidewaypoints
	float icon, vector rgb // initial icon and color
)
{
	entity wp;
	wp = spawn();
	wp.classname = "sprite_waypoint";
	wp.teleport_time = time + lifetime;
	wp.fade_time = lifetime;
	wp.exteriormodeltoclient = ref;
	if(ref)
	{
		wp.view_ofs = ofs;
		setorigin(wp, ref.origin + ofs);
	}
	else
		setorigin(wp, ofs);
	wp.enemy = showto;
	wp.team = t;
	wp.owner = own;
	wp.currentammo = hideable;
	if(own)
	{
		if(own.ownfield)
			remove(own.ownfield);
		own.ownfield = wp;
		wp.owned_by_field = ownfield;
	}
	wp.fade_rate = maxdistance;
	wp.think = WaypointSprite_Think;
	wp.nextthink = time;
	wp.model1 = spr;
	wp.customizeentityforclient = WaypointSprite_Customize;
	wp.waypointsprite_visible_for_player = WaypointSprite_visible_for_player;
	wp.reset2 = WaypointSprite_Reset;
	wp.cnt = icon;
	wp.colormod = rgb;
	Net_LinkEntity(wp, FALSE, 0, WaypointSprite_SendEntity);
	return wp;
}

entity WaypointSprite_SpawnFixed(
	string spr,
	vector ofs,
	entity own,
	.entity ownfield,
	float icon, vector rgb // initial icon and color
)
{
	return WaypointSprite_Spawn(spr, 0, 0, world, ofs, world, 0, own, ownfield, TRUE, icon, rgb);
}

.entity waypointsprite_deployed_fixed;
entity WaypointSprite_DeployFixed(
	string spr,
	float limited_range,
	vector ofs,
	float icon, vector rgb // initial icon and color
)
{
	float t, maxdistance;
	if(teamplay)
		t = self.team;
	else
		t = 0;
	if(limited_range)
		maxdistance = waypointsprite_limitedrange;
	else
		maxdistance = 0;
	return WaypointSprite_Spawn(spr, waypointsprite_deployed_lifetime, maxdistance, world, ofs, world, t, self, waypointsprite_deployed_fixed, FALSE, icon, rgb);
}

.entity waypointsprite_deployed_personal;
entity WaypointSprite_DeployPersonal(
	string spr,
	vector ofs,
	float icon, vector rgb // initial icon and color
)
{
	return WaypointSprite_Spawn(spr, 0, 0, world, ofs, world, 0, self, waypointsprite_deployed_personal, FALSE, icon, rgb);
}

.entity waypointsprite_attached;
.entity waypointsprite_attachedforcarrier;
entity WaypointSprite_Attach(
	string spr,
	float limited_range,
	float icon, vector rgb // initial icon and color
)
{
	float t, maxdistance;
	if(self.waypointsprite_attachedforcarrier)
		return world; // can't attach to FC
	if(teamplay)
		t = self.team;
	else
		t = 0;
	if(limited_range)
		maxdistance = waypointsprite_limitedrange;
	else
		maxdistance = 0;
	return WaypointSprite_Spawn(spr, waypointsprite_deployed_lifetime, maxdistance, self, '0 0 64', world, t, self, waypointsprite_attached, FALSE, icon, rgb);
}

entity WaypointSprite_AttachCarrier(
	string spr,
	entity carrier,
	float icon, vector rgb // initial icon and color
)
{
	entity e;
	WaypointSprite_Kill(carrier.waypointsprite_attached); // FC overrides attached
	e = WaypointSprite_Spawn(spr, 0, 0, carrier, '0 0 64', world, carrier.team, carrier, waypointsprite_attachedforcarrier, FALSE, icon, rgb);
	if(e)
	{
		WaypointSprite_UpdateMaxHealth(e, '1 0 0' * healtharmor_maxdamage(start_health, start_armorvalue, autocvar_g_balance_armor_blockpercent) * 2);
		WaypointSprite_UpdateHealth(e, '1 0 0' * healtharmor_maxdamage(carrier.health, carrier.armorvalue, autocvar_g_balance_armor_blockpercent));
	}
	return e;
}

void WaypointSprite_DetachCarrier(entity carrier)
{
	WaypointSprite_Disown(carrier.waypointsprite_attachedforcarrier, waypointsprite_deadlifetime);
}

void WaypointSprite_ClearPersonal()
{
	WaypointSprite_Kill(self.waypointsprite_deployed_personal);
}

void WaypointSprite_ClearOwned()
{
	WaypointSprite_Kill(self.waypointsprite_deployed_fixed);
	WaypointSprite_Kill(self.waypointsprite_deployed_personal);
	WaypointSprite_Kill(self.waypointsprite_attached);
}

void WaypointSprite_PlayerDead()
{
	WaypointSprite_Disown(self.waypointsprite_attached, waypointsprite_deadlifetime);
	WaypointSprite_DetachCarrier(self);
}

void WaypointSprite_PlayerGone()
{
	WaypointSprite_Disown(self.waypointsprite_deployed_fixed, waypointsprite_deadlifetime);
	WaypointSprite_Kill(self.waypointsprite_deployed_personal);
	WaypointSprite_Disown(self.waypointsprite_attached, waypointsprite_deadlifetime);
	WaypointSprite_DetachCarrier(self);
}
