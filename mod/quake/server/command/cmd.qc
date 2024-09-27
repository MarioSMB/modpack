#include "cmd.qh"

// functions for ignore command
string ignore_removefromlist(entity list, entity ignore)
{
	if(ignore.crypto_idfp && ignore.crypto_idfp != "" && list.crypto_idfp && list.crypto_idfp != "")
	{
		for(int j = 0; j < IGNORE_MAXPLAYERS; ++j)
		{
			string pos = db_get(ServerProgsDB, strcat("/ignore/", list.crypto_idfp, "/", ftos(j)));
			if(pos == ignore.crypto_idfp)
			{
				db_remove(ServerProgsDB, strcat("/ignore/", list.crypto_idfp, "/", ftos(j)));
				return string_null;
			}
		}
		// should this fall back? we know advanced mode is being used
	}

	string newlist = "";
	string theid = ftos(etof(ignore));

	FOREACH_WORD(list.ignore_list, it != theid,
	{
		newlist = cons(newlist, it);
	});

	if(newlist == "")
		return string_null;
	else
		return newlist;
}

bool ignore_playerinlist(entity sender, entity targ)
{
	// TODO: optimize this by saving it to .ignore_list?
	if(targ.crypto_idfp && targ.crypto_idfp != "" && sender.crypto_idfp && sender.crypto_idfp != "")
	{
		string thelist = "";
		for(int j = 0; j < IGNORE_MAXPLAYERS; ++j)
		{
			string pos = db_get(ServerProgsDB, strcat("/ignore/", targ.crypto_idfp, "/", ftos(j)));
			thelist = cons(thelist, pos);
		}

		return ((thelist != "") ? PlayerInList(sender, thelist) : false);
	}
	else if(!targ.ignore_list || targ.ignore_list == "")
		return false;

	string theid = ftos(etof(sender));

	FOREACH_WORD(targ.ignore_list, it == theid,
	{
		return true;
	});

	return false;
}

void ignore_clearall(entity this)
{
	for(int j = 0; j < IGNORE_MAXPLAYERS; ++j)
	{
		string pos = db_get(ServerProgsDB, strcat("/ignore/", this.crypto_idfp, "/", ftos(j)));
		if(pos != "")
			db_remove(ServerProgsDB, strcat("/ignore/", this.crypto_idfp, "/", ftos(j)));
	}
}
