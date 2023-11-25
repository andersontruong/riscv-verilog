import Types::*;

module tb_DECODE;

    logic clk = 0;
    word insts [0:1];
    decode_struct decode_data [0:1];

    always begin
        #1 clk <= ~clk;
    end
    
    INSTRUCTION_ROM inst_rom(
        .i_clk(clk),
        .i_en(1'b1),
        .o_insts(insts)
    );

    DECODE decode(
        .i_clk(clk),
        .i_insts(insts),
        .o_decode_data(decode_data)
    );
    

endmodule : tb_DECODE