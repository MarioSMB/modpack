spawnfunc(tree)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	if(!this.model)
		this.model = "progs/tree.mdl";
	precache_model(this.model);
	_setmodel(this, this.model);
	CSQCMODEL_AUTOINIT(this);
	//makestatic(this);
}
