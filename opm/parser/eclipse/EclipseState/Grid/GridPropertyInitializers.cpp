#include <algorithm>
#include <limits>
#include <vector>

#include <opm/parser/eclipse/Deck/Deck.hpp>
#include <opm/parser/eclipse/EclipseState/EclipseState.hpp>
#include <opm/parser/eclipse/EclipseState/Grid/EclipseGrid.hpp>
#include <opm/parser/eclipse/EclipseState/Grid/GridProperty.hpp>
#include <opm/parser/eclipse/EclipseState/Grid/GridPropertyInitializers.hpp>
#include <opm/parser/eclipse/EclipseState/Tables/RtempvdTable.hpp>
#include <opm/parser/eclipse/EclipseState/Tables/TableManager.hpp>

namespace Opm {

    template< typename T >
    void GridPropertyConstantInitializer< T >::apply(std::vector< T >& values) const {
        std::fill(values.begin(), values.end(), m_value);
    }

    void GridPropertyTemperatureLookupInitializer::apply(std::vector<double>& values) const
    {
        if (!m_deck.hasKeyword("EQLNUM")) {
            // if values are defaulted in the TEMPI keyword, but no
            // EQLNUM is specified, you will get NaNs...
            double nan = std::numeric_limits<double>::quiet_NaN();
            std::fill(values.begin(), values.end(), nan);
            return;
        }

        auto tables = m_eclipseState.getTableManager();
        auto eclipseGrid = m_eclipseState.getEclipseGrid();
        const TableContainer& rtempvdTables = tables->getRtempvdTables();
        const std::vector<int>& eqlNum = m_eclipseState.getIntGridProperty("EQLNUM")->getData();

        for (size_t cellIdx = 0; cellIdx < eqlNum.size(); ++ cellIdx) {
            int cellEquilNum = eqlNum[cellIdx];
            const RtempvdTable& rtempvdTable = rtempvdTables.getTable<RtempvdTable>(cellEquilNum);
            double cellDepth = std::get<2>(eclipseGrid->getCellCenter(cellIdx));
            values[cellIdx] = rtempvdTable.evaluate("Temperature", cellDepth);
        }
    }
}

template class Opm::GridPropertyConstantInitializer< int >;
template class Opm::GridPropertyConstantInitializer< double >;

template class Opm::GridPropertyBaseInitializer< int >;
template class Opm::GridPropertyBaseInitializer< double >;
template class Opm::GridPropertyBasePostProcessor< int >;
template class Opm::GridPropertyBasePostProcessor< double >;
