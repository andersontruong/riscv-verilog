import Types::*;

module INSTRUCTION_ROM(
    input  logic i_clk,
    input  logic i_en,
    output word o_insts [0:1]
);
    integer data_file, scan_file;
    integer out = 0;

    initial begin
        data_file = $fopen("r-test-hex.txt", "r");
        if (data_file) $display("File opened successfully at FH: %0d", data_file);
        else $display("File not opened : %0d", data_file);
    end

    always @(posedge i_clk) begin
        foreach (o_insts[i]) begin
            if (out != -1) begin
                out = $fscanf(data_file, "%2x\n", o_insts[i][31:24]);
                out = $fscanf(data_file, "%2x\n", o_insts[i][23:16]);
                out = $fscanf(data_file, "%2x\n", o_insts[i][15:8]);
                out = $fscanf(data_file, "%2x\n", o_insts[i][7:0]);
                $display("ReadA %8x", o_insts[i]);
            end
            // Set NOP when EOF
            else begin
                o_insts[i] = 0;
            end
        end
    end

endmodule : INSTRUCTION_ROM