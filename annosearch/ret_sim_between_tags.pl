
use DB_File;
use Data::Dumper;

my $db_file_index = $ARGV[0];
my $feature_db_file = $ARGV[1];
my $key_s = $ARGV[2];
my $key_d = $ARGV[3];

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

my $feature_s = $features[$h{$key_s}];
my @features_s_index = split ':', $feature_s;
my %feature_values_s;
my %scores;

foreach my $feature_pair (@features_s_index) {
  my ($feature_index, $feature_value) = split ',', $feature_pair;
  $feature_values_s{$feature_index} = $feature_value; 
}

next if ($key_d eq 'last_index');

my $feature_d = $features[$h{$key_d}];
my @features_d_index = split ':', $feature_d;
my %feature_values_d;
  
foreach my $feature_pair (@features_d_index) {
  my ($feature_index, $feature_value) = split ',', $feature_pair;
  $feature_values_d{$feature_index} = $feature_value;
}

my $score = 0;

foreach my $feature_index (keys %feature_values_s) {
  if (defined($feature_values_d{$feature_index})) {
    $score += $feature_values_s{$feature_index} * $feature_values_d{$feature_index};
  }
}

print $score . "\n";

untie %h;
untie @features;

