%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.4"
%defines
%define api.prefix {xx}
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
# include <string>
class xmldriver;
}
// The parsing context.
%param { xmldriver& drv }
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
# include "xml_driver.hh"
elemStack elm_stack;
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
  XMLNS  "xmlns"
  XSI   "xsi"
  XSD   "xsd"
  XSDLOC "noNamespaceSchemaLocation"
;
%token <std::string> STRING "string"
%token <int> NUMBER "number"
%token <float> FLOAT "float"
%nterm <std::string> stringdata
%nterm <std::string> date
%nterm <std::string> time
%nterm <DataAttr*> ltag
%nterm <std::string> rtag
%nterm <std::vector<DataUnit*>> dataunits
%nterm <DataUnit*> dataunit

%%
%start xmldata;                           

xmldata: header dataunits                          { drv.xml_db = $2; std::cout<<"XML Parsed" <<std::endl; }

garbage: garbage STRING
| garbage EQ
| garbage SL
| garbage QS
| garbage DQ
| garbage COL
| garbage DOT
| garbage MIN
| garbage NUMBER
| garbage FLOAT
| STRING
| DQ
| EQ
| SL
| QS
| COL
| DOT
| MIN
| NUMBER
| FLOAT

hyperlink: hyperlink STRING
| hyperlink SL
| hyperlink COL
| hyperlink DOT
| hyperlink MIN
| hyperlink NUMBER
| STRING
| SL
| COL
| DOT
| MIN
| NUMBER

xsdfilename: STRING DOT XSD

xmlsival: XMLNS COL XSI EQ DQ hyperlink DQ

xsdlocationval: XSI COL XSDLOC EQ DQ xsdfilename DQ

others: others xmlsival
| others xsdlocationval
| %empty

header: header LA garbage RA                              {}
| %empty                                                  {}

dataunits: dataunits dataunit               { $$ = $1; $$.push_back($2); }
| dataunit                                  { $$.push_back($1); }

dataunit: ltag stringdata rtag              { Element* temp = elm_stack.peek();
                                              if (temp->params->type != xsstring &&
                                                temp->params->type != xsdate &&
                                                temp->params->type != xsboolean) {
                                                xx::parser::error (@2,$2 + " << Error!!! String not expected here");
                                                return 1;
                                              }
                                              if (temp->params->type == xsboolean && $2 != "true" && $2 != "false") {
                                                xx::parser::error (@2,$2 + " << Error!!! ture or false expected here");
                                                return 1;
                                              }
                                              $$ = new DataUnit(); 
                                              $$->name = temp->name;
                                              $$->data = $2;
                                              if (temp->params->type == xsboolean)  $$->data_type = t_bool;
                                              else  $$->data_type = t_string;
                                              elm_stack.pop();
                                            }
| ltag date rtag                            { Element* temp = elm_stack.peek();
                                              if (temp->params->type != xsdate) {
                                                xx::parser::error (@2,$2 + " << Error!!! Date not expected here");
                                                return 1;
                                              }
                                              $$ = new DataUnit(); 
                                              $$->name = temp->name;
                                              $$->data = $2;
                                              $$->data_type = t_string;
                                              elm_stack.pop();
                                            }
| ltag time rtag                            { Element* temp = elm_stack.peek();
                                              if (temp->params->type != xstime) {
                                                xx::parser::error (@2,$2 + " << Error!!! Time not expected here");
                                                return 1;
                                              }
                                              $$ = new DataUnit(); 
                                              $$->name = temp->name;
                                              $$->data = $2;
                                              $$->data_type = t_string;
                                              elm_stack.pop();
                                            }
| ltag NUMBER rtag                          { Element* temp = elm_stack.peek();
                                              if (temp->params->type != xsinteger && 
                                                temp->params->type != xspositiveInteger &&
                                                temp->params->type != xsnegativeInteger &&
                                                temp->params->type != xsnonNegativeInteger &&
                                                temp->params->type != xsnonPositiveInteger) 
                                              {
                                                xx::parser::error (@2,std::to_string($2) + " << Error!!! Number not expected here");
                                                return 1;
                                              }
                                              $$ = new DataUnit();
                                              $$->name = temp->name;
                                              $$->data = std::to_string($2);
                                              $$->data_type = t_int;
                                              elm_stack.pop();
                                            }
| ltag FLOAT rtag                           { Element* temp = elm_stack.peek();
                                              if (temp->params->type != xsdecimal) {
                                                xx::parser::error (@2,std::to_string($2) + " << Error!!! Float not expected here");
                                                return 1;
                                              }
                                              $$ = new DataUnit();
                                              $$->name = temp->name;
                                              $$->data = std::to_string($2);
                                              $$->data_type = t_float;
                                              elm_stack.pop();
                                            }
