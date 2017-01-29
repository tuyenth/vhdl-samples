library ieee;
use ieee.std_logic_1164.all;

-- Transforma um sinal ativo em varios ciclos para um sinal ativo no primeiro ciclo
entity varios_para_um is
	port (leitura, clock, reset : in std_logic; saida : out std_logic);
end entity varios_para_um;

architecture behavior of varios_para_um is
	signal conta : std_logic;
begin
	process (clock, reset)
	begin
		if (reset = '0') then
			conta <= '0';
			saida <= '0';
		elsif (rising_edge(clock)) then
			if (leitura = '0') then
				conta <= '0';
				saida <= '0';
			else
				if (conta = '0') then
					conta <= '1';
					saida <= '1';
				else
					conta <= '1';
					saida <= '0';
				end if;
			end if;
		end if;
	end process;
end architecture behavior;

library ieee;
use ieee.std_logic_1164.all;


-- Este aqui é para mouses mais espertos

--entity um_para_varios is
--	port (entrada, leitura, clock, reset : in std_logic; saida : out std_logic);
--end entity um_para_varios;
--
--architecture behavior of um_para_varios is
--	signal conta : std_logic;
--begin
--	process (clock, reset)
--	begin
--		if (reset = '0') then
--			conta <= '0';
--			saida <= '0';
--		elsif (rising_edge(clock)) then
--			if (leitura = '1') then
--				saida <= entrada or conta;
--				conta <= '0';
--			else
--				saida <= entrada or conta;
--				conta <= entrada or conta;
--			end if;
--		end if;
--	end process;
--end architecture behavior;
