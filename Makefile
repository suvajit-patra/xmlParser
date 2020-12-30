# This Makefile is designed to be simple and readable.  It does not
# aim at portability.  It requires GNU Make.

BASE = xmlParser
BISON = bison
CXX = g++
FLEX = flex
XSLTPROC = xsltproc
LIBFLAGS=-lm
MAKE = make

main: $(BASE)

%.cc %.hh %.xml %.gv: %.yy
	$(BISON) $(BISONFLAGS) --xml --graph=$*.gv -o $*.cc $<

%.cc: %.ll
	$(FLEX) $(FLEXFLAGS) -o$@ $<

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c -o$@ $<

$(BASE): $(BASE).o xsdParserFiles/xsd_driver.o  xmlParserFiles/xml_driver.o xsdParserFiles/xsd_parser.o xsdParserFiles/xsd_scanner.o xmlParserFiles/xml_parser.o xmlParserFiles/xml_scanner.o classes.o dbInterface.o
	$(CXX) -o $@ $^ $(LIBFLAGS)

$(BASE).o: xsdParserFiles/xsd_parser.hh xmlParserFiles/xml_parser.hh
xsdParserFiles/xsd_parser.o: xsdParserFiles/xsd_parser.hh
xsdParserFiles/xsd_scanner.o: xsdParserFiles/xsd_parser.hh
xmlParserFiles/xml_parser.o: xmlParserFiles/xml_parser.hh
xmlParserFiles/xml_scanner.o: xmlParserFiles/xml_parser.hh

# run: $(BASE)
# 	@echo "Type."
# 	./$<

html: xsdParser.html
%.html: %.xml
	$(XSLTPROC) $(XSLTPROCFLAGS) -o $@ $$($(BISON) --print-datadir)/xslt/xml2xhtml.xsl $<

clean:
	@echo "Cleaning up..."
	rm -f $(BASE) *.o
	cd xsdParserFiles && $(MAKE) clean
	cd xmlParserFiles && $(MAKE) clean
