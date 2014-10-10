.float  script_type;

#include "script/string.qh"
#include "script/ast.qh"
#include "script/lex.qh"
#include "script/parse.qh"

// ========================================================================
//   Command
// ========================================================================

void GenericCommand_script(float request, float argc, string command)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			entity ast_root = script_compile(substring(command, 7, strlen(command)));
			print(strcat(script_evaluate(ast_root).script_value,"\n"));
			script_cleanup(ast_root);
			return;
		}
		
		default:
		case CMD_REQUEST_USAGE:
			print(strcat("\nUsage:^3 ", GetProgramCommandPrefix(), " script EXPRESSION...\n"));
			return;
	}
}