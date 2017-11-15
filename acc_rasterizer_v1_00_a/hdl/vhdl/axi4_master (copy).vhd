library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.types.all;

entity axi4_master is
	generic
	(
		C_USE_WSTRB                    : integer              := 0;
		C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
		C_HIGHADDR                     : std_logic_vector     := X"00000000";
		C_M_AXI_ADDR_WIDTH             : integer              := 32;
		C_M_AXI_DATA_WIDTH             : integer              := 64
	);
	port
	(
		-- AXI4 Write-only Interfaces
		m_axi_aclk    : in  std_logic;
		m_axi_aresetn : in  std_logic;

        -- Address write channel
		m_axi_awready : in  std_logic;
		m_axi_awvalid : out std_logic;
		m_axi_awaddr  : out std_logic_vector( ( C_M_AXI_ADDR_WIDTH - 1 ) downto 0 );
		m_axi_awlen   : out std_logic_vector(  7 downto 0 );
		m_axi_awsize  : out std_logic_vector(  2 downto 0 );
		m_axi_awburst : out std_logic_vector(  1 downto 0 );
		m_axi_awprot  : out std_logic_vector(  2 downto 0 );
		m_axi_awcache : out std_logic_vector(  3 downto 0 );
		
		-- Data write channel
		m_axi_wready  : in  std_logic;
		m_axi_wvalid  : out std_logic;
		m_axi_wdata   : out std_logic_vector( ( C_M_AXI_DATA_WIDTH - 1 ) downto 0 );
		m_axi_wstrb   : out std_logic_vector( ( C_M_AXI_DATA_WIDTH / 8 ) - 1 downto 0 );
		m_axi_wlast   : out std_logic;
		
		-- Write response channel
		m_axi_bready  : out std_logic;
		m_axi_bvalid  : in  std_logic;
		m_axi_bresp   : in  std_logic_vector( 1 downto 0 );
		
		-- Frame buffer interface
		fb_addr_out   : out std_logic_vector( 2 downto 0 );
		fb_data_in    : in  std_logic_vector( C_M_AXI_DATA_WIDTH - 1 downto 0 );
		fb_data_en    : out std_logic;
        
		axi_addr      : in  u32_t;
        line_width    : in  u32_t;
        
		enable        : in  std_logic;
		done          : out std_logic
	);
end axi4_master;

architecture Behavioral of axi4_master is
	type state_t is ( S_REQUEST, S_WAIT, S_BUFFER,
                      S_WRITE_1, S_WRITE_2, S_WRITE_3, S_WRITE_4, S_FINISHED );

    signal reg_wdata   : std_logic_vector( C_M_AXI_DATA_WIDTH - 1 downto 0 );
    signal reg_fb_en   : std_logic;
    signal reg_wlast   : std_logic;
    signal reg_wvalid  : std_logic;
    signal reg_awvalid : std_logic;
    signal reg_awaddr  : u32_t;
    signal reg_done    : std_logic;

    type proc_t is record
        state   : state_t;
        row_cnt : unsigned( 2 downto 0 );
        fb_data : std_logic_vector( C_M_AXI_DATA_WIDTH * 4 - 1 downto 0 );
        aw_addr : unsigned( C_M_AXI_ADDR_WIDTH - 1 downto 0 );
        aw_done : std_logic;
        w_done  : std_logic;
    end record;

    signal proc_cur  : proc_t;
    signal proc_next : proc_t;
    
	constant c_prot  : std_logic_vector( 2 downto 0 ) := "010";		 -- Unpriviledged, non-secure, data access
	constant c_burst : std_logic_vector( 1 downto 0 ) := "01"; 		 -- INCR
	constant c_size  : std_logic_vector( 2 downto 0 ) := "011";      -- 8 bytes
	constant c_len   : std_logic_vector( 7 downto 0 ) := "00000011"; -- 4 beats
	
