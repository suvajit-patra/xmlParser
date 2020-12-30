#ifndef XML_DRIVER_HH
# define XML_DRIVER_HH
# include <string>
# include <map>
# include "xml_parser.hh"
# define MAX 1000   //Max stack size
// Tell Flex the lexer's prototype ...
# define YY_DECL \
  xx::parser::symbol_type xxlex (xmldriver& driver)
// ... and declare it for the parser's sake.
YY_DECL;
// Conducting the whole scanning and parsing of Calc++.
class xmldriver
{
public:
  xmldriver ();
  virtual ~xmldriver ();
  
  //Root of the parse tree
  Element* root;
  //Vertor of the dataunits
  std::vector<DataUnit*> xml_db;
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
  void error (const xx::location& l, const std::string& m);
  void error (const std::string& m);
};

class elemStack {
  int top;

  public:
      Element* a[MAX]; // Maximum size of Stack
  
      elemStack();
      bool push(Element* x);
      Element* pop();
      Element* peek();
      bool isEmpty();
};

#endif // ! DRIVER_HH