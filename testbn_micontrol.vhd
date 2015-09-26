
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;


-- entity declaration for your testbench.Dont declare any ports here
ENTITY TB_microcontroller IS 
END TB_microcontroller;

ARCHITECTURE TB_microcontrollerbehavior OF TB_microcontroller IS
    -- Component Declaration for the Unit Under Test (UUT)
  Component microcontroller IS
        port ( 
          clk,reset : in std_logic; 
          oe_bar: out std_logic; 
          address: out std_logic_vector(7 downto 0);  
          instruction: in std_logic_vector(16 downto 0);   
          input_port: in std_logic_vector(7 downto 0);   
          output_port: out std_logic_vector(7 downto 0); 
          port_id:out std_logic_vector(7 downto 0) 
  ); 
  END Component;
    
  Component inst_ROM IS
        port ( 
          oe_bar: in std_logic; -- output_enable  
          address:in std_logic_vector(7 downto 0); -- It indicates the current instruction address  
          data_out: out std_logic_vector(16 downto 0) -- It returns a 17-bit instruction
  ); 
  END Component;
        
  
  signal tb_clk : std_logic;
  signal tb_reset : std_logic; 
  signal tb_oe_bar : std_logic; 
  signal tb_address : std_logic_vector(7 downto 0);  
  signal tb_instruction : std_logic_vector(16 downto 0);   
  signal tb_input_port : std_logic_vector(7 downto 0);   
  signal tb_output_port : std_logic_vector(7 downto 0); 
  signal tb_port_id : std_logic_vector(7 downto 0); 
  constant clk_period : time := 1 sec;
  
  --signal tb_oe_bar : std_logic;
  --signal tb_address : std_logic_vector(7 downto 0);
  --signal tb_data_out : std_logic_vector(16 downto 0);
    
   
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   microcont_mp: microcontroller PORT MAP (
          clk => tb_clk,
          reset => tb_reset, 
          oe_bar => tb_oe_bar, 
          address => tb_address, 
          instruction => tb_instruction,  
          input_port => tb_input_port,   
          output_port => tb_output_port, 
          port_id => tb_port_id
        ); 
        
  instrom_mp: inst_ROM PORT MAP (
          oe_bar => tb_oe_bar,
          address => tb_address,
          data_out => tb_instruction
        ); 

 
 -- Clock process definitions( clock with 50% duty cycle is generated here.
    clk_process :process
    begin
         tb_clk <= '0';
         wait for clk_period/2;  --for 0.5 ns signal is '0'. actually 0.05 seconds here
         tb_clk <= '1';
         wait for clk_period/2;  --for next 0.5 ns signal is '1'.
    end process;
   
   --Stimulus process
  microcont_stim_proc: process
  begin
    tb_reset <= '1';
    wait for 2 ns;
    tb_reset <= '0';    
    wait;
  end process;
  
   --clk <= not clk after half_period;
   --wait for 0.05 ns;

END;
