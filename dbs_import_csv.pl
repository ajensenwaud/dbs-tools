#!/usr/bin/perl
use strict; 
use warnings; 

use Text::CSV; 
use Data::Dumper;
use Date::Parse;
use DateTime;
use Text::CSV::Slurp;
use Log::Log4perl qw(:easy);

# Set debugging level. Change to $DEBUG if you need to debug stuff
Log::Log4perl->easy_init( 
	$DEBUG
	#{ file => "STDERR", level => $DEBUG}, 
	#{ file => "STDERR", level => $ERROR } 
);

my $csv = Text::CSV->new({ sep_char => ',' });
my $file = $ARGV[0] or die "Need to get CSV file on the command line.\n";
my $file_out = $ARGV[1] or die "Need to specify output file on the commmand line.\n";

# Trim a string nicely
sub trim
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub usage
{
	return "Usage: dbs_import_csv.pl <input CSV file> <output CSV file>\n"
}

sub usage_and_die
{
	my $error = shift;
	die $error." ".usage();
}
	
# Convert one line of DBS CSV format to an array
sub line_to_arr
{
	my ($fields, $ccy) = @_; 	
	my $txndate = DateTime->from_epoch(
		epoch => str2time(trim($fields->[0])." 00:00:00"),
		time_zone => 'Asia/Singapore'
	);
	my $debitAmount = length(trim $fields->[4]) > 0 ? trim($fields->[4]) + 0.0  : 0.0;
	my $creditAmount = length(trim $fields->[5]) > 0 ? trim($fields->[5]) + 0.0 : 0.0;
	my $txnDateStr = $txndate->strftime("%Y-%m-%d");
	my $statementCode = 	trim($fields->[2]);
	my $reference = 	trim($fields->[3]); 
	my $debit = 		$debitAmount,
	my $credit = 		$creditAmount,
	my $text = 		trim($fields->[6].$fields->[7].$fields->[8]);
	my @line = ( 
		$txnDateStr, 
		$ccy, 
		$statementCode,
		$reference, 
		$debit, 
		$credit, 
		$text);
	DEBUG("Transformed line into array with data: { txnDateStr = '$txnDateStr', ccy = '$ccy', statementCode = '$statementCode', reference = '$reference', debit = '$debit', credit = '$credit', text = '$text' }");
	return @line;
}

open (my $data, '<', $file) or die "Could not open '$file' $!\n";
my @outcsv = ();
my $ccy = "SGD";
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
			my @elem = line_to_arr(\@fields, $ccy);
			push @outcsv, \@elem;
			#DEBUG("Line parsed into: ".Dumper(@elem));
		}
	}
	else { 
		ERROR("Line could not be parsed: $line\n");
	}
}

open my $fh, ">:encoding(utf8)", $file_out or usage_and_die($!); # die "Usage:  $!"; 
my $csvo  = Text::CSV->new({binary => 1, auto_diag => 1});
for my $e (@outcsv) { 
	$csvo->say($fh, \@$e);
}
close $fh or die "new.csv: $!\n".usage();

