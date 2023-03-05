defmodule Test.MatrixTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Test.MatrixData
  alias Matrix.SquareMatrix

  # In order to compile the files we need outside of lib, we must explicitly specify the paths where the files we want to compile will be stored
  describe "Matrix creation test: " do
    test "success create" do
      assert %{dimension: dimension, array_elems: matrix} = MatrixData.get_matrix()

      assert %SquareMatrix{} = new_matrix = SquareMatrix.new_matrix(dimension, matrix)
      assert new_matrix.dim == dimension
      assert new_matrix.array_elems == matrix
    end

    test "Error: dimension less then matrix" do
      dimension = 1

      matrix = [
        [1, 2],
        [3, 4]
      ]

      assert {:error, "Not square matrix"} == SquareMatrix.new_matrix(dimension, matrix)
    end

    test "Error: row longer then dimension" do
      dimension = 1

      matrix = [
        [1, 2, 3],
        [3, 4]
      ]

      assert {:error, "Not square matrix"} == SquareMatrix.new_matrix(dimension, matrix)
    end
  end

  describe "Matrix print test: " do
    setup do
      %{dimension: dimension, array_elems: matrix} = MatrixData.get_matrix()
      new_matrix = SquareMatrix.new_matrix(dimension, matrix)

      {:ok, matrix: new_matrix}
    end

    test "success test with normal index", %{matrix: matrix} do
      assert capture_io(fn -> SquareMatrix.print_matrix(matrix) end) == "1\t2\t\n3\t4\t\n"
    end
  end

  describe "Matrix get_row test: " do
    setup %{} do
      %{dimension: dimension, array_elems: matrix} = MatrixData.get_matrix()
      new_matrix = SquareMatrix.new_matrix(dimension, matrix)

      {:ok, matrix: new_matrix}
    end

    test "success test: normal index", %{matrix: matrix} do
      assert {:ok, first_row} = SquareMatrix.get_row(matrix, 0)
      assert first_row === List.first(matrix.array_elems)
    end

    test "error test: bad index", %{matrix: matrix} do
      assert {:error, "There is no row with this index in the matrix"} = SquareMatrix.get_row(matrix, 2)
    end
  end

  describe "Matrix set_row test: " do
    setup %{} do
      %{dimension: dimension, array_elems: matrix} = MatrixData.get_matrix()
      new_matrix = SquareMatrix.new_matrix(dimension, matrix)

      {:ok, matrix: new_matrix}
    end

    test "success test: normal index and normal row", %{matrix: matrix} do
      assert {:ok, [1, 2]} = SquareMatrix.get_row(matrix, 0)
      assert %SquareMatrix{} = new_matrix = SquareMatrix.set_row(matrix, [5, 6], 0)
      assert SquareMatrix.get_row(new_matrix, 0) != SquareMatrix.get_row(matrix, 0)
      assert SquareMatrix.get_row(new_matrix, 0) == {:ok, [5, 6]}
    end

    test "success test (struct won't change): bad index and normal row", %{matrix: matrix} do
      assert {:ok, [1, 2]} = SquareMatrix.get_row(matrix, 0)
      assert %SquareMatrix{} = new_matrix = SquareMatrix.set_row(matrix, [5, 6], 2)
      assert new_matrix == matrix
    end

    @tag current_test: "yes"
    test "error test: normal index and bad row", %{matrix: matrix} do
      assert {:error, "This row does not match the size of the matrix"} = SquareMatrix.set_row(matrix, [5, 6, 7], 0)
    end
  end

  describe "Matrix sort_row test: " do
    setup %{} do
      %{dimension: dimension, array_elems: matrix} = MatrixData.get_not_sort_matrix()
      new_matrix = SquareMatrix.new_matrix(dimension, matrix)

      {:ok, matrix: new_matrix}
    end

    test "success test", %{matrix: matrix} do
      assert {:ok, [2, 1] = row} = SquareMatrix.get_row(matrix, 0)
      assert [1, 2] = SquareMatrix.sort_matrix_row!(row)
    end
  end

  describe "Matrix full sort test: " do
    setup %{} do
      %{dimension: dimension, array_elems: matrix} = MatrixData.get_not_sort_matrix()
      new_matrix = SquareMatrix.new_matrix(dimension, matrix)

      {:ok, matrix: new_matrix}
    end

    test "success test", %{matrix: matrix} do
      assert %SquareMatrix{} = sort_matrix = SquareMatrix.full_sort_matrix(matrix)
      assert sort_matrix.array_elems == [[1, 2], [3, 4]]
    end
  end
end
