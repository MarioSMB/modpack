#ifdef INTERFACE
void RadioButton_Click(entity me, entity other);
CLASS(RadioButton) EXTENDS(CheckBox)
	METHOD(RadioButton, configureRadioButton, void(entity, string, float, string, float, float))
	ATTRIB(RadioButton, checked, float, 0)
	ATTRIB(RadioButton, group, float, 0)
	ATTRIB(RadioButton, allowDeselect, float, 0)
	ATTRIB(RadioButton, onClick, void(entity, entity), RadioButton_Click)
ENDCLASS(RadioButton)
#endif

#ifdef IMPLEMENTATION
void RadioButton_configureRadioButton(entity me, string txt, float sz, string gfx, float theGroup, float doAllowDeselect)
{
	me.configureCheckBox(me, txt, sz, gfx);
	me.align = 0;
	me.group = theGroup;
	me.allowDeselect = doAllowDeselect;
}
void RadioButton_Click(entity me, entity other)
{
	if(me.checked)
	{
		if(me.allowDeselect)
			me.setChecked(me, 0);
	}
	else
	{
		entity e;
		for(e = me.parent.firstChild; e; e = e.nextSibling)
			if(e != me)
				if(e.group == me.group)
					e.setChecked(e, 0);
		me.setChecked(me, 1);
	}
}
#endif
