
/*
 A demo (Live text) Ted  */
  
table marks = #  A / B            / C    / D               / E          
              1:   | Lab          | Exam | Avg             | Grade      
              2:   | 7            | 7    | = (B2 + C2) / 2 | = round(D2)
              3:   | 6            | 7    | = (B3 + C3) / 2 | = round(D3)
              4:   | 6            | 7    | = (B4 + C4) / 2 | = round(D4)
              5:   | 9            | 10   | = (B5 + C5) / 2 | = round(D5)
              6:   | = sum(B1:B5) |      |                 |.
 

test marks E2 * 2 == B2 + C2

repl for marks
> A2 + B2.
=> 7.0
>B2 + B2.
=> 7.0
>B5 * C5.
=> 90.
>round(B2/3).
=> 2.
>B2/3.
=> 2.333333333
>
