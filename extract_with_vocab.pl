#use strict;
#use warnings;
use lib '/home/phd/viirya/lib';
use lib '/home/phd/viirya/lib/lib/perl5';

use Data::Dumper;
use Lingua::Stem qw(stem);
use Lingua::StopWords qw(getStopWords);

my $stemmer = Lingua::Stem->new(-locale => 'EN');
$stemmer->stem_caching({ -level => 2 });

my $stopwords = getStopWords('en');

my $documents = 50;

my $vocab_file = $ARGV[2] || "result";
print "$vocab_file\n";

# read for total corpus terms
my %corpus = ();
open(INP, "<$vocab_file") || die "$!\n";
my $count = 0;
while(my $line=<INP>) {
    chomp $line;
    if ($line =~ m/(.*?)\s(.*)/) {
      $line = $1;
    }
    $corpus{"$line"} = $count;
    $count += 1;
}
close(INP);

my $term1 = "Condoleeza Rice";
my $term2 = "Iyad Allawi";
#my $score = &similarity($term1,$term2,$count);
#printf("Similarity:%.4f\n",$score);

&generate_cbir_format;

#&concept374;
#&trecvid_query;
#&flickr_query;

sub generate_cbir_format {
  my $input_file = $ARGV[0];
  my $output_file = $ARGV[1];

    open(CON, "<$input_file") || die "$!\n";
    open(RES, ">$output_file") || die "$!\n";
    my $index = 1;
    while(my $line=<CON>) {
        chomp $line;
        $line =~ s/#n//g;
        $line =~ s/#v//g;
        $line =~ s/ /+/g;
        printf ("[%d/%d]...\n",$index,21);
        my @doc_vector = &crawl_pages($line,$count);

        foreach my $vector_index (0..scalar(@doc_vector)) {
          if ($vector_index != 0) {
            print RES ":";
          }
          print RES "$vector_index" . "," . $doc_vector[$vector_index];
        }
        print RES "% $line\n"; 
        #my $output = join ',' , @doc_vector;
        #print RES "$output % $line\n";
        $index += 1;
    }
    close(CON);
    close(RES);
}
# generate tv05,06 query vector
sub trecvid_query {
    open(CON, "<tv02.search.stem.result.txt") || die "$!\n";
    open(RES, ">tv02.query.snippet.txt") || die "$!\n";
    my $index = 1;
    my $line;
=com
    for (my $c=0;$c<22;$c++) {
    	$line=<CON>;
	$index += 1;
    }
=cut
    while($line=<CON>) {
        chomp $line;
        $line =~ s/#n//g;
        $line =~ s/#v//g;
        $line =~ s/ /+/g;
        printf ("[%d/%d]...%s\n",$index,24,$line);
        my @doc_vector = &crawl_pages($line,$count);
        my $output = join ',' , @doc_vector;
        print RES "$output\n";
        $index += 1;
    }
    close(CON);
    close(RES);
}

# generate pre-defined defined 21 flickr query vector
sub flickr_query {
    open(CON, "<qry_flickr.txt") || die "$!\n";
    open(RES, ">flickr.query.snippet.new.txt") || die "$!\n";
    my $index = 1;
    while(my $line=<CON>) {
        chomp $line;
        $line =~ s/#n//g;
        $line =~ s/#v//g;
        $line =~ s/ /+/g;
        printf ("[%d/%d]...\n",$index,21);
        my @doc_vector = &crawl_pages($line,$count);
        my $output = join ',' , @doc_vector;
        print RES "$output\n";
        $index += 1;
    }
    close(CON);
    close(RES);
}

# generate concept 374 vector
sub concept374 {
    
    open(CON, "<concepts39.txt") || die "$!\n";
    open(RES, ">snippet39.txt") || die "$!\n";
    my $index = 1;
    my $line;
=com
    for (my $c=0;$c<190;$c++) {
        $line=<CON>;
	$index += 1;
    }
=cut
    while($line=<CON>) {
        chomp $line;
        $line = lc($line);
	$line =~ s/\_/+/g;
        printf ("[%d/%d] %s...\n",$index,374,$line);
        my @doc_vector = &crawl_pages($line,$count);
        my $output = join ',' , @doc_vector;
        print RES "$output\n";
        $index += 1;
    }
    close(CON);
    close(RES);
}


