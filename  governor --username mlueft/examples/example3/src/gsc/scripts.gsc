=script1
	push	"hello "	// pushed "hello " on the stack.
	push	"world"		// pushes "world" on the stack.
	push	"!"			// pushes "!" on the stack.
	add					// concatenates "world" and "!" to "world!".
	add					// concatenates "hello " and "world!" to "hello world!".
	trace				// traces "hello world!"".