import Types::*;

module tb_INSTRUCTION_ROM;

    logic clk = 0;
    word insts [0:1];

    always begin
        #1 clk <= ~clk;
    end
    
    INSTRUCTION_ROM inst_rom(
        .i_clk(clk),
        .i_en(1'b1),
        .o_insts(insts)
    );
    

endmodule : tb_INSTRUCTION_ROM