REGISTER_MUTATOR(otrails, cvar("g_observer_trails"));

AUTOCVAR(g_observer_trails, bool, false, "");

MUTATOR_HOOKFUNCTION(otrails, MakePlayerObserver)
{
	self.traileffect = EFFECT_TR_NEXUIZPLASMA.m_id;
	return false;
}

MUTATOR_HOOKFUNCTION(otrails, ClientConnect)
{
	if(!IS_PLAYER(self))
		self.traileffect = EFFECT_TR_NEXUIZPLASMA.m_id;
	return false;
}

MUTATOR_HOOKFUNCTION(otrails, PutClientInServer, CBC_ORDER_LAST)
{
	if(IS_PLAYER(self) || gameover)
		self.traileffect = 0;
	return false;
}
