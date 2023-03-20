defmodule Test.MatrixData do
  def get_matrix() do
    %{
      dimension: 2,
      array_elems: [
        [1, 2],
        [3, 4]
      ]
    }
  end

  def get_matrix_struct(dim) do
    list = Enum.map(1..dim, fn _x -> Enum.to_list(dim..1) end)

    Matrix.SquareMatrix.new_matrix(dim, list)
  end

  def get_not_sort_matrix do
    %{
      dimension: 2,
      array_elems: [
        [2, 1],
        [4, 3]
      ]
    }
  end
end
