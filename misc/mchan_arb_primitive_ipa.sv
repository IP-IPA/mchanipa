////////////////////////////////////////////////////////////////////////////////
// Company:        Multitherman Laboratory @ DEIS - University of Bologna     //
//                    Viale Risorgimento 2 40136                              //
//                    Bologna - fax 0512093785 -                              //
//                                                                            //
// Engineer:       Davide Rossi - davide.rossi@unibo.it                       //
//                                                                            //
// Additional contributions by:                                               //
//                  Igor Loi - igor.loi@unibo.it                              //
//                                                                            //
//                                                                            //
// Create Date:    01/06/2015                                                 //
// Design Name:    ULPSoC                                                     //
// Module Name:    mchan_arb_primitive                                        //
// Project Name:   ULPSoC                                                     //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    MINI DMA CHANNEL                                           //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - File Created                                               //
// Revision v0.2 - the CORE id is propagated in the mchan arbiter and now     //
//                 is parametric (25/08/2015)                                 //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module mchan_arb_primitive_ipa
#(
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
)
(
    input  logic                   RR_FLAG,

    

    // LEFT SIDE
    input  logic                   req0_i,
    input  logic                   req1_i,      
    output logic                   gnt0_o,
    output logic                   gnt1_o,
    input  logic [DATA_WIDTH-1:0]  data0_i,
    input  logic [DATA_WIDTH-1:0]  data1_i,
    input  logic [ID_WIDTH-1:0]    id0_i,
    input  logic [ID_WIDTH-1:0]    id1_i,



    // RIGTH SIDE
    output logic                   req_o,
    input  logic                   gnt_i,
    output logic [DATA_WIDTH-1:0]  data_o,
    output logic [ID_WIDTH-1:0]    id_o

);
   logic                   sel;

   assign req_o  = req0_i | req1_i;
   assign sel    = ~req0_i | ( RR_FLAG & req1_i); // SEL FOR ROUND ROBIN MUX
   assign gnt0_o = (( req0_i & ~req1_i) | ( req0_i & ~RR_FLAG)) & gnt_i;
   assign gnt1_o = ((~req0_i &  req1_i) | ( req1_i &  RR_FLAG)) & gnt_i;
   
   assign data_o = sel   ? data1_i : data0_i;
   assign id_o   = sel   ? id1_i   : id0_i;
   
endmodule
