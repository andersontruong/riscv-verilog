import Types::*;

module dispatch_reg(
    input i_clk,
    input  word  i_r_reg_data,
    output p_reg o_r_reg_addr,
    output word o_result
);
    logic [6:0] counter;
    initial begin
        counter <= 0;
    end

    assign o_result = i_r_reg_data;

    always @(posedge i_clk) begin
        o_r_reg_addr = counter;
        counter = counter + 1;
    end

endmodule