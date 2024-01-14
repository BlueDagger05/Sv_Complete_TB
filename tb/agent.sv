package agent_pkg;

	// importing generator_pkg
	import generator_pkg::Generator;
	class Agent;

		// Transactionear class object -> agt_trnx
		Transaction agt_trnx;

		// Mailbox to send processed data to the driver
		// Parameterized with Transaction object with a bound of 1 
		mailbox #(Transaction) agt2drv;

		// Mailbox gen2agt to receive data from the Generator class
		mailbox #(Transaction) gen2agt;

		// New constructor function to allocate memory to the mailbox
		function new(input mailbox #(Transaction) agt2drv, mailbox #(Transaction) gen2agt);
			this.agt2drv = agt2drv;
			this.gen2agt = gen2agt;
		endfunction : new

		// run task which will process the raw data sent from the transaction class
		// Correct data will be sent to the Driver 
		extern virtual task run();

	endclass : Agent

//------------------------------
// Run Task
//------------------------------
task Agent::run(int numOfPackets);
	// allocating memory to the object
	trnx = new();
	repeat(numOfPackets) 
	begin
		// Using get method of mailbox to get trnx object values
		gen2agt.get(trnx)

		// copying trnx object 
		trnx_c = trnx.copy();
		
		// Transmitting write packet
		if(trnx_c.PWRITE)
		begin
			// updating ir_wr field
			trnx_c.is_wr = 1'b1;
			agt2drv.put(trnx_c);		
		end	

		// Transmitting read packet
		else
		begin
			// updating is_rd field
			trnx_c.is_rd = 1'b1;
			agt2drv.put(trnx_c);
		end
	end
endtask : run

endpackage : agent_pkg