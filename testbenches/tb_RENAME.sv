import Types::*;

module tb_RENAME;

    logic clk = 0;
    word insts [0:1];
    p_reg free_pregs [0:1];
    decode_struct decode_data [0:1];
    rename_struct rename_data [0:1];

    initial begin
        clk <= 0;
        foreach (free_pregs[i])
            free_pregs[i] = 0;
    end

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

    RENAME rename(
        .i_clk(clk),
        .i_free_PRegs(free_pregs),
        .i_decode_data(decode_data),
        .o_rename_data(rename_data)
    );

endmodule : tb_RENAME