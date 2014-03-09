float TEST_failed;
float TEST_ok;

void TEST_Fail(string cond)
{
	printf("Assertion failed: ", cond);
	//backtrace();
	++TEST_failed;
}

void TEST_OK()
{
	TEST_ok = TRUE;
}

float TEST_RunAll()
{
	float f = 0;
	float n = numentityfields();
	float i;
	for(i = 0; i < n; ++i)
	{
		string name = entityfieldname(i);
		if(substring(name, 0, 6) == "_TEST_")
			if(!TEST_Run(substring(name, 6, -1)))
				++f;
	}
	if(f)
	{
		printf("%d tests failed\n", f);
		return 1;
	}
	else
	{
		printf("All tests OK\n", f);
		return 0;
	}
}

float TEST_Run(string s)
{
	printf("%s: testing...\n", s);
	TEST_failed = TEST_ok = 0;
	callfunction(strcat("_TEST_", s));
	if(TEST_failed > 0)
	{
		printf("%s: %d items failed.\n", s, TEST_failed);
		return 0;
	}
	else if(!TEST_ok)
	{
		printf("%s: did not complete.\n", s);
		return 0;
	}
	return 1;
}
