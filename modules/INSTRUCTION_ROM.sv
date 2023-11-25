import Types::*;

module INSTRUCTION_ROM(
    input  logic i_clk,
    input  logic i_en,
    output word o_instA, o_instB
);
    integer data_file, scan_file;
    integer out = 0;

    initial begin
        data_file = $fopen("r-test-hex.txt", "r");
        if (data_file) $display("File opened successfully at FH: %0d", data_file);
        else $display("File not opened : %0d", data_file);
    end

    always @(posedge i_clk) begin
        // Handle instruction A
        if (out != -1) begin
            out = $fscanf(data_file, "%2x\n", o_instA[31:24]);
            out = $fscanf(data_file, "%2x\n", o_instA[23:16]);
            out = $fscanf(data_file, "%2x\n", o_instA[15:8]);
            out = $fscanf(data_file, "%2x\n", o_instA[7:0]);
            $display("ReadA %8x", o_instA);
        end
        // Set NOP when EOF
        else begin
            o_instA = 0;
        end

        // Handle instruction A
        if (out != -1) begin
            out = $fscanf(data_file, "%2x\n", o_instB[31:24]);
            out = $fscanf(data_file, "%2x\n", o_instB[23:16]);
            out = $fscanf(data_file, "%2x\n", o_instB[15:8]);
            out = $fscanf(data_file, "%2x\n", o_instB[7:0]);
            $display("ReadB %8x", o_instB);
        end
        // Set NOP when EOF
        else begin
            o_instB = 0;
        end
    end

endmodule : INSTRUCTION_ROM