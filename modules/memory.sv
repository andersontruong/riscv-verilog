module memory(
    input  logic i_clk,
    input  word i_r_mem_addr,
    output word i_r_mem_data
);

    // Currently only 8-bit address for bytes
    logic [7:0] memory [0:255];

    initial begin
        foreach (memory[i])
            memory[i] <= {8{1'b0}};
    end

    always @(posedge i_clk) begin
        i_r_mem_data <= { 
            memory[i_r_mem_addr[7:0]],
            memory[i_r_mem_addr[7:0] + 1],
            memory[i_r_mem_addr[7:0] + 1],
            memory[i_r_mem_addr[7:0] + 1]
        };

        // if (i_mem_req.w_en) begin
        //     memory[i_mem_req.w_addr[7:0]] <= i_mem_req.w_data[31:24];
        //     memory[i_mem_req.w_addr[7:0] + 1] <= i_mem_req.w_data[23:16];
        //     memory[i_mem_req.w_addr[7:0] + 2] <= i_mem_req.w_data[15:8];
        //     memory[i_mem_req.w_addr[7:0] + 3] <= i_mem_req.w_data[7:0];
        // end
    end

endmodule