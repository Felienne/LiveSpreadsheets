module XanaSyntax

//extend std::lang::Layout;
//extend std::lang::Id;
import IO;

/*
Angle
- direct manipulation is not at odds with textual syntax.

Todo:
- c and <, > for copy and paste (happens on closing >); this does tracking
   --> highlight it specially!
   --> c's stay on, unless deleted, or non-contiguous c is started.
   --> (Does it have to be contiguous?)
- headers (only identifiers there, or nothing)
- + and - in header cells to add (pre/post) or delete columns
  --> this is essential, you now cannot delete columns...
- view x -> shows the computed table inline
- links: from view to formula cell
- checks: names, contiguous use of "c" and balanced < and >
- 
*/

start syntax Sheet
  = sheet: TableDef*
  ;


syntax TableDef
  = def: "table" Id name "=" Table table "." 
  | view: "view" Id name "=" Table table "."
  | emptyView: "view" Id name
  | repl: "repl" "for" Id ctx Repl repl
  | testSuccess: "test" Id ctx Expr lhs "==" Expr rhs
  | testFailed: "test" Id ctx Expr lhs "==" Expr rhs "expected" Expr exp ", got" Expr got
  ;


syntax Repl
  = empty: ^ "\>"
  | command: ^ "\>" Expr cmd "."
  | right result: Repl hist "=\>" Expr result Repl prompt
  ;

syntax Table 
  = table: Header header TableLayout {Row TableLayout}+ rows
  ;

syntax Header
  = header: "#" {CName (RowLayout "/" RowLayout) }+ lst
  ;


syntax Row
  = row: RName rname ":" Cells cells
  ;

syntax RName
  = rname: Int
  | empty:
  | addBefore: "+" RName!addBefore!addAfter
  | addAfter: RName!addBefore!addAfter "+"
  | delete: "-" RName!addBefore!addAfter!delete
  ;

syntax CName
  = @category="Variable" cname: UId name
  | empty:
  | addBefore: "+" CName!addBefore!addAfter
  | addAfter: CName!addAfter!addBefore "+"
  | delete: "-" CName!addAfter!addBefore!delete
  ;


syntax Cells
  = {Cell (RowLayout "|" RowLayout)}+ lst
  ;

layout TableLayout
  = @manual [\ \t\r\n]* [\n\r] [\ \t\r\n]* !>> [\ \t\n\r]
  ;

layout RowLayout
  = @manual [\ \t]* !>> [\ \t]
  ;


syntax Cell
  = @category="Constant" integer: Int
  | @category="Constant" float: Float
  | @category="StringLiteral" string: String
  | @category="StringLiteral" symbol: Id
  | empty:
  | formula: "=" Expr
  | openRect: "[" Cell!openRect!closeRect
  | closeRect:  Cell!closeRect!openRect "]"
  | rect: "[" Cell!rect!closeRect!openRect "]"
  ;
    
  
lexical UId
  = [A-Z]+ !>> [A-Z]
  ;

syntax Ref
  = relCell: UId Int
  | absRow:  UId "$" Int
  | absCol:  "$" UId  Int
  | absCell: "$" UId "$" Int
  ;

syntax Expr
  = ref: Ref ref
  | range: Ref from ":" Ref to // TODO: range should be in ref
  | integer: Int
  | string: String
  | float: Float
  | \true: "true"
  | \false: "false"
  | call: Id "(" {Expr ","}* ")"
  | tableRef: Id "." Ref
  | bracket "(" Expr ")"
  > not: "!" Expr
  > left (
      mul: Expr "*" Expr
    | div: Expr "/" Expr
  )
  > left (
      add: Expr "+" Expr
    | sub: Expr "-" Expr
  )
  > non-assoc (
      lt: Expr "\<" Expr
    | leq: Expr "\<=" Expr
    | gt: Expr "\>" Expr
    | geq: Expr "\>=" Expr
    | eq: Expr "==" Expr
    | neq: Expr "!=" Expr
  )
  > left and: Expr "&&" Expr
  > left or: Expr "||" Expr
  ;
  
keyword Keywords = "true" | "false" ;

lexical String
  = [\"] ![\"\\]* [\"]
  ;


lexical Int
  = [1-9][0-9]* !>> [0-9]
  | [0]
  ;
  
lexical Float
  = [0-9]+ "." [0-9]* !>> [0-9]
  ;

lexical Id
  = ([a-z A-Z 0-9 _] !<< [a-z A-Z][a-z A-Z 0-9 _]* !>> [a-z A-Z 0-9 _]) \ Keywords
  ;

lexical Comment
  = "/*" (![*] | [*] !>> [/])* "*/";

syntax WhitespaceOrComment
  = Whitespace
  | @category="Comment" Comment
  ;

layout Layout
  = WhitespaceOrComment* !>> [\ \t\n\r] !>> "*/"
  ;
  
lexical Whitespace 
  = [\ \t\n\r]
  ; 

  
Row row(Cells cells) {
   i = 0;
   for (_ <- cells.lst) i += 1;
   if (i == 1, c <- cells.lst, c is empty) {
     filter;
   }
   else {
     fail;
   }
}