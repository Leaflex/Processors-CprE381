# Comparative Perforamnce Analysis of Single Cycle, Software & Hardware Scheduled Pipelined Processors
Git repo containing code and documentation for Alexander Somers and Remmington Greatline's single and multi cycle processors design and analysis project. 

## Project Overview:
This project consisted of the design and comparison of three VHDL implemented processors, a single cycle processor, a software multi-cycle processor, and a hardware multi-cycle processor, as a team of two with Remmington Greatline and myself. The processors were built from scratch using VHDL implemented gates such as ANDs, ORs, XORs, etc, as the base for components like the arithmetic logic unit (ALU) or control unit. Once built, these processors underwent extensive testing using QuestSim before a comparative analysis of performance. The metrics for this analysis were cycles per instruction, maximum cycle time, and total execution time. Additional comparisons were also made for how each processor performed on specific instructions.

## My Role:
My role was to design and implement the ALU and its sub components, create a control table to map inputs and outputs of the control unit, assist with the design and implementation of the control unit, and manually test sub-components of the ALU and control unit. Examples of my work include the adder-subtractor, bit shifter, 2x1 n-bit multiplexor, n-bit decoder, etc. For testing, I use QuestaSim waveforms to compare graphed outputs of subcomponents to expected outputs to ensure the processors could successfully run most MIPS instructions that would be run through them during synthesis.

## Skills and Knowledge:
Throughout this project I learned about various processors, performance, and specific applications for each.  I also learned how to use the VHDL coding language to implement software versions of hardware. Throughout the debugging and testing process I gained experience in developing test classes and testbenches in addition to various testing and debugging tools such as QuestaSim and Mars MIPS Simulator.

## Resources Used:
 - VHDL
 - QuestaSim
 - MIPS Assembly
 - Mars MIPS Simulator
 - Visual Studio Code
 - Microsoft Excel


## Directory Navigation:
Most VHDL files can be found in the `/cpre381-toolflow/` directory for the single cycle processor, or in the `/proj/` directory for the hardware and software processors. 
 - For VHDL source files used for the main components of our processors, navigate to `/proj/src/TopLevel`. 
 - For the VHDL testbenches used for testing our processors in QuestaSim, navigate to `/proj/test`.
 - For the MIPS assembly instructions files we used for exhaughstive testing of our processors, navigate to `/proj/mips/`.