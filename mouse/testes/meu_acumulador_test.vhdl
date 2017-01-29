library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity meu_acumulador_test is
end entity;

architecture behavior of meu_acumulador_test is
	signal s0, d0, l0, c0, r0 :  std_logic;
	signal res0 : integer;
begin
	test_meu_acumulador : entity work.meu_acumulador(sm)
		port map (s0, d0, l0, c0, r0, res0);

	process
		type pattern_type is record
			s, d, l, c, r : std_logic;
			res : integer;
		end record;

		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns : pattern_array :=
			(('0', '0', '0', '0', '0', 0),
			 ('0', '0', '0', '0', '1', 0),
			 ('0', '0', '0', '0', '1', 0),
			 ('0', '0', '0', '0', '1', 0),
			 ('0', '0', '0', '1', '1', 0),
			 ('0', '0', '0', '0', '1', 0),
			 ('0', '0', '0', '1', '1', 0),
			 ('0', '0', '1', '0', '1', 0),
			 ('0', '0', '1', '1', '1', 0),
			 ('0', '0', '1', '0', '1', 0),

			 ('0', '0', '1', '1', '1', 0),
			 ('1', '0', '1', '0', '1', 0),
			 ('1', '0', '1', '1', '1', -1), -- entrada -1, leitura
			 ('1', '0', '0', '0', '1', -1),
			 ('1', '0', '0', '1', '1', -1), -- entrada -1, saida -1
			 ('1', '0', '1', '0', '1', -1),
			 ('1', '0', '1', '1', '1', -2), -- entrada -1, leitura
			 ('1', '0', '1', '0', '1', -2),
			 ('1', '0', '1', '1', '1', -1), -- entrada -1, leitura, saida -2
			 ('0', '0', '0', '0', '1', -1),

			 ('0', '0', '0', '1', '1', 0), -- saida -1
			 ('0', '0', '0', '0', '1', 0),
			 ('0', '0', '0', '1', '1', 0),
			 ('0', '1', '0', '0', '1', 0),
			 ('0', '1', '0', '1', '1', 1),
			 ('0', '0', '0', '0', '1', 1),
			 ('0', '0', '0', '1', '1', 1), 
			 ('0', '1', '0', '0', '1', 1),
			 ('0', '1', '0', '1', '1', 2),
			 ('0', '0', '0', '0', '1', 2),
			 
			 ('0', '0', '0', '1', '1', 2),
			 ('1', '0', '1', '0', '1', 2),
			 ('1', '0', '1', '1', '1', 1),
			 ('0', '0', '0', '0', '1', 1),
			 ('0', '0', '0', '1', '1', 0),
			 ('0', '0', '0', '0', '1', 0),
			 ('0', '0', '0', '1', '1', 0),
			 ('0', '0', '0', '0', '1', 0)
			 
			 
			);
	begin
		for i in patterns'range loop
			s0 <= patterns(i).s after 2 ns;
			d0 <= patterns(i).d after 2 ns;
			l0 <= patterns(i).l after 1 ns;
			c0 <= patterns(i).c after 1 ns;
			r0 <= patterns(i).r after 1 ns;
			
			wait for 1 ms;
			
			assert res0 = patterns(i).res
				report "Erro" severity error;
		end loop;
		assert false report "End of test" severity note;
		wait;
	end process;
end behavior;

