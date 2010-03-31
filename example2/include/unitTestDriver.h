/*
 * unitTestDriver.h
 *
 *  Created on: Jan 20, 2010
 *      Author: omueller
 */

#ifndef UNITTESTDRIVER_H_
#define UNITTESTDRIVER_H_

#include "RemoteTestRunner.h"
#include "cppunit/ui/text/TestRunner.h"
#include "cppunit/XmlOutputter.h"
#include <fstream>
#include <iostream>


namespace unitTest
{
typedef CppUnit::TextUi::TestRunner TextTestRunner;

struct XmlOutputScope
{
	XmlOutputScope(std::string& fileName, TextTestRunner& r) : fOutputFile(fileName.c_str(), std::ios::app)
	{
		CppUnit::XmlOutputter* outputter= new CppUnit::XmlOutputter(&r.result(), fOutputFile);
		r.setOutputter(outputter);
	}
	~XmlOutputScope()
	{
		fOutputFile.flush();
		fOutputFile.close();
	}

	std::ofstream fOutputFile;
};
void internalRunTests(TextTestRunner& r, CppUnit::Test& suite)
{
	r.addTest(&suite);
	r.run();
}

void internalRunTestsXml(TextTestRunner& r, CppUnit::Test& suite, std::string& out)
{
	XmlOutputScope s(out, r);
	r.addTest(&suite);
	r.run();
}

void runUnitTests(int n,char *args[])
{
  std::cout << "runnig unit tests..." << std::endl;
	std::string xml;
	bool debugMode = false;
	bool xmlEnabled = false;
	for (int i = 0; i < n; i++)
	{
		std::string arg(args[i]);
		std::string xmlOption("-xml=");
		int pos = arg.find(xmlOption);
		if (pos > -1)
		{
			xml = arg.substr(pos + xmlOption.length(), arg.length());
			xmlEnabled = true;
		}
		std::string debugOption("-debug");
		pos = arg.find(debugOption);
		if (pos > -1)
		{
			debugMode = true;
		}
	}
//start test server
	RemoteTestRunner* testRunServer = new RemoteTestRunner();
	testRunServer->init(n,args);
	testRunServer->run();
	//start test runner
	TextTestRunner* r = new TextTestRunner();
	CppUnit::TestFactoryRegistry& registry = CppUnit::TestFactoryRegistry::getRegistry();
	CppUnit::Test* suite = registry.makeTest();
	xmlEnabled ? internalRunTestsXml(*r, *suite, xml) : internalRunTests(*r, *suite);
}
} // namespace unitTest

#endif /* UNITTESTDRIVER_H_ */
