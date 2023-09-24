library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        imm_signed : out std_logic;
        sel_b      : out std_logic;
        op_alu     : out std_logic_vector(5 downto 0);
        read       : out std_logic;
        write      : out std_logic;
        sel_pc     : out std_logic;
        branch_op  : out std_logic;
        sel_mem    : out std_logic;
        rf_wren    : out std_logic;
        pc_sel_imm : out std_logic;
        pc_sel_a   : out std_logic;
        sel_ra     : out std_logic;
        rf_retaddr : out std_logic_vector(4 downto 0);
        sel_rC     : out std_logic
    );
end controller;

architecture synth of controller is
    type state_type is (R_OP,STORE,BREAK,LOAD,I_OP,BRANCH, CALL, CALLR,JMP, JMPI, I_ALU);
    signal state: state_type;
    --degage fetch1, decode, 
    --rajouter u_iop
begin
    
    rf_retaddr<="11111"; --=register ra qu on doit update
    
    --read
    rd : process (state)
    begin
        if state =  LOAD then
            read<='1';
        else
            read<='0';
        end if;
    end process rd;
    
    --rf_wren
    rfWren : process (state)
    begin
        if state = I_OP  or state = R_OP or state = LOAD or state=CALL or state=CALLR or state = I_ALU then
            rf_wren<='1';
        else
            rf_wren<='0';
        end if;
    end process rfWren;
    
    --imm_signed
    immSigned : process (state)
    begin
        if state = I_OP  or state= LOAD or state=STORE then
            imm_signed<='1';  --laisser un seul load et l^dependantce
        else
            imm_signed<='0';
        end if;
    end process immSigned;
    
    --sel_rC
    selRC : process (state)
    begin
        if state = R_OP then
            sel_rC<='1';
        else 
            sel_rC<='0';
        end if;
    end process selRC;
    
    --sel_b
    selb : process (state)
    begin
        if state = R_OP or state=BRANCH  then
            sel_b<='1';
        else
            sel_b<='0';
        end if;
    end process selb;
    
    --sel_mem
    selMem : process (state)
    begin
        if state = LOAD then
            sel_mem<='1';
        else
            sel_mem<='0';
        end if;
    end process selMem;
    
    --write
    wrte : process (state)
    begin
        if state =STORE then
            write<='1';
        else
            write<='0';
        end if;
    end process wrte;
    
    --branch_op
    branchOP : process (state)
    begin
        if state =BRANCH then
            branch_op<='1';
        else
            branch_op<='0';
        end if;
    end process branchOP;
    
    
    --pc_sel_pc
    selPC : process (state)
    begin
        if state =CALL or state = CALLR then
            sel_pc<='1';
        else
            sel_pc<='0';
        end if;
    end process selPC;
    
    --pc_sel_ra
    selRA : process (state)
    begin
        if state =CALL or state=CALLR then
            sel_ra<='1';
        else
            sel_ra<='0';
        end if;
    end process selRA;
    
    --pc_sel_a
    pcSelA : process (state)
    begin
        if  state=CALLR or state=JMP then
            pc_sel_a<='1';
        else
            pc_sel_a<='0';
        end if;
    end process pcSelA;
    
    --pc_sel_imm
    pcSelImm : process (state)
    begin
        if state =JMPI or state=CALL then
            pc_sel_imm<='1';
        else
            pc_sel_imm<='0';
        end if;
    end process pcSelImm;
    
    
    --calculate next state
    nxt : process (state, op, opx)
    begin
        case op is
                when "111010" =>if opx = "110100"then 
                                    state<=BREAK;
                                elsif opx="011101" then
                                    state<=CALLR;
                                elsif opx="000101" or opx="001101" then
                                    state<=JMP;
                                else 
                                    state<=R_OP;
                                end if;
                when "000110" => state<=BRANCH;
                when "001110" => state<=BRANCH;
                when "010110" => state<=BRANCH;
                when "011110" => state<=BRANCH;
                when "100110" => state<=BRANCH;
                when "101110" => state<=BRANCH;
                when "110110" => state<=BRANCH;
                when "010111" => state<=LOAD; 
                when "010101" => state<=STORE;
            
                when "000000" => state<=CALL;
                when "000001" => state<=JMPI;
                when "000100" =>state<=I_OP;
                when "001000" =>state<=I_OP; -- xO8
                when "010000" =>state<=I_OP; --x10
                when "011000" =>state<=I_OP; -- x18
                when "100000" =>state<=I_OP; -- x20
                
    --I_ALU OP
                when "001100" => state <= I_ALU; -- and -x0C
                when "010100" => state <= I_ALU; --or -x14
                when "011100" => state <= I_ALU; --xnor -x1C
                when "101000" => state <= I_ALU; --a leq imm(unsigned) -x28
                when "110000" => state <= I_ALU; --a gt imm(unsigned) -x30
                when others => state<=state;
                end case;
    end process nxt;
    
    --op_alu
    opALU : process (op, opx)
        begin
        case op is
            when "111010" => case opx is
                                --initial CPU
                                when "001110" => op_alu<="100001";--and
                                when "011011" => op_alu<="110011";--srl
                                    
                                when "110100" => op_alu<="000000";--break -- TODO ? 
                                --ROP
                                when "110001" => op_alu <= "000000"; --+
                                when "111001" => op_alu <= "001000"; -- -
        
                                when "001000" => op_alu <= "011001";-- <= TODO signed ?
                                when "010000" => op_alu <= "011010"; -->
                                when "000110" => op_alu <= "100000"; --nor
                                --when "001110" => op_alu <= "100001"; -- and
                                when "010110" => op_alu <= "100010"; -- or
                                when "011110" => op_alu <= "100011"; -- xnor
                                when "010011" => op_alu <= "110010"; -- <<
                                --when "011011" => op_alu <= "110011"; -- >> unsigned TODO LEQUEL
                                when "111011" => op_alu <= "110111"; -- >>signed TODO lequel
                                when "010010" => op_alu <= "110010"; -- <<
                                when "011010" => op_alu <= "110011"; -- >> unsigned (TODO lequel)
                                when "111010" => op_alu <= "110111"; -- >> signed (TODO lequel)
                                when "011000" => op_alu <= "011011"; -- >> !=
                                when "100000" => op_alu <= "011100"; -- >> =
                                when "101000" => op_alu <= "011101"; -- >> <= unsigned
                                when "110000" => op_alu <= "011110"; -- >> > unsigned
                                when "000011" => op_alu <= "110000"; -- >> rol
                                when "001011" => op_alu <= "110001"; -- >> ror
                                when "000010" => op_alu <= "110000"; -- >> rol
                                when others=> op_alu<="000000";
                            end case;
            --chelou (load/store)
            when "010111" => op_alu<="000000";--add TODO demander ca aussi
            when "010101" => op_alu<="000000";--add
            --iop:
            --when "000100" => op_alu <= "000000"; -- + signed
            when "001100" => op_alu <= "100001"; -- and unsigned
            when "010100" => op_alu <= "100010"; -- or unsigned
            when "011100" => op_alu <= "100011"; -- xnor unsigned
            when "001000" => op_alu <= "011001"; -- <= signed
            when "010000" => op_alu <= "011010"; -- > signed
            when "011000" => op_alu <= "011011"; -- !=signed
            when "100000" => op_alu <= "011100"; -- =signed
            when "101000" => op_alu <= "011101"; -- <=unsigned
            when "110000" => op_alu <= "011110"; -- >unsigned
            --initial
            when "000100" => op_alu <= "000000"; -- > + signed
            --when "010111" => op_alu <= "000000"; -- > + signed
            --when "010101" => op_alu <= "000000"; -- >+ signed
            --branch instructions:
            when "000110" => op_alu <="011101";--unconditionnal branch (operands are both 0) 0x06
            when "001110" => op_alu<="011001";--signed <= 0x0E
            when "010110" => op_alu<="011010";--signed > 0x16
            when "011110" => op_alu<="011011";--!= 0x1E
            when "100110" => op_alu<="011100";--= 0x26
            when "101110" => op_alu<="011101";--unsigned<= 0x2E
            when "110110" => op_alu<="011110";--unsigned> 0x36
            when others => op_alu<="000000";
        end case;
    end process opALU;
    
    
    

end synth;
