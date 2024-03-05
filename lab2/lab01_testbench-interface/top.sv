/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top;
  timeunit 1ns/1ns; // timpul de simulare este 1ns cu pas de 1ns

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // clock variables
  logic clk;
  logic test_clk;

  // interconnecting signals
  logic          load_en; 
  logic          reset_n; //resetul este activ in 0
  opcode_t       opcode; //operatia dintre a si b
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  operand_t      res;
  instruction_t  instruction_word;

  // instantiate testbench and connect ports
  instr_register_test test (
    .clk(test_clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // instantiate design and connect ports
  instr_register dut (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .res(res),
    .instruction_word(instruction_word)
   );

  // clock oscillators
  initial begin // cuvant cheie care executa incepand cu timpul de simulare 0
    clk <= 0; //primeste 0
    forever #5  clk = ~clk; //la fiecare 5ns, clk primeste ~clk
  end

  initial begin 
    test_clk <=0; //primeste 0 
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin //dupa 4ns intra in bucla infinita care dupa asteapta inca 2ns si dupa 8ns (#4 se executa doar o data)
      #2ns test_clk = 1'b1; //pune 1 la 6ns
      #8ns test_clk = 1'b0; //pune 0 la 14ns
    end //cele 2 ceasuri au faza diferita
  end

endmodule: top
