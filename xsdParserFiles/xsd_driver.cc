#include "xsd_driver.hh"
#include "xsd_parser.hh"

xsddriver::xsddriver ()
  : trace_scanning (false), trace_parsing (false)
{
  root = NULL;
}

xsddriver::~xsddriver ()
{
}

int
xsddriver::parse (const std::string &f)
{
  std::cout<<"Parsing XSD file...\n";
  file = f;
  scan_begin ();
  yy::parser parser (*this);
  parser.set_debug_level (trace_parsing);
  int res = parser.parse ();
  scan_end ();
  return res;
}

void
xsddriver::error (const yy::location& l, const std::string& m)
{
  std::cerr << l << ": " << m << std::endl;
}

void
xsddriver::error (const std::string& m)
{
  std::cerr << m << std::endl;
}