package {
	
	import flash.display.Sprite; 
    import flash.events.InvokeEvent; 
    import flash.desktop.NativeApplication; 
    import flash.text.TextField;
	import flash.display.Sprite;
	import flash.filesystem.*;
	import at.lueftenegger.governor.OpCodes;
	

	/**
	 * ...
	 * @author Michael Lueftenegger
	 * 
	 * This is a quick and dirty command line compiler for governor script engine.
	 * 
	 * parameters:
	 * 
	 * -if inout file
	 * -of output file
	 * -an array name 				!obsolet! Use -on.
	 * -cn class name 				!obsolet! Use -on.
	 * -v  version [AS2/AS3]
	 * -on object name. 			replaces -an and -cn . for AS2 on is taken for array name, in AS3 on is taken for cn.
	 * -ns name space.				namespace for AS3 class.
	 * -ct cutom tokens.			config file for custom tokens.
	 * 
	 * 
	 */
	public class Main extends Sprite{
		
		private static const _AS2:String = "as2";
		private static const _AS3:String = "as3";
		
		private var sourceFile:String;
		private var destFile:String;
		private var ctFile:String;
		private var on:String = "script";
		private var ns:String = "";
		private var scriptVersion:String = _AS3;
		
		public var params:Array = [];
		public var log:TextField; 
		
		public var _customToken:Array;
		
		private const VERSION:String 	= "0.1";
		private const DATE:String 		= "2010.03.01";
		private const COPYRIGHT:String	= "2006 - 2010, M. Lueftenegger, http://www.lueftenegger.at";
		
		public function showHelp():void {
			logEvent( " This is a quick'n dirty command line compiler for governor script engine." );
			logEvent( " version: "+ VERSION);
			logEvent( " date: "+ DATE );
			logEvent( " copyright: "+ COPYRIGHT );
			logEvent( "" );
			logEvent( " parameters:" );
			logEvent( "" );
			logEvent( " -if input file" );
			logEvent( " -of output file" );
			logEvent( " -an array name        !obsolet! Use -on." );
			logEvent( " -cn class name        !obsolet! Use -on." );
			logEvent( " -v  version           [AS2/AS3]" );
			logEvent( " -on object name.      replaces -an and -cn . for AS2 on is taken for array name, in AS3 on is taken for cn." );
			logEvent( " -ns name space.       namespace for AS3 class." );
			logEvent( " -ct cutom tokens.	  config file for custom tokens." );
			logEvent( "" );
			logEvent( "Example AS2:" );
			logEvent( "governorc.exe -if c:\\temp\\scripts.asm -of c:\\temp\\scripts.as -on scripts -v AS2" );
			logEvent( "" );
			logEvent( "Example AS3:" );
			logEvent( "governorc.exe -if c:\\temp\\scripts.asm -of c:\\temp\\game\\classes\\scripts.as -on scripts -v AS3 -ns game.classes" );
			logEvent( "" );
			logEvent( "" );
		}
		
		public function parseArgs():Boolean {
			
			var help:Boolean = false;
			var ifDefined:Boolean = false;
			var ofDefined:Boolean = false;
			var anCnOnDefined:Boolean = false;
			
			for ( var j:int = 0; j < params.length; j++) {
				logEvent( params[j].toString() );
			}
			
			for ( var i:int = 0; i < params.length; i++) {
				switch(params[i]) {
					case "-?":
					case "-h":
					case "-help":
						help = true;
						break;
					case "-if":
							sourceFile = params[i + 1];
							ifDefined = true;
						break;
					case "-of":
						destFile = params[i + 1];
						ofDefined = true;
						break;
					case "-v":
						if(	params[i + 1] == "AS2")
							scriptVersion = _AS2;
						else
							scriptVersion = _AS3;
						break;
					case "-ns":
						ns = params[i + 1];
						break;
					case "-ct":
						ctFile = params[i + 1];
						break;
					case "-an":
					case "-cn":
					case "-on":
						on = params[i + 1];
						anCnOnDefined = true;
						break;
				}
			}
			
			if ( 
				params.length == 0
				||
				!ifDefined
				||
				!ofDefined
				||
				!anCnOnDefined
				||
				help
			){
				showHelp();
				return false;
			}
			return true;
			
			// sourceFile has to be a file.
			
			// destFile hast to be a file.
			
		}
		
		public function removeComments(inputFile:String, outputFile:String):void {
			/*
			 * comments are:
			 * // ... \n
			 * /* ... */
			/**/
			 
			var iFile:File = File.documentsDirectory.resolvePath(inputFile);
			var oFile:File = File.documentsDirectory.resolvePath(outputFile);
			
			var inputStream:FileStream = new FileStream();
			inputStream.open(iFile, FileMode.READ);
			
			var outputStream:FileStream = new FileStream();
			outputStream.open(oFile, FileMode.WRITE);
			
			
			var lastChar:String;
			var curChar:String;
			var peakChar:String;
			
			var slc:Boolean = false;	// single lineComment
			var mlc:Boolean = false;	// multi  line comment
			var str:Boolean = false;
			
			curChar = inputStream.readMultiByte(1, File.systemCharset);
			peakChar = curChar;
			
			while( inputStream.bytesAvailable > 1){
				peakChar = inputStream.readMultiByte(1, File.systemCharset);
				
				if ( peakChar == "\"" )	str = !str;
				if ( peakChar == "\n" && !str)	slc = false;
				if ( !slc && !mlc && !str) {
					if ( curChar == "/" && peakChar == "*" )		mlc = true;
					if ( curChar == "/" && peakChar == "/" )		slc = true;
				}
				if ( !slc && ! mlc)									outputStream.writeMultiByte(curChar, "utf-8");
				if( !str && (peakChar == " " || peakChar == "\t") )	outputStream.writeMultiByte("\n", "utf-8");
				if ( lastChar == "*" && curChar == "/" && !slc && !str)		mlc = false;
				lastChar = curChar;
				curChar = peakChar;
			}
			if ( !slc && ! mlc) {
				peakChar = inputStream.readMultiByte(1, File.systemCharset);
				outputStream.writeMultiByte(curChar, "utf-8");
				outputStream.writeMultiByte(peakChar, "utf-8");
			}
			
			inputStream.close();
			outputStream.close();
		}
		
		public function removeEmptyLines(inputFile:String, outputFile:String):void {
			 
			var iFile:File = File.documentsDirectory.resolvePath(inputFile);
			var oFile:File = File.documentsDirectory.resolvePath(outputFile);
			
			var inputStream:FileStream = new FileStream();
			inputStream.open(iFile, FileMode.READ);
			
			var outputStream:FileStream = new FileStream();
			outputStream.open(oFile, FileMode.WRITE);
			
			var strHelper:StringHelper = new StringHelper();

	
			var curChar:String;
			var line:String = "";
		
			while( inputStream.bytesAvailable > 0){
				
				curChar = "";// inputStream.readMultiByte(1, File.systemCharset);
				line = "";// curChar;
					
				while( inputStream.bytesAvailable > 0 && curChar != "\n"){
					curChar = inputStream.readMultiByte(1, File.systemCharset);
					
					if( curChar.charCodeAt(0) != 10 && curChar.charCodeAt(0) != 13)
						line += curChar;
				}
				
				line = strHelper.myTrim(line);
				
				if( line.length >0)	outputStream.writeMultiByte(line+"\n", "utf-8");

				line = "";
			}
			
			inputStream.close();
			outputStream.close();
		}		
		
		public function resolveTokens(inputFile:String, outputFile:String):void {
			 
			/*
			 * comments are:
			/**/
			 
			var iFile:File = File.documentsDirectory.resolvePath(inputFile);
			var oFile:File = File.documentsDirectory.resolvePath(outputFile);
			
			var inputStream:FileStream = new FileStream();
			inputStream.open(iFile, FileMode.READ);
			
			var outputStream:FileStream = new FileStream();
			outputStream.open(oFile, FileMode.WRITE);
			
			var curChar:String;
			var line:String;
			
			while ( inputStream.bytesAvailable > 0) {
				
				line  = "";
				curChar = "";
				while ( curChar != "\n" && inputStream.bytesAvailable > 0 ) {
					
					curChar = inputStream.readMultiByte(1, File.systemCharset);
					
					if( curChar.charCodeAt(0) != 10 && curChar.charCodeAt(0) != 13)
						line += curChar;
					
				}
				
				if ( Number(line).toString() != line) {
					if(line.substr(0,1) != "\"" && line.substr(0,1) != "="){
						// token to resolve
						outputStream.writeMultiByte( resolveToken(line), "utf-8");
					}else
						outputStream.writeMultiByte( line, "utf-8");
				}else {
					// number
					outputStream.writeMultiByte(line, "utf-8");
				}
				outputStream.writeMultiByte("\n", "utf-8");

			}
			
			inputStream.close();
			outputStream.close();
		}
		
		public function resolveToken(token:String):String{
			switch(token.toLowerCase()) {
				
				// stack operators
				case "push" : return OpCodes.PUSH.toString();
				case "pop" : return OpCodes.POP.toString();
				
				// memory management
				case "sts" : return OpCodes.STS.toString();
				case "lds" : return OpCodes.LDS.toString();
				case "stsg" : return OpCodes.STSG.toString();
				case "ldsg" : return OpCodes.LDSG.toString();
				
				// numeric operators
				case "add" : return OpCodes.ADD.toString();
				case "sub" : return OpCodes.SUB.toString();
				case "mul" : return OpCodes.MUL.toString();
				case "div" : return OpCodes.DIV.toString();
				case "inc" : return OpCodes.INC.toString();
				case "dec" : return OpCodes.DEC.toString();
				case "mod" : return OpCodes.MOD.toString();
				
				// boolean operators
				case "and" : return OpCodes.AND.toString();
				case "or" : return OpCodes.OR.toString();
				case "not" : return OpCodes.NOT.toString();
				case "band" : return OpCodes.BAND.toString();
				case "bor" : return OpCodes.BOR.toString();
				case "bxor" : return OpCodes.BXOR.toString();
				case "bnot" : return OpCodes.BNOT.toString();
				
				// binary operators
				case "rol" : return OpCodes.ROL.toString();
				case "ror0" : return OpCodes.ROR0.toString();
				case "ror1" : return OpCodes.ROR1.toString();
				
				// comparative operators
				case "eq" : return OpCodes.EQ.toString();
				case "seq" : return OpCodes.SEQ.toString();
				case "uq" : return OpCodes.UQ.toString();
				case "suq" : return OpCodes.SUQ.toString();
				case "les" : return OpCodes.LES.toString();
				case "mor" : return OpCodes.MOR.toString();
				case "leq" : return OpCodes.LEQ.toString();
				case "moq" : return OpCodes.MOQ.toString();
				
				// math function
				case "abs" : return OpCodes.ABS.toString();
				case "acos" : return OpCodes.ACOS.toString();
				case "asin" : return OpCodes.ASIN.toString();
				case "atan" : return OpCodes.ATAN.toString();
				case "atan2" : return OpCodes.ATAN2.toString();
				case "ceil" : return OpCodes.CEIL.toString();
				case "cos" : return OpCodes.COS.toString();
				case "exp" : return OpCodes.EXP.toString();
				case "floor" : return OpCodes.FLOOR.toString();
				case "log" : return OpCodes.LOG.toString();
				case "max" : return OpCodes.MAX.toString();
				case "min" : return OpCodes.MIN.toString();
				case "pow" : return OpCodes.POW.toString();
				case "random" : return OpCodes.RANDOM.toString();
				case "round" : return OpCodes.ROUND.toString();
				case "sin" : return OpCodes.SIN.toString();
				case "sqrt" : return OpCodes.SQRT.toString();
				case "tan" : return OpCodes.TAN.toString();
				
				// math const
				case "e" : return OpCodes.E.toString();
				case "ln10" : return OpCodes.LN10.toString();
				case "ln2" : return OpCodes.LN2.toString();
				case "log10e" : return OpCodes.LOG10E.toString();
				case "log2e" : return OpCodes.LOG2E.toString();
				case "pi" : return OpCodes.PI.toString();
				case "sqrt1_2" : return OpCodes.SQRT1_2.toString();
				case "sqrt2" : return OpCodes.SQRT2.toString();
				
				// misc functions
				case "trace" : return OpCodes.TRACE.toString();
				case "non" : return OpCodes.NON.toString();
				
				// multithreading functions
				case "fork" : return OpCodes.FORK.toString();
				case "threadlock" : return OpCodes.THREADLOCK.toString();
				case "threadunlock" : return OpCodes.THREADUNLOCK.toString();
				case "ipt" : return OpCodes.IPT.toString();
				
				// program flow
				case "jmp" : return OpCodes.JMP.toString();
				case "gto" : return OpCodes.GTO.toString();
				
				case "time" : return OpCodes.TIME.toString();
				
			}
			
			return resolveCustomToken(token);			
		}
		
		public function resolveCustomToken(token:String):String {
			for ( var i:String in _customToken) {
				if (i.toLowerCase() == token) {
					return _customToken[i].toString();
				}
			}
			return token;
		}
		
		public function resolveMarks(inputFile:String, outputFile:String):void {
			
			var iFile:File = File.documentsDirectory.resolvePath(inputFile);
			var oFile:File = File.documentsDirectory.resolvePath(outputFile);
			
			var inputStream:FileStream = new FileStream();
			inputStream.open(iFile, FileMode.READ);
			
			var outputStream:FileStream = new FileStream();
			outputStream.open(oFile, FileMode.WRITE);
			
			var line:String = "";
			var curChar:String = "";
			
			var marks:Array = new Array();
			var position:int = 0;
			
			var scriptname:String;
			
			// recording marks
			do{
				position = 0;
				do{
					line  = "";
					curChar = "";
					while ( curChar != "\n" && inputStream.bytesAvailable > 0 ) {
						curChar = inputStream.readMultiByte(1, File.systemCharset);
						
						if( curChar.charCodeAt(0) != 10 && curChar.charCodeAt(0) != 13)
							line += curChar;

					}
				
					// script name
					if ( line.substr(0, 1) == "=") {
						scriptname = line.substr(1, line.length -1);
						//trace(":"+scriptname+":");
						marks[scriptname] = new Array();
					}
					
					// mark name
					if ( line.substr(line.length-1, 1) == ":") {
						position--;
						marks[scriptname][line.substr( 0, line.length - 1)] = position;
						//trace(scriptname, line.substr( 0, line.length - 3) ,marks[scriptname][line.substr( 0, line.length - 3)]);
					}
					position++;
					
				}while( line.substr(0, 1) != "=" && inputStream.bytesAvailable > 0);
				
			}while( inputStream.bytesAvailable > 0);
			
			inputStream.position = 0;
			
			/**/
			// resolving marks

			// recording marks
			scriptname = "";
			while( inputStream.bytesAvailable > 0 ){

				line  = "";
				curChar = "";
				do{
					curChar = inputStream.readMultiByte(1, File.systemCharset);
					if( curChar.charCodeAt(0) != 10 && curChar.charCodeAt(0) != 13)
						line += curChar;
				}while ( curChar != "\n" && inputStream.bytesAvailable > 0);
				
				// script name
				if ( line.substr(0, 1) == "=") {
					scriptname = line.substr(1, line.length-1);
				}
					
				// mark name
				if ( line.substr(line.length - 1, 1) != ":") {
					
					if ( line.substr(0, 1) == "#" ) {
						//trace(scriptname,line.substr(1,line.length-2), marks[scriptname][line.substr(1,line.length-3)]+"\n");
						outputStream.writeMultiByte(marks[scriptname][line.substr(1,line.length-1)]+"\n", "utf-8");
					}else{
						outputStream.writeMultiByte(line+"\n", "utf-8");
					}
				}
				position++;
					
			}
			
			
			inputStream.close();
			outputStream.close();
			/**/
		}
		
		public function parseString(inputFile:String, outputFile:String):void {
			/*
			 * comments are:
			 * // ... \n
			 * /* ... */
			/**/
			 
			var iFile:File = File.documentsDirectory.resolvePath(inputFile);
			var oFile:File = File.documentsDirectory.resolvePath(outputFile);
			
			var inputStream:FileStream = new FileStream();
			inputStream.open(iFile, FileMode.READ);
			
			var outputStream:FileStream = new FileStream();
			outputStream.open(oFile, FileMode.WRITE);
			
			var curChar:String;
			var line:String;
			
			while ( inputStream.bytesAvailable > 0) {
				
				line  = "";
				curChar = "";
				while ( curChar != "\n" && inputStream.bytesAvailable > 0 ) {
					
					curChar = inputStream.readMultiByte(1, File.systemCharset);
					
					if( curChar.charCodeAt(0) != 10 && curChar.charCodeAt(0) != 13)
						line += curChar;
					
				}
				
				if ( Number(line).toString() != line) {
					if(line.substr(0,1) != "\"" && line.substr(0,1) != "=")
						outputStream.writeMultiByte("\"", "utf-8");
					outputStream.writeMultiByte(line, "utf-8");
					if(line.substr(0,1) != "\"" && line.substr(0,1) != "=")
						outputStream.writeMultiByte("\"", "utf-8");
				}else {
					outputStream.writeMultiByte(line, "utf-8");
				}
				outputStream.writeMultiByte("\n", "utf-8");

			}
			
			inputStream.close();
			outputStream.close();
		}		
		
		public function readCustomToken(inputFile:String):void {
			/*
			 * comments are:
			/**/
			
			var iFile:File = File.documentsDirectory.resolvePath(inputFile);
			
			var inputStream:FileStream = new FileStream();
			inputStream.open(iFile, FileMode.READ);
			
			var strHelper:StringHelper = new StringHelper();
			
			
			var curChar:String;
			var line:String;
			
			_customToken = new Array();
			
			while ( inputStream.bytesAvailable > 0) {
				
				line  = "";
				curChar = "";
				while ( curChar != "\n" && inputStream.bytesAvailable > 0 ) {
					
					curChar = inputStream.readMultiByte(1, File.systemCharset);
					
					if( curChar.charCodeAt(0) != 10 && curChar.charCodeAt(0) != 13)
						line += curChar;
					
				}
				
				if ( line.indexOf(":") != -1) {
					
					var pair:Array = line.split(":");
					_customToken[ strHelper.myTrim(pair[0]) ] = int(strHelper.myTrim(pair[1]));
				}
			}
			
			inputStream.close();
		}	
		
		public function parseAS2(inputFile:String, outputFile:String, objectName:String):void {
			/*
			 * comments are:
			 * // ... \n
			 * /* ... */
			/**/
			
			/*
			var scripts:Array = [];
			scripts["script1"] = ["push",12,"push",1,"push",2,"add","trace","push",15,"push","reg1","sts","push","dada!","trace"];
			scripts["script2"] = ["push",7,"push",1,"push",3,"push",7];
			*/
			 
			var iFile:File = File.documentsDirectory.resolvePath(inputFile);
			var oFile:File = File.documentsDirectory.resolvePath(outputFile);
			
			var inputStream:FileStream = new FileStream();
			inputStream.open(iFile, FileMode.READ);
			
			var outputStream:FileStream = new FileStream();
			outputStream.open(oFile, FileMode.WRITE);
			
			var curChar:String;
			var line:String;
			var scriptname:String;
			var firstScript:Boolean = true;
			var firstCommand:Boolean = true;
			outputStream.writeMultiByte("var "+objectName+":Array = [];\n", "utf-8");
			
			while ( inputStream.bytesAvailable > 0) {
				
				line  = "";
				curChar = "";
				while ( curChar != "\n" && inputStream.bytesAvailable > 0 ) {
					
					curChar = inputStream.readMultiByte(1, File.systemCharset);
					
					if( curChar.charCodeAt(0) != 10 && curChar.charCodeAt(0) != 13)
						line += curChar;
					
				}
				
				if ( line.substr(0, 1) == "=") {
					scriptname = line.substr(1,line.length-1);
					if(!firstScript)
						outputStream.writeMultiByte("];\n", "utf-8");
					outputStream.writeMultiByte( objectName + "[\"" + scriptname + "\"] = [", "utf-8");
					firstScript = false;
					firstCommand = true;
				}else{
					if(!firstCommand)
						outputStream.writeMultiByte(",", "utf-8");
					outputStream.writeMultiByte(line, "utf-8");
					firstCommand = false;
				}
			}
			
			outputStream.writeMultiByte("];\n", "utf-8");
			
			inputStream.close();
			outputStream.close();
		}	
		
		public function parseAS3(inputFile:String, outputFile:String, nameSpace:String, objectName:String):void {
			/*
			 * comments are:
			 * // ... \n
			 * /* ... */
			/**/
			 
			/*
			package classes.game {
				public class Scripts{
					public static var scripts:Array = [];
					public static function fillScripts():void {
						scripts["initprot"] = ["threadlock", "_push", "_name", "lds", "_push", 9, "setcreaturespeed", "_push", "_name", "lds", "_push", 40000, "setcreatureenergy", "_push", "_name", "lds", "_push", 1, "setcreaturedirection", "_push", "_name", "lds", "_push", 2, "setcreatureclimbingspeed", "_push", "_name", "lds", "_push", -151, "setcreaturejumpstartspeed", "_push", "_name", "lds", "_push", "shot1", "setcreatureshot", "_push", "_name", "lds", "_push", 2.7, "setweight", "_push", "_name", "lds", "_push", 0, "setbarposx", "_push", "_name", "lds", "_push", -40, "setbarposy", "_push", "_name", "lds", "_push", 30, "setcreatureacceleration"];
					}
				}
			}
			*/
			
			var iFile:File = File.documentsDirectory.resolvePath(inputFile);
			var oFile:File = File.documentsDirectory.resolvePath(outputFile);
			
			var inputStream:FileStream = new FileStream();
			inputStream.open(iFile, FileMode.READ);
			
			var outputStream:FileStream = new FileStream();
			outputStream.open(oFile, FileMode.WRITE);
			
			var curChar:String;
			var line:String;
			var scriptname:String;
			var firstScript:Boolean = true;
			var firstCommand:Boolean = true;
			outputStream.writeMultiByte("package " + nameSpace + "{\n", "utf-8");
			outputStream.writeMultiByte(" public class " + objectName + "{\n", "utf-8");
			outputStream.writeMultiByte("  public static var scripts:Array = [];\n", "utf-8");
			outputStream.writeMultiByte("  public static function fillScripts():void{\n", "utf-8");
			
			
			while ( inputStream.bytesAvailable > 0) {
				
				line  = "";
				curChar = "";
				while ( curChar != "\n" && inputStream.bytesAvailable > 0 ) {
					
					curChar = inputStream.readMultiByte(1, File.systemCharset);
					
					if( curChar.charCodeAt(0) != 10 && curChar.charCodeAt(0) != 13)
						line += curChar;
					
				}
				
				if ( line.substr(0, 1) == "=") {
					scriptname = line.substr(1,line.length-1);
					if(!firstScript)
						outputStream.writeMultiByte("];\n", "utf-8");
					outputStream.writeMultiByte( "   "+"scripts" + "[\"" + scriptname + "\"] = [", "utf-8");
					firstScript = false;
					firstCommand = true;
				}else{
					if(!firstCommand)
						outputStream.writeMultiByte(",", "utf-8");
					outputStream.writeMultiByte(line, "utf-8");
					firstCommand = false;
				}
			}
			
			outputStream.writeMultiByte("];\n", "utf-8");
			outputStream.writeMultiByte("  }\n", "utf-8");
			outputStream.writeMultiByte(" }\n", "utf-8");
			outputStream.writeMultiByte("}\n", "utf-8");
			
			inputStream.close();
			outputStream.close();
		}
		
		public function Main():void{

			log = new TextField(); 
            log.x = 15; 
            log.y = 15; 
            log.width = 800; 
            log.height = 600; 
            log.background = true; 
             
            addChild(log);
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke); 

		}
		
		
		public function onInvoke(invokeEvent:InvokeEvent):void {
			
            if (invokeEvent.arguments.length > 0){
                params = invokeEvent.arguments;
            }
			
			if( parseArgs() ){
			
				if (ctFile) {
					// read custom tokens
					readCustomToken(ctFile);
				}
				
				removeComments(		sourceFile, 			"c:/temp/test.pars1");
				removeEmptyLines(	"c:/temp/test.pars1", 	"c:/temp/test.pars2");
				
				
				if (scriptVersion == _AS3) {
					resolveMarks(	"c:/temp/test.pars2", 	"c:/temp/test.pars3");
					resolveTokens(	"c:/temp/test.pars3", 	"c:/temp/test.pars4");
					
				}else
					resolveMarks(	"c:/temp/test.pars2", 	"c:/temp/test.pars4");
					
				parseString(		"c:/temp/test.pars4", 	"c:/temp/test.pars5");
				
				 destFile = destFile + on+".as";
				
				if(scriptVersion == _AS2)
					parseAS2(		"c:/temp/test.pars5", 	destFile, on);
				else
					parseAS3(		"c:/temp/test.pars5", 	destFile, ns, on);


				/*
				var file:File;
				
				file = File.documentsDirectory.resolvePath("c:/temp/test.pars1"); 
				file.deleteFile();
				
				file = File.documentsDirectory.resolvePath("c:/temp/test.pars2"); 
				file.deleteFile();
				
				file = File.documentsDirectory.resolvePath("c:/temp/test.pars3"); 
				file.deleteFile();
				
				file = File.documentsDirectory.resolvePath("c:/temp/test.pars4"); 
				file.deleteFile();
				
				file = File.documentsDirectory.resolvePath("c:/temp/test.pars5"); 
				file.deleteFile();
				/**/
			}
			
			NativeApplication.nativeApplication.exit();
			
        }
		
        public function logEvent(entry:String):void{
            log.appendText(entry + "\n"); 
            trace(entry); 
        }
		
		
	}
	
}
	
class StringHelper {
	
	public function StringHelper() {}

	public function replace(str:String, oldSubStr:String, newSubStr:String):String {
		return str.split(oldSubStr).join(newSubStr);
	}

	public function myTrim(str:String):String {
		var str:String;
		
		str = trim(str, " "  );
		str = trim(str, "\t" );
		str = trim(str, "\n" );
		
		return str;
	}
	
	public function trim(str:String, char:String = " "):String {
		return trimBack(trimFront(str, char), char);
	}

	public function trimFront(str:String, char:String):String {
		char = stringToCharacter(char);
		if (str.charAt(0) == char) {
			str = trimFront(str.substring(1), char);
		}
		return str;
	}

	public function trimBack(str:String, char:String):String {
		char = stringToCharacter(char);
		if (str.charAt(str.length - 1) == char) {
			str = trimBack(str.substring(0, str.length - 1), char);
		}
		return str;
	}

	public function stringToCharacter(str:String):String {
		if (str.length == 1) {
			return str;
		}
		return str.slice(0, 1);
	}
}