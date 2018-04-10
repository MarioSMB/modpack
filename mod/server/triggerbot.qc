AUTOCVAR(g_triggerbot, bool, false, _("You are a terrible person"));

REGISTER_MUTATOR(triggerbot, true); // always enable, allow toggling midmatch

MUTATOR_HOOKFUNCTION(triggerbot, PlayerPreThink)
{
	if(!autocvar_g_triggerbot || autocvar_g_antilag != 3) // we can't really handle this without client side aiming
		return;

	entity player = M_ARGV(0, entity);
	if(!IS_PLAYER(player) || player.vehicle)
		return;
	if(!(CS(player).cursor_trace_ent && CS(player).cursor_trace_ent != player && IS_PLAYER(CS(player).cursor_trace_ent) && CS(player).cursor_trace_ent.takedamage))
		return;

	PHYS_INPUT_BUTTON_ATCK(player) = true;
}
