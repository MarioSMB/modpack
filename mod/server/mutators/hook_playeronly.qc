//FEATURE: Random Spawns mutator, spawn at random locations throughout the map

AUTOCVAR(g_grappling_hook_playeronly, bool, false, "Make grappling hooks break if the target isn't a player");
AUTOCVAR(g_grappling_hook_playeronly_speed, float, 1, "Multiplies pull speed by this amount if hooking a player");
AUTOCVAR(g_grappling_hook_playeronly_range, float, 0, "If set, breaks hook when it's this close to the hooked player");
REGISTER_MUTATOR(hook_playeronly, true);

MUTATOR_HOOKFUNCTION(hook_playeronly, GrappleHookThink)
{
	if(!autocvar_g_grappling_hook_playeronly)
		return;

	entity myhook = M_ARGV(0, entity);
	entity pull_entity = M_ARGV(2, entity);

	if(myhook.state != 1)
		return;

	if(!IS_PLAYER(myhook.aiment) || (autocvar_g_grappling_hook_playeronly_range > 0 && vdist(pull_entity.origin - myhook.aiment.origin, <, autocvar_g_grappling_hook_playeronly_range)))
	{
		// we can't remove the hook immediately thanks to no return call
		// but we can disable it for a frame and remove it afterwards!
		myhook.state = 0;
		setthink(myhook, RemoveHook);
		myhook.nextthink = time;
		return;
	}

	M_ARGV(3, float) *= autocvar_g_grappling_hook_playeronly_speed;
}
