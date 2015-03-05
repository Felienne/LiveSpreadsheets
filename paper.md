---
title: | 
   XanaSheet: Fixing Spreadsheets without Breaking Them
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



Spreadsheet systems can easily be considered the most successful form of programming. Winston [@Wins2001] estimates that 90% of all analysts in industry perform calculations in spreadsheets. Spreadsheet users perform a range of diverse tasks with spreadsheets, from inventory administration to educational applications and from scientific modelling to financial systems. The financial business is a domain where spreadsheets are especially prevailing. Panko[@Pank2006] estimates that 95% of U.S. firms, and 80% in Europe, use spreadsheets in some form for financial reporting.

Spreadsheets are formally defined as a collection of worksheets, which in turn can contain cells. These cells can contain values, like numbers or text, or formulas, with calculations and cell references. In addition to these basic operations, many spreadsheet systems also allow users to create charts, graphs and pivot tables. When a user enters or updates a formula, the result is immediately shown to the user. Also, all cells depending on the changed formula are updated immediately. 

Researchers have  argued that the _liveness_ characteristics of spreadsheets have contributed to the widespread success of spreadsheets [@thesisFelienne] and we know from interviews with users that liveness is important to them. They often start building a spreadsheet with the end goal in mind, and manipulate the formulas until the obtain the result they want.

The liveness characteristics of spreadsheets can be divided in two categories:

- Direct manipulation: instead of editing a separate plan or program to achieve some result, the spreadsheet user edits the "thing itself": there is almost no distinction between the actual data and the "code" of a spreadsheet. This feature addresses the "gulf of execution" which exists between a goal, and the steps that need to be executed to achieve that goal [@Malo95, LiebermanFry1995].

- Immediate feedback: after a change to the spreadsheet data or formulas, the user can immediately observe the effect of the edit. This feature bridges the "gulf of evaluation"which exists between performing an action and receiving feedback on the success of that action [@LiebermanFry1995].



<!--
Problem: spreadsheets are notoriously error-prone (fault-prone?) \cite{.....}
Reason (?): copy-paste is the only mechanism for reuse/sharing behavior/functionality
-->

Despite these attractive features for end-users, spreadsheets are well-known to be extremely fault-prone [@Pank2006]. There are numerous _horror stories_ known in which organizations lost money or credibility because of spreadsheet mistakes. TransAlta for example lost US $24 Million in 2003 because of a copy-paste error in a spreadsheet [@Tran2003]. More recently, the Federal Reserve made a copy-paste error in their consumer credit statement which, although they did not make an official statement about the impact, could have led to a difference of US $4 billion[@Fede2010]. These stories, while single instances of copy-paste problems in spreadsheets do, give credibility to the hypothesis  that copy-paste errors in spreadsheets can greatly impact spreadsheet quality. 

This copy-pasting as in the stories above is not always done my mistake. Rather, we see spreadsheet users using copy-pasting as a deliberate technique. This is understandable, as standard spreadsheets do not support any form of data schema or meta model, so there is no way in which a new worksheet in a spreadsheet could inherit or reuse the model of an existing worksheet. Copy-paste is then often used to compensate for for the lack of code abstractions [@Herm2013]. Finally, when faced with spreadsheets they do not know, users are often afraid to modify existing formulas, thus copy-paste them and add new functionality [@Herm2013] creating many versions of similar formulas, of which the origin can no longer be determined.

<!-- should emphasize the copying here... --->

Existing research has focused on  improving spreadsheets in this direction. An example of this is the work of Abraham _et al._ , who have developed a system called ClassSheets [@Abra2005, Enge2005] with which the structure of a spreadsheet can be described separately. The actual spreadsheet can then be guaranteed to conform to the meta description. 
<!-- TODO: MDSheet -->
Another direction is enriching spreadsheets with user-defined functions (UDFs) [@Jone2003]. In this case, spreadsheets users can factor out common computations into separate cells, and refer to them from elsewhere in the spreadsheet.

Although these features improve the reliability of spreadsheet use, they have one important drawback, namely, that they break the "direct manipulation" aspect of spreadsheets. In a sense, separate meta models, or user defined abstractions, create distance between the actual thing (data + formulas), and its behavior. Instead of just looking at the cells, the user now has to look at at least two places: the cells containing the data and the the separate definitions of the abstractions (meta model and/or user defined functions). 


