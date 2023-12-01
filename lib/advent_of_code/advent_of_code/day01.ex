defmodule AdventOfCode.Day01 do

  def part1() do
    File.stream!("./lib/advent_of_code/advent_of_code/day01.input.txt")
    |> Enum.map(&sum_outside_numbers/1)
    |> Enum.reduce(0,
      fn num_string, sum -> sum + String.to_integer(num_string) end
    )
  end

  def part2() do
    File.stream!("./lib/advent_of_code/advent_of_code/day01.input.txt")
    |> Enum.map(&number_strings_to_digits/1)
    |> Enum.map(&sum_outside_numbers/1)
    |> Enum.reduce(0,
      fn num_string, sum -> sum + String.to_integer(num_string) end
    )
  end

  defp sum_outside_numbers(line) do
    first_digit = List.first(Regex.run(~r/(\d)/, line))
    last_digit = List.first(Regex.run(~r/(\d)/, String.reverse(line)))
    first_digit <> last_digit
  end

  defp number_strings_to_digits(line) do
    replacement_map = %{
      one: "1",
      two: "2",
      three: "3",
      four: "4",
      five: "5",
      six: "6",
      seven: "7",
      eight: "8",
      nine: "9"
    }

    String.replace(
      line,
      Map.keys(replacement_map)
      |> Enum.map(&Atom.to_string/1),
      fn number_string -> replacement_map[String.to_atom(number_string)]
      end
    )
  end
end
