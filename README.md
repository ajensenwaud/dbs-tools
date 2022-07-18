# dbs-tools
Perl-based tool which can transform transaction statement CSV files from various Singaporean banks into something GnuCash can understand.
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
