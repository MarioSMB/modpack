void error(...) = #1;
float id(float x) { return x; }

void Oassignments(float foo) // pass 1
{
	float bar;
	bar = 2;
	bar = (foo ? 0 : (foo & 1));
	if(bar == 2)
		error("FTEQCC SUCKS");
}

void Oreturn_only(float foo) // pass 0
{
	if(foo)
	{
		return;
	}
}

void Oreturn_only_trap(void)
{
	error("FTEQCC SUCKS");
}

.float fld;
void Ono_assignments(entity e, float wep) // pass an e with e.fld == 1, and wep == 3. e.fld will be 2 instead of 3. Observe the INDIRECT and the SUB use the same field for storage, wreaking havoc.
{
	        ((e).fld |= id(wep - 1));
}
