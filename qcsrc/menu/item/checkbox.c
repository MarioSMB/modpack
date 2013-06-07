#ifdef INTERFACE
void CheckBox_Click(entity me, entity other);
CLASS(CheckBox) EXTENDS(Button)
	METHOD(CheckBox, configureCheckBox, void(entity, string, float, string))
	METHOD(CheckBox, draw, void(entity))
	METHOD(CheckBox, toString, string(entity))
	METHOD(CheckBox, setChecked, void(entity, float))
	ATTRIB(CheckBox, useDownAsChecked, float, 0)
	ATTRIB(CheckBox, checked, float, 0)
	ATTRIB(CheckBox, onClick, void(entity, entity), CheckBox_Click)
	ATTRIB(CheckBox, srcMulti, float, 0)
	ATTRIB(CheckBox, disabled, float, 0)
ENDCLASS(CheckBox)
#endif

#ifdef IMPLEMENTATION
void CheckBox_setChecked(entity me, float val)
{
	me.checked = val;
}
void CheckBox_Click(entity me, entity other)
{
	me.setChecked(me, !me.checked);
}
string CheckBox_toString(entity me)
{
	return strcat(SUPER(CheckBox).toString(me), ", ", me.checked ? "checked" : "unchecked");
}
void CheckBox_configureCheckBox(entity me, string txt, float sz, string gfx)
{
	me.configureButton(me, txt, sz, gfx);
	me.align = 0;
}
void CheckBox_draw(entity me)
{
	float s;
	s = me.pressed;
	if(me.useDownAsChecked)
	{
		me.srcSuffix = string_null;
		me.forcePressed = me.checked;
	}
	else
		me.srcSuffix = (me.checked ? "1" : "0");
	me.pressed = s;
	SUPER(CheckBox).draw(me);
}
#endif
