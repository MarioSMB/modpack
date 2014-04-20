#ifndef COMMANDBUTTON_CLOSE
# define COMMANDBUTTON_CLOSE 1
# define COMMANDBUTTON_APPLY 2
//# define COMMANDBUTTON_REVERT 4
#endif

#ifdef INTERFACE
CLASS(XonoticCommandButton) EXTENDS(XonoticButton)
	METHOD(XonoticCommandButton, configureXonoticCommandButton, void(entity, string, vector, string, float))
	ATTRIB(XonoticCommandButton, onClickCommand, string, string_null)
	ATTRIB(XonoticCommandButton, flags, float, 0)
ENDCLASS(XonoticCommandButton)
entity makeXonoticCommandButton(string theText, vector theColor, string theCommand, float closesMenu);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticCommandButton(string theText, vector theColor, string theCommand, float theFlags)
{
	entity me;
	me = spawnXonoticCommandButton();
	me.configureXonoticCommandButton(me, theText, theColor, theCommand, theFlags);
	return me;
}

void XonoticCommandButton_Click(entity me, entity other)
{
	//if(me.flags & COMMANDBUTTON_APPLY)
	//	saveAllCvars(me.parent);
	cmd("\n", me.onClickCommand, "\n");
	//if(me.flags & COMMANDBUTTON_REVERT)
	//	loadAllCvars(me.parent);
	if(me.flags & COMMANDBUTTON_CLOSE)
		m_goto(string_null);
}

void XonoticCommandButton_configureXonoticCommandButton(entity me, string theText, vector theColor, string theCommand, float theFlags)
{
	me.configureXonoticButton(me, theText, theColor);
	me.onClickCommand = theCommand;
	me.flags = theFlags;
	me.onClick = XonoticCommandButton_Click;
	me.onClickEntity = me;
}
#endif
