import cocotb
from cocotb.triggers import Timer
import numpy as np
from matplotlib import pyplot as plt


async def clock_cycle(dut):
    dut.clk.value = 0
    await Timer(0.5, units="ns")
    dut.clk.value = 1
    await Timer(0.5, units="ns")


async def generate_clock(dut, num_clocks):
    for cycle in range(num_clocks):
        await clock_cycle(dut)


async def reset(dut):
    dut.rst.value = 1
    await Timer(1, units="ns")
    dut.rst.value = 0
    await Timer(1, units="ns")


@cocotb.test()
async def test(dut):
    # Set step

    clock_cycles = 1000

    await reset(dut)

    await cocotb.start(generate_clock(dut, 1))

    out_data = np.zeros(clock_cycles)
    for i in range(clock_cycles):
        print(dut.out.value)
        out_data[i] = dut.out.value
        await clock_cycle(dut)

    await Timer(10, units="ns")

    plt.plot(out_data, linewidth=0.8)
    # plt.yscale("log")
    # plt.ylim([1e-3, 1e3])
    # plt.xlim([0, 0.1])
    plt.show()

    with open('../data.txt', 'w') as f:
        for out in out_data:
            f.write(f"{out}\n")
