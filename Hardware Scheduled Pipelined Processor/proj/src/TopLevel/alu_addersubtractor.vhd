-------------------------------------------------------------------------
-- lex Somers
-- Department of Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
--addersubtractor.vhd
-------------------------------------------------------------------------
--
-- NOTES:
-- 3/22/2023 Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity alu_addersubtractor is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
		--i_OvrflwCtrl	: in std_logic; -- controls overflow
		nAdd_Sub	: in std_logic; -- 1 takes the signed i_B, 0 takes unsigned i_B
		i_A 		: in std_logic_vector(N-1 downto 0);
		i_B			: in std_logic_vector(N-1 downto 0);
		o_Y			: out std_logic_vector(N-1 downto 0);
		o_Overflow	: out std_logic
	);
end alu_addersubtractor;

architecture structural of alu_addersubtractor is
	
  	component mux2t1_N is 
		generic(N : integer := 32);
		port(
			i_S		: in std_logic;
			i_D0	: in std_logic_vector(N-1 downto 0);
			i_D1	: in std_logic_vector(N-1 downto 0);
			o_O		: out std_logic_vector(N-1 downto 0)
		);
	end component;
		
	component ones_comp is 
		generic(N : integer := 32);
		port(
			i_A	: in std_logic_vector(N-1 downto 0);
			o_F	: out std_logic_vector(N-1 downto 0)
		);
	end component;

	component full_adder is
		port(
			i_A		: in std_logic;
			i_B		: in std_logic;
			i_Cin	: in std_logic;
			o_Cout	: out std_logic;
			o_Sum	: out std_logic
		);
	end component;

	component xorg2 is
		port(
			i_A		: in std_logic;
			i_B		: in std_logic;
			o_F		: out std_logic
		);
	end component;

	component andg2 is
		port(
			i_A 	: in std_logic;
			i_B		: in std_logic;
			o_F		: out std_logic
		);
	end component;
  
	signal c : std_logic_vector(N downto 0);
	signal s1, s2 : std_logic_vector(N-1 downto 0);

begin	
	-- Invert the 2nd input and output it in wire s1.
	inverter: ones_comp
		port MAP(
			i_A   => i_B,
			o_F   => s1
		);  

  	-- Choose whether to use the original X1 or the inverted X1
	addsubctrl: mux2t1_N 
		port MAP(
			i_S		=> nAdd_sub, -- 1 takes D1, 0 takes D0
			i_D0	=> i_B,
			i_D1	=> s1,
			o_O		=> s2
		);
  
	c(0) <= nAdd_Sub;

	G_full_adder: for i in 0 to N-1 generate
		full_adderlist: full_adder 
		port map(
			i_A 	=> i_A(i),
			i_B 	=> s2(i),
			i_Cin	=> c(i),
			o_Sum	=> o_Y(i),
			o_Cout	=> c(i+1)
		);
	end generate G_full_adder;

	overflow: xorg2
		port map(
			i_A => c(N),
			i_B => c(N-1),
			o_F => o_Overflow
		);

  
end structural;