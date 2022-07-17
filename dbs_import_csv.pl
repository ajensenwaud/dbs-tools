#!/usr/bin/perl
use strict; 
use warnings; 

use Text::CSV; 
use Data::Dumper;
use Date::Parse;
use DateTime;
use Text::CSV::Slurp;

my $csv = Text::CSV->new({ sep_char => ',' });
my $file = $ARGV[0] or die "Need to get CSV file on the command line.\n";
my $file_out = $ARGV[1] or die "Need to specify output file on the commmand line.\n";

sub trim
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

open (my $data, '<', $file) or die "Could not open '$file' $!\n";
my @out = (); 
my @out2 = ();
my $ccy = "SGD";
my $reached_csv = 0; # is true if we reached where the good stuff is (= skip headers)
while (my $line = <$data>) { 
	chomp $line; 
	if ($csv->parse($line)) { 
		my @fields = $csv->fields(); 
		if ($fields[0] eq 'Currency:') { 
			$ccy = trim((split(' ', $fields[1]))[0]);
			print "$fields[1], Setting curency = $ccy\n";
		}
		if ($fields[0] eq 'Transaction Date') { 
			print "I reached the Transsaction date line!\n";
			$reached_csv = 1;
		} elsif ($reached_csv && length($fields[0]) > 0) { 
			#	print Dumper(\@fields);
			my %elem = ( 
				'TxnDateRaw' 		=> trim($fields[0]),
				'TxnDate' 		=> str2time(trim($fields[0])." 00:00:00"),
				'Currency'		=> $ccy,
				'StatementCode' 	=> trim($fields[2]), 
				'Reference' 		=> trim($fields[3]),
				'DebitAmount' 		=> trim($fields[4]) + 0.0,
				'CreditAmount' 		=> trim($fields[5]) + 0.0, 
				'ClientReference' 	=> trim($fields[6]),
				'AdditionalReference' 	=> trim($fields[7]),
				'Misc Reference'	=> trim($fields[8])
			);
			my $txndate = DateTime->from_epoch(
				epoch => $elem{'TxnDate'}, 
				time_zone => 'Asia/Singapore'
			);
			my @elem2 = ( 
				#trim($fields[0]),
				#$txndate->year()."-".$txndate->month()."-".$txndate->day(),
				$txndate->strftime("%Y-%m-%d"),
				$ccy,
				trim($fields[2]), 
				trim($fields[3]),
				trim($fields[4]) + 0.0,
				trim($fields[5]) + 0.0, 
				trim($fields[6]),
				trim($fields[7]),
				trim($fields[8])
			);
			if ($elem{'TxnDate'}) {
				push @out, \%elem;
				push @out2, \@elem2;
			}
		}
	}
	else { 
		warn "Line could not be parsed: $line\n";
	}
}

print Dumper(@out2);

open my $fh, ">:encoding(utf8)", $file_out or die "new.csv: $!"; 
my $csvo  = Text::CSV->new({binary => 1, auto_diag => 1});
for my $e (@out2) { 
	$csvo->say($fh, \@$e);
}
close $fh or die "new.csv: $!";
#for %e in @out
#$csvo->say($fh, $_) for @out;
#close $fh or die "new csv: $!";

