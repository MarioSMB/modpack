#include "csqcprojectile.qh"

.int csqcprojectile_type;
.bool silent;

bool CSQCProjectile_SendEntity(entity this, entity to, int sf)
{
	float ft, fr;

	// note: flag 0x08 = no trail please (teleport bit)
	sf = sf & 0x0F;

	if(this.csqcprojectile_clientanimate)
		sf |= 0x80; // client animated, not interpolated

	if(IS_ONGROUND(this))
		sf |= 0x40;

	if(this.silent)
		sf |= 4;
	else
		sf &= ~4;

	ft = fr = 0;
	if(this.fade_time != 0 || this.fade_rate != 0)
	{
		ft = (this.fade_time - time) / sys_frametime;
		fr = (1 / this.fade_rate) / sys_frametime;
		if(ft <= 255 && fr <= 255 && fr >= 1)
			sf |= 0x20;
	}

	if(this.gravity != 0)
		sf |= 0x10;

	WriteHeader(MSG_ENTITY, ENT_CLIENT_PROJECTILE);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		WriteVector(MSG_ENTITY, this.origin);

		if(sf & 0x80)
		{
			WriteVector(MSG_ENTITY, this.velocity);
			if(sf & 0x10)
				WriteCoord(MSG_ENTITY, this.gravity);
		}

		if(sf & 0x20)
		{
			WriteByte(MSG_ENTITY, ft);
			WriteByte(MSG_ENTITY, fr);
		}

		WriteByte(MSG_ENTITY, this.realowner.clientcolors); // NOTE: doesn't work on non-clients
	}

	if(sf & 2)
		WriteByte(MSG_ENTITY, this.csqcprojectile_type); // TODO maybe put this into sf?

	return true;
}

.vector csqcprojectile_oldorigin;
void CSQCProjectile_Check(entity e)
{
	if(e.csqcprojectile_clientanimate)
	if(IS_ONGROUND(e))
	if(e.origin != e.csqcprojectile_oldorigin)
		UpdateCSQCProjectile(e);
	e.csqcprojectile_oldorigin = e.origin;
}

void CSQCProjectile(entity e, float clientanimate, int type, float docull)
{
	Net_LinkEntity(e, docull, 0, CSQCProjectile_SendEntity);

	e.csqcprojectile_clientanimate = clientanimate;

	if(e.move_movetype == MOVETYPE_TOSS || e.move_movetype == MOVETYPE_BOUNCE)
	{
		if(e.gravity == 0)
			e.gravity = 1;
	}
	else
		e.gravity = 0;

	e.silent = !sound_allowed(MSG_BROADCAST, e);
	e.csqcprojectile_type = type;
}

void UpdateCSQCProjectile(entity e)
{
	if(getSendEntity(e) == CSQCProjectile_SendEntity)
	{
		// send new origin data
		e.SendFlags |= 0x01;
	}
}

void UpdateCSQCProjectileAfterTeleport(entity e)
{
	if(getSendEntity(e) == CSQCProjectile_SendEntity)
	{
		// send new origin data
		e.SendFlags |= 0x01;
		// send full data as the projectile may need resetting
		// this is a workaround for client-side projectiles erroneously calling their SUB_Stop touch function occasionally
		// when passing through a warpzone
		e.SendFlags |= 2;
		// mark as teleported
		e.SendFlags |= 0x08;
	}
}
