#!/usr/bin/perl -w
use strict;

my %hash;
my $id;
open FA,"$ARGV[0]" or die $!;
while(<FA>){
	chomp;
	if(/^>(\S+)/){
		$id=$1;
	}else{
		$hash{$id}.=$_;
	}
}
my $cut=$ARGV[1]; ###29000
for my $key(keys %hash){
	my $len=length($hash{$key});
	if($len>=$cut){
		open OUT,">$key.fasta" or die $!;
		print OUT">$key\n$hash{$key}\n";
	}
}
