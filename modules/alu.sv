import Types::*;

module alu(
    input [2:0] i_ALUOp,
    input word i_operand0, i_operand1,
    output logic o_valid,
    output word o_result
);

    always_comb begin
        if (^i_operand0 !== 1'bX && ^i_operand1 !== 1'bX && |i_ALUOp) begin
            o_valid <= 1;
        end
        else 
            o_valid <= 0;
            
        case (i_ALUOp)
            3'b001:
                o_result <= i_operand0 + i_operand1;
            3'b010:
                o_result <= i_operand0 - i_operand1;
            3'b011:
                o_result <= i_operand0 ^ i_operand1;
            3'b100:
                o_result <= i_operand0 & i_operand1;
            3'b101:
                o_result <= i_operand0 >>> i_operand1;
            default:
                o_result <= 'X;
        endcase
    end

endmodule