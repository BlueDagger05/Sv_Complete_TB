//package test_pkg;
	// importing environment package
	import environment_pkg::*;

	// change the interface name if required
	program automatic Test(apb_slave_ifc ifc);
		Environment env;

		initial
		begin
			// creating environment 
			env = new();

			// calling environment tasks
			// building environment objects
			env.build();

			env.pktCount = 20;
			// running corresponding run tasks of classes

			// Clean up task after running 
			// env.wrap_up();

			// exiting simulation after 1000 time units
			#1000 $finish();
		end
	endprogram: Test
