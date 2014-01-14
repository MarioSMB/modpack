/*
 * Copyright (c) 2011 Rudolf Polzer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

// generic CSQC model code

float CSQCModel_Send(entity to, float sf)
{
	// some nice flags for CSQCMODEL_IF
	float isplayer = (IS_CLIENT(self));
	float islocalplayer = (self == to);
	float isnolocalplayer = (isplayer && (self != to));

	unused_float = isplayer;
	unused_float = islocalplayer;
	unused_float = isnolocalplayer;

	WriteByte(MSG_ENTITY, ENT_CLIENT_MODEL);
	WriteInt24_t(MSG_ENTITY, sf);

#define CSQCMODEL_IF(cond) if(cond) {
#define CSQCMODEL_ENDIF }
#define CSQCMODEL_PROPERTY(flag,t,r,w,f) \
	if(sf & flag) \
	{ \
		w(MSG_ENTITY, self.csqcmodel_##f); \
	}
#define CSQCMODEL_PROPERTY_SCALED(flag,t,r,w,f,s,mi,ma) CSQCMODEL_PROPERTY(flag,t,r,w,f)
	ALLPROPERTIES
#undef CSQCMODEL_PROPERTY_SCALED
#undef CSQCMODEL_PROPERTY
#undef CSQCMODEL_ENDIF
#undef CSQCMODEL_IF

	return TRUE;
}

#ifdef CSQCPLAYER_FORCE_UPDATES
.float csqcmodel_nextforcedupdate;
#endif
void CSQCModel_CheckUpdate()
{
	// some nice flags for CSQCMODEL_IF
	float isplayer = (IS_CLIENT(self));
	float islocalplayer = isplayer; // we set BOTH to 1 here as we need the sendflags
	float isnolocalplayer = isplayer; // we set BOTH to 1 here as we need the sendflags

	unused_float = isplayer;
	unused_float = islocalplayer;
	unused_float = isnolocalplayer;

#ifdef CSQCPLAYER_FORCE_UPDATES
	if(isplayer && time > self.csqcmodel_nextforcedupdate)
	{
		self.SendFlags |= CSQCMODEL_PROPERTY_ORIGIN;
		self.csqcmodel_nextforcedupdate = time + CSQCPLAYER_FORCE_UPDATES * (0.5 + random()); // ensure about 4 origin sends per sec
	}
#endif

	if(self.effects & EF_RESTARTANIM_BIT)
	{
		self.SendFlags |= CSQCMODEL_PROPERTY_FRAME | CSQCMODEL_PROPERTY_FRAME2; // full anim resend please
		self.effects &= ~EF_RESTARTANIM_BIT;
	}

	if(self.effects & EF_TELEPORT_BIT)
	{
		self.SendFlags |= CSQCMODEL_PROPERTY_TELEPORTED; // no interpolation please
		self.effects &= ~EF_TELEPORT_BIT;
	}

#define CSQCMODEL_IF(cond) if(cond) {
#define CSQCMODEL_ENDIF }
#define CSQCMODEL_PROPERTY(flag,t,r,w,f) \
	{ \
		t tmp = self.f; \
		if(tmp != self.csqcmodel_##f) \
		{ \
			self.csqcmodel_##f = tmp; \
			self.SendFlags |= flag; \
		} \
	}
#define CSQCMODEL_PROPERTY_SCALED(flag,t,r,w,f,s,mi,ma) \
	{ \
		t tmp = rint(bound(mi, s * self.f, ma) - mi); \
		if(tmp != self.csqcmodel_##f) \
		{ \
			self.csqcmodel_##f = tmp; \
			self.SendFlags |= flag; \
		} \
	}
	ALLPROPERTIES
#undef CSQCMODEL_PROPERTY_SCALED
#undef CSQCMODEL_PROPERTY
#undef CSQCMODEL_ENDIF
#undef CSQCMODEL_IF
}

void CSQCModel_LinkEntity()
{
	self.SendEntity = CSQCModel_Send;
	self.SendFlags = 0xFFFFFF;
	CSQCModel_CheckUpdate();
}

void CSQCModel_UnlinkEntity()
{
	self.SendEntity = func_null;
}
