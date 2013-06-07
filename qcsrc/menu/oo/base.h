.string classname;
entity Object_vtbl;
.string vtblname;
.entity vtblbase;
// THIS LINE INTENTIONALLY LEFT BLANK
entity spawnVtbl(entity e, entity b)
{
	entity v;
	v = spawn();
	copyentity(e, v);
	v.vtblname = v.classname;
	v.classname = "vtbl";
	if(b)
		v.vtblbase = b;
	else
		v.vtblbase = v;
	return v;
}
entity spawnObject()
{
	entity e;
	e = spawn();
	e.classname = "Object";
	if(!Object_vtbl)
		Object_vtbl = spawnVtbl(e, null_entity);
	return e;
}
