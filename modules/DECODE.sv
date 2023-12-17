import Types::*;

module DECODE(
    input  logic i_clk,
    input  word i_insts [0:1],
    output decode_struct o_decode_data [0:1]
);
    always @(posedge i_clk) begin
        
        foreach (i_insts[i]) begin
            $display("DECODE Issue %d:", i);
            if (|i_insts[i] == 0) begin
                $display("\tNOP===");
                $display("\tSrc0: %d", 0);
                $display("\tSrc1: %d", 0);
                $display("\tImmediate:  %d", 0);
                $display("\tDst:  %d", 0);
                o_decode_data[i].ARegAddrSrc0 <= 0;
                o_decode_data[i].ARegAddrSrc1 <= 0;
                o_decode_data[i].ARegAddrDst  <= 0;
                o_decode_data[i].immediate    <= 0;
                o_decode_data[i].ALUOp        <= 0;
                o_decode_data[i].ALUSrc       <= 0;
                o_decode_data[i].RegWrite     <= 0;
                o_decode_data[i].MemRead      <= 0;
                o_decode_data[i].MemWrite     <= 0;
            end
            else begin
                case (i_insts[i][6:0])
                    // Handle R-type instruction
                    7'b0110011:
                        begin
                            $display("\tSrc0: %d", i_insts[i][19:15]);
                            $display("\tSrc1: %d", i_insts[i][24:20]);
                            $display("\tImmediate:  %d", 0);
                            $display("\tDst:  %d", i_insts[i][11:7]);
                            
                            o_decode_data[i].ARegAddrSrc0 <= i_insts[i][19:15];
                            o_decode_data[i].ARegAddrSrc1 <= i_insts[i][24:20];
                            o_decode_data[i].ARegAddrDst  <= i_insts[i][11:7];
                            o_decode_data[i].immediate    <= 0;

                            // ADD
                            if      (i_insts[i][31:25] == 7'h00 && i_insts[i][14:12] == 3'h0)
                                o_decode_data[i].ALUOp    <= 3'b001;
                            // SUB
                            else if (i_insts[i][31:25] == 7'h20 && i_insts[i][14:12] == 3'h0)
                                o_decode_data[i].ALUOp    <= 3'b010;
                            // XOR
                            else if (i_insts[i][31:25] == 7'h00 && i_insts[i][14:12] == 3'h4)
                                o_decode_data[i].ALUOp    <= 3'b011;
                            // SRA
                            else if (i_insts[i][31:25] == 7'h20 && i_insts[i][14:12] == 3'h5)
                                o_decode_data[i].ALUOp    <= 3'b101;

                            o_decode_data[i].ALUSrc       <= 0;
                            o_decode_data[i].RegWrite     <= 1;
                            o_decode_data[i].MemRead      <= 0;
                            o_decode_data[i].MemWrite     <= 0;
                        end

                    // Handle I-type instruction (non-load)
                    7'b0010011:
                        begin
                            $display("\tI-Type===");
                            $display("\tSrc0: %d", i_insts[i][19:15]);
                            $display("\tSrc1: %d", 0);
                            $display("\tImmediate:  %d", i_insts[i][31:20]);
                            $display("\tDst:  %d", i_insts[i][11:7]);
                            
                            o_decode_data[i].ARegAddrSrc0 <= i_insts[i][19:15];
                            o_decode_data[i].ARegAddrSrc1 <= 0;
                            o_decode_data[i].ARegAddrDst  <= i_insts[i][11:7];
                            o_decode_data[i].immediate    <= i_insts[i][31:20];
                            
                            // ADDI
                            if (i_insts[i][14:12] == 3'h0)
                                o_decode_data[i].ALUOp    <= 3'b001;
                            // ANDI
                            else if (i_insts[i][14:12] == 3'h7)
                                o_decode_data[i].ALUOp    <= 3'b100; 

                            o_decode_data[i].ALUSrc       <= 1;
                            o_decode_data[i].RegWrite     <= 1;
                            o_decode_data[i].MemRead      <= 0;
                            o_decode_data[i].MemWrite     <= 0;
                        end

                    // Handle LW instruction
                    7'b0000011:
                        begin
                            $display("\tLW===");
                            $display("\tSrc0: %d", i_insts[i][19:15]);
                            $display("\tSrc1: %d", 0);
                            $display("\tImmediate:  %d", i_insts[i][31:20]);
                            $display("\tDst:  %d", i_insts[i][11:7]);

                            o_decode_data[i].ARegAddrSrc0 <= i_insts[i][19:15];
                            o_decode_data[i].ARegAddrSrc1 <= 0;
                            o_decode_data[i].ARegAddrDst  <= i_insts[i][11:7];
                            o_decode_data[i].immediate    <= i_insts[i][31:20];
                            o_decode_data[i].ALUOp        <= 3'b001;
                            o_decode_data[i].ALUSrc       <= 1;
                            o_decode_data[i].RegWrite     <= 1;
                            o_decode_data[i].MemRead      <= 1;
                            o_decode_data[i].MemWrite     <= 0;
                        end

                    // Handle SW instruction
                    7'b0100011:
                        begin
                            $display("\tSW===");
                            $display("\tSrc0: %d", i_insts[i][19:15]);
                            $display("\tSrc1: %d", i_insts[i][24:20]);
                            $display("\tImmediate:  %d", { i_insts[i][31:25], i_insts[i][11:7] });
                            $display("\tDst:  %d", 0);
                            
                            o_decode_data[i].ARegAddrSrc0 <= i_insts[i][19:15];
                            o_decode_data[i].ARegAddrSrc1 <= i_insts[i][24:20];
                            o_decode_data[i].ARegAddrDst  <= 0;
                            o_decode_data[i].immediate    <= { i_insts[i][31:25], i_insts[i][11:7] };
                            o_decode_data[i].ALUOp        <= 3'b001;
                            o_decode_data[i].ALUSrc       <= 1;
                            o_decode_data[i].RegWrite     <= 0;
                            o_decode_data[i].MemRead      <= 0;
                            o_decode_data[i].MemWrite     <= 1;
                        end

                    7'b0000000:
                        begin
                            $display("\tNOP===");
                            $display("\tSrc0: %d", 0);
                            $display("\tSrc1: %d", 0);
                            $display("\tImmediate:  %d", 0);
                            $display("\tDst:  %d", 0);
                            o_decode_data[i].ARegAddrSrc0 <= 0;
                            o_decode_data[i].ARegAddrSrc1 <= 0;
                            o_decode_data[i].ARegAddrDst  <= 0;
                            o_decode_data[i].immediate    <= 0;
                            o_decode_data[i].ALUOp        <= 0;
                            o_decode_data[i].ALUSrc       <= 0;
                            o_decode_data[i].RegWrite     <= 0;
                            o_decode_data[i].MemRead      <= 0;
                            o_decode_data[i].MemWrite     <= 0;
                        end
                endcase
            end
            
            
        end
    end

endmodule : DECODE