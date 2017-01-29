library std;
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.std_logic_textio.all;

entity tb_quadratura is
end tb_quadratura;

architecture behavior of tb_quadratura is

  constant clk_period : time := 100 ns;  -- Clock period
  constant delta : time := 1 ns;  -- Delta time to assert the inputs

  file InFile        : text open read_mode is "quadratura.base.input";  -- Input file
  file OutFile       : text open write_mode is "output.std";  -- Output file
--  file FullFile      : text open write_mode is "quadratura.base.full.output";  -- Full output

  signal end_of_file : boolean;  	-- End of File indicator

  signal iclk	     : std_logic := '0';		-- Internal Clock (testbench only)
  signal iresetn     : std_logic;		-- Internal Resetn (testbench only)
  signal clk	     : std_logic;		-- Clock signal
  signal reset	     : std_logic;
  signal leitura, horizontalA, horizontalB, verticalA, verticalB, scrollA, scrollB,
  	 botaoE, botaoM, botaoD, alterado : std_logic;
  signal x, y, scroll : integer;
  signal botoes : std_logic_vector(5 downto 0);

--  component Quadratura
--  	generic (debounce : natural := 7);
--	port (clk, reset, leitura, horizontalA, horizontalB, verticalA, verticalB,
--	      scrollA, scrollB, botaoE, botaoM, botaoD : in std_logic;
--	      alterado : out std_logic; x, y, scroll : out integer;
--	      botoes : out std_logic_vector(5 downto 0));
--  end component;
  
  
begin  -- behavior

  iclk <= not iclk after clk_period / 2;
  iresetn <= '0', '1' after 7 * clk_period;

  quadratura0: entity work.Quadratura
    port map (clk, reset, leitura, horizontalA, horizontalB, verticalA, verticalB,
	      scrollA, scrollB, botaoE, botaoM, botaoD, alterado, x, y, scroll, botoes);
	      
  ReadInput : process(iClk, iResetn)

    variable input_line	  : line;
    variable clk_value	  : std_logic;
    variable reset_value  : std_logic;
    variable leitura_value, horizontalA_value, horizontalB_value, verticalA_value,
    	     verticalB_value, scrollA_value, scrollB_value, botaoE_value, botaoM_value,
    	     botaoD_value : std_logic;
     
  begin  -- process ReadInput
    if (iResetn = '0') then
      end_of_file <= false;

    elsif iClk'EVENT and iClk = '0' then
      if EndFile(InFile) then
	end_of_file <= true;  		-- stop when reaches end of file
      else
	ReadLine(InFile, input_line);

	Read(input_line, clk_value);
	Read(input_line, reset_value);
	Read(input_line, leitura_value);
	Read(input_line, horizontalA_value);
	Read(input_line, horizontalB_value);
	Read(input_line, verticalA_value);
	Read(input_line, verticalB_value);
	Read(input_line, scrollA_value);
	Read(input_line, scrollB_value);
	Read(input_line, botaoE_value);
	Read(input_line, botaoM_value);
	Read(input_line, botaoD_value);
	
	reset <= reset_value after delta;
	leitura <= leitura_value after delta;
	horizontalA <= horizontalA_value after delta;
	horizontalB <= horizontalB_value after delta;
	verticalA <= verticalA_value after delta;
	verticalB <= verticalB_value after delta;
	scrollA <= scrollA_value after delta;
	scrollB <= scrollB_value after delta;
	botaoE <= botaoE_value after delta;
	botaoM <= botaoM_value after delta;
	botaoD <= botaoD_value after delta;
	clk <= clk_value;
      end if;
    end if;

  end process ReadInput;

  -- Writes a simple output report
  WriteOutput : process(Clk, reset)

    variable output_line : line;
    variable command     : character;  	-- Input command

  begin  -- process ReadInput
--    if (reset = '0') then
--      null;
--    elsif Clk'EVENT and Clk = '0' then
	if (rising_edge(reset)) then
		Write(output_line, string'("Time    Reset    Alt Lei  X    Y    Z    Botoes"));
		WriteLine(OutFile, output_line);
	elsif (clk'event and clk = '0') then
	      Write(output_line, now, left, 12);
	      Write(output_line, reset, left, 6);
	      Write(output_line, alterado, left, 4);
	      Write(output_line, leitura, left, 4);
	      Write(output_line, x, left, 5);
	      Write(output_line, y, left, 5);
	      Write(output_line, scroll, left, 5);
	      Write(output_line, botoes, left, 5);
	      WriteLine(OutFile, output_line);
    end if;
  end process WriteOutput;
  

  -- Writes an extende output report (including the input)
--  WriteFull : process(iClk, iResetn)

--    variable output_line : line;
--    variable command     : character;  	-- Input command

--  begin  -- process ReadInput
--    if (iResetn = '0') then
--      null;
--    elsif iClk'EVENT and iClk = '0' then
--      Write(output_line, now, left, 11);
--      Write(output_line, sensor, left, 6);
--      Write(output_line, total, left, 5);
--      WriteLine(FullFile, output_line);
--    end if;
--  end process WriteFull;

  -- stop the simulator when the end of file is reached
  assert not end_of_file report "End of Simulation" severity failure;

end architecture behavior;