sub similarity {
    $_[0] =~ s/ /+/g;
    $_[1] =~ s/ /+/g;
    print "crawing webpages for $_[0]...\n";
    my @vec1 = &crawl_pages($_[0],$_[2]);
    print "crawing webpages for $_[1]...\n";
    my @vec2 = &crawl_pages($_[1],$_[2]);
    my $score = 0;
    for (my $i=0;$i<$_[2];$i++) {
        $score += $vec1[$i]*$vec2[$i];
    }
    return $score;
}

sub crawl_pages {
    
    my @vector = ();

    for(my $index=0;$index<$documents;$index+=10) {
        my $google = `w3m -dump_source -no-cookie http://www.google.com/search?q=$_[0]&start=$index`;
        my @search_res = split(/Search Results<\/h2><div><ol>/,$google);
        my @segment = split(/<span class=gl>/,lc($search_res[1]));
        
        for(my $i=0;$i<10;$i++) {
	    
	    my @array = (); #document vector
	    for (my $j = 0;$j<$_[1];$j++) {
	         push @array,0;
	    }

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

                    #$obj_str = $stemmer->stemString($obj_str);
	    	    my @words = split(/ /,$obj_str);
                    my $stemmed_words = $stemmer->stem(@words);
                    @words = @{$stemmed_words};

		    my $word_len = @words;
	    	        foreach my $word (@words) {
	            	    if (exists $corpus{$word}) {
	    	                $array[$corpus{$word}]+=1;
		            }
	    	        }
	            }
	        }

	        # term frequency
	        my $sumation = 0;
	        foreach my $element (@array) {
	            $sumation += $element;
	        }
	        my @temp_sort = reverse sort(@array);
	        foreach my $element (@array) {
	            if ($sumation == 0) {
	                $element = 0;
		        }
		        else {
		            if($element>$temp_sort[49]) {
		                $element = $element/$sumation; }
		            else {
		    	        $element = 0;}
		        }
	        }
                push @vector, [@array];
	        #push @vector,[&normalization(@array)];
            }
        }
    
    # calculate for centroid representation
    my @result = ();
    
    for (my $i=0;$i<$_[1];$i++) {
        my $total = 0;
        for (my $j=0;$j<$documents;$j++) {
	    $total += $vector[$j][$i];
	    }
	    push @result,$total/$documents;
    }

    #@result = &normalization(@result);
    @result = @result;

    return @result;

}

sub normalization {
    my $norm = 0;
    my $length = @_;
    my @result = ();

    for (my $i=0;$i<$length;$i++) {
        $norm += $_[$i]*$_[$i];
	    push @result,0;
    }

    if ($norm == 0) {
        return @result;
    }
    else {
        $norm = sqrt($norm);
        for (my $i=0;$i<$length;$i++) {
	        $result[$i] = $_[$i]/$norm;
	    }
	    return @result;
    }
}

sub tfidf {
    my @doc_fre = ();
    for (my $i=0;$i<$count;$i++) {
        my $sum = 0;
        for (my $j=0;$j<$documents;$j++) {
            $sum += $_[$j][$i];
        }
        push @doc_fre,$sum;
    }
    
    for (my $i=0;$i<$count;$i++) {
        $doc_fre[$i] = $documents/($doc_fre[$i]+1);
    }
    
    my @result = ();

    for (my $j=0;$j<$documents;$j++) {
        my @tmp = ();
        for (my $i=0;$i<$count;$i++) {
            if($_[$j][$i] != 0) {
                push @tmp,$_[$j][$i]*$doc_fre[$i];
            }
            else {
                push @tmp,0;
            }
        }
        push @result,[@tmp];
    }

    return @result;
}
