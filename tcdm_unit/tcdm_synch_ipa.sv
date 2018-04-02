////////////////////////////////////////////////////////////////////////////////
// Company:        Multitherman Laboratory @ DEIS - University of Bologna     //
//                    Viale Risorgimento 2 40136                              //
//                    Bologna - fax 0512093785 -                              //
//                                                                            //
// Engineer:       Davide Rossi - davide.rossi@unibo.it                       //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    11/04/2013                                                 // 
// Design Name:    ULPSoC                                                     // 
// Module Name:    minichan                                                   //
// Project Name:   ULPSoC                                                     //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    MINI DMA CHANNEL                                           //
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

module tcdm_synch_ipa
#(
      parameter TRANS_SID_WIDTH = 2
)
(

      input  logic                            clk_i,
      input  logic                            rst_ni,

      input  logic [1:0]                      synch_req_i,
      input  logic [1:0][TRANS_SID_WIDTH-1:0] synch_sid_i,

      output logic                            synch_req_o,
      output logic [TRANS_SID_WIDTH-1:0]      synch_sid_o

);
   
   logic [1:0]                               s_synch_req;
   logic                                     s_synch_gnt;
   logic [1:0][TRANS_SID_WIDTH-1:0]          s_synch_sid;
   
   genvar         i;
   
   generate
      for (i=0; i<2; i++)
      begin : synch
            mchan_fifo_ipa
            #(
               .DATA_WIDTH(TRANS_SID_WIDTH),
               .DATA_DEPTH(2) // IMPORTANT: DATA DEPTH MUST BE THE SAME AS CMD QUEUE DATA DEPTH
            )
            synch_ipa_i
            (

               .clk_i       ( clk_i           ),
               .rst_ni      ( rst_ni          ),

               .push_dat_i  ( synch_sid_i[i]  ),
               .push_req_i  ( synch_req_i[i]  ),
               .push_gnt_o  (                 ),

               .pop_dat_o   ( s_synch_sid[i]  ),
               .pop_req_i   ( s_synch_gnt     ),
               .pop_gnt_o   ( s_synch_req[i]  )

            );
      end
   endgenerate
   
   assign s_synch_gnt = s_synch_req[0] & s_synch_req[1];
   
   assign synch_req_o = s_synch_gnt;
   assign synch_sid_o = s_synch_sid[0];
   
endmodule
