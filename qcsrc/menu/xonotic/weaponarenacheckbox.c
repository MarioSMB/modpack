#ifdef INTERFACE
CLASS(XonoticWeaponarenaCheckBox) EXTENDS(CheckBox)
	METHOD(XonoticWeaponarenaCheckBox, configureXonoticWeaponarenaCheckBox, void(entity, string, string))
	METHOD(XonoticWeaponarenaCheckBox, setChecked, void(entity, float))
	ATTRIB(XonoticWeaponarenaCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(XonoticWeaponarenaCheckBox, image, string, SKINGFX_CHECKBOX)
	ATTRIB(XonoticWeaponarenaCheckBox, netname, string, string_null)

	METHOD(XonoticWeaponarenaCheckBox, loadCvars, void(entity))
	METHOD(XonoticWeaponarenaCheckBox, saveCvars, void(entity))
ENDCLASS(XonoticWeaponarenaCheckBox)
entity makeXonoticWeaponarenaCheckBox(string, string);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticWeaponarenaCheckBox(string theWeapon, string theText)
{
	entity me;
	me = spawnXonoticWeaponarenaCheckBox();
	me.configureXonoticWeaponarenaCheckBox(me, theWeapon, theText);
	return me;
}
void XonoticWeaponarenaCheckBox_configureXonoticWeaponarenaCheckBox(entity me, string theWeapon, string theText)
{
	me.netname = theWeapon;
	me.checked = FALSE;
	me.loadCvars(me);
	me.configureCheckBox(me, theText, me.fontSize, me.image);
}
void XonoticWeaponarenaCheckBox_setChecked(entity me, float foo)
{
	me.checked = !me.checked;
	me.saveCvars(me);
}
void XonoticWeaponarenaCheckBox_loadCvars(entity me)
{
	float n = tokenize_console(cvar_string("menu_weaponarena"));
	float i;
	for(i=0; i<n; ++i)
	{
		if(argv(i) == me.netname)
		{
			me.checked = TRUE;
			break;
		}
	}
}

void XonoticWeaponarenaCheckBox_saveCvars(entity me)
{
	if(me.checked)
		localcmd(strcat("\nmenu_cmd addtolist menu_weaponarena ", me.netname, "\n"));
	else
		localcmd(strcat("\nmenu_cmd removefromlist menu_weaponarena ", me.netname, "\n"));
	localcmd("\ng_weaponarena \"$menu_weaponarena\"\n");
}
#endif
