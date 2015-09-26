library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.all; 



entity inst_ROM is 
port ( 
	oe_bar: in std_logic; -- output_enable  
	address:in std_logic_vector(7 downto 0); -- It indicates the current instruction address  
	data_out: out std_logic_vector(16 downto 0) -- It returns a 17-bit instruction 
); 
end inst_ROM; 

ARCHITECTURE inst_ROMbehavioral OF inst_ROM IS
type two_dim_array is array (0 to 255) of std_logic_vector(16 downto 0);
--signal mem_array : two_dim_array := ("10000001100001100","10000000000000111","10000000100000111","10110001100001100",others=> (others=>'0'));
-- the shift left logical here is changed to a shift value of 1 instead of 4 given on the assigment paper
signal mem_array : two_dim_array := ("10000001100001100","10000000000000000","10000000100000001","10111000011111111","10111000111111111","00000001000010000","00100000100000000","10111000111111111","00000000000100000","10110001100000001","11111000000001100","01111000000000101","10000010000111111","01000010000000001","10111010011111110","11111100000010001","01111000000001101","01110000000000000",others=> (others=>'0')); --final test sequence
BEGIN
  
    inst_ROM_proc: process(oe_bar)
    --variable varadr : integer:=0;
    begin
	    if oe_bar = '1' then
	      data_out <= mem_array(to_integer(unsigned(address)));
	    end if;
    end process;

END ARCHITECTURE inst_ROMbehavioral;
