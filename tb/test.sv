package test_pkg;
	// importing environment package
	import environment_pkg::Environment;

	// change the interface name if required
	program automatic Test(design_if.TEST ifc);
		Environment env;

		initial
		begin
			// creating environment 
			env = new();

			// calling environment tasks
			// building environment objects
			env.build();

			// running corresponding run tasks of classes
			env.run(20);

			// Clean up task after running 
			// env.wrap_up();

			// exiting simulation after 1000 time units
			#1000 $finish();
		end
	endprogram: Test
endpackage : test_pkg