library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_MIPS_Processor is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_MIPS_Processor;

architecture mixed of tb_MIPS_Processor is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;
constant N : integer := 32;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component MIPS_Processor is
  generic(N : integer := N);
	port(
		iCLK		: in std_logic;
		iRST		: in std_logic;
		iInstLd		: in std_logic;
		iInstAddr	: in std_logic_vector(N-1 downto 0);
		iInstExt	: in std_logic_vector(N-1 downto 0);
		oALUOut		: out std_logic_vector(N-1 downto 0)
	);
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_iRST   : std_logic := '0';
signal s_iInstLd   : std_logic := '0';
signal s_iInstAddr  : std_logic_vector(N-1 downto 0) := 32x"0";
signal s_iInstExt  : std_logic_vector(N-1 downto 0) := 32x"0";
signal s_oALUOut : std_logic_vector(N-1 downto 0) := 32x"0";

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: MIPS_Processor
  port map(
          iCLK     => CLK,
          iRST     => s_iRST,
          iInstLd   => s_iInstLd,
          iInstAddr   => s_iInstAddr,
          iInstExt    => s_iInstExt,
          oALUOut   => s_oALUOut
      );
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
    --s_A   <= 32X"00000";
    --s_B   <= 32X"00000";
    --s_nAdd_Sub <= '0';
    wait for gCLK_HPER*2;
    


    wait;
  end process;

end mixed;
