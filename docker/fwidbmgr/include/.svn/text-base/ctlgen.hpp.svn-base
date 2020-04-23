/*
 * ctlgen.h
 *
 *  Created on: 26/mag/2012
 *      Author: buck
 */

#ifndef CTLGEN_H_
#define CTLGEN_H_

/**
 * \file	ctlgen.hpp CTL file generator
 * \brief	Grads control file generator using spirit.karma from boost libraries
 *
 * This generator produces the .ctl file content about the coupled .dat file like
 * for example:
 *
 * <code>
 * DSET /home/meteo/programmi/interpolazione_statistica/oi_fwi/temp/20120111t2m_g.dat<br />
 * TITLE  2m temperature<br />
 * UNDEF  -9999.000<br />
 * XDEF  177 LINEAR 1436301.37500000 1500.00000000000<br />
 * YDEF  174 LINEAR 4916704.50000000 1500.00000000000<br />
 * ZDEF  1 LINEAR 1.000000 1.000000<br />
 * TDEF 24 LINEAR 13:00Z11jan2012 1HR<br />
 * VARS  3<br />
 * xb  0  99  T background field<br />
 * xa  0  99  T analysis field<br />
 * xidi  0  99  integral data influence<br />
 * ENDVARS<br />
 * </code>
 *
 * @see		http://www.boost.org/
 */

//#include <GridField.h>
//#include <Grid.h>

// boost
//#include <boost/spirit/include/qi.hpp>
#include <boost/spirit/include/karma.hpp>
#include <boost/spirit/include/karma_real.hpp>
#include <boost/spirit/include/phoenix_core.hpp>
#include <boost/spirit/include/phoenix_operator.hpp>
//#include <boost/spirit/include/phoenix_object.hpp>
//#include <boost/spirit/include/phoenix_fusion.hpp>
//#include <boost/spirit/include/phoenix_stl.hpp>

//#include <boost/fusion/include/io.hpp>
//#include <boost/fusion/include/std_pair.hpp>
//#include <boost/variant/recursive_variant.hpp>

// adaptors
//#include <boost/fusion/adapted.hpp>
//#include <boost/fusion/include/adapted.hpp>
//#include <boost/fusion/adapted/adt.hpp>
//#include <boost/spirit/include/support_adapt_adt_attributes.hpp>
//#include <boost/fusion/include/adapt_adt.hpp>
#include <boost/fusion/include/support.hpp>
//#include <boost/spirit/include/support_adapt_adt_attributes.hpp>
#include <boost/fusion/include/adapt_struct.hpp>
//#include <boost/fusion/adapted/adt/adapt_adt.hpp>

//#include <boost/type_traits/is_const.hpp>
//#include <boost/type_traits/add_const.hpp>

using namespace boost::spirit::karma;
using namespace boost::fusion;

//BOOST_FUSION_ADAPT_ADT
//(
//	fwi::grid::GridField,
	//(int,                  int,                        obj.getPosition(),  /*obj.setPosition(val)*/)
	//(std::string ,          std::string,                obj.getName(),      /*obj.setName(val)*/)
	//(std::string ,          std::string,                obj.getFieldName(), /*obj.setFieldName(val)*/)
	//(fwi::grid::GridField::GRID_VALUE_TYPE, fwi::grid::GridField::GRID_VALUE_TYPE, obj.getType(),      /*obj.setType(val)*/)
//)

namespace fwi
{
	namespace generators
	{

		/**
		 * \struct	struct fixed_policy
		 * \brief	defines floating-point values fixed-point obj.getType()generator policy
		 * @see		http://www.boost.org/doc/libs/1_41_0/libs/spirit/doc/html/spirit/karma/reference/numeric/real_number.html
		 */
		template<typename Num>
		struct fixed_policy : real_policies<Num>
		{
			static int floatfield(Num n) { return real_policies<Num>::fmtflags::fixed; }
		};

		/**
		 * \typedef	fixed_type
		 * \brief	floating-point fixed-point generator type
		 */
		typedef real_generator<float, fixed_policy<float> > fixed_type;

		/**
		 * \var		fixedgen
		 * \brief	fixed-point generator instance
		 */
		fixed_type const fixedgen = fixed_type();

		/**
		 * \fn		bool generate_dset(OutputIterator sink, Grid<T>& grid)
		 * \brief	GrADS ctl file DSET generator
		 * \param	sink output iterator
		 * \param	grid grid for which DSET will be generated
		 * \return	true on success else false
		 */
		template<typename OutputIterator, typename T>
		bool generate_dset(OutputIterator sink, fwi::grid::Grid<T>& grid)
		{
			using boost::spirit::karma::string;
			using boost::spirit::karma::_1;

			return generate(sink, "DSET " << string[_1 = grid.getExportDatPath()]);
		}

		/**
		 * \fn		bool generate_title(OutputIterator sink, Grid<T>& grid)
		 * \brief	GrADS ctl file TITLE generator
		 * \param	sink output iterator
		 * \param	grid grid for which TITLE will be generated
		 * \return	true on success else false
		 */
		template<typename OutputIterator, typename T>
		bool generate_title(OutputIterator sink, fwi::grid::Grid<T>& grid)
		{
			using boost::spirit::karma::string;
			using boost::spirit::karma::_1;

			return generate(sink, "TITLE " << string[_1 = grid.getTitle()]);
		}

