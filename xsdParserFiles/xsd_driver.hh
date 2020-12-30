#ifndef XSD_DRIVER_HH
# define XSD_DRIVER_HH
# include <string>
# include <map>
# include "xsd_parser.hh"
// Tell Flex the lexer's prototype ...
# define YY_DECL \
  yy::parser::symbol_type yylex (xsddriver& driver)
// ... and declare it for the parser's sake.
YY_DECL;
// Conducting the whole scanning and parsing of Calc++.
class xsddriver
{
public:
  xsddriver ();
  virtual ~xsddriver ();

  //Root of the parse tree
  Element* root;
  // Handling the scanner.
  void scan_begin ();
  void scan_end ();
  bool trace_scanning;
  // Run the parser on file F.
  // Return 0 on success.
  int parse (const std::string& f);
  // The name of the file being parsed.
  // Used later to pass the file name to the location tracker.
  std::string file;
  // Whether parser traces should be generated.
  bool trace_parsing;
  // Error handling.
  void error (const yy::location& l, const std::string& m);
  void error (const std::string& m);
};
#endif // ! DRIVER_HH