#! /usr/bin/perl -w
#                              -*- Mode: Perl -*- 
# wiki2html.pl --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Tue Dec 10 16:56:05 2002
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Thu Feb  6 23:54:55 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 37
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

my $preamble=<<EOF;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>_TITLE_</title>
    <style type="text/css">
      /*
      * Changing the defaults  
      */


      address
      {
      color: gray; 
      margin-left: -2em;
      text-align: right;
      }     

      body 
      {
      color: black;
      link:  #18605a;
      alink: #663300;
      vlink: #996666;
      background-color: white;
      }
      pre 
      {
      color: maroon;
      margin-left: 1em;
      font-family: monospace
      font-variant:   small-caps; 
      font-weight: bold 
      }

      /*
      *   Status
      */

      .Failed { color: LightSlateGrey; background-color: Beige; text-align: center; }
      .Successful { color: DarkGreen; background-color: PaleGreen; text-align: center; }
      .Baseline { color: MediumBlue;  background-color: Cyan; text-align: center; } 
      .Folder { font-size : smaller; font-style: italic; }
      .Ignored { color: Bisque4; background-color: Bisque; text-align: center; }


      h1.title
      {
      text-align: center; 
      font-family: Times New Roman, Helvetica, Myriad Web, Syntax, sans-serif; 
      font-weight: bold; 
      text-transform: small-caps;
      color: MidNightBlue;
      }


      small { font-size:      0.92em;  }       
      big   { font-size:      1.17em; }       


      tt, code, kbd, samp      { font-family: monospace; }


      /*
      *   Effects
      */

      .try                      { border:solid 4px;             }
      .name                     { font-size: 4em; align: center }
      .oops                     { font-family: Jester, "Comic Sans MS" }
      /* letter and word spacing */
      .letterspaced    {letter-spacing: 10pt;}
      .wordspaced      {word-spacing: 20px;}
      /* vertical alignment examples */
      .sub             {vertical-align: sub;}
      .super           {vertical-align: super;}
      /* text alignment properties */ .right {text-align: right;}
      .left            {text-align: left;}
      .justify         {text-align: justify;}
      .center          {text-align: center;}
      /* indentation and line-height examples */
      p.indent         {text-indent: 20px;
      line-height: 200%;}
      p.negindent      {text-indent: -10px;
      background-color: yellow;}
      p.noindent               { text-indent: 0em     }
      p.indent                 { text-indent: 1.5em   }
      #bigchar         {background-color: red;
      color: white;
      font-size: 28pt;
      font-family: Impact;}
      p.carson         {font-size: 12pt;
      font-family: Courier;
      letter-spacing: 4pt;
      line-height: 5pt;}
      /* text transformation properties */
      .uppercase       {text-transform: uppercase;}
      .lowercase       {text-transform: lowercase;}
      .capitalize      {text-transform: capitalize;}
      /* text-decoration properties */
      .underline       {text-decoration: underline;}
      .blink           {text-decoration: blink;}
      .line-through    {text-decoration: line-through;}
      .overline        {text-decoration: overline;}
      /* white space control */
      .normal          {white-space: normal;}
      .pre             {white-space: pre;}
      .nowrap          {white-space: nowrap;}
      .obeylines-h,.obeylines-v { white-space: nowrap;          }

      span.skip                 { display: none }
      div.skip                  { display: none }

      /* 
      * Link types
      */

      A:link                   { color:  #18605a; }       
      A:visited                { color:  #996666; }       
      A:active                 { color:  #663300; }       
      A:hover                  { color:  #FC0;    }       

      a.normref                { color : red;     }       
      a.informref              { color : green;   }       
      A.offsite                { color:  #F60;    }       

      /*
      * Ordered Lists
      */

      ol.withroman             { list-style-type: lower-roman }
      ol.upperroman            { list-style-type: upper-roman }
      ol.upperalpha            { list-style-type: upper-alpha }
      ol.withalpha             { list-style-type: lower-alpha }

      li.serif      		 { font-family: Georgia, serif, Helvetica, }
      li.sans-serif 		 { font-family: Times New Roman, Helvetica, sans-serif 	}
      li.fantasy    		 { font-family: fantasy    	}
      li.monospace  		 { font-family: monospace  	}
      li.cursive    		 { font-family: cursive    	}    

      ul.padded                { line-height: 120%                  }
      li.overskrift            { margin-top: 2ex; font-weight: bold }

      /*
      *   DocBook: Title
      */

      div.titlepage            {
      margin: 1em 0;
      padding: 1em;
      border:   solid thin;
      border-color:   blue;
      }

      .titletext               {
      color: black;
      font-size: 18pt;
      font-weight: bold;
      xmargin-bottom: -10px;
      }



      /*
      * Create a Box around the matter
      */

      div.box {
      border: solid; 
      border-width: 0.1em; 
      padding: 0.5em;
      }


      /*
      *   Logical divisions
      */

      /*
      *   DocBook: Article
      */

      /* div.article {  } */

      /*
      *   DocBook: Appendix
      */

      /* div.appendix {} */
      /* h1.appendix {} */

      /* div.article {  } */

      /*
      *   DocBook: Authors
      */

      /* div.authorgroup {} */
      h3.author                {
      font-style: bold;
      margin: 2%;  	
      text-align: center; 
      font-style: italic;
      }

      /*
      *   Abstracts
      */

      div.abstract             { font-style: italic;  }

      /*
      *   DocBook: Book
      */

      /* body.book {  } */
      /* div.book {  } */


      /*
      *   Copyright
      */

      div.copyright, p.copyright {
      font-style: bold;
      margin: 5%;  
      }

      span.holder              {
      font-family:            Times New Roman, Helvetica, Verdana, Syntax;
      font-size-adjust:       .53;


      .colophon                { display:        none; }  

      /*
      *   Introduction
      */

      div.intro                {
      font-style: italic;
      margin-left: 2em;
      margin-right: 2em
      }

      div.intro EM             {
      font-style: normal
      }

      div.intro H2             {
      background: #fbfbff;
      color: black;
      border: none;
      }


      /*
      *   Navigation
      */

      div.navigation           {
      font-size: smaller;
      background: #E0E0E0 
      }

      p.navigation             {
      font-family: Times New Roman, helvetica, Verdana, Myriad Web, Syntax; 
      font-size: 80%; 
      background: #e0e0e0;
      margin-left: -3em;
      padding: 0.3em 0.3em 0.3em 3em
      }

      /*
      *   Table of Contents
      */

      ul.toc                   { list-style-type: none; }
      div.toc,div.subtoc               {
      padding: 1em;
      border: solid thin;
      margin: 1em 0;
      background: #ddd
      }

      /*
      *   Captions
      */

      p.caption                { font-weight: bold;     }

      /*
      *   To Be Decided
      */

      p.tbd, div.tbd {
      font-style: italic;
      color: #800000;
      font-size: smaller
      }
      div.tbd                  { margin: 1em            }

      /*
      *   DocBook: Section
      */

      /* div.section {} */
      h1.section               {
      font-family: sans-serif, helvetica, Times New Roman, Verdana, Syntax; 
      text-transform: small-caps;
      }

      /*
      *   Selections
      */


      th.selected              { 
      background: #E0E022; 
      color: Blue 
      }

      /*
      *   Important things
      */
      .important                 {       
      text-transform: none;
      font-style:     normal;
      font-weight:    bolder;
      background:     white;
      color:          red;
      }       
      DIV.output                { margin-left:3%; }

      .default                  { text-decoration: underline; 
                                  font-style: normal }
      .required                 { font-weight: bold }

      .footer {
      margin-top: 2em;
      padding-top: 1em;
      border-top: solid thin black
      }
      

      /*
      *   Notes
      */


      div.note                 {
      color: green;
      margin-left: 1em;
      }

      p.note                   {
      color: green;
      margin-left: 1em;
      }

      P.pnote                  {
      border-top: red thin solid;
      border-bottom: red thin solid;
      padding: 10px;
      }

      /*
      *   Warnings
      */
      div.warning               {
      margin-right: 8%;
      margin-left:8%;
      align-margin:justify; 
      font-weight: bold; 
      border:solid 1
      }

      .warning                  
      {       
      text-transform: none;
      font-style:     normal;
      font-weight:    bolder;
      background:     yellow;
      color:  black;
      } 
      
      .warning strong {
      color: #FF4500;
      background: #FFD700;
      text-decoration: none
      }

      .warning a:link, .warning a:visited, .warning a:active {
      color: #FF4500;
      background: transparent;
      text-decoration: underline
      }

      .warning strong a:link, .warning strong a:visited, .warning strong a:active {
      color: #FF4500;
      background: #FFD700
      }

      /*
      * Error
      */

      .error {
      color: #DC143C;
      background: transparent;
      text-decoration: none
      }

      .error strong {
      color: #DC143C;
      background: #FFD700;
      text-decoration: none
      }

      .error a:link, .error a:visited, .error a:active {
      color: #DC143C;
      background: transparent;
      text-decoration: underline
      }

      .error strong a:link, .error strong a:visited, .error strong a:active {
      color: #DC143C;
      background: #FFD700
      }

      /*
      * Command bars
      */
      .commandbar                {
      position: absolute;
      top: 40px;  
      background-color: Navy;
      height: 22px;
      border: thin solid Black;  
      width: 100%;  
      }

      .commandbar div             {
      position: absolute;
      color: white;

      }

      .commandbar div a           {
      text-decoration: none;
      font-size: 10pt;
      color: White;
      font-weight: bold;  
      }

      .commandbar div a:visited   {  color: white;  }
      .commandbar div a:hover     {  color: #3399FF }
      .cmdItem                    {  top: 1px;      }
      .cmdItemA                   {
      border: thin solid White;  
      top: -1px;
      top-margin: -1px;
      cursor: default;
      font-size: 10pt;
      color: White;
      font-weight: bold;
      height: 18px;
      }


      /*
      *     Products
      */
      span.productname         {
      font-weight:    bold;
      }
      span.productnumber       {
      font-style:     italic;
      }      

      /*
      *     Outlines
      */

      .outlineunder            {
      position: absolute;
      left: 0px;
      background-color: #EEEEEE;
      width: 150px;
      border-right:black thin solid;
      height: 100%;
      top: 62px;

      }

      .outline                 {
      position: absolute;  
      top: 62px;
      width: 150px;
      padding-left: 15px;  
      font-weight: bold;
      font-family: Tahoma;
      font-size: 11pt;
      color: #003399;
      height: 100%;
      padding-top: 10px;

      }

      .outline div             {
      padding-top: 5px;
      padding-bottom: 3px;
      padding-right: 6px;
      }

      .outline div a           {
      text-decoration: none;
      color: #003399;

      }

      .outline div A:visited   {  color: #003399; }
      .outline div a:hover     {  color: #3399FF; }

      /*
      *   Examples
      */

      div.example              {
      width: 100%;
      color: black;
      }

      tt.example               {
      color: maroon;
      margin-left: 1em;
      }


      div.illegal-example      {
      width: 100%;
      color: red;
      border: solid red;
      }

      div.illegal-example p    { color: black; }

      div.deprecated-example   {
      width: 100%;
      color: red;
      border: solid rgb(255,165,0); /* orange */
      }

      div.deprecated-example p { color: black; }



      /*
      *   DTD's
      */

      pre.dtd-fragment         { margin-left: 0;        }

      pre.dtd                  {
      color: black;
      margin-left: 0;
      }

      div.dtd-example          {
      width: 100%;
      color: black;
      }

      div.dtd-fragment         {
      width: 100%;
      border: none;
      background-color: #eee;
      }

      /*
      *  Banners
      */
      .banner                    {
      top: 0px;
      position: absolute;
      padding-right: 10px;
      float: right;
      width: 100%;
      height=40px;
      background-color: #EEEEEE;
      text-align: right;
      }

      .banner img                { float: left; }

      /*
      *    TeX based stuff
      */ 

      .cmr-7                   {font-size:70%;                   	}
      .cmmi-10                 {font-style: italic;              	}
      .cmmi-7                  {font-size:70%;font-style: italic;	}
      .cmbx-10                 {font-weight: bold;               	}
      .cmtt-10                 {font-family: monospace;          	}
      .cmti-10                 {font-style: italic;              	}
      .small-caps              {font-variant: small-caps;        	}
      .hline hr, .cline hr     { height : 1px;                   	}
      .Canvas                  { position:relative;              	}    
      img.mathdisplay          { margin-top: 1em; margin-bottom: 1em; }

      .bugfixes                {
      background: yellow;
      padding:0.5em;
      margin-left:70%;
      text-align:center;
      font-style: italic;
      font-weight: bold; 
      }

      span.tex                  {letter-spacing: -0.125em; }
      span.tex span.e           { position:relative;top:0.5ex;left:-0.0417em;}
      a span.tex span.e         {text-decoration: none; }

      .math                     { font-family: "Century Schoolbook", serif; }
      .math i                   {
      font-family: "Century Schoolbook", serif;
      font-shape: italic 
      }
      .boldmath                 {
      font-family: "Century Schoolbook", serif;
      font-weight: bold 
      }
      p.tinytext                 {
      border-top: black thin solid;
      border-bottom: black thin solid;
      padding: 8px;
      font-size: 8pt;
      }
      /* implement both fixed-size and relative sizes */
      small.xtiny             { font-size : xx-small }
      small.tiny              { font-size : x-small  }
      small.scriptsize        { font-size : smaller  }
      small.footnotesize      { font-size : small    }
      small.small             {  }
      big.large               {  }
      big.xlarge              { font-size : large    }
      big.xxlarge             { font-size : x-large  }
      big.huge                { font-size : larger   }
      big.xhuge               { font-size : xx-large }


    </style>
  </head>
  <body>
    <a name="PageTop"></a>
    <h1 class="title">_TITLE_</h1>
EOF
;

my $tabletop=<<EOT;
      <table width="90%"  class="center" 
             border="1" cellspacing="0" cellpadding="1">
        <tbody>
EOT
  ;

my $tablebot=<<EOTB
        </tbody>
      </table>
EOTB
  ;


my $bottom=<<EOB;
    <SCRIPT LANGUAGE="JavaScript">
      <!--
        document.write("Last Updated:");
        document.writeln(document.lastModified);
        // -->
      </SCRIPT>
    <a name="PageBottom"></a>
  </body>
</html>

EOB
  ;

my %table_headers = ('runs0.txt' => 'Experiment Summary Table',
		     'runs1.txt' => 'Agent Counts Table',
		     'runs2.txt' => 'Timing of Events',
		     'runs3.txt' => 'Results Table',
		     'runs4.txt' => 'Level 2 Level 6 Issues',
		     'runs5.txt' => 'Events occirring in the first 7 days');
my %twiki_files = ('runs0.txt' => 'summary.html',
		   'runs1.txt' => 'agent.html',
		   'runs2.txt' => 'timing.html',
		   'runs3.txt' => 'results.html',
		   'runs4.txt' => 'level2.html',
		   'runs5.txt' => 'first7.html');

for my $input (keys %twiki_files) {
  # print STDERR "Doing file $input -> $twiki_files{$input}\n";
  if (! open (RUNS, "$input")) {
    warn "Did not find the file $input:$!";
    next;
  }

  if (! open (OUT, ">$twiki_files{$input}")) {
    warn "Could not open the output file $twiki_files{$input}:$!";
    next;
  }


  my $titles = <RUNS>;
  $titles =~ s/\*//g;

  my @title = split (/\s+\|\s+/, $titles);
  my $dummy = shift @title;
  my $headers;
  ($headers = $preamble)  =~ s/_TITLE_/$table_headers{$input}/g;

  print OUT $headers;
  print OUT $tabletop;

  print OUT "          <tr>\n";
  for (@title) {
    print OUT "            <td class=\"center\">$_</td>\n";
  }
  print OUT "          </tr>\n";


  while (<RUNS>) {
    chomp;
    next if /^\s*$/;
    next unless /\s+\|\s+\d+/;
    my $status;

    if (s/<span id=\"(\S+)\">//) {
      $status = $1;
    }
    s/<\/span>//;

    # Read line from file
    @row{ 'dummy', @title } = split (/\s+\|\s+/);

    # write line back
    print OUT "          <tr class=\"$status\">\n" if     $status;
    print OUT "          <tr class=\"center\">\n"  unless $status;
    for my $key (@title) {
      $key =~ s/\|//g;
      if (exists $row{$key} && defined $row{$key} && $row{$key}) {
	my $value = $row{$key};
	$value =~ s/\|//g;
	if ($status) {
	  print OUT "            <td class=\"$status\">$value</td>\n";
	}
	else {
	  print OUT "            <td class=\"center\">$value</td>\n";
	}
      }
      else {
	print OUT "            <td class=\"center\">\&nbsp;</td>\n";
      }
    }
    print OUT "          </tr>\n";
  }

  print OUT $tablebot;
  print OUT $bottom;
  close RUNS;
  close OUT;
}


