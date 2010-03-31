#include "cppunit/extensions/HelperMacros.h"

class ConfigurationManagerTest : public CppUnit::TestFixture
{
public:

	enum { HISTORY_BUFFER_SIZE = 8 };
	enum { PLAIN_BLOCK_SIZE = 1 };
	enum { PLAIN_BLOCK_WITH_CRC_SIZE = 1 };

	ConfigurationManagerTest()
	{}

	void setUp()
	{
	}

	void tearDown()
	{
	}

	void testLengthOfRegularBlock()
	{
		CPPUNIT_ASSERT_EQUAL(5, 4);
	}

	CPPUNIT_TEST_SUITE( ConfigurationManagerTest );
		CPPUNIT_TEST( testLengthOfRegularBlock );
	CPPUNIT_TEST_SUITE_END();

};

CPPUNIT_TEST_SUITE_REGISTRATION(ConfigurationManagerTest);
