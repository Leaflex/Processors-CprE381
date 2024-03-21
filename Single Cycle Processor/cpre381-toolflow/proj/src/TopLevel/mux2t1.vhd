library IEEE;
use IEEE.std_logic_1164.all;


entity mux2t1 is
	port(
		i_D0 : in std_logic;
		i_D1 : in std_logic;
		i_S  : in std_logic; -- 1 takes D1, 0 take D0
		o_O  : out std_logic
	);
end mux2t1;

architecture structure of mux2t1 is

	component andg2
		port(
			i_A             : in std_logic;
			i_B             : in std_logic;
			o_F             : out std_logic
		);
	end component;

	component org2
		port(
			i_A             : in std_logic;
			i_B             : in std_logic;
			o_F             : out std_logic
		);
	end component;

	component invg
		port(
			i_A             : in std_logic;
			o_F             : out std_logic
		);
	end component;

	signal s_and : std_logic;
	signal s_and2 : std_logic;
	signal s_not : std_logic;

	begin

	g_stage1: andg2 port MAP(
		i_A => i_D1, --This used to be i_D0, swap with i_D1 to switch inputs
		i_B => i_S,
		o_F => s_and
	);

	g_stage2: invg port MAP(
		i_A => i_S,
		o_F => s_not
	);

	g_stage3: andg2 port MAP(
		i_A => i_D0, --This used to be i_D1, swap wotj i_D0 to switch inputs
		i_B => s_not,
		o_F => s_and2
	);

	g_stage4: org2 port MAP(
		i_A => s_and,
		i_B => s_and2,
		o_F => o_O
	);

end structure;