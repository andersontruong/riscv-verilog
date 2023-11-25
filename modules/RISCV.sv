import Types::*;

module RISCV(
    input  logic clk
);

    word instA_buf, instB_buf;
    INSTRUCTION_ROM inst_rom(
        .i_clk(clk), 
        .i_en(1'b1),
        .o_instA(instA_buf),
        .o_instB(instB_buf)
    );

    DECODE decode(
        .i_clk(clk),
        .i_instA(instA_buf),
        .i_instB(instB_buf)
    )

endmodule : RISCV