#!/usr/bin/perl
# this tool generates JUST the autocvar declarations for cvars
use strict;
use warnings;

my @files = @ARGV;

my %cvars = ();
my %old = ();
my %menu = ();
my %defaults = ();

sub found($$$$)
{
	my ($name, $type, $default, $force) = @_;
	if(length $name >= 55)
	{
		warn "cvar $name is a Dr. honorificabilitudinitatibis causa BRLOGENSHFEGLE";
		$type = 'cvar_toolong';
		return;
	}
#	$old{$name} = 1
#		if $force;
#	$menu{$name} = 1
#		if $force > 1;
	if(exists $cvars{$name} and not defined $cvars{name})
	{
		# have already warned
	}
	elsif(exists $cvars{$name} and $type ne $cvars{$name})
	{
		warn "cvar $name used with different types";
		if($force)
		{
			$defaults{$name} = $default;
			$cvars{$name} = $type;
		}
		else
		{
			undef $cvars{$name}
				unless $old{$name};
		}
		return;
	}
	elsif(exists $cvars{$name} and exists $defaults{$name} and $default ne $defaults{$name})
	{
		warn "cvar $name used with different defaults";
		if($force)
		{
			$defaults{$name} = $default;
			$cvars{$name} = $type;
		}
		else
		{
			undef $cvars{$name}
				unless $old{$name};
		}
	}
	else
	{
		$defaults{$name} = $default;
		$cvars{$name} = $type;
	}
}

