#ifdef SVQC
spawnfunc(misc_barrel)
{
	setmodel(this, MDL_BARREL);
	setsize(this, '-12 -12 0', '12 12 36');
	this.solid = SOLID_BBOX;
	set_movetype(this, MOVETYPE_TOSS);
	
	entity targetent = find(NULL, targetname, this.target);
	if(targetent)
		this.velocity = (targetent.origin - this.origin) * 4 + '0 0 400';
	
	settouch(this, sub_fake_remove);
}
#endif
