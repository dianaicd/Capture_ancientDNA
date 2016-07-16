#!/usr/bin/perl

=head1 NAME

GC_CpG.pl 

=head1 DESCRIPTION

This script takes as input a multifasta file in order to calculate 
%GC, CpG and length per sequence.

=head1 AUTHOR

Cruz-Davalos Diana Ivette

=head1 VERSION

1.0

=head1 USAGE

perl GC_CpG.pl -i INPUT.fasta -o OUTPUT

=head1 INPUT FORMAT

Multifasta file. Each identifier must include the coordinates followed by 
the position of the probe to the SNP:

>Affy670k_B<chr1:3548786-3548815_I<UP>>

GTGTACATCTTCCCTTCCTAAGGCTCATAA

>Affy670k_B<chr1:3548876-3548906_I<DOWN>>

GTATTAGCTTCCGTAAGATGGAATTCCAGAT

>Affy670k_B<chr1:3548815-3548875_I<CENTRAL1>>

AGTACTTGGTGGTTGTTTTGCAAGAAACACCTGGCCTCTAGGTCATTCTCCTAAAGATGA

>Affy670k_B<chr1:3548815-3548875_I<CENTRAL2>>

AGTACTTGGTGGTTGTTTTGCAAGAAACACATGGCCTCTAGGTCATTCTCCTAAAGATGA

>Affy670k_B<chr1:3548786-3548906_I<ALL1>>

GTGTACATCTTCCCTTCCTAAGGCTCATAAAGTACTTGGTGGTTGTTTTGCAAGAAACACCTGGCCTCTAGGTCATTCTCCTAAAGATGAGTATTAGCTTCCGTAAGATGGAATTCCAGAT


=head1 OUTPUT FORMAT

Coordinates	Position	Length	GC	CpG

chr1:3548786-3548815	UP	30	13	0

chr1:3548876-3548906	DOWN	31	12	1

chr1:3548815-3548875	CENTRAL1	60	26	0

chr1:3548815-3548875	CENTRAL2	60	25	0

chr1:3548786-3548906	ALL1	121	51	1


=cut


use Getopt::Long;
my %opts = ();
GetOptions(\%opts, 'i=s', 'o=s');


if(scalar(keys(%opts)) != 2){
   &PrintHelp();
}


sub PrintHelp {
   system "pod2text -c $0 ";
   exit();
}

#=============================================================================#
# The action starts here
#=============================================================================#
my ($line, @seq, $gc, $cpg, $length);

if(!open(FASTA, $opts{'i'})){
  die "The multifasta file cannot be found.\n"
}

open(OUTPUT, ">$opts{'o'}") || die "Cannot create output destination.\n";

print OUTPUT "Coordinates\tPosition\tLength\tGC\tCpG\n";

while (<FASTA>){
	chomp($_);
	$line = $_;
	@seq = split(//,$line);
	$gc = 0;
	$cpg = 0;
	$length = scalar(@seq);                     # Sequence length

  if ($line =~ m/>/){                         # The first match contains the
    $line =~ m/.*(chr.*)_(.*)/;               # coordinates, and the second
    print OUTPUT "$1\t$2\t";                         # the probe's position to the
    next;                                     # SNP (up, down, central)
  }

	foreach my $k (0..$length-1) {
		if($seq[$k] =~ m/[GC]/) {                 # Counts G or C occurrences
			$gc++;                                  # along the probe.
		}unless($k == 0){
		  if (($seq[$k-1] eq 'C') && ($seq[$k] eq 'G')){      # Counts CpG
				$cpg++;		                                        
			}
		}
	}
	
	print OUTPUT "$length\t$gc\t$cpg\n";

}

close(OUTPUT);
exit;
