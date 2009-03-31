
use DB_File;
use Data::Dumper;

my $db_file_index = $ARGV[0];
my $inputfile = $ARGV[1];

my @features;
my %h;
 
tie %h, "DB_File", $db_file_index, O_RDWR|O_CREAT, 0666, $DB_HASH
   or die "Cannot open file 'fruit': $!\n";

my $last_index;

if ($h{'last_index'}) {
  $last_index = $h{'last_index'};
}
else {
  $last_index = 0;
}

my $count = 1;
open(MYINPUTFILE, "<$inputfile");

while (<MYINPUTFILE>) {
  my $line = $_;

  print $count++ . "\n";

  if ($line =~ /(.*)% (.*)$/) {
    my $feature = $1;
    my $tag = $2;
    $tag = trim($tag);
    $tag = lc($tag);

    if (!defined($h{$tag})) {
      $h{$tag} = $last_index;
      $last_index++;
    }
    else {
      print "$tag has been defined previously.\n";
    }
  }
}

$h{'last_index'} = $last_index;

close(MYINPUTFILE);

untie %h ;

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
# Left trim function to remove leading whitespace
sub ltrim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	return $string;
}
# Right trim function to remove trailing whitespace
sub rtrim($)
{
	my $string = shift;
	$string =~ s/\s+$//;
	return $string;
}

