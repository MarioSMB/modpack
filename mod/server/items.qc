string autocvar_sv_items_modeloverride;

MUTATOR_HOOKFUNCTION(mutator_mod, ItemModel)
{
	if(autocvar_sv_items_modeloverride != "" && autocvar_sv_items_modeloverride != "default")
	{
		string themdl = sprintf("models/items_%s/%s", autocvar_sv_items_modeloverride, item_model);
		if(fexists(themdl))
			item_model_output = themdl;
	}

	return false;
}
