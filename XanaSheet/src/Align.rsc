module Align

import AST;
import List;
import util::Math;
import IO;

@doc{Makes sure all rows and header are of equal length}
Table align(Table t) {
  len = longestRowSize(t);
  t.header.names += [ CName::empty() | _ <- [0..size(t.header.names) - len] ];
  
  t.rows = for (r <- t.rows) {
    r.cells += [ Cell::empty() | _ <- [0..size(r.cells) - len] ];
    append r;
  }
  
  return t;
}

int longestRowSize(Table t)
  = ( size(t.header.names) | max(it, size(r.cells)) | r <- t.rows );


