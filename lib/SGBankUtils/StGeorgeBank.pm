package SGBankUtils::StGeorgeBank;

use warnings;
use strict; 
use Log::Log4perl qw(:easy);
use Text::CSV;
use Date::Parse;
use Data::Dumper;
use DateTime;
use lib "./";
use SGBankUtils::Util qw(trim trim_num_or_zero);

use Exporter qw(import); 
our @EXPORT_OK = qw(traverse_and_construct);

sub line_to_arr
{
	my ($fields, $ccy) = @_;
	my $text = trim($fields->[1]);
	my ($day, $month, $year) = split("/", $fields->[0]);
	my $debit = trim_num_or_zero($fields->[2]);
	my $credit = trim_num_or_zero($fields->[3]);
	my %e = (
		date 		=> "$year-$month-$day", 
		text 		=> $text,
		debit 		=> $debit, 
		credit 		=> $credit,
		currency 	=> $ccy 
	);
	return %e;
}

sub traverse_and_construct
{
	my $csv = Text::CSV->new({ sep_char => ',', binary => 1, });
	my $file = shift; # $ARGV[0] or die "Need to get CSV file on the command line.\n";
	open (my $data, '<', $file) or die "Could not open '$file' $!\n";
	my @outcsv = ();
	my $ccy = "AUD";
	my $counter = 0;
	my $reached_csv = 0; # is true if we reached where the good stuff is (= skip headers)
	while (my $line = <$data>) { 
		chomp $line; 
		if ($counter == 0) { 
			DEBUG("Reached first line, skipping it!");
			$counter++;
			next;
		}
		elsif ($csv->parse($line)) { 
			DEBUG("Parsing line: $line");
			my @fields = $csv->fields(); 
			my %elem = line_to_arr(\@fields, "AUD");
			push @outcsv, \%elem;
			DEBUG("Converted into hash: ".Dumper(\%elem));
		}
		else { 
			my $error = $csv->error_input();
			my $diag = $csv->error_diag();
			ERROR("Error in line: $error - rationale: $diag\n");
		}
		$counter++;
	}
	INFO("Total number of lines in raw input file: ". ($counter + 1));
	return @outcsv;
}


