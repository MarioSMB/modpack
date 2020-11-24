//FEATURE: Crushing, for all your goomba stomping needs

REGISTER_MUTATOR(pc, true);

#ifdef SVQC
AUTOCVAR(g_player_crush, bool, false, "Allow crushing players by jumping on their head");
AUTOCVAR(g_player_crush_simple, int, 1, "Use simple height checking");
AUTOCVAR(g_player_crush_damage, float, 200, "");
AUTOCVAR(g_player_crush_headheight, float, 0.9, "");
AUTOCVAR(g_player_crush_bounce, float, 300, "Bounce height in advanced trace mode");
AUTOCVAR(g_player_crush_bounce_jump, float, 600, "Bounce height while holding jump in advanced trace mode");
#endif

REGISTER_STAT(PLAYER_CRUSH, bool, autocvar_g_player_crush)
REGISTER_STAT(PLAYER_CRUSH_SIMPLE, int, autocvar_g_player_crush_simple)
REGISTER_STAT(PLAYER_CRUSH_BOUNCE, float, autocvar_g_player_crush_bounce)
REGISTER_STAT(PLAYER_CRUSH_BOUNCE_JUMP, float, autocvar_g_player_crush_bounce_jump)

void pc_PlayerTouch(entity this, entity toucher)
{
	if(toucher == NULL)
		return;

#ifdef SVQC
	bool and_monster = IS_MONSTER(toucher) && (this.monsterdef.spawnflags & MON_FLAG_CRUSH);

	if(!autocvar_g_player_crush && !and_monster)
		return;

	if(!IS_PLAYER(this))
		return;

	if(!IS_PLAYER(toucher) && !and_monster)
		return;

	if(IS_DEAD(this) || IS_DEAD(toucher))
		return;

	if(!this.iscreature || !toucher.iscreature)
		return;

	if(weaponLocked(this))
		return;
#elif defined(CSQC)
	if(STAT(PLAYER_CRUSH_SIMPLE) != -1)
		return;
	if(!IS_PLAYER(toucher))
		return;
	if(!STAT(PLAYER_CRUSH))
		return;
#endif

	if(STAT(PLAYER_CRUSH_SIMPLE, this) == 1 && IS_PLAYER(toucher))
	{
#ifdef SVQC
		vector vdir = normalize(toucher.origin - this.origin);

		if(vdir_z > autocvar_g_player_crush_headheight) // adjust this to set how sharp from above players need to hit the player to crush them. 
			Damage (this, toucher, toucher, autocvar_g_player_crush_damage, DEATH_VH_CRUSH.m_id, DMG_NOWEP, this.origin, '0 0 0');
#endif
	}
	else if(STAT(PLAYER_CRUSH_SIMPLE, this) == 0)
	{
		tracebox(this.origin, this.mins, this.maxs, this.origin - ('0 0 1' * (this.maxs_z + 5)), MOVE_NORMAL, this);

		if(trace_ent == toucher)
		{
			float mjumpheight = STAT(PLAYER_CRUSH_BOUNCE, this);

			setorigin(this, this.origin + '0 0 2');

			if(PHYS_INPUT_BUTTON_JUMP(this))
			{
				mjumpheight = STAT(PLAYER_CRUSH_BOUNCE_JUMP, this);
				SET_JUMP_HELD(this);
			}

			UNSET_ONGROUND(this);

			this.velocity_z = mjumpheight;
	#ifdef SVQC
			this.oldvelocity_z = this.velocity_z;

			animdecide_setaction(this, ANIMACTION_JUMP, true);

			Damage (toucher, this, this, autocvar_g_player_crush_damage, DEATH_VH_CRUSH.m_id, DMG_NOWEP, toucher.origin, '0 0 0');
	#endif
		}
	}
	else if(STAT(PLAYER_CRUSH_SIMPLE, this) == -1)
	{
		if(tracebox_hits_box(this.origin, this.mins, this.maxs, this.origin - ('0 0 1' * (this.maxs_z + 5)), toucher.origin + toucher.mins, toucher.origin + toucher.maxs))
		{
			float mjumpheight = STAT(PLAYER_CRUSH_BOUNCE, this);

			setorigin(this, this.origin + '0 0 2');

			if(PHYS_INPUT_BUTTON_JUMP(this))
			{
				mjumpheight = STAT(PLAYER_CRUSH_BOUNCE_JUMP, this);
				SET_JUMP_HELD(this);
			}

			UNSET_ONGROUND(this);

			this.velocity_z = mjumpheight;
	#ifdef SVQC
			this.oldvelocity_z = this.velocity_z;

			animdecide_setaction(this, ANIMACTION_JUMP, true);

			Damage (toucher, this, this, autocvar_g_player_crush_damage, DEATH_VH_CRUSH.m_id, DMG_NOWEP, toucher.origin, '0 0 0');
	#endif
		}
	}
}

#ifdef SVQC
MUTATOR_HOOKFUNCTION(pc, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	settouch(player, pc_PlayerTouch);
}
#elif defined(CSQC)
MUTATOR_HOOKFUNCTION(pc, PlayerPhysics)
{
	if(!STAT(PLAYER_CRUSH)) return;
	if(STAT(PLAYER_CRUSH_SIMPLE) != -1) return;

	entity player = M_ARGV(0, entity);
	if(gettouch(player) == pc_PlayerTouch) return; // getting is cheaper than setting

	settouch(player, pc_PlayerTouch);
}
#endif
