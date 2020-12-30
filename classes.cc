#include "classes.hh"

Element::Element()
{
    name = "";
    type = simple;
    attrs = new Attribute();
    params = new Parameter();
    indicator = all;
}

Element::~Element()
{
}

Element* Element::find_child(string name) {
    for (auto i = elements.begin(); i != elements.end(); ++i)
    {
        if ((*i)->name == name)
        {
            return (*i);
        }
    }

    return NULL;
}

Attribute::Attribute()
{
    name = "";
    type = xsstring;
    def = "";
    fixed = "";
    use = "optional";
}

Attribute::~Attribute()
{
}

Parameter::Parameter()
{
    type = xsstring;
    maxOccurs = 1;
    minOccurs = 1;
}

Parameter::~Parameter()
{
}

DataAttr::DataAttr()
{
    attr_name = "";
    attr_val = "";
    attr_val_type = t_string;
}

DataAttr::~DataAttr()
{
}

DataUnit::DataUnit()
{
    name = "";
    data = "";
    data_type = t_string;
    attr = new DataAttr();
    unit_type = simple;
}

DataUnit::~DataUnit()
{
}