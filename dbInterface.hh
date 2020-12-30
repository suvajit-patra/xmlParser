# ifndef CLASSES_HH
# define CLASSES_HH
# include "classes.hh"
# endif

//Database access interface
class DbInterface {
    private:
    vector<DataUnit *> result;                                              //query result vector
    int get_result(vector<DataUnit*>, char*);
    public:
    vector<DataUnit*> get_query_result(vector<DataUnit*>, std::string);     //get query
    void print_query_result(vector<DataUnit*>);                             //print the values from the query result
};