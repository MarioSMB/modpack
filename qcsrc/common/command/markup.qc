// =========================================================
//  Markup chat characters command code, reworked by Samual
//  Last updated: December 28th, 2011
// =========================================================

void GenericCommand_markup_init()
{
	float i;
	if (markup_init)
		return;
	markup_init = 1;
	i = 0;
	markup_from[i] = "&alien"; markup_to[i] = "\x12"; ++i;
	markup_from[i] = "&:-)"; markup_to[i] = "\x13"; ++i;
	markup_from[i] = "&:-("; markup_to[i] = "\x14"; ++i;
	markup_from[i] = "&x-P"; markup_to[i] = "\x15"; ++i;
	markup_from[i] = "&:-/"; markup_to[i] = "\x16"; ++i;
	markup_from[i] = "&:-D"; markup_to[i] = "\x17"; ++i;
	markup_from[i] = "&<<"; markup_to[i] = "\x18"; ++i;
	markup_from[i] = "&>>"; markup_to[i] = "\x19"; ++i;
	markup_from[i] = "&dot"; markup_to[i] = "\x1a"; ++i;
	markup_from[i] = "&^_"; markup_to[i] = "\x1b"; ++i;
	markup_from[i] = "&ysplat"; markup_to[i] = "\x1c"; ++i;
	markup_from[i] = "&-]"; markup_to[i] = "\x1d"; ++i;
	markup_from[i] = "&--"; markup_to[i] = "\x1e"; ++i;
	markup_from[i] = "&[-"; markup_to[i] = "\x1f"; ++i;
	markup_from[i] = "&s<"; markup_to[i] = "\x2c"; ++i;
	markup_from[i] = "&s>"; markup_to[i] = "\x2e"; ++i;
	markup_from[i] = "&<-"; markup_to[i] = "\x7f"; ++i;
	markup_from[i] = "&[="; markup_to[i] = "\x80"; ++i;
	markup_from[i] = "&=="; markup_to[i] = "\x81"; ++i;
	markup_from[i] = "&=]"; markup_to[i] = "\x82"; ++i;
	markup_from[i] = "&r!"; markup_to[i] = "\x84"; ++i;
	markup_from[i] = "&|o|"; markup_to[i] = "\x85"; ++i;
	markup_from[i] = "&|u|"; markup_to[i] = "\x86"; ++i;
	markup_from[i] = "&|i|"; markup_to[i] = "\x87"; ++i;
	markup_from[i] = "&|c|"; markup_to[i] = "\x88"; ++i;
	markup_from[i] = "&[c]"; markup_to[i] = "\x89"; ++i;
	markup_from[i] = "&[n]"; markup_to[i] = "\x8a"; ++i;
	markup_from[i] = "&[]"; markup_to[i] = "\x8b"; ++i;
	markup_from[i] = "&r?"; markup_to[i] = "\x8c"; ++i;
	markup_from[i] = "&|>"; markup_to[i] = "\x8d"; ++i;
	markup_from[i] = "&splat0"; markup_to[i] = "\x8e"; ++i;
	markup_from[i] = "&splat1"; markup_to[i] = "\x8f"; ++i;
	markup_from[i] = "&[["; markup_to[i] = "\x90"; ++i;
	markup_from[i] = "&]]"; markup_to[i] = "\x91"; ++i;
	markup_from[i] = "&splat2"; markup_to[i] = "\x9a"; ++i;
	markup_from[i] = "&)("; markup_to[i] = "\x9b"; ++i;
	markup_from[i] = "&splat3"; markup_to[i] = "\x9c"; ++i;
	markup_from[i] = "&(."; markup_to[i] = "\x9d"; ++i;
	markup_from[i] = "&.."; markup_to[i] = "\x9e"; ++i;
	markup_from[i] = "&.)"; markup_to[i] = "\x9f"; ++i;
	markup_from[i] = "&<|"; markup_to[i] = "\xff"; ++i;
	unused_float = i;
}

string GenericCommand_markup(string s2)
{
	float red, ccase, i, j;
	string s, s3;

	GenericCommand_markup_init();

	s = "";

	red = 0;
	ccase = 0;
	for(i = 0; i < strlen(s2); ++i)
	{
		for(j = 0; j < NUM_MARKUPS; ++j)
		{
			s3 = substring(s2, i, strlen(markup_from[j]));
			if (s3 == markup_from[j])
			{
				s = strcat(s, markup_to[j]);
				i += strlen(markup_from[j]) - 1;
				break;
			}
		}

		if(j == NUM_MARKUPS)
		{
			if(substring(s2, i, 2) == "&&")
			{
				s = strcat(s, strconv(ccase, red, red, "&"));
				++i;
			}
			else if(substring(s2, i, 2) == "&d")
			{
				red = 2;
				ccase = 0;
				++i;
			}
			else if(substring(s2, i, 2) == "&a")
			{
				red = 2;
				ccase = 2;
				++i;
			}
			else if(substring(s2, i, 2) == "&n")
			{
				red = 0;
				ccase = 0;
				++i;
			}
			else
				s = strcat(s, strconv(ccase, red, red, substring(s2, i, 1)));
		}
	}

	return s;
}
