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

    initial begin
        foreach (o_complete_result[i])
            o_complete_result[i].ready <= 0;
    end

    always_ff @(posedge i_clk) begin
        for (int i = 0; i < 2; i++) begin
            if (alu_valid[i]) begin
                o_complete_result[i].ready <= 1;
                o_complete_result[i].FU_Result <= alu_result[i];
            end
            else begin
                o_complete_result[i].ready <= 0;
                o_complete_result[i].FU_Result <= 0;
            end
        end
        if (alu_valid[2] && ^i_r_mem_data !== 1'bX) begin
            o_complete_result[2].ready <= 1;
            o_complete_result[2].FU_Result <= i_r_mem_data;
        end
        else begin
            o_complete_result[2].ready <= 0;
            o_complete_result[2].FU_Result <= 0;
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