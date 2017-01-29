library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

use std.textio;

entity tb_processador is
end entity tb_processador;

architecture behavior of tb_processador is

  constant clk_period : time := 10 ns;
  constant delta      : time := 1 ns;
  type mem_array is array (natural range <>) of std_logic_vector(15 downto 0);

--  constant program : mem_array :=
--    ( X"0100", X"0200", X"0300", X"0400", X"0500", X"0600", X"0700", X"0800",
--      X"0900", X"0A00", X"0B00", X"0C00", X"0D00", X"0E00", X"0F00", X"B001",
--      X"B002", X"B003", X"B004", X"B005", X"B006", X"B007", X"B008", X"B009",
--      X"B00A", X"B00B", X"B00C", X"B00D", X"B00E", X"B00F" );

  signal reset, clock : std_logic;
  signal oop          : T_mem_op;
  signal addr         : std_logic_vector(15 downto 0) := (others => '0');
  signal read         : std_logic_vector(15 downto 0) := (others => '0');
  signal write        : std_logic_vector(15 downto 0) := (others => '0');
  signal done         : std_logic                     := '0';

begin
  reset <= '0', '1' after 7 * clk_period;

  process
  begin
    clock   <= '0';
    wait for clk_period;
    loop
      clock <= '1', '0' after clk_period / 2;
      wait for clk_period;
    end loop;
  end process;

  process
    variable memory : mem_array (0 to 32767);
    variable x      : integer;
    variable count  : integer := 0;
    variable i      : integer := 0;
    variable l      : textio.line;
  begin
    while not textio.endfile(textio.input) loop
      textio.readline(textio.input, l);
      textio.read(l, x);
      memory(count)           := std_logic_vector(to_unsigned(x, 16));
      count                   := count + 1;
    end loop;

    loop
      wait on oop, reset until (oop'event and oop /= none) or (rising_edge(reset));
      x := to_integer(unsigned(addr))/2;

      if oop = work.lib.read then

        read <= memory(x) after delta;
        done <= '1'       after delta, '0' after clk_period + delta;
      elsif oop = work.lib.write then
        memory(x) := write;
        if x = 21 and to_integer(unsigned(write)) = 42 then
          report "halt" severity failure;
        end if;
      end if;
    end loop;
  end process;

  test : entity work.processador port map
    (
      Clk        => clock,
      SReset_n   => reset,
      MCmd       => open,
      MAddr      => addr,
      MData      => write,
      SCmdAccept => done,
      SResp      => "00",
      SData      => read,
      oop        => oop
      );
end architecture behavior;
