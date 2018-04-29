//FEATURE: A miniature code scripting engine for all your hacking needs! Somewhat limited in functionality, but allows simple code files to be executed

.float  script_type;
.string script_value;
.entity script_next;

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
			if ( argc >= 3 && argv(1) == "file" )
			{
				float file = fopen(argv(2),FILE_READ);
				if ( file < 0 )
				{
					LOG_DEBUG("Script: unable to open file ",argv(2));
					return;
				}
				LOG_DEBUG("Script: executing ",argv(2));
				
				
				string code_source = "";
				string line;
				while (( line = fgets(file) ))
					code_source = strcat(code_source,line,"\n");
				fclose(file);
				entity ast_root = script_compile(code_source);
				
				context_push();
				context_define_variable(current_context,"argc",ftos(argc-2));
				for (int j = 2; j < argc; j++ )
					context_define_variable(current_context,strcat("arg",ftos(j-2)),argv(j));
				script_evaluate(ast_root);
				context_pop();
				
				script_cleanup(ast_root);
			}
			else
			{
				entity ast_root = script_compile(substring(command, 7, strlen(command)));
				LOG_INFO(script_evaluate(ast_root));
				script_cleanup(ast_root);
			}
			return;
		}
		
		default:
		case CMD_REQUEST_USAGE:
			LOG_INFO("Usage:^3 ", GetProgramCommandPrefix(), " script EXPRESSION...");
			LOG_INFO("Usage:^3 ", GetProgramCommandPrefix(), " script file filename");
			return;
	}
}

GENERIC_COMMAND(script, "Script interpreter") { GenericCommand_script(request, arguments, command); }

STATIC_INIT_LATE(script_command)
{
	localcmd(strcat("\nalias script \"", GetProgramCommandPrefix(), " script ${* ?}\"\n"));

	localcmd("\nalias runscript \"script file plugins/${* ?}.qs\"\n");
}
