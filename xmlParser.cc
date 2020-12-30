#include <iostream>
#include "xsdParserFiles/xsd_driver.hh"
#include "xmlParserFiles/xml_driver.hh"
#include "dbInterface.hh"

int main(int argc, char *argv[])
{
  int res = 0;
  xsddriver xsd_drv;
  xmldriver xml_drv;
  DbInterface dbInterface;
  for (int i = 1; i < argc; ++i)
    if (argv[i] == std::string("-p"))
    {
      xsd_drv.trace_parsing = true;
      xml_drv.trace_parsing = true;
    }
    else if (argv[i] == std::string("-s"))
    {
      xsd_drv.trace_scanning = true;
      xml_drv.trace_scanning = true;
    }
    else if (!xsd_drv.parse(argv[i]))   //Parse the xsd
    {
      std::cout << "XSD Parsed" << std::endl;
      xml_drv.root = xsd_drv.root;
      if (!xml_drv.parse(argv[i + 1]))  //Parse xml
      {
        //query
        std::string query = "";
        while (1)
        {
          std::cout << "\nEnter Query (Enter -q to quit):" << std::endl;
          std::cin >> query;
          std::cout<<"\n";
          if (query == "-q") //enter -q to exit
          {
            break;
          }

          dbInterface.print_query_result(dbInterface.get_query_result(xml_drv.xml_db, query));
        }
      }
      break;
    }
    else
      res = 1;

  return res;
}
