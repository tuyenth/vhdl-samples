library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.std_logic_textio;

use work.lib.all;
library std;
use std.textio;

entity Processador is
  port (Clk,
        SReset_n   : in  std_logic;
        MCmd       : out std_logic_vector(2 downto 0);
        MAddr,
        MData      : out std_logic_vector(15 downto 0);
        SCmdAccept : in  std_logic;
        SResp      : in  std_logic_vector(1 downto 0);
        SData      : in  std_logic_vector(15 downto 0);
        oop        : out T_mem_op);
end entity Processador;

architecture behavior of processador is
  signal pc_in    : std_logic_vector(reg_size-1 downto 0);
  signal pc_out   : std_logic_vector(reg_size-1 downto 0);
  signal pc_write : std_logic;
  signal pc_src   : T_pc_src;

  signal mem_addr_in : std_logic_vector(15 downto 0);
  signal mem_src     : T_mem_src;
  signal mem_write   : std_logic_vector(reg_size-1 downto 0);
  signal mem_read    : std_logic_vector(reg_size-1 downto 0);
  signal mem_op      : T_mem_op;
  signal mem_done    : std_logic;

  signal ir_in    : std_logic_vector(reg_size-1 downto 0);
  signal ir_write : std_logic;
  signal ir_out   : std_logic_vector(reg_size-1 downto 0);
  alias ir_rs1    : std_logic_vector(3 downto 0) is ir_out(7 downto 4);
  alias ir_rs2    : std_logic_vector(3 downto 0) is ir_out(3 downto 0);
  alias ir_rd     : std_logic_vector(3 downto 0) is ir_out(11 downto 8);
  alias ir_opcode : std_logic_vector(3 downto 0) is ir_out(15 downto 12);
  alias ir_imm8   : std_logic_vector(7 downto 0) is ir_out(7 downto 0);
  alias ir_imm12  : std_logic_vector(11 downto 0) is ir_out(11 downto 0);
  alias ir_imm4   : std_logic_vector(3 downto 0) is ir_out(3 downto 0);

  signal mdr_in    : std_logic_vector(reg_size-1 downto 0);
  signal mdr_out   : std_logic_vector(reg_size-1 downto 0);
  signal mdr_write : std_logic;


  signal R1_in    : std_logic_vector(lg(reg_count)-1 downto 0);
  signal R2_in    : std_logic_vector(lg(reg_count)-1 downto 0);
  signal W1_in    : std_logic_vector(lg(reg_count)-1 downto 0);
  signal data_in  : std_logic_vector(reg_count-1 downto 0);
  signal reg_cmd  : T_reg_cmd;
  signal reg1_src : T_reg1_src;
  signal reg_src  : T_reg_src;
  signal A_out    : std_logic_vector(reg_size-1 downto 0);
  signal B_out    : std_logic_vector(reg_size-1 downto 0);

  signal alu_A    : std_logic_vector(reg_size-1 downto 0);
  signal alu_B    : std_logic_vector(reg_size-1 downto 0);
  signal alu_S    : std_logic_vector(reg_size-1 downto 0);
  signal alu_srcA : T_alu_srcA;
  signal alu_srcB : T_alu_srcB;
  signal alu_cmd  : T_alu_cmd;

  signal alu_out_in  : std_logic_vector(reg_size-1 downto 0);
  signal alu_out_out : std_logic_vector(reg_size-1 downto 0);
  signal alu_zero    : std_logic;

  alias clock : std_logic is Clk;
  alias reset : std_logic is SReset_n;
