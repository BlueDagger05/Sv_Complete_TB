package agent_pkg;

	// importing generator_pkg
	import generator_pkg::Generator;
	class agent;

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

		task run(int numOfPackets);
			// allocating memory to the object
			trnx = new();
			repeat(numOfPackets) 
			begin
				// Using get method of mailbox to get trnx object values
				gen2agt.get(trnx)

				// copying trnx object 
				trnx_c = trnx.copy();

				// Toggling case as per randomized states
				case(trnx.st)

					//IDLE state
					st.IDLE:
					begin
						// Do nothing
					end
	
					// Setup State
					st.SETUP:
					begin
						// input addr and data must be stable in setup phase
						agt2drv.put(trnx_c);
					end
	
					// Access State
					st.ACCESS:
					begin
						// Do nothing
					end

				endcase // current_state
			end
		endtask : run

	endclass : agent
endpackage : agent_pkg