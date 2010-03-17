=script0
	push	1
	
	
	push	1	//true,1
	not			//dd

	push	1//


	push	1
	
	      
	      //
	
	push	1	//
	
	
	
	push	1
	
	
	time
	push	"start"
	sts
	
	push	7	//7
	push	1	//7,1
	add			//8
	push	1	//8,1
	sub			//7
	push	2	//7,2
	mul			//14
	push	2	//14,2
	div			//7
	inc			//8
	dec			//7
	push	2	//7,2
	mod			//7,1
	push	1	//7,1
	//stacktrace
	push	1	//7,1,1
	//stacktrace
	and			//7,true
	or			//true
	push	1	//true,1
	not			//dd

	push	1
	push	1
	band
	
=script1
	push	#one
	push	1
	push	2
	add
	trace
	push	#two
	push	"reg1"
	sts
one:
	push	"dada!"
	trace
	isopen
two:

