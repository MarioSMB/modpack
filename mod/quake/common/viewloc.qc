#include "viewloc.qh"

// client movement
void viewloc_PlayerPhysics(entity this)
{
	if(this.viewloc)
	{
		if(this.viewloc.goalentity == this.viewloc.enemy)
			return; // we can't side-scroll in this case

		vector old_movement = this.movement;
		this.movement_x = old_movement_y;
		if((this.viewloc.spawnflags & VIEWLOC_FREEMOVE))
			this.movement_y = old_movement_x;
		else
			this.movement_y = 0;

		vector level_start, level_end;
		level_start = this.viewloc.enemy.origin;
		level_end = this.viewloc.goalentity.origin;
		vector forward = vectoangles(normalize(level_end - level_start));
		vector backward = vectoangles(normalize(level_start - level_end));

		if((this.viewloc.spawnflags & VIEWLOC_FREEMOVE) && this.angles_y < 0)
			this.movement_y = -this.movement_y;

		if(this.viewloc.spawnflags & VIEWLOC_FREEAIM)
		{
			if(this.angles_y > 0)
				this.movement_x = -this.movement_x;
		}
		else
		{
			if(this.movement_x < 0)
				this.movement_x = -this.movement_x;

			if(this.movement_x < 0) // left
				this.angles_y = backward.y;
			if(this.movement_x > 0) // right
				this.angles_y = forward.y;
		}
	#if 0
		//if(!PHYS_INPUT_BUTTON_CROUCH(this) && !IS_DUCKED(this))
		if(!(this.viewloc.spawnflags & VIEWLOC_FREEMOVE))
		{
#ifdef SVQC
			//PHYS_INPUT_BUTTON_CROUCH(this) = (old_movement_x < 0);
			if (old_movement.x < 0)
				PHYS_INPUT_BUTTON_CROUCH(this) = true;
#elif defined(CSQC)
			if (old_movement.x < 0)
			{
				input_buttons |= BIT(4);
				this.flags |= FL_DUCKED;
			}
			//else { input_buttons &= ~16; this.flags &= ~FL_DUCKED; }
#endif
		}
	#endif
	}
}

#ifdef CSQC

void viewloc_SetTags(entity this)
{
	if(this.viewloc && wasfreed(this.viewloc))
		this.viewloc = NULL;

	if(this.viewloc.entnum != this.tag_networkviewloc)
	{
		if(this.tag_networkviewloc == 0)
			this.viewloc = NULL;
		else
			this.viewloc = findfloat(NULL, entnum, this.tag_networkviewloc);
	}
}

vector CursorToWorldCoord(vector mpos)
{
	vector wnear = cs_unproject(vec2(mpos)); // determine the world coordinate for the mouse cursor upon the near clip plane
	vector wfar = cs_unproject(vec3(mpos.x, mpos.y, 32768)); // determine the world coordinate for the mouse cursor upon the far clip plane, with an outrageously large value as a workaround for dp.
	traceline(wnear, wfar, MOVE_NOMONSTERS, NULL);
	return trace_endpos;
}

