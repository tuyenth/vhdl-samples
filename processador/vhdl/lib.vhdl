library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log;
use ieee.math_real.MATH_LOG_OF_2;
use ieee.std_logic_1164.all;


package lib is
  function lg (n : positive) return natural;

  constant reg_size          : positive := 16;
  constant reg_count         : positive := 16;
  constant instruction_align : positive := 2;
  constant signal_delay : time := 1 ns;

  type T_mem_src is (pc, A);
  type T_mem_op is (none, read, write);
  type T_alu_srcA is (pc, A);
  type T_alu_srcB is (incr, B, imm);
  type T_alu_cmd is (add, sub, aand, nnor, mult, slt, shl, shr);
  type T_pc_src is (alu, A, imm);
  type T_reg1_src is (rs1, rd);
  type T_reg_cmd is (none, word, upper, lower);
  type T_reg_src is (alu_out, mdr, pc, imm);

  type opcodes is (add, sub, aand, nnor, mult, slt, beq, bne,
                   call, jump, load, store, lui, li, shl, shr);
  type processor_state is (fetch, decode, r_execute, r_save, branch_execute,
                           branch_completion, store, load_execute, load_save,
                           call, jump, i_execute, shift_execute, shift_save);

  function r_to_arith (op     : opcodes) return T_alu_cmd;
  function branch_to_pc (op   : opcodes; zero : std_logic) return std_logic;
  function i_to_reg (op       : opcodes) return T_reg_cmd;
  function shift_to_arith (op : opcodes) return T_alu_cmd;
  function ir_to_opcode (op   : std_logic_vector(3 downto 0)) return opcodes;

end package lib;

package body lib is
  function lg (n : positive) return natural is
  begin
    return natural(ceil(log(real(n))/MATH_LOG_OF_2));
  end function lg;

  function r_to_arith (op : opcodes) return T_alu_cmd is
  begin
    case op is
      when add    => return add;
      when sub    => return sub;
      when aand   => return aand;
      when nnor   => return nnor;
      when mult   => return mult;
      when slt    => return slt;
      when others =>
        report "Invalid R-type to ALU conversion" severity error;
        return add;
    end case;
  end function r_to_arith;

  function branch_to_pc (op : opcodes; zero : std_logic) return std_logic is
  begin
    case op is
      when beq    => return zero;
      when bne    => return not zero;
      when others =>
        report "Invalid branch to PC conversion" severity error;
        return '0';
    end case;
  end function branch_to_pc;

  function i_to_reg (op : opcodes) return T_reg_cmd is
  begin
    case op is
      when li     => return lower;
      when lui    => return upper;
      when others =>
        report "Invalid I-type to reg conversion" severity error;
        return none;
    end case;
  end function i_to_reg;

  function shift_to_arith (op : opcodes) return T_alu_cmd is
  begin
    case op is
      when shl    => return shl;
      when shr    => return shr;
      when others =>
        report "Invalid shift to ALU conversion" severity error;
        return add;
    end case;
  end function shift_to_arith;

  function ir_to_opcode (op : std_logic_vector(3 downto 0)) return opcodes is
  begin
    case op is
      when "0000" => return add;
      when "0001" => return sub;
      when "0010" => return aand;
      when "0011" => return nnor;
      when "0100" => return slt;
      when "0101" => return mult;
      when "0110" => return beq;
      when "0111" => return bne;
      when "1000" => return call;
      when "1001" => return jump;
      when "1010" => return load;
      when "1011" => return store;
      when "1100" => return lui;
      when "1101" => return li;
      when "1110" => return shl;
      when "1111" => return shr;
      when others =>
        null;
    end case;
  end function ir_to_opcode;

end package body lib;

