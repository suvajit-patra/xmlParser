## Table of contents

* General Info  [08]
* Run           [17]
* Input         [28]
* Query         [45]

## General Info

    * This is a xml parser that creates a database and accepts query.
    * Only one attribute is supported per element.
    * Attributes supported in the xsd files are name, type, fixed, default and use.
    * Type reference to another element is not permitted in the xsd.
    * Use the DbInterface class to access the database.
    * Input xsd and xml files are given try to follow then or you might get a syntax or semantic error

## Run

    * To make the xmlParser executable 

    $ make

    * To clean derived files

    $ make clean


## Input

    There are 3 ways to give Input (!!!Caution. xml filename must follow xsd filename)

        #1 Parse xsd and xml files without verbose

        $ ./xmlParser input.xsd input.xml

        #2 Parse xsd and xml files and see trace parsing verbose

        $ ./xmlParser -p input.xsd input.xml

        #3 Parse xsd and xml files and see trace scanning verbose

        $ ./xmlParser -s input.xsd input.xml


## Query

    There are 2 types of query you can make

        #1 element query

        .childElementName

        #2 specific element with attribute query

        .childElementName(attribute_value)

    * If query successful then all the results will be shown. 
    * If query results are complex type then those cannot pe printed as strings. 
    * Enter -q to quit the program.

    Query example       (To get results from the below queries you have to use the given xsd and xml files)

        * shiporder.shipto.name
        * shiporder(889923).shipto.name
        * shiporder(889923).orderperson