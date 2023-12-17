import Types::*;

module INSTRUCTION_ROM(
    input  logic i_clk,
    input  logic i_en,
    output word o_insts [0:1]
);
    integer data_file, scan_file;
    integer out = 0;
    word insts [0:1];

    initial begin
        #1;
        data_file <= $fopen("evaluation-hex.txt", "r");
        if (data_file) $display("File opened successfully at FH: %0d", data_file);
        else $display("File not opened : %0d", data_file);
    end

    assign o_insts = insts;

    always @(posedge i_clk) begin
        foreach (insts[i]) begin
            if (!$feof(data_file)) begin
                out <= $fscanf(data_file, "%2x", insts[i][31:24]);
                out <= $fscanf(data_file, "%2x", insts[i][23:16]);
                out <= $fscanf(data_file, "%2x", insts[i][15:8]);
                out <= $fscanf(data_file, "%2x", insts[i][7:0]);
                $display("FETCH Issue %i: %8x, out=%d", i, insts[i], out);
            end
            // Set NOP when EOF
            else begin
                $display("EOF");
                insts[i] <= 0;
            end
        end
    end

endmodule : INSTRUCTION_ROM