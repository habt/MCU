library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity microcontroller is 
port ( 
	clk,reset : in std_logic; 
	oe_bar: out std_logic; -- to read from the Instruction Memory  
	address: out std_logic_vector(7 downto 0); -- It indicates the current instruction address  
	instruction: in std_logic_vector(16 downto 0); -- It receives a 17bit instruction  
	input_port: in std_logic_vector(7 downto 0); -- input port to connect to peripheral devices  
	output_port: out std_logic_vector(7 downto 0); -- output port to connect to peripheral devices  
	port_id:out std_logic_vector(7 downto 0) -- It indicates the port address for export(EXP) operation. 
); 
end microcontroller; 


ARCHITECTURE microcontrollerbehavioral OF microcontroller IS


component register_bank is 
port ( 
  clk,reset, write_enable : in std_logic;  
  data_in: in std_logic_vector(7 downto 0); -- input data to write to the registers  
  address_w,address_r1, address_r2: in std_logic_vector(3 downto 0); -- write address, Rx address, Ry address (in other words x and y)  
  data_out1,data_out2 : out std_logic_vector(7 downto 0) -- Rx data, Ry data 
); 
end component;

component alu is 
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
end component;

component idu is 
port (  
	instruction: in std_logic_vector(16 downto 0);  
	operation: out std_logic_vector(3 downto 0);  
	shift_rotate_operation: out std_logic_vector(2 downto 0); 
	operand_selection: out std_logic;  
	x_address,y_address : out std_logic_vector(3 downto 0);  
	port_address: out std_logic_vector(7 downto 0); 
	conditional:out std_logic;  
	jump :out std_logic;  
	jump_address: out std_logic_vector(7 downto 0);  
	condition_flag: out std_logic;   
	exp: out std_logic;   
	halt: out std_logic 
); 
end component;

TYPE m_state IS (id_ex,wb);
SIGNAL current_state : m_state := id_ex;
SIGNAL next_state: m_state := wb;
signal instruction_line : std_logic_vector(16 downto 0);
signal const : std_logic_vector(7 downto 0);
signal operand_1 : std_logic_vector(7 downto 0);
signal operand_2 : std_logic_vector(7 downto 0);
signal rx : std_logic_vector(7 downto 0);-- register_1 mapped to register bank data_out1
signal ry : std_logic_vector(7 downto 0);-- register_2 mapped to register bank data_out2
signal input_data : std_logic_vector(7 downto 0);
signal output_data : std_logic_vector(7 downto 0);
signal prt_adr : std_logic_vector(7 downto 0);
signal prt_id : std_logic_vector(7 downto 0);
signal op_code: std_logic_vector(3 downto 0);  
signal shift_rotate: std_logic_vector(2 downto 0); 
signal operand_select: std_logic;
signal address_1 : std_logic_vector(3 downto 0);--to be mapped to idu x_address and registerbank address_r1
signal address_2 : std_logic_vector(3 downto 0);--to be mapped to idu y_adrdess and registerbank address_r2
signal cry : std_logic;
signal zr : std_logic;
signal cond : std_logic;
signal jp : std_logic;
signal jp_adr : std_logic_vector(7 downto 0);
signal cond_flag : std_logic;
signal exprt : std_logic;
signal hlt : std_logic;
signal program_counter : std_logic_vector(7 downto 0):= "00000000";
signal rslt : std_logic_vector(7 downto 0);
signal m_clk : std_logic;
signal rst : std_logic;
signal wr_en : std_logic;
signal data_reg : std_logic_vector(7 downto 0); -- data to write to registers





