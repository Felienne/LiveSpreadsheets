---
title: | 
   E Pluribus Unum: Direct Manipulation of Implicit Abstractions through Copy-Paste Tracking in Spreadsheets
author:
  - name: Felienne Hermans
    affiliation: Delft University of Technology
    email: f.f.j.hermans@tudelft.nl
  - name: Tijs van der Storm
    affiliation: Centrum Wiskunde & Informatica
    email: storm@cwi.nl
abstract: |
  TBD
  TBD
  TBD
fontsize: 11pt
geometry: margin=2cm
fontfamily: libertine
fontfamily: inconsolata
mainfont: Linux Libertine O
monofont: Inconsolata
bibliography: references.bib
...

# Introduction

<!--
XanaSheet: Fixing Spreadsheets without Breaking Them
Copy-Paste Tracking in Spreadsheets: Supporting Reuse without Compromising Directness
Copy-Paste Tracking in Spreadsheets: Single Point of Change without Abstraction
Copy-Paste Tracking in Spreadsheets: Once and Only Once without Abstraction
E Pluribus Unum: Direct Manipulation of Implicit Abstractions through Copy-Paste Tracking.
One clone to rule them all.
E Pluribus Unum: Many-to-One Direct Manipulation in Spreadsheets
-->
 

Spreadsheet systems can easily be considered the most successful form of programming. Winston [@Wins2001] estimates that 90% of all analysts in industry perform calculations in spreadsheets. Spreadsheet users perform a range of diverse tasks with spreadsheets, from inventory administration to educational applications and from scientific modelling to financial systems. The financial business is a domain where spreadsheets are especially prevailing. Panko[@Pank2006] estimates that 95% of U.S. firms, and 80% in Europe, use spreadsheets in some form for financial reporting.

Spreadsheets are formally defined as a collection of worksheets, which in turn can contain cells. These cells can contain values, like numbers or text, or formulas, with calculations and cell references. In addition to these basic operations, many spreadsheet systems also allow users to create charts, graphs and pivot tables. When a user enters or updates a formula, the result is immediately shown to the user. Also, all cells depending on the changed formula are updated immediately. 

Researchers have  argued that the _liveness_ characteristics of spreadsheets have contributed to the widespread success of spreadsheets [@thesisFelienne] and we know from interviews with users that liveness is important to them. They often start building a spreadsheet with the end goal in mind, and manipulate the formulas until the obtain the result they want.

The liveness characteristics of spreadsheets can be divided in two categories:

- Direct manipulation: instead of editing a separate plan or program to achieve some result, the spreadsheet user edits the "thing itself": there is almost no distinction between the actual data and the "code" of a spreadsheet. This feature addresses the "gulf of execution" which exists between a goal, and the steps that need to be executed to achieve that goal [@Malo95] [@LiebermanFry1995].

- Immediate feedback: after a change to the spreadsheet data or formulas, the user can immediately observe the effect of the edit. This feature bridges the "gulf of evaluation"which exists between performing an action and receiving feedback on the success of that action [@LiebermanFry1995].



<!--
Problem: spreadsheets are notoriously error-prone (fault-prone?) \cite{.....}
Reason (?): copy-paste is the only mechanism for reuse/sharing behavior/functionality
-->

Despite these attractive features for end-users, spreadsheets are well-known to be extremely fault-prone [@Pank2006]. There are numerous _horror stories_ known in which organizations lost money or credibility because of spreadsheet mistakes. TransAlta for example lost US $24 Million in 2003 because of a copy-paste error in a spreadsheet [@Tran2003]. More recently, the Federal Reserve made a copy-paste error in their consumer credit statement which, although they did not make an official statement about the impact, could have led to a difference of US $4 billion [@Fede2010]. These stories, while single instances of copy-paste problems in spreadsheets do, give credibility to the hypothesis  that copy-paste errors in spreadsheets can greatly impact spreadsheet quality. 

This copy-pasting as in the stories above is not always done my mistake. Rather, we see spreadsheet users using copy-pasting as a deliberate technique. This is understandable, as standard spreadsheets do not support any form of data schema or meta model, so there is no way in which a new worksheet in a spreadsheet could inherit or reuse the model of an existing worksheet. Copy-paste is then often used to compensate for for the lack of code abstractions [@Herm2013]. Finally, when faced with spreadsheets they do not know, users are often afraid to modify existing formulas, thus copy-paste them and add new functionality [@Herm2013] creating many versions of similar formulas, of which the origin can no longer be determined.

