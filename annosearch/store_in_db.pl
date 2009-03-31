
use DB_File;
use Data::Dumper;

my $db_file_index = $ARGV[0];
my $db_file_feature = $ARGV[1];
my $inputfile = $ARGV[2];

my @features;
my %h;
 
tie %h, "DB_File", $db_file_index, O_RDWR|O_CREAT, 0666, $DB_HASH
   or die "Cannot open file 'fruit': $!\n";

tie @features, "DB_File", $db_file_feature, O_RDWR|O_CREAT, 0666, $DB_RECNO 
   or die "Cannot open file 'text': $!\n" ;

my $last_index;

if ($h{'last_index'}) {
  $last_index = $h{'last_index'};
}
else {
  $last_index = 0;
}

open(MYINPUTFILE, "<$inputfile");

while (<MYINPUTFILE>) {
  my $line = $_;

  $line =~ s/,/ /g;
  $line =~ s/ \+/\+/g;
  $line =~ s/\+ /\+/g;

  if ($line =~ /(.*)% (.*)$/) {
    my $feature = $1;
    my $tag = $2;
    $tag = trim($tag);
    $tag = lc($tag);

    #print "$tag\n";
    unless ($h{$tag}) {
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

      $h{$tag} = $last_index;
      $features[$last_index++] = $sparse_feature;
      #print "In DB: " . $h{$tag} . "\n";
    }
  }
}

$h{'last_index'} = $last_index;

close(MYINPUTFILE);

untie %h ;
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

