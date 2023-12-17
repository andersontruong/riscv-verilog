import Types::*;

module memory(
    input  logic i_clk,
    input  word i_r_mem_addr,
    output word i_r_mem_data,

    input word i_w_mem_addr [0:1],
    input word i_w_mem_data [0:1],
    input logic i_w_mem_en [0:1]
);

    // Currently only 8-bit address for bytes
    logic [7:0] memory [0:255];
    logic state = 0;

    initial begin
        i_r_mem_data = 'X;
    end

    initial begin
        foreach (memory[i])
            memory[i] <= {8{1'b0}};
    end

    always @(posedge i_clk) begin
        if (state == 0) begin
            if (i_r_mem_addr) begin
                i_r_mem_data <= { 
                    memory[i_r_mem_addr[7:0]],
                    memory[i_r_mem_addr[7:0] + 1],
                    memory[i_r_mem_addr[7:0] + 1],
                    memory[i_r_mem_addr[7:0] + 1]
                };
            end
            else begin
                i_r_mem_data <= 'X;
            end
            state <= 1;
        end
        else begin
            state <= 0;
            i_r_mem_data <= 'X;
        end

        foreach (i_w_mem_addr[i]) begin
            if (i_w_mem_en[i] && ^i_w_mem_addr[i] !== 'X) begin
                $display("MEMORY WRITE: WORD %8x to ADDR %d", i_w_mem_data[i], i_w_mem_addr[i]);
                memory[i_w_mem_addr[i][7:0]] <= i_w_mem_data[i][31:24];
                memory[i_w_mem_addr[i][7:0] + 1] <= i_w_mem_data[i][23:16];
                memory[i_w_mem_addr[i][7:0] + 2] <= i_w_mem_data[i][15:8];
                memory[i_w_mem_addr[i][7:0] + 3] <= i_w_mem_data[i][7:0];
            end
        end
    end

endmodule