rem define the correct paths here

set pathGovernor=D:\programme\governorc\
set pathProject=D:\programming\AS3\governor\trunk\examples\example3\

rem this line calls the compiler with the defined parameters to compile scripts.gsc to Governor.as
%pathGovernor%governorc.exe -if %pathProject%src\gsc\scripts.gsc -of %pathProject%src\gsc\ -ct %pathProject%customTokens.txt -ns gsc -v AS3 -on Governor
