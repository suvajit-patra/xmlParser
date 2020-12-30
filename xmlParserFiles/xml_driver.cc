#include "xml_driver.hh"
#include "xml_parser.hh"

xmldriver::xmldriver ()
  : trace_scanning (false), trace_parsing (false)
{
  
}

xmldriver::~xmldriver () {}

int
xmldriver::parse (const std::string &f)
{
  std::cout<<"Parsing XML file...\n";
  file = f;
  scan_begin ();
  xx::parser parser (*this);
  parser.set_debug_level (trace_parsing);
  int res = parser.parse ();
  scan_end ();
  return res;
}

void
xmldriver::error (const xx::location& l, const std::string& m)
{
  std::cerr << l << ": " << m << std::endl;
}

void
xmldriver::error (const std::string& m)
{
  std::cerr << m << std::endl;
}


elemStack::elemStack () { top = -1; }

bool elemStack::push(Element* x)
{
  if (top >= (MAX - 1)) {
    // std::cout << "Stack Overflow";
    return false;
  }
  else {
    a[++top] = x;
    // std::cout << x << " pushed into stack\n";
    return true;
  }
}
 
Element* elemStack::pop()
{
  if (top < 0) {
    // std::cout << "Stack Underflow";
    return NULL;
  }
  else {
    Element* x = a[top--];
    return x;
  }
}
Element* elemStack::peek()
{
  if (top < 0) {
    // std::cout << "Stack is Empty";
    return NULL;
  }
  else {
    Element* x = a[top];
    return x;
  }
}

bool elemStack::isEmpty()
{
    return (top < 0);
}