for my $f(@files)
{
	print STDERR "In file $f\n";
	open my $fh, "<", $f;
	while(<$fh>)
	{
		chomp;
		if(/^\/\/#NO AUTOCVARS START/ .. /^\/\/#NO AUTOCVARS END/)
		{
			next;
		}
		s/\/\/.*//;
		if(/^(?:var )?float autocvar_(\w+);$/)
		{
			found $1, 'cvar', 0, 1;
			next;
		}
		if(/^var float autocvar_(\w+) = (.*);$/)
		{
			found $1, 'cvar', $2, 1;
			next;
		}
		if(/^(?:var )?vector autocvar_(\w+);$/)
		{
			found $1, 'cvar_vector', "0 0 0", 1;
			next;
		}
		if(/^var vector autocvar_(\w+) = '(.*)';$/)
		{
			found $1, 'cvar_vector', $2, 1;
			next;
		}
		if(/^(?:var )?string autocvar_(\w+);$/)
		{
			found $1, 'cvar_string', "", 1;
			next;
		}
		if(/^var string autocvar_(\w+) = "(.*)";$/)
		{
			found $1, 'cvar_string', $2, 1;
			next;
		}
		if(/^#define autocvar_(\w+) cvar("\1")$/)
		{
			found $1, 'cvar', 0, 2;
			next;
		}
		if(/^#define autocvar_(\w+) cvar_or("\1", (.*))$/)
		{
			found $1, 'cvar', $1, 2;
			next;
		}
		if(/^#define autocvar_(\w+) cvar_string("\1")$/)
		{
			found $1, 'cvar_string', "", 2;
			next;
		}
		while(/\bcvar\s*\(\s*"(\w+)"\s*\)/g)
		{
			found $1, 'cvar', 0, 0;
		}
		while(/\bcvar_string\s*\(\s*"(\w+)"\s*\)/g)
		{
			found $1, 'cvar_string', "", 0;
		}
		while(/\bcvar_vector\s*\(\s*"(\w+)"\s*\)/g)
		{
			found $1, 'cvar_vector', "0 0 0", 0;
		}
		while(/\bcvar_or\s*\(\s*"(\w+)"\s*,\s*([^\s)]+)\s*\)/g)
		{
			found $1, 'cvar', $2, 0;
		}
	}
}

if($ENV{AUTOCVARING_SVQC})
{
	for my $f(<menu/xonotic/*.c>)
	{
		print STDERR "In file $f\n";
		open my $fh, "<", $f;
		while(<$fh>)
		{
			for(/"([^"]*)"/g)
			{
				$menu{$1} = 1;
			}
		}
	}

	for my $f(<../maps/campaign*.txt>)
	{
		print STDERR "In file $f\n";
		open my $fh, "<", $f;
		while(<$fh>)
		{
			for(/\b(.+?)\b/g)
			{
				$menu{$1} = 1;
			}
		}
	}
}

for my $name(sort keys %cvars)
{
	my $type = $cvars{$name};
	my $menu = $menu{$name};
	my $default = $defaults{$name};
	die "wtf" if $name =~ /\0/;
	if(not defined $type)
	{
		print "// cannot declare $name, it is used with different types\n";
	}
	elsif($type eq 'cvar_toolong')
	{
		print "// cannot declare $name, name is too long\n";
	}
	elsif($type eq 'cvar' and not $menu and $default eq "0")
	{
		print "float autocvar_$name;\n";
	}
	elsif($type eq 'cvar' and not $menu and $default ne "0")
	{
		print "var float autocvar_$name = $default;\n";
	}
	elsif($type eq 'cvar_vector' and not $menu and $default eq "0 0 0")
	{
		print "vector autocvar_$name;\n";
	}
	elsif($type eq 'cvar_vector' and not $menu and $default ne "0 0 0")
	{
		print "var vector autocvar_$name = '$default';\n";
	}
	elsif($type eq 'cvar_string' and not $menu and $default eq "")
	{
		print "string autocvar_$name;\n";
	}
	elsif($type eq 'cvar_string' and not $menu and $default ne "")
	{
		print "var string autocvar_$name = \"$default\";\n";
	}
	elsif($type eq 'cvar' and $menu and $default eq "0")
	{
		print "#define autocvar_$name cvar(\"$name\")\n";
	}
	elsif($type eq 'cvar' and $menu and $default ne "0")
	{
		print "#define autocvar_$name cvar_or(\"$name\", \"$default\")\n";
	}
	elsif($type eq 'cvar_string' and $menu) # sorry, no cvar_or for these
	{
		print "#define autocvar_$name cvar_string(\"$name\")\n";
	}
	elsif($type eq 'cvar_vector' and $menu) # sorry, no cvar_or for these
	{
		print "#define autocvar_$name cvar_vector(\"$name\")\n";
	}
}

for my $f(@files)
{
	print STDERR "In file $f\n";
	open my $fh, "<", $f;
	my $out = "";
	while(<$fh>)
	{
		chomp;
		if(/^\/\/#NO AUTOCVARS START/ .. /^\/\/#NO AUTOCVARS END/)
		{
			$out .= "$_\n";
			next;
		}
		if(/^(?:var )?float autocvar_(.*);$/)
		{
			$out .= "$_\n";
			next;
		}
		if(/^(?:var )?string autocvar_(.*);$/)
		{
			$out .= "$_\n";
			next;
		}
		if(/^#define autocvar_(.*) cvar/)
		{
			$out .= "$_\n";
			next;
		}
		s{\b(cvar|cvar_string|cvar_vector|cvar_or)\s*\(\s*"([^"]+)"\s*(?:,\s*[^\s)]+\s*)?\)}{
			my ($type, $name) = ($1, $2);
			$type = 'cvar' if $type eq 'cvar_or';
			my $realtype = $cvars{$name};
			my $r = $&;
			if(defined $realtype)
			{
				#$r = "$realtype(\"$name\")";
				$r = "autocvar_$name";
				if($type eq 'cvar' && $realtype eq 'cvar_string')
				{
					$r = "stof($r)";
				}
				if($type eq 'cvar_string' && $realtype eq 'cvar')
				{
					$r = "ftos($r)";
				}
			}
			$r;
		}ge;
		$out .= "$_\n";
	}
	close $fh;
	open $fh, ">", $f;
	print $fh $out;
	close $fh;
}
