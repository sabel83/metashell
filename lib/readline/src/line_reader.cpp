// Metashell - Interactive C++ template metaprogramming shell
// Copyright (C) 2014, Abel Sinkovics (abel@sinkovics.hu)
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

#include <metashell/readline/line_reader.hpp>

#ifdef USE_EDITLINE
#include <editline/readline.h>
#else
#include <readline/history.h>
#include <readline/readline.h>
#endif

#include <algorithm>
#include <cassert>
#include <functional>
#include <iterator>
#include <set>
#include <string>

namespace metashell
{
  namespace readline
  {
    namespace
    {
      int completion_end = 0;

      data::code_completer completer;

#ifdef _WIN32
      template <class T>
      stdext::checked_array_iterator<T*> array_begin(T* array_, int len_)
      {
        return stdext::checked_array_iterator<T*>(array_, len_);
      }
#else
      template <class T>
      T* array_begin(T* array_, int)
      {
        return array_;
      }
#endif

      int line_length()
      {
#ifdef _WIN32
        return int(wcslen(_el_line_buffer));
#else
        return rl_end;
#endif
      }

      std::string get_edited_text()
      {
        return std::string(rl_line_buffer, rl_line_buffer + line_length());
      }

      void string_literal_workaround(const data::user_input& to_complete_,
                                     std::set<data::user_input>& values_)
      {
        if (values_.size() == 1 &&
            std::count(begin(to_complete_), end(to_complete_), '\"') % 2 == 1)
        {
          const data::user_input& completion = *values_.begin();
          if (!empty(completion) && *(end(completion) - 1) == '\"')
          {
            data::user_input replacement =
                substr(completion, 0, size(completion) - 1);
            values_.clear();
            values_.insert(std::move(replacement));
          }
        }
      }

      char* tab_generator(const char* text_, int state_)
      {
        assert(bool(completer));

        static std::set<data::user_input> values;
        static std::set<data::user_input>::const_iterator pos;

        if (!state_) // init
        {
          const std::string edited_text = get_edited_text();

          const auto eb = edited_text.begin();
          values.clear();
          const data::user_input to_complete{eb, eb + completion_end};
          completer(to_complete, values);
          string_literal_workaround(to_complete, values);
          pos = values.begin();
        }

        if (pos == values.end())
        {
          return nullptr;
        }
        else
        {
          const auto str = text_ + pos->value();
          // readline expects the string to be allocated by malloc
          const auto len = str.size();
          char* s = (char*)malloc(len + 1);
          std::copy(str.begin(), str.end(), array_begin(s, len + 1));
          s[len] = 0;
          ++pos;
          return s;
        }
        return nullptr;
      }

      char** tab_completion(const char* text_, int, int end_)
      {
        completion_end = end_;
        return rl_completion_matches(const_cast<char*>(text_), &tab_generator);
      }

      std::optional<data::user_input>
      read_next_line(const std::string& prompt_,
                     const data::code_completer& completer_)
      {
        completer = completer_;
        rl_attempted_completion_function = tab_completion;
        rl_completion_append_character = '\0';

        if (char* line = ::readline(prompt_.c_str()))
        {
          std::string str(line);

#if defined __FreeBSD__ || defined __OpenBSD__ || defined __APPLE__ ||         \
    defined USE_EDITLINE
          free(line);
#else
          rl_free(line);
#endif
          return data::user_input(str);
        }
        else
        {
          return std::nullopt;
        }
      }
    }

    data::line_reader line_reader(const data::code_completer& completer_)
    {
      return [completer_](const std::string& prompt_) {
        return read_next_line(prompt_ + " ", completer_);
      };
    }
  }
}
