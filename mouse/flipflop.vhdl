library ieee;
use ieee.std_logic_1164.all;

-- Registrador
entity flipflop is
  port (input : in integer; clock, reset : in std_logic;
        output : out integer);
end entity flipflop;

architecture behavior of flipflop is
begin
	process (clock, reset)
	begin
		if (reset = '0') then
			output <= 0;
		elsif (rising_edge(clock)) then
			output <= input;
		end if;
	end process;
end architecture behavior;

library ieee;
use ieee.std_logic_1164.all;

-- Como se faz overload mesmo ?
entity flipflop_s is
	port (input, clock, reset : in std_logic; output : out std_logic);
end entity flipflop_s;

architecture behavior of flipflop_s is
begin
	process (clock, reset)
	begin
		if (reset = '0') then
			output <= '0';
		elsif (rising_edge(clock)) then
			output <= input;
		end if;
	end process;
end architecture behavior;

