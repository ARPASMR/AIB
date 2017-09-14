/*
 * Grid.cpp
 *
 *  Created on: 25/mar/2012
 *      Author: buck
 */

/**
 * \file	Grid.cpp
 * \brief	Grid
 */

using namespace std;

/**
 * \namespace	fwi
 * \brief		main fwidbmgr namespace
 *
 * <h2>Computed indexes</h2>
 * <ul>
 *   <li><em>FFMC</em> - Fine Fuel Moisture Code</li>
 *   <li><em>DMC</em> - Duff Moisture Code</li>
 *   <li><em>DC</em> - Drought Code</li>
 *   <li><em>ISI</em> - Initial Spread Index</li>
 *   <li><em>BUI</em> - Build Up Index</li>
 *   <li><em>FWI</em> - Fire Weather Index</li>
 * </ul>
 * <table>
 *   <tr><th>Index</th><th>Low</th><th>Moderate</th><th>High</th><th>Very high</th><th>Estreme</th></tr>
 *   <tr><td>FFMC</td><td align="center">0 - 81</td><td align="center">81 - 88</td><td align="center">88 - 90.5</td><td align="center">90.5 - 92.5</td><td align="center">92.5+</td></tr>
 *   <tr><td>DMC</td><td align="center">0 - 13</td><td align="center">13 - 28</td><td align="center">28 - 42</td><td align="center">42 - 63</td><td align="center">63+</td></tr>
 *   <tr><td>DC</td><td align="center">0 - 80</td><td align="center">80 - 210</td><td align="center">210 - 274</td><td align="center">274 - 360</td><td align="center">360+</td></tr>
 *   <tr><td>ISI</td><td align="center">0 - 4</td><td align="center">4 - 8</td><td align="center">8 - 11</td><td align="center">11 - 19</td><td align="center">19+</td></tr>
 *   <tr><td>BUI</td><td align="center">0 - 19</td><td align="center">19 - 34</td><td align="center">34 - 54</td><td align="center">54 - 77</td><td align="center">77+</td></tr>
 *   <tr><td>FWI</td><td align="center">0 - 5</td><td align="center">5 - 14</td><td align="center">14 - 21</td><td align="center">21 - 33</td><td align="center">33+</td></tr>
 * </table>
 *
 * <h2>Not computed indexes</h2>
 * <ul>
 *   <li><em>FFDC</em> - Forest Fire Danger Code</li>
 *   <li><em>SFDC</em> - Scrub Fire Danger Code</li>
 *   <li><em>GFDC</em> - Grass Fire Danger Code</li>
 * </ul>
 *
 * <p>
 * <b>FFMC</b> <em>(Fine Fuel Moisture Code)</em> is a numerical rating of the moisture content
 * of surface litter and other cured fine fuels. It shows the relative ease  of
 * ignition and flammability of fine fuels. The moisture content of fine  fuels
 * is very sensitive to the weather.<br />
 * Even a day of rain, or of fine and windy weather, will significantly  affect
 * the FFMC rating.<br />
 * The system uses a time lag of two-thirds of a day to accurately measure  the
 * moisture content in fine fuels.<br />
 * The FFMC rating is on a scale of 0 to 99. Any figure above 70  is high,  and
 * above 90 is extreme.
 * </p>
 * <p>
 * <b>DMC</b> <em>(Duff Moisture Code)</em> is a numerical rating of the average moisture content
 * of loosely compacted organic layers of moderate depth.<br />
 * The code indicates the depth that fire will burn in moderate duff layers  and
 * medium size woody material.<br />
 * Duff layers take longer than surface fuels to dry out but weather  conditions
 * over the past couple of weeks will significantly affect the DMC.<br />
 * The system applies a time lag of 12 days to calculate the DMC.<br />
 * A DMC rating of more than 30 is dry, and above 40 indicates that intensive
 * burning will occur in the duff and medium fuels.<br />
 * Burning off operations should not be carried out when the DMC rating is above
 * 40.
 * </p>
 * <p>
 * <b>DC</b> <em>(Drought Code)</em> is a numerical rating of the moisture content of deep, compact,
 * organic layers.<br />
 * It is a useful indicator of seasonal drought and shows the likelihood of fire
 * involving the deep duff layers and large logs.<br />
 * A long period of dry weather (the system uses 52 days) is needed to dry out these
 * fuels and affect the Drought Code.<br />
 * A DC rating of 200 is high, and 300 or more is extreme indicating that fire will
 * involve deep sub-surface and heavy fuels.<br />
 * Burning off should not be permitted when the DC rating is above 300.
 * </p>
 * <p>
 * <b>ISI</b> <em>(Initial Spread Index)</em> indicates the rate fire will spread in its early stages.
 * It is calculated from the FFMC rating and the wind factor.<br />
 * The open-ended ISI scale starts at zero and a rating of 10 indicates high rate of
 * spread shortly after igition.<br />
 * A rating of 16 or more indicates extremely rapid rate of spread.
 * </p>
 * <p>
 * <b>BUI</b> <em>(Build Up Index)</em> index shows the amount of fuel available for combustion,
 * indicating how the fire will develop after initial spread.<br />
 * It is calculated from the Duff Moisture Code and the Drought Code.<br />
 * The BUI scale starts at zero and is open-ended. A rating above 40 is high, above
 * 60 is extreme.
 * </p>
 * <p>
 * <b>FWI</b> <em>(Fire Weather Index)</em> Information from the ISI and BUI is combined to provide
 * a numerical rating of fire intensity - the Fire Weather Index.<br />
 * The FWI indicates the likely intensity of a fire. The FWI is divided into four
 * fire danger classes: Low 0 - 7 Moderate 8 - 16 High l7 - 31 Extreme 32+<br />
 * </p>
 * <p>
 * <b>FFDC</b> <em>(Forest Fire Danger Code)</em> Based on predicted generated "fire intensity (kw/m?)"
 * in forest type vegetation (pine, beech).<br />
 * This code denotes how difficult it would be to control a fire in this vegetation
 * type should one start. (Low, Moderate, High, Very High, Extreme)<br />
 * </p>
 * <p>
 * <b>SFDC</b> <em>(Scrub Fire Danger Code)</em> Based on predicted generated "fire intensity (kw/m?)"
 * in scrub type vegetation (manuka, gorse, broom).<br />
 * This code denotes how difficult it would be to control a fire in this vegetation
 * type should one start. (Low, Moderate, High, Very High, Extreme)<br />
 * </p>
 * <p>
 * <b>GFDC</b> <em>(Grass Fire Danger Code)</em> Based on predicted generated "fire intensity (kw/m?)"
 * in grass type vegetation (dry grass, tussock).<br />
 * This code denotes how difficult it would be to control a fire in this vegetation
 * type should one start. (Low, Moderate, High, Very High, Extreme)<br />
 * </p>
 */
namespace fwi
{
	/**
	 * \namespace	grid
	 * \brief		Contains all grid related classes.
	 */
	namespace grid
	{

	}	// namespace grid
}	// namespace fwi
