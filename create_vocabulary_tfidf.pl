
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
my @rows;

my $input_file = $ARGV[0];
my $output_file = $ARGV[1];

my $count = 0;
my $limit = 5;
open(CON, "<$input_file") || die "$!\n";
while(my $line=<CON>) {
  chomp $line;
  $line =~ s/#n//g;
  $line =~ s/#v//g;
  $line =~ s/ /+/g;

  my %row;
  crawl_pages($line, \%row);

  $rows{$line} = \%row;

  $count++;
  print "#$count tag.....\n";
  #last if $count++ >= $limit;
}
close(CON);

tfidf(\%rows);

#sample_and_filter(\%terms);
output_to_file($output_file, \%rows);

exit;


sub tfidf {    

  my $rows = shift;
  my @indexes = keys %{$rows};
  my $document_num = $#indexes;
  my %document_freq;
  my %all_keys;

  foreach my $doc_key (keys %{$rows}) {
    my $row = $rows->{$doc_key};
    foreach my $term_key (keys %{$row}) {
      if (!defined($all_keys{$term_key})) {
        $all_keys{$term_key} = 1;
      }
    }
  }

  foreach my $term_key (keys %all_keys) {
    my $sum = 0;
    foreach my $doc_key (@indexes) {
      if (defined($rows->{$doc_key}->{$term_key})) {
        $sum += $rows->{$doc_key}->{$term_key};
      }
    }
    $document_freq{$term_key} = $sum; 
  }

  foreach my $term_key (keys %all_keys) {
    $document_freq{$term_key} = $document_num / ($document_freq{$term_key} + 1);
  }

  #my %weighted_rows;
  foreach my $doc_key (@indexes) {
    foreach my $term_key (keys %all_keys) {
      if (defined($rows->{$doc_key}->{$term_key})) {
        $rows->{$doc_key}->{$term_key} *= $document_freq{$term_key};
      }
    }
    #$weighted_rows{$doc_key} = \%row;
  } 

  return $rows;

}

sub output_to_file {

  my $output_file = shift;
  my $rows = shift;
  my @indexes = keys %{$rows};
  my %rows_sum;

  foreach my $doc_key (keys %{$rows}) {
    foreach my $term_key (keys %{$rows->{$doc_key}}) {
      if (defined($rows_sum{$term_key})) {
        $rows_sum{$term_key} += $rows->{$doc_key}->{$term_key}; 
      }
      else {
        $rows_sum{$term_key} = $rows->{$doc_key}->{$term_key};
      }
    }
  }
  
  open(RES, ">$output_file") || die "$!\n";
  foreach my $key (keys %rows_sum) {
    print RES "$key\t" . $rows_sum{$key} . "\n";
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

