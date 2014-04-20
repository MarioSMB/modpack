#ifdef INTERFACE
CLASS(XonoticMapInfoDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticMapInfoDialog, fill, void(entity))
	METHOD(XonoticMapInfoDialog, loadMapInfo, void(entity, float, entity))
	ATTRIB(XonoticMapInfoDialog, title, string, _("Map Information"))
	ATTRIB(XonoticMapInfoDialog, color, vector, SKINCOLOR_DIALOG_MAPINFO)
	ATTRIB(XonoticMapInfoDialog, intendedWidth, float, 1.0)
	ATTRIB(XonoticMapInfoDialog, rows, float, 12)
	ATTRIB(XonoticMapInfoDialog, columns, float, 10)

	ATTRIB(XonoticMapInfoDialog, previewImage, entity, NULL)
	ATTRIB(XonoticMapInfoDialog, titleLabel, entity, NULL)
	ATTRIB(XonoticMapInfoDialog, authorLabel, entity, NULL)
	ATTRIB(XonoticMapInfoDialog, descriptionLabel, entity, NULL)
	ATTRIB(XonoticMapInfoDialog, featuresLabel, entity, NULL)

	ATTRIBARRAY(XonoticMapInfoDialog, typeLabels, entity, 24)

	ATTRIB(XonoticMapInfoDialog, currentMapIndex, float, 0)
	ATTRIB(XonoticMapInfoDialog, currentMapBSPName, string, string_null)
	ATTRIB(XonoticMapInfoDialog, currentMapTitle, string, string_null)
	ATTRIB(XonoticMapInfoDialog, currentMapAuthor, string, string_null)
	ATTRIB(XonoticMapInfoDialog, currentMapDescription, string, string_null)
	ATTRIB(XonoticMapInfoDialog, currentMapPreviewImage, string, string_null)
	ATTRIB(XonoticMapInfoDialog, currentMapFeaturesText, string, string_null)
ENDCLASS(XonoticMapInfoDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticMapInfoDialog_loadMapInfo(entity me, float i, entity mlb)
{
	me.currentMapIndex = i;
	me.startButton.onClickEntity = mlb;
	MapInfo_Get_ByID(i);

	if(me.currentMapBSPName)
	{
		strunzone(me.currentMapBSPName);
		strunzone(me.currentMapTitle);
		strunzone(me.currentMapAuthor);
		strunzone(me.currentMapDescription);
		strunzone(me.currentMapPreviewImage);
		strunzone(me.currentMapFeaturesText);
	}
	me.currentMapBSPName = strzone(MapInfo_Map_bspname);
	me.currentMapTitle = strzone(strdecolorize(MapInfo_Map_title));
	me.currentMapAuthor = strzone(strdecolorize(MapInfo_Map_author));
	me.currentMapDescription = strzone(MapInfo_Map_description);
	me.currentMapFeaturesText = strzone((MapInfo_Map_supportedFeatures & MAPINFO_FEATURE_WEAPONS) ? _("Full item placement") : _("MinstaGib only"));
	me.currentMapPreviewImage = strzone(strcat("/maps/", MapInfo_Map_bspname));

	me.frame.setText(me.frame, me.currentMapBSPName);
	me.titleLabel.setText(me.titleLabel, me.currentMapTitle);
	me.authorLabel.setText(me.authorLabel, me.currentMapAuthor);
	me.descriptionLabel.setText(me.descriptionLabel, me.currentMapDescription);
	me.featuresLabel.setText(me.featuresLabel, me.currentMapFeaturesText);
	if(draw_PictureSize(me.currentMapPreviewImage) == '0 0 0')
		me.previewImage.src = "nopreview_map";
	else
		me.previewImage.src = me.currentMapPreviewImage;

	for(i = 0; i < GameType_GetCount(); ++i)
	{
		entity e;
		e = me.(typeLabels[i]);
		e.disabled = !(MapInfo_Map_supportedGametypes & GameType_GetID(i));
	}

	MapInfo_ClearTemps();
}
void XonoticMapInfoDialog_fill(entity me)
{
	entity e;
	float w, wgt, i, n;
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, me.rows - 2, 3, e = makeXonoticImage(string_null, 4.0/3.0));
		me.previewImage = e;
	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
	w = me.columns - me.currentColumn;
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Title:")));
		me.TD(me, 1, w-1, e = makeXonoticTextLabel(0, ""));
			e.colorL = SKINCOLOR_MAPLIST_TITLE;
			e.allowCut = 1;
			me.titleLabel = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Author:")));
		me.TD(me, 1, w-1, e = makeXonoticTextLabel(0, ""));
			e.colorL = SKINCOLOR_MAPLIST_AUTHOR;
			e.allowCut = 1;
			me.authorLabel = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Features:")));
		me.TD(me, 1, w-1, e = makeXonoticTextLabel(0, ""));
			e.allowCut = 1;
			me.featuresLabel = e;
	me.TR(me);
		me.TD(me, 1, w, e = makeXonoticTextLabel(0, _("Game types:")));

	n = ceil(GameType_GetCount() / (me.rows - 6));
	wgt = (w - 0.2) / n;
	for(i = 0; i < GameType_GetCount(); ++i)
	{
		if(mod(i, n) == 0)
		{
			me.TR(me);
			me.TDempty(me, 0.2);
		}
		me.TD(me, 1, wgt, e = makeXonoticTextLabel(0, MapInfo_Type_ToText(GameType_GetID(i))));
			me.(typeLabels[i]) = e;
	}

	me.gotoRC(me, me.rows - 2, 0);
		me.TD(me, 1, me.columns, e = makeXonoticTextLabel(0.5, ""));
			e.allowCut = 1;
			me.descriptionLabel = e;

	me.gotoRC(me, me.rows - 1, 0);
		me.TDempty(me, 0.5);

		me.TD(me, 1, me.columns - 5.5, e = makeXonoticButton(_("Close"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
		me.TD(me, 1, me.columns - 5.5, me.startButton = e = makeXonoticButton(ZCTX(_("MAP^Play")), '0 0 0'));
			me.startButton.onClick = MapList_LoadMap;
			me.startButton.onClickEntity = NULL; // filled later
}
#endif
