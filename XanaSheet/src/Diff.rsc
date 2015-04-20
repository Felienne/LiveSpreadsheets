module Diff

data Delta
  = insertRow(int row)
  | insertColumn(int col)
  | deleteRow(int row)
  | deleteColumn(int row)
  | updateCell(int row, int col)
  ;