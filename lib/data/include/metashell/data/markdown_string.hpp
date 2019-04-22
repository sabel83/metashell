#ifndef METASHELL_DATA_MARKDOWN_STRING_HPP
#define METASHELL_DATA_MARKDOWN_STRING_HPP

// Metashell - Interactive C++ template metaprogramming shell
// Copyright (C) 2017, Abel Sinkovics (abel@sinkovics.hu)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <metashell/data/string.hpp>

#include <vector>

namespace metashell
{
  namespace data
  {
    class markdown_string : string<markdown_string>
    {
    public:
      using string<markdown_string>::string;
      using string<markdown_string>::value;
    };

    markdown_string italics(const markdown_string& md_);

    markdown_string make_id(const std::string& value_);
    markdown_string self_reference(const std::string& value_);
    markdown_string self_id(const std::string& value_);

    void format_table(const std::vector<markdown_string>& header_,
                      const std::vector<std::vector<markdown_string>>& table_,
                      std::ostream& out_);

    std::string unformat(const markdown_string& s_);
  }
}

#endif
