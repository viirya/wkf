
use DB_File;
use Data::Dumper;

my $db_file_index = $ARGV[0];
my $feature_db_file = $ARGV[1];
my $output_filename = $ARGV[2];

my @features;
my %h;

tie %h, "DB_File", $db_file_index, O_RDWR|O_CREAT, 0666, $DB_HASH
   or die "Cannot open file 'fruit': $!\n";

tie @features, "DB_File", $feature_db_file, O_RDWR|O_CREAT, 0666, $DB_RECNO
   or die "Cannot open file 'text': $!\n" ;

my $last_index;

if ($h{'last_index'}) {
  $last_index = $h{'last_index'};
}
else {
  $last_index = 0;
}

my @keys = keys  %h;
print $#keys + 1 . " tags.\n"; 

my $count = 0;
my $limit = 100;

open FILE, ">$output_filename" or die $!;

foreach my $key_s (@keys) {
  next if ($key_s eq 'last_index');
  my $feature_s = $features[$h{$key_s}];
  my @features_s_index = split ':', $feature_s;
  my %feature_values_s;
  my %scores;

  #last if ($count++ > $limit);
  $count++;
  print "processing #$count tag.....$key_s\n";

  foreach my $feature_pair (@features_s_index) {
    my ($feature_index, $feature_value) = split ',', $feature_pair;
    $feature_values_s{$feature_index + 1} = $feature_value; 
  }


  foreach my $feature_index (keys %feature_values_s) {
    print FILE $h{$key_s} . "  " . $feature_index . "  " . $feature_values_s{$feature_index} . "\n";    
  }

  #last if ($count++ > $limit);
  #print "$count\n";
}

close(FILE);

untie %h;
untie @features;