		/**
		 * \fn		bool generate_undef(OutputIterator sink, Grid<T>& grid)
		 * \brief	GrADS ctl file UNDEF generator
		 * \param	sink output iterator
		 * \param	grid grid for which UNDEF will be generated
		 * \return	true on success else false
		 */
		template<typename OutputIterator, typename T>
		bool generate_undef(OutputIterator sink, fwi::grid::Grid<T>& grid)
		{
			using boost::spirit::karma::float_;
			using boost::spirit::karma::_1;

			return generate(sink, "UNDEF " << fixedgen[_1 = grid.getUndefValue()]);
		}

		/**
		 * \fn		bool generate_xdef(OutputIterator sink, Grid<T>& grid)
		 * \brief	GrADS ctl file XDEF generator
		 * \param	sink output iterator
		 * \param	grid grid for which XDEF will be generated
		 * \return	true on success else false
		 */
		template<typename OutputIterator, typename T>
		bool generate_xdef(OutputIterator sink, fwi::grid::Grid<T>& grid)
		{
			using boost::spirit::karma::lit;
			using boost::spirit::karma::int_;
			using boost::spirit::karma::float_;
			using boost::spirit::karma::_1;

			return generate(sink,
					// Begin grammar
					(
						lit("XDEF ") <<
						int_[_1 = grid.getCols()] <<
						lit(" LINEAR ") <<
						fixedgen[_1 = grid.getXStart()] <<
						' ' << fixedgen[_1 = grid.getXStep()]
					)
				);
		}

		/**
		 * \fn		bool generate_ydef(OutputIterator sink, Grid<T>& grid)
		 * \brief	GrADS ctl file YDEF generator
		 * \param	sink output iterator
		 * \param	grid grid for which YDEF will be generated
		 * \return	true on success else false
		 */
		template<typename OutputIterator, typename T>
		bool generate_ydef(OutputIterator sink, fwi::grid::Grid<T>& grid)
		{
			using boost::spirit::karma::lit;
			using boost::spirit::karma::int_;
			using boost::spirit::karma::float_;
			using boost::spirit::karma::_1;

			return generate(sink,
					// Begin grammar
					(
						lit("YDEF ") <<
						int_[_1 = grid.getRows()] <<
						lit(" LINEAR ") <<
						fixedgen[_1 = grid.getYStart()] <<
						' ' << fixedgen[_1 = grid.getYStep()]
					)
				);
		}

		/**
		 * \fn		bool generate_zdef(OutputIterator sink, Grid<T>& grid)
		 * \brief	GrADS ctl file ZDEF generator
		 * \param	sink output iterator
		 * \param	grid grid for which ZDEF will be generated
		 * \return	true on success else false
		 */
		template<typename OutputIterator, typename T>
		bool generate_zdef(OutputIterator sink, fwi::grid::Grid<T>& grid)
		{
			return generate(sink,
						// Begin grammar
						(
							lit("ZDEF  1 LINEAR 1.000000 1.000000")
						)
					);
		}

		/**
		 * \fn		bool generate_tdef(OutputIterator sink, Grid<T>& grid)
		 * \brief	GrADS ctl fiel TDEF generator
		 * \param	sink output iterator
		 * \param	grid grid for which TDEF will be generated
		 */
		template<typename OutputIterator, typename T>
		bool generate_tdef(OutputIterator sink, fwi::grid::Grid<T>& grid)
		{
			using boost::spirit::karma::lit;
			using boost::spirit::karma::int_;
			using boost::spirit::karma::_1;
			using boost::spirit::karma::string;

			return generate(sink,
						// Begin grammar
						// TDEF 24 LINEAR 13:00Z11jan2012 1HR
						(
							lit("TDEF ") << int_[_1 = grid.getTimeBandsNumber()] << lit(" LINEAR 13:00Z") <<
							string[_1 = grid.getGradsDate()] << lit(' ') << string[_1 = grid.getTimeIncrement()]
						)
				);
		}

		/**
		 * \fn		bool generate_vars(OutputIterator sink, GridFields& grid)
		 * \brief	GrADS ctl file VARS generator
		 * \param	sink output iterator
		 * \param	fields grid fields for which VARS will be generated
		 * \return	true on success else false
		 */
		template<typename OutputIterator>
		bool generate_vars(OutputIterator sink, fwi::grid::GridFields& fields)
		{
			using boost::spirit::karma::lit;
			using boost::spirit::karma::int_;

			bool result = false;

			result = generate(sink,
							// Begin grammar
							(
								lit("VARS ") << int_[_1 = fields.size()] << lit("\n")
							)
					 );

			result = result && generate(sink, stream %eol, fields);
			result = result && generate(sink,
							// Begin grammar
							(
								lit("\nENDVARS")
							)
					 );

			return result;
		}

	}	// generators namespace

	namespace parsers
	{
		struct MYDATE
		{
			int d;
			int m;
			int y;
		};
	}

}	// fwi namespace

#include <boost/fusion/support.hpp>
#include <boost/type_traits.hpp>

BOOST_FUSION_ADAPT_STRUCT
(
	fwi::parsers::MYDATE,
	//(int, d)
)

#endif /* CTLGEN_H_ */
