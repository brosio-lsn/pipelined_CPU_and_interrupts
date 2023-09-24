library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        sel_a     : in  std_logic;
        sel_imm   : in  std_logic;
        branch    : in  std_logic;
        a         : in  std_logic_vector(15 downto 0);
        d_imm     : in  std_logic_vector(15 downto 0);
        e_imm     : in  std_logic_vector(15 downto 0);
        pc_addr   : in  std_logic_vector(15 downto 0);
        addr      : out std_logic_vector(15 downto 0);
        next_addr : out std_logic_vector(15 downto 0)
    );
end PC;

architecture synth of PC is
    constant four : std_logic_vector(15 downto 0 ) := x"0004";
    signal first_plus : std_logic_vector(15 downto 0 );
    signal middle_plus : std_logic_vector(15 downto 0 );
    signal lower_plus : std_logic_vector(15 downto 0 );
    signal res_dff : std_logic_vector(15 downto 0 );
    signal res_prev_dff : std_logic_vector(15 downto 0 );
    signal d_imm_shift : std_logic_vector(15 downto 0 );
    signal selector : std_logic_vector(1 downto 0 );
begin
    
    lower_plus<=std_logic_vector(unsigned(a)+unsigned(four));
    
    middle_plus<=std_logic_vector(unsigned(e_imm)+unsigned(four));
    
    first_plus<=std_logic_vector(unsigned(middle_plus)+unsigned(pc_addr)) when branch ='1' else
            std_logic_vector(unsigned(res_dff)+unsigned(four));
            
    d_imm_shift <= (d_imm(13 downto 0)&"00");
    
    selector<=sel_imm & sel_a;
    
    process (selector, d_imm_shift, first_plus, lower_plus)
    begin
      case selector is
        when "00" =>
          res_prev_dff<=first_plus;
        when "01" =>
          res_prev_dff<=lower_plus;
        when "10" =>
          res_prev_dff<=d_imm_shift;
        when others =>
          -- optional: handle unexpected values of selector
      end case;
    end process;
    
    addr<=res_prev_dff;
    
    process (reset_n, clk)
    begin
      if reset_n = '0' then
        -- reset the system
        -- for example, set all registers and signals to their initial values
        res_dff <= (others => '0');
      elsif rising_edge(clk) then
        -- update res_dff on positive edge of clk
        res_dff <= res_prev_dff;
      end if;
    end process;

    next_addr<=res_dff;
    
    
    
    
end synth;
