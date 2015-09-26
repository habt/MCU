library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity idu is 
port (  
	instruction: in std_logic_vector(16 downto 0); -- input instruction to be decoded  
	operation: out std_logic_vector(3 downto 0); -- 4 bit opcode for the ALU (IR(15 downto12))  
	shift_rotate_operation: out std_logic_vector(2 downto 0); -- a number between 0 to 7 indicating ?how many times
	operand_selection: out std_logic; -- ?0? means operand2 <= Ry, ?1? means operand2 <= kk  
	x_address,y_address : out std_logic_vector(3 downto 0); -- Rx and Ry addresses 
	port_address: out std_logic_vector(7 downto 0); -- port_ID  
	conditional:out std_logic; -- indicating the jump is conditional or unconditional  
	jump :out std_logic; -- indicating the instruction type, ?1? means JMP, JZ, or JC, ?0? means normal  
	jump_address: out std_logic_vector(7 downto 0); -- indicating the line number for jump  
	condition_flag: out std_logic; -- condition type for jump, ?0? means JZ, ?1? means JC  
	exp: out std_logic; -- indicating whether the instruction is export (EXP) or not  
	halt: out std_logic -- ?1? means ?stop the execution? (end ofprogram) 
); 
end idu; 


ARCHITECTURE idubehavioral OF idu IS
--signal idu_instruction : std_logic_vector(16 downto 0);

BEGIN
  --idu_instruction <= instruction;
  
  
  idu_proc : process(instruction)
  begin
    operation <= instruction(15 downto 12);
    shift_rotate_operation <= instruction(2 downto 0);
    operand_selection <= instruction(16);
    x_address <= instruction(11 downto 8);
    y_address <= instruction(7 downto 4);
    port_address <= instruction(7 downto 0);
    if instruction(15 downto 12)= "1111" then
	     conditional <= instruction(16); -- last bit of instruction used for jump selection or operand selection
	     jump <= '1';
	     jump_address <= instruction(7 downto 0);
	     condition_flag <= instruction(11);
    else
	     jump <= '0';
    end if;
    if instruction(15 downto 12)= "0111" then 
	     exp <= '1';
    else
	     exp <= '0';
    end if;
    if instruction(15 downto 12)= "1110" then 
	     halt <= '1';
    else
	     halt <= '0';
    end if;
  end process;


END ARCHITECTURE idubehavioral;