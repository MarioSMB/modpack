my %classoffile = ();
my %classes = ();
my %baseclass = ();
my %methods = ();
my %attrs = ();
my %methodnames = ();
my %old2new = ();

print STDERR "Scanning...\n";
for my $f(@ARGV)
{
	open my $fh, '<', $f;
	while(<$fh>)
	{
		if(/^CLASS\(([^)]*)\)(?:\s*EXTENDS\(([^)]*)\))?/)
		{
			$classes{$1} = defined($2) ? $2 : "Object";
			$classoffile{$f} = $1;
		}
		if(/^\s*METHOD\(([^),]*),\s*([^),]*)/)
		{
			$methods{$1}{$2} = $1;
			$methodnames{"$1"."_"."$2"} = $f;
			$old2new{"$2$1"} = "$1"."_"."$2";
		}
		if(/^\s*ATTRIB(?:ARRAY)?\(([^),]*),\s*([^),]*)/)
		{
			$attrs{$1}{$2} = $1;
		}
	}
	close $fh;
}

# propagate down methods etc.
print STDERR "Propagating...\n";
for my $class(keys %classes)
{
	print STDERR "$class";
	my $base = $class;
	for(;;)
	{
		$base = $classes{$base};
		last if not defined $base;
		print STDERR " -> $base";
		while(my ($method, $definingclass) = each %{$methods{$base}})
		{
			$methods{$class}{$method} = $definingclass
				if not defined $methods{$class}{$method};
		}
		while(my ($attr, $definingclass) = each %{$attrs{$base}})
		{
			$attrs{$class}{$attr} = $definingclass
				if not defined $attrs{$class}{$attr};
		}
	}
	print STDERR "\n";
}

# change all calls to base method to super, complain about skipping
print STDERR "Fixing...\n";
for my $f(@ARGV)
{
	open my $fh, '<', $f;
	my $s = do { undef local $/; <$fh>; };
	my $s0 = $s;
	close $fh;

	my $class = $classoffile{$f};
	my $base = $classes{$class};
	next if not defined $base;

	for(keys %old2new)
	{
		$s =~ s/\b$_\b/$old2new{$_}/g;
	}

	my @methods_super = map { [ $methods{$base}{$_} . "_" . $_, "SUPER($class).$_" ]; } keys %{$methods{$base}};
	for(@methods_super)
	{
		my ($search, $replace) = @$_;
		my $n = ($s =~ s/\b$search\b/$replace/g);
		print STDERR "[$f] $search -> $replace... $n replacements\n"
			if $n;
	}

	for(grep { $methodnames{$_} ne $f } keys %methodnames)
	{
		if($s =~ /\b$_\b/)
		{
			print STDERR "[$f] calls non-super external method directly: $_\n";
		}
	}

	if($s ne $s0)
	{
		print STDERR "Rewriting $f...\n";
		open my $fh, '>', $f;
		print $fh $s;
		close $fh;
	}
}
