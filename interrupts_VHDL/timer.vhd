library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    port(
        -- bus interface
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(1 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);

        irq     : out std_logic;
        rddata  : out std_logic_vector(31 downto 0)
    );
end timer;

architecture synth of timer is
    constant counterad   : std_logic_vector(1 downto 0) := "00";
    constant periodad  : std_logic_vector(1 downto 0) := "01";
    constant controlad  : std_logic_vector(1 downto 0) := "10";
    constant statusad : std_logic_vector(1 downto 0) := "11";
    constant zero : std_logic_vector(31 downto 0 ) := x"00000000";
    SIGNAL counter_cur : std_logic_vector(31 downto 0 );
    signal period, control, status : std_logic_vector(31 downto 0);
    signal reg_read    : std_logic;
begin
    
    --irq:
    irq<='0' when control(1)='0' else status(1);
    
    --reg_read
    reg : process (clk)  --rajouter reset asynchrone 
    begin
        if(rising_edge(clk))then
            reg_read<=cs and read;
        end if;
    end process reg;
    
    --read
    process(reg_read, address, control, counter_cur, period, status)
    begin
        rddata <= (others => 'Z');
        if (reg_read = '1') then
            case address is
                when statusad =>rddata <= status;
                when controlad => rddata <=control;
                when periodad => rddata <= period;
                when counterad => rddata <=counter_cur;
                when others => null;
            end case;
        end if;
    end process;
    
    --TODO CLARIFIER LE TRUC OU ON CHANGE TO MM SI RUN EST A 0
    --write
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            period   <= zero;
            counter_cur <= zero;
            control <=zero;
            status <=zero;
        elsif (rising_edge(clk)) then
            if (cs = '1' and write = '1') then --si y a un write
                case address is
                    when periodad   => period(31 downto 0) <= wrdata; --si period change, counter devient juste period
                        counter_cur <=wrdata;
                        status(0)<='0';
                        
                        
                    when statusad =>
                            --update TO
                            if wrdata(1)='0' then status(1)<='0';
                            else status<=status;
                            end if;
                                    
                            --update counter based on run
                            if status(0)='0' then--cas ou run =0 (change juste si counter =0 pour le mettre a la periode)
                                if counter_cur = zero
                                    then counter_cur <= period;
                                    --status(1)<='1';
                                end if;
                            else -- cas ou run =1
                                if counter_cur = zero --si counter est a 0
                                    then counter_cur <= period; --counter devient period
                                    status(1)<='1'; --signaler un TO 
                                    if control(0)='0' then --si mon cont=0 et que le counter est a 0, je mets mon run a 0
                                        status(0)<='0';
                                    end if;
                                        
                                else counter_cur<=std_logic_vector(unsigned(counter_cur)-1);
                                end if;
                            end if;
                            
                    when controlad => control(1 downto 0) <=wrdata(1 downto 0);
                        if wrdata(2)='1'
                            then control(2)<='1';
                        end if;
                        if wrdata(3)='1'
                            then control(3)<='1';
                        end if;
                
                        if status(0)='0' then
                            if wrdata(3)='1' then
                                status(0)<='1';
                            end if;
                        else
                            if wrdata(2)='1' then
                                status(0)<='0';
                            end if;
                        end if;
                            
                        
                        --update counter based on run
                            if status(0)='0' then--cas ou run =0 (change juste si counter =0 pour le mettre a la periode)
                                if counter_cur = zero
                                    then counter_cur <= period;
                                    --status(1)<='1';
                                end if;
                            else -- cas ou run =1
                                if counter_cur = zero --si counter est a 0
                                    then counter_cur <= period;
                                    status(1)<='1';
                                    if control(0)='0' then --si mon cont=0 et que le counter est a 0, je mets mon run a 0
                                        status(0)<='0';
                                    end if;
                                        
                                else counter_cur<=std_logic_vector(unsigned(counter_cur)-1);
                                end if;
                            end if;
                    when others =>
                        --cas ou on ecrit le counter register 
                        --update counter based on run
                            if status(0)='0' then--cas ou run =0 (change juste si counter =0 pour le mettre a la periode)
                                if counter_cur = zero
                                    then counter_cur <= period;
                                    --status(1)<='1';
                                end if;
                            else -- cas ou run =1
                                if counter_cur = zero --si counter est a 0
                                    then counter_cur <= period;
                                    status(1)<='1';--TODO voir ed(peut changer pr que ce sot au clock cycle de 0 en mode si counter =1 et run =1 alors TO)
                                    if control(0)='0' then --si mon cont=0 et que le counter est a 0, je mets mon run a 0
                                        status(0)<='0';
                                    end if;
                                        
                                else counter_cur<=std_logic_vector(unsigned(counter_cur)-1);
                                end if;
                            end if;
                    end case;
            else --cas ou y a aucun write
            --update counter based on run
                        if status(0)='0' then--cas ou run =0 (change juste si counter =0 pour le mettre a la periode)
                            if counter_cur = zero
                                then counter_cur <= period;
                                --status(1)<='1';
                            end if;
                        else -- cas ou run =1
                            if counter_cur = zero --si counter est a 0
                                then counter_cur <= period;
                                status(1)<='1';
                                if control(0)='0' then --si mon cont=0 et que le counter est a 0, je mets mon run a 0
                                    status(0)<='0';
                                end if;
                                    
                            else counter_cur<=std_logic_vector(unsigned(counter_cur)-1);
                            end if;
                        end if;
            end if;
            
            
        end if;
    end process;
    
    --couter :
    --process(clk, reset_n) 
    --begin
        --if (reset_n = '0') then
            --counter_cur <= zero;
        --elsif (rising_edge(clk)) then
            --counter_cur <= counter_next;
        --end if;
    --end process;
    
    
    
    
    
end synth;
 