import Types::*;

module RENAME(
    input  logic i_clk,
    input  p_reg i_free_PRegs [0:1], // Received from Retiring
    input  decode_struct i_decode_data [0:1],
    input rob_row_struct i_complete_rob_rows [0:2],
    output rename_struct o_rename_data [0:1]
);
    // RAT

    // 32 rows, one for each AReg
    // Current PReg Assignment
    p_reg physical_reg [0:31];

    logic free_pool [127];

    // 4 src registers to rename
    // Pull from free pool 2 dst registers
    initial begin
        foreach (free_pool[i]) begin
            if (i < 32) free_pool[i] <= 1'b0;
            else free_pool[i] <= 1'b1;
        end
        foreach (physical_reg[i]) begin
            physical_reg[i] <= i;
        end
    end

    always @(posedge i_clk) begin
        foreach (o_rename_data[i]) begin
            o_rename_data[i].immediate <= i_decode_data[i].immediate;
            o_rename_data[i].ALUOp     <= i_decode_data[i].ALUOp;
            o_rename_data[i].ALUSrc    <= i_decode_data[i].ALUSrc;
            o_rename_data[i].RegWrite  <= i_decode_data[i].RegWrite;
            o_rename_data[i].MemRead   <= i_decode_data[i].MemRead;
            o_rename_data[i].MemWrite  <= i_decode_data[i].MemWrite;
            o_rename_data[i].MemtoReg  <= i_decode_data[i].MemtoReg;

            if (i_decode_data[i].ARegAddrSrc0 == 0)
                o_rename_data[i].PRegAddrSrc0 <= 0;
            else
                o_rename_data[i].PRegAddrSrc0 <= physical_reg[i_decode_data[i].ARegAddrSrc0];
            
            if (i_decode_data[i].ARegAddrSrc1 == 0)
                o_rename_data[i].PRegAddrSrc1 <= 0;
            else
                o_rename_data[i].PRegAddrSrc1 <= physical_reg[i_decode_data[i].ARegAddrSrc1];

            $display("RENAME Issue %d:", i);
            $display("\tSrc0: %d", physical_reg[i_decode_data[i].ARegAddrSrc0]);
            $display("\tSrc1: %d", physical_reg[i_decode_data[i].ARegAddrSrc1]);
            $display("\tImmediate:  %d", i_decode_data[i].immediate);

            if (|i_decode_data[i].ARegAddrDst) begin
                for (int j = 0; j < 128; j++) begin
                    if (free_pool[j]) begin
                        $display("\tDst:  %d", j);
                        $display("\t\tOldDst:  %d", physical_reg[i_decode_data[i].ARegAddrDst]);
                        free_pool[j] = 0;
                        o_rename_data[i].PRegAddrDst <= j;
                        o_rename_data[i].OldPRegAddrDst <= physical_reg[i_decode_data[i].ARegAddrDst];
                        physical_reg[i_decode_data[i].ARegAddrDst] <= j;
                        
                        break;
                    end
                end
            end
            else begin
                $display("\t<<<NO DEST>>>, zeroing...");
                $display("\tDst:  %d", 0);
                $display("\t\tOldDst:  %d", 0);
                o_rename_data[i].OldPRegAddrDst <= 0;
                o_rename_data[i].PRegAddrDst <= 0;
            end
        end
    end

    always @(posedge i_clk) begin
        // Free Retired Dst Registers
        foreach (i_complete_rob_rows[i]) begin
            if (i_complete_rob_rows[i].valid) begin
                foreach (free_pool[j]) begin
                    // Free old register
                    if (j == i_complete_rob_rows[i].OldPRegAddrDst) begin
                        free_pool[j] <= 1'b1;
                        break;
                    end
                end
            end
        end
    end

endmodule : RENAME