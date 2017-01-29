library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio;

use work.lib.all;

entity processor_control is
  port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    alu_zero  : in  std_logic;
    mem_done  : in  std_logic;
    opcode    : in  opcodes;
    mem_src   : out T_mem_src;
    mem_op    : out T_mem_op;
    alu_srcA  : out T_alu_srcA;
    alu_srcB  : out T_alu_srcB;
    alu_cmd   : out T_alu_cmd;
    pc_write  : out std_logic;
    ir_write  : out std_logic;
    pc_src    : out T_pc_src;
    reg1_src  : out T_reg1_src;
    reg_cmd   : out T_reg_cmd;
    reg_src   : out T_reg_src;
    mdr_write : out std_logic
    );
end entity processor_control;

architecture behavior of processor_control is
  signal current_state : processor_state;
  signal next_state    : processor_state;

  type output_vector is record
                          mem_src   : T_mem_src;
                          mem_op    : T_mem_op;
                          alu_srcA  : T_alu_srcA;
                          alu_srcB  : T_alu_srcB;
                          alu_cmd   : T_alu_cmd;  -- not always constant
                          pc_write  : std_logic;  -- not always constant
                          ir_write  : std_logic;  -- not always constant
                          pc_src    : T_pc_src;
                          reg1_src  : T_reg1_src;
                          reg_cmd   : T_reg_cmd;  -- not always constant
                          reg_src   : T_reg_src;
                          mdr_write : std_logic;  -- not always constant
                        end record;

  type output_array is array (processor_state) of output_vector;

  -- Note: the following entries are not constant and will be handled later
  -- in the code. They are:
  -- * fetch(pc_write)
  -- * fetch(ir_write)
  -- * r_execute(alu_cmd)
  -- * branch_completion(pc_write)
  -- * load_execute(mdr_write)
  -- * i_execute(reg_cmd)
  -- * shift_execute(alu_cmd)
  constant outputs : output_array :=
    (fetch             => (pc, read, pc, incr, add, '1', '1', alu, rs1, none, alu_out, '0'),
     decode            => (pc, none, A, B, add, '0', '0', alu, rs1, none, alu_out, '0'),
     r_execute         => (pc, none, A, B, add, '0', '0', alu, rs1, none, alu_out, '0'),
     r_save            => (pc, none, A, B, add, '0', '0', alu, rs1, word, alu_out, '0'),
     branch_execute    => (pc, none, A, B, sub, '0', '0', alu, rd, none, alu_out, '0'),
     branch_completion => (pc, none, A, B, add, '0', '0', A, rs1, none, alu_out, '0'),
     store             => (A, write, A, B, add, '0', '0', alu, rs1, none, alu_out, '0'),
     load_execute      => (A, read, A, B, add, '0', '0', alu, rs1, none, alu_out, '1'),
     load_save         => (pc, none, A, B, add, '0', '0', alu, rs1, word, mdr, '0'),
     call              => (pc, none, A, B, add, '1', '0', A, rs1, word, pc, '0'),
     jump              => (pc, none, A, B, add, '1', '0', imm, rs1, none, alu_out, '0'),
     i_execute         => (pc, none, A, B, add, '0', '0', alu, rs1, none, imm, '0'),
     shift_execute     => (pc, none, A, imm, add, '0', '0', alu, rs1, none, alu_out, '0'),
     shift_save        => (pc, none, A, B, add, '0', '0', alu, rs1, word, alu_out, '0'));

begin  -- behavior

  sync : process (clock, reset)
    variable l : textio.line;
  begin  -- process sync
    if reset = '0' then
      current_state <= fetch;
    elsif rising_edge(clock) then
      current_state <= next_state;
      textio.write(l, now);
      textio.write(l, string'(" Entering state " & processor_state'image(next_state) & "**************************"));
      textio.writeline(textio.output, l);        
    end if;
  end process sync;

  fsm : process (current_state, mem_done, opcode)
  begin  -- process fsm
