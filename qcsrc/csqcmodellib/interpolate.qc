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

.vector iorigin1, iorigin2;
.vector ivelocity1, ivelocity2;
.vector iforward1, iforward2;
.vector iup1, iup2;
.vector ivforward1, ivforward2;
.vector ivup1, ivup2;
.float itime1, itime2;
void InterpolateOrigin_Reset()
{
	self.iflags &= ~IFLAG_INTERNALMASK;
	self.itime1 = self.itime2 = 0;
}
void InterpolateOrigin_Note()
{
	float dt;
	float f0;

	dt = time - self.itime2;

	f0 = self.iflags;
	if(self.iflags & IFLAG_PREVALID)
		self.iflags |= IFLAG_VALID;
	else
		self.iflags |= IFLAG_PREVALID;

	if(self.iflags & IFLAG_ORIGIN)
	{
		self.iorigin1 = self.iorigin2;
		self.iorigin2 = self.origin;
	}

	if(self.iflags & IFLAG_AUTOANGLES)
		if(self.iorigin2 != self.iorigin1)
			self.angles = vectoangles(self.iorigin2 - self.iorigin1);

	if(self.iflags & IFLAG_AUTOVELOCITY)
		if(self.itime2 != self.itime1)
			self.velocity = (self.iorigin2 - self.iorigin1) * (1.0 / (self.itime2 - self.itime1));

	if(self.iflags & IFLAG_ANGLES)
	{
		fixedmakevectors(self.angles);
		if(f0 & IFLAG_VALID)
		{
			self.iforward1 = self.iforward2;
			self.iup1 = self.iup2;
		}
		else
		{
			self.iforward1 = v_forward;
			self.iup1 = v_up;
		}
		self.iforward2 = v_forward;
		self.iup2 = v_up;
	}

	if(self.iflags & IFLAG_V_ANGLE)
	{
		fixedmakevectors(self.v_angle);
		if(f0 & IFLAG_VALID)
		{
			self.ivforward1 = self.ivforward2;
			self.ivup1 = self.ivup2;
		}
		else
		{
			self.ivforward1 = v_forward;
			self.ivup1 = v_up;
		}
		self.ivforward2 = v_forward;
		self.ivup2 = v_up;
	}
	else if(self.iflags & IFLAG_V_ANGLE_X)
	{
		self.ivforward1_x = self.ivforward2_x;
		self.ivforward2_x = self.v_angle_x;
	}

	if(self.iflags & IFLAG_VELOCITY)
	{
		self.ivelocity1 = self.ivelocity2;
		self.ivelocity2 = self.velocity;
	}

	if(self.iflags & IFLAG_TELEPORTED)
	{
		self.iflags &= ~IFLAG_TELEPORTED;
		self.itime1 = self.itime2 = time; // don't lerp
	}
	else if(vlen(self.iorigin2 - self.iorigin1) > 1000)
	{
		self.itime1 = self.itime2 = time; // don't lerp
	}
	else if((self.iflags & IFLAG_VELOCITY) && (vlen(self.ivelocity2 - self.ivelocity1) > 1000))
	{
		self.itime1 = self.itime2 = time; // don't lerp
	}
	else if(dt >= 0.2)
	{
		self.itime1 = self.itime2 = time;
	}
	else
	{
		self.itime1 = serverprevtime;
		self.itime2 = time;
	}
}
void InterpolateOrigin_Do()
{
	vector forward, up;
	if(self.itime1 && self.itime2 && self.itime1 != self.itime2)
	{
		float f;
		f = bound(0, (time - self.itime1) / (self.itime2 - self.itime1), 1 + autocvar_cl_lerpexcess);
		if(self.iflags & IFLAG_ORIGIN)
			setorigin(self, (1 - f) * self.iorigin1 + f * self.iorigin2);
		if(self.iflags & IFLAG_ANGLES)
		{
			forward = (1 - f) * self.iforward1 + f * self.iforward2;
			up = (1 - f) * self.iup1 + f * self.iup2;
			self.angles = fixedvectoangles2(forward, up);
		}
		if(self.iflags & IFLAG_V_ANGLE)
		{
			forward = (1 - f) * self.ivforward1 + f * self.ivforward2;
			up = (1 - f) * self.ivup1 + f * self.ivup2;
			self.v_angle = fixedvectoangles2(forward, up);
		}
		else if(self.iflags & IFLAG_V_ANGLE_X)
			self.v_angle_x = (1 - f) * self.ivforward1_x + f * self.ivforward2_x;
		if(self.iflags & IFLAG_VELOCITY)
			self.velocity = (1 - f) * self.ivelocity1 + f * self.ivelocity2;
	}
}
void InterpolateOrigin_Undo()
{
	if(self.iflags & IFLAG_ORIGIN)
		setorigin(self, self.iorigin2);
	if(self.iflags & IFLAG_ANGLES)
		self.angles = fixedvectoangles2(self.iforward2, self.iup2);
	if(self.iflags & IFLAG_V_ANGLE)
		self.v_angle = fixedvectoangles2(self.ivforward2, self.ivup2);
	else if(self.iflags & IFLAG_V_ANGLE_X)
		self.v_angle_x = self.ivforward2_x;
	if(self.iflags & IFLAG_VELOCITY)
		self.velocity = self.ivelocity2;
}

