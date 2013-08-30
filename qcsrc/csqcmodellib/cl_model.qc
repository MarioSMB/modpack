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

var float autocvar_cl_lerpanim_maxdelta_framegroups = 0.1;
var float autocvar_cl_nolerp = 0;

.float csqcmodel_lerpfrac;
.float csqcmodel_lerpfrac2;
.float csqcmodel_lerpfractime;
.float csqcmodel_lerpfrac2time;

void CSQCModel_InterpolateAnimation_2To4_PreNote(float sf)
{
	if(sf & CSQCMODEL_PROPERTY_FRAME)
	{
		self.frame3 = self.frame;
		self.frame3time = self.frame1time;
	}
	if(sf & CSQCMODEL_PROPERTY_FRAME2)
	{
		self.frame4 = self.frame2;
		self.frame4time = self.frame2time;
	}
	if(sf & CSQCMODEL_PROPERTY_LERPFRAC)
	{
		self.csqcmodel_lerpfrac2 = self.csqcmodel_lerpfrac;
		self.csqcmodel_lerpfrac2time = self.csqcmodel_lerpfractime;
		self.lerpfrac = self.csqcmodel_lerpfrac;
	}
}
void CSQCModel_InterpolateAnimation_1To2_PreNote(float sf)
{
	if(sf & CSQCMODEL_PROPERTY_FRAME)
	{
		self.frame2 = self.frame;
		self.frame2time = self.frame1time;
	}
}
void CSQCModel_InterpolateAnimation_PreNote(float sf)
{
#ifdef CSQCMODEL_HAVE_TWO_FRAMES
	CSQCModel_InterpolateAnimation_2To4_PreNote(sf);
#else
	CSQCModel_InterpolateAnimation_1To2_PreNote(sf);
#endif
}

void CSQCModel_InterpolateAnimation_2To4_Note(float sf, float set_times)
{
	if(sf & CSQCMODEL_PROPERTY_FRAME)
	{
		if(set_times)
			self.frame1time = time;
	}
	if(sf & CSQCMODEL_PROPERTY_FRAME2)
	{
		if(set_times)
			self.frame2time = time;
	}
	if(sf & CSQCMODEL_PROPERTY_LERPFRAC)
	{
		self.csqcmodel_lerpfrac = self.lerpfrac;
		if(set_times)
			self.csqcmodel_lerpfractime = time;
	}
}
void CSQCModel_InterpolateAnimation_1To2_Note(float sf, float set_times)
{
	if(sf & CSQCMODEL_PROPERTY_FRAME)
	{
		if(set_times)
			self.frame1time = time;
	}
}
void CSQCModel_InterpolateAnimation_Note(float sf)
{
#ifdef CSQCMODEL_HAVE_TWO_FRAMES
	CSQCModel_InterpolateAnimation_2To4_Note(sf, TRUE);
#else
	CSQCModel_InterpolateAnimation_1To2_Note(sf, TRUE);
#endif
}

void CSQCModel_InterpolateAnimation_2To4_Do()
{
	if(autocvar_cl_nolerp || (autocvar_cl_lerpanim_maxdelta_framegroups == 0))
	{
		self.lerpfrac = self.csqcmodel_lerpfrac;
		self.lerpfrac3 = 0;
		self.lerpfrac4 = 0;
	}
	else
	{
		float l13, l24, llf;
		float l24_13;

		if(self.frame3time == 0) // if frame1/3 were not previously displayed, only frame1 can make sense
			l13 = 1;
		else
			l13 = bound(0, (time - self.frame1time) / autocvar_cl_lerpanim_maxdelta_framegroups, 1);

		if(self.frame4time == 0) // if frame2/4 were not previously displayed, only frame2 can make sense
			l24 = 1;
		else
			l24 = bound(0, (time - self.frame2time) / autocvar_cl_lerpanim_maxdelta_framegroups, 1);

		if(self.csqcmodel_lerpfrac2time == 0) // if there is no old lerpfrac (newly displayed model), only lerpfrac makes sense
			llf = 1;
		else
			llf = bound(0, (time - self.csqcmodel_lerpfractime) / autocvar_cl_lerpanim_maxdelta_framegroups, 1);

		l24_13 = self.csqcmodel_lerpfrac * llf + self.csqcmodel_lerpfrac2 * (1 - llf);

		self.lerpfrac  = l24 * l24_13;
		self.lerpfrac4 = (1 - l24) * l24_13;
		self.lerpfrac3 = (1 - l13) * (1 - l24_13);

		if(l24_13 == 0) // if frames 2/4 are not displayed, clear their frametime
		{
			self.frame2time = 0;
			self.frame4time = 0;
		}

		if(l24_13 == 1) // if frames 1/3 are not displayed, clear their frametime
		{
			self.frame1time = 0;
			self.frame3time = 0;
		}
	}
}
void CSQCModel_InterpolateAnimation_1To2_Do()
{
	if(autocvar_cl_nolerp || (autocvar_cl_lerpanim_maxdelta_framegroups == 0))
	{
		self.lerpfrac = 0;
	}
	else
	{
		if(self.frame2time == 0) // if frame2 was not previously displayed, only frame1 can make sense
			self.lerpfrac = 0;
		else
			self.lerpfrac = 1 - bound(0, (time - self.frame1time) / autocvar_cl_lerpanim_maxdelta_framegroups, 1);
	}
}
void CSQCModel_InterpolateAnimation_Do()
{
#ifdef CSQCMODEL_HAVE_TWO_FRAMES
	CSQCModel_InterpolateAnimation_2To4_Do();
#else
	CSQCModel_InterpolateAnimation_1To2_Do();
#endif
}