In this paper we  introduce a different approach called *XanaSheet*, which is based on Ted Nelson's concept of _transclusion_ [@Nelson65].
Transclusion is a form of referencing or hyperlinking where references are actually little windows or views on the thing that's being referenced. 
Whenever the original is updated, the references update as well.
This works both ways: editing the reference will update the original, and as a consequence all other references are updated as well. 

XanaSheet implements transclusion by tracking formula copy actions and transforming edits on copies back to the original.
The original is not modified directly,  within the context of their surrounding cells.

So, instead of introducing levels of indirection via abstractions, XanaSheet supports reuse and sharing by allowing users to edit _equivalence classes_ of formulas. 
In a sense, the abstraction, or user defined function, is there, but it it's never made explicit. 
Nevertheless, this technique eliminates a large class of copy-paste bugs, without at the same time sacrificing the direct manipulation of formulas in cells.




<!--
Without making the abstractions "concrete" as it were, we see the ranges for formulas as "materialization" of "platonic" (?) abstractions.
The way to do this is tracking copying relations (origin tracking).
Whenever a copy of a formula is edited, the original and all other copies are updated as well.
-->

As a result, we conjecture, it is possible to have our cake and eat it too, and fix spreadsheets without breaking them.


# Live programming in Spreadsheets


![*Maintaining consistency among clones of formulas through transclusion*](images/grades.png)


# Moving forward

## More power for spreadsheets

### User-defined functions in formula syntax
Despite their widespread success, there are some limitations to spreadsheets.Of course, UDFs can already be implemented with Visual Basic for Applications in Excel, however, this breaks the concept of liveness as the VBA code has to be compiled. Furthermore, also the directness property [@Malo95] is somewhat lost as the VBA code has to be edited in a separate window.

### Loops and fixed points
While it is possible to have spreadsheet systems like Excel calculate fix points, currently, users need to enable special settings to achieve this, as shown in Figure 1. Spreadsheet systems would be more powerful if such features would be expressible with formula syntax rather that with options.

![*Excel 2010 for Windows showing the property which enables iterative calculation*](images/iterative.PNG)

## Spreadsheets properties for regular languages

Separate meta from concrete, but use tables everywhere.

Code = Data = Spreadsheet?

Data scratch pads: data literals (e.g. Terms, JSON etc.) = data guis
Like FIT
Or Crud Apps: methods become buttons or computed values

# Related Work
Related work for this paper comes in different categories, that we will summarize in this section.

## Improving spreadsheets

Other directions for improvement have been the by enhancing the interface with units of calculation. Abraham and Erwig for example, have written a series of articles on unit inference[@Abra2004, @Abra2006, @Abra2007}. Their units form a type system based on values in the spreadsheet, which is subsequently used to determine whether all cells in a column or row have the same type, improving the safety of the spreadsheet under test. Ahmad _et al._ [@Ahma2003] also created a system to annotate spreadsheets, however their approach requires users to indicate the types of fields themselves, hence significantly chaining the user experience.

Finally, there are related works that aim to improve spreadsheets by adding various forms of error and 'smell' detection. We ourselves have worked on spreadsheet smells in previous work [@herm2012icse,@hermans2012icsm]. In those papers we have explored both spreadsheet smells at the low level of formulas as in a spreadsheets structure. Recently, other work on spreadsheet smells has been published[@cunh2012] that aims to find smells in values, such as typographical errors and values that do not follow the normal distribution. Related is the recent work by Barowy _et al.__ who created CheckCell, a data debugging tool that finds errors or suspicious values in Excel [@Baro2014].

While all the above directions for improvement have their merits, demonstrated with empirical evidence, they do not specifically focus on retaining or even improving the 'live' properties of spreadsheets like we propose.

## Improving spreadsheets
Another category of related work explores the possibility of transferring live properties, as common in spreadsheets.... 


# Conclusion
This paper describes the liveness properties of spreadsheets and how they contribute to the mainstream success of spreadsheets. In addition, directions are presented to  both move spreadsheets forward and to incorporate the success factors into regular programming languages. as such, the contributions of this paper are as follows:

* An detailed overview of _live_ properties of spreadsheets and their impact on users
* Two distinct directions for the advancement of spreadsheet live programming success:
	1. More power for spreadsheets
	2. Spreadsheets properties for regular languages

# References
