use strict;
use warnings;

# List of required cli tools
my @tools = ("git", "cmake", "make", "ninja");

foreach my $tool (@tools)
{
  # Check if the tool is installed
  my $result = `which $tool 2>/dev/null`;
  chomp($result);

  if ($result)
  {
    print "$tool is installed at $result\n";
  }
  else
  {
    print "$tool is not installed. Trying to install it now...\n";
    system("brew install $tool") == 0
      or die "system failed to install $tool: $?\n";
  }
}

print "Your system should be configured now and you can proceed to building\n";