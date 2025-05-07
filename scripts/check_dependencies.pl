use strict;
use warnings;

my $os = `uname -s`;
chomp($os);
my $installer = "";

if ($os eq "Linux")
{
  $installer = "sudo dnf install -y";
}
elsif ($os eq "Darwin")
{
  $installer = "brew install";
}
else
{
  print "Unsupported OS: $os\n";
  exit 1;
}

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
    my $install_result = system("$installer $tool");

    if ($install_result != 0)
    {
      print "Error: Failed to install $tool. Exiting...\n";
      exit 1;
    }
  }
}

print "Your system should be configured now and you can proceed to building\n";
exit 0;
