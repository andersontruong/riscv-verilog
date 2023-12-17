import Types::*;

module DISPATCH(
    input  logic i_clk,
    input  rename_struct i_rename_data [0:1],

    input  word  i_r_reg_data [0:3],
    output p_reg o_r_reg_addr [0:3],

    input  logic i_free_fu [0:2],
    output logic o_free_fu [0:2],

    input rob_row_struct i_complete_rob_rows [0:2],

    // output rs_row_struct rows [0:15],
    output rs_row_struct o_issue_inst [0:2],

    output rob_row_struct o_rob_rows [0:1] // up to 2 new rows to add to ROB
);
    logic fu_counter = 0;
    logic free_p_regs [0:127];
    logic [3:0] ROB_pointer = 0;
    logic mem_issue_state = 0;
    rs_row_struct rows [0:15];

    // Request Register Data
    always_comb begin
        foreach(i_rename_data[i]) begin
            o_r_reg_addr[2*i] <= i_rename_data[i].PRegAddrSrc0;
            o_r_reg_addr[2*i + 1] <= i_rename_data[i].PRegAddrSrc1;
        end
    end

    assign free_p_regs[0] = 1;

    initial begin
        foreach (free_p_regs[i]) begin
            free_p_regs[i] = 1'b1;
        end
        foreach (rows[i])
            rows[i].in_use <= 0;

        foreach(o_free_fu[i])
            o_free_fu[i] <= 1;
    end
    
    always_ff @(posedge i_clk) begin
        
    end

    always_ff @(posedge i_clk) begin
        // Handle Retire Dependencies
        foreach(i_complete_rob_rows[i]) begin
            if (i_complete_rob_rows[i].valid) begin
                free_p_regs[i_complete_rob_rows[i].PRegAddrDst] = 1;
                foreach(rows[j]) begin
                    if (rows[j].PRegAddrSrc0 == i_complete_rob_rows[i].PRegAddrDst) begin
                        rows[j].src0 = i_complete_rob_rows[i].data;
                        rows[j].Src0Ready = 1;
                        
                    end
                    if (rows[j].PRegAddrSrc1 == i_complete_rob_rows[i].PRegAddrDst) begin
                        rows[j].src1 = i_complete_rob_rows[i].data;
                        rows[j].Src1Ready = 1;
                    end
                end
            end
        end

        // Dispatch
        foreach (i_rename_data[i]) begin
            if (^i_rename_data[i].PRegAddrSrc0 !== 1'bX && ^i_rename_data[i].PRegAddrSrc1 !== 1'bX && |i_rename_data[i].ALUOp) begin
                for (int j = 0; j < 16; j++) begin
                    if (rows[j].in_use != 1) begin
                        $display("DISPATCH Issue %d:", i);
                        $display("\tSrc0: %d\n\t\tR? %d\n\t\t\tData: %8x", i_rename_data[i].PRegAddrSrc0, free_p_regs[i_rename_data[i].PRegAddrSrc0], i_r_reg_data[2*i]);
                        $display("\tSrc1: %d\n\t\tR? %d\n\t\t\tData: %8x", i_rename_data[i].PRegAddrSrc1, free_p_regs[i_rename_data[i].PRegAddrSrc1], i_r_reg_data[2*i + 1]);
                        $display("\tImmediate: %d", i_rename_data[i].immediate);
                        $display("\tDst:  %d", i_rename_data[i].PRegAddrDst);
                        $display("\t\tOldDst:  %d", i_rename_data[i].OldPRegAddrDst);

                        o_rob_rows[i] <= '{
                            ROBNumber: ROB_pointer,
                            valid: 1,
                            PRegAddrDst: i_rename_data[i].PRegAddrDst,
                            OldPRegAddrDst: i_rename_data[i].OldPRegAddrDst,
                            complete: 0,
                            data: 0,
                            RegWrite: i_rename_data[i].RegWrite,
                            MemWrite: i_rename_data[i].MemWrite
                        };

                        // $display("%d, Reserved at %d to DST %d", i, j, i_rename_data[i].PRegAddrDst);
                        rows[j].in_use = 1;
                        rows[j].PRegAddrDst <= i_rename_data[i].PRegAddrDst;
                        rows[j].OldPRegAddrDst <= i_rename_data[i].OldPRegAddrDst;

                        if (|i_rename_data[i].PRegAddrDst)
                            free_p_regs[i_rename_data[i].PRegAddrDst] <= 0;

                        rows[j].PRegAddrSrc0 <= i_rename_data[i].PRegAddrSrc0;
                        rows[j].Src0Ready <= free_p_regs[i_rename_data[i].PRegAddrSrc0];
                        rows[j].src0 <= i_r_reg_data[2*i];

                        rows[j].PRegAddrSrc1 <= i_rename_data[i].PRegAddrSrc1;
                        rows[j].Src1Ready <= free_p_regs[i_rename_data[i].PRegAddrSrc1];
                        rows[j].src1 <= i_r_reg_data[2*i + 1];

                        rows[j].immediate <= i_rename_data[i].immediate;

                        rows[j].ALUOp    <= i_rename_data[i].ALUOp;
                        rows[j].ALUSrc   <= i_rename_data[i].ALUSrc;
                        rows[j].RegWrite <= i_rename_data[i].RegWrite;
                        rows[j].MemRead  <= i_rename_data[i].MemRead;
                        rows[j].MemWrite <= i_rename_data[i].MemWrite;
                        rows[j].ROBNumber = ROB_pointer;

                        ROB_pointer = ROB_pointer + 1;

                        // LW
                        if ((i_rename_data[i].ALUOp == 3'b001) && (i_rename_data[i].ALUSrc == 1) && (i_rename_data[i].RegWrite == 1)
                            && (i_rename_data[i].MemRead == 1) && (i_rename_data[i].MemWrite == 0))
                            rows[j].fu <= 2'b10;
                        // Else SW doesn't need Memory Read
                        else begin
                            rows[j].fu = fu_counter;
                            fu_counter = fu_counter + 1;
                        end

                        break;
                    end
                end
            end
            else begin
                o_rob_rows[i] <= '{
                    ROBNumber: 'X,
                    valid: 0,
                    PRegAddrDst: 0,
                    OldPRegAddrDst: 0,
                    complete: 0,
                    data: 0,
                    RegWrite: 0,
                    MemWrite: 0
                };
            end
        end
        foreach (o_free_fu[i])
            o_free_fu[i] = i_free_fu[i];

        

        // Issue instruction
        // FU 0/1 Instructions
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 16; j++) begin
                if (rows[j].in_use && rows[j].Src0Ready && rows[j].Src1Ready && i_free_fu[rows[j].fu] && i == rows[j].fu && |rows[j].ALUOp) begin
                    // $display("Issued %d to DST %d", i, rows[j].PRegAddrDst);
                    $display("ISSUE Issue %d:", i);
                    $display("\tSrc0: %d\n\t\tR? %d\n\t\t\tData: %8x", rows[j].PRegAddrSrc0, rows[j].Src0Ready, rows[j].src0);
                    $display("\tSrc1: %d\n\t\tR? %d\n\t\t\tData: %8x", rows[j].PRegAddrSrc1, rows[j].Src1Ready, rows[j].src1);
                    $display("\tImmediate: %d", rows[j].immediate);
                    $display("\tDst:  %d", rows[j].PRegAddrDst);
                    $display("\t\tOldDst:  %d", rows[j].OldPRegAddrDst);
                    rows[j].in_use <= 1'b0;

                    o_issue_inst[i] <= rows[j];
                    o_free_fu[rows[j].fu] <= 0;

                    $display("\tFinished Issued %d to DST %d, in-use at %d? %d", i, rows[j].PRegAddrDst, j, rows[j].in_use);
                    break;
                end
                if (j == 15) begin
                    o_issue_inst[i] <= '{
                        in_use: 0,
                        PRegAddrDst: 0,
                        OldPRegAddrDst: 0,
                        PRegAddrSrc0: 0,
                        Src0Ready: 0,
                        src0: 'X,
                        PRegAddrSrc1: 0,
                        Src1Ready: 0,
                        src1: 'X,
                        immediate: 0,
                        ALUOp: 0,
                        ALUSrc: 0,
                        RegWrite: 0,
                        MemRead: 0,
                        MemWrite: 0,
                        fu: 0,
                        ROBNumber: 'X
                    };
                end
            end
        end

        // Mem Instruction
        for (int j = 0; j < 16; j++) begin
            if (rows[j].in_use && rows[j].Src0Ready && rows[j].Src1Ready && rows[j].fu == 2 && i_free_fu[rows[j].fu] && mem_issue_state == 0) begin
                // $display("Issued %d to DST %d", i, rows[j].PRegAddrDst);
                $display("ISSUE Issue %d:", 2);
                $display("\tSrc0: %d\n\t\tR? %d\n\t\t\tData: %8x", rows[j].PRegAddrSrc0, rows[j].Src0Ready, rows[j].src0);
                $display("\tSrc1: %d\n\t\tR? %d\n\t\t\tData: %8x", rows[j].PRegAddrSrc1, rows[j].Src1Ready, rows[j].src1);
                $display("\tImmediate: %d", rows[j].immediate);
                $display("\tDst:  %d", rows[j].PRegAddrDst);
                $display("\t\tOldDst:  %d", rows[j].OldPRegAddrDst);
                rows[j].in_use <= 1'b0;

                o_issue_inst[2] <= rows[j];
                o_free_fu[2] <= 0;
                if (|rows[j].PRegAddrDst)
                    free_p_regs[rows[j].PRegAddrDst] <= 0;

                mem_issue_state <= 1;

                $display("\tFinished Issued %d to DST %d, in-use at %d? %d", 2, rows[j].PRegAddrDst, j, rows[j].in_use);
                break;
            end
            else if (j == 15) begin
                if (mem_issue_state == 0) begin
                        o_issue_inst[2] <= '{
                        in_use: 0,
                        PRegAddrDst: 0,
                        OldPRegAddrDst: 0,
                        PRegAddrSrc0: 0,
                        Src0Ready: 0,
                        src0: 'X,
                        PRegAddrSrc1: 0,
                        Src1Ready: 0,
                        src1: 'X,
                        immediate: 0,
                        ALUOp: 0,
                        ALUSrc: 0,
                        RegWrite: 0,
                        MemRead: 0,
                        MemWrite: 0,
                        fu: 0,
                        ROBNumber: 'X
                    };
                end
                else
                    mem_issue_state <= 0;
            end
        end
    end

endmodule : DISPATCH
