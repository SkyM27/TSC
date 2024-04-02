/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;
  parameter WR_NR = 5;
  parameter RD_NR = 5;
  parameter READ_ORDER = 1; // 0 = incremental , 1 = decremental, 2 = random
  parameter WRITE_ORDER = 2; // 0 = incremental , 1 = decremental, 2 = random
  parameter TEST_NAME;

  static int failcounter = 0;
  
  int seed = 555;

  instruction_t  iw_reg_test [0:31];

  initial begin
    $display("\n\n***********************************************************");
    $display(    "********  THIS IS A SELF-CHECKING TESTBENCH.  YOU  ********");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    //repeat (3) begin LAB3
    repeat (WR_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    //for (int i=0; i<=2; i++) begin LAB3
      for (int i=0; i<RD_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) case(READ_ORDER)
        0: read_pointer = i % 32; // incremental
        1: read_pointer = 31 - (i % 32); // decremental
        2: read_pointer = $unsigned($random) % 32; // random
      endcase
      @(negedge clk) print_results;
      check_results;
    end
    

    @(posedge clk) ;
    final_report;
    $display("\n***********************************************************");
    $display(  "********  THIS IS A SELF-CHECKING TESTBENCH.  YOU  ********");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;//se salveaza valorile generate in iw_reg_test
  /* LAB3
  operand_t op_a;
  operand_t op_b;
  opcode_t  opc;
  int wp_t;
  
  static int temp = 0; //nu se aloca decat o singura data variabila pentru 'static'
  
  op_a = $random(seed)%16; // between -15 and 15. Algoritmul de randomize vine cu verilog-ul. Se iau valori intre 15 si -15 deoarece este signed
  op_b = $unsigned($random)%16;  // between 0 and 15
  opc = opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
  //cast converteste tipul de variabila. 
  //se face %8 deoarece sunt 8 operatii
  wp_t = temp++;

    operand_a     = op_a;                 
    operand_b     = op_b;          
    opcode        = opc; 
    write_pointer = wp_t; //temp++ se incrementeaza (creste valoarea cu 1). primeste 0 deoarece ++ este dupa 'temp'
    iw_reg_test[wp_t] = '{opc,op_a,op_b,0}; //se salveaza valorile generate in iw_reg_test */

    static int temp_incrementare = 0;
    static int temp_decrementare = 31;

    operand_a = $random(seed) % 16; // between -15 and 15
    operand_b = $unsigned($random % 16); // between 0 and 15
    opcode = opcode_t'($unsigned($random % 8)); // between 0 and 7, cast to opcode_t type
    case(WRITE_ORDER)
      0: write_pointer = temp_incrementare++;
      1: write_pointer = temp_decrementare--;
      2: write_pointer = $random($random) % 32;
    endcase
    $display("At write pointer = %0d:, timp %0t: ", write_pointer, $time);
    $display("  opcode = %0d", opcode,);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
    iw_reg_test[write_pointer] = '{opcode,operand_a,operand_b,0};
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
    $display("  result = %0d\n", instruction_word.res);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name); //opc.name este built-in
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  result = %0d\n", instruction_word.res);
    $display("Fail counter: %0d\n", failcounter);
  endfunction: print_results

  function void check_results;
  operand_res res;
    case(iw_reg_test[read_pointer].opc)
        ZERO: res = 0;
        PASSA: res = iw_reg_test[read_pointer].op_a;
        PASSB: res = iw_reg_test[read_pointer].op_b;
        ADD: res = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
        SUB: res = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
        MULT: res = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
        DIV: begin
          if (iw_reg_test[read_pointer].op_b === 0) res = 0;
          else res = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
        end
        MOD: res = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
        default : res = 0;
    endcase
    if (res !== instruction_word.res) begin
      $display("ERROR: read value does not match expected value");
      $display("  Expected: %0d", instruction_word.res);
      $display("  Read: %0d", res);
      failcounter++;
    end
    else begin
      $display("Read value matches expected value");
      $display("  Expected: %0d", instruction_word.res);
      $display("  Read: %0d", res);
    end
    // if (operand_a !== instruction_word.op_a) begin
    //   $display("ERROR: Operand A is not the same");
    //   $display("  Expected: %0d", instruction_word.op_a);
    //   $display("  Read: %0d", instruction_word.op_a);
    // end
    // else begin
    //   $display("Operand A is the same");
    //   $display("  Expected: %0d", instruction_word.op_a);
    //   $display("  Read: %0d", instruction_word.op_a);
    // end
  endfunction: check_results

  function void final_report;
    int file;
    file = $fopen("../reports/regression_status.txt", "a");
    if (failcounter != 0)
    begin
      $fdisplay(file, "%s: failed", TEST_NAME);
    end
    else
    begin
      $fdisplay(file, "%s: passed", TEST_NAME);
    end
    $fclose(file);
  endfunction:final_report
endmodule: instr_register_test