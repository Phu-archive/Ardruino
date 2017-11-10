


// Button height 
buttonHeight = 0.5;

// Number of buttons
buttonNum = 5;

// LDR variables

// Button Variables 

// Size
buttonX = 3;
buttonY = 4;
buttonZ = 4 + buttonHeight + 1; // Breadboard hight is 4.

// LDR Variables

// Size
LDRX = 1;
LDRY = 1;
LDRZ = 4 + buttonHeight;

// Space 

// between each button
spaceButton = 2;

// space between button and cylinder
spaceCylinder = 0.8;

// between LDR
spaceLDR = buttonX*2 + 3 * spaceButton + (buttonX - LDRX)/2; 


module Button(buttonNumber){
      // For y value keep it constant. 
      translate([buttonNumber*spaceButton + (buttonNumber-1)*buttonX, 3.5, 0.2]){
         // Size of button cube
         cube([buttonX, buttonY, buttonZ]);  
         
      }
}



difference() {
    // The breadboard.
    color([1,0,0]) cube([32, 11, 4]);
    
    for(i = [1:6]){
        if(i != 3){
            Button(i);
            // LDR at i == 3
        } else {
            translate([spaceLDR, 5, 1]){
             // Draw LDR Button
            cube([LDRX, LDRY, LDRZ]);  
            }
            
        }
    }
    
    translate([1, 1, 1]){
        color([1,0,0]) cube([30, 20, 1]);
    }
}


