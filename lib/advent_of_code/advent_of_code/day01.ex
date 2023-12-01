defmodule AdventOfCode.Day01 do

  def part1() do
    File.stream!("./lib/advent_of_code/advent_of_code/day01.input.txt")
    |> Enum.map(&sum_outside_numbers/1)
    |> Enum.reduce(
      0,
      fn num_string, sum -> sum + String.to_integer(num_string) end
    )
  end

  def part2() do
    File.stream!("./lib/advent_of_code/advent_of_code/day01.input.txt")
    |> Enum.map(&number_strings_to_digits/1)
    |> Enum.map(&sum_outside_numbers/1)
    |> Enum.reduce(
      0,
      fn num_string, sum -> sum + String.to_integer(num_string) end
    )
  end

  defp sum_outside_numbers(line) do
    first_digit = List.first(
      Regex.run(~r/(\d)/, line)
    )
    last_digit = List.first(
      Regex.run(~r/(\d)/, String.reverse(line))
    )
    first_digit <> last_digit
  end

  defp number_strings_to_digits(line) do
    String.replace(
      line,
      ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"],
      fn number_string ->
        case (number_string) do
          "one" -> "1"
          "two" -> "2"
          "three" -> "3"
          "four" -> "4"
          "five" -> "5"
          "six" -> "6"
          "seven" -> "7"
          "eight" -> "8"
          "nine" -> "9"
        end
      end
    )
  end
end
