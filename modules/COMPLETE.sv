module COMPLETE(
    input  logic i_clk,
    input  complete_stage_struct i_complete [0:2],
    output fu_ready [0:2]
);

    always_ff @(posedge i_clk) begin
        
        foreach (i_complete) begin
        end
    end

endmodule : COMPLETE