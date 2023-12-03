defmodule AdventOfCode.Day03 do
  @moduledoc"""

  WARNING: this is UGLY

  """

  @doc"""
  --- Day 3: Gear Ratios ---
  You and the Elf eventually reach a gondola lift station; he says the gondola lift will take you up to the water source, but this is as far as he can bring you. You go inside.

  It doesn't take long to find the gondolas, but there seems to be a problem: they're not moving.

  "Aaah!"

  You turn around to see a slightly-greasy Elf with a wrench and a look of surprise. "Sorry, I wasn't expecting anyone! The gondola lift isn't working right now; it'll still be a while before I can fix it." You offer to help.

  The engineer explains that an engine part seems to be missing from the engine, but nobody can figure out which one. If you can add up all the part numbers in the engine schematic, it should be easy to work out which part is missing.

  The engine schematic (your puzzle input) consists of a visual representation of the engine. There are lots of numbers and symbols you don't really understand, but apparently any number adjacent to a symbol, even diagonally, is a "part number" and should be included in your sum. (Periods (.) do not count as a symbol.)

  Here is an example engine schematic:

  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  In this schematic, two numbers are not part numbers because they are not adjacent to a symbol: 114 (top right) and 58 (middle right). Every other number is adjacent to a symbol and so is a part number; their sum is 4361.

  Of course, the actual engine schematic is much larger. What is the sum of all of the part numbers in the engine schematic?
  """
  def part1() do
    input = File.read!("./lib/advent_of_code/advent_of_code/day03.input.txt")

    row_count = row_count(input)
    col_count = col_count(input)

    input
    |> number_positions(row_count, col_count)
    |> Enum.filter(&number_is_touching_symbol(input, col_count, &1))
    |> Enum.reduce(0, fn {_row, _col, number}, sum -> sum + number end)
  end

  @doc"""
  --- Part Two ---
  The engineer finds the missing part and installs it in the engine! As the engine springs to life, you jump in the closest gondola, finally ready to ascend to the water source.

  You don't seem to be going very fast, though. Maybe something is still wrong? Fortunately, the gondola has a phone labeled "help", so you pick it up and the engineer answers.

  Before you can explain the situation, she suggests that you look out the window. There stands the engineer, holding a phone in one hand and waving with the other. You're going so slowly that you haven't even left the station. You exit the gondola.

  The missing part wasn't the only issue - one of the gears in the engine is wrong. A gear is any * symbol that is adjacent to exactly two part numbers. Its gear ratio is the result of multiplying those two numbers together.

  This time, you need to find the gear ratio of every gear and add them all up so that the engineer can figure out which gear needs to be replaced.

  Consider the same engine schematic again:

  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  In this schematic, there are two gears. The first is in the top left; it has part numbers 467 and 35, so its gear ratio is 16345. The second gear is in the lower right; its gear ratio is 451490. (The * adjacent to 617 is not a gear because it is only adjacent to one part number.) Adding up all of the gear ratios produces 467835.

  What is the sum of all of the gear ratios in your engine schematic?
  """
  def part2() do
    input = File.read!("./lib/advent_of_code/advent_of_code/day03.input.txt")

    row_count = row_count(input)
    col_count = col_count(input)

    numbers = input |> number_positions(row_count, col_count)
    gears = input |> gear_positions(row_count, col_count)

    gears
    |> Enum.map(&product_of_numbers_adjacent_to_gear(&1, numbers))
    |> Enum.reduce(0, fn product, sum -> product + sum end)
  end

  # returns an integer with how many rows are in the input
  defp row_count(input) do
    input
    |> String.graphemes
    |> Enum.count(& &1 == "\n")
  end

  # returns an integer of how many columns are on the first line,
  # assumes that all lines have the same number of columns
  defp col_count(input) do
    [match] = Regex.run(~r/^.*\n/, input)
    String.length(match) - 1
  end

  # Returns a list of tuples containing number positions in
  # the following formation: {row, col, number}
  defp number_positions(input, row_count, col_count, row \\ 0, col \\ 0, numbers \\ [])
  defp number_positions(_input, row_count, _col_count, row, _col, numbers) when row >= row_count do
    # case: we've read to the end of the input, return the numbers
    numbers
  end
  defp number_positions(input, row_count, col_count, row, col, numbers) when col >= col_count do
    # case: we've read to the end of the line, go to the next
    number_positions(input, row_count, col_count, row + 1, 0, numbers)
  end
  # if there's a number at the specified row / col, then record it into
  # the numbers list and begin processing at the position immediately
  # after the found number
  defp number_positions(input, row_count, col_count, row, col, numbers) do
    case number_at_position(input, row, col, col_count) do
      nil -> number_positions(input, row_count, col_count, row, col + 1, numbers)
      number -> number_positions(input, row_count, col_count, row, col + digit_count(number), [{row, col, number} | numbers])
    end
  end

  # returns the complete number located at a specific row/col coordinate
  # regardless of its size
  defp number_at_position(input, row, col, col_count, digits \\ [])
  defp number_at_position(_input, _row, col, col_count, digits) when col >= col_count do
    # case: reached the end of the row, return the value so far
    list_to_integer_or_nil(digits)
  end
  defp number_at_position(input, row, col, col_count, digits) do
    # case: for each position, check for a digit, if one is found
    #       add it to the digits list and continue with the next
    character = String.at(input, (row*(col_count+1)) + col)

    case Integer.parse(character) do
      # if this character isn't a number, then return the set
      # of digits as an integer, or as nil if empty
      :error -> list_to_integer_or_nil(digits)
      # if the character is a number, then add it to the BEGINNING
      # of the set of digits and continue to the next iteration
      _ -> number_at_position(input, row, col + 1, col_count, [character | digits])
    end
  end

  # returns true if the number (specified by {row, col, number})
  # is touching any non-period symbol
  defp number_is_touching_symbol(input, col_count, {row, col, number}) do
    number_of_symbols = surrounding_characters(input, col_count, row, col, digit_count(number))
    |> String.replace(".", "")
    |> String.length

    number_of_symbols > 0
  end

  # return all of the characters surrounding a space  of specified
  # length at the specified row / column
  defp surrounding_characters(input, col_count, row, col, digit_count) do
    # above
    substring(input, col_count, row - 1, col - 1, digit_count + 2) <>
    # left
    substring(input, col_count, row, col - 1, 1) <>
    # right
    substring(input, col_count, row, col + digit_count, 1) <>
    # below
    substring(input, col_count, row + 1, col - 1, digit_count + 2)
  end

  # captures the substring handling negative values and values
  # larger than the maximum correctly
  defp substring(_input, _col_count, row, _col, _length) when row < 0 do
    # case: if we try to read a row that doesn't exist return an empty string
    ""
  end
  defp substring(input, col_count, row, col, length) when col < 0 do
    # case: when trying to read too far to the left, start at zero
    #       instead and read fewer characters
    substring(input, col_count, row, 0, length + col)
  end
  defp substring(input, col_count, row, col, length) when col + length > col_count do
    # case: when trying to read off the right end of a row, past the
    #       maximum column, instead reduce the length to read until
    #       it doesn't run over the edge
    difference = col + length - col_count
    substring(input, col_count, row, col, length - difference)
  end
  defp substring(input, col_count, row, col, length) do
    # case: no edge case, just read
    # col_count + 1 to account for newline characters
    String.slice(input, row*(col_count+1) + col, length)
  end

  # returns an integer count of the digits in a number
  defp digit_count(number) do
    number
    |> Integer.digits
    |> length
  end

  # convert a list like ["1", "4", "5"] to the integer 145
  # -or- nil if the list is empty
  defp list_to_integer_or_nil(number_string_list) when length(number_string_list) == 0 do
    nil
  end
  defp list_to_integer_or_nil(number_string_list) do
    number_string_list
    |> Enum.join
    |> String.reverse
    |> String.to_integer
  end

  # -- part 2

  # Returns a list of tuples containing gear positions in
  # the following formation: {row, col}
  defp gear_positions(input, row_count, col_count, row \\ 0, col \\ 0, gears \\ [])
  defp gear_positions(_input, row_count, _col_count, row, _col, gears) when row >= row_count do
    # case: we've read to the end of the input, return the gears
    gears
  end
  defp gear_positions(input, row_count, col_count, row, col, gears) when col >= col_count do
    # case: we've read to the end of the line, go to the next
    gear_positions(input, row_count, col_count, row + 1, 0, gears)
  end
  defp gear_positions(input, row_count, col_count, row, col, gears) do
    character = String.at(input, (row*(col_count+1)) + col)

    case character do
      "*" -> gear_positions(input, row_count, col_count, row, col + 1, [{row, col} | gears])
      _ -> gear_positions(input, row_count, col_count, row, col + 1, gears)
    end
  end

  # calculate the product of all numbers adjacent to
  # the specified gear
  defp product_of_numbers_adjacent_to_gear(gear, numbers) do
    adjacent_numbers = numbers_adjacent_to_gear(gear, numbers)

    case Enum.count(adjacent_numbers) do
      2 -> adjacent_numbers |> Enum.reduce(1, fn {_, _, number}, product -> product * number end)
      _ -> 0
    end
  end

  # get all numbers adjacent to the specified gear
  defp numbers_adjacent_to_gear(gear, numbers) do
    numbers
    |> Enum.filter(&number_is_adjacent_to_gear(&1, gear))
  end

  # AABB collision detection, padding the collider by 1
  defp number_is_adjacent_to_gear({number_row, number_col, number}, {gear_row, gear_col}) do
    left_of_number = number_col
    right_of_number = number_col + digit_count(number) - 1

    number_row >= gear_row - 1 and number_row <= gear_row + 1 and
    gear_col >= left_of_number - 1 and gear_col <= right_of_number + 1
  end
end
