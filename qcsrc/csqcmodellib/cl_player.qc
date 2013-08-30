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

var float autocvar_cl_movement_errorcompensation = 0;

// engine stuff
#define REFDEFFLAG_TELEPORTED 1
#define REFDEFFLAG_JUMPING 2
float pmove_onground; // weird engine flag we shouldn't really use but have to for now

vector csqcplayer_origin, csqcplayer_velocity;
float csqcplayer_sequence, player_pmflags;
float csqcplayer_moveframe;
vector csqcplayer_predictionerroro;
vector csqcplayer_predictionerrorv;
float csqcplayer_predictionerrortime;
float csqcplayer_predictionerrorfactor;

vector CSQCPlayer_GetPredictionErrorO()
{
	if(time >= csqcplayer_predictionerrortime)
		return '0 0 0';
	return csqcplayer_predictionerroro * (csqcplayer_predictionerrortime - time) * csqcplayer_predictionerrorfactor;
}

vector CSQCPlayer_GetPredictionErrorV()
{
	if(time >= csqcplayer_predictionerrortime)
		return '0 0 0';
	return csqcplayer_predictionerrorv * (csqcplayer_predictionerrortime - time) * csqcplayer_predictionerrorfactor;
}

void CSQCPlayer_SetPredictionError(vector o, vector v, float onground_diff)
{
	// error too big to compensate, we LIKELY hit a teleport or a
	// jumppad, or it's a jump time disagreement that'll get fixed
	// next frame

	// FIXME we sometimes have disagreement in order of jump velocity. Do not act on them!
	/*
	// commented out as this one did not help
	if(onground_diff)
	{
		print(sprintf("ONGROUND MISMATCH: %d x=%v v=%v\n", onground_diff, o, v));
		return;
	}
	*/
	if(vlen(o) > 32 || vlen(v) > 192)
	{
		//print(sprintf("TOO BIG: x=%v v=%v\n", o, v));
		return;
	}

	if(!autocvar_cl_movement_errorcompensation)
	{
		csqcplayer_predictionerrorfactor = 0;
		return;
	}

	csqcplayer_predictionerroro = CSQCPlayer_GetPredictionErrorO() + o;
	csqcplayer_predictionerrorv = CSQCPlayer_GetPredictionErrorV() + v;
	csqcplayer_predictionerrorfactor = autocvar_cl_movement_errorcompensation / ticrate;
	csqcplayer_predictionerrortime = time + 1.0 / csqcplayer_predictionerrorfactor;
}

void CSQCPlayer_Unpredict()
{
	if(csqcplayer_status == CSQCPLAYERSTATUS_UNPREDICTED)
		return;
	if(csqcplayer_status != CSQCPLAYERSTATUS_PREDICTED)
		error("Cannot unpredict in current status");
	self.origin = csqcplayer_origin;
	self.velocity = csqcplayer_velocity;
	csqcplayer_moveframe = csqcplayer_sequence+1; //+1 because the recieved frame has the move already done (server side)
	self.pmove_flags = player_pmflags;
}

void CSQCPlayer_SetMinsMaxs()
{
	if(self.pmove_flags & PMF_DUCKED)
	{
		self.mins = PL_CROUCH_MIN;
		self.maxs = PL_CROUCH_MAX;
		self.view_ofs = PL_CROUCH_VIEW_OFS;
	}
	else
	{
		self.mins = PL_MIN;
		self.maxs = PL_MAX;
		self.view_ofs = PL_VIEW_OFS;
	}
}

void CSQCPlayer_SavePrediction()
{
	player_pmflags = self.pmove_flags;
	csqcplayer_origin = self.origin;
	csqcplayer_velocity = self.velocity;
	csqcplayer_sequence = servercommandframe;
	csqcplayer_status = CSQCPLAYERSTATUS_PREDICTED;
}

void CSQCPlayer_PredictTo(float endframe, float apply_error)
{
	CSQCPlayer_Unpredict();
	if(apply_error)
	{
		self.origin += CSQCPlayer_GetPredictionErrorO();
		self.velocity += CSQCPlayer_GetPredictionErrorV();
	}
	CSQCPlayer_SetMinsMaxs();

	csqcplayer_status = CSQCPLAYERSTATUS_PREDICTED;

#if 0
	// we don't need this
	// darkplaces makes servercommandframe == 0 in these cases anyway
	if (getstatf(STAT_HEALTH) <= 0)
	{
		csqcplayer_moveframe = clientcommandframe;
		getinputstate(csqcplayer_moveframe-1);
		print("the Weird code path got hit\n");
		return;
	}
#endif

	if(csqcplayer_moveframe >= endframe)
	{
		getinputstate(csqcplayer_moveframe - 1);
	}
	else
	{
		do
		{
			if (!getinputstate(csqcplayer_moveframe))
				break;
			runstandardplayerphysics(self);
			CSQCPlayer_SetMinsMaxs();
			csqcplayer_moveframe++;
		}
		while(csqcplayer_moveframe < endframe);
	}

	//add in anything that was applied after (for low packet rate protocols)
	input_angles = view_angles;
}

float CSQCPlayer_IsLocalPlayer()
{
	return (self == csqcplayer);
}

void(entity e, float fl) V_CalcRefdef = #640; // DP_CSQC_V_CALCREFDEF

