
use DB_File;
use Data::Dumper;

my $db_file_index = $ARGV[0];
my $similarity_db_file = $ARGV[1];
my $top_n_db_file = $ARGV[2];

my %h;

tie %h, "DB_File", $db_file_index, O_RDWR|O_CREAT, 0666, $DB_HASH
   or die "Cannot open file 'fruit': $!\n";

$DB_BTREE->{'flags'} = R_DUP;
tie %topn, "DB_File", $top_n_db_file, O_RDWR|O_CREAT, 0666, $DB_BTREE
    or die "Cannot open file '$top_n_db_file': $!\n";


my $last_index;

if ($h{'last_index'}) {
  $last_index = $h{'last_index'};
}
else {
  $last_index = 0;
}

#$DB_BTREE->{'flags'} = R_DUP;
tie %sim, "DB_File", $similarity_db_file, O_RDWR|O_CREAT, 0666, $DB_HASH
    or die "Cannot open file '$similarity_db_file': $!\n";

my @keys = keys  %h;
print $#keys + 1 . " tags.\n"; 

my $count = 0;
my $limit = 100;

foreach my $key_s (@keys) {
  next if ($key_s eq 'last_index');
  my %scores;

  #last if ($count++ > $limit);
  $count++;
  print "processing #$count tag.....$key_s\n";

  foreach my $key_d (@keys) {
    next if ($key_d eq 'last_index');
    next if ($key_s eq $key_d);
    next if ($sim{$key_s . ':' . $key_d});
    next if ($sim{$key_d . ':' . $key_s});

    print "\t\"$key_s\" \"$key_d\"\n";

    my $score = `w3m -dump_source -no-cookie "http://www.cmlab.csie.ntu.edu.tw/~viirya/flickr_cbir/cal_tags_similarity.php?src=$key_s&dst=$key_d"`;

    chomp($score);

    $scores{$key_d} = $score;

    $sim{$key_s . ':' . $key_d} = $score; 

    #last if ($count++ > $limit);
    #print "$count\n";
  }

  my @sorted_keywords = sort { $scores{$b} <=> $scores{$a} } keys %scores;
  for (my $i = 0; $i <= 100; $i++) {
    last if ($i > $#sorted_keywords);
    $topn{$key_s} = $sorted_keywords[$i];      
  }

  #last if ($count++ > $limit);
}

untie %topn;
untie %sim;
untie %h;

