import Types::*;

module RESERVATION_STATION(
    input  logic i_clk,
    input  p_reg i_free_PRegs [0:1], // Received from Retiring
    input rs_row_struct i_rs_rows [0:1],
    input complete_stage_struct i_complete_stage_data[0:1] // from complete stage for updating RS & values
    output reservation_station_struct o_rs_issue_rows [0:2] // can issue up to 3 instr at once
);

endmodule : RESERVATION_STATION