begin  -- behavior

  PC : entity work.dff port map (
    d     => pc_in,
    q     => pc_out,
    clock => clock,
    reset => reset,
    en    => pc_write);
  with pc_src select
    pc_in <=
    alu_S                                 after signal_delay when work.lib.alu,
    A_out                                 after signal_delay when A,
    pc_out(15 downto 13) & ir_imm12 & '0' after signal_delay when imm;

  MEM : entity work.memory_interface port map (
    Clk, SReset_n, SCmdAccept, MCmd, MAddr, MData, SData,
    SResp, oop, mem_addr_in, mem_write, mem_read, mem_done, mem_op);
  with mem_src select
    mem_addr_in <=
    pc_out               after signal_delay when work.lib.pc,
    A_out                after signal_delay when A;
  mem_write     <= B_out after signal_delay;

  IR : entity work.dff port map (
    d     => ir_in,
    q     => ir_out,
    clock => clock,
    reset => reset,
    en    => ir_write);
  ir_in <= mem_read after signal_delay;

  MDR : entity work.dff port map (
    d     => mdr_in,
    q     => mdr_out,
    clock => clock,
    reset => reset,
    en    => mdr_write);
  mdr_in <= mem_read after signal_delay;

  REGS : entity work.reg_bank port map (
    read1     => R1_in,
    read2     => R2_in,
    write1    => W1_in,
    write1_in => data_in,
    read1_out => A_out,
    read2_out => B_out,
    write_cmd => reg_cmd,
    clock     => clock);
  with reg1_src select
    R1_in   <=
    ir_rs1 after signal_delay when rs1,
    ir_rd  after signal_delay when rd;
  R2_in     <= ir_rs2;
  W1_in     <= ir_rd;
  with reg_src select
    data_in <=
    mdr_out                   when work.lib.mdr,
    "00000000" & ir_imm8      when imm,
    pc_out                    when work.lib.pc,
    alu_out_out               when work.lib.alu_out;

  ALU : entity work.lalu port map (
    alu_A,
    alu_B,
    alu_S,
    alu_cmd);
  with alu_srcA select
    alu_A <=
    A_out                    when A,
    pc_out                   when work.lib.pc;
  with alu_srcB select
    alu_B <=
    "0000000000000010"       when incr,
    B_out                    when B,
    "000000000000" & ir_imm4 when imm;

  ALU_out : entity work.dff port map (
    d     => alu_out_in,
    q     => alu_out_out,
    clock => clock,
    reset => reset,
    en    => '1');
  alu_out_in <= alu_S;
  with alu_out_out select
    alu_zero <=
    '1' when "0000000000000000",
    '0' when others;

  control : entity work.processor_control port map (
    clock, reset, alu_zero, mem_done, ir_to_opcode(ir_opcode), mem_src,
    mem_op, alu_srcA, alu_srcB, alu_cmd, pc_write,
    ir_write, pc_src, reg1_src, reg_cmd, reg_src, mdr_write
    );


  debug        : process(clock, reset)
    variable l : textio.line;
  begin
    if reset = '1' and falling_edge(clock) then
      textio.write(l, now);
      textio.writeline(textio.output, l);
      textio.write(l, string'("PC ******"));
      textio.writeline(textio.output, l);
      textio.write(l, pc_in'path_name & ":", textio.left, 40);
      std_logic_textio.hwrite(l, pc_in);
      textio.writeline(textio.output, l);
      textio.write(l, pc_out'path_name & ":", textio.left, 40);
      std_logic_textio.hwrite(l, pc_out);
      textio.writeline(textio.output, l);
      textio.write(l, pc_src'path_name & ":", textio.left, 40);
      textio.write(l, T_pc_src'image(pc_src));
      textio.writeline(textio.output, l);
      textio.write(l, pc_write'path_name & ":", textio.left, 40);
      std_logic_textio.write(l, pc_write);
      textio.writeline(textio.output, l);
      textio.write(l, string'("MEM ******"));
      textio.writeline(textio.output, l);
      textio.write(l, mem_addr_in'path_name & ":", textio.left, 40);
      std_logic_textio.hwrite(l, mem_addr_in);
      textio.writeline(textio.output, l);
      textio.write(l, mem_read'path_name & ":", textio.left, 40);
      std_logic_textio.hwrite(l, mem_read);
      textio.writeline(textio.output, l);
      textio.write(l, mem_write'path_name & ":", textio.left, 40);
      std_logic_textio.hwrite(l, mem_write);
      textio.writeline(textio.output, l);
      textio.write(l, mem_done'path_name & ":", textio.left, 40);
      std_logic_textio.write(l, mem_done);
      textio.writeline(textio.output, l);
      textio.write(l, mem_op'path_name & ":", textio.left, 40);
      textio.write(l, T_mem_op'image(mem_op));
      textio.writeline(textio.output, l);
    end if;
  end process debug;



end architecture behavior;
