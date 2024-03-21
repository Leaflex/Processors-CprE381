# Comparative Perforamnce Analysis of Single and Multi-Cycle Processors
Git repo containing code and documentation for Alexander Somers and Remmington Greatline's single and multi cycle processors design and analysis project. 

## Project Overview:
This project consisted of designing and comparatively analyzing three VHDL implemented processors, a single cycle processor, a software multi-cycle processor, and a hardware multi-cycle processor, as a team of two with Remmington Greatline and myself, Alexander Somers. The processors were built from scratch using basic VHDL implemented gates such as ANDs, ORs, XORs, etc, as the base for more complex components of the processors such as the arithmetic logic unit (ALU) or control unit. Once built, these processors underwent extensive manual testing and were then synthesized and had an exhaustive set of MIPS Assembly instructions run through them to allow for a comparative analysis of performance. The performance analysis was done based on metrics such as cycles per instruction, maximum cycle time, and total execution time. Comparisons were also made for which instructions each processor implementation was able to execute the most and least efficiently.

## My Role:
My role was to design and implement the ALU and all of its sub components, create and fill out the control table used for mapping inputs and outputs to and from the control unit, assist with the design and implementation of the control unit itself, and manually test all individual components used in the ALU and control unit. Designing the ALU and control unit involved writing VHDL code for their subcomponents such as the ALU adder and subtractor, a bit shifter, a 2x1 n-bit multiplexor, a n-bit decoder, etc. As for testing, this process included manually running simulations of instructions and comparing the actual graphed output of subcomponents to the expected outputs in order to ensure our processors could successfully run most of the MIPS instructions that would be run through them during the more exhaustive test while being synthesized.

## Skills and Knowledge:
Throughout this project I learned about various types of processors (I.E., single cycle vs multicycle, vs pipelined), their performance, and specific applications for each depending on the scenario. I also learned how to use the VHDL coding language to implement software versions of hardware. Throughout the process of debugging and testing our processors I gained skills in knowing what types of things to look for while debugging complex multi-level pieces of code as well as various tools and techniques for optimizing the software testing and debugging process and preventing human error.

## Resources Used:
 - VHDL
 - QuestaSim
 - MIPS Assembly
 - Visual Studio Code
 - Microsoft Excel

## Navigation:
Most relevant project files can be found in the `/cpre381-toolflow/` directory. 
 - For VHDL source files used for the main components of our project, navigate to `/cpre381-toolflow/proj/src/TopLevel`. 
 - For the VHDL testbenches used for testing our processors in QuestaSim, navigate to `/cpre381-toolflow/proj/test`.