# dbs-tools

I use GnuCash to manage my personal finances. GnuCash is capable of importing bank statements from various formats (including plain old CSV), but it is quite particular about the format.
I live in Singapore and bank with HSBC and DBS for my personal banking needs. Unfortunately, the CSV formats of both banks are quite poor - for instance, DBS use the first 20-odd lines of their script to include various header statements. HSBC do not have a separate debit and credit column, but instead use a minus to denote whether cash is deposited or withdrawn. Finally, the date format is not comptabible with what CnuCash expects.

Therefore, I wrote Perl-based tool which can transform transaction statement CSV files from various Singaporean banks into something GnuCash can understand.
Currently, only DBS and HSBC SG are supported. I plan to expand to other banks depending on need.  Feel free to contribute!

Usage:
```
bin/import_csv [bank format] [input file] [output file]
```

For instance, to import from DBS bank statement: 

```
bin/import_csv dbs dbs-input-file.csv output.csv
```

Or HSBC:

```
bin/import_csv hsbc hsbc-input-file.csv output.csv
```

After running the command, you can point gnuCash at ``output.csv`` to import it following the usual process.
