import Types::*;

module ISSUE(
    input  logic i_clk,
    input  rs_row_struct i_issue_inst [0:2],
    input  word i_r_mem_data,
    output word i_r_mem_addr,
    output logic o_fu_ready [0:2],
    output rob_row_struct o_complete_rob_row [0:2]
);
    word alu_result [0:2];
    logic alu_valid [0:2];
    logic mem_issue_state = 0;

    initial begin
        foreach (o_complete_rob_row[i])
            o_complete_rob_row[i].valid <= 0;
        i_r_mem_addr = 'X;
    end

    always_ff @(posedge i_clk) begin
        for (int i = 0; i < 2; i++) begin
            if (alu_valid[i] && ^alu_valid[i] !== 1'bX) begin
                o_complete_rob_row[i] <= '{
                    ROBNumber: i_issue_inst[i].ROBNumber,
                    valid: 1,
                    PRegAddrDst: i_issue_inst[i].PRegAddrDst,
                    OldPRegAddrDst: i_issue_inst[i].OldPRegAddrDst,
                    complete: 0,
                    data: alu_result[i],
                    RegWrite: i_issue_inst[i].RegWrite,
                    MemWrite: i_issue_inst[i].MemWrite
                };
                o_fu_ready[i] <= 1;
            end
            else begin
                o_complete_rob_row[i] <= '{
                    ROBNumber: 'X,
                    valid: 0,
                    PRegAddrDst: 'X,
                    OldPRegAddrDst: 'X,
                    complete: 0,
                    data: 'X,
                    RegWrite: 'X,
                    MemWrite: 'X
                };
                o_fu_ready[i] <= 0;
            end
        end

        if (alu_valid[2] && ^alu_valid[2] !== 1'bX && ^i_r_mem_data !== 1'bX) begin
            o_complete_rob_row[2] <= '{
                ROBNumber: i_issue_inst[2].ROBNumber,
                valid: 1,
                PRegAddrDst: i_issue_inst[2].PRegAddrDst,
                OldPRegAddrDst: i_issue_inst[2].OldPRegAddrDst,
                complete: 0,
                data: i_r_mem_data,
                RegWrite: i_issue_inst[2].RegWrite,
                MemWrite: i_issue_inst[2].MemWrite
            };
            o_fu_ready[2] <= 1;
        end
        else begin
            o_complete_rob_row[2] <= '{
                ROBNumber: 'X,
                valid: 0,
                PRegAddrDst: 'X,
                OldPRegAddrDst: 'X,
                complete: 0,
                data: 'X,
                RegWrite: 'X,
                MemWrite: 'X
            };
            o_fu_ready[2] <= 0;
        end
    end

    alu alu0(
        .i_ALUOp(i_issue_inst[0].ALUOp),
        .i_operand0(i_issue_inst[0].src0), 
        .i_operand1(i_issue_inst[0].ALUSrc ? i_issue_inst[0].immediate : i_issue_inst[0].src1),
        .o_valid(alu_valid[0]),
        .o_result(alu_result[0])
    );

    alu alu1(

        .i_ALUOp(i_issue_inst[1].ALUOp),
        .i_operand0(i_issue_inst[1].src0), 
        .i_operand1(i_issue_inst[1].ALUSrc ? i_issue_inst[1].immediate : i_issue_inst[1].src1),
        .o_valid(alu_valid[1]),
        .o_result(alu_result[1])
    );

    alu alu2(

        .i_ALUOp(3'b001),
        .i_operand0(i_issue_inst[2].src0), 
        .i_operand1(i_issue_inst[2].ALUSrc ? i_issue_inst[2].immediate : i_issue_inst[2].src1),
        .o_valid(alu_valid[2]),
        .o_result(i_r_mem_addr)
    );

endmodule: ISSUE