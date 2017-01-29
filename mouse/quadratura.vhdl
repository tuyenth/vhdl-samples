library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity Quadratura is
  generic (debounce : natural := 7);
  port (clk, 
	reset,
	leitura,
	horizontalA, 
	horizontalB,
	verticalA, 
	verticalB,
	scrollA, 
	scrollB,
	botaoE, 
	botaoM, 
	botaoD : in std_logic;
	alterado : out std_logic;
	x,
	y,
	scroll : out integer;
	botoes : out std_logic_vector(5 downto 0));
end entity Quadratura;

architecture structure of Quadratura is
	-- Todos os sinais são de interconexão estrutural
	signal x_subiu, x_desceu,
	       y_subiu, y_desceu,
	       z_subiu, z_desceu : std_logic;
	signal proximo_dx, proximo_dy, proximo_dz : integer;
	signal proximo_bE, proximo_bM, proximo_bD : std_logic_vector (0 to 1);
	signal xA, xB, yA, yB, zA, zB, bE, bM, bD : std_logic;
begin

	-- Tudo do eixo x
	debouncer_xA: entity work.debouncer generic map (debounce => debounce)
					    port map (horizontalA, clk, reset, xA);
	debouncer_xB: entity work.debouncer generic map (debounce => debounce)
					    port map (horizontalB, clk, reset, xB);
	leitor_x: entity work.minha_quadratura port map (xA, xB, clk, reset, x_subiu, x_desceu);
	contador_x : entity work.meu_acumulador port map (x_subiu, x_desceu, leitura,
							  clk, reset, proximo_dx);
	x <= proximo_dx;
		
	-- Tudo do eixo y
	debouncer_yA: entity work.debouncer generic map (debounce => debounce)
					    port map (verticalA, clk, reset, yA);
	debouncer_yB: entity work.debouncer generic map (debounce => debounce)
				            port map (verticalB, clk, reset, yB);
	leitor_y: entity work.minha_quadratura port map (yA, yB, clk, reset, y_subiu, y_desceu);
	contador_y : entity work.meu_acumulador port map (y_subiu, y_desceu, leitura,
							  clk, reset, proximo_dy);
	y <= proximo_dy;

	-- Tudo do eixo scroll
	debouncer_zA: entity work.debouncer generic map (debounce => debounce)
					    port map (scrollA, clk, reset, zA);
	debouncer_zB: entity work.debouncer generic map (debounce => debounce)
					    port map (scrollB, clk, reset, zB);
	leitor_z: entity work.minha_quadratura port map (zA, zB, clk, reset, z_subiu, z_desceu);
	contador_z : entity work.meu_acumulador port map (z_subiu, z_desceu, leitura,
							  clk, reset, proximo_dz);
	scroll <= proximo_dz;

	-- Tudo do botão esquerdo
	debouncer_bE: entity work.debouncer generic map (debounce => debounce)
					    port map (botaoE, clk, reset, bE);
	contador_bE: entity work.meu_botao port map (bE, leitura, clk, reset, proximo_bE);
	botoes(5) <= proximo_bE(0);
	botoes(4) <= proximo_bE(1);
	
	-- Tudo do botão do meio
	debouncer_bM: entity work.debouncer generic map (debounce => debounce)
					    port map (botaoM, clk, reset, bM);
	contador_bM: entity work.meu_botao port map (bM, leitura, clk, reset, proximo_bM);
	botoes(3) <= proximo_bM(0);
	botoes(2) <= proximo_bM(1);
	
	-- Tudo do botão direito
	debouncer_bD: entity work.debouncer generic map (debounce => debounce)
					    port map (botaoD, clk, reset, bD);
	contador_bD: entity work.meu_botao port map (bD, leitura, clk, reset, proximo_bD);
	botoes(1) <= proximo_bD(0);
	botoes(0) <= proximo_bD(1);

	-- Lógica do sinal "alterado".
	-- OBS: O sinal sempre está em zero quando "leitura" é ativado
	process (proximo_dx, proximo_dy, proximo_dz, proximo_bE,
		 proximo_bM, proximo_bD, clk, reset)
		 variable alterado0 : std_logic;
	begin
		if (reset = '0') then
			alterado <= '0';
		elsif(rising_edge(clk)) then
			if (proximo_dx /= 0 or proximo_dy /= 0 or proximo_dz /= 0 or
 	                    proximo_bE /= "00" or proximo_bM /= "00" or proximo_bD /= "00") then
 	                	alterado0 := not leitura;
 	                else
 	                	alterado0 := '0';
 	                end if;
			alterado <= alterado0;
		end if;
	end process;
	
end architecture structure;
