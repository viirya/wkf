
use Data::Dumper;

my $filename = $ARGV[0];
print "filename: $filename \n";
my $outputfile = $ARGV[1];

open(MYINPUTFILE, "<$filename");
open(MYOUTFILE, ">$outputfile");

while (<MYINPUTFILE>) {
  my $line = $_;

  $line =~ s/,/ /g;
  $line =~ s/ \+/\+/g;
  $line =~ s/\+ /\+/g;

  unless ($line =~ /.*%\s$/) {
    print MYOUTFILE $line;
  }
}

close(MYINPUTFILE);
close(MYOUTFILE);

