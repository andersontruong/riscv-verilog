`timescale 1ns/1ns

import Types::*;

module tb;

    logic clk = 0;

    p_reg r_reg_addr [0:3];
    word r_reg_data [0:3];
    word result;
    logic w_en[0:1];
    p_reg w_addr[0:1];
    word w_data[0:1];

    dispatch_reg dut(
        clk,
        r_reg_data[0],
        r_reg_addr[0],
        result
    );

    register_file test(
        .i_clk(clk),
        .i_r_addr(r_reg_addr),
        .i_w_en(w_en),
        .i_w_addr(w_addr),
        .i_w_data(w_data),
        .o_r_data(r_reg_data)
    );

    always begin
        #1 clk <= ~clk;
    end

    initial begin
        clk <= 0;
        #10;
        $stop();
    end

endmodule