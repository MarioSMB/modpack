REGISTER_MUTATOR(pc, true);

bool autocvar_g_player_crush;
bool autocvar_g_player_crush_simple = true;
float autocvar_g_player_crush_damage = 200;
float autocvar_g_player_crush_headheight = 0.9;
float autocvar_g_player_crush_bounce = 300;
float autocvar_g_player_crush_bounce_jump = 600;

void pc_PlayerTouch()
{
	if(other == world)
		return;

	bool and_monster = IS_MONSTER(other);
	if(and_monster && !((get_monsterinfo(other.monsterid)).spawnflags & MON_FLAG_CRUSH))
		and_monster = false;

	if(!autocvar_g_player_crush && !and_monster)
		return;

	if(!IS_PLAYER(self))
		return;

	if(!IS_PLAYER(other) && !and_monster)
		return;

	if(self.deadflag != DEAD_NO || other.deadflag != DEAD_NO)
		return;

	if(!self.iscreature || !other.iscreature)
		return;

	if(forbidWeaponUse(self))
		return;

	if(autocvar_g_player_crush_simple && IS_PLAYER(other))
	{
		vector vdir = normalize(other.origin - self.origin);

		if(vdir_z > autocvar_g_player_crush_headheight) // adjust this to set how sharp from above players need to hit the player to crush them. 
			Damage (self, other, other, autocvar_g_player_crush_damage, DEATH_VH_CRUSH, self.origin, '0 0 0');
	}
	else
	{

		tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * (self.maxs_z + 5)), MOVE_NORMAL, self);

		if(trace_ent == other)
		{
			float mjumpheight = autocvar_g_player_crush_bounce;

			setorigin(self, self.origin + '0 0 2');

			if(self.BUTTON_JUMP)
			{
				mjumpheight = autocvar_g_player_crush_bounce_jump;
				self.flags &= ~FL_JUMPRELEASED;
			}

			self.flags &= ~FL_ONGROUND;

			self.velocity_z = mjumpheight;
			self.oldvelocity_z = self.velocity_z;

			animdecide_setaction(self, ANIMACTION_JUMP, true);

			Damage (other, self, self, autocvar_g_player_crush_damage, DEATH_VH_CRUSH, other.origin, '0 0 0');
		}
	}
}

MUTATOR_HOOKFUNCTION(pc, PlayerSpawn)
{
	self.touch = pc_PlayerTouch;
	return false;
}
