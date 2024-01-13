package environment_pkg;

	// importing packages
	import generator_pkg::*;
	import agent_pkg::*;
	import driver_pkg::*;
	import monitor_pkg::*
	import checker_pkg::*;
	import scoreboard_pkg::*;

	class Environment;

		// class objects
		Generator 	gen;
		Agent 		agt;
		Driver 		drv;
		Monitor 	mon;
		Scoreboard 	scb;
		Checker 	ckhr;

	// mailboxes
	mailbox #(Transaction) gen2agt, #(Transaction) chkr2scb, #(Transaction) agt2scb;
	mailbox #(Transaction) agt2drv, #(Transaction) agt2chkr, #(Transaction) mon2chkr;

	virtual function void build();

		// Unbounded Mailbox
		gen2agt  = new();
		chkr2scb = new();
		agt2scb  = new();
		mon2chkr = new();

		// Bounded Mailbox
		agt2drv  = new(1);
		agt2chkr = new(1);

		// Constructing TB components
		gen  = new(gen2agt);
		agt  = new(gen2agt, agt2drv, agt2chkr); // kindly check
		drv  = new(agt2drv);
		mon  = new(mon2chkr);
		chkr = new(agt2chkr, mon2chkr, chkr2scb);
		scb  = new(agt2scb, chkr2scb);

		// run task to control individual run tasks of classes
		virtual task run(int pktCount);
			fork
				gen.run(pktCount);
				agt.run(pktCount);
				drv.run();
				mon.run();
				scb.run();
				chkr.run();
			join_none
		endtask : run

		// clean up task 
		virtual task wrap_up();
			// Empty
		endtask : wrap_up


	endfunction : build
	endclass : Environment

endpackage : environment_pkg