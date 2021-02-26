#!/usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;
my %hash;
my $id;
while(<IN>){
	chomp;
	$_=~s/\r//g;
	if(/^>/){
		$id=$_;
		$id=~s/>//g;
	}else{
#		$_=~s/\r//g;
		$_=~s/\s/N/g;
		$hash{$id}.=uc($_);
	}
}

for my $key(keys %hash){
	print ">$key\n$hash{$key}\n";
}
close IN;
