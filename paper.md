---
title: 'Spreadsheets: the original live coding environment. 
Lessons learnt and steps forward.'
author:
  - name: Felienne Hermans
    affiliation: Delft University of Technology
    email: f.f.j.hermans@tudelft.nl
  - name: Tijs van der Storm
    affiliation: Centrum voor Wiskunde en Informatica
    email: storm@cwi.nl
abstract: |
  Replace this text with a 100-250 word abstract. You'll find it in the
  'metadata block' at the top of your markdown document), be sure that
  each line of the abstract is indented.
fontsize: 11pt
geometry: margin=2cm
fontfamily: libertine
fontfamily: inconsolata
mainfont: Linux Libertine O
monofont: Inconsolata
bibliography: references.bib
...

# Introduction

Spreadsheet systems can easily be considered the most succesful form of programming. Winston [@Wins2001] estimates that 90% of all analysts in industry perform calculations in spreadsheets. Spreadsheet users perform a range of diverse tasks with spreadsheets, from inventory administration to educational applications and from scientific modeling to financial systems. The financial business is a domain where spreadsheets are especially prevailing. Panko[@Pank2006] estimates that 95% of U.S. firms, and 80% in Europe, use spreadsheets in some form for financial reporting.

The success of spreadsheets is of course due to many different factors, the ubiquitous Microsoft Office suite within companies provides almost every office worker with a version of Excel, the world's most popular spreadsheet system. However, researchers have also argued that the liveness of spreadsheets has contributed to the widespread success of spreadsheets [@thesisFelienne].

# Live programming in Spreadsheets

Spreadsheets are formally defined as a collection of worksheets, which in turn can contain cells. These cells can contain values, like numbers or text, or formulas, with calculations and cell references. In addition to these basic operations, many spreadsheet systems also allow users to create charts, graphs and pivot tables. When a user enters or updates a formula, the result is immediately shown to the user. Also, all cells depending on the changed formula are updated. 

From interviews with users we know that this _liveness_ is important to users. They often start building a spreadsheet with the end goal in mind, and manipulate the formulas until the obtain the result they want.

# Moving forward

## More power for spreadsheets

### User-defined functions in formula syntax
Despite their widespread success, there are some limitations to spreadsheets. Previous work [@Jone2003] has described the idea of allowing users to add user-defined functions (UDFs) with spreadsheet formula syntax. This seems to be a powerful addition that unfortunately has not made it so common spreadsheet implementations yet. Of course, UDFs can already be implemented with Visual Basic for Applications in Excel, however, this breaks the concept of liveness as the VBA code has to be compiled. Furthermore, also the directness property [@Malo95] is somewhat lost as the VBA code has to be edited in a separate window.

### Loops and fixed points
While it is possible to have spreadsheet systems like Excel calculate fix points, currently, users need to enable special settings to achieve this, as shown in Figure 1. Spreadsheet systems would be more powerful if such features would be expressable with formula syntac rather that with options.

![*Excel 2010 for Windows showing the property which enables iterative calculation*](images/iterative.PNG)

## Spreadsheets properties for regular languages

# Related Work

## Modeling spreadsheets
Prviously, work has been done that attempted to raise the abstraction level of spreadsheets. Abraham _et al._ for example, have developed a system called ClassSheets [@Abra2005, Enge2005] with which the design of a spreadsheet can be described. From this specification, spreadsheets can be generated. A related effort is the work of Cunha, which transforms a spreadsheet into a database by analyzing functional dependencies[@Cunh2009]. While evaluations showed that this systems makes users more efficient and effective, the authors also conclude that ``that deeper insight on the spreadsheet models is required to maximize effectiveness''[@Beckw2011]. 

# Conclusion
This paper describes the liveness properties of spreadsheets and how they contribute to the mainstream success of spreadsheets. In addtion, directions are presented to  both move spreadsheets forward and to encorporate the success factors into regular programming languages. as such, the contributions of this paper are as follows:

* An detailed overview of _live_ properties of spreadsheets and their inpact on users
* Two distinct directions for the advancement of spreadsheet live programing succes:
	1. More power for spreadsheets
	2. Spreadsheets properties for regular languages

# References