BEGIN
  
    reg_bank_mp: register_bank PORT MAP (
              clk => m_clk,
              reset => rst,
              write_enable => wr_en, 
              data_in => data_reg, 
              address_w => address_1,
              address_r1 => address_1, 
              address_r2 => address_2,  
              data_out1 => rx,
              data_out2 => ry
              ); 
  
    alu_mp: alu PORT MAP (
              operation => op_code,  
              shift_rotate_operation => shift_rotate,  
              operand_a => operand_1,
              operand_b => operand_2,
              result => rslt,
              zero => zr,
              carry => cry,
              input_port => input_data, --??
              port_address => prt_adr, --?? --maybe same bits as jmp_adr
              output_port => output_data, --?? 
              port_ID => prt_id -- ?? what isthe use of these here in ALU
            ); 
  
  
    idu_mp: idu PORT MAP (
            instruction => instruction_line,
	          operation => op_code,
	          shift_rotate_operation => shift_rotate, 
	          operand_selection => operand_select, 
	          x_address => address_1,
	          y_address => address_2, 
	          port_address => prt_adr,
	          conditional => cond,  
	          jump => jp,  
	          jump_address => jp_adr,  
	          condition_flag => cond_flag,  
	          exp => exprt,   
	          halt => hlt
          );  
      
  operand_1 <= rx;
  instruction_line <= instruction;
  m_clk <= clk;
  rst <= reset;
  address <= program_counter;
  state_proc : process(clk) begin
    if current_state = id_ex then
      next_state <= wb;
    elsif current_state = wb then
      next_state <= id_ex;
    else
      null;
    end if;
  end process state_proc;
  seq_proc:PROCESS (clk) BEGIN -- two different action sequences based on the current state(id_ex or wr)
     --variable current_state : m_state := id_ex;
     --variable next_state : m_state := wb;
     if reset = '0' then
      if clk'event and clk= '1' then
        --here maybe insert condition if hlt not equal to zero
          if(current_state = id_ex) then -- alu is clk free(combinational) 
            oe_bar <= '1';
            current_state <= next_state;
            --next_state <= wb;
            wr_en <= '0';
          end if;
        
        if(current_state = wb) then
          oe_bar <= '0';
          current_state <= next_state;
          --next_state <= id_ex;
          if jp = '0' then
            if exprt = '0' and hlt = '0' then -- works for import as well
              wr_en <= '1'; -- maybe here add condition check if carry = 0 to enable writing
              program_counter <= program_counter +'1';-- std_logic_vector(unsigned(program_counter)+1);
            elsif exprt = '1' then
              port_id <= prt_adr;
              output_port <= rx;
              program_counter <= program_counter +'1';
            elsif hlt = '1' then
              program_counter <= program_counter;
            else
              --program_counter <= program_counter +'1';
              null;
            end if;
          end if;
          if jp = '1' then
            if cond = '1' then
              if cond_flag = '1' then -- jump if carry is 1
                if cry = '1' then
                  program_counter <= jp_adr;
                else
                  program_counter <= program_counter +'1';
                end if;
              end if;
              if cond_flag = '0' then -- jump if zero is 1
                if zr = '1' then
                  program_counter <= jp_adr;
                  wr_en <= '1';
                else 
                  program_counter <= program_counter +'1';
                end if;
              end if;
            end if;
            if cond = '0' then -- unconditional jump
              program_counter <= jp_adr;
            end if;
          end if;
        end if;
      else
        null;--program_counter <=  (others=>'0'); 
      end if;
    end if; 
  END PROCESS seq_proc;

  -- Synthesis Issues
  -- A "combinational process" must have a sensitivity list containing all the signals which it reads (inputs), 
  -- and must always update the signals which it assigns (outputs): 
  comb_proc:PROCESS(operand_select,ry,prt_adr,rx,op_code,input_port,rslt)  BEGIN -- the multiplexing and data selection
    --operand_2 <= (others => 'Z');
    if operand_select = '1' then 
	    operand_2 <= prt_adr; -- register_2 mapped to register bank data_out2
    else 
      operand_2 <= ry;
    end if;

    --if exprt = '1' then
	    --port_id <= prt_adr;
	    --output_port <= rx;
	  --else
	    --port_id <= (others => 'Z');
      --output_port <= (others => 'Z');
    --end if;
   
   
    if op_code = "0101" then -- import operation 
      data_reg <= input_port;   --- do we need to set write_enable as well???
    else
      data_reg <= rslt;
    end if;
   
  END PROCESS comb_proc;


END ARCHITECTURE microcontrollerbehavioral;