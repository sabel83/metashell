#ifndef METASHELL_PRAGMA_CONFIG_SHOW_HPP
#define METASHELL_PRAGMA_CONFIG_SHOW_HPP

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

#include <metashell/iface/pragma_handler.hpp>

#include <string>

namespace metashell
{
  namespace pragma
  {
    class config_show : public iface::pragma_handler
    {
    public:
      std::string arguments() const override;
      std::string description() const override;

      void run(const data::command::iterator& name_begin_,
               const data::command::iterator& name_end_,
               const data::command::iterator& args_begin_,
               const data::command::iterator& args_end_,
               iface::main_shell& shell_,
               iface::displayer& displayer_) const override;

      void code_complete(data::command::const_iterator,
                         data::command::const_iterator,
                         iface::main_shell&,
                         std::set<data::user_input>&) const override;
    };
  }
}

#endif
