import Types::*;

module ISSUE(
    input  logic i_clk,
    input  rs_row_struct i_issue_inst [0:2],
    input  word i_r_mem_data,
    output word i_r_mem_addr,
    output complete_stage_struct o_complete_result [0:2]
);
    word alu_result [0:2];
    logic alu_valid [0:2];
    logic mem_issue_state = 0;

    initial begin
        foreach (o_complete_result[i])
            o_complete_result[i].ready <= 0;
        i_r_mem_addr = 'X;
    end

    always_ff @(posedge i_clk) begin
        for (int i = 0; i < 2; i++) begin
            if (alu_valid[i] && ^alu_valid[i] !== 1'bX) begin
                o_complete_result[i] <= '{
                    ROBNumber: i_issue_inst[i].ROBNumber,
                    RegWrite: i_issue_inst[i].RegWrite,
                    MemWrite: i_issue_inst[i].MemWrite,
                    MemtoReg: i_issue_inst[i].MemtoReg,
                    ready: 1,
                    fu: i,
                    FU_Result: alu_result[i]
                };
            end
            else begin
                o_complete_result[i] <= '{
                    ROBNumber: 'X,
                    RegWrite: 'X,
                    MemWrite: 'X,
                    MemtoReg: 'X,
                    ready: 'X,
                    fu: 'X,
                    FU_Result: 'X
                };
            end
        end

        if (alu_valid[2] && ^alu_valid[2] !== 1'bX && ^i_r_mem_data !== 1'bX) begin
            o_complete_result[2] <= '{
                ROBNumber: i_issue_inst[2].ROBNumber,
                RegWrite: i_issue_inst[2].RegWrite,
                MemWrite: i_issue_inst[2].MemWrite,
                MemtoReg: i_issue_inst[2].MemtoReg,
                ready: 1,
                fu: 2,
                FU_Result: i_r_mem_data
            };
        end
        else begin
            o_complete_result[2] <= '{
                ROBNumber: 'X,
                RegWrite: 'X,
                MemWrite: 'X,
                MemtoReg: 'X,
                ready: 'X,
                fu: 'X,
                FU_Result: 'X
            };
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