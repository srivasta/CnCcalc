#                              -*- Mode: Cperl -*- 
# Script_Initialize.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Tue Nov 18 19:26:42 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Wed Nov 19 18:34:28 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 14
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Script_Initialize;

use strict;
use CnCCalc::Server;
use CnCCalc;
use CnCCalc::Baseline;
use DBI;


sub handle_scripted_initialize {
  my $request = shift;      # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Initialize::::handle_scripted_initialize"
    if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};
  my $content = $request->content();


  if (! ($content =~ /DataBase=/ && $content =~ /User=/ &&
	 $content =~ /PassWord=/)) {    # Bad request!!!
    if ($url =~ /DataBase=/ && $url =~ /User=/ && $url =~ /PassWord=/) {
      $content = $url;
      $content =~ s/^[\?]+?//;
    }
    else {
      my $msg = "request did not have db name/user/password hidden variables";
      warn "$msg"	if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_message_error("$msg");
    }
  }

  $content = CGI::Util::unescape($content);

  my %vars;

  my $options = $content;
  $options =~ s/^[^\?]*\?// if $options =~ m/\?/o;
  my @variables = split('&', $options);
  foreach my $component (@variables) {
    my ($key, $var) = split('=', $component);
    if (defined $vars{$key}) {
      $vars{$key} .= ", $var";
    }
    else {
      $vars{$key} = $var;
    }
  }

  $$confref{'Lower Bound'} = undef;
  $$confref{'Upper Bound'} = undef;
  $$confref{'DB Host'}     = $vars{HostName}    if $vars{HostName};
  $$confref{'Data Base'}   = $vars{DataBase}    if $vars{DataBase};
  $$confref{'User'}        = $vars{User}    if $vars{User};
  $$confref{'Pass Word'}   = $vars{PassWord}    if $vars{PassWord};
  $$confref{'DB Port'}     = $vars{Port}    if $vars{Port};

  my $calc = CnCCalc->new();
  my $dbh  = $calc->connect_db('DB Host'   => $$confref{'DB Host'},
			       'Data Base' => $$confref{'Data Base'},
			       'User'      => $$confref{'User'},
			       'Pass Word' => $$confref{'Pass Word'},
			       'DB Port'   => $$confref{'DB Port'}
			      );

  if (! defined $dbh) {
    my $handle;
    eval {
      $handle =
	DBI->connect_cached("dbi:Pg:dbname=template1", $$confref{'User'},
			    $$confref{'Pass Word'},
			    { RaiseError => 1, AutoCommit => 1 })
	  or die $DBI::errstr;
    };
    if ($@) {
      my $msg = "Could not create database:$!";
      warn "$msg" if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_db_error("$msg");
    }
    $handle->disconnect;
    $dbh  = $calc->connect_db('DB Host'   => $$confref{'DB Host'},
			       'Data Base' => $$confref{'Data Base'},
			       'User'      => $$confref{'User'},
			       'Pass Word' => $$confref{'Pass Word'},
			       'DB Port'   => $$confref{'DB Port'}
			      );
    if (! defined $dbh) {
      my $msg = "Could not connect to new database:$!";
      warn "$msg" if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_db_error("$msg");
    }
  }
  ### Create a new statement handle to fetch table information
  my %HaveTable = ();
  my $tabsth = $dbh->table_info();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $HaveTable{$name}++;
  }
  my $message;
  if (! exists $HaveTable{'runs'}) {
    my $initobj = CnCCalc::Init->new();
    $message = $initobj->create_tables('DB Handle' => $dbh);
  }

  my $body = <<EOB;
  <html>
   <head>
     <title>Response</title>
   </head>
   <body>
    <pre>
      STATUS = DONE

      $message
    </pre>
   </body>
  </html>
EOB
  ;
  my $res = HTTP::Response->new(200);
  $res->content($body);
  return $res;
}

sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/script_initialize.html',
			       'handler' => \&handle_scripted_initialize);
}

1;
__END__
