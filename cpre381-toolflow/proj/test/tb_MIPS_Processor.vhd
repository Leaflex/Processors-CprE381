-------------------------------------------------------------------------
-- Lex Somers
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a test bench for the top level MIPS
--      Processor component of the single cycle MIPS processor. 
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

library work;
use work.MIPS_types.all;

entity tb_MIPS_Processor is
	generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_MIPS_Processor;

architecture architectural of tb_MIPS_Processor is

	--define the total clock period time
    constant cCLK_PER : time := gCLK_HPER * 2;

	component MIPS_Processor is
		generic(N : integer := DATA_WIDTH);
		port(
			iCLK		: in std_logic;
			iRST		: in std_logic;
			iInstLd		: in std_logic;
			iInstAddr	: in std_logic_vector(31 downto 0);
			iInstExt	: in std_logic_vector(31 downto 0);
			oALUOut		: out std_logic_vector(31 downto 0)
		);
	end component;
	-- std_logic_vector(N-1 downto 0);
	signal s_CLK 		: std_logic;
	signal s_RST 		: std_logic;
	signal s_iInstLd	: std_logic;
	signal s_iInstAddr	: std_logic_vector(31 downto 0);
	signal s_iInstExt	: std_logic_vector(31 downto 0); 
	signal s_oALUOut	: std_logic_vector(31 downto 0);

begin 

	DUT0: MIPS_Processor
		port map(
			iCLK		=> s_CLK,
			iRST		=> s_RST,
			iInstLd		=> s_iInstLd,
			iInstAddr	=> s_iInstAddr,
			iInstExt	=> s_iInstExt,
			oALUOut		=> s_oALUOut
		);

   --This first process is to setup the clock for the test bench
   P_CLK: process
   begin
	   s_CLK <= '1';         -- clock starts at 1
	   wait for gCLK_HPER; -- after half a cycle
	   s_CLK <= '0';         -- clock becomes a 0 (negative edge)
	   wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
   end process;

	-- This process resets the sequential components of the design.
    -- It is held to be 1 across both the negative and positive edges of the clock
    -- so it works regardless of whether the design uses synchronous (pos or neg edge)
    -- or asynchronous resets.
    P_RST: process
    begin
        s_RST <= '0';   
        wait for gCLK_HPER/2;
        s_RST <= '1';
        wait for gCLK_HPER*2;
        s_RST <= '0';
        wait;
    end process;

	-- Assign inputs for each test case.
    P_TEST_CASES: process
    begin
        wait for gCLK_HPER/2; -- for waveform clarity, NOT changing inputs on clk edges
        
        --Test case 1: 
        s_iInstExt <= 32b"00100000000000010000000000000001";
        s_iInstAddr <= 32b"00100000000000010000000000000001";
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        --Test case 2: 
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        --Test case 3: 
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;
        
        --Test case 4: 
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        --Test case 5: 
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

		--Test case 6: 
		wait for gCLK_HPER*2;
		wait for gCLK_HPER*2;
        
        --Test case 7: 
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

		--Test case 8: 
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

		--Test case 9: 
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

		--Test case 10: 
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        end process;

end architectural;