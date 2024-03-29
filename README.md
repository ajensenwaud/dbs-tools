# dbs-tools

## Situation
I am an expat living in Singapore. I use GnuCash to manage my personal finances for a while. I have lookedfor ways to streamline the accounting workflow by automating data entry of cash transactions. GnuCash provides an import facility with support for CSV and OFX formats.

## Motivation
In Singapore I use DBS and HSBC for personal banking. Unfortunately, the CSV formats of both banks are quite poor and therefore don't work well with GnuCash. For instance, DBS use the first 20-odd lines of their CSV to include various header statements, which then have to be stripped out manually, text / note fields describing the transaction are cut into random sub fields, which have to be concatenated, etc. HSBC do not have a separate debit and credit column, but instead use a minus to denote whether cash is deposited or withdrawn. For both banks, the date format (dd/mm/yyyy) is not compatiable with that GnuCash expects (yyyy-mm-dd).

To solve this issue and improve my efficiecny in GnuCash, I set out to answer the following question: Is it possible to write a tool that automates the ingestion and tranformation of transaction data into a common format, which can be easily understood by GnuCash?

## Solution
To prove it, I wrote a Perl-based tool which can transform transaction statement CSV files from various Singaporean banks into something GnuCash can understand.
Currently, only DBS and HSBC SG are supported. I plan to expand to other banks depending on need.  

## Installation
First, ensure you have a recent version of Perl installed (I use Perl 5.34, which comes with Ubuntu 22.04 at time of writing). If Perl is not installed, you can install it from packages / ports on your Linux / BSD distribution.

```
$ perl -v

This is perl 5, version 34, subversion 0 (v5.34.0) built for x86_64-linux-gnu-thread-multi
(with 50 registered patches, see perl -V for more detail)
```

Clone the repo: 

```
$ git clone https://github.com/ajensenwaud/dbs-tools.git
```

Enter the directory

```
$ cd dbs-tools
```

Generate a Makefile for your environment:

```
$ perl Makefile.PL
```

Then installation is as per most Unix systems using Make:

```
$ make
$ make install
```

This installs it into your PATH here (YMMV): 

```
$ which import_bank_csv
/home/aj/perl5/bin/import_bank_csv
```

## Usage

Usage:
```
bin/import_bank_csv [--dbs|--hsbc] [input file] [output file]
```

For instance, to import from DBS bank statement: 

```
bin/import_bank_csv --dbs dbs-input-file.csv output.csv
```

Or HSBC:

```
bin/import_bank_csv --hsbc hsbc-input-file.csv output.csv
```

After running the command, you can point GnuCash at ``output.csv`` to import it following the usual process.

## License
``dbs-tools`` is licensed under a BSD License. It comes with absolutely no warranty. As with Varnish, If you like the tool, you can buy me a beer.

## Contributions
I appreciate any kind of contribution. Feel free to open a pull request!

## News
We hit Hacker News! Follow the discussion here: https://news.ycombinator.com/item?id=32135157
