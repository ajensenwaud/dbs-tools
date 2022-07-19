use strict; 
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'SGBankUtils',
	AUTHOR		=> 'Anders Jensen-Waud <aojensen@gmail.com>',
	LICENSE		=> 'bsd',
	EXE_FILES	=> [
		'bin/import_bank_csv'
	],
	VERSION_FROM 	=> 'lib/SGBankUtils.pm',
	PREREQ_PM	=> { 
		'Text::CSV'		=> '0',
		'Data::Dumper' 		=> '0',
		'Date::Parse'		=> '0',
		'DateTime'		=> '0',
		'Log::Log4perl' 	=> '0',
		######'Test::More'		=> '0'
	}
);

