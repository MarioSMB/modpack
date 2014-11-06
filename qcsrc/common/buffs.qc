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

float Buff_Type_FromSprite(string buff_sprite)
{
	entity e;
	for(e = Buff_Type_first; e; e = e.enemy)
		if(buff_sprite == e.model2)
			return e.items;
	return 0;
}


float Buff_Skin(float buff_id)
{
	entity e;
	for(e = Buff_Type_first; e; e = e.enemy)
		if(buff_id == e.items)
			return e.skin;
	return 0;
}

string Buff_Sprite(float buff_id)
{
	entity e;
	for(e = Buff_Type_first; e; e = e.enemy)
		if(buff_id == e.items)
			return e.model2;
	return "";
}
