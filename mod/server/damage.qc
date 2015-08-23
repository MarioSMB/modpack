MUTATOR_HOOKFUNCTION(mutator_mod, PlayHitsound)
{
	return (frag_victim.classname == "func_assault_destructible"
		|| (frag_victim.classname == "onslaught_generator" && !frag_victim.isshielded)
		|| (frag_victim.classname == "onslaught_controlpoint_icon" && !frag_victim.owner.isshielded));
}
