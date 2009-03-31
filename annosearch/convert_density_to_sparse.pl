
use DB_File;
use Data::Dumper;

my $db_file_feature = $ARGV[0];
my $inputfile = $ARGV[1];

my @features;
 
tie @features, "DB_File", $db_file_feature, O_RDWR|O_CREAT, 0666, $DB_RECNO 
   or die "Cannot open file 'text': $!\n" ;

my $count = 0;
open(MYINPUTFILE, "<$inputfile");

while (<MYINPUTFILE>) {
  my $line = $_;

  $line =~ s/,/ /g;
  $line =~ s/ \+/\+/g;
  $line =~ s/\+ /\+/g;

  #if ($line =~ /(.*)%(.*)$/) {
    #print "$2\n"; 
    #next;
  #}
 
  print $count . "\n";

  if ($line =~ /(.*)% (.*)$/) {
    my $feature = $1;
    my $tag = $2;
    $tag = trim($tag);
    $tag = lc($tag);

    #print "processing $tag.....\n";

    #print "$tag\n";
    my @feature_vector = split ' ', $feature;
    my $sparse_feature = '';
 
    for (my $i = 0; $i <= $#feature_vector; $i++) {
      $feature_vector[$i] += 0;

      if ($feature_vector[$i] != 0) {
        if ($sparse_feature ne '') {
          $sparse_feature .= ':';
        }
        $sparse_feature .= "$i," . $feature_vector[$i];
      }
    }

    $features[$count++] = $sparse_feature . "% $tag";
  }
}

close(MYINPUTFILE);

untie @features;


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

