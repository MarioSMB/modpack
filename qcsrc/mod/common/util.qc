bool checkinlist(string command, string list)
{
	string l = strcat(" ", list, " ");

	if(strstrofs(l, strcat(" ", command, " "), 0) >= 0)
		return true;

	return false;
}
