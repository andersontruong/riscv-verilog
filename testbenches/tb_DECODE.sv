import Types::*;

module tb_DECODE;

    logic clk = 0;
    word instA, instB;
    decode_struct decodeA, decodeB;

    always begin
        #1 clk <= ~clk;
    end
    
    INSTRUCTION_ROM inst_rom(
        .i_clk(clk),
        .i_en(1'b1),
        .o_instA(instA),
        .o_instB(instB)
    );

    DECODE decode(
        .i_clk(clk),
        .i_instA(instA),
        .i_instB(instB),
        .o_decode_dataA(decodeA),
        .o_decode_dataB(decodeB)
    );
    

endmodule : tb_DECODE