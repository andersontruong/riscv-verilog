import Types::*;

module RENAME(
    input  logic i_clk,
    input  p_reg i_free_PRegs [0:1], // Received from Retiring
    input  decode_struct i_decode_data [0:1],
    output rename_struct o_rename_data [0:1]
);


    // RAT

    // 32 rows, one for each AReg
    // Current PReg Assignment
    p_reg physical_reg [0:31];

    logic free_pool [0:126];

    // 4 src registers to rename
    // Pull from free pool 2 dst registers
    initial begin
        foreach (free_pool[i]) begin
            if (i < 32) free_pool[i] = 1'b0;
            else free_pool[i] = 1'b1;
        end
        foreach (physical_reg[i]) physical_reg[i] = i;
    end

    always @(posedge i_clk) begin
        // Free Retired Dst Registers
        foreach (i_free_PRegs[i]) begin
            if (i_free_PRegs[i] == 0)
                continue;
            foreach (free_pool[j]) begin
                if (j == i_free_PRegs[i] - 1) begin
                    free_pool[j] = 1'b1;
                end
            end
        end

        // Rename
        foreach (i_decode_data[i]) begin
            o_rename_data[i].immediate = i_decode_data[i].immediate;
            o_rename_data[i].ALUOp     = i_decode_data[i].ALUOp;
            o_rename_data[i].ALUSrc    = i_decode_data[i].ALUSrc;
            o_rename_data[i].RegWrite  = i_decode_data[i].RegWrite;
            o_rename_data[i].MemRead   = i_decode_data[i].MemRead;
            o_rename_data[i].MemWrite  = i_decode_data[i].MemWrite;
            o_rename_data[i].MemtoReg  = i_decode_data[i].MemtoReg;

            // Rename sources
            o_rename_data[i].PRegAddrSrc0 = physical_reg[i_decode_data[i].ARegAddrSrc0];
            o_rename_data[i].PRegAddrSrc1 = physical_reg[i_decode_data[i].ARegAddrSrc1];

            // Replace and rename dest
            if (|i_decode_data[i].ARegAddrDst)
                foreach (free_pool[j]) begin
                    if (free_pool[j]) begin
                        free_pool[j] = 0;
                        o_rename_data[i].OldPRegAddrDst = physical_reg[i_decode_data[i].ARegAddrDst];
                        o_rename_data[i].PRegAddrDst = j + 1;
                        physical_reg[i_decode_data[i].ARegAddrDst] = j + 1;
                        $display("Inst%i Dst replaced p%d with p%d", i, o_rename_data[i].OldPRegAddrDst, j + 1);
                        break;
                    end
                end
            else begin
                o_rename_data[i].OldPRegAddrDst = 0;
                o_rename_data[i].PRegAddrDst = 0;
                $display("Inst%i Dst is p0");
            end
        end
    end

endmodule : RENAME