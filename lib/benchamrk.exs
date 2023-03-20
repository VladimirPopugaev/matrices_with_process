alias Test.MatrixData

input = %{
  "small matrix (10x10)" => MatrixData.get_matrix_struct(10),
  "medium matrix (500x500)" => MatrixData.get_matrix_struct(500)
}

Benchee.run(
  %{
    "parallel sort matrix" => fn input -> Matrix.SquareMatrix.async_sort_matrix(input) end,
    "sequential sort matrix" => fn input -> Matrix.SquareMatrix.full_sort_matrix(input) end
  },
  inputs: input,
  time: 60,
  memory_time: 10,
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.Console
  ]
)
