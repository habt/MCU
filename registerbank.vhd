library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity register_bank is 
port ( 
	clk,reset, write_enable : in std_logic;  
	data_in: in std_logic_vector(7 downto 0); -- input data to write to the registers  
	address_w,address_r1, address_r2: in std_logic_vector(3 downto 0); -- write address, Rx address, Ry address (in other words x and y)  
	data_out1,data_out2 : out std_logic_vector(7 downto 0) -- Rx data, Ry data 
); 
end register_bank;


ARCHITECTURE register_bankbehavioral OF register_bank IS
type two_dim_array is array (0 to 15) of std_logic_vector(7 downto 0);
signal reg_array : two_dim_array := (others=> (others=>'1'));
BEGIN
    data_out1 <= reg_array(conv_integer(address_r1));
    data_out2 <= reg_array(conv_integer(address_r2));
    register_bank_proc: process(clk)
    begin
      if reset='0' then
        if clk'event and clk = '1' then
	       if write_enable = '1' then
	         reg_array(to_integer(unsigned(address_w)))<= data_in;
	       end if;
	      end if;
      else
         reg_array <=(others=> (others=>'0'));
      end if;
    end process;

END ARCHITECTURE register_bankbehavioral;