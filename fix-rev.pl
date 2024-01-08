#!/usr/bin/env perl
use strict;
use warnings;
use Text::CSV;

# Help text
my $help_text = << 'HELP';
WAT:
   Preprocess revolut account csv.
HOW:
   Takes input from STDIN and spits out to STDOUT
USAGE:
   ./fix-rev.pl < rev-raw-input.csv > rev-output.csv
OPTIONS:
   -h, --help displays this text

HELP

# Check for help flag
if ($ARGV[0] && ($ARGV[0] eq '-h' || $ARGV[0] eq '--help')) {
    print $help_text;
    exit;
}

# Initialize CSV parser
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });

# Process header
my $header = $csv->getline(\*STDIN);
push @$header, "Amount_with_Fee"; # Add new column header
$csv->print(\*STDOUT, $header);

# Process rows
while (my $row = $csv->getline(\*STDIN)) {
    # Remove time from date stamps
    $row->[2] =~ s/\s\d{2}:\d{2}:\d{2}//g;
    $row->[3] =~ s/\s\d{2}:\d{2}:\d{2}//g;

    # Calculate new column (Amount + Fee)
    my $amount_with_fee = $row->[5] + $row->[6];
    push @$row, $amount_with_fee; # Add calculated value as a new column

    $csv->print(\*STDOUT, $row);
}
