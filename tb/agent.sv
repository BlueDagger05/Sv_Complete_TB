package agent_pkg;

	// importing generator_pkg
	import generator_pkg::*;
	import transaction_pkg::*;
	class Agent;

		// Transactionear class object -> agt_trnx
		Transaction agt_trnx;

		// Mailbox to send processed data to the driver
		// Parameterized with Transaction object with a bound of 1 
		mailbox #(Transaction) agt2drv;

		// Mailbox gen2agt to receive data from the Generator class
		mailbox #(Transaction) gen2agt;

		mailbox #(Transaction) agt2scb;

		// New constructor function to allocate memory to the mailbox
		function new(input mailbox #(Transaction) agt2drv, mailbox #(Transaction) gen2agt, mailbox #(Transaction) agt2scb);
			this.agt2drv = agt2drv;
			this.gen2agt = gen2agt;
			this.agt2scb = agt2scb;
		endfunction : new

		// run task which will process the raw data sent from the transaction class
		// Correct data will be sent to the Driver 
		extern virtual task run(int);


	endclass : Agent

//------------------------------
// Run Task
//------------------------------
task Agent::run(int numOfPackets);
	// allocating memory to the object
	Transaction trnx 	= new;
	Transaction trnx_c 	= new;
	repeat(numOfPackets) 
	begin
		// Using get method of mailbox to get trnx object values
		gen2agt.get(trnx);


		// copying trnx object 
		trnx_c.copy(trnx);
		
		// Transmitting write packet
		if(trnx_c.PWRITE)
		begin
			// updating ir_wr field
			trnx_c.is_wr = 1'b1;
			fork
				agt2drv.put(trnx_c);	
				agt2scb.put(trnx_c);	
			join
		end	

		// Transmitting read packet
		else
		begin
			// updating is_rd field
			trnx_c.is_rd = 1'b1;
			fork
				agt2drv.put(trnx_c);
				agt2scb.put(trnx_c);	
			join
		end
	end
endtask : run

endpackage : agent_pkg