<!-- should emphasize the copying here... --->

Existing research has focused on  improving spreadsheets in this direction. An example of this is the work of Abraham _et al._ , who have developed a system called ClassSheets [@Abra2005] [@Enge2005] with which the structure of a spreadsheet can be described separately. The actual spreadsheet can then be guaranteed to conform to the meta description. 
<!-- TODO: MDSheet -->
Another direction is enriching spreadsheets with user-defined functions (UDFs) [@Jone2003]. In this case, spreadsheets users can factor out common computations into separate cells, and refer to them from elsewhere in the spreadsheet.

Although these features improve the reliability of spreadsheet use, they have one important drawback, namely, that they break the "direct manipulation" aspect of spreadsheets. In a sense, separate meta models, or user defined abstractions, create distance between the actual thing (data + formulas), and its behavior. Instead of just looking at the cells, the user now has to look at at least two places: the cells containing the data and the the separate definitions of the abstractions (meta model and/or user defined functions). 


In this paper we introduce a different approach based on tracking copy-paste actions on formulas and transforming edits on copies ("clones") back to the original.
So, instead of introducing another level of indirection using abstraction, our technique supports single-point-of-change by allowing users to edit equivalence classes of formulas, all at once. 
In a sense, the abstraction, or user defined function, is there, but it never becomes explicit. 
Nevertheless, this technique eliminates a large class of copy-paste bugs, without at the same time comprimising the direct manipulation of formulas in cells.




<!--
Without making the abstractions "concrete" as it were, we see the ranges for formulas as "materialization" of "platonic" (?) abstractions.
The way to do this is tracking copying relations (origin tracking).
Whenever a copy of a formula is edited, the original and all other copies are updated as well.
As a result, we conjecture, it is possible to have our cake and eat it too, and fix spreadsheets without breaking them.

-->


# Copy-Paste Tracking in Action


![*Maintaining consistency among clones of formulas through copy-paste tracking*](images/grades.png)

Figure 1 shows an example user interaction with a spreadsheet containing student grades.
In the first step  the sheet contains just the Lab and Exam grades of three students, and a formula for computing the average of the two grades in D2.
In the second step, the formula in cell D2 is copied to D3 and D4.
D3 and D4 are clones of D2, and this relation is maintained by the system as an origin relation (visualized using the arrow). 
In the third step, the clone in D4 is modified to apply rounding to the computed average. 
Unlike in normal spreadsheets, however, this is not the end of the story
and the system will reconcile the  original formula of D2 and the other clone in D3 with the changes in D4. 

A way to understand what is happening here, is to see spreadsheet formulas as materialized or unfolded abstractions.
The abstraction in Fig. 1  is function `average(x,y)` for computing the average of two grades. 
In ordinary programming such a function could, for instance, be mapped over a list of pairs of grades to obtain a list of averages, like `map(average, zip(Lab, Exam))`.
In the spreadsheet of Fig. 1, however, the abstraction `average` does not really exist, but is represented collectively by the set of all its inlined applications, e.g. `[(Lab[0]+Exam[0])/ 2, (Lab[1]+Exam[1])/2, (Lab[2]+Exam[2])/2]`.
In a  sense, each application is a clone of the same implicit prototype, with parameters filled in with concrete data references.
The tracking relation induced by copy-paste actions, identifies which clones belong to the same equivalence class.
Therefore, editing one clone triggers updating the clones which belong to  the same  class.



# Semantics of Copy-Paste Tracking

We've developed an executable semantics for experimenting with copy-paste tracking.
It can be used to simulate interactive editing sessions with a spreadsheet [^1]. 
For instance, the following script is used to build the initial sheet of Fig. 1:

~~~~
  putData(<0, 0>, 6.0), putData(<0, 1>, 9.0), putData(<0, 2>, 5.0), // enter the data
  putData(<1, 0>, 9.5), putData(<1, 1>, 7.0), putData(<1, 2>, 3.5),
  putFormula(<2, 0>, div(add(ref(-2, 0), ref(-1, 0)), lit(2.0))) // add the formula
~~~~ 

The `put` actions are anchored at absolute, zero-based coordinates $\langle column, row\rangle$.
Formula expressions are written in prefix notation. 
Addition is represented by the `add` constructor, division by `div`, and literals by `lit`. 
The `ref` expression is a relative cell reference, where the numbers indicate column and row offsets from the current cell, respectively. 

