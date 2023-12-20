module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/lfsr.fst");
    $dumpvars(0, lfsr);
end
endmodule
