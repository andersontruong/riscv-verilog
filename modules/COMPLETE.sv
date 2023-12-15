import Types::*;

module COMPLETE(
    input  logic i_clk,
    input  rob_row_struct i_rob_row [0:1],
    input  complete_stage_struct i_complete_result [0:2],
    output rob_row_struct o_retire_row [0:1],
    output logic [0:1] fu_ready [0:2]
);
    // 16 ROB rows
    logic [3:0] ROB_pointer;
    rob_row_struct rob_rows [0:15];

    initial begin
        foreach (rob_rows[i]) begin
            rob_rows[i].valid <= 0;
            rob_rows[i].complete <= 0;
        end
    end

    // Retire ROB entry
    always_ff @(posedge i_clk) begin
        foreach (o_retire_row[i]) begin
            for (int j = 0; j < 16; j++) begin
                if (rob_rows[ROB_pointer + j].complete) begin
                    o_retire_row[i] = rob_rows[ROB_pointer + j];
                    ROB_pointer = ROB_pointer + j;
                    break;
                end
                if (j == 15) begin
                    o_retire_row[i] = '{
                        valid: 0,
                        PRegAddrDst: 0,
                        OldPRegAddrDst: 0,
                        complete: 0,
                        data: 0,
                        RegWrite: 0,
                        MemWrite: 0,
                        MemtoReg: 0,
                    };
                end
            end
        end
    end

    // Update ROB entry with Complete
    always_ff @(posedge i_clk) begin
        foreach(i_complete_result[i]) begin
            if (i_complete_result[i].ready) begin
                $display("COMPLETE Issue %d:", i);
                $display("\tROB#:  %d", i_complete_result[i].ROBNumber);
                $display("\tResult:  %d", i_complete_result[i].FU_Result);

                rob_rows[i_complete_result[i].ROBNumber].complete <= 1;
                rob_rows[i_complete_result[i].ROBNumber].data <= i_complete_result[i].FU_Result;
                fu_ready[i] <= i_complete_result[i].fu;
            end
            else begin
                rob_rows[i_complete_result[i].ROBNumber].complete <= 0;
                rob_rows[i_complete_result[i].ROBNumber].data <= 0;
                fu_ready[i] <= 'X;
            end
        end
    end

    // Create ROB Entry
    always_ff @(posedge i_clk) begin
        foreach (i_rob_row[i]) begin
            if (i_rob_row[i].valid && !rob_rows[i_rob_row[i].ROBNumber].valid) begin
                $display("ROB Issue %d: at %d", i, ROB_pointer + j);
                rob_rows[i] = i_rob_row[i];
            end
        end
    end

endmodule : COMPLETE