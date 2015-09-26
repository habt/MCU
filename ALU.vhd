library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.all; 

entity alu is 
port (  
	operation: in std_logic_vector(3 downto 0); -- 4 bit opcode from IDU  
	shift_rotate_operation: in std_logic_vector(2 downto 0); -- from IDU  
	operand_a,operand_b : in std_logic_vector(7 downto 0); -- first and second operands 
	result:out std_logic_vector(7 downto 0); -- result 
	zero,carry : out std_logic; -- zero and carry  
	input_port:in std_logic_vector(7 downto 0); -- data from a peripheral device (out of the microcontroller) 
	port_address: in std_logic_vector(7 downto 0); -- port_ID from IDU  
	output_port:out std_logic_vector(7 downto 0); -- data for a peripheral device (out of the microcontroller)  
	port_ID: out std_logic_vector(7 downto 0) -- port_ID for a peripheral device (out of the microcontroller) 
); 
end alu; 


ARCHITECTURE alubehavioral OF alu IS
type two_dim_array is array (0 to 15) of std_logic_vector(7 downto 0);
signal reg_array : two_dim_array := (others=> (others=>'0'));
signal sum_with_carry : std_logic_vector(8 downto 0);
signal sum_with_carry2 : std_logic_vector(8 downto 0);
signal twos_compl : std_logic_vector(8 downto 0);
signal twos_compl2 : std_logic_vector(8 downto 0);
signal temp : std_logic_vector(8 downto 0);
signal temp2 : std_logic_vector(8 downto 0);
BEGIN
    --d_nxt(idx) <= d_cur(to_integer(idx_cur_v));
    alu_proc: process(operation,operand_a,operand_b) -- saving to registers and others are handeled by the microcontroller 
    variable shft_result : std_logic_vector(8 downto 0);
    variable sgn_result : signed(7 downto 0);
    
    begin
      if operation = "0000"  then --load constant(opb) to Rx(opa) 
	      result <= operand_b;
      end if;
      if operation = "0001"  then -- AND Rx and constant, then save in Rx
	      result <= operand_a and operand_b;
      end if;
      if operation = "0010" then -- OR Rx and constant, then save in Rx
	      result <= operand_a or operand_b;
      end if;
      if operation = "0011" then -- XOR Rx and constant, then save in Rx
	      result <= operand_a xor operand_b;
      end if;
      if operation = "0100"  then -- add opa with opb
        -- if output is faulty for this one try using variable in place of sum_with_carry signal(conversion might be required)
	      --sum_with_carry <= ('0' & operand_a) + ('0' & operand_b); --sum <= ('0' & operand1) + ('0' & operand2);
	      --result <= sum_with_carry(7 downto 0);
	      --carry <= sum_with_carry(8);
	      sgn_result := signed(operand_a)+signed(operand_b);
	      result <= std_logic_vector(sgn_result);
	      if(std_logic_vector(sgn_result) = "00000000") then
	        zero <= '1';
	      else 
	        zero <= '0'; 
	      end if;
	      if operand_a(7) = '0' and operand_b(7)='0' and sgn_result(7)= '1' then --http://www.doc.ic.ac.uk/~eedwards/compsys/arithmetic/
	        carry <= '1';
	      elsif operand_a(7) = '1' and operand_b(7)='1' and sgn_result(7)= '0' then
	        carry <= '1';
	      else
	        carry<= '0';  
	      end if;
	        
      end if;
      if operation = "0110" then -- subtract
	       sgn_result := signed(operand_a)-signed(operand_b);
	       result <= std_logic_vector(sgn_result);
	       if(std_logic_vector(sgn_result) = "00000000") then
	         zero <= '1';
	       else
	         zero <= '0';
         end if;
         if operand_a(7)/= operand_b(7) and operand_b(7)= sgn_result(7) then --http://www.doc.ic.ac.uk/~eedwards/compsys/arithmetic/
           carry <= '1';
         else
            carry<= '0';  
         end if;
      end if;
      if operation = "1000"  then -- logical left shift
        shft_result := to_stdlogicvector( to_bitvector('0' & operand_a) sll to_integer(unsigned(shift_rotate_operation)) );
        result <= shft_result(7 downto 0);
        carry <= shft_result(8);
	      --result <= operand_a sll to_integer(unsigned(shift_rotate_operation));
	      --result <= operand_a sll conv_integer(shift_rotate_operation);
      end if;
      if operation = "1001" then --arthimetic left shift --carry
        shft_result := to_stdlogicvector( to_bitvector('0' & operand_a) sla to_integer(unsigned(shift_rotate_operation)) );
        result <= shft_result(7 downto 0);
        carry <= shft_result(8);
	      --result <= operand_a sla to_integer(unsigned(shift_rotate_operation));
      end if;
      if operation = "1010" then --logical right shift
        shft_result := to_stdlogicvector( to_bitvector( operand_a & '0') srl to_integer(unsigned(shift_rotate_operation)) );
        result <= shft_result(8 downto 1);
        carry <= shft_result(0);
	      --result <= operand_a srl to_integer(unsigned(shift_rotate_operation));
      end if;
      if operation = "1011"  then --arthimetic right shift --carry
        shft_result := to_stdlogicvector( to_bitvector( operand_a & '0') sra to_integer(unsigned(shift_rotate_operation)) );
        result <= shft_result(8 downto 1);
        carry <= shft_result(0);
	      --result <= operand_a sra to_integer(unsigned(shift_rotate_operation));
      end if;
      if operation = "1100"  then -- rotate left
        shft_result := to_stdlogicvector( to_bitvector('0' & operand_a) rol to_integer(unsigned(shift_rotate_operation)) );
	      --result <= operand_a rol to_integer(unsigned(shift_rotate_operation));
      end if;
      if operation = "1101"  then -- rotate right
        shft_result := to_stdlogicvector( to_bitvector('0' & operand_a) ror to_integer(unsigned(shift_rotate_operation)) );
	      --result <= operand_a ror to_integer(unsigned(shift_rotate_operation));
      end if;
      

    end process;

END ARCHITECTURE alubehavioral;