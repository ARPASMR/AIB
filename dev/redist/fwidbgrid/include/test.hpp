#include <boost/fusion/include/adapt_adt.hpp>
#include <boost/fusion/include/adapt_assoc_struct.hpp>

namespace fwi { namespace grid {
		struct test0
		{
			int    i;
			double d;
		};

		class test1
		{
		private:
			int    i;
			double d;
		public:
			int get_i() { return i; }
			double get_d() { return d; }
		};
	}
}

BOOST_FUSION_ADAPT_STRUCT(
		fwi::grid::test0,
		//(int, i)
		//(double, d)
)


BOOST_FUSION_ADAPT_ADT(
	fwi::grid::test1,
	//(int, int, obj.get_i(), /**/)
)
