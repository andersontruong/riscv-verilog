`timescale 1ns/1ns

import Types::*;

module tb_RISCV;

    logic clk = 0;
    word insts [0:1];
    decode_struct decode_data [0:1];
    rename_struct rename_data [0:1];

    p_reg r_reg_addr [0:5];
    word  r_reg_data [0:5];

    logic w_reg_en [0:1];
    p_reg w_reg_addr [0:1];
    word  w_reg_data [0:1];

    logic w_free_fu [0:2];
    logic dispatch_free_fu [0:2];
    logic complete_free_fu [0:2];

    rs_row_struct issue_inst [0:2];
    rob_row_struct dispatched_rob_rows [0:1];

    word r_mem_data, r_mem_addr;
    word w_mem_addr [0:1];
    word w_mem_data [0:1];
    logic w_mem_en [0:1];
    rob_row_struct complete_rob_row [0:2];
    rob_row_struct retire_rob_rows [0:1];

    initial begin
        clk <= 0;
        #100;
        $stop;
    end

    always begin
        #0.5 clk <= ~clk;
    end

    always_comb begin
        foreach (w_free_fu[i]) begin
            if (^complete_free_fu[i] === 1'bX)
                w_free_fu[i] <= dispatch_free_fu[i];
            else
                w_free_fu[i] <= dispatch_free_fu[i] | complete_free_fu[i];
        end
    end

    always_comb begin
        foreach (w_mem_data[i]) begin
            w_mem_data[i] <= r_reg_data[4+i];
        end
    end

    always_ff @(posedge clk) begin
        foreach (retire_rob_rows[i]) begin
            if (retire_rob_rows[i].valid) begin
                // Store from reg to mem
                if (retire_rob_rows[i].MemWrite) begin
                    w_mem_addr[i] <= retire_rob_rows[i].data;
                    r_reg_addr[4+i] <= retire_rob_rows[i].PRegAddrDst;
                    w_mem_en[i] <= 1;
                end
                // Write FUResult to reg
                else if (retire_rob_rows[i].RegWrite) begin
                    w_reg_addr[i] <= retire_rob_rows[i].PRegAddrDst;
                    w_reg_data[i] <= retire_rob_rows[i].data;
                    w_reg_en[i] <= 1;
                end
            end
            else begin
                w_mem_en[i] <= 0;
                w_reg_en[i] <= 0;
            end
        end
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
        .i_decode_data(decode_data),
        .i_complete_rob_row(complete_rob_row),
        .o_rename_data(rename_data)
    );

    register_file reg_file(
        .i_clk(clk),
        .i_r_addr(r_reg_addr),
        .i_w_en(w_reg_en),
        .i_w_addr(w_reg_addr),
        .i_w_data(w_reg_data),
        .o_r_data(r_reg_data)
    );

    DISPATCH dispatch(
        .i_clk(clk),
        .i_rename_data(rename_data),

        .i_r_reg_data(r_reg_data[0:3]),
        .o_r_reg_addr(r_reg_addr[0:3]),

        .i_free_fu(w_free_fu),
        .o_free_fu(dispatch_free_fu),

        .i_complete_rob_row(complete_rob_row),
        
        .o_issue_inst(issue_inst),
        .o_rob_rows(dispatched_rob_rows)
    );

    memory mem(
        .i_clk(clk),
        .i_r_mem_addr(r_mem_addr),
        .i_r_mem_data(r_mem_data),
        .i_w_mem_addr(w_mem_addr),
        .i_w_mem_data(w_mem_data),
        .i_w_mem_en(w_mem_en)
    );

    ISSUE issue(
        .i_clk(clk),
        .i_issue_inst(issue_inst),
        .i_r_mem_data(r_mem_data),
        .i_r_mem_addr(r_mem_addr),
        .o_complete_rob_row(complete_rob_row),
        .o_fu_ready(complete_free_fu)
    );

    COMPLETE complete(
        .i_clk(clk),
        .i_rob_row(dispatched_rob_rows),
        .i_complete_rob_row(complete_rob_row),
        .o_retire_rob_rows(retire_rob_rows)
    );

endmodule : tb_RISCV