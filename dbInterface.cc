#include <iostream>
#include "dbInterface.hh"

vector<DataUnit *> DbInterface::get_query_result(vector<DataUnit *> data_units, std::string query)
{
    char *query_ptr = &query[0];                                            //query_ptr used to access the characters
    result.clear();
    if (get_result(data_units, query_ptr) == -1)
        result.clear();

    return result;
}

int DbInterface::get_result(vector<DataUnit *> data_units, char *query_ptr)
{
    std::string name = "";
    std::string attr = "";
    int query_end = 0;

    while (*query_ptr != '\0' && *query_ptr != '.' && *query_ptr != '(')    //get name value
    {
        name += *query_ptr;
        query_ptr++;
    }

    if (*query_ptr == '(')
    {
        query_ptr++;
        if (*query_ptr == '\0')
        {
            std::cout << "!!!query syntax error" << std::endl;
            return -1;
        }
        while (*query_ptr != '\0' && *query_ptr != '.' && *query_ptr != ')')    //get attribute value
        {
            attr += *query_ptr;
            query_ptr++;
        }
        if (*query_ptr != ')')
        {
            std::cout << "!!!query syntax error" << std::endl;
            return -1;
        }
    }

    if (*query_ptr == ')')
    {
        query_ptr++;
    }

    if (*query_ptr == '.')
    {
        query_ptr++;
    }

    if (*query_ptr == '\0')
    {
        query_end = 1;
    }

    for (auto i = data_units.begin(); i != data_units.end(); ++i)       //iterate over all children
    {
        if ((*i)->name == name && (attr == "" || (*i)->attr->attr_val == attr))
        {
            if (query_end)
                (result).push_back(*i);
            else
                if (get_result((*i)->data_units, query_ptr) == -1)      //recursive call to search query in the children vector
                    break;
        }
    }

    return 0;
}

void DbInterface::print_query_result(vector<DataUnit*> data_units)
{
    int data_count = data_units.size();
    if (data_count == 0)
    {
        std::cout<<"no data found"<<std::endl;
        return;
    }
    
    if ((*data_units.begin())->unit_type == complex)
    {
        std::cout<<"can't print result(Complex type)"<<std::endl;
        return;
    }

    for (auto i = data_units.begin(); i != data_units.end(); ++i)       //if results are simple type then print the values
    {
        std::cout<<"["<<(*i)->data<<"]"<<std::endl;
    }
}