defmodule Matrix.CsvFormatter do
  @doc """

  It takes as input the name of the file in which the matrix is stored in csv format.
  Retrieves the matrix and turns it into a structure `%Matrix.SquareMatrix{}`

  """
  @spec import(String.t()) :: %Matrix.SquareMatrix{} | {:error, String.t()}
  def import(file_name) do
    file_name
    |> read_lines_from_file()
    |> convert_lines_in_rows()
    |> then(&Matrix.SquareMatrix.new_matrix(length(&1), &1))
  end

  defp read_lines_from_file(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp convert_lines_in_rows(lines_list) do
    Enum.map(lines_list, &convert_string_to_row(&1))
  end

  defp convert_string_to_row(string_row) do
    String.split(string_row, " ")
    |> Enum.map(&String.to_integer/1)
  end
end
