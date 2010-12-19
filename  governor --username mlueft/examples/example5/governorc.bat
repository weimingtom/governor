rem define the correct paths here

set pathGovernor=D:\programme\governorc\
set pathProject=D:\programming\AS3\03_tools\governor\trunk\examples\example5\

%pathGovernor%governorc.exe -if %pathProject%src\gvs\scripts.gvs -of %pathProject%src\gvs\ -ct %pathProject%customTokens.txt -ns gvs -v AS3 -on Governor
