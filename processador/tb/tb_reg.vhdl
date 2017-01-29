library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

entity tb_reg is
end entity tb_reg;

architecture behavior of tb_reg is
	signal q, d : std_logic_vector (15 downto 0);
	signal clock, reset : std_logic;
begin
	reset <= '0', '1' after 100 ns;
	
	process
	begin
		clock <= '0';
		wait for 10 ns;
		loop
			clock <= '1', '0' after 5 ns;
			report "Clock tick" severity note;
			wait for 10 ns;
		end loop;
	end process;

	d <= "0000000000000001";
		
	ff : entity work.dff port map (d => d, q => q, clock => clock, reset => reset, en => '1');
end architecture behavior;
