library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

use work.lib.all;
use work.std_logic_textio.all;

entity reg_bank is
  port (
    read1, read2 : in  std_logic_vector(lg(reg_count)-1 downto 0);
    write1       : in  std_logic_vector(lg(reg_count)-1 downto 0);
    write1_in    : in  std_logic_vector(reg_size-1 downto 0);
    read1_out    : out std_logic_vector(reg_size-1 downto 0);
    read2_out    : out std_logic_vector(reg_size-1 downto 0);
    write_cmd    : in  T_reg_cmd;
    clock        : in  std_logic
    );
end entity reg_bank;

architecture behavior of reg_bank is
  type reg is array (reg_size-1 downto 0) of std_logic;
  type bank is array (reg_count-1 downto 1) of reg;
  signal     registers : bank;
begin
  process (clock, read1, read2, write1, write1_in, write_cmd)
    variable i, j, k   : integer;
    variable aux       : reg;
    variable l         : line;
  begin
-- report "Reg bank." severity note;
    if rising_edge(clock) then

      if is_X(read1) or is_X(read2) or is_X(write1) or is_X(write1_in) then
        read1_out <= (others => 'X');
        read2_out <= (others => 'X');
        report "Reg bank is weird" severity note;
      else

        i   := to_integer(unsigned(read1));
        j   := to_integer(unsigned(read2));
        k   := to_integer(unsigned(write1));
        aux := reg(write1_in);

        if i = 0 then
          read1_out <= (others => '0');
        else
          read1_out <= std_logic_vector(registers(i));
        end if;

        if j = 0 then
          read2_out <= (others => '0');
        else
          read2_out <= std_logic_vector(registers(j));
        end if;

        if (k /= 0) then
          case write_cmd is
            when word   =>
              registers(k)                               <= reg(write1_in);
            when upper  =>
              registers(k)(reg_size-1 downto reg_size/2) <=
                aux(reg_size/2-1 downto 0);
            when lower  =>
              registers(k)(reg_size/2-1 downto 0)        <= aux(reg_size/2-1 downto 0);
            when others =>
              null;
          end case;
        end if;

      end if;
    end if;
  end process;
end architecture behavior;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

use work.lib.all;
use work.std_logic_textio.all;

entity dff is port (d                :     std_logic_vector(reg_size-1 downto 0);
                    clock, reset, en : in  std_logic;
                    q                : out std_logic_vector(reg_size-1 downto 0));
end entity dff;

architecture behavior of dff is
begin
  process (clock, reset)
    variable l : line;
  begin
    if reset = '0' then
-- report "dff reset" severity note;
      q <= (others => '0');
    elsif rising_edge(clock) and en = '1' then
      q <= d after signal_delay;
    end if;
  end process;
end architecture behavior;

library ieee;
use ieee.std_logic_1164.all;
use work.lib.all;
library std;
use std.textio;

entity memory_interface is

  port (
    clk, sreset_n : in  std_logic;
    scmdaccept    : in  std_logic;
    mcmd          : out std_logic_vector(2 downto 0);
    maddr, mdata  : out std_logic_vector(15 downto 0);
    sdata         : in  std_logic_vector(15 downto 0);
    sresp         : in  std_logic_vector(1 downto 0);
    oop           : out T_mem_op;
    addr          : in  std_logic_vector(15 downto 0);
    data          : in  std_logic_vector(15 downto 0);
    read          : out std_logic_vector(15 downto 0);
    done          : out std_logic;
    op            : in  T_mem_op
    );

end memory_interface;

architecture behavior of memory_interface is

begin  -- behavior
  mdata <= data       after signal_delay;
  maddr <= addr       after signal_delay;
  read  <= sdata      after signal_delay;
  done  <= scmdaccept after signal_delay;
  oop   <= op         after signal_delay;
end architecture behavior;
