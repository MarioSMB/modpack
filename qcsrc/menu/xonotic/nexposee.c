#ifdef INTERFACE
CLASS(XonoticNexposee) EXTENDS(Nexposee)
	METHOD(XonoticNexposee, configureXonoticNexposee, void(entity))
	METHOD(XonoticNexposee, close, void(entity))
ENDCLASS(XonoticNexposee)
entity makeXonoticNexposee();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticNexposee()
{
	entity me;
	me = spawnXonoticNexposee();
	me.configureXonoticNexposee(me);
	return me;
}

void XonoticNexposee_configureXonoticNexposee(entity me)
{
}

void XonoticNexposee_close(entity me)
{
	m_goto(string_null); // hide
}
#endif
