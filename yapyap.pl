#!/usr/bin/perl

#  yapypa.pl
#  
#  Copyright 2011 jordonr
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
# 

use Net::Twitter;
use Term::ReadKey;
use Text::Wrap;
#use Data::Dumper;

## Setup ##
$Text::Wrap::columns = 36;
binmode STDOUT, ":encoding(utf8)";

$appName = "YapYap";
$run = 1;

## Start App ##
print "Username: ";
$user = <STDIN>;
chomp($user);

print "Password: ";
ReadMode('noecho');
$password = <STDIN>;
chomp($password);
ReadMode(0);

## Connect ##
$nt = Net::Twitter->new(
      traits   => [qw/API::REST API::Search/],
      ssl => 1,
      identica => 1,
      username => $user,
      password => $password,
      clientname => $appName,
      source => $appName
);

print "\n\nThanks!  Welcome to $appName!\n\n";
#print $colorOut->uName("\n\nThanks!  Welcom to $appName!\n\n");
print &sayLine;

&getHomeTimeline;

## Main loop ##
while($run != 0) {
	print &sayLine;
	$input = <STDIN>;
	chomp($input);
	$run = &parseInput($input);
}

exit 0;


## Functions ##

sub sayLine {
	return "-"x36 . "\n";
}

sub help {
	print "Command Mode is :\n";
	print "Search Mode is /\n";
	print "Quit or Exit-\t\t:quit, :exit, :q\n";
	print "Home Timeline-\t\t:home, :h\n";
	print "Friends Timeline-\t:friends, :f\n";
	print "Replies-\t\t:replies, :r\n";
	print "Direct messages-	:inbox, :dm\n";
	print "Help (this screen)-\t:help\n";
	return 1;
}

sub parseInput {
	$parseMe = @_[0];
	$modifier = substr($parseMe, 0, 1);
	
	print &sayLine;
		
	## Commands ##
	if($modifier eq ":") {
		@split = split(/ /, $parseMe);
		@split[0] = lc(@split[0]);
		
		if(@split[0] eq ":exit" || @split[0] eq ":quit" || @split[0] eq ":q") {
			$temp = 0;
		}
		
		if(@split[0] eq ":home" || @split[0] eq ":h") {
			$temp = &getHomeTimeline;
		}
		
		if(@split[0] eq ":friends" || @split[0] eq ":f") {
			$temp = &getFriendTimeline;
		}
		
		if(@split[0] eq ":replies" || @split[0] eq ":r") {
			$temp = &getReplies;
		}
		
		if(@split[0] eq ":inbox" || @split[0] eq ":dm") {
			$temp = &getDirectMessages;
		}
		
		if(@split[0] eq ":help") {
			$temp = &help;
		}
	}
	
	## Search ##
	elsif($modifier eq "/") {
		$searchMe = substr($parseMe, 1);
		$temp = &search($searchMe);
	}
	
	## Post Status ##
	else {
		$temp = &sendStatus($parseMe);
	}
	
	return $temp;
}

sub sendStatus {
	$status = @_[0];
	eval { $nt->update($status) };	
    if ( $@ ) {
        warn "update failed because: $@\n";
        print &sayLine;
    }
	
	return 1;
}

sub search {
	$temp = $_;
	$r = $nt->search($temp);
    for my $status ( @{$r->{results}} ) {
        print wrap("","", "<$status->{user}{screen_name}> $status->{text}\n");
    }

	return 1;
}

sub getFriendTimeline {
	$statuses = $nt->friends_timeline;
	@$statuses = reverse(@$statuses);

	for $status ( @$statuses ) {
		print wrap("","", "<$status->{user}{screen_name}> $status->{text}\n");
		print $status->{created_at} . "\n";
		print &sayLine;
	}
	
	print "Friends\n";
	
	return 1;
}

sub getHomeTimeline {
	$statuses = $nt->home_timeline;
	@$statuses = reverse(@$statuses);
	
	for $status ( @$statuses ) {
		print wrap("","", "<$status->{user}{screen_name}> $status->{text}\n");
		print $status->{created_at} . "\n";
		print &sayLine;
	}
	
	print "Home\n";
	
	return 1;
}

sub getReplies {
	$statuses = $nt->replies;
	@$statuses = reverse(@$statuses);

	for $status ( @$statuses ) {
		#$msg = "<" . $colorOut->uName($status->{user}{screen_name}) . "> $status->{text}\n";
		#print wrap("","", $msg);
		print wrap("","", "<$status->{user}{screen_name}> $status->{text}\n");
		$tempTime = $status->{created_at};
		print $tempTime . "\n";
		print &sayLine;
	}
	
	print "Replies\n";
	
	return 1;
}

sub getDirectMessages {
	$statuses = $nt->direct_messages;
	@$statuses = reverse(@$statuses);

	for $status ( @$statuses ) {
		print wrap("","", "<$status->{sender_screen_name}> $status->{text}\n");
		print $status->{created_at} . "\n";
		print &sayLine;
	}
	
	print "Direct Messages\n";
	
	return 1;
}

