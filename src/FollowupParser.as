package
{
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	import mx.graphics.shaderClasses.ExclusionShader;

	public class FollowupParser extends EventDispatcher
	{
		private var csvLines:Array;
		private var count:int;
		private var total:int;
		
		//the indexes for the given csv
		private var c1:int = -1;
		private var c2:int = -1;
		private var c3:int = -1;
		private var c4:int = -1;
		private var v1:int = -1;
		private var v2:int = -1;
		
		private var crlf:String=String.fromCharCode(10);
		private var newCsv:String="First Name, Last Name, Address 1, City, State, Zip, Volunteer 1, Volunteer 2" + crlf;
		
		public function processArray(csvLines:Array):void {
			this.csvLines = csvLines;
			/*
			* Parsing a csv is quick.  The UI that is listening to these
			* events may not have time to adjust if the events are fired
			* so quickly after calling this method.  Giving the UI
			* 1 second to ready itself is just being polite.
			*/
			setTimeout(parse, 1000);
		}
		
		public function getNewCSVString():String {
			return this.newCsv;
		}
		
		private function processHeaders(headers:Array):void {
			for(var i:int = 0; i < headers.length; ++i) {
				var header:String = headers[i];
				if(header.indexOf("clientName1") != -1) {
					c1 = i;
				} else if(header.indexOf("clientName2") != -1) {
					c2 = i;
				} else if(header.indexOf("clientName3") != -1) {
					c3 = i;
				} else if(header.indexOf("clientName4") != -1) {
					c4 = i;
				} else if(header.indexOf("volName1") != -1) {
					v1 = i;
				} else if(header.indexOf("volName2") != -1) {
					v2 = i;
				}
			}
		}
		
		private function parse():void {
			var headers:String = this.csvLines[0];
			processHeaders(headers.split(","));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "****Begining the parse starting with headers."));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "****Location of clients and volunteers follows:"));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "c1: " + c1.toString()));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "c2: " + c2.toString()));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "c3: " + c3.toString()));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "c4: " + c4.toString()));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "v1: " + v1.toString()));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "v2: " + v2.toString()));
			this.csvLines.splice(0,1);
			this.total = this.csvLines.length;
			this.count = 0;
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "****Total lines to parse: " + this.total.toString()));
			this.batchProcess();
		}
		
		private function batchProcess():int {
			if(count < total) {
				this.processLog(this.csvLines[count].split('","'));
				this.dispatchEvent(new ParseEvent(ParseEvent.LINE_PARSED));
				count++;
				setTimeout(batchProcess, 100);
				return 1;
			} else {
				this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "****Total chars:"));
				this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, newCsv.length.toString()));
				this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "****PARSE COMPLETE."));
				this.dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE));
				return 1;
			}
		}
		
		private function processLog(log:Array):void {
			var clients:Array = [log[c1], log[c2], log[c3], log[c4]];
			var volunteers:Array = [];
			
			//validate there is a volunteer in the space
			if(log[v1] != "") {
				volunteers.push(log[v1]);
			}
			if(log[v2] != "") {
				volunteers.push(log[v2]);
			}
			
			//validate the client exists and process
			var clientCount:int = 1;
			for each(var c:String in clients) {
				if(c && c != "") {
					try {
						processClient(this["c" + clientCount.toString()], log, volunteers);
					} catch (e:Error) {
						this.dispatchEvent(new ParseEvent(ParseEvent.PARSE_ERROR, e.message));
					}
				}
				clientCount++;
			}
		}
		
		private function processClient(cPos:int, log:Array, v:Array):void {
			var tmpStr:String = "";
			var fuzzyName:Object = fuzzyFindName(log[cPos]);
			var client:Array = [fuzzyName.firstName, fuzzyName.lastName, log[(cPos + 4)] + " " + log[(cPos + 5)], log[(cPos + 6)], log[(cPos + 7)], log[(cPos + 8)]];
			for each(var val:String in client) {
				tmpStr += '"' + val + '",';
			}
			for each(var vol:String in v) {
				tmpStr += '"' + vol + '",'
			}
			tmpStr = tmpStr.substr(0, tmpStr.length-1); //trim the last comma
			tmpStr += crlf;
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, "****Logging the following client:"));
			this.dispatchEvent(new ParseEvent(ParseEvent.NOTES, tmpStr));
			newCsv += tmpStr;
		}
		
		private function fuzzyFindName(name:String):Object {
			var n:Array = name.split(" ");
			var newName:Object = {};
			newName.firstName = n[0];
			newName.lastName = "";
			for(var i:int = 1; i<n.length; ++i) {
				newName.lastName += n[i];
				if(i!=n.length) {
					newName.lastName += " ";
				}
			}
			return newName;
		}
	}
}