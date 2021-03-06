module Priorities

// To be moved to standard library eventually.

import Grammar;
import Node;
import lang::rascal::grammar::definition::Priorities;
import IO;
import List;
import XanaSyntax;

// NB () are required around #Module; otherwise ambiguous code error.
DoNotNest myPrios() = doNotNest(grammar({}, (#Expr).definitions));

DoNotNest PRIOS = myPrios();

&T parens(node parent, node kid, &T x,  &T(&T x) parenizer) 
  = parens(PRIOS, parent, kid, x, parenizer);
  
public &T parens(DoNotNest prios, node parent, node kid, &T x,  &T(&T x) parenizer) = parenizer(x)
  when 
     <pprod, pos, kprod> <- prios,
     pprod.def has name,
     kprod.def has name, 
     pprod.def.name == getName(parent), 
     kprod.def.name == getName(kid),
     parent[astPosition(pos, pprod)] == kid;

private int astPosition(int pos, Production p)
  = ( -1 | it + 1 | i <- [0..pos+1], isASTsymbol(p.symbols[i]) );

public bool isASTsymbol(\layouts(_)) = false; 
public bool isASTsymbol(\keywords(str name)) = false;
public bool isASTsymbol(\lit(str string)) = false;
public bool isASTsymbol(\cilit(str string)) = false;
public bool isASTsymbol(\conditional(_, _)) = false;
public bool isASTsymbol(\empty()) = false;
public default bool isASTsymbol(Symbol _) = true;

public default &T parens(DoNotNest prios, node parent, node kid, &T x,  &T(&T x) parenizer) = x;
