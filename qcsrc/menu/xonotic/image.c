#ifdef INTERFACE
CLASS(XonoticImage) EXTENDS(Image)
	METHOD(XonoticImage, configureXonoticImage, void(entity, string, float))
ENDCLASS(XonoticImage)
entity makeXonoticImage(string theImage, float theAspect);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticImage(string theImage, float theAspect)
{
	entity me;
	me = spawnXonoticImage();
	me.configureXonoticImage(me, theImage, theAspect);
	return me;
}
void XonoticImage_configureXonoticImage(entity me, string theImage, float theAspect)
{
	me.configureImage(me, theImage);
	me.forcedAspect = theAspect;
}
#endif
