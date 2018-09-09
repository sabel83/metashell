// Metashell - Interactive C++ template metaprogramming shell
// Copyright (C) 2015, Andras Kucsma (andras.kucsma@gmail.com)
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

#include <metashell/core/get_file_section.hpp>

#include <gtest/gtest.h>

using namespace metashell;

void indexed_line_assert_equal(const core::indexed_line& a,
                               const core::indexed_line& b)
{
  ASSERT_EQ(a.line_index, b.line_index);
  ASSERT_EQ(a.line, b.line);
}

TEST(get_file_section, empty)
{
  std::string buffer = "";

  auto section = core::get_file_section_from_buffer(buffer, 3, 2);

  ASSERT_EQ(0u, section.size());
}

TEST(get_file_section, one_line)
{
  std::string buffer = "the first line\n";

  auto section = core::get_file_section_from_buffer(buffer, 1, 2);

  ASSERT_EQ(1u, section.size());
  indexed_line_assert_equal({1, "the first line"}, section[0]);
}

TEST(get_file_section, one_line_out_of_bounds)
{
  std::string buffer = "the first line\n";

  auto section = core::get_file_section_from_buffer(buffer, 2, 2);

  ASSERT_EQ(0u, section.size());
}

TEST(get_file_section, one_line_out_of_bounds_zero)
{
  std::string buffer = "the first line\n";

  auto section = core::get_file_section_from_buffer(buffer, 0, 2);

  ASSERT_EQ(0u, section.size());
}

TEST(get_file_section, two_line_1)
{
  std::string buffer = "the first line\nthe second line\n";

  auto section = core::get_file_section_from_buffer(buffer, 1, 2);

  ASSERT_EQ(2u, section.size());
  indexed_line_assert_equal({1, "the first line"}, section[0]);
  indexed_line_assert_equal({2, "the second line"}, section[1]);
}

TEST(get_file_section, two_lines_2)
{
  std::string buffer = "the first line\nthe second line\n";

  auto section = core::get_file_section_from_buffer(buffer, 2, 2);

  ASSERT_EQ(2u, section.size());
  indexed_line_assert_equal({1, "the first line"}, section[0]);
  indexed_line_assert_equal({2, "the second line"}, section[1]);
}

TEST(get_file_section, six_lines_1)
{
  std::string buffer = "the first line\nthe second line\nthird\n4\nfifth\n6";

  auto section = core::get_file_section_from_buffer(buffer, 2, 2);

  ASSERT_EQ(4u, section.size());
  indexed_line_assert_equal({1, "the first line"}, section[0]);
  indexed_line_assert_equal({2, "the second line"}, section[1]);
  indexed_line_assert_equal({3, "third"}, section[2]);
  indexed_line_assert_equal({4, "4"}, section[3]);
}

TEST(get_file_section, six_lines_2)
{
  std::string buffer = "the first line\nthe second line\nthird\n4\nfifth\n6";

  auto section = core::get_file_section_from_buffer(buffer, 3, 2);

  ASSERT_EQ(5u, section.size());
  indexed_line_assert_equal({1, "the first line"}, section[0]);
  indexed_line_assert_equal({2, "the second line"}, section[1]);
  indexed_line_assert_equal({3, "third"}, section[2]);
  indexed_line_assert_equal({4, "4"}, section[3]);
  indexed_line_assert_equal({5, "fifth"}, section[4]);
}

TEST(get_file_section, six_lines_3)
{
  std::string buffer = "the first line\nthe second line\nthird\n4\nfifth\n6";

  auto section = core::get_file_section_from_buffer(buffer, 4, 2);

  ASSERT_EQ(5u, section.size());
  indexed_line_assert_equal({2, "the second line"}, section[0]);
  indexed_line_assert_equal({3, "third"}, section[1]);
  indexed_line_assert_equal({4, "4"}, section[2]);
  indexed_line_assert_equal({5, "fifth"}, section[3]);
  indexed_line_assert_equal({6, "6"}, section[4]);
}

TEST(get_file_section, six_lines_4)
{
  std::string buffer = "the first line\nthe second line\nthird\n4\nfifth\n6";

  auto section = core::get_file_section_from_buffer(buffer, 5, 2);

  ASSERT_EQ(4u, section.size());
  indexed_line_assert_equal({3, "third"}, section[0]);
  indexed_line_assert_equal({4, "4"}, section[1]);
  indexed_line_assert_equal({5, "fifth"}, section[2]);
  indexed_line_assert_equal({6, "6"}, section[3]);
}
