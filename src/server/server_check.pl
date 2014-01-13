#!/usr/bin/perl -w

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;  
use HTTP::Response;  
use HTTP::Request::Common; 
use HTTP::Status; 

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();
use Email::Simple ();
use Email::Simple::Creator ();

use Cwd qw(abs_path getcwd);
use Fcntl;
use File::Basename qw(dirname);

chdir dirname(abs_path($0)); #change to current directory

my $logFilename = getcwd() . "/server_check.result";

my $agent = new LWP::UserAgent; 

$agent->timeout(30); 

my @downServer = ();


foreach my $url (qw(http://www.betteredu.net)) {
    my $request = GET($url); 
    $request->header('User-Agent'=>'Mozilla/5.0 (Windows NT 5.1; rv:10.0.1) Gecko/20100101 Firefox/23.0.1');  
    $request->header('Accept-Encoding'=>'gzip, deflate');  

    my $response = $agent->request($request);  
    if ($response->status_line ne "200 OK") {
        push @downServer,$url;
    }
}

my $mailBody = "";
foreach my $url (@downServer) {
    print $url . "\n";

    $mailBody .= $url . "\r\n";
}

my $lastCheckResult = "";
if (-e $logFilename) {
    open RESULT,"< $logFilename";
    $lastCheckResult = do {local $/;<RESULT>};
    close RESULT;
} 

if ($mailBody ne "" && $mailBody ne $lastCheckResult) {
    send_email("test\@qq.com", "服务器检测到异常，请检查", $mailBody);

    print "send email \n";

    
}

if ($mailBody ne $lastCheckResult) {
    #write to result
    open RESULT,"> $logFilename";
    print RESULT $mailBody;
    close RESULT;
}

sub send_email {
    my ($email, $subject, $body) = @_;

    my $smtpserver = 'smtp';
    my $smtpport = 25;
    my $smtpuser   = 'mail address';
    my $smtppassword = 'mail password';

    my $transport = Email::Sender::Transport::SMTP->new({
        host => $smtpserver,
        port => $smtpport,
        sasl_username => $smtpuser,
        sasl_password => $smtppassword});

    my $emailEncode = Email::Simple->create(
        header => [
            To      => $email,
            From    => '瓊粵小助手 <test@qq.com>',
            Subject => $subject,
        ],
        body => $body,
        );
    
    sendmail($emailEncode, { transport => $transport });
}


