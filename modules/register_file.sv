import Types::*;

module register_file(
    input logic clk,
    input logic w_en,
    input p_reg r_addr1, r_addr2, w_addr,
    input word w_data,
    output word r_data1, r_data2
);
    word reg_array[0:127];

    assign word[0] = 32'b0;

    assign r_data1 = reg_array[r_addr1];
    assign r_data2 = reg_array[r_addr2];

    always @(posedge clk) begin
        if (w_en)
            reg_array[w_addr] = w_data;
    end

endmodule: register_file