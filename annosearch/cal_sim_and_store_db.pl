
use DB_File;

my $feature_db_file = $ARGV[0];
my $similarity_db_file = $ARGV[1];


tie %h, "DB_File", $feature_db_file, O_RDWR|O_CREAT, 0666, $DB_HASH
   or die "Cannot open file '$feature_db_file': $!\n";

$DB_BTREE->{'flags'} = R_DUP;
tie %sim, "DB_File", $similarity_db_file, O_RDWR|O_CREAT, 0666, $DB_BTREE
    or die "Cannot open file '$similarity_db_file': $!\n";

my @keys = keys %h;
foreach my $key_s (@keys) {
  my $feature_s = $h{$key_s};
  my @features_s = split ' ', $feature_s;

  foreach my $key_d (@keys) {
    next if ($key_s eq $key_d);
    next if ($sim{$key_s . ':' . $key_d});
    next if ($sim{$key_d . ':' . $key_s});

    my $feature_d = $h{$key_d};
    my @features_d = split ' ', $feature_d;

    my $score = 0;
    for (my $i = 0; $i <= $#features_s; $i++) {
      $score += $features_s[$i] * $features_d[$i];
    }

    $sim{$key_s . ':' . $key_d} = $score; 
    
  }

}


untie %sim;
untie %h;
