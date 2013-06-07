#ifdef INTERFACE
CLASS(BorderImage) EXTENDS(Label)
	METHOD(BorderImage, configureBorderImage, void(entity, string, float, vector, string, float))
	METHOD(BorderImage, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(BorderImage, recalcPositionWithText, void(entity, string))
	ATTRIB(BorderImage, isBold, float, 1)
	METHOD(BorderImage, draw, void(entity))
	ATTRIB(BorderImage, src, string, string_null)
	ATTRIB(BorderImage, borderHeight, float, 0)
	ATTRIB(BorderImage, borderVec, vector, '0 0 0')
	ATTRIB(BorderImage, color, vector, '1 1 1')
	ATTRIB(BorderImage, closeButton, entity, NULL)
	ATTRIB(BorderImage, realFontSize_Nexposeed, vector, '0 0 0')
	ATTRIB(BorderImage, realOrigin_Nexposeed, vector, '0 0 0')
	ATTRIB(BorderImage, isNexposeeTitleBar, float, 0)
	ATTRIB(BorderImage, zoomedOutTitleBarPosition, float, 0)
	ATTRIB(BorderImage, zoomedOutTitleBar, float, 0)
	ATTRIB(BorderImage, overrideRealOrigin, vector, '0 1 0')
	ATTRIB(BorderImage, saveRelOrigin, vector, '0 0 0')
	ATTRIB(BorderImage, saveRelSize, vector, '0 0 0')
ENDCLASS(BorderImage)
#endif

#ifdef IMPLEMENTATION
void BorderImage_recalcPositionWithText(entity me, string t)
{
	if(me.isNexposeeTitleBar)
	{
		vector scrs;
		scrs = eX * conwidth + eY * conheight;
		me.resizeNotify(me, me.saveRelOrigin, me.saveRelSize, boxToGlobal(me.parent.Nexposee_smallOrigin, '0 0 0', scrs), boxToGlobalSize(me.parent.Nexposee_smallSize, scrs));
		SUPER(BorderImage).recalcPositionWithText(me, t);
		me.realOrigin_y = me.realFontSize_y * me.zoomedOutTitleBarPosition;
		me.realOrigin_Nexposeed = me.realOrigin;
		me.realFontSize_Nexposeed = me.realFontSize;
		me.resizeNotify(me, me.saveRelOrigin, me.saveRelSize, boxToGlobal(me.parent.Nexposee_initialOrigin, '0 0 0', scrs), boxToGlobalSize(me.parent.Nexposee_initialSize, scrs));
	}
	SUPER(BorderImage).recalcPositionWithText(me, t);
}
void BorderImage_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.isNexposeeTitleBar = 0;
	if(me.zoomedOutTitleBar)
		if(me.parent.parent.instanceOfNexposee)
			if(me.parent.instanceOfDialog)
				if(me == me.parent.frame)
					me.isNexposeeTitleBar = 1;
	me.saveRelOrigin = relOrigin;
	me.saveRelSize = relSize;
	SUPER(BorderImage).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);
	me.borderVec_x = me.borderHeight / absSize_x;
	me.borderVec_y = me.borderHeight / absSize_y;
	me.realOrigin_y = 0.5 * (me.borderVec_y - me.realFontSize_y);
	if(me.closeButton)
	{
		// move the close button to the right place
		me.closeButton.Container_origin = '1 0 0' * (1 - me.borderVec_x);
		me.closeButton.Container_size = me.borderVec;
		me.closeButton.color = me.color;
		me.closeButton.colorC = me.color;
		me.closeButton.colorF = me.color;
	}
}
void BorderImage_configureBorderImage(entity me, string theTitle, float sz, vector theColor, string path, float theBorderHeight)
{
	me.configureLabel(me, theTitle, sz, 0.5);
	me.src = path;
	me.color = theColor;
	me.borderHeight = theBorderHeight;
}
void BorderImage_draw(entity me)
{
	if(me.src)
		draw_BorderPicture('0 0 0', me.src, '1 1 0', me.color, 1, me.borderVec);

	if(me.fontSize > 0)
	{
		if(me.recalcPos)
			me.recalcPositionWithText(me, me.text);

		if(me.isNexposeeTitleBar)
		{
			vector ro, rf, df;

			// me.parent.Nexposee_animationFactor 0 (small) or 1 (full)
			// default values are for 1
			ro = me.realOrigin;
			rf = me.realFontSize;
			df = draw_fontscale;
			me.realOrigin = ro * me.parent.Nexposee_animationFactor + me.realOrigin_Nexposeed * (1 - me.parent.Nexposee_animationFactor);
			me.realFontSize = rf * me.parent.Nexposee_animationFactor + me.realFontSize_Nexposeed * (1 - me.parent.Nexposee_animationFactor);
			draw_fontscale = globalToBoxSize(boxToGlobalSize(df, me.realFontSize), rf);

			SUPER(BorderImage).draw(me);

			// me.Nexposee_animationState 0 (small) or 1 (full)
			// default values are for 1
			me.realOrigin = ro;
			me.realFontSize = rf;
			draw_fontscale = df;
		}
		else
			SUPER(BorderImage).draw(me);
	}
	else
	{
		SUPER(BorderImage).draw(me);
	}
}
#endif