void CSQCPlayer_SetCamera()
{
	vector v0;
	v0 = pmove_vel; // TRICK: pmove_vel is set by the engine when we get here. No need to network velocity

	if(csqcplayer)
	{
		entity oldself;
		oldself = self;
		self = csqcplayer;

#ifdef COMPAT_XON050_ENGINE
		if(servercommandframe == 0 || clientcommandframe == 0 || !(checkextension("DP_CSQC_V_CALCREFDEF") || checkextension("DP_CSQC_V_CALCREFDEF_WIP1")))
#else
		if(servercommandframe == 0 || clientcommandframe == 0)
#endif
		{
			InterpolateOrigin_Do();
			self.view_ofs = '0 0 1' * getstati(STAT_VIEWHEIGHT);

			// get crouch state from the server
			if(getstati(STAT_VIEWHEIGHT) == PL_VIEW_OFS_z)
				self.pmove_flags &= ~PMF_DUCKED;
			else if(getstati(STAT_VIEWHEIGHT) == PL_CROUCH_VIEW_OFS_z)
				self.pmove_flags |= PMF_DUCKED;

			// get onground state from the server
			if(pmove_onground)
				self.pmove_flags |= PMF_ONGROUND;
			else
				self.pmove_flags &= ~PMF_ONGROUND;

			CSQCPlayer_SetMinsMaxs();

			// override it back just in case
			self.view_ofs = '0 0 1' * getstati(STAT_VIEWHEIGHT);

			// set velocity
			self.velocity = v0;
		}
		else
		{
			float flg = self.iflags;
			self.iflags &= ~(IFLAG_ORIGIN | IFLAG_ANGLES);
			InterpolateOrigin_Do();
			self.iflags = flg;

			if(csqcplayer_status == CSQCPLAYERSTATUS_FROMSERVER)
			{
				vector o, v;
				o = self.origin;
				v = v0;
				csqcplayer_status = CSQCPLAYERSTATUS_PREDICTED;
				CSQCPlayer_PredictTo(servercommandframe + 1, FALSE);
				CSQCPlayer_SetPredictionError(self.origin - o, self.velocity - v, pmove_onground - !!(self.pmove_flags & PMF_ONGROUND));
				self.origin = o;
				self.velocity = v;

				// get crouch state from the server
				if(getstati(STAT_VIEWHEIGHT) == PL_VIEW_OFS_z)
					self.pmove_flags &= ~PMF_DUCKED;
				else if(getstati(STAT_VIEWHEIGHT) == PL_CROUCH_VIEW_OFS_z)
					self.pmove_flags |= PMF_DUCKED;

				// get onground state from the server
				if(pmove_onground)
					self.pmove_flags |= PMF_ONGROUND;
				else
					self.pmove_flags &= ~PMF_ONGROUND;

				CSQCPlayer_SavePrediction();
			}
			CSQCPlayer_PredictTo(clientcommandframe + 1, TRUE);

#ifdef CSQCMODEL_SERVERSIDE_CROUCH
			// get crouch state from the server (LAG)
			if(getstati(STAT_VIEWHEIGHT) == PL_VIEW_OFS_z)
				self.pmove_flags &= ~PMF_DUCKED;
			else if(getstati(STAT_VIEWHEIGHT) == PL_CROUCH_VIEW_OFS_z)
				self.pmove_flags |= PMF_DUCKED;
#endif

			CSQCPlayer_SetMinsMaxs();

			self.angles_y = input_angles_y;
		}

		// relink
		setorigin(self, self.origin);

		self = oldself;
	}

	entity view;
#ifdef COMPAT_XON050_ENGINE
	view = CSQCModel_server2csqc((spectatee_status > 0) ? spectatee_status : player_localentnum);
#else
	view = CSQCModel_server2csqc(player_localentnum);
#endif

	if(view && view != csqcplayer)
	{
		entity oldself = self;
		self = view;
		InterpolateOrigin_Do();
		self.view_ofs = '0 0 1' * getstati(STAT_VIEWHEIGHT);
		self = oldself;
	}

#ifdef COMPAT_XON050_ENGINE
	if(view && !(checkextension("DP_CSQC_V_CALCREFDEF") || checkextension("DP_CSQC_V_CALCREFDEF_WIP1")))
	{
		// legacy code, not totally correct, but good enough for not having V_CalcRefdef
		setproperty(VF_ORIGIN, view.origin + '0 0 1' * getstati(STAT_VIEWHEIGHT));
		setproperty(VF_ANGLES, view_angles);
	}
	else
#endif
	if(view)
	{
		var float refdefflags = 0;

		if(view.csqcmodel_teleported)
			refdefflags |= REFDEFFLAG_TELEPORTED;

		if(input_buttons & 4)
			refdefflags |= REFDEFFLAG_JUMPING;

		// note: these two only work in WIP2, but are harmless in WIP1
		if(getstati(STAT_HEALTH) <= 0)
			refdefflags |= REFDEFFLAG_DEAD;

		if(intermission)
			refdefflags |= REFDEFFLAG_INTERMISSION;

		V_CalcRefdef(view, refdefflags);
	}
	else
	{
		// FIXME by CSQC spec we have to do this:
		// but it breaks chase cam
		/*
		setproperty(VF_ORIGIN, pmove_org + '0 0 1' * getstati(STAT_VIEWHEIGHT));
		setproperty(VF_ANGLES, view_angles);
		*/
	}

	{ CSQCPLAYER_HOOK_POSTCAMERASETUP }
}

void CSQCPlayer_Remove()
{
	csqcplayer = world;
	cvar_settemp("cl_movement_replay", "1");
}

float CSQCPlayer_PreUpdate()
{
	if(self != csqcplayer)
		return 0;
	if(csqcplayer_status != CSQCPLAYERSTATUS_FROMSERVER)
		CSQCPlayer_Unpredict();
	return 1;
}

float CSQCPlayer_PostUpdate()
{
	if(self.entnum != player_localnum + 1)
		return 0;
	csqcplayer = self;
	csqcplayer_status = CSQCPLAYERSTATUS_FROMSERVER;
	cvar_settemp("cl_movement_replay", "0");
	self.entremove = CSQCPlayer_Remove;
	return 1;
}
