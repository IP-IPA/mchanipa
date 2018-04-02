////////////////////////////////////////////////////////////////////////////////
// Company:        Multitherman Laboratory @ DEIS - University of Bologna     //
//                 Viale Risorgimento 2 40136                                 //
//                 Bologna - fax 0512093785 -                                 //
//                                                                            //
// Engineer:       Davide Rossi - davide.rossi@unibo.it                       //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    23/11/2015                                                 // 
// Design Name:    PULP                                                       // 
// Module Name:    twod_trans_queue                                           //
// Project Name:   PULP                                                       //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    queue for 2D transactions parameters                       //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - File Created                                               //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module twd_trans_queue_ipa
  #(
    parameter NB_CORES            = 4,
    parameter TWD_QUEUE_WIDTH     = 2,
    parameter TWD_QUEUE_DEPTH     = 4,
    parameter TWD_QUEUE_ADD_WIDTH = $clog2(TWD_QUEUE_DEPTH)
    )
   (
    
    input  logic                                         clk_i,
    input  logic                                         rst_ni,
    
    input  logic [NB_CORES-1:0]                          alloc_req_i,
    output logic [NB_CORES-1:0]                          alloc_gnt_o,
    output logic [NB_CORES-1:0][TWD_QUEUE_ADD_WIDTH-1:0] alloc_add_o,
    
    input  logic [NB_CORES-1:0]                          wr_req_i,
    input  logic [NB_CORES-1:0][TWD_QUEUE_ADD_WIDTH-1:0] wr_add_i,
    input  logic [NB_CORES-1:0][TWD_QUEUE_WIDTH-1:0]     wr_dat_i,
    
    input  logic                                         tx_rd_req_i,
    input  logic [TWD_QUEUE_ADD_WIDTH-1:0]               tx_rd_add_i,
    output logic [TWD_QUEUE_WIDTH-1:0]                   tx_rd_dat_o,
    
    input  logic                                         rx_rd_req_i,
    input  logic [TWD_QUEUE_ADD_WIDTH-1:0]               rx_rd_add_i,
    output logic [TWD_QUEUE_WIDTH-1:0]                   rx_rd_dat_o
    
    );
   
   // Internal data structures
   logic [TWD_QUEUE_ADD_WIDTH-1:0]                  s_pointer; // pointer to current free element
   logic [TWD_QUEUE_DEPTH-1:0][TWD_QUEUE_WIDTH-1:0] s_buffer;  // table
   logic [TWD_QUEUE_DEPTH-1:0]                      s_busy;    // busy tag
   
   logic 					    s_full;
   
   logic                                            s_alloc_req, s_alloc_gnt;
   
   integer                                          s_loop1,s_loop2,s_loop3;
   genvar 					    i;
   
   // ARBITER
   mchan_arbiter_ipa
     #(
       .DATA_WIDTH(1),
       .N_MASTER(NB_CORES)
       )
   twd_queue_arbiter_ipa_i
     (
      
      .clk(clk_i),
      .rst_n(rst_ni),
      
      .data_i('0),
      .req_i(alloc_req_i),
      .gnt_o(alloc_gnt_o),
      
      .req_o(s_alloc_req),
      .gnt_i(s_alloc_gnt),
      .id_o(),
      .data_o()
      
      );
   
   // COMPUTE CURRENT POINTER LOCATION
   always_comb
     begin
	s_pointer = 0;
        for (s_loop1 = TWD_QUEUE_DEPTH - 1 ; s_loop1 >= 0  ; s_loop1 = s_loop1 - 1)
          begin
             if (s_busy[s_loop1] == 1'b0)
               s_pointer = s_loop1;
          end
     end
   
   // 2D TRANS QUEUE BUFFER
   always @(posedge clk_i or negedge rst_ni)
     begin
        if (rst_ni == 1'b0)
          begin
             for (s_loop2 = 0 ; s_loop2 < TWD_QUEUE_DEPTH ; s_loop2 = s_loop2 + 1)
               begin
                  s_buffer[s_loop2] <= 0;
               end
          end
        else
          begin
	     for (s_loop3 = 0 ; s_loop3 < NB_CORES ; s_loop3 = s_loop3 + 1)
               begin
                  if (wr_req_i[s_loop3] == 1)
		    begin
		       s_buffer[wr_add_i[s_loop3]] <= wr_dat_i[s_loop3];
		    end
               end
          end
     end
   
   // COMPUTE BUSY VECTOR
   always @(posedge clk_i or negedge rst_ni)
     begin
        if (rst_ni == 1'b0)
          begin
             s_busy <= 0;
          end
        else
          begin
             if (s_alloc_req && s_alloc_gnt)
               begin
                  s_busy[s_pointer] <= 1;
               end
             
             if (tx_rd_req_i)
               begin
                  s_busy[tx_rd_add_i] <= 0;
               end
             
             if (rx_rd_req_i)
               begin
                  s_busy[rx_rd_add_i] <= 0;
               end
          end
     end
   
   // UPDATE OUTPUT PORTS
   generate
      
      for (i=0; i<NB_CORES; i++)
	begin
	   assign alloc_add_o[i] =  s_pointer;
	end
      
   endgenerate
   
   assign tx_rd_dat_o = s_buffer[tx_rd_add_i];
   assign rx_rd_dat_o = s_buffer[rx_rd_add_i];
   
   assign s_full      = &s_busy;
   assign s_alloc_gnt = ~s_full;
   
endmodule