begin
	--------------------
	-- AXI4 Interface --
	--------------------
	m_axi_wstrb   <= ( others => '1' );	  -- Always write all bytes
	m_axi_awprot  <= c_prot;			  -- Unpriviledged, non-secure, data access
	m_axi_awcache <= ( others => '0' );	  -- No caching
	m_axi_awburst <= c_burst;			  -- Burst type is INCR
	m_axi_awsize  <= c_size;			  -- 8 bytes in transfer
	m_axi_awlen   <= c_len;				  -- Burst length of 4
	
	m_axi_awvalid <= reg_awvalid;
	m_axi_wvalid  <= reg_wvalid;
	m_axi_bready  <= '1';
	
	m_axi_wdata   <= reg_wdata;
	m_axi_wlast   <= reg_wlast;
	
	m_axi_awaddr  <= std_logic_vector( reg_awaddr );

    -- Frame buffer interface
    fb_addr_out   <= std_logic_vector( proc_cur.row_cnt );
    fb_data_en    <= reg_fb_en;

    done          <= reg_done;

    proc_seq : process( m_axi_aclk, m_axi_aresetn )
    begin
        if( rising_edge( m_axi_aclk ) )
        then
            if( m_axi_aresetn = '0' )
            then
                proc_cur.state   <= S_REQUEST;
                proc_cur.row_cnt <= ( others => '0' );
                proc_cur.fb_data <= ( others => '0' );
                proc_cur.aw_addr <= axi_addr;
                proc_cur.aw_done <= '0';
                proc_cur.w_done  <= '0';
            else
                proc_cur <= proc_next;
            end if;
        end if;
    end process;

    proc_comb : process( proc_cur, m_axi_aresetn, m_axi_awready, m_axi_wready, fb_data_in, axi_addr, line_width, enable )
    begin
        proc_next <= proc_cur;

        if( m_axi_aresetn = '0' )
        then
            reg_wdata   <= ( others => '0' );
            reg_wvalid  <= '0';
            reg_wlast   <= '0';
            reg_fb_en   <= '0';
            reg_awvalid <= '0';
            reg_awaddr  <= ( others => '0' );
            reg_done    <= '0';
        end if;

        if( enable = '1' )
        then
            case proc_cur.state is
                when S_REQUEST =>
                    reg_wdata       <= ( others => '0' );
                    reg_wvalid      <= '0';
                    reg_wlast       <= '0';
                    reg_awvalid     <= '0';
                    reg_awaddr      <= ( others => '0' );
                    reg_fb_en       <= '1';
                    proc_next.state <= S_WAIT;
                when S_WAIT =>
                    -- Retrieving data from block ram takes 1 clock cycle +
                    -- some slack, so it will not be valid this clock cycle.
                    -- Therefore we this state to actually wait 2 clock cycles.
                    proc_next.state <= S_BUFFER;
                when S_BUFFER =>
                    reg_fb_en  <= '0';
                    reg_wdata  <= fb_data_in;
                    reg_awaddr <= proc_cur.aw_addr;

                    if( proc_cur.aw_done = '0' )
                    then
                        reg_awvalid <= '1';
                    else
                        reg_awvalid <= '0';
                    end if;
                    
                    if( m_axi_awready = '1' )
                    then
                        proc_next.aw_done <= '1';
                    end if;

                    if( proc_cur.w_done = '0' )
                    then
                        reg_wvalid <= '1';
                    else
                        reg_wvalid <= '0';
                    end if;

                    if( m_axi_wready = '1' )
                    then
                        proc_next.w_done <= '1';
                        
                        if( proc_cur.row_cnt < "111" )
                        then
                            reg_wlast <= '0';
                        else
                            reg_wlast <= '1';
                        end if;

                        if( proc_cur.row_cnt = "111" )
                        then
                            proc_next.row_cnt <= ( others => '0' );
                            proc_next.aw_addr <= axi_addr;
                            proc_next.state   <= S_FINISHED;
                        else
                            proc_next.row_cnt <= proc_cur.row_cnt + 1;
                            proc_next.aw_addr <= resize( proc_cur.aw_addr + line_width, 32 );
                            proc_next.state   <= S_REQUEST;
                        end if;
                    else
                        -- AXI is not ready, so buffer fb_data_in
                        proc_next.fb_data <= fb_data_in;
                        proc_next.state   <= S_WRITE_1;
                    end if;
                when S_WRITE =>
                    reg_wdata  <= proc_cur.fb_data;
                    reg_awaddr <= proc_cur.aw_addr;

                    if( proc_cur.aw_done = '0' )
                    then
                        reg_awvalid <= '1';
                    else
                        reg_awvalid <= '0';
                    end if;
                    
                    if( m_axi_awready = '1' )
                    then
                        proc_next.aw_done <= '1';
                    end if;

                    if( proc_cur.w_done = '0' )
                    then
                        reg_wvalid <= '1';
                    else
                        reg_wvalid <= '0';
                    end if;
                    
                    if( m_axi_wready = '1' )
                    then
                        proc_next.w_done <= '1';
                        
                        if( proc_cur.row_cnt < "111" )
                        then
                            reg_wlast <= '0';
                        else
                            reg_wlast <= '1';
                        end if;

                        if( proc_cur.row_cnt = "111" )
                        then
                            proc_next.row_cnt <= ( others => '0' );
                            proc_next.aw_addr <= axi_addr;
                            proc_next.state   <= S_FINISHED;
                        else
                            proc_next.row_cnt <= proc_cur.row_cnt + 1;
                            proc_next.aw_addr <= resize( proc_cur.aw_addr + line_width, 32 );
                            proc_next.state   <= S_REQUEST;
                        end if;
                    else
                        proc_next.state <= S_WRITE;
                    end if;
                when S_FINISHED =>
                    reg_done        <= '1';
                    proc_next.state <= S_FINISHED;
                when others => null;
            end case;
        end if;
    end process;

end Behavioral;
