import Types::*;

module DISPATCH(
    input  logic i_clk,
    input rename_struct i_rename_data [0:1],
    output rob_row_struct o_rob_rows [0:1], // up to 2 new rows to add to ROB
    output rs_row_struct o_rs_rows [0:1] // up to 2 new rows to add to reservation station
);

    always @(posedge i_clk) begin

        // prepare rows to add to ROB (make ROB in later module)
        foreach (o_rob_rows[i]) begin
            o_rob_rows[i].valid <= 1;
            o_rob_rows[i].PRegAddrDst <= i_rename_data[i].PRegAddrDst;
            o_rob_rows[i].OldPRegAddrDst <= i_rename_data[i].OldPRegAddrDst;
            o_rob_rows[i].complete <= 0;
        end

        // prepare rows to add to reservation station (make RS in later module)
        foreach (o_rs_rows[i]) begin
            o_rs_rows[i].use <= 1;
            o_rs_rows[i].ALUOp <= i_rename_data[i].ALUOp;
            o_rs_rows[i].PRegAddrDst <= i_rename_data[i].PRegAddrDst;
            o_rs_rows[i].PRegAddrSrc0 <= i_rename_data[i].PRegAddrSrc0;
            o_rs_rows[i].Src0Ready <= 0; // TODO --> do this in RS (check rest of entries in RS)
            o_rs_rows[i].PRegAddrSrc1 <= i_rename_data[i].PRegAddrSrc1;
            o_rs_rows[i].Src1Ready <= 0; // TODO --> do this in RS (check rest of entries in RS)
            o_rs_rows[i].immediate <= i_rename_data[i].immediate;

            // LW instruction
            if ((i_rename_data[i].ALUOp == 3'b001) && (i_rename_data[i].ALUSrc == 1) && (i_rename_data[i].RegWrite == 0)
                && (i_rename_data[i].MemRead == 0) && (i_rename_data[i].MemWrite == 1) && (i_rename_data[i].MemtoReg == 0))
                o_rs_rows[i].fu <= 2'b10;
            // SW instruction
            else if ((i_rename_data[i].ALUOp == 3'b001) && (i_rename_data[i].ALUSrc == 1) && (i_rename_data[i].RegWrite == 1)
                && (i_rename_data[i].MemRead == 1) && (i_rename_data[i].MemWrite == 0) && (i_rename_data[i].MemtoReg == 0))
                o_rs_rows[i].fu <= 2'b10;
            else
                o_rs_rows[i].fu <= 0; // TODO: this makes the default FU the first one (just as a placeholder), need to add a variable or smthn to determine which FU is free
            
            o_rs_rows[i].ROBNumber <= 0; // TODO --> do this in ROB
        end

    end

endmodule : DISPATCH
