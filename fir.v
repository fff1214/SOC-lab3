module fir 
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)
(
    output  wire                     awready,
    output  wire                     wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,
    output  wire                     arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  wire                     rvalid,
    output  wire [(pDATA_WIDTH-1):0] rdata,    
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  wire                     ss_tready, 
    input   wire                     sm_tready, 
    output  wire                     sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  wire                     sm_tlast, 
    
    // bram for tap RAM
    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  wire [(pADDR_WIDTH-1):0] tap_A,
    input   wire [(pDATA_WIDTH-1):0] tap_Do,

    // bram for data RAM
    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,

    input   wire                     axis_clk,
    input   wire                     axis_rst_n,
    output  wire                     ap_start
);
begin

    // write your code here!
    
    reg awready_r;
    reg wready_r;
    reg awvalid_r;
    reg [(pADDR_WIDTH-1):0] awaddr_r;
    reg wvalid_r;
    reg [(pDATA_WIDTH-1):0] wdata_r;
    reg arready_r;
    reg rready_r;
    reg arvalid_r;
    reg [(pADDR_WIDTH-1):0] araddr_r;
    reg rvalid_r;
    reg [(pDATA_WIDTH-1):0] rdata_r;
    reg ss_tvalid_r;
    reg [(pDATA_WIDTH-1):0] ss_tdata_r;
    reg ss_tlast_r;
    reg ss_tready_r;
    reg sm_tready_r;
    reg sm_tvalid_r;
    reg [(pDATA_WIDTH-1):0] sm_tdata_r;
    reg sm_tlast_r;
    assign awready = awready_r;
    assign eready = wready_r;
    assign awvalid = awvalid_r;
    assign awaddr = awaddr_r;
    assign wvalid = wvalid_r;
    assign wdata = wdata_r;
    assign arready = arready_r;
    assign rready = rready_r;
    assign arvalid = arvalid_r;
    assign araddr = araddr_r;
    assign rvalid = rvalid_r;
    assign rdata = rdata_r;
    assign ss_tvalid = ss_tvalid_r;
    assign ss_tdata = ss_tdata_r;
    assign ss_tlast = ss_tlast_r;
    assign ss_tready = ss_tready_r;
    assign sm_tready = sm_tready_r;
    assign sm_tvalid = sm_tvalid_r;
    assign sm_tdata = sm_tdata_r;
    assign sm_tlast = sm_tlast_r;
    
    reg [3:0]tap_WE_r;
    reg tap_EN_r;
    reg [(pDATA_WIDTH-1):0] tap_Di_r;
    reg [(pADDR_WIDTH-1):0] tap_A_r;
    reg [(pDATA_WIDTH-1):0] tap_Do_r;
    assign tap_WE = tap_WE_r;
    assign tap_EN = tap_EN_r;
    assign tap_Di = tap_Di_r;
    assign tap_A = tap_A_r;
    assign tap_Do = tap_Do_r;
    
    reg [3:0] data_WE_r;
    reg data_EN_r;
    reg [(pDATA_WIDTH-1):0] data_Di_r;
    reg [(pADDR_WIDTH-1):0] data_A_r;
    reg [(pDATA_WIDTH-1):0] data_Do_r;
    assign data_WE = data_WE_r;
    assign data_EN = data_EN_r;
    assign data_Di = data_Di_r;
    assign data_A = data_A_r;
    assign data_Do = data_Do_r;
    
    reg ap_start_r;
    assign ap_start = ap_start_r;


    //AXI4-Lite read transaction
    always@(posedge axis_clk) begin
        if(!axis_rst_n) begin
            araddr_r <= 0;
            arvalid_r <= 0;
            arready_r <= 0;
            rready_r <= 0;
            rdata_r <= 0;
            rvalid_r <= 0;

            end
        else begin
            if(arvalid) begin
                araddr_r <= data_A;
                if(arready) begin   //handshake
                    rdata_r <= araddr_r;
                    araddr_r <= 0;
                    rvalid_r <= 1;
                    arvalid_r <=0;
                    arready_r <=0;
                end
            end
            else if(rready && rvalid) begin
                rready_r <= 0;
                rvalid_r <= 0;
            end
        end
    end
    
    //AXI4-Lite write
    always@(posedge axis_clk) begin
        if(!axis_rst_n) begin
            awaddr_r <= 0;
            awvalid_r <= 0;
            awready_r <= 0;
            wready_r <= 0;
            wdata_r <= 0;
            wvalid_r <= 0;
        end
        else begin
            if(awvalid) begin
                awaddr_r <= data_A_r;
                if(awready) begin //write_addr_handshake
                    awaddr_r <=0;
                    awvalid_r <= 0;
                    awready_r <= 0;
                end
            end
            else if(awready && awvalid) begin
                awready_r <= 0;
                awvalid_r <= 0;   
            end
            if(wvalid) begin
                awaddr_r <= data_Do;
                if(awready) begin //write_data_handshake
                    wvalid_r <= 0;
                    wready_r <= 0;
                end
            end
            else if(wready && wvalid) begin
                wready_r <= 0;
                wvalid_r <= 0;   
            end
        end
    end
    
    
    //AXI4-Stream Din
    always@(posedge axis_clk) begin
        if(!axis_rst_n) begin
            ss_tvalid_r <= 0;
            ss_tready_r <= 0;
            ss_tdata_r <= 0;
            ss_tlast_r <= 0;
        end
        else begin
            if(ss_tvalid && ss_tready) begin //transfer
                ss_tdata_r <= data_Di;
                if(ss_tlast) begin
                    ss_tvalid_r <= 0;
                    ss_tlast_r <= 0;
                end
            end
        end
    end
    
    //AXI4-Stream Dout
    always@(posedge axis_clk) begin
        if(!axis_rst_n) begin
            sm_tvalid_r <= 0;
            sm_tready_r <= 0;
            sm_tdata_r <= 0;
            sm_tlast_r <= 0;
        end
        else begin
            if(sm_tvalid && sm_tready) begin //transfer
                sm_tdata_r <= acc;
                if(sm_tlast) begin
                    sm_tvalid_r <= 0;
                    sm_tlast_r <= 0;
                    ap_start_r <= 0;
                end
            end
        end
    end
    
    //calculate
    wire muxsel;
    wire [(pDATA_WIDTH-1):0] sm_tdata_r;
    wire [(pDATA_WIDTH-1):0] ss_data_r;
    reg  [(pDATA_WIDTH-1):0] acc;
       

    always@(posedge axis_clk) begin 
        if(!axis_rst_n) begin
            acc <= 0;
        end
        else begin    
            acc <= acc + (data_Do * tap_Do);
            sm_tdata_r = acc;
        end
    end
    
end
endmodule