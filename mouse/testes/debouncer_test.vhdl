library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity debouncer_test is
end debouncer_test;

architecture behavior of debouncer_test is
	signal i, o, c, r : std_logic;
begin
	test_debouncer: entity work.debouncer port map (i, c, r, o);
	process
	   variable l : line;
	begin
		c <= '0';
		i <= '0';
		r <= '0';
		wait for 1 ms;
		r <= '1';
		i <= '1';
		wait for 1 ms;
		for j in 0 to 18 loop
			write (l ,  j);
			writeline (output, l);
			c <= not c;
			wait for 10 ms;
			if (c = '1') then
				write (l, String'("Clock"));
				writeline (output,  l);
			end if;
			assert o = '0'
				report "Error" severity error;
			wait for 10 ms;
		end loop;
		assert false report "end of test" severity note;
		wait;
	end process;
end architecture behavior;
