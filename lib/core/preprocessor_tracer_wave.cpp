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

#include <metashell/preprocessor_trace_builder.hpp>
#include <metashell/preprocessor_tracer_wave.hpp>

namespace metashell
{
  preprocessor_tracer_wave::preprocessor_tracer_wave(data::wave_config config_)
    : _config(std::move(config_))
  {
  }

  data::metaprogram
  preprocessor_tracer_wave::eval(iface::environment& env_,
                                 const boost::optional<data::cpp_code>& exp_,
                                 data::metaprogram::mode_t mode_)
  {
    return preprocessor_trace_builder(env_.get(), exp_, mode_).build(_config);
  }
}