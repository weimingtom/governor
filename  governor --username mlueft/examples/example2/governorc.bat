rem define the correct paths here

set pathGovernor=D:\programme\governorc\
set pathProject=D:\programming\AS3\03_tools\governor\trunk\examples\example2\

rem this line calls the compiler with the defined parameters to compile scripts.gsc to Governor.as
%pathGovernor%governorc.exe -if %pathProject%src\gvs\scripts.gvs -of %pathProject%src\gvs\ -ct %pathProject%customTokens.txt -ns src.gvs -v AS3 -on Governor
