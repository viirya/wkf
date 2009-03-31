
use DB_File;

my $filename = $ARGV[0];

#$DB_BTREE->{'flags'} = R_DUP;
tie %h, "DB_File", $filename, O_RDWR|O_CREAT, 0666, $DB_HASH
    or die "Cannot open file 'fruit': $!\n";

# Add a few key/value pairs to the file

# Check for existence of a key
#print "Banana Exists\n\n" if $h{"banana"} ;

# Delete a key/value pair.
#delete $h{"apple"} ;

# print the contents of the file
#my @keys = keys %h;
#foreach my $key (@keys) {
#  print "$key\n";
#}

while (($k, $v) = each %h)
  { print "$k -> $v\n" }

untie %h ;
