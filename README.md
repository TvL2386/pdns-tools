# pdns-tools

## Why
I have one supermaster and a bunch of slaves. The problem I had is that I can remove a domain + records from the supermaster, but having to remove the domain + records from every slave is a tedious task.
Therefor I've created a simple cleanup script: [pdns_clean.sh](https://raw.github.com/TvL2386/pdns-tools/master/pdns_clean.sh).

## What does it do
This tool will check all zones that should be removed. If run without arguments, it will only list the results, if run with '-f' it will remove domains and records.

To summarizes the steps the script takes (assuming '-f'):
* It will fetch all domains from the database that has the ip of a supermaster MASTER
* Then it will use dig in tcp mode (reliable imho) to get the NS records for every domain from the supermaster
* If the dig command was succesful and your current slave is not in the resultset, this domain must be removed
* Remove domain and it's records from the database

That's it!

## What does it not do
Check and/or remove SLAVE zones that haven't been configured with a supermaster ip