--  	report "fsm update" severity note;
    case current_state is
      when fetch      =>
        case mem_done is
          when '1'    => next_state <= decode;
          when others => next_state <= fetch;
        end case;

      when decode                =>
        case opcode is
          when add | sub | aand  => next_state <= r_execute;
          when nnor | mult | slt => next_state <= r_execute;
          when bne | beq         => next_state <= branch_execute;
          when call              => next_state <= call;
          when jump              => next_state <= jump;
          when load              => next_state <= load_execute;
          when store             => next_state <= store;
          when lui | li          => next_state <= i_execute;
          when shl | shr         => next_state <= shift_execute;
          when others            => null;
        end case;

      when r_execute         => next_state <= r_save;
      when r_save            => next_state <= fetch;
      when branch_execute    => next_state <= branch_completion;
      when branch_completion => next_state <= fetch;
      when store             => next_state <= fetch;
      when load_save         => next_state <= fetch;
      when call              => next_state <= fetch;
      when jump              => next_state <= fetch;
      when i_execute         => next_state <= fetch;
      when shift_execute     => next_state <= shift_save;
      when shift_save        => next_state <= fetch;

      when load_execute =>
        case mem_done is
          when '1'      => next_state <= load_save;
          when others   => next_state <= load_execute;
        end case;

      when others => null;
    end case;
  end process fsm;

  output         : process (current_state, mem_done, opcode, alu_zero)
    variable tmp : output_vector;
  begin  -- process output
    tmp := outputs(current_state);

    case current_state is
      when decode | r_save | branch_execute | store
        | load_save | call | jump | shift_save =>
        (mem_src, mem_op, alu_srcA, alu_srcB, alu_cmd, pc_write,
         ir_write, pc_src, reg1_src, reg_cmd, reg_src, mdr_write) <= outputs(current_state);

      when fetch =>
        mem_src   <= tmp.mem_src;
        mem_op    <= tmp.mem_op;
        alu_srcA  <= tmp.alu_srcA;
        alu_srcB  <= tmp.alu_srcB;
        alu_cmd   <= tmp.alu_cmd;
        pc_write  <= mem_done;
        ir_write  <= mem_done;
        pc_src    <= tmp.pc_src;
        reg1_src  <= tmp.reg1_src;
        reg_cmd   <= tmp.reg_cmd;
        reg_src   <= tmp.reg_src;
        mdr_write <= tmp.mdr_write;

      when r_execute =>
        mem_src   <= tmp.mem_src;
        mem_op    <= tmp.mem_op;
        alu_srcA  <= tmp.alu_srcA;
        alu_srcB  <= tmp.alu_srcB;
        alu_cmd   <= r_to_arith(opcode);
        pc_write  <= tmp.pc_write;
        ir_write  <= tmp.ir_write;
        pc_src    <= tmp.pc_src;
        reg1_src  <= tmp.reg1_src;
        reg_cmd   <= tmp.reg_cmd;
        reg_src   <= tmp.reg_src;
        mdr_write <= tmp.mdr_write;

      when branch_completion =>
        mem_src   <= tmp.mem_src;
        mem_op    <= tmp.mem_op;
        alu_srcA  <= tmp.alu_srcA;
        alu_srcB  <= tmp.alu_srcB;
        alu_cmd   <= tmp.alu_cmd;
        pc_write  <= branch_to_pc(opcode, alu_zero);
        ir_write  <= tmp.ir_write;
        pc_src    <= tmp.pc_src;
        reg1_src  <= tmp.reg1_src;
        reg_cmd   <= tmp.reg_cmd;
        reg_src   <= tmp.reg_src;
        mdr_write <= tmp.mdr_write;

      when load_execute =>
        mem_src   <= tmp.mem_src;
        mem_op    <= tmp.mem_op;
        alu_srcA  <= tmp.alu_srcA;
        alu_srcB  <= tmp.alu_srcB;
        alu_cmd   <= tmp.alu_cmd;
        pc_write  <= tmp.pc_write;
        ir_write  <= tmp.ir_write;
        pc_src    <= tmp.pc_src;
        reg1_src  <= tmp.reg1_src;
        reg_cmd   <= tmp.reg_cmd;
        reg_src   <= tmp.reg_src;
        mdr_write <= mem_done;

      when i_execute =>
        mem_src   <= tmp.mem_src;
        mem_op    <= tmp.mem_op;
        alu_srcA  <= tmp.alu_srcA;
        alu_srcB  <= tmp.alu_srcB;
        alu_cmd   <= tmp.alu_cmd;
        pc_write  <= tmp.pc_write;
        ir_write  <= tmp.ir_write;
        pc_src    <= tmp.pc_src;
        reg1_src  <= tmp.reg1_src;
        reg_cmd   <= i_to_reg(opcode);
        reg_src   <= tmp.reg_src;
        mdr_write <= tmp.mdr_write;

      when shift_execute =>
        mem_src   <= tmp.mem_src;
        mem_op    <= tmp.mem_op;
        alu_srcA  <= tmp.alu_srcA;
        alu_srcB  <= tmp.alu_srcB;
        alu_cmd   <= shift_to_arith(opcode);
        pc_write  <= tmp.pc_write;
        ir_write  <= tmp.ir_write;
        pc_src    <= tmp.pc_src;
        reg1_src  <= tmp.reg1_src;
        reg_cmd   <= tmp.reg_cmd;
        reg_src   <= tmp.reg_src;
        mdr_write <= tmp.mdr_write;


      when others => null;
    end case;
  end process output;
end behavior;
