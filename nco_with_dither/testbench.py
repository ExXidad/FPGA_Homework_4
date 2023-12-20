import cocotb
from cocotb.triggers import Timer
import numpy as np
from matplotlib import pyplot as plt
from binary_fractions import Binary


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
    step_integer_part_width = int(dut.STEP_INTEGER_PART_WIDTH.value)
    step_fractional_part_width = int(dut.STEP_FRACTIONAL_PART_WIDTH.value)
    step_width = int(dut.STEP_WIDTH.value)
    period = int(dut.PERIOD.value)
    desired_frequency = 100e6
    samplingFrequency = 1e9
    step = period * desired_frequency / samplingFrequency
    dut.step.value = int(step * (2 ** step_fractional_part_width))
    periods = 100
    clock_cycles = int(1. * period * periods / step)

    await reset(dut)

    await cocotb.start(generate_clock(dut, 1))

    out_data = np.zeros(clock_cycles)
    for i in range(clock_cycles):
        out_data[i] = dut.out.value
        await clock_cycle(dut)

    await Timer(10, units="ns")

    out_data_fft = np.abs(np.fft.rfft(out_data, norm="forward"))
    out_data_fft[0] = 0
    out_data_freq = np.array(range(len(out_data_fft))) / len(out_data_fft)

    plt.plot(out_data_freq, out_data_fft, linewidth=0.8)
    plt.yscale("log")
    plt.ylim([1e-3, 1e3])
    # plt.xlim([0, 0.1])
    plt.show()

    with open('../data.txt', 'w') as f:
        for out in out_data:
            f.write(f"{out}\n")


async def run_and_dump(dut, desired_frequency):
    # Set step
    step_integer_part_width = int(dut.STEP_INTEGER_PART_WIDTH.value)
    step_fractional_part_width = int(dut.STEP_FRACTIONAL_PART_WIDTH.value)
    step_width = int(dut.STEP_WIDTH.value)
    period = int(dut.PERIOD.value)
    samplingFrequency = 1e9
    step = period * desired_frequency / samplingFrequency
    dut.step.value = int(step * (2 ** step_fractional_part_width))
    periods = 100
    clock_cycles = int(1. * period * periods / step)

    await reset(dut)

    await cocotb.start(generate_clock(dut, 1))

    out_data = np.zeros(clock_cycles)
    for i in range(clock_cycles):
        out_data[i] = dut.out.value
        await clock_cycle(dut)

    await Timer(10, units="ns")

    with open(f'../text_files/data_dither_{desired_frequency}.txt', 'w') as f:
        for out in out_data:
            f.write(f"{out}\n")


@cocotb.test()
async def test_sweep(dut):
    freq_list = [1e6,10e6,100e6,123.123123e6]
    for freq in freq_list:
        await run_and_dump(dut, freq)
