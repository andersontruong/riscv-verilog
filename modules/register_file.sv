import Types::*;

module register_file(
    input  logic i_clk,
    input  p_reg i_r_addr [0:5],
    input  logic i_w_en [0:1],
    input  p_reg i_w_addr [0:1],
    input  word  i_w_data [0:1],
    output word  o_r_data [0:5]
);
    word reg_array[0:127];

    assign reg_array[0] = 32'b0;

    initial begin
        foreach(reg_array[i])
            reg_array[i] <= 0;
    end

    always_comb begin
        foreach (i_r_addr[i]) begin
            o_r_data[i] <= reg_array[i_r_addr[i]];
        end
    end

    always @(posedge i_clk) begin
        foreach (i_w_addr[i]) begin
            if (i_w_en[i])
                reg_array[i_w_addr[i]] <= i_w_data[i];
        end
    end

endmodule: register_file