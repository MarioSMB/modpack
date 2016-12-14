AUTOCVAR(sv_items_modeloverride, string, "", _("Custom directory for item models, set to something like myserver, end result will look like 'models/items_myserver/item.md3'"));
AUTOCVAR(sv_items_sounddir, string, "", _("Custom directory for item sounds, set to something like myserver, end result will look like 'sound/misc_myserver/item.wav'"));

MUTATOR_HOOKFUNCTION(mutator_mod, ItemModel)
{
	if(autocvar_sv_items_modeloverride != "" && autocvar_sv_items_modeloverride != "default")
	{
		string themdl = sprintf("models/items_%s/%s", autocvar_sv_items_modeloverride, M_ARGV(0, string));
		if(fexists(themdl))
			M_ARGV(1, string) = themdl;
	}
}

MUTATOR_HOOKFUNCTION(mutator_mod, ItemSound)
{
	if(autocvar_sv_items_sounddir != "" && autocvar_sv_items_sounddir != "default")
	{
		string thesnd = sprintf("misc_%s/%s", autocvar_sv_items_sounddir, M_ARGV(0, string));

		if (Sound_Exists(thesnd)) { M_ARGV(1, string) = thesnd; }
	}
}
