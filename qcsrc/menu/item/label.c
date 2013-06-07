#ifdef INTERFACE
CLASS(Label) EXTENDS(Item)
	METHOD(Label, configureLabel, void(entity, string, float, float))
	METHOD(Label, draw, void(entity))
	METHOD(Label, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Label, setText, void(entity, string))
	METHOD(Label, toString, string(entity))
	METHOD(Label, recalcPositionWithText, void(entity, string))
	ATTRIB(Label, isBold, float, 0)
	ATTRIB(Label, text, string, string_null)
	ATTRIB(Label, currentText, string, string_null)
	ATTRIB(Label, fontSize, float, 8)
	ATTRIB(Label, align, float, 0.5)
	ATTRIB(Label, allowCut, float, 0)
	ATTRIB(Label, allowColors, float, 0)
	ATTRIB(Label, keepspaceLeft, float, 0) // for use by subclasses (radiobuttons for example)
	ATTRIB(Label, keepspaceRight, float, 0)
	ATTRIB(Label, marginLeft, float, 0) // alternate way to specify keepspace* (in characters from the font)
	ATTRIB(Label, marginRight, float, 0)
	ATTRIB(Label, realFontSize, vector, '0 0 0')
	ATTRIB(Label, realOrigin, vector, '0 0 0')
	ATTRIB(Label, alpha, float, 0.7)
	ATTRIB(Label, colorL, vector, '1 1 1')
	ATTRIB(Label, disabled, float, 0)
	ATTRIB(Label, disabledAlpha, float, 0.3)
	ATTRIB(Label, textEntity, entity, NULL)
	ATTRIB(Label, allowWrap, float, 0)
	ATTRIB(Label, recalcPos, float, 0)
	ATTRIB(Label, condenseFactor, float, 1)
	ATTRIB(Label, overrideRealOrigin, vector, '0 0 0')
	ATTRIB(Label, overrideCondenseFactor, float, 0)
ENDCLASS(Label)
#endif

#ifdef IMPLEMENTATION
string Label_toString(entity me)
{
	return me.text;
}
void Label_setText(entity me, string txt)
{
	me.text = txt;
	if(txt != me.currentText)
	{
		if(me.currentText)
			strunzone(me.currentText);
		me.currentText = strzone(txt);
		me.recalcPos = 1;
	}
}
void Label_recalcPositionWithText(entity me, string t)
{
	float spaceAvail;
	spaceAvail = 1 - me.keepspaceLeft - me.keepspaceRight;

	if(me.isBold)
		draw_beginBoldFont();

	float spaceUsed;
	spaceUsed = draw_TextWidth(t, me.allowColors, me.realFontSize);

	if(spaceUsed <= spaceAvail)
	{
		if(!me.overrideRealOrigin_x)
			me.realOrigin_x = me.align * (spaceAvail - spaceUsed) + me.keepspaceLeft;
		if(!me.overrideCondenseFactor)
			me.condenseFactor = 1;
	}
	else if(me.allowCut || me.allowWrap)
	{
		if(!me.overrideRealOrigin_x)
			me.realOrigin_x = me.keepspaceLeft;
		if(!me.overrideCondenseFactor)
			me.condenseFactor = 1;
	}
	else
	{
		if(!me.overrideRealOrigin_x)
			me.realOrigin_x = me.keepspaceLeft;
		if(!me.overrideCondenseFactor)
			me.condenseFactor = spaceAvail / spaceUsed;
		dprint(sprintf(_("NOTE: label text %s too wide for label, condensed by factor %f\n"), t, me.condenseFactor));
	}

	if(!me.overrideRealOrigin_y)
	{
		float lines;
		vector dfs;
		vector fs;

		// set up variables to draw in condensed size, but use hinting for original size
		fs = me.realFontSize;
		fs_x *= me.condenseFactor;

		dfs = draw_fontscale;
		draw_fontscale_x *= me.condenseFactor;

		if(me.allowCut) // FIXME allowCut incompatible with align != 0
			lines = 1;
		else if(me.allowWrap) // FIXME allowWrap incompatible with align != 0
		{
			getWrappedLine_remaining = me.text;
			lines = 0;
			while(getWrappedLine_remaining)
			{
				if (me.allowColors)
					getWrappedLine((1 - me.keepspaceLeft - me.keepspaceRight), fs, draw_TextWidth_WithColors);
				else
					getWrappedLine((1 - me.keepspaceLeft - me.keepspaceRight), fs, draw_TextWidth_WithoutColors);
				++lines;
			}
		}
		else
			lines = 1;

		draw_fontscale = dfs;

		me.realOrigin_y = 0.5 * (1 - lines * me.realFontSize_y);
	}

	if(me.isBold)
		draw_endBoldFont();

	me.recalcPos = 0;
}
void Label_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(Label).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	// absSize_y is height of label
	me.realFontSize_y = me.fontSize / absSize_y;
	me.realFontSize_x = me.fontSize / absSize_x;
	if(me.marginLeft)
		me.keepspaceLeft = me.marginLeft * me.realFontSize_x;
	if(me.marginRight)
		me.keepspaceRight = me.marginRight * me.realFontSize_x;

	me.recalcPos = 1;
}
void Label_configureLabel(entity me, string txt, float sz, float algn)
{
	me.fontSize = sz;
	me.align = algn;
	me.setText(me, txt);
}
void Label_draw(entity me)
{
	string t;
	vector o;
	if(me.disabled)
		draw_alpha *= me.disabledAlpha;

	if(me.textEntity)
	{
		t = me.textEntity.toString(me.textEntity);
		if(t != me.currentText)
		{
			if(me.currentText)
				strunzone(me.currentText);
			me.currentText = strzone(t);
			me.recalcPos = 1;
		}
	}
	else
		t = me.text;

	if(me.recalcPos)
		me.recalcPositionWithText(me, t);

	if(me.fontSize)
		if(t)
		{
			vector dfs;
			vector fs;

			if(me.isBold)
				draw_beginBoldFont();

			// set up variables to draw in condensed size, but use hinting for original size
			fs = me.realFontSize;
			fs_x *= me.condenseFactor;

			dfs = draw_fontscale;
			draw_fontscale_x *= me.condenseFactor;

			if(me.allowCut) // FIXME allowCut incompatible with align != 0
				draw_Text(me.realOrigin, draw_TextShortenToWidth(t, (1 - me.keepspaceLeft - me.keepspaceRight), me.allowColors, fs), fs, me.colorL, me.alpha, me.allowColors);
			else if(me.allowWrap) // FIXME allowWrap incompatible with align != 0
			{
				getWrappedLine_remaining = t;
				o = me.realOrigin;
				while(getWrappedLine_remaining)
				{
					if (me.allowColors)
						t = getWrappedLine((1 - me.keepspaceLeft - me.keepspaceRight), fs, draw_TextWidth_WithColors);
					else
						t = getWrappedLine((1 - me.keepspaceLeft - me.keepspaceRight), fs, draw_TextWidth_WithoutColors);
					draw_Text(o, t, fs, me.colorL, me.alpha, me.allowColors);
					o_y += me.realFontSize_y;
				}
			}
			else
				draw_Text(me.realOrigin, t, fs, me.colorL, me.alpha, me.allowColors);

			draw_fontscale = dfs;

			if(me.isBold)
				draw_endBoldFont();
		}

	SUPER(Label).draw(me);
}
#endif
