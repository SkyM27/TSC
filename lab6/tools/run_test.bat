::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
::========================================================================================
::vsim -gui -do run.do
::========================================================================================
::vsim -c -do run.do

::echo %1 %2 %3 %4 %0
vsim -c -do "do run.do %1 %2 %3 %4 %5"