| ltag dataunits rtag                       { Element* temp = elm_stack.peek();
                                              if (temp->type != complex) {
                                                xx::parser::error (@2," << Error!!! Element is not complex");
                                                return 1;
                                              }
                                              $$ = new DataUnit();
                                              $$->name = temp->name;
                                              $$->attr = $1;
                                              $$->unit_type = complex;
                                              $$->data_units = $2;

                                              //Occurance and order indicator checking

                                              or_indicator t_indicator = temp->indicator;
                                              class val{public: int min,max;};
                                              std::map<std::string,val*> occurvals;
                                              for (auto i = temp->elements.begin(); i != temp->elements.end(); ++i)
                                              {
                                                $$->child_count[(*i)->name] = 0;
                                                val* temp = new val();
                                                temp->min = (*i)->params->minOccurs;
                                                temp->max = (*i)->params->maxOccurs;
                                                occurvals[(*i)->name] = temp;
                                              }
                                              std::string prv_name = "";
                                              auto elem_iter = temp->elements.begin();
                                              for (auto i = $$->data_units.begin(); i != $$->data_units.end(); ++i)
                                              {
                                                std::string t_name = (*i)->name;
                                                $$->child_count[t_name]++;
                                                if (occurvals[t_name]->max >= 0 && $$->child_count[t_name] > occurvals[t_name]->max) {    //MaxOccurs checking
                                                  xx::parser::error (@2,t_name + " << exceeds maxOccurs limit");
                                                  return 1;
                                                }
                                                if ($$->child_count[t_name] < occurvals[t_name]->min) {                                   //MinOccurs checking
                                                  xx::parser::error (@2,t_name + " << less than minOccurs limit");
                                                  return 1;
                                                }

                                                if (prv_name != t_name && t_indicator == sequence) {                                      //Order indicator "sequence" checking
                                                  if (elem_iter == temp->elements.end()) {
                                                    xx::parser::error (@2," << does not maintain the order indicator \"sequence\"");
                                                    return 1;
                                                  }
                                                  while(elem_iter != temp->elements.end() && (*elem_iter)->name != t_name)
                                                    elem_iter++;
                                                }
                                                
                                                prv_name = t_name;
                                              }

                                              if (t_indicator == choice) {                                                                //Order indicator "choice" checking
                                                int flag;
                                                for( std::map<std::string,int>::iterator ii=$$->child_count.begin(); ii!=$$->child_count.end(); ++ii)  
                                                {  
                                                  if ((*ii).second > 0) flag++;  
                                                }
                                                if (flag > 1) {
                                                  xx::parser::error (@2," << only one child allowed because order indicator is \"choice\"");
                                                  return 1;
                                                }
                                              }
                                              elm_stack.pop();
                                            }





ltag: LA STRING others RA                   { if (elm_stack.isEmpty()) {
                                                if ( drv.root->name == $2)
                                                  elm_stack.push(drv.root); 
                                                else{
                                                  xx::parser::error (@2,$2 + " << not defined in xsd");
                                                  return 1;
                                                }
                                              } else {
                                                Element* temp = elm_stack.peek()->find_child($2);
                                                if ( temp != NULL)
                                                  elm_stack.push(elm_stack.peek()->find_child($2));
                                                else{
                                                  xx::parser::error (@2,$2 + " << not defined in xsd");
                                                  return 1;
                                                }
                                              }
                                              Attribute* temp = elm_stack.peek()->attrs;
                                              if (temp->use != "optional" && temp->use != "prohibited") {
                                                xx::parser::error (@3,"Error!!! Attribute expected here");
                                                return 1;
                                              }
                                              $$ = new DataAttr();
                                            }
| LA STRING STRING EQ DQ STRING DQ others RA  { if (elm_stack.isEmpty()) {
                                                  if ( drv.root->name == $2)
                                                    elm_stack.push(drv.root); 
                                                  else{
                                                    xx::parser::error (@2,$2 + " << not defined in xsd");
                                                    return 1;
                                                  }
                                                } else {
                                                  Element* temp = elm_stack.peek()->find_child($2);
                                                  if ( temp != NULL)
                                                    elm_stack.push(elm_stack.peek()->find_child($2));
                                                  else {
                                                    xx::parser::error (@2,$2 + " << not defined in xsd");
                                                    return 1;
                                                  }
                                                }
                                                Attribute* temp = elm_stack.peek()->attrs;
                                                if (temp->use != "required") {
                                                  xx::parser::error (@3,$3 + " << Error!!! Attribute not expected here");
                                                  return 1;
                                                }
                                                if (temp->name != $3) {
                                                  xx::parser::error (@3,$3 + " << Error!!! Attribute name not right here");
                                                  return 1;
                                                }
                                                if (temp->type != xsstring &&
                                                  temp->type != xsdate &&
                                                  temp->type != xstime) {
                                                  xx::parser::error (@6,$6 + " << Error!!! String not expected here");
                                                  return 1;
                                                }
                                                $$ = new DataAttr();
                                                $$->attr_name = $3;
                                                $$->attr_val = $6;
                                                $$->attr_val_type = t_string;
                                              }
