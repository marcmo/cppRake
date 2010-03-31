/*
 * testRunnerMain.cpp
 *
 *  Created on: Jan 20, 2010
 *      Author: omueller
 */

#ifdef CPPUNIT_MAIN

#include "unitTestDriver.h"
#include <iostream>

using namespace unitTest;
using namespace std;

int CPPUNIT_MAIN(int n,char *arg[])
{
  cout << "running tests..." << endl;
	runUnitTests(n, arg);
	exit(0);
}

#endif // CPPUNIT_MAIN