void CSQCModel_Draw()
{
	// some nice flags for CSQCMODEL_IF and the hooks
	local noref float isplayer = (self.entnum >= 1 && self.entnum <= maxclients);
	local noref float islocalplayer = (self.entnum == player_localnum + 1);
	local noref float isnolocalplayer = (isplayer && (self.entnum != player_localnum + 1));

	// we don't do this for the local player as that one is already handled
	// by CSQCPlayer_SetCamera()
	if(!CSQCPlayer_IsLocalPlayer())
		InterpolateOrigin_Do();

	CSQCModel_InterpolateAnimation_Do();

	{ CSQCMODEL_HOOK_PREDRAW }

	// inherit draw flags easily
	entity root = self;
	while(root.tag_entity)
		root = root.tag_entity;
	if(self != root)
	{
		self.renderflags &= ~(RF_EXTERNALMODEL | RF_VIEWMODEL);
		self.renderflags |= (root.renderflags & (RF_EXTERNALMODEL | RF_VIEWMODEL));
	}

	// we're drawn, now teleporting is over
	self.csqcmodel_teleported = 0;
}

void CSQCModel_Read(float isnew)
{
	float sf;
	sf = ReadShort();

	// some nice flags for CSQCMODEL_IF and the hooks
	local noref float isplayer = (self.entnum >= 1 && self.entnum <= maxclients);
	local noref float islocalplayer = (self.entnum == player_localnum + 1);
	local noref float isnolocalplayer = (isplayer && (self.entnum != player_localnum + 1));

	self.classname = "csqcmodel";
	self.iflags |= IFLAG_ORIGIN; // interpolate origin too
	self.iflags |= IFLAG_ANGLES; // interpolate angles too
	self.iflags |= IFLAG_VELOCITY | IFLAG_AUTOVELOCITY; // let's calculate velocity automatically

	{ CSQCMODEL_HOOK_PREUPDATE }

	CSQCPlayer_PreUpdate();
	InterpolateOrigin_Undo();
	CSQCModel_InterpolateAnimation_PreNote(sf);

#define CSQCMODEL_IF(cond) if(cond) {
#define CSQCMODEL_ENDIF }
#define CSQCMODEL_PROPERTY(flag,t,r,w,f) \
	if(sf & flag) \
		self.f = r();
#define CSQCMODEL_PROPERTY_SCALED(flag,t,r,w,f,s,mi,ma) \
	if(sf & flag) \
		self.f = (r() + mi) / s;
	ALLPROPERTIES
#undef CSQCMODEL_PROPERTY_SCALED
#undef CSQCMODEL_PROPERTY
#undef CSQCMODEL_ENDIF
#undef CSQCMODEL_IF

	if(sf & CSQCMODEL_PROPERTY_MODELINDEX)
		setmodelindex(self, self.modelindex); // this retrieves the .model key and sets mins/maxs/absmin/absmax
		// FIXME do we WANT this to override mins/maxs?

	if(sf & CSQCMODEL_PROPERTY_TELEPORTED)
	{
		self.iflags |= IFLAG_TELEPORTED;
		self.csqcmodel_teleported = 1;
	}
	
	CSQCModel_InterpolateAnimation_Note(sf);
	InterpolateOrigin_Note();
	CSQCPlayer_PostUpdate();

	{ CSQCMODEL_HOOK_POSTUPDATE }

#ifdef CSQCMODEL_SUPPORT_GETTAGINFO_BEFORE_DRAW
	InterpolateOrigin_Do();
	CSQCModel_InterpolateAnimation_Do();
#endif

	// relink
	setorigin(self, self.origin);

	// set obvious render flags
#ifdef COMPAT_XON050_ENGINE
	if(self.entnum == player_localentnum || self.entnum == spectatee_status)
#else
	if(self.entnum == player_localentnum)
#endif
		self.renderflags |= RF_EXTERNALMODEL;
	else
		self.renderflags &= ~RF_EXTERNALMODEL;

	// draw it
	self.drawmask = MASK_NORMAL;
	self.predraw = CSQCModel_Draw;
}

entity CSQCModel_server2csqc(float pl)
{
	return findfloat(world, entnum, pl); // FIXME optimize this using an array
}
