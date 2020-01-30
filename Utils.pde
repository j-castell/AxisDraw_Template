int[] getMotorPixelPos() {
  int[] out = {

    int (float (MotorX) / MotorStepsPerPixel) + MousePaperLeft, 
    int (float (MotorY) / MotorStepsPerPixel) + MousePaperTop + yBrushRestPositionPixels

  };
  return out;
}

void scanSerial() {  

  // Serial port search string:  
  int PortCount = 0;
  String portName;
  String str1, str2;
  int j;


  int OpenPortList[]; 
  OpenPortList = new int[0]; 


  SerialOnline = false;
  boolean serialErr = false;


  try {
    PortCount = Serial.list().length;
  } 
  catch (Exception e) {
    e.printStackTrace(); 
    serialErr = true;
  }


  if (serialErr == false)
  {

    println("\nI found "+PortCount+" serial ports, which are:");
    println(Serial.list());


    String  os=System.getProperty("os.name").toLowerCase();
    boolean isMacOs = os.startsWith("mac os x");
    boolean isWin = os.startsWith("win");




    if (isMacOs) 
    {
      str1 = "/dev/tty.usbmodem";       // Can change to be the name of the port you want, e.g., COM5.
      // The default value is "/dev/cu.usbmodem"; which works on Macs.

      str1 = str1.substring(0, 14);

      j = 0;
      while (j < PortCount) {
        str2 = Serial.list()[j].substring(0, 14);
        if (str1.equals(str2) == true) 
          OpenPortList =  append(OpenPortList, j);

        j++;
      }
    } else if  (isWin) 
    {    
      // All available ports will be listed.

      j = 0;
      while (j < PortCount) {
        OpenPortList =  append(OpenPortList, j);
        j++;
      }
    } else {
      // Assume linux

      str1 = "/dev/ttyACM"; 
      str1 = str1.substring(0, 11);

      j = 0;
      while (j < PortCount) {
        str2 = Serial.list()[j].substring(0, 11);
        if (str1.equals(str2) == true)
          OpenPortList =  append(OpenPortList, j);
        j++;
      }
    }

    boolean portErr;

    j = 0;
    while (j < OpenPortList.length) {

      portErr = false;
      portName = Serial.list()[OpenPortList[j]];

      try
      {    
        myPort = new Serial(this, portName, 38400);
      }
      catch (Exception e)
      {
        SerialOnline = false;
        portErr = true;
        println("Serial port "+portName+" could not be activated.");
      }

      if (portErr == false)
      {
        myPort.buffer(1);
        myPort.clear(); 
        println("Serial port "+portName+" found and activated.");

        String inBuffer = "";

        myPort.write("v\r");  //Request version number
        delay(50);  // Delay for EBB to respond!

        while (myPort.available () > 0) {
          inBuffer = myPort.readString();   
          if (inBuffer != null) {
            println("Version Number: "+inBuffer);
          }
        }

        str1 = "EBB";
        if (inBuffer.length() > 2)
        {
          str2 = inBuffer.substring(0, 3); 
          if (str1.equals(str2) == true)
          {
            // EBB Identified! 
            SerialOnline = true;    // confirm that this port is good
            j = OpenPortList.length; // break out of loop

            println("Serial port "+portName+" confirmed to have EBB.");
          } else
          {
            myPort.clear(); 
            myPort.stop();
            println("Serial port "+portName+": No EBB detected.");
          }
        }
      }
      j++;
    }
  }
}

