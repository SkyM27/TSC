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
  parameter WR_NR = 20;
  parameter RD_NR = 20;
  int seed = 555;

  instruction_t  iw_reg_test [0:31];

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
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
    //repeat (3) begin - Cristi 6/3/2024
    repeat (WR_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    //for (int i=0; i<=2; i++) begin - Cristi 6/3/2024
      for (int i=0; i<=RD_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) read_pointer = i;
      @(negedge clk) print_results;
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;//se salveaza valorile generate in iw_reg_test
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0; //nu se aloca decat o singura data variabila pentru 'static'
    //algoritmul de randomize vine cu verilog-ul
    //se iau valori intre 15 si -15 deoarece este signed
    operand_a     <= $random(seed)%16;                 // between -15 and 15
    operand_b     <= $unsigned($random)%16;            // between 0 and 15
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    //cast converteste tipul de variabila. 
    //se face %8 deoarece sunt 8 operatii
    write_pointer <= temp++; //temp++ se incrementeaza (creste valoarea cu 1). primeste 0 deoarece ++ este dupa 'temp'
    iw_reg_test[write_pointer] = '{opcode,operand_a,operand_b,0}; //se salveaza valorile generate in iw_reg_test
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name); //opc.name este built-in
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  result = %0d\n", instruction_word.res);
  endfunction: print_results

  function void check_results;
  operand_res res = 0;
    case(iw_reg_test[read_pointer].opcode)
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
    if (res !== iw_reg_test[read_pointer].res) begin
      $display("ERROR: read value does not match expected value");
      $display("  Expected: %0d", iw_reg_test[read_pointer].res);
      $display("  Read: %0d", res);
    end
  endfunction: check_results

endmodule: instr_register_test
