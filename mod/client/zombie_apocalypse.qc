REGISTER_MUTATOR(za, true);

MUTATOR_HOOKFUNCTION(za, WantEventchase)
{
	if(substring(self.model, 0, 16) == "models/monsters/")
		return true;
	return false;
}
