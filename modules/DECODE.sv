import Types::*;

module DECODE(
    input  logic i_clk,
    input  word i_instA, i_instB,
    output decode_struct o_decode_dataA, o_decode_dataB
);
    word insts [0:1];
    decode_struct decode_data [0:1];

    assign insts[0] = i_instA;
    assign insts[1] = i_instB;

    assign o_decode_dataA = decode_data[0];
    assign o_decode_dataB = decode_data[1];

    always @(posedge i_clk) begin
        foreach (insts[i]) begin
            case (insts[i][6:0])
                // Handle R-type instruction
                7'b0110011:
                    begin
                        decode_data[i].ARegAddrSrc0 <= insts[i][19:15];
                        decode_data[i].ARegAddrSrc1 <= insts[i][24:20];
                        decode_data[i].ARegAddrDst  <= insts[i][11:7];
                        decode_data[i].immediate    <= 0;

                        // ADD
                        if      (insts[i][31:25] == 7'h00 && insts[i][14:12] == 3'h0)
                            decode_data[i].ALUOp    <= 3'b001;
                        // SUB
                        else if (insts[i][31:25] == 7'h20 && insts[i][14:12] == 3'h0)
                            decode_data[i].ALUOp    <= 3'b010;
                        // XOR
                        else if (insts[i][31:25] == 7'h00 && insts[i][14:12] == 3'h4)
                            decode_data[i].ALUOp    <= 3'b010;
                        // SRA
                        else if (insts[i][31:25] == 7'h20 && insts[i][14:12] == 3'h5)
                            decode_data[i].ALUOp    <= 3'b010;

                        decode_data[i].ALUSrc       <= 0;
                        decode_data[i].RegWrite     <= 1;
                        decode_data[i].MemRead      <= 0;
                        decode_data[i].MemWrite     <= 0;
                        decode_data[i].MemtoReg     <= 1;
                    end

                // Handle I-type instruction (non-load)
                7'b0010011:
                    begin
                        decode_data[i].ARegAddrSrc0 <= insts[i][19:15];
                        decode_data[i].ARegAddrSrc1 <= 0;
                        decode_data[i].ARegAddrDst  <= insts[i][11:7];
                        decode_data[i].immediate    <= insts[i][31:20];
                        
                        // ADDI
                        if (insts[i][14:12] == 3'h0)
                            decode_data[i].ALUOp    <= 3'b001;
                        // ANDI
                        else if (insts[i][14:12] == 3'h7)
                            decode_data[i].ALUOp    <= 3'b100; 

                        decode_data[i].ALUSrc       <= 1;
                        decode_data[i].RegWrite     <= 1;
                        decode_data[i].MemRead      <= 0;
                        decode_data[i].MemWrite     <= 0;
                        decode_data[i].MemtoReg     <= 1;
                    end

                // Handle LW instruction
                7'b0000011:
                    begin
                        decode_data[i].ARegAddrSrc0 <= insts[i][19:15];
                        decode_data[i].ARegAddrSrc1 <= 0;
                        decode_data[i].ARegAddrDst  <= insts[i][11:7];
                        decode_data[i].immediate    <= insts[i][31:20];
                        decode_data[i].ALUOp        <= 3'b001;
                        decode_data[i].ALUSrc       <= 1;
                        decode_data[i].RegWrite     <= 1;
                        decode_data[i].MemRead      <= 1;
                        decode_data[i].MemWrite     <= 0;
                        decode_data[i].MemtoReg     <= 0;
                    end

                // Handle SW instruction
                7'b0100011:
                    begin
                        decode_data[i].ARegAddrSrc0 <= insts[i][19:15];
                        decode_data[i].ARegAddrSrc1 <= insts[i][24:20];
                        decode_data[i].ARegAddrDst  <= 0;
                        decode_data[i].immediate    <= { insts[i][31:25], insts[i][11:7] };
                        decode_data[i].ALUOp        <= 3'b001;
                        decode_data[i].ALUSrc       <= 1;
                        decode_data[i].RegWrite     <= 0;
                        decode_data[i].MemRead      <= 0;
                        decode_data[i].MemWrite     <= 1;
                        decode_data[i].MemtoReg     <= 0;
                    end

                default:
                    begin
                        decode_data[i].ARegAddrSrc0 <= 0;
                        decode_data[i].ARegAddrSrc1 <= 0;
                        decode_data[i].ARegAddrDst  <= 0;
                        decode_data[i].immediate    <= 0;
                        decode_data[i].ALUOp        <= 0;
                        decode_data[i].ALUSrc       <= 0;
                        decode_data[i].RegWrite     <= 0;
                        decode_data[i].MemRead      <= 0;
                        decode_data[i].MemWrite     <= 0;
                        decode_data[i].MemtoReg     <= 0;
                    end
            endcase
        end
    end

endmodule : DECODE