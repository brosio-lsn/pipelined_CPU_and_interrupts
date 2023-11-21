## Introduction
This project demonstrates the implementation of a stopwatch on an FPGA, using VHDL for the CPU design. It showcases two methods of interaction between the hardware timer and the CPU: polling and interrupt-driven execution.

## Features
- Hardware timer with both polling and regular interrupt capabilities.
- Start/stop and IRQ enable/disable controls via polling and interrupts.
- Dual-mode operation: count-down once or continuous.
- Interrupt service routines (ISRs) for handling timer expiries and button presses.

## Implementation Details
- Polling mechanism for timer status checks in a controlled loop.
- Regular interrupts to manage timer events and user inputs asynchronously.

## Acknowledgements
- EPFL for providing the educational resources and framework for the project.
