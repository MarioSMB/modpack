vector Buff_Color(float buff_id)
{
	entity e;
	for(e = Buff_Type_first; e; e = e.enemy)
		if(buff_id == e.items)
			return e.colormod;
	return '1 1 1';
}

string Buff_PrettyName(float buff_id)
{
	entity e;
	for(e = Buff_Type_first; e; e = e.enemy)
		if(buff_id == e.items)
			return e.message;
	return "";
}

string Buff_Name(float buff_id)
{
	entity e;
	for(e = Buff_Type_first; e; e = e.enemy)
		if(buff_id == e.items)
			return e.netname;
	return "";
}

float Buff_Type_FromName(string buff_name)
{
	entity e;
	for(e = Buff_Type_first; e; e = e.enemy)
		if(buff_name == e.netname)
			return e.items;
	return 0;
}

string Buff_Model(float buff_id)
{
	string buffmodel = sprintf("models/buffs/buff_%s.md3", Buff_Name(buff_id));

	if(!fexists(buffmodel))
		buffmodel = "models/buffs/buff.md3";

	return buffmodel;
}
