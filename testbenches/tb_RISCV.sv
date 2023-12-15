`timescale 1ns/1ns

import Types::*;

module tb_RISCV;

    logic clk = 0;
    word insts [0:1];
    p_reg free_pregs [0:1];
    decode_struct decode_data [0:1];
    rename_struct rename_data [0:1];

    initial begin
        clk <= 0;
        foreach (free_pregs[i])
            free_pregs[i] = 0;
        #50;
        $stop;
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

    p_reg r_reg_addr [0:3];
    word  r_reg_data [0:3];

    logic w_reg_en [0:1];
    p_reg w_reg_addr [0:1];
    word  w_reg_data [0:1];

    logic i_free_fu [0:2];
    logic o_free_fu [0:2];

    assign i_free_fu = o_free_fu;

    rs_row_struct issue_inst [0:2];

    register_file reg_file(
        .i_clk(clk),
        .i_r_addr(r_reg_addr),
        .i_w_en(w_reg_en),
        .i_w_addr(w_reg_addr),
        .i_w_data(w_reg_data),
        .o_r_data(r_reg_data)
    );

    rs_row_struct rows [0:15];
    rob_row_struct rob_rows [0:1];

    DISPATCH dispatch(
        .i_clk(clk),
        .i_rename_data(rename_data),

        .i_r_reg_data(r_reg_data),
        .o_r_reg_addr(r_reg_addr),

        .i_free_fu(i_free_fu),
        .o_free_fu(o_free_fu),
        
        .rows(rows),
        .o_issue_inst(issue_inst),
        .o_rob_rows(rob_rows)
    );

    // word r_mem_data, r_mem_addr;
    // complete_stage_struct complete_result [0:2];

    // memory mem(
    //     .i_clk(clk),
    //     .i_r_mem_addr(r_mem_addr),
    //     .i_r_mem_data(r_mem_data)
    // );

    // ISSUE issue(
    //     .i_clk(clk),
    //     .i_issue_inst(issue_inst),
    //     .i_r_mem_data(r_mem_data),
    //     .i_r_mem_addr(r_mem_addr),
    //     .o_complete_result(complete_result)
    // );

    // COMPLETE complete(
    //     .i_clk(clk),
    //     input  rob_row_struct i_rob_row [0:1],
    //     input  complete_stage_struct i_complete_result [0:2],
    //     output rob_row_struct o_retire_row [0:1],
    //     output logic [0:1] fu_ready [0:2]
    // );

endmodule : tb_RISCV