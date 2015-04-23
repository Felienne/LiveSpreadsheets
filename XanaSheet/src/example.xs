
/*
 This is a test.
 */
      
table bar   = 
  #  A    / B / C
  1: = B1 | 4 | 2 .      
  
view bar = 
  #  A  / B / C
  1: 4. | 4 | 2.


   
  
table grades = 
  #  A   / B    / C               / D          
  1: Lab | Exam | Avg             | Grade      
  2: 7   | 7    | = (A2 + B2) / 3 | = round(C2)
  3: 3   | 6    | = (A3 + B3) / 2 | = round(C3)
  4: 9   | 10   | = (A4 + B4) / 2 | = round(C4).
 
test grades A2 + B2 == 14 
 
repl for grades
> A2 + B2.
=> 13
> A2 * B2.
=> 42.
>A2 * B2.
=> 42.
> 32.
=> 32.
> 
  
 
view grades = 
  #  A   / B    / C           / D    
  1: Lab | Exam | Avg         | Grade
  2: 7   | 7    | 4.666666667 | 5.   
  3: 3   | 6    | 4.5         | 5.   
  4: 9   | 10   | 9.5         | 10..        

