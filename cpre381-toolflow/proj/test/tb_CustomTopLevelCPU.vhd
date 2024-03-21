library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity CustomTopLevelCPU is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end CustomTopLevelCPU;

architecture mixed of CustomTopLevelCPU is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;
constant N : integer := 32;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component CustomTopLevelCPU is
  generic(N : integer := N);
    port(
	    i_CLK: in std_logic;
	    i_Inst: in std_logic_vector(31 downto 0);
	    i_RST: in std_logic;
	    i_PC: in std_logic_vector(31 downto 0);
	    o_Overflow: out std_logic
	);
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_Inst  : std_logic_vector(N-1 downto 0) := 32X"0";
signal s_PC    : std_logic_vector(N-1 downto 0) := 32X"0";
signal s_RST   : std_logic := '0';
signal s_Overflow   : std_logic := '0';

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: CustomTopLevelCPU
  port map(
            --iCLK => CLK,
            i_CLK => CLK,
            i_Inst => s_Inst,
			i_RST => s_RST,
	    	i_PC => s_PC,
            o_Overflow	=> s_Overflow);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

  
  --This first process is to setup the clock for the test bench
  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
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
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- Test case 1:
    s_Inst   <= 32X"20010001"; --addi $t0, $t0, -1
    --s_PC   <= 32X"00400000"; --Address already set to correct value
    s_RST <= '0';
    wait for gCLK_HPER*2;
    
	s_Inst   <= 32X"20020002";
    s_PC   <= 32X"00400004";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20030003";
    s_PC   <= 32X"00400008";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20040004";
    s_PC   <= 32X"0040000C";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20050005";
    s_PC   <= 32X"00400010";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20060006";
    s_PC   <= 32X"00400014";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20070007";
    s_PC   <= 32X"00400018";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20080008";
    s_PC   <= 32X"0040001c";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20090009";
    s_PC   <= 32X"00400020";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"200a000a";
    s_PC   <= 32X"00400024";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"200b000b";
    s_PC   <= 32X"00400028";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"200c000c";
    s_PC   <= 32X"0040002c";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"200d000d";
    s_PC   <= 32X"00400030";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"200e000e";
    s_PC   <= 32X"00400034";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"200f000f";
    s_PC   <= 32X"00400038";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20100010";
    s_PC   <= 32X"0040003c";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20110011";
    s_PC   <= 32X"00400040";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20120012";
    s_PC   <= 32X"00400044";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20130013";
    s_PC   <= 32X"00400048";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20140014";
    s_PC   <= 32X"0040004c";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20150015";
    s_PC   <= 32X"00400050";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20160016";
    s_PC   <= 32X"00400054";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20170017";
    s_PC   <= 32X"00400058";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20180018";
    s_PC   <= 32X"0040005c";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"20190019";
    s_PC   <= 32X"00400060";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"201a001a";
    s_PC   <= 32X"00400064";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"201b001b";
    s_PC   <= 32X"00400068";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"201c001c";
    s_PC   <= 32X"0040006c";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"201d001d";
    s_PC   <= 32X"00400070";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"201e001e";
    s_PC   <= 32X"00400074";
    s_RST <= '0';
	wait for gCLK_HPER*2;

	s_Inst   <= 32X"201f001f";
    s_PC   <= 32X"00400078";
    s_RST <= '0';
	wait for gCLK_HPER*2;
   
    wait;
  end process;

end mixed;