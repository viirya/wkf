
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

my $key_s_index = $h{$key_s};
my $key_d_index = $h{$key_d};  
my $row = $features[$key_s_index];
my @column = split ' ', $row;

my $score = $column[$key_d_index];

print 1 - $score . "\n";

untie %h;
untie @features;

