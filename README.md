# Digital Phase-Locked Loop (DPLL)

An FPGA-oriented implementation of a **Digital Phase-Locked Loop (DPLL)** in Verilog. This project was developed to understand the architecture and operation of digital clock recovery systems, including phase detection, loop filtering, and Numerically Controlled Oscillators (NCOs).

The implementation demonstrates how a digital feedback loop synchronizes an internally generated clock with an external reference clock using only digital logic.

---

## Features

- Digital phase detector
- Phase accumulator based Numerically Controlled Oscillator (NCO)
- Configurable loop gain
- Optional frequency tracking
- Glitch-free phase correction
- Parameterizable phase accumulator width

---

## Architecture

```
                     Reference Clock
                            │
                            ▼
                  +-------------------+
                  |  Phase Detector   |
                  +-------------------+
                            │
                     Phase Error
                            │
                            ▼
                  +-------------------+
                  |    Loop Filter    |
                  | Phase/Freq Gain   |
                  +-------------------+
                            │
                            ▼
                  +-------------------+
                  |        NCO        |
                  | Phase Accumulator |
                  +-------------------+
                            │
                            ▼
                    Generated Clock
```

---

## Working Principle

### 1. Phase Detection

The phase detector compares the most significant bit (MSB) of the internal phase accumulator with the incoming reference clock.

Whenever the two signals differ, a phase error is generated.

The detector also determines whether the internal oscillator is:

- Leading the reference clock
- Lagging the reference clock

---

### 2. Loop Filter

The loop filter determines how aggressively the PLL should react to a phase error.

Two corrections are generated:

- Phase correction
- Frequency correction

The loop gain is configurable using the `i_lgcoeff` input.

Higher gain results in faster locking but increased jitter.

Lower gain provides smoother operation with slower lock time.

---

### 3. Numerically Controlled Oscillator (NCO)

The NCO is implemented using a phase accumulator.

Every clock cycle,

```
phase_accumulator = phase_accumulator + frequency_word
```

The most significant bit of the accumulator acts as the generated clock.

---

### 4. Frequency Tracking

If enabled, the PLL continuously updates its frequency estimate.

When the internal oscillator leads the reference,

```
frequency_word = frequency_word - frequency_gain
```

When it lags,

```
frequency_word = frequency_word + frequency_gain
```

This allows the PLL to track slow frequency variations of the input clock.

---


## Future Improvements

- Add a proportional-integral (PI) digital loop filter
- Implement a sine-wave NCO using Look-Up-Tables(LUTs)
- FPGA implementation and hardware validation

---

## Tools Used

- Xilinx Vivado
- GitHub

---

## Learning Outcomes

Through this project I gained practical experience with:

- Digital Phase-Locked Loops
- Numerically Controlled Oscillators
- Phase Accumulators
- Digital Feedback Systems
- Clock Recovery
- FPGA RTL Design
- Verilog Simulation and Verification

---
