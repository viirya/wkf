
use lib '/home/phd/viirya/lib';
use lib '/home/phd/viirya/lib/lib/perl5';

use Data::Dumper;
use Lingua::Stem qw(stem);
use Lingua::StopWords qw(getStopWords);

my $stemmer = Lingua::Stem->new(-locale => 'EN');
$stemmer->stem_caching({ -level => 2 });

my $stopwords = getStopWords('en');

my $query_term = '';
my %terms;

my $input_file = $ARGV[0];
my $output_file = $ARGV[1];

my $count = 0;
my $limit = 10;
open(CON, "<$input_file") || die "$!\n";
while(my $line=<CON>) {
  chomp $line;
  $line =~ s/#n//g;
  $line =~ s/#v//g;
  $line =~ s/ /+/g;

  crawl_pages($line, \%terms);

  $count++;
  print "#$count tag.....\n";
  #last if $count++ >= $limit;
}
close(CON);

#sample_and_filter(\%terms);
output_to_file($output_file, \%terms);

exit;

sub output_to_file {

  my $output_file = shift;
  my $terms = shift;

  open(RES, ">$output_file") || die "$!\n";
  foreach my $word (keys %{$terms}) {
    print RES "$word\t" . $terms->{$word} . "\n";
  }
  close(RES);

}

sub sample_and_filter {

  my $terms = shift;

  my $total = 0;
  my $count = 0;
  foreach my $word (keys %{$terms}) {
    $total += $terms->{$word};
    $count++;
  }

  my $mean = $total / $count;

  foreach my $word (keys %{$terms}) {
    if ($terms->{$word} > 5 * $mean) {
      delete $terms->{$word};
    }
    elsif ($terms->{$word} < $mean / 2) {
      delete $terms->{$word};
    }
  }

}

sub crawl_pages {
  
  my $term = shift; 
  my $terms = shift; 
  my @vector = ();
  my $documents = 50;

  $term =~ s/\&amp//;
  $term =~ s/\&//;
  $term =~ s/\(//;
  $term =~ s/\)//;
  $term =~ s/'//;
  $term =~ s/"//;

  for(my $index=0;$index<$documents;$index+=10) {
    my $google = `w3m -dump_source -no-cookie http://www.google.com/search?q=$term&start=$index`;

    my @search_res = split(/Search Results<\/h2><div><ol>/,$google);
    my @segment = split(/<span class=gl>/,lc($search_res[1]));

    for(my $i=0;$i<10;$i++) {
	    
      if($segment[$i]) {
        my @temp = split(/<div class="s">/,$segment[$i]);
        if ($temp[1]) {
          my $obj_str = $temp[1];

          # remove urls
          $obj_str =~ s/<br><cite>(.+)<\/cite>//;
          # remove tags
          $obj_str =~ s/<(\/)*(\w+)>//g;
		    
  	  # reserve english words
  	  $obj_str =~ s/[^a-zA-Z_-]/ /g;

                     
	  my @words = split(/ /,$obj_str);
          my $stemmed_words = $stemmer->stem(@words);
            
	  foreach my $word (@{$stemmed_words}) {
            chomp($word);
            next if $word eq '';
            next if $stopwords->{$word};
            next if length($word) == 1;

            if (defined $terms->{$word}) {
              $terms->{$word}++;
            }
            else {
              $terms->{$word} = 1;
            }
          }
        }  
      }
    }
  }

  return $terms;
  
}

