using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class HeartArcView extends WatchUi.DataField {

    hidden var heartRate;
    hidden var numZones = Application.getApp().getProperty("numZones");
    
    hidden var maxHr = Application.getApp().getProperty("maxHr");
    hidden var zoneLowerBound = new [numZones + 1];

    function initialize() {
    
    	for (var i=0; i<numZones; i++) {
    		var zone = i+1;
    		zoneLowerBound[i] = Application.getApp().getProperty("zone" + zone);
    	}
    	zoneLowerBound[numZones] = maxHr;
    	
//    	System.println(zoneLowerBound);
    
        DataField.initialize();
        heartRate = 0.0f;
        heartRate = 99;
    }

    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        if(info has :currentHeartRate){
//            heartRate = info.currentHeartRate != null ? info.currentHeartRate : 0;
			heartRate++;
			heartRate = heartRate + 0.0f;
        }
    }

    function onUpdate(dc) {
    
    	var width = dc.getWidth();
    	var height = dc.getHeight();
    	var radius = width < height ? width : height;
    	
    	var textCenter = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var backgroundColor = getBackgroundColor();
        var font = getFont(heartRate.format("%d"), radius, Graphics.FONT_NUMBER_MILD, dc);
        
        
        // set background color
        dc.setColor(backgroundColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, width, height);
        // set foreground color
        dc.setColor((backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        // do layout
        dc.drawText(width / 2, height / 2 - getSpace(dc, heartRate.format("%d"), font), Graphics.FONT_TINY, WatchUi.loadResource(Rez.Strings.label), textCenter);
        dc.drawText(width / 2, height / 2, font, heartRate.format("%d"), textCenter);
              
        //Arcs
		try {
			var zone = drawZoneBarsArcs(dc, (radius/2)+1, width/2, height/2, heartRate); //radius, center x, center y
		}
		catch( ex ) {}
		
    }
    
    function getFont(text, height, limit, dc){
    	
		var font = Graphics.FONT_NUMBER_THAI_HOT;
		
		while (dc.getTextDimensions(text, font)[0]*2 > height && font >= limit ) {
			font--;
		}
    	
    	return font;
    }
    
    function getSpace(dc, text, font){
    	var size = dc.getTextDimensions(text, font)[1];
    	return (size / 2) + (size / 4);
    }
    
    
    //function for HeartRate Arc
	function drawZoneBarsArcs(dc, radius, centerX, centerY, hr){

		var zoneColours = [Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_ORANGE, Graphics.COLOR_RED, Graphics.COLOR_YELLOW, Graphics.COLOR_PURPLE, Graphics.COLOR_DK_RED];	
		var penO = 25;
		var penI = 25;
		var circleWith = 15;
		var circleResaltWith = 20;
	
		var degrees = 260;
		var divDegree = degrees/numZones;
			
		//Calculate arc degrees
		var arcDegrees = new [numZones + 1];
		arcDegrees[0] = 220;
		for (var j=1; j<numZones+1; j++) {
			arcDegrees[j] = arcDegrees[j-1] - degrees/numZones;
		}
			
		//Load with properties
		var zoneCircleWidth = new [numZones];
		for (var j=0; j<numZones; j++){
			zoneCircleWidth[j] = circleWith; 
		}
		
		//Calculate heartZone
		var heartZone;
		for (var i = 0; i < zoneLowerBound.size() && hr >= zoneLowerBound[i]; ++i) { 
			heartZone = i+1; 
		}
		if (heartZone > numZones) { return heartZone;} //If zone not exists --> return
		
		if(heartZone >= 0){
			zoneCircleWidth[heartZone-1] = circleResaltWith;
		}
		
		//Draw Arc
		for (var j = 0; j < numZones; ++j){
			dc.setColor(zoneColours[j], Graphics.COLOR_TRANSPARENT);
			dc.setPenWidth(zoneCircleWidth[j]);
			dc.drawArc(centerX, centerY, radius - zoneCircleWidth[j]/2, dc.ARC_CLOCKWISE, arcDegrees[j], arcDegrees[j+1]);
		}
		
		//Calculate and draw dial
		var zonedegree;
		zonedegree = ((zoneLowerBound[heartZone]-hr) / (zoneLowerBound[heartZone] - zoneLowerBound[heartZone-1])) * divDegree;
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(penO);
		dc.drawArc(centerX, centerY, radius-12, dc.ARC_COUNTER_CLOCKWISE, arcDegrees[heartZone] + zonedegree - 3, arcDegrees[heartZone] + zonedegree + 1);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(penI);
		dc.drawArc(centerX, centerY, radius-12, dc.ARC_COUNTER_CLOCKWISE, arcDegrees[heartZone] + zonedegree - 2, arcDegrees[heartZone] + zonedegree);
		
		return heartZone;
	}

}
