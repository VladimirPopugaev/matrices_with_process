defmodule Matrix.System do
  alias Matrix.CsvFormatter
  alias Matrix.SquareMatrix

  def start() do
    matr = SquareMatrix.new_matrix(2, [[1, 2], [3, 4]])
    SquareMatrix.print_matrix(matr)

    new_matrix = CsvFormatter.import("matrix.csv")
    SquareMatrix.print_matrix(new_matrix)
  end
end
