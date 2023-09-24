library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_registers is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        write_n   : in  std_logic;
        backup_n  : in  std_logic;
        restore_n : in  std_logic;
        address   : in  std_logic_vector(2 downto 0);
        irq       : in  std_logic_vector(31 downto 0);
        wrdata    : in  std_logic_vector(31 downto 0);

        ipending  : out std_logic;
        rddata    : out std_logic_vector(31 downto 0)
    );
end control_registers;

architecture synth of control_registers is
    constant statusad   : std_logic_vector(2 downto 0) := "000";
    constant estatusad  : std_logic_vector(2 downto 0) := "001";
    constant bstatusad  : std_logic_vector(2 downto 0) := "010";
    constant ienablead : std_logic_vector(2 downto 0) := "011";
    constant ipendingad : std_logic_vector(2 downto 0) := "100";
    constant cpuidad : std_logic_vector(2 downto 0) := "101";
    constant zero : std_logic_vector(31 downto 0 ) := x"00000000";
    signal status, estatus, bstatus, ienable, ipendingReg, cpuid : std_logic_vector(31 downto 0);
begin
    --read
    process(address, estatus, ienable, ipendingReg, status)
    begin
        rddata <= (others => 'Z');
        case address is
            when statusad =>rddata <= status;
            when estatusad => rddata <=estatus;
            --when bstatusad => rddata <= period;
            when ienablead => rddata <=ienable;
            when ipendingad => rddata <=ipendingReg;
            --when cpuidad => rddata <=counter_cur;
            when others => null;
        end case;
    end process;
    
    --write (ie handle of status and ienable) + handle of EPIE
    --write
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            estatus<=zero;
            status   <= zero;
            ienable <= zero;
            bstatus <=zero;
            cpuid <=zero;
        elsif (rising_edge(clk)) then
            if write_n='0' then 
                case address is
                    when statusad => status(0)<=wrdata(0); --write the PIE 
                    when ienablead => ienable<=wrdata; --write the whole ienable
                    when others => null; -- other case are note writable
                end case;
            else -- if no write_n, check bachup then restore for the EPIE and PIE
                --check backup 
                if backup_n='0' then
                    estatus(0)<=status(0);
                    status(0)<='0';
                else
                    --check restore
                    if restore_n='0' then
                        status(0)<=estatus(0);
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    
    --ipendingReg process
    process(irq, ienable, reset_n)
    begin
        if(reset_n='0')then
            ipendingReg<=zero;
        else
            ipendingReg <=  ienable and irq;
        end if;
    end process;
    
    
    --ipending 
    ipending<='1' when (status(0)='1' and ipendingReg/=zero) else '0';
end synth;
