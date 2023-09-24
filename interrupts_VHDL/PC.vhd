library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        en           : in  std_logic;
        sel_a        : in  std_logic;
        sel_imm      : in  std_logic;
        sel_ihandler : in  std_logic;
        add_imm      : in  std_logic;
        imm          : in  std_logic_vector(15 downto 0);
        a            : in  std_logic_vector(15 downto 0);
        addr         : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
    
constant leastSignificantBits : std_logic_vector(31 downto 0) := "00000000000000001111111111111100";
    signal curaddr : std_logic_vector(31 downto 0);
    signal nextaddr : std_logic_vector(31 downto 0);
    
begin
    
    --update curaddr
    pr : process (clk, reset_n) 
    begin
        if reset_n = '0' then
            curaddr<=(others => '0');
        elsif rising_edge(clk) then
            if en='1' then 
                curaddr<=nextaddr and leastSignificantBits;
            end if;
        end if;
    end process pr;
    
    --calculate next address
    nextAdr : process (curaddr, add_imm, imm, sel_imm, sel_a, a, sel_ihandler)
    begin
        if add_imm='0' then
            if sel_ihandler ='0' then
                if sel_imm='0' then
                    if sel_a ='0' then
                        nextaddr<=std_logic_vector(unsigned(curaddr)+to_unsigned(4,32));
                    else
                        nextaddr<="0000000000000000"&a;
                    end if;
                else
                    nextaddr<="0000000000000000"&imm(13 downto 0)&"00";
                end if;
            else
                nextaddr<="00000000000000000000000000000100"; --0x0004
            end if;
            
        else
            nextaddr<=std_logic_vector(unsigned(curaddr)+unsigned("0000000000000000"&imm));
        end if;
    end process nextAdr;
    
    --return the curent address
    result : process (curaddr)
    begin
        addr<=curaddr;
    end process result;
    
    
    
    
end synth;
