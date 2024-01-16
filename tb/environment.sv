package environment_pkg;

	// importing packages
	import transaction_pkg::*;
	import generator_pkg::*;
	import agent_pkg::*;
	import driver_pkg::*;
	import monitor_pkg::*;
	import checker_pkg::*;
	import scoreboard_pkg::*;

	class Environment;

		// class objects
		Generator 	gen;
		Agent 		agt;
		Driver 		drv;
		Monitor 	mon;
		Scoreboard 	scb;
		Checker 	chkr;

	// mailboxes
	mailbox #(Transaction) gen2agt;
	mailbox #(Transaction) chkr2scb;
	mailbox #(Transaction) agt2scb;
	mailbox #(Transaction) agt2drv;
	mailbox #(Transaction) agt2chkr;
	mailbox #(Transaction) mon2chkr;

    // interface 
    virtual apb_slave_ifc vif;
    
    int pktCount;
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
		agt  = new(agt2drv, gen2agt,agt2scb); // kindly check
		drv  = new(agt2drv, vif);
		mon  = new(mon2chkr, vif);
		chkr = new(mon2chkr, chkr2scb);
		scb  = new(agt2scb, chkr2scb);

	endfunction: build

	// run task to control individual run tasks of classes
	 task run(pktCount);
		fork
			gen.run(pktCount);
			agt.run(pktCount);
			drv.main_run();
			mon.run();
			scb.run();
			chkr.run(pktCount);
		join_none
	endtask : run

	task post_run();
		wait(drv.count == 20);
	endtask : post_run

	task main();
		run(pktCount);
		// post_run();
		//$finish;
	endtask: main
	// clean up task 
	virtual task wrap_up();
		// Empty
	endtask : wrap_up

endclass : Environment

endpackage : environment_pkg