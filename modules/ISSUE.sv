import Types::*;

module ISSUE(
    input  logic i_clk,
    input  rs_row_struct i_issue_inst [0:2],
    input  word i_r_mem_data,
    output word i_r_mem_addr,
    output logic o_fu_ready [0:2],
    output p_reg forward_issue_result_addr [0:2],
    output word  forward_issue_result_data [0:2],
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

    always_comb begin
        for (int i = 0; i < 2; i++) begin
            if (alu_valid[i] && ^alu_valid[i] !== 1'bX) begin
                forward_issue_result_addr[i] <= i_issue_inst[i].PRegAddrDst;
                forward_issue_result_data[i] <= alu_result[i];
                o_fu_ready[i] <= 1;
            end
            else begin
                forward_issue_result_addr[i] <= 'X;
                forward_issue_result_data[i] <= 'X;
            end
        end
        if (alu_valid[2] && ^alu_valid[2] !== 1'bX && ^i_r_mem_data !== 1'bX) begin
            forward_issue_result_addr[2] <= i_issue_inst[2].PRegAddrDst;
            forward_issue_result_data[2] <= alu_result[2];
            o_fu_ready[2] <= 1;
        end
        else begin
            forward_issue_result_addr[2] <= 'X;
            forward_issue_result_data[2] <= 'X;
        end
    end

    always_ff @(posedge i_clk) begin
        for (int i = 0; i < 2; i++) begin
            if (alu_valid[i] && ^alu_valid[i] !== 1'bX) begin
                o_complete_result[i] <= '{
                    ROBNumber: i_issue_inst[i].ROBNumber,
                    RegWrite: i_issue_inst[i].RegWrite,
                    MemWrite: i_issue_inst[i].MemWrite,
                    ready: 1,
                    fu: i,
                    FU_Result: alu_result[i]
                };
                o_fu_ready[i] <= 1;
            end
            else begin
                o_complete_result[i] <= '{
                    ROBNumber: 'X,
                    RegWrite: 'X,
                    MemWrite: 'X,
                    ready: 'X,
                    fu: 'X,
                    FU_Result: 'X
                };
                o_fu_ready[i] <= 0;
            end
        end

        if (alu_valid[2] && ^alu_valid[2] !== 1'bX && ^i_r_mem_data !== 1'bX) begin
            o_complete_result[2] <= '{
                ROBNumber: i_issue_inst[2].ROBNumber,
                RegWrite: i_issue_inst[2].RegWrite,
                MemWrite: i_issue_inst[2].MemWrite,
                ready: 1,
                fu: 2,
                FU_Result: i_r_mem_data
            };
            o_fu_ready[2] <= 1;
        end
        else begin
            o_complete_result[2] <= '{
                ROBNumber: 'X,
                RegWrite: 'X,
                MemWrite: 'X,
                ready: 'X,
                fu: 'X,
                FU_Result: 'X
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