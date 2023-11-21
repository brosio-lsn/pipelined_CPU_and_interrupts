# FPGA-Based Stopwatch and Pipelined CPU Implementation

## Introduction
This repository contains two interrelated projects: a stopwatch implemented on an FPGA with VHDL, and a 5-stage pipelined CPU also implemented in VHDL. 

## Part 1: Stopwatch with Polling and Interrupts
The first part involves a stopwatch capable of measuring time intervals, reacting to user input, and implementing both polling and interrupt-driven mechanisms for interactions between the CPU and hardware timer.

## Part 2: 5-Stage Pipelined CPU
The second part extends the concepts of CPU design to a pipelined architecture. It involves creating a simplified version of the Nios II processor with a 5-stage pipeline, adapting to a Harvard architecture to avoid stalling, and handling the intricacies of pipelined execution without data forwarding.

## Features
- VHDL implementation of a stopwatch with hardware timer
- Polling and regular interrupt mechanisms
- Design of a 5-stage instruction pipeline
- Reorganization of CPU components for pipeline efficiency

## Acknowledgements
Special thanks to EPFL for providing the framework and guidance for these projects.
