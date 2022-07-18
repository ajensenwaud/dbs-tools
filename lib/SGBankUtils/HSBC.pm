package SGBankUtils::HSBC;

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
	my $text = trim($fields->[1]);
	$fields->[2] =~ s/\,//g;
	my $amount = length(trim $fields->[2]) > 0 ? trim($fields->[2]) + 0.0 : 0.0;
	my $credit = 0.0; 
	my $debit = 0.0;
	if ($amount > 0) { 
		$credit = $amount;
	}
	else {
		$debit = -($amount);
	}
	return ( 
		$fields->[0],
		$text,
		$debit, 
		$credit,
	);
}

sub traverse_and_construct
{
	my $file = shift;
	my $csv = Text::CSV->new({sep_char => ',', quote_char => '"' });
	open (my $data, '<', $file) or die "Could not open '$file' $!\n";
	my @outcsv = ();
	my $counter = 0;
	
	while (my $line = <$data>) { 
		if ($csv->parse($line)) { 
			my @fields = $csv->fields();
			my @elem = line_to_arr(\@fields, "SGD"); 
			push @outcsv, \@elem;
		}
		$counter++;
	}	
	INFO("Total number of lines in raw input file: ". ($counter));
	return @outcsv;
}


