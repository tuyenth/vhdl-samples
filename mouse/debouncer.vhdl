library ieee;
use ieee.std_logic_1164.all;

-- Lógica de debounce
-- OBS: debounce = 1 -> requer no mínimo um ciclo completo (duas subidas de clock)
--      para fazer o debounce. Não funciona com debounce = 0.
entity debouncer is
	generic (debounce : natural := 7);
	port (input, clock, reset : in std_logic;
	      output1 : out std_logic);
end entity debouncer;

architecture behavior of debouncer is
	signal counter : natural;
	signal last : std_logic;
begin
	process (clock, reset) is
		constant rdebounce : natural := debounce - 1;
	begin
		if (reset = '0') then
			counter <= 0;
			output1 <= '0';
			last <= '0';
		else
			if (rising_edge(clock)) then
				if (input = last) then
					if (counter < rdebounce) then
						counter <= counter+1;
					else
						output1 <= last;
						counter <= 0;
					end if;
				else
					counter <= 0;
					last <= input;
				end if;
			end if;
		end if;
	end process;
end architecture behavior;