void checkServiceBrush() {

  if (serviceBrush() == false) {

    if (millis() > NextMoveTime) {

      boolean actionItem = false;
      int intTemp = -1;
      float inputTemp = -1.0;
      PVector toDoItem;

      if ((ToDoList.length > (indexDone + 1))) {
        actionItem = true;
        toDoItem = ToDoList[1 + indexDone];
        inputTemp = toDoItem.x;
        indexDone++;
      }

      if (actionItem) {  // Perform next action from ToDoList::

        if (inputTemp >= 0) { // Move the carriage to draw a path segment!

          toDoItem = ToDoList[indexDone];  
          float x2 = toDoItem.x;
          float y2 = toDoItem.y;

          int x1 = round( (x2 - float(MousePaperLeft)) * MotorStepsPerPixel);
          int y1 = round( (y2 - float(MousePaperTop)) * MotorStepsPerPixel); 

          MoveToXY(x1, y1);
          //println("Moving to: " + str(x2) + ", " + str(y2));

          if (lastPosition.x == -1) {
            lastPosition = toDoItem; 
            //println("Starting point: Init.");
          }

          lastPosition = toDoItem;

          /*
           IF next item in ToDoList is ALSO a move, then calculate the next move and queue it to the EBB at this time.
           Save the duration of THAT move as "SubsequentWaitTime."
           
           When the first (pre-existing) move completes, we will check to see if SubsequentWaitTime is defined (i.e., >= 0).
           If SubsequentWaitTime is defined, then (1) we add that value to the NextMoveTime:
           
           NextMoveTime = millis() + SubsequentWaitTime; 
           SubsequentWaitTime = -1;
           
           We also (2) queue up that segment to be drawn.
           
           We also (3) queue up the next move, if there is one that could be queued. 
           
           */
        } else {
          intTemp = round(-1 * inputTemp);
          if ((intTemp > 9) && (intTemp < 20)) {  // Change paint color  
            intTemp -= 10;
          } else if (intTemp == 30) {
            raiseBrush();
          } else if (intTemp == 31) {  
            lowerBrush();
          } else if (intTemp == 33) {  
            delay(3000);
          } else if (intTemp == 35) {  
            MoveToXY(0, 0);
          }
        }
      }
    }
  }
}

void setupPloter() {
  
  ToDoList = new PVector[0];
  
  Ani.init(this); // Initialize animation library
  Ani.setDefaultEasing(Ani.LINEAR);
  
  MotorMinX = 0;
  MotorMinY = 0;
  MotorMaxX = int(floor(float(MousePaperRight - MousePaperLeft) * MotorStepsPerPixel)) ;
  MotorMaxY = int(floor(float(MousePaperBottom - MousePaperTop) * MotorStepsPerPixel)) ;
  
  lastPosition = new PVector(-1, -1);
  
  ServoUp = 7500 + 175 * ServoUpPct;    // Brush UP position, native units
  ServoPaint = 7500 + 175 * ServoPaintPct;   // Brush DOWN position, native units. 
  
  MotorX = 0;
  MotorY = 0;
  
  ToDoList = new PVector[0];
  PVector cmd = new PVector(-35, 0);   // Command code: Go home (0,0)
  ToDoList = (PVector[]) append(ToDoList, cmd);
  
  indexDone = -1;    // Index in to-do list of last action performed
  indexDrawn = -1;   // Index in to-do list of last to-do element drawn to screen

  raiseBrushStatus = -1;
  lowerBrushStatus = -1; 
  moveStatus = -1;
  MoveDestX = -1;
  MoveDestY = -1;
  
  int[] pos = getMotorPixelPos();
  background(0);
  MotorLocatorX = pos[0];
  MotorLocatorY = pos[1];
  
  NextMoveTime = millis();
}

void doConnection() {
  if (doSerialConnect) {
    // FIRST RUN ONLY:  Connect here, so that 
    doSerialConnect = false;

    scanSerial();

    if (SerialOnline) {    
      myPort.write("EM,1,1\r");  //Configure both steppers in 1/16 step mode

      // Configure brush lift servo endpoints and speed
      myPort.write("SC,4," + str(ServoPaint) + "\r");  // Brush DOWN position, for painting
      myPort.write("SC,5," + str(ServoUp) + "\r");  // Brush UP position 

      myPort.write("SC,10,65535\r"); // Set brush raising and lowering speed.

      // Ensure that we actually raise the brush:
      BrushDown = true;  
      raiseBrush();    
    } else { 
      println("Now entering offline simulation mode.\n");
    }
  }
}

void drawPloter() {
  if (doSerialConnect == false)
    checkServiceBrush();
}



boolean serviceBrush() {
  // Manage processes of getting paint, water, and cleaning the brush,
  // as well as general lifts and moves.  Ensure that we allow time for the
  // brush to move, and wait respectfully, without local wait loops, to
  // ensure good performance for the artist.

  // Returns true if servicing is still taking place, and false if idle.

  boolean serviceStatus = false;

  int waitTime = NextMoveTime - millis();
  if (waitTime >= 0) {
    serviceStatus = true;
    // We still need to wait for *something* to finish!
  } else {
    if (raiseBrushStatus >= 0) {
      raiseBrush();
      serviceStatus = true;
    } else if (lowerBrushStatus >= 0) {
      lowerBrush();
      serviceStatus = true;
    } else if (moveStatus >= 0) {
      MoveToXY(); // Perform next move, if one is pending.
      serviceStatus = true;
    }
  }
  return serviceStatus;
}
