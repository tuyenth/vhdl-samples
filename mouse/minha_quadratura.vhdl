library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity minha_quadratura is
	port (A, B, clock, reset : in std_logic;
		subiu, desceu : out std_logic);
end entity minha_quadratura;

architecture behavior of minha_quadratura is
	-- O espaço de estados é de (4 estados do sensor) * (3 estados de transição)
	-- Acabou saindo tudo junto
	type estados is (zero_parado, A_parado, B_parado, AB_parado,
			 zero_descendo, A_descendo, AB_descendo, B_descendo,
			 zero_subindo, B_subindo, AB_subindo, A_subindo);
	signal estado_atual, proximo_estado : estados;
begin
	
	sync: process (clock, reset)
		variable entradas : std_logic_vector(0 to 1);
	begin
		entradas(0) := A;
		entradas(1) := B;
		if (reset = '0') then
			case entradas is
			 when "00" => estado_atual <= zero_parado;
			 when "10" => estado_atual <= A_parado;
			 when "01" => estado_atual <= B_parado;
			 when "11" => estado_atual <= AB_parado;
			 when others => estado_atual <= zero_parado;
			end case;
		elsif (rising_edge(clock)) then
			estado_atual <= proximo_estado;
		end if;
	end process sync;
	
	fsm: process (estado_atual, A, B)
		variable entradas : std_logic_vector(0 to 1);
	begin
		entradas(0) := A;
		entradas(1) := B;
		case estado_atual is
		 when zero_parado =>
		  case entradas is
		   when "00" => proximo_estado <= zero_parado;
		   when "10" => proximo_estado <= A_descendo;
		   when "01" => proximo_estado <= B_subindo;
		   when "11" => proximo_estado <= AB_parado;
		   when others => proximo_estado <= zero_parado;
		  end case;
		 when A_parado =>
		  case entradas is
		   when "00" => proximo_estado <= zero_subindo;
		   when "10" => proximo_estado <= A_parado;
		   when "01" => proximo_estado <= B_parado;
		   when "11" => proximo_estado <= AB_descendo;
		   when others => proximo_estado <= A_parado;
		  end case;
		 when B_parado =>
		  case entradas is
		   when "00" => proximo_estado <= zero_descendo;
		   when "10" => proximo_estado <= A_parado;
		   when "01" => proximo_estado <= B_parado;
		   when "11" => proximo_estado <= AB_subindo;
		   when others => proximo_estado <= B_parado;
		  end case;
		 when AB_parado =>
		  case entradas is
		   when "00" => proximo_estado <= zero_parado;
		   when "10" => proximo_estado <= A_subindo;
		   when "01" => proximo_estado <= B_descendo;
		   when "11" => proximo_estado <= AB_parado;
		   when others => proximo_estado <= AB_parado;
		  end case;
		 when zero_descendo =>
		  case entradas is
		   when "00" => proximo_estado <= zero_parado;
		   when "10" => proximo_estado <= A_subindo;
		   when "01" => proximo_estado <= B_descendo;
		   when "11" => proximo_estado <= AB_parado;
		   when others => proximo_estado <= zero_parado;
		  end case;
		 when A_descendo =>
		  case entradas is
		   when "00" => proximo_estado <= zero_subindo;
		   when "10" => proximo_estado <= A_parado;
		   when "01" => proximo_estado <= B_parado;
		   when "11" => proximo_estado <= AB_descendo;
		   when others => proximo_estado <= A_parado;
		  end case;
		 when B_descendo =>
		  case entradas is
		   when "00" => proximo_estado <= zero_descendo;
		   when "10" => proximo_estado <= A_parado;
		   when "01" => proximo_estado <= B_parado;
		   when "11" => proximo_estado <= AB_subindo;
		   when others => proximo_estado <= B_parado;
		  end case;
		 when AB_descendo =>
		  case entradas is
		   when "00" => proximo_estado <= zero_parado;
		   when "10" => proximo_estado <= A_subindo;
		   when "01" => proximo_estado <= B_descendo;
		   when "11" => proximo_estado <= AB_parado;
		   when others => proximo_estado <= AB_parado;
		  end case;
		 when zero_subindo =>
		  case entradas is
		   when "00" => proximo_estado <= zero_parado;
		   when "10" => proximo_estado <= A_subindo;
		   when "01" => proximo_estado <= B_descendo;
		   when "11" => proximo_estado <= AB_parado;
		   when others => proximo_estado <= zero_parado;
		  end case;
		 when A_subindo =>
		  case entradas is
		   when "00" => proximo_estado <= zero_subindo;
		   when "10" => proximo_estado <= A_parado;
		   when "01" => proximo_estado <= B_parado;
		   when "11" => proximo_estado <= AB_descendo;
		   when others => proximo_estado <= A_parado;
		  end case;
		 when B_subindo =>
		  case entradas is
		   when "00" => proximo_estado <= zero_descendo;
		   when "10" => proximo_estado <= A_parado;
		   when "01" => proximo_estado <= B_parado;
		   when "11" => proximo_estado <= AB_subindo;
		   when others => proximo_estado <= B_parado;
		  end case;
		 when AB_subindo =>
		  case entradas is
		   when "00" => proximo_estado <= zero_parado;
		   when "10" => proximo_estado <= A_subindo;
		   when "01" => proximo_estado <= B_descendo;
		   when "11" => proximo_estado <= AB_parado;
		   when others => proximo_estado <= AB_parado;
		  end case;
  		end case;
  	end process fsm;
  	
  	outputs: process (estado_atual)
  		variable saidas : std_logic_vector (0 to 1);
  	begin
  		case estado_atual is
  		 when zero_parado to AB_parado => saidas := "00";
  		 when zero_descendo to B_descendo => saidas := "01";
  		 when zero_subindo to A_descendo => saidas := "10";
  		 when others => saidas := "XX";
  		end case;
  		subiu <= saidas(0);
  		desceu <= saidas(1);
  	end process outputs;


end architecture behavior;
