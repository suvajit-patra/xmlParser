%option prefix="xx"
%{ /* -*- C++ -*- */

# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "xml_driver.hh"
# include "xml_parser.hh"

// Work around an incompatibility in flex (at least versions
// 2.5.31 through 2.5.33): it generates code that does
// not conform to C89.  See Debian bug 333231
// <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=333231>.
# undef yywrap
# define yywrap() 1


// The location of the current token.
static xx::location loc;
%}

%option noyywrap nounput batch debug noinput
string  [a-zA-Z][a-zA-Z_0-9]*
int     [-+]?[0-9]+
float   [-+]?[0-9]*[.][0-9]+
blank   [ \t]

%{
  // Code run each time a pattern is matched.
  # define YY_USER_ACTION  loc.columns (yyleng);
%}

%%

%{
  // Code run each time yylex is called.
  loc.step ();
%}

{blank}+   loc.step ();
[\n]+      loc.lines (yyleng); loc.step ();
"<"             return xx::parser::make_LA(loc);
"?"             return xx::parser::make_QS(loc);
":"             return xx::parser::make_COL(loc);
"."             return xx::parser::make_DOT(loc);
"-"             return xx::parser::make_MIN(loc);
">"             return xx::parser::make_RA(loc);
"\""            return xx::parser::make_DQ(loc);
"="             return xx::parser::make_EQ(loc);
"/"             return xx::parser::make_SL(loc);
"xmlns"         return xx::parser::make_XMLNS(loc);
"xsi"           return xx::parser::make_XSI(loc);
"xsd"           return xx::parser::make_XSD(loc);
"noNamespaceSchemaLocation"             return xx::parser::make_XSDLOC(loc);


{int}      {
  errno = 0;
  long n = strtol (yytext, NULL, 10);
  if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
    driver.error (loc, "integer is out of range");
  return xx::parser::make_NUMBER(n, loc);
}

{float}      {
  errno = 0;
  double f = (float)atof(yytext);
  return xx::parser::make_FLOAT(f, loc);
}

{string}       return xx::parser::make_STRING(yytext, loc);
.          driver.error (loc, "invalid character");
<<EOF>>    return xx::parser::make_END(loc);
%%

void
xmldriver::scan_begin ()
{
  yy_flex_debug = trace_scanning;
  if (file.empty () || file == "-")
    yyin = stdin;
  else if (!(yyin = fopen (file.c_str (), "r")))
    {
      error ("cannot open " + file + ": " + strerror(errno));
      exit (EXIT_FAILURE);
    }
}



void
xmldriver::scan_end ()
{
  fclose (yyin);
}
