call run_test.bat 25 25 0 0 case_INC_INC c
cd ../tools
call run_test.bat 25 25 0 1 case_INC_DEC c
cd ../tools
call run_test.bat 25 25 0 2 case_INC_RAND c
cd ../tools
call run_test.bat 50 50 1 0 case_DEC_INC c
cd ../tools
call run_test.bat 50 50 1 1 case_DEC_DEC c
cd ../tools
call run_test.bat 50 50 1 2 case_DEC_RAND c
cd ../tools
call run_test.bat 75 75 2 0 case_RAND_INC c
cd ../tools
call run_test.bat 75 75 2 1 case_RAND_DEC c
cd ../tools
call run_test.bat 75 75 2 2 case_RAND_RAND c
cd ../tools
