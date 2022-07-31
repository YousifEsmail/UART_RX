module data_sampler (
    input wire RX_in,
    
    input wire CLK,
    input wire RST,
   
    input wire dat_samp_en,
    input wire [3:0] edge_cnt,
    input wire [3:0] prescale,
    output reg sampled_bit
        
);
    


reg [2:0] internal_sampled_bit;

always @(posedge CLK or negedge RST ) 
begin
    if (!RST) 
        begin
            internal_sampled_bit<=3'b000; 
        end
    else
     begin
        
                case (edge_cnt)
                    4'b0100:
                    begin
                    internal_sampled_bit[0]<=RX_in;
                    internal_sampled_bit[1]<=internal_sampled_bit[1];
                    internal_sampled_bit[2]<=internal_sampled_bit[2];
                    end
                    4'b0101:
                    begin
                    internal_sampled_bit[0]<=internal_sampled_bit[0];
                    internal_sampled_bit[1]<=RX_in;
                    internal_sampled_bit[2]<=internal_sampled_bit[2];
                    end

                    4'b0110:
                    begin
                    internal_sampled_bit[0]<=internal_sampled_bit[0];
                    internal_sampled_bit[1]<=internal_sampled_bit[1];
                    internal_sampled_bit[2]<=RX_in;
                    end
                    
                     
                    default: 
                    begin
                    internal_sampled_bit[0]<=internal_sampled_bit[0];
                    internal_sampled_bit[1]<=internal_sampled_bit[1];                    
                    internal_sampled_bit[2]<=internal_sampled_bit[2];
                    end
                endcase
            end
end
   
   

always @(*) 
begin
if (dat_samp_en) 
                begin
                    
                        begin
                            if(edge_cnt==4'b0111)
                                begin
                                case (internal_sampled_bit)
                                    3'b000:sampled_bit=0;
                                    3'b001:sampled_bit=0;
                                    3'b010:sampled_bit=0;
                                    3'b011:sampled_bit=1;
                                    3'b100:sampled_bit=0;
                                    3'b101:sampled_bit=1;
                                    3'b110:sampled_bit=1;
                                    3'b111:sampled_bit=1;

                                    default: sampled_bit=sampled_bit;
                                endcase
                                end

                            else
                                begin
                                sampled_bit=sampled_bit;
                                end

                            end
                end 
            else
                begin
                    sampled_bit=sampled_bit;
                end    
end


endmodule
