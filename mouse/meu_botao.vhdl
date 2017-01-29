library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
use work.std_logic_textio.all;

-- Lógica de cliques
-- OBS: detecta, no máximo uma alteração de estado (solto -> clicado ou clicado -> solto ou nada)
entity meu_botao is
  port (input, leitura, clock, reset : in std_logic;
        output0 : out std_logic_vector (0 to 1));
end entity meu_botao;

architecture mixed of meu_botao is
	signal d0, q0, d1, d2, q1, q2, rleitura : std_logic;
begin

	-- Leitura somente fica ativa no ciclo certo
	reg_leitura: entity work.varios_para_um port map (leitura, clock, reset, rleitura);

	-- Registrador de estado
	reg_entrada: entity work.flipflop_s port map (d0, clock, reset, q0);
	process (input, q0, rleitura)
	begin
		if (rleitura = '1') then
			d0 <= input;
		else
			d0 <= q0;
		end if;
	end process;

	-- Registradores de transições	
	process (input, q0)
	begin
		d1 <= input and (not q0);
		d2 <= (not input) and q0;
	end process;
	reg_subiu: entity work.flipflop_s port map (d1, clock, reset, q1);
	reg_desceu: entity work.flipflop_s port map (d2, clock, reset, q2);
	output0(0) <= q1;
	output0(1) <= q2;
end architecture mixed;
