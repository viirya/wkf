    use warnings ;
    use strict ;
    use DB_File ;

    my ($filename, $x, %h, $status, $key, $value) ;

    $filename = $ARGV[0];

    # Enable duplicate records
    $DB_BTREE->{'flags'} = R_DUP ;

    $x = tie %h, "DB_File", $filename, O_RDWR|O_CREAT, 0666, $DB_BTREE 
        or die "Cannot open $filename: $!\n";

    # iterate through the btree using seq
    # and print each key/value pair.
    $key = $value = 0 ;
    for ($status = $x->seq($key, $value, R_FIRST) ;
         $status == 0 ;
         $status = $x->seq($key, $value, R_NEXT) )
      {  print "$key -> $value\n" }

    undef $x ;
    untie %h ;

