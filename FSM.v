module FSM (
    input wire RX_in,
    input wire PAR_en,
    input wire clk,
    input wire rst,
    input wire Par_err,
    input wire STR_err,
    input wire STP_err,
    input wire [3:0] bit_cnt,
    input wire [3:0] edge_cnt,
    output reg par_chk_en,
    output reg enable,
    output reg dat_samp_en,
    output reg str_chk_en,
    output reg stp_chk_en,
    output reg data_valid,
    output reg deser_en,
    output reg PAR_CHK_New_bit,
    output reg reset_bit_cnt,
    output reg deser_New_bit

);

// state decleration 
localparam  [2:0]Idle =3'b000 ,
                Start =3'b001 ,
                data =3'b010 ,
                Parity =3'b011 ,
                Stop =3'b100 ,
                OP_chk= 3'b101,
                OP_P=3'b110;



reg    [2:0]         curent_state,
                     next_state ;


always @(posedge clk or negedge rst) 
begin
    if(!rst)
    begin  
    curent_state<=Idle;
    end
    else
    curent_state<=next_state;

end



always @(*)
begin
case (curent_state)
    Idle:
    begin
        if(RX_in)
            begin
                reset_bit_cnt=1'b1;
                par_chk_en=1'b0;
                str_chk_en=1'b0;
                stp_chk_en=1'b0;
                data_valid=1'b0;
                deser_en=1'b0;
                PAR_CHK_New_bit=1'b0;
                deser_New_bit=1'b0;
                
                
                next_state=Idle;

            end
        else
            begin
            reset_bit_cnt=1'b1;

            data_valid=1'b0;
            next_state=Start;  
            end
    end

    Start:
    begin
        enable=1'b1;
        deser_en=1'b0;
        reset_bit_cnt=1'b0;

        if (edge_cnt!=4'b0111) 
            begin
                next_state=Start;   
            end
        else 
            begin
                dat_samp_en=1'b1;
                str_chk_en=1'b1;    
                next_state=data;
            end    
    end
    
    data:
        begin
            reset_bit_cnt=1'b0;
            dat_samp_en=1'b0;
            str_chk_en=1'b0;
            if(STR_err)
            begin
                next_state=Idle;

            end    
else
begin
    

            if (bit_cnt!=4'b1001) begin
              begin
                    if (edge_cnt!=4'b111) 
                        begin
                            deser_New_bit=1'b0;
                           PAR_CHK_New_bit=1'b0;

                            next_state=data;   
                        end
                    else 
                        begin
                            deser_New_bit=1'b1;
                            PAR_CHK_New_bit=1'b1;
                            dat_samp_en=1'b1;
                            next_state=data;
                        end    
                end  
            end
            else
                begin
                    deser_New_bit=1'b0;
                    PAR_CHK_New_bit=1'b0;            
                    if (PAR_en) 
                        begin
                        par_chk_en=1'b0;    
                        next_state=Parity;
                        end
                    else next_state=Stop;

                
                end     
        end
    
end

    Parity:
        begin
            deser_New_bit=1'b0;
            PAR_CHK_New_bit=1'b0;
            enable=1'b1;
            if (bit_cnt!=4'b1010) 
                begin
                    if (edge_cnt!=4'b0111) begin
                    next_state=Parity;
                    end
                    else
                        begin
                            dat_samp_en=1'b1;
                            next_state=Parity;
                        end
                    
   
                end
            else 
                begin
                    par_chk_en=1'b1;    
                    next_state=Stop;
                end    
        end
    Stop:
            begin
                enable=1'b1;
                deser_New_bit=1'b0;
                dat_samp_en=1'b0;


                if (edge_cnt!=4'b0111) 
                    begin

                        next_state=Stop;   
                    end
                else 
                    begin
                        dat_samp_en=1'b1;
                        par_chk_en=1'b0;    
                        stp_chk_en=1'b1;
                       next_state=OP_chk;   

                            
                    end    
            end
            


    OP_chk:
        begin
                 dat_samp_en=1'b0;
                if (Par_err==0&&STR_err==0&&STP_err==0) 
                    begin
                        next_state=OP_P;
                        deser_en=1'b1;
                        data_valid=1'b1;
                        next_state=Idle;

                    end 
                else
                    begin
                        deser_en=1'b0;
                        data_valid=1'b0;                
                        next_state=Idle;
                    end   
                

        end  

        
          

    





endcase    
end





    
endmodule
