package SGBankUtils::DBS;

use warnings;
use strict;
use Log::Log4perl qw(:easy);
use Text::CSV;
use Date::Parse;
use Data::Dumper;
use SGBankUtils::Util qw(trim);

use Exporter qw(import);
our @EXPORT_OK = qw(line_to_arr traverse_and_construct);

# Convert one line of DBS CSV format to an array
sub line_to_arr
{
	my ($fields, $ccy) = @_; 	
	my $txndate = DateTime->from_epoch(
		epoch => str2time(trim($fields->[0])." 00:00:00"),
		time_zone => 'Asia/Singapore'
	);
	# Fix data converion issues, i.e. 
	# Argument " " isn't numeric in addition (+)
	my $debit = length(trim $fields->[4]) > 0 ? trim($fields->[4]) + 0.0  : 0.0;
	my $credit = length(trim $fields->[5]) > 0 ? trim($fields->[5]) + 0.0 : 0.0;
	
	# Make sure DBS use a date format that GnuCash can consume - yyyy-mm-dd
	my $txnDateStr = $txndate->strftime("%Y-%m-%d");
	my $statementCode = 	trim($fields->[2]);
	my $reference = 	trim($fields->[3]); 
	my $text = 		trim($fields->[6].$fields->[7].$fields->[8]);
	my %line = ( 
		date => $txnDateStr, 
		text => "$statementCode - $reference - $text", 
		debit => $debit, 
		credit => $credit,
		currency => $ccy
	);
	#my @line = ( 
	#	$txnDateStr, 
	#	"$statementCode - $reference - $text",	
	#	$debit, 
	#	$credit, 
	#		$ccy);
	return %line;
}

sub traverse_and_construct
{
	my $csv = Text::CSV->new({ sep_char => ',' });
	my $file = shift; # $ARGV[0] or die "Need to get CSV file on the command line.\n";
	open (my $data, '<', $file) or die "Could not open '$file' $!\n";
	my @outcsv = ();
	my $ccy = "SGD";
	my $counter = 0;
	my $reached_csv = 0; # is true if we reached where the good stuff is (= skip headers)
	while (my $line = <$data>) { 
		chomp $line; 
		if ($csv->parse($line)) { 
			my @fields = $csv->fields(); 
			if ($fields[0] eq 'Currency:') { 
				$ccy = trim((split(' ', $fields[1]))[0]);
				DEBUG( "Setting curency = $ccy" );
			}
			if ($fields[0] eq 'Transaction Date') { 
				DEBUG("I reached the Transsaction date line!");
				$reached_csv = 1;
			} elsif ($reached_csv && length($fields[0]) > 0) { 
				DEBUG("Parsing line $line");
				my %elem = line_to_arr(\@fields, $ccy);
				push @outcsv, \%elem;
				#DEBUG("Line parsed into: ".Dumper(@elem));
			}
		}
		else { 
			ERROR("Line could not be parsed: $line\n");
		}
		$counter++;
	}
	INFO("Total number of lines in raw input file: ". ($counter + 1));
	return @outcsv;
}


