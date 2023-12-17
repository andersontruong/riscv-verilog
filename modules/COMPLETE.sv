import Types::*;

module COMPLETE(
    input  logic i_clk,
    input  rob_row_struct i_rob_row [0:1],
    input  complete_stage_struct i_complete_result [0:2],
    output rob_row_struct o_complete_rob_rows [0:2],
    output rob_row_struct o_retire_rob_rows [0:1]
);
    // 16 ROB rows
    logic [3:0] ROB_pointer = 0;
    rob_row_struct rob_rows [0:15];

    initial begin
        foreach (rob_rows[i]) begin
            rob_rows[i].valid <= 0;
            rob_rows[i].complete <= 0;
        end
    end

    // Create ROB Entry if Valid Request and Empty Row
    always_ff @(posedge i_clk) begin
        foreach (i_rob_row[i]) begin
            $display("TRY ROB ISSUE %d: at %d; valid i=%d, valid spot=", i, i_rob_row[i].ROBNumber, i_rob_row[i].valid, rob_rows[i_rob_row[i].ROBNumber].valid);
            if (i_rob_row[i].valid && !rob_rows[i_rob_row[i].ROBNumber].valid) begin
                $display("ROB Issue %d: at %d", i, i_rob_row[i].ROBNumber);
                rob_rows[i_rob_row[i].ROBNumber] <= i_rob_row[i];
            end
        end

        foreach(i_complete_result[i]) begin
            if (i_complete_result[i].ready) begin
                $display("COMPLETE Issue %d:", i);
                $display("\tROB#:  %d", i_complete_result[i].ROBNumber);
                $display("\tResult:  %d", i_complete_result[i].FU_Result);

                rob_rows[i_complete_result[i].ROBNumber].complete <= 1;
                rob_rows[i_complete_result[i].ROBNumber].data <= i_complete_result[i].FU_Result;
                o_complete_rob_rows[i] <= rob_rows[i_complete_result[i].ROBNumber];
            end
            else begin
                rob_rows[i_complete_result[i].ROBNumber].complete <= 0;
                rob_rows[i_complete_result[i].ROBNumber].data <= 'X;
                o_complete_rob_rows[i].valid <= 0;
            end
        end

        foreach (o_retire_rob_rows[i]) begin
            if (rob_rows[ROB_pointer].complete) begin
                $display("RETIRE Issue %d:", i);
                $display("\tROB#:  %d", ROB_pointer);
                o_retire_rob_rows[i] = rob_rows[ROB_pointer];
                rob_rows[ROB_pointer].valid = 0;
                ROB_pointer = ROB_pointer + 1;
                $display("\tNew ROB#:  %d", ROB_pointer);
            end
            else begin
                o_retire_rob_rows[i] <= '{
                    valid: 'X,
                    PRegAddrDst: 'X,
                    OldPRegAddrDst: 'X,
                    complete: 'X,
                    data: 'X,
                    RegWrite: 'X,
                    MemWrite: 'X,
                    ROBNumber: 'X
                };
            end
        end
    end

endmodule : COMPLETE