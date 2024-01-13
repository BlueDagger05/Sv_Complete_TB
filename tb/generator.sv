package generator_pkg;
	import transaction_pkg::Transaction;

	class Generator;

		// Transaction class object -> trnx
		Transaction trnx;

		// mailbox mbx to send raw transactions to agent  
		mailbox #(Transaction) gen2agt;

		// int variable for counting packet
		int pktCount = 0;

		// new constructor parameterized with mailbox
		// parameterized mailbox as input to the class Generator
		function new(input mailbox #(Transaction) gen2agt);
			this.gen2agt = gen2agt;
		endfunction : new

		// Display functions
		extern function void gen_display();

		// run task which will generate pin level activity for DUT
		task run(int numOfPackets);

			// using repeat loop for generating n number of packets 
			repeat(numOfPackets) 
			begin

				// allocating memory to the object
				trnx = new();

				// If checks if randomization passes else displays error on to the console
				assert(trnx.randomize());

				// Calling extern gen_display function
				gen_display(pktCount);

				// Using put method of mailbox for processing to the agent
				gen2agt.put(trnx);

				// incrementing count of pkt ID
				pktCount++;
				
			end
		endtask : run
	endclass:Generator


// extern defined function definition
function void Generator::gen_display(int pktCount);
	$display("PKT_ID [%0d] :: PADDR = 0x%0h, PWDATA = 0x%0h", $time, pktCount, trnx.PADDR, trnx.PWDATA);
	$display("==============================================\n");
endfunction

endpackage : generator_pkg