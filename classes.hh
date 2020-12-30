#include <string>
#include <map>
#include <vector>

using namespace std;

enum xstype { xsstring, xsdecimal, xsboolean, xsinteger, xspositiveInteger, xsnegativeInteger, xsnonNegativeInteger, xsnonPositiveInteger, xsdate, xstime };    //XSD simple elements value types
enum or_indicator { all, choice, sequence };            //XSD elements order indicators
enum el_type { simple, complex };                       //Element and Dataunits types

enum d_type { t_string, t_int, t_float, t_bool };       //XML data unit data types

class Attribute {               //XSD element attribute
        public:
        string name;
        xstype type;
        string def;
        string fixed;
        string use;
        Attribute();
        ~Attribute();
};

class Parameter {               //XSD element parameter
        public:
        xstype type;
        int maxOccurs;
        int minOccurs;
        Parameter();
        ~Parameter();
};

class Element {                 //XSD element
        public:
        string name;
        Attribute* attrs;
        Parameter* params;
        el_type type;
        or_indicator indicator;
        vector<Element*> elements;
        Element* find_child(string);
        Element();
        ~Element();
};

class DataAttr {                //XML data attribute
        public:
        string attr_name;
        string attr_val;
        d_type attr_val_type;
        DataAttr();
        ~DataAttr();
};

class DataUnit {                //XML data unit
        public:
        string name;
        DataAttr* attr;
        string data;
        d_type data_type;
        el_type unit_type;
        map<string,int> child_count;
        vector<DataUnit*> data_units;
        DataUnit();
        ~DataUnit();
};