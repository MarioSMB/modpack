//FEATURE: Option to change all or individual player's size

REGISTER_MUTATOR(player_size, true);

AUTOCVAR(g_player_size, float, 1, "");

const vector _PL_VIEW_OFS_CONST = '0 0 35';
const vector _PL_CROUCH_VIEW_OFS_CONST = '0 0 20';

.float player_scale;
.float player_scale_override;

MUTATOR_HOOKFUNCTION(player_size, PlayerPhysics_PostUpdateStats)
{
	entity player = M_ARGV(0, entity);
	if(player.player_scale == 1 || !player.player_scale)
		return;

	STAT(PL_MIN, player) = PL_MIN_CONST * player.scale;
	STAT(PL_MAX, player) = PL_MAX_CONST * player.scale;
	STAT(PL_VIEW_OFS, player) = _PL_VIEW_OFS_CONST * player.scale;
	STAT(PL_CROUCH_MIN, player) = PL_CROUCH_MIN_CONST * player.scale;
	STAT(PL_CROUCH_MAX, player) = PL_CROUCH_MAX_CONST * player.scale;
	STAT(PL_CROUCH_VIEW_OFS, player) = _PL_CROUCH_VIEW_OFS_CONST * player.scale;
}

MUTATOR_HOOKFUNCTION(player_size, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);
	if((!autocvar_g_player_size || autocvar_g_player_size == 1) && !player.player_scale_override)
		return;

	player.player_scale = ((player.player_scale_override) ? player.player_scale_override : autocvar_g_player_size);
	if(player.player_scale < 0)
		player.player_scale = (random() * (player.player_scale * -1));
	player.scale = player.player_scale;

	// TODO: setting size here causes havoc (you get stuck in the floor!), moving them up is an option but may break certain maps
	STAT(PL_MIN, player) = PL_MIN_CONST * player.scale;
	STAT(PL_MAX, player) = PL_MAX_CONST * player.scale;
	STAT(PL_VIEW_OFS, player) = _PL_VIEW_OFS_CONST * player.scale;
	STAT(PL_CROUCH_MIN, player) = PL_CROUCH_MIN_CONST * player.scale;
	STAT(PL_CROUCH_MAX, player) = PL_CROUCH_MAX_CONST * player.scale;
	STAT(PL_CROUCH_VIEW_OFS, player) = _PL_CROUCH_VIEW_OFS_CONST * player.scale;

	// attempt to get new height before adjusting hitbox
	vector newsize = -STAT(PL_MIN, player);
	float oldz = -PL_MIN_CONST.z;
	float newz = newsize.z;
	float height_diff = (newz - oldz);

	if(player.scale > 1) // below 1 doesn't need adjustment, the player will just be above the ground a bit
		setorigin(player, player.origin + '0 0 1' * (height_diff));

	setsize(player, STAT(PL_MIN, player), STAT(PL_MAX, player));
	player.view_ofs = STAT(PL_VIEW_OFS, player);
}
