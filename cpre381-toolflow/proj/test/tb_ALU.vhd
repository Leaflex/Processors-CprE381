-------------------------------------------------------------------------
-- Lex Somers
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a test bench for the main ALU 
--      component for a single cycle MIPS processor. 
--  
-- Notes            
-- 3/28/2023 by Lex Somers::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_alu is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_alu;


architecture arch of tb_alu is

    --define the total clock period time
    constant cCLK_PER : time := gCLK_HPER * 2;
    
    component alu is
        port(
            i_Data1 	: in std_logic_vector(31 downto 0);
            i_Data2 	: in std_logic_vector(31 downto 0);
            i_ALUOp 	: in std_logic_vector(3 downto 0); --This is decoded into instructions for the ALU
            o_Out 		: out std_logic_vector(31 downto 0);
            o_Overflow 	: out std_logic
            --o_RegDst : out std_logic; --Might be useful later but seems to only make sudo code viable
        );
    end component;
    
    -- Create signals for all of the inputs and outputs of the file that you are testing
    signal iCLK, reset : std_logic := '0';

    signal s_Data1		: std_logic_vector(31 downto 0);
    signal s_Data2		: std_logic_vector(31 downto 0);
    signal s_ALUOp	    : std_logic_vector(3 downto 0);
    signal s_Out	    : std_logic_vector(31 downto 0);
	signal s_Overflow	: std_logic;

begin 

    DUT0: alu
        port map(
            i_Data1		=> s_Data1,
            i_Data2		=> s_Data2,
            i_ALUOp		=> s_ALUOp,
            o_Out		=> s_Out,
            o_Overflow	=> s_Overflow
        );
			  
    --This first process is to setup the clock for the test bench
    P_CLK: process
    begin
        iCLK <= '1';         -- clock starts at 1
        wait for gCLK_HPER; -- after half a cycle
        iCLK <= '0';         -- clock becomes a 0 (negative edge)
        wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
    end process;
    
                
    -- This process resets the sequential components of the design.
    -- It is held to be 1 across both the negative and positive edges of the clock
    -- so it works regardless of whether the design uses synchronous (pos or neg edge)
    -- or asynchronous resets.
    P_RST: process
    begin
        reset <= '0';   
        wait for gCLK_HPER/2;
        reset <= '1';
        wait for gCLK_HPER*2;
        reset <= '0';
        wait;
    end process;
    
    -- Assign inputs for each test case.
    P_TEST_CASES: process
    begin
        wait for gCLK_HPER/2; -- for waveform clarity, NOT changing inputs on clk edges
        
        --Test case 1: add the two values from data1 and data2
        s_Data1	<= x"10101010";
        s_Data2	<= x"01010101";
        s_ALUOp	<= "0001";
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        --Test case 2: add the two values from data1 and data2
        s_Data1	<= x"FFFFFFFF";
        s_Data2	<= x"00000001";
        s_ALUOp	<= "0001";
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        --Test case 3: add the two values from data1 and data2
        s_Data1	<= x"00000005";
        s_Data2	<= x"00000005";
        s_ALUOp	<= "0001";
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;
        
        --Test case 4: subtract value 2 from value 1
        s_Data1	<= x"0000000a";
        s_Data2	<= x"00000005";
        s_ALUOp	<= "0010";
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        --Test case 5: subtract value 2 from value 1
        s_Data1	<= x"00000005";
        s_Data2	<= x"0000000a";
        s_ALUOp	<= "0010";
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

		--Test case 6: and the two values from data1 and data2
		s_Data1	<= x"11111111";
		s_Data2	<= x"10101010";
		s_ALUOp	<= "0100";
		wait for gCLK_HPER*2;
		wait for gCLK_HPER*2;
        
        --Test case 7 : and the two values from data1 and data2
        s_Data1		<= x"00000000";
        s_Data2		<= x"00000000";
        s_ALUOp	<= "0100";
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        end process;
	
end arch;