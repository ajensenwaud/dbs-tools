package SGBankUtils::Util;

use warnings;
use strict;
use Exporter qw(import);
use Data::Dumper;
use Text::CSV;
use Log::Log4perl qw(:easy);
our @EXPORT_OK = qw(trim usage usage_and_die write_array_to_csv_file);

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

sub write_array_to_csv_file
{
	my ($file_out, $outcsv)  = @_;
	DEBUG(Dumper($outcsv));
	open my $fh, ">:encoding(utf8)", $file_out or usage_and_die($!); # die "Usage:  $!"; 
	my $csvo  = Text::CSV->new({binary => 1, auto_diag => 1});
	for my $e (@$outcsv) { 
		$csvo->say($fh, \@$e);
	}
	close $fh or die "new.csv: $!\n".usage();
}

1;	