| LA STRING STRING EQ DQ NUMBER DQ others RA  { if (elm_stack.isEmpty()) {
                                                  if ( drv.root->name == $2)
                                                    elm_stack.push(drv.root); 
                                                  else{
                                                    xx::parser::error (@2,$2 + " << not defined in xsd");
                                                    return 1;
                                                  }
                                                } else {
                                                  Element* temp = elm_stack.peek()->find_child($2);
                                                  if ( temp != NULL)
                                                    elm_stack.push(elm_stack.peek()->find_child($2));
                                                  else{
                                                    xx::parser::error (@2,$2 + " << not defined in xsd");
                                                    return 1;
                                                  }
                                                }
                                                Attribute* temp = elm_stack.peek()->attrs;
                                                if (temp->use != "required") {
                                                  xx::parser::error (@3,$3 + " << Error!!! Attribute not expected here");
                                                  return 1;
                                                }
                                                if (temp->name != $3) {
                                                  xx::parser::error (@3,$3 + " << Error!!! Attribute name not right here");
                                                  return 1;
                                                }
                                                if (temp->type != xsinteger && 
                                                  temp->type != xspositiveInteger &&
                                                  temp->type != xsnegativeInteger &&
                                                  temp->type != xsnonNegativeInteger &&
                                                  temp->type != xsnonPositiveInteger) 
                                                {
                                                  xx::parser::error (@6,std::to_string($6) + " << Error!!! Number not expected here");
                                                  return 1;
                                                }
                                                if (temp->type == xspositiveInteger && $6 <= 0) {
                                                  xx::parser::error (@6,std::to_string($6) + " << Error!!! Positive Integer expected here");
                                                  return 1;
                                                }
                                                if (temp->type == xsnegativeInteger && $6 >= 0) {
                                                  xx::parser::error (@6,std::to_string($6) + " << Error!!! Negative Integer expected here");
                                                  return 1;
                                                }
                                                if (temp->type == xsnonNegativeInteger && $6 < 0) {
                                                  xx::parser::error (@6,std::to_string($6) + " << Error!!! Non Negative Integer expected here");
                                                  return 1;
                                                }
                                                if (temp->type == xsnonPositiveInteger && $6 > 0) {
                                                  xx::parser::error (@6,std::to_string($6) + " << Error!!! Non Positive Integer expected here");
                                                  return 1;
                                                }
                                                $$ = new DataAttr();
                                                $$->attr_name = $3;
                                                $$->attr_val = std::to_string($6);
                                                $$->attr_val_type = t_int;
                                              }
| LA STRING STRING EQ DQ FLOAT DQ others RA { if (elm_stack.isEmpty()) {
                                                if ( drv.root->name == $2)
                                                  elm_stack.push(drv.root); 
                                                else{
                                                  xx::parser::error (@2,$2 + " << not defined in xsd");
                                                  return 1;
                                                }
                                              } else {
                                                Element* temp = elm_stack.peek()->find_child($2);
                                                if ( temp != NULL)
                                                  elm_stack.push(elm_stack.peek()->find_child($2));
                                                else{
                                                  xx::parser::error (@2,$2 + " << not defined in xsd");
                                                  return 1;
                                                }
                                              }
                                              Attribute* temp = elm_stack.peek()->attrs;
                                              if (temp->use != "required") {
                                                xx::parser::error (@3,$3 + " << Error!!! Attribute not expected here");
                                                return 1;
                                              }
                                              if (temp->name != $3) {
                                                xx::parser::error (@3,$3 + " << Error!!! Attribute name not right here");
                                                return 1;
                                              }
                                              if (temp->type != xsdecimal) {
                                                xx::parser::error (@6,std::to_string($6) + " << Error!!! Float not expected here");
                                                return 1;
                                              }
                                              $$ = new DataAttr();
                                              $$->attr_name = $3;
                                              $$->attr_val = std::to_string($6);
                                              $$->attr_val_type = t_float;
                                            }




rtag: LA SL STRING RA                       { $$ = $3;
                                              if (elm_stack.peek()->name != $3) {
                                                xx::parser::error (@3,$3 + " << Syntax Error!!! Closing tag name is not same as opening");
                                                return 1;
                                              }
                                            }

stringdata: stringdata STRING               { $$ = $1 + " " + $2; }
| stringdata NUMBER                         { $$ = $1 + " " + std::to_string($2); }
| stringdata FLOAT                          { $$ = $1 + " " + std::to_string($2); }
| STRING                                    { $$ = $$ + $1; }
| NUMBER                                    { $$ = $$ + std::to_string($1); }
| FLOAT                                     { $$ = $$ + std::to_string($1); }

date: NUMBER SL NUMBER SL NUMBER            { $$ = std::to_string($1) + "/" + std::to_string($3) + "/" + std::to_string($5); }

time: NUMBER COL NUMBER                   { $$ = std::to_string($1) + ":" + std::to_string($3); }
| NUMBER COL NUMBER COL NUMBER          { $$ = std::to_string($1) + ":" + std::to_string($3) + ":" + std::to_string($5); }


%%
void
xx::parser::error (const location_type& l,
  const std::string& m)
{
  drv.error (l, m);
}