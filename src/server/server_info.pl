#!/usr/bin/perl -w

use strict;
use Win32;

use POSIX qw/strftime/;

use HTTP::Request::Common qw(POST);  
use LWP::UserAgent;

use Data::Dumper;

my $time = strftime('%Y-%m-%d %H:%M:%S',localtime);

my $username = Win32::LoginName;
my $ip = join('.', unpack('C*', gethostbyname('')));

my $out = `netstat -n -p tcp | find ":9999"`; //rdp port 9999
my @s = split(/\s+/i, $out);
my @client =  split(':', $s[3]);

#send data to server
my $ua = LWP::UserAgent->new();  
my $req = POST 'http://aq.test.com/Stat/server', [ 
    login_at => $time,
    login_username => $username,
    server_ip => $ip,
    client_ip => $client[0]
    ];


my $content = $ua->request($req)->as_string; 

#print $content;

if ($content =~ m/200 OK/i) {
    print "OK\n";
}



