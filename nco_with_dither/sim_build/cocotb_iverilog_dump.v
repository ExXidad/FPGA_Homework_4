module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/NCO.fst");
    $dumpvars(0, NCO);
end
endmodule
