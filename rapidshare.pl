#!/usr/bin/perl -w

use rapidshare;

my $rapid = rapidshare->new();

print "Name of the textfile: ";
chomp(my $get = <STDIN>);
$rapid->file($get);
 
print "Username: ";
chomp($get = <STDIN>);
print "Password: ";
chomp(my $pass = <STDIN>);
$rapid->save($get, $pass);

$rapid->read();
$rapid->filename();
$rapid->directory();
$rapid->startdownload();
$rapid->decompress();
