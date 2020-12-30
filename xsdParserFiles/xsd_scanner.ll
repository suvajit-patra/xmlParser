%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "xsd_driver.hh"
# include "xsd_parser.hh"

// Work around an incompatibility in flex (at least versions
// 2.5.31 through 2.5.33): it generates code that does
// not conform to C89.  See Debian bug 333231
// <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=333231>.
# undef yywrap
# define yywrap() 1


// The location of the current token.
static yy::location loc;
%}
%option noyywrap nounput batch debug noinput
id    [a-zA-Z][a-zA-Z_0-9]*
int   [0-9]+
blank [ \t]

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
"<"             return yy::parser::make_LA(loc);
"?"             return yy::parser::make_QS(loc);
":"             return yy::parser::make_COL(loc);
"."             return yy::parser::make_DOT(loc);
"-"             return yy::parser::make_MIN(loc);
">"             return yy::parser::make_RA(loc);
"\""            return yy::parser::make_DQ(loc);
"="             return yy::parser::make_EQ(loc);
"/"             return yy::parser::make_SL(loc);
"name="         return yy::parser::make_NAMEEQ(loc);
"type="         return yy::parser::make_TYPEEQ(loc);
"use="          return yy::parser::make_USEEQ(loc);
"default="      return yy::parser::make_DEFEQ(loc);
"fixed="        return yy::parser::make_FIXEQ(loc);
"xs:element"    return yy::parser::make_XSE(loc);
"xs:attribute"    return yy::parser::make_XSATTR(loc);
"xs:complexType"  return yy::parser::make_XSCOM(loc);
"xs:sequence"   return yy::parser::make_XSSQ(loc);
"xs:all"        return yy::parser::make_XSALL(loc);
"xs:choice"     return yy::parser::make_XSCH(loc);
"xs:string"     return yy::parser::make_XSSTRING(loc);
"xs:decimal"    return yy::parser::make_XSDECIMAL(loc);
"xs:integer"    return yy::parser::make_XSINT(loc);
"xs:positiveInteger"    return yy::parser::make_XSPOSINT(loc);
"xs:negativeInteger"    return yy::parser::make_XSNEGINT(loc);
"xs:nonNegativeInteger" return yy::parser::make_XSNNEGINT(loc);
"xs:nonPositiveInteger" return yy::parser::make_XSNPOSINT(loc);
"xs:boolean"    return yy::parser::make_XSBOOLEAN(loc);
"xs:date"    return yy::parser::make_XSDATE(loc);
"xs:time"    return yy::parser::make_XSTIME(loc);
"unbounded"     return yy::parser::make_UNBOUNDED(loc);
"maxOccurs="    return yy::parser::make_MAXOCREQ(loc);
"minOccurs="    return yy::parser::make_MINOCREQ(loc);


{int}      {
  errno = 0;
  long n = strtol (yytext, NULL, 10);
  if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
    driver.error (loc, "integer is out of range");
  return yy::parser::make_NUMBER(n, loc);
}

{id}       return yy::parser::make_IDENTIFIER(yytext, loc);
.          driver.error (loc, "invalid character");
<<EOF>>    return yy::parser::make_END(loc);
%%

void
xsddriver::scan_begin ()
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
xsddriver::scan_end ()
{
  fclose (yyin);
}
