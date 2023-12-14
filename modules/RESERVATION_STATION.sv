import Types::*;

module RESERVATION_STATION(
    input  logic i_clk,
    input  p_reg i_free_PRegs [0:1], // Received from Retiring
    input rs_row_struct i_rs_rows [0:1],
    input complete_stage_struct i_complete_stage_data[0:1], // from complete stage for updating RS & values
    input logic i_fu_ready [0:2],
    output rs_row_struct o_rs_issue_rows [0:2] // can issue up to 3 instr at once
);

    logic [3:0] row_pointer;
    rs_row_struct rows [0:15];

    initial begin
        row_pointer <= 0;
    end

    always @(posedge i_clk) begin
        foreach (i_rs_rows[i]) begin
            while (rows[row_pointer].in_use) begin
                row_pointer = row_pointer + 1;
            end
            rows[row_pointer] = i_rs_rows[i];
        end
        foreach (o_rs_issue_rows[i]) begin
            if 
        end
    end

endmodule : RESERVATION_STATION