To model copy-paste tracking, `copy` actions are explicitly modeled.
For instance, the following two actions copy the formula for computing the average in D2 down to D3 and D4[^2]: 

~~~~
  copy(<2, 0>, <2, 1>), copy(<2, 0>, <2, 2>)`
~~~~  
  
The `copy` actions also populate the origin relation $Org$, which is a relation between absolute cell addresses:  
$Org = \{\langle \langle 2,2\rangle,\langle 2,0\rangle\rangle,\langle \langle 2,1\rangle,\langle 2,0\rangle\rangle\}$.
In this case, the relation states that the formulas in cell $\langle 2,2\rangle$ and cell $\langle 2, 1\rangle$ both originate from  cell $\langle 2,0\rangle$.

In the third step of Fig. 1, the formula is updated in the bottom row to add rounding of the average grade. 
This is modeled again using a `putFormula` action: 

~~~~
  putFormula(<2, 2>, round(div(add(ref(-2, 0), ref(-1, 0)), lit(2.0))))`.
~~~~

Since this update is applied to a cell containing a formula clone, the origin relation is used to find all cells which are in the same equivalence class as the current one.
The equivalence class of a cell $c$ is defined as $[c]_{Org} = \{\; c' \;|\; \langle c, c'\rangle \in (Org \cup Org^{-1})^* \;\}$.
That is the set of cells in the equivalence class of $c$ is the right-image under $c$ in the symmetric, transitive, and reflexive closure of the origin relation.
Since all cell references in expressions are relative, the new formula of in the `putFormula` action can be just copied to all cells in the equivalence class. 

Entering data and formulas, and copy-pasting cells are not the only operations in spreadsheets. 
For the purpose of copy-paste tracking, however, the only two other relevant operations are inserting or removing rows and columns. 
In these cases, the origin relation needs to be adjusted as well. 
For instance, when inserting a row  at position $i$, the row components of all the cell addresses on rows $\geq i$ in the origin relation needs to be shifted one down.
Similar adjustments need to be made when inserting a column or deleting a row or column.

Although in this section we have just discussed copy-paste tracking for formulas, the same model could equally well apply to copy-pasting of data as well. In that case, the origin relation helps against inadvertently duplicating input data.

An interesting special case is particularly error-prone "paste as value" operation. 
Instead of copying the formula, this operation copies the result of the formula, thus completely disconnecting the value from its original source.
Tracking such copy-paste actions would probably not be very useful: editing the pasted value would incur computing the inverse of the original formula, and updating the input data accordingly!


[^1]: The semantics is developed in Rascal [@Rascal] and can be found online here: [https://github.com/Felienne/LiveSpreadsheets/tree/master/XanaSheet](https://github.com/Felienne/LiveSpreadsheets/tree/master/XanaSheet)


[^2]: Note that we don't count the header row as an actual row in this formalization.


<!--
# Discussion
Changes user interaction
"Past and match style" "Delete only this event, or all future events?"
-->



# Related Work

Related work for this paper comes in different categories, that we will summarize in this section.

- *Origin tracking*: [@VanDeursenKT93] [@InostrozaVdSE]

- *Transclusion*:  Ted Nelson's concept of _transclusion_ [@Nelson65] is a form of "reference by inclusion" where transcluded data is presented through a "live" view: whenever the target of the reference is updated, the references themselves update as well.
Our origin relation provides a similar hyperlinking between cells. 
But unlike in the case of transclusion, the relation is bidirectional: changes to the original are propagated forward, but changes to copies (references) are also propagated backwards (and then forward again). 

- *Clone tracking* in software: Godfrey and Tu [@Godf2002] proposed a method called _origin analysis_ which is a related to both clone detection and the above described origin tracking, but aims at deciding if a program entity was newly introduced or whether it if it should more accurately be viewed as a renamed, moved, or otherwise changed version of an previously existing entity. This laid the ground for a tool called _CloneTracker_ that "can automatically track clones as the code evolves, notify developers of modifications to clone
regions, and support simultaneous editing of clone regions." [@Dual2007].

- *Prototype-based inheritance* was poineered in the Self language [@Self], and contributed to direct manipulation model of interaction [@Malo95]. In proto-type-based languages, objects are created by cloning and existing object. The cloned object then inherits features (methods, slots) from its prototype. This parent relation between object is similar to our origin relation. However, we are not aware of any related work discussing propagating changes on clones back to the parents. 


# Conclusion

Future work

Empirical evaluation which kind of copy is most used (?)

Inferring origin relations to "migrate".


# References
