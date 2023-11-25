import Types::*;

module tb_INSTRUCTION_ROM;

    logic clk = 0;
    logic en;
    word addr;
    word instA, instB;

    always begin
        #1 clk <= ~clk;
    end
    
    INSTRUCTION_ROM inst_rom(
        .i_clk(clk),
        .i_en(1'b1),
        .o_instA(instA),
        .o_instB(instB)
    );
    

endmodule : tb_INSTRUCTION_ROM