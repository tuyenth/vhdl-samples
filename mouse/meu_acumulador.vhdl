library ieee;
use ieee.std_logic_1164.all;

-- Acumulador de movimento
entity meu_acumulador is
  port (subiu, desceu, leitura, clock, reset : in std_logic;
        resultado : out integer);
end entity meu_acumulador;

architecture mixed of meu_acumulador is
	signal soma, d1, q1, d2, q2 : integer;
	signal rleitura : std_logic;
begin
	-- Leitura somente fica ativa no ciclo certo
	reg_leitura: entity work.varios_para_um port map (leitura, clock, reset, rleitura);

	-- Somador
	process (q1, subiu, desceu)
		variable x : integer;
	begin
		if (subiu = '1' and desceu = '0') then
			x := -1;
		elsif (subiu = '0' and desceu = '1') then
			x := 1;
		else
			x := 0;
		end if;
		
		soma <= q1 + x;
	end process;
	
	-- Registrador de saída
	d2 <= soma;
	reg_saida: entity work.flipflop port map (d2, clock, reset, q2);
	resultado <= q2;
	
	-- Registrador de acumulação
	process (soma, rleitura)
	begin
		if (rleitura = '1') then
			d1 <= 0;
		else
			d1 <= soma;
		end if;
	end process;
	reg_acumulador: entity work.flipflop port map (d1, clock, reset, q1);
	
end architecture mixed;

