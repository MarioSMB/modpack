#ifdef INTERFACE
CLASS(XonoticTeamSelectDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticTeamSelectDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	METHOD(XonoticTeamSelectDialog, showNotify, void(entity))
	ATTRIB(XonoticTeamSelectDialog, title, string, _("Team Selection")) // ;)
	ATTRIB(XonoticTeamSelectDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticTeamSelectDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticTeamSelectDialog, rows, float, 5)
	ATTRIB(XonoticTeamSelectDialog, columns, float, 4)
	ATTRIB(XonoticTeamSelectDialog, name, string, "TeamSelect")
	ATTRIB(XonoticTeamSelectDialog, team1, entity, NULL)
	ATTRIB(XonoticTeamSelectDialog, team2, entity, NULL)
	ATTRIB(XonoticTeamSelectDialog, team3, entity, NULL)
	ATTRIB(XonoticTeamSelectDialog, team4, entity, NULL)
ENDCLASS(XonoticTeamSelectDialog)
#endif

#ifdef IMPLEMENTATION
entity makeTeamButton(string theName, vector theColor, string commandtheName)
{
	entity b;
	b = makeXonoticBigCommandButton(theName, theColor, commandtheName, 1);
	return b;
}

void XonoticTeamSelectDialog_showNotify(entity me)
{
	float teams, nTeams;
	teams = cvar("_teams_available");
	nTeams = 0;
	me.team1.disabled = !(teams & 1); nTeams += !!(teams & 1);
	me.team2.disabled = !(teams & 2); nTeams += !!(teams & 2);
	me.team3.disabled = !(teams & 4); nTeams += !!(teams & 4);
	me.team4.disabled = !(teams & 8); nTeams += !!(teams & 8);
}

void XonoticTeamSelectDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 2, 4, e = makeTeamButton(_("join 'best' team (auto-select)"), '0 0 0', "cmd selectteam auto; cmd join"));
			e.preferredFocusPriority = 1;
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.team1 = makeTeamButton(_("red"), '1 0.5 0.5', "cmd selectteam red; cmd join"));
		me.TD(me, 2, 1, me.team2 = makeTeamButton(_("blue"), '0.5 0.5 1', "cmd selectteam blue; cmd join"));
		me.TD(me, 2, 1, me.team3 = makeTeamButton(_("yellow"), '1 1 0.5', "cmd selectteam yellow; cmd join"));
		me.TD(me, 2, 1, me.team4 = makeTeamButton(_("pink"), '1 0.5 1', "cmd selectteam pink; cmd join"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 4, makeXonoticCommandButton(_("spectate"), '0 0 0', "cmd spectate", 1));
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
