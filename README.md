# README

## Job Application Tracking Database [Mojolicious](https://mojolicious.org/) Coding Demo

This application is a rewrite to Mojolicious of an HTML5 + jquery based tool I made to keep track of job applications I had found on The Government of Canada's [Job Bank](https://www.jobbank.gc.ca/home) website.

The original Perl scripts to add data to the JSON flat files are included since I haven't converted their functions over to Mojolicious yet. On its own joblist.pl is a good example of my Web::Query usage.

## Required Modules
In addition to Mojolicious (this program was developed with Mojolicious 8.33 on Ubuntu 20.04) you will need:

* Data::Dumper
* File::Slurper
* JSON
* JSON::PP or JSON::XS
* Modern::Perl
* POSIX
* Web::Query

## Run

To add data into the application:

1. Save a job application from JobBank into a directory in public/APPLY/<abbreviation>
2. Run from command line `perl joblist.pl` to enter new data in.
3. Run from command line `perl wagesort.pl` to sort changes from apply to applied, and find out which applications have closed (according to the saved data).
4. Any applications that show up in delete.json are closed according to the job closed date. Manually delete them, as at the moment I'm looking into best practices for automated deletion besides running `rm -r $filepath` in backticks from a UUID key added to the json files.

## Configuration

jobDatabase.conf contains the locations of the json flat files used to populate data in the model the relevant keys are:

* applied_json: defaults to "public/json/applied.json"
* apply_json: defaults to "public/json/apply.json"
* delete_json: defaults to "public/json/delete.json"

File paths are stored in the form file:// pointing to the direct file rather than a relative link. To change this set find to `find=>"file:///direct/path/to/public"` and it will be removed to default to APPLY or APPLIED. If you move or rename the directories you will need to set the appropriate replace `apply_replace` and `applied_replace`.