vector old_camera_angle = '0 0 0';
void viewloc_SetViewLocation()
{
	entity view = CSQCModel_server2csqc(player_localentnum - 1);
	if (!view) return;
	entity viewloc_ent = view.viewloc;
	if(viewloc_ent && !wasfreed(viewloc_ent) && viewloc_ent.enemy && viewloc_ent.goalentity)
	{
		bool have_sidescroll = (viewloc_ent.enemy != viewloc_ent.goalentity);
		vector position_a = viewloc_ent.enemy.origin;
		vector position_b = viewloc_ent.goalentity.origin;
		vector camera_angle = '0 0 0';
		vector camera_position;

		/*TODO: have the camera only move when a player moves too much from the center of the camera
		 * basically the player would move around in a small "box" in the center of the screen with out changing the camera position or angles */
		camera_position = vec_bounds_in(view.origin, position_a, position_b);

		// use camera's angle when possible
		if (!(viewloc_ent.spawnflags & VIEWLOC_CAM_NOANGLE)) {
			camera_angle = viewloc_ent.enemy.movedir;
		}

		// a tracking camera follows the player when it leaves the world box
		if ((viewloc_ent.spawnflags & VIEWLOC_CAM_TRACK) || !have_sidescroll) {
			camera_angle = aim_vec (camera_position, view.origin);
		}

		// hard snap changes the angle as soon as it crosses over the nearest 90 degree mark
		if (viewloc_ent.spawnflags & VIEWLOC_CAM_SNAP_HARD) {
			camera_angle = angle_snap_vec(aim_vec(camera_position, view.origin), 90);
		}

		// tries to avoid snapping unless it *really* needs to
		if (viewloc_ent.spawnflags & VIEWLOC_CAM_SNAP_CLOSE) {
			// like hard snap, but don't snap angles yet.
			camera_angle = aim_vec(camera_position, view.origin);

			/* if the difference between the old and new angle is 60 degrees or more, switch angles.
			 * NOTE: bug/feature: this will use non-snaped angles for one frame.
			 * doing this results in less code, faster code, and a smoother transisition between angles.
			 */
			float camera_angle_diff = max(camera_angle.y, old_camera_angle.y) - min(camera_angle.y, old_camera_angle.y);

			if (60 <= camera_angle_diff) { // use new angles
				old_camera_angle.y = angle_snap_f(camera_angle.y, 90);
			} else { // use old angles
				camera_angle.y = old_camera_angle.y;
			}
		}

		//unlocking this allows the camera to look up and down. this also allows a top-down view.
		if (!(viewloc_ent.spawnflags & VIEWLOC_CAM_SNAP_UNLOCK)) {
			camera_angle.x = 0;
			camera_angle.z = 0;
		}

#if 0
		LOG_TRACE(vtos(camera_position));
		LOG_TRACE(vtos(old_camera_angle));
		LOG_TRACE(vtos(camera_angle));
#endif

		//freeze_org = getpropertyvec(VF_ORIGIN);
		//freeze_ang = getpropertyvec(VF_ANGLES);
		setproperty(VF_ORIGIN, camera_position);
		setproperty(VF_ANGLES, camera_angle);

		if (have_sidescroll) {
			vector view_angle = view.angles;
			if (!(viewloc_ent.spawnflags & VIEWLOC_FREEAIM)) {
				vector avatar_facing_dir;
				// get the player's forward-facing direction, based on positions a and b
				if (0 == input_movevalues.y) {
					avatar_facing_dir = view_angle; // default to the previous values
				} else if (0 > input_movevalues.y) { // left is forward
					avatar_facing_dir = vectoangles(normalize(vec_to_max(position_b, position_a) - vec_to_min(position_b, position_a)));
				} else { // right is forward
					avatar_facing_dir = vectoangles(normalize(vec_to_min(position_b, position_a) - vec_to_max(position_b, position_a)));
				}
				view_angle.y = avatar_facing_dir.y; // snap avatar to look on along the correct axis

				// if (0 == input_movevalues.x) look straight ahead
				if (!(viewloc_ent.spawnflags & VIEWLOC_FREEMOVE)) {
					if (0 > input_movevalues.x) { // look up
						view_angle.x = 50;
					} else if (0 < input_movevalues.x) { // look down
						view_angle.x = -50;
					}
				}
			} else {
				vector mpos = CursorToWorldCoord(viewloc_mousepos);
				mpos.x = view.origin.x; // replace the cursor's x position with the player's
				view_angle = aim_vec(view.origin + view.view_ofs, mpos); // get new angles
			}
			view.angles_y = view_angle.y;
			setproperty(VF_CL_VIEWANGLES, view_angle);
		}
	}
}

STATIC_INIT_LATE(viewloc_cursor)
{
	// fix the mouse position on init so it isn't in the corner
	viewloc_mousepos = '0.5 0 0' * autocvar_vid_conwidth + '0 0.5 0' * autocvar_vid_conheight;
}

#endif
