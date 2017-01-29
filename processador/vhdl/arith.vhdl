library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

entity lalu is
  port (
    a, b : in  std_logic_vector(reg_size-1 downto 0);
    r    : out std_logic_vector(reg_size-1 downto 0);
    cmd  : in  T_alu_cmd
    );
end entity lalu;

architecture behavior of lalu is
begin
  process (a, b, cmd)
    variable sa, sb, sr, sd : signed(reg_size-1 downto 0);
    variable x : std_logic_vector(reg_size-1 downto 0);
  begin
--  	report "Alu" severity note;
    if is_X(a) or is_X(b) then
      r <= (others => 'X');
      report "ALU is weird" severity note;
    else
      sa := signed(a);
      sb := signed(b);

      case cmd is
        when add  =>
          sr   := sa+sb;
        when sub  =>
          sr   := sa-sb;
        when aand =>
          sr   := sa and sb;
        when nnor =>
          sr   := sa nor sb;
        when slt  =>
          if (sa-sb < 0) then
            sr := to_signed(1, reg_size);
          else
            sr := to_signed(0, reg_size);
          end if;
        when mult =>
          sr   := resize(sa*sb, 16);
        when shr  =>
          sr   := shift_right(sa, to_integer(sb));
        when shl  =>
          sr   := shift_left(sa, to_integer(sb));
      end case;

      r <= std_logic_vector(sr);
    end if;
  end process;
end architecture behavior;
