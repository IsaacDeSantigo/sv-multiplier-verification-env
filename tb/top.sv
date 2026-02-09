/* Transaction Class */
class transaction;
  
  rand bit [3:0] a;
  rand bit [3:0] b; 
       bit [7:0] res;
  
  function transaction copy(); 
    copy = new(); 
    copy.a = this.a; 
    copy.b = this.b;
    copy.res = this.res;
  endfunction
  
  function void display();
    
    $display("a = %0d, b = %0d, res = %0d",this.a,this.b,this.res);
    
  endfunction 
  
  constraint edgeCasesA{ a dist { 0 := 20, [1:14] :/ 60 ,15 := 20  };}
  
  constraint edgeCasesB{ a == 0  -> b == 0; 
                         a == 15 -> b == 15;
                       }
  
  
endclass

/* Generator Class */

class generator; 
  
  mailbox #(transaction) mbx; 
  transaction data; 
  
  event done; 
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    data = new();
  endfunction 
  
  task run();
    for(int i = 0; i < 10; i++ ) begin 
      assert( data.randomize() ) else $warning("Randomization has failed");
      mbx.put(data.copy());
      $display("[GEN] : time = %0t | DATA SENT TO DRIVER",$time);
      data.display();
      #40; 
    end 
    ->done; 
  endtask 
  
endclass

/* End Generator Class */

/* Interface Mul */

interface mul_if(); 
  
  logic       clk; 
  logic [3:0] a; 
  logic [3:0] b;
  logic [7:0] res; 
  
 // modport dir( output a, b, input res, clk); 
  
endinterface

/* End Interface Mul */

/* Driver Class */

class driver; 
  
  virtual mul_if mif; 
  mailbox #(transaction) mbx; 
  transaction data; 
  
  function new(mailbox #(transaction) mbx); 
    this.mbx = mbx; 
  endfunction 
  
  task run(); 
    
    forever begin 
      mbx.get(data); 
      @(posedge mif.clk); 
      mif.a <= data.a; 
      mif.b <= data.b;
      
      $display("[DRV] : time = %0t | DATA APPLIED TO DUT",$time);
      data.display();
      @(posedge mif.clk);      
    end 
    
  endtask
  
endclass


/* End Driver Class */ 

/* Monitor Class */

class monitor; 
  
  virtual mul_if mif; 
  mailbox #(transaction) mbx; 
  transaction data; 
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx; 
    data = new(); 
  endfunction 
  
  task run();
    forever begin 
      repeat(2) @(posedge mif.clk); 
      #5;
      data.a = mif.a; 
      data.b = mif.b; 
      data.res = mif.res; 
      mbx.put(data);
      $display("[MON] : Time = %0t | DATA SENT TO SCOREBOARD",$time);
      data.display();
    end
  endtask 
  
endclass

/* End Monitor Class */

/* Scoreboard Class */

class scoreboard; 
  
  mailbox #(transaction) mbx; 
  transaction trans; 
  
  function new(mailbox #(transaction) mbx); 
    this.mbx = mbx; 
  endfunction
  
  task validate(input transaction data); 
    
    if( (data.res) == (data.a * data.b) ) begin 
      
      $display("TEST PAST!");
      
    end else begin 
     
      $error("TEST FAILED");
      
    end
    
  endtask
  
  task run(); 
    
    forever begin  
      mbx.get(trans); 
      $display("[SCO] : Time = %0t | DATA RCVD FROM MONITOR",$time);
      trans.display();
      validate(trans); 
      $display("-------------------------------------------------");
    end 
    
  endtask 
  
  
endclass

/* End Scoreboard Class */


/* TOP MODULE */

module tb(); 
  
  
  mailbox #(transaction) mbx; 
  generator gen; 
  driver drv; 
  monitor mon; 
  scoreboard sco; 
  
  mul_if mif(); 
  
  mul dut(
    .clk(mif.clk), 
    .a(mif.a),
    .b(mif.b), 
    .res(mif.res)
  );
  
  initial begin 
    mif.clk <= 0; 
  end 
  
  always #10 mif.clk <= ~mif.clk; 
  
  event done; 
  
  initial begin 
    
    mbx = new(); 
    gen = new(mbx);
    drv = new(mbx); 
    mon = new(mbx); 
    sco = new(mbx); 
    
    drv.mif = mif; 
    mon.mif = mif; 
    
    gen.done = done; 
    
  end 
  
  initial begin 
    
    fork 
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_none 
    wait(done.triggered); 
    #20; 
    $finish; 
 
  end 
  
  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars; 
  end 
  
  
endmodule 

/* END TOP MODULE */
