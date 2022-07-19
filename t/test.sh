#!/bin/sh
bin/import_bank_csv --version
bin/import_bank_csv --hsbc t/hsbc-txn-set-01.csv t/hsbc-test-out.csv
bin/import_bank_csv --dbs t/dbs-txn-set-01.csv t/dbs-tst-out.csv

