package SGBankUtils;

use SGBankUtils::Util qw(write_array_to_csv_file);
use SGBankUtils::DBS; 
use SGBankUtils::HSBC;
use SGBankUtils::StGeorgeBank;
use Log::Log4perl qw(:easy);
use Exporter qw(import); 
our @EXPORT_OK = qw(run);

our $VERSION = "0.3";

sub run { 
	my ($format, $file, $file_out) = @_;
	INFO("Input file is: $file\n");
	# Work out what format is passed on and give back the appropriate handler 
	# from the modules using a sub routine reference
	my $handler;
	if ($format eq "--hsbc") { # Picked HSBC format
		$handler = \&SGBankUtils::HSBC::traverse_and_construct; 
	} elsif ($format eq "--dbs") {  # Picked DBS format
		$handler = \&SGBankUtils::DBS::traverse_and_construct;
	} elsif ($format eq "--stgeorge") { 
		$handler = \&SGBankUtils::StGeorgeBank::traverse_and_construct;
	} else {  # Format is unknown - die
		die "Unknown format: $format";
	}
	my @outcsv = &$handler($file);
	my $num_output = $#outcsv + 1;
	INFO("Converted into $num_output lines of transaction data.");
	write_array_to_csv_file($file_out, \@outcsv);
	INFO("Wrote $num_output lines of transaction data to $file_out");
}

1; 
