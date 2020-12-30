%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.4"
%defines
%define parser_class_name {parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%code requires
{
# include <string>
# ifndef CLASSES_HH
# define CLASSES_HH
# include "../classes.hh"
# endif
class xsddriver;
}
// The parsing context.
%param { xsddriver& drv }
%locations
%initial-action
{
  // Initialize the initial location.
  @$.begin.filename = @$.end.filename = &drv.file;
};
%define parse.trace
%define parse.error verbose
%code
{
# include "xsd_driver.hh"
}
%define api.token.prefix {TOK_}
%token
  END  0  "end of file"
  LA  "<"
  QS  "?"
  COL  ":"
  DOT  "."
  MIN  "-"
  RA  ">"
  DQ  "\""
  EQ    "="
  SL   "/"
  NAMEEQ    "name="
  TYPEEQ  "type="
  USEEQ  "use="
  DEFEQ  "default="
  FIXEQ  "fixed="
  XSE   "xs:element"
  XSATTR  "xs:attribute"
  XSCOM   "xs:complexType"
  XSSQ   "xs:sequence"
  XSALL   "xs:all"
  XSCH   "xs:choice"
  XSSTRING  "xs:string"
  XSINT  "xs:integer"
  XSPOSINT    "xs:positiveInteger"
  XSNEGINT    "xs:negativeInteger"
  XSNNEGINT    "xs:nonNegativeInteger"
  XSNPOSINT    "xs:nonPositiveInteger"
  XSDECIMAL  "xs:decimal"
  XSBOOLEAN  "xs:boolean"
  XSDATE  "xs:date"
  XSTIME  "xs:time"
  UNBOUNDED   "unbounded"
  MAXOCREQ   "maxOccurs="
  MINOCREQ   "minOccurs="

;
%token <std::string> IDENTIFIER "identifier"
%token <int> NUMBER "number"
%nterm  <Parameter*> paramline
%nterm  <Parameter*> params
%nterm  <Attribute*> attrline
%nterm  <Attribute*> attrs
%nterm  <vector<Element*>> elements
%nterm  <Element*> element
%nterm  <xstype> type
%nterm  <int> occurval

%%
%start xsdschema;

xsdschema: header element footer                          { drv.root = $2; }

header: header LA garbage RA                              {}
| %empty                                                  {}

footer: footer LA SL garbage RA                           {}
| %empty                                                  {}

garbage: garbage "identifier"
| garbage EQ
| garbage SL
| garbage QS
| garbage DQ
| garbage COL
| garbage DOT
| garbage MIN
| garbage NUMBER
| "identifier"
| DQ
| EQ
| SL
| QS
| COL
| DOT
| MIN
| NUMBER

element: LA XSE NAMEEQ DQ "identifier" DQ paramline SL RA    { $$ = new Element(); 
                                                              $$->type = simple; 
                                                              $$->name = $5; 
                                                              $$->params = $7; 
                                                            }
| LA XSE NAMEEQ DQ "identifier" DQ paramline RA LA XSCOM RA LA XSSQ RA elements LA SL XSSQ RA LA attrline SL XSCOM RA LA SL XSE RA  { $$ = new Element(); 
                                                                                                                                      $$->type = complex; 
                                                                                                                                      $$->name = $5; 
                                                                                                                                      $$->params = $7; 
                                                                                                                                      $$->indicator = sequence; 
                                                                                                                                      $$->elements = $15; $$->attrs = $21; 
                                                                                                                                    }
| LA XSE NAMEEQ DQ "identifier" DQ paramline RA LA XSCOM RA LA XSALL RA elements LA SL XSALL RA LA attrline SL XSCOM RA LA SL XSE RA { $$ = new Element(); 
                                                                                                                                      $$->type = complex; 
                                                                                                                                      $$->name = $5; 
                                                                                                                                      $$->params = $7; 
                                                                                                                                      $$->indicator = all;
                                                                                                                                      $$->elements = $15; 
                                                                                                                                      $$->attrs = $21; 
                                                                                                                                      if($7->maxOccurs > 1 || $7->minOccurs > 1) {
                                                                                                                                        yy::parser::error (@7," Error!!! maxOccurs and minOccurs must be <= 1");
                                                                                                                                        return 1;
                                                                                                                                      }
                                                                                                                                    }
| LA XSE NAMEEQ DQ "identifier" DQ paramline RA LA XSCOM RA LA XSCH RA elements LA SL XSCH RA LA attrline SL XSCOM RA LA SL XSE RA  { $$ = new Element(); 
                                                                                                                                      $$->type = complex; 
                                                                                                                                      $$->name = $5; 
                                                                                                                                      $$->params = $7; 
                                                                                                                                      $$->indicator = choice; 
                                                                                                                                      $$->elements = $15; 
                                                                                                                                      $$->attrs = $21; 
                                                                                                                                    }

elements: elements element                                { $$ = $1;
                                                            for (auto i = $$.begin(); i != $$.end(); ++i)
                                                            {
                                                              if ((*i)->name == $2->name) {
                                                                yy::parser::error (@2,$2->name + " << Error!!! more than one definition of this element");
                                                                return 1;
                                                              }
                                                            }
                                                            $$.push_back($2); 
                                                          }
| element                                                 { $$.push_back($1); }

paramline: params                                         { if ($1->maxOccurs != -1 && $1->maxOccurs < $1->minOccurs) {
                                                              yy::parser::error (@1," Error!!! maxOccurs must be >= minOccurs");
                                                              return 1;
                                                            }
                                                            if ($1->minOccurs == -1) {
                                                              yy::parser::error (@1," Error!!! minOccurs cannot be unbounded");
                                                              return 1;
                                                            }
                                                            if ($1->maxOccurs != -1 && $1->minOccurs > $1->maxOccurs) {
                                                              yy::parser::error (@1," Error!!! minOccurs must be <= maxOccurs");
                                                              return 1;
                                                            }
                                                            $$ = $1;
                                                          }

params: params TYPEEQ DQ type DQ                          { $$ = $1; $$->type = $4; }
| params MAXOCREQ DQ occurval DQ                          { $$ = $1; $$->maxOccurs = $4; }
| params MINOCREQ DQ occurval DQ                          { $$ = $1; $$->minOccurs = $4; }
| %empty                                                  { $$ = new Parameter(); }

attrline: XSATTR attrs SL RA LA                           { $$ = $2; }
| %empty                                                  { $$ = new Attribute(); }

attrs: attrs NAMEEQ DQ "identifier" DQ                    { $$ = $1; $$->name = $4; }
| attrs TYPEEQ DQ type DQ                                 { $$ = $1; $$->type = $4; }
| attrs DEFEQ DQ "identifier" DQ                          { $$ = $1; $$->def = $4; }
| attrs FIXEQ DQ "identifier" DQ                          { $$ = $1; $$->fixed = $4; }
| attrs USEEQ DQ "identifier" DQ                          { $$ = $1; $$->use = $4; }
| %empty                                                  { $$ = new Attribute(); }

type: XSSTRING                                            { $$ = xsstring; }
| XSDECIMAL                                               { $$ = xsdecimal; }
| XSINT                                                   { $$ = xsinteger; }
| XSBOOLEAN                                               { $$ = xsboolean; }
| XSDATE                                                  { $$ = xsdate; }
| XSTIME                                                  { $$ = xstime; }
| XSPOSINT                                                { $$ = xspositiveInteger; }
| XSNEGINT                                                { $$ = xsnegativeInteger; }
| XSNNEGINT                                               { $$ = xsnonNegativeInteger; }
| XSNPOSINT                                               { $$ = xsnonPositiveInteger; }

occurval: UNBOUNDED                                       { $$ = -1; }
| "number"                                                { $$ = $1; }

%%
void
yy::parser::error (const location_type& l,
                          const std::string& m)
{
  drv.error (l, m);
}