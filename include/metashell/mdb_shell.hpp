#ifndef METASHELL_MDB_SHELL_HPP
#define METASHELL_MDB_SHELL_HPP

// Metashell - Interactive C++ template metaprogramming shell
// Copyright (C) 2014, Andras Kucsma (andras.kucsma@gmail.com)
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

#include <string>

#include <boost/optional.hpp>
#include <metashell/boost/regex.hpp>

#include <metashell/breakpoint.hpp>
#include <metashell/logger.hpp>
#include <metashell/mdb_command_handler_map.hpp>

#include <metashell/data/metaprogram.hpp>

#include <metashell/iface/call_graph.hpp>
#include <metashell/iface/command_processor.hpp>
#include <metashell/iface/displayer.hpp>
#include <metashell/iface/engine.hpp>
#include <metashell/iface/environment.hpp>
#include <metashell/iface/history.hpp>

namespace metashell
{

  class mdb_shell : public iface::command_processor
  {
  public:
    const mdb_command_handler_map command_handler;

    mdb_shell(iface::environment& env,
              iface::engine& engine_,
              const boost::filesystem::path& env_path_,
              const boost::filesystem::path& mdb_temp_dir_,
              bool _preprocessor,
              logger* logger_);

    virtual std::string prompt() const override;
    virtual bool stopped() const override;

    void display_splash(iface::displayer& displayer_) const;
    virtual void line_available(const std::string& line,
                                iface::displayer& displayer_,
                                iface::history& history_) override;
    void line_available(const std::string& line, iface::displayer& displayer_);
    virtual void cancel_operation() override;

    void command_continue(const std::string& arg, iface::displayer& displayer_);
    void command_finish(const std::string& arg, iface::displayer& displayer_);
    void command_step(const std::string& arg, iface::displayer& displayer_);
    void command_next(const std::string& arg, iface::displayer& displayer_);
    void command_evaluate(const std::string& arg, iface::displayer& displayer_);
    void command_forwardtrace(const std::string& arg,
                              iface::displayer& displayer_);
    void command_backtrace(const std::string& arg,
                           iface::displayer& displayer_);
    void command_frame(const std::string& arg, iface::displayer& displayer_);
    void command_rbreak(const std::string& arg, iface::displayer& displayer_);
    void command_break(const std::string& arg, iface::displayer& displayer_);
    void command_help(const std::string& arg, iface::displayer& displayer_);
    void command_quit(const std::string& arg, iface::displayer& displayer_);

    virtual void code_complete(const std::string& s_,
                               std::set<std::string>& out_) override;

    static mdb_command_handler_map build_command_handler(bool preprocessor_);

  protected:
    bool require_empty_args(const std::string& args,
                            iface::displayer& displayer_) const;
    bool require_evaluated_metaprogram(iface::displayer& displayer_) const;
    bool require_running_metaprogram(iface::displayer& displayer_) const;
    bool
    require_running_or_errored_metaprogram(iface::displayer& displayer_) const;

    bool run_metaprogram_with_templight(
        const boost::optional<data::cpp_code>& expression,
        data::metaprogram::mode_t mode,
        iface::displayer& displayer_);

    void filter_unwrap_vertices();
    void filter_similar_edges();
    void filter_metaprogram();

    static boost::optional<int>
    parse_defaultable_integer(const std::string& arg, int default_value);

    static boost::optional<int> parse_mandatory_integer(const std::string& arg);

    // may return nullptr
    const breakpoint* continue_metaprogram(data::direction_t direction);
    unsigned finish_metaprogram();

    void next_metaprogram(data::direction_t direction, int n);

    void display_frame(const data::frame& frame,
                       iface::displayer& displayer_) const;
    void display_current_frame(iface::displayer& displayer_) const;
    void display_current_forwardtrace(boost::optional<int> max_depth,
                                      iface::displayer& displayer_) const;
    void display_backtrace(iface::displayer& displayer_) const;
    void display_argument_parsing_failed(iface::displayer& displayer_) const;
    void display_metaprogram_reached_the_beginning(
        iface::displayer& displayer_) const;
    void display_metaprogram_finished(iface::displayer& displayer_) const;
    void display_movement_info(bool moved, iface::displayer& displayer_) const;

    iface::environment& env;

    boost::optional<data::metaprogram> mp;

    int next_breakpoint_id = 1;
    breakpoints_t breakpoints;

    std::string prev_line;
    bool last_command_repeatable = false;

    // It is empty if evaluate was called with "-".
    // mp is empty when there were no evaluations at all
    boost::optional<data::cpp_code> last_evaluated_expression;

    bool is_stopped = false;
    logger* _logger;
    iface::engine& _engine;
    boost::filesystem::path _env_path;
    boost::filesystem::path _mdb_temp_dir;

    bool _preprocessor;
  };
}

#endif
