#!/usr/bin/env python3
"""
Template Python Script for Alibre Design Addon

This is a template script that demonstrates basic operations in Alibre Design.
Replace this content with your specific addon functionality.

Author: $username$
Date: $date$
Description: $scriptdescription$
"""

import math
import sys
import clr
from System.Runtime.InteropServices import Marshal
from AlibreScript.API import *

# Get the Alibre application interface
alibre = Marshal.GetActiveObject("AlibreX.AutomationHook")
root = alibre.Root
myPart = Part(root.TopmostSession)

# Set units to millimeters
Units.Current = UnitTypes.Millimeters

# Example: Create a simple box
def create_example_box():
    """Create a simple parametric box as an example"""
    
    # Parameters (modify these as needed)
    width = 50.0   # Box width in mm
    height = 30.0  # Box height in mm  
    depth = 20.0   # Box depth in mm
    
    print(f"Creating example box: {width}x{height}x{depth} mm")
    
    try:
        # Create a sketch on the XY plane
        boxSketch = myPart.AddSketch('BoxSketch', myPart.GetPlane('XY-Plane'))
        
        # Create a rectangle
        boxLine = Polyline()
        boxLine.AddPoint(PolylinePoint(-width/2., -height/2.))
        boxLine.AddPoint(PolylinePoint(width/2., -height/2.))
        boxLine.AddPoint(PolylinePoint(width/2., height/2.))
        boxLine.AddPoint(PolylinePoint(-width/2., height/2.))
        boxLine.AddPoint(PolylinePoint(-width/2., -height/2.))
        
        boxSketch.AddPolyline(boxLine, False)
        
        # Extrude the sketch to create a 3D box
        myPart.AddExtrudeBoss('BoxExtrude', boxSketch, depth, False)
        
        print("Example box created successfully!")
        
    except Exception as e:
        print(f"Error creating box: {e}")
        
# Example: Add rounded corners (optional)
def add_rounded_corners(radius=2.0):
    """Add fillets to the box edges"""
    
    try:
        # Note: Edge names may vary depending on creation order
        # You may need to adjust these edge references for your specific case
        edges_to_fillet = [
            'Edge<1>', 'Edge<2>', 'Edge<3>', 'Edge<4>'  # Top edges
        ]
        
        # Attempt to add fillets
        myPart.AddFillet('BoxFillets', [myPart.GetEdge(edge) for edge in edges_to_fillet], radius, False)
        print(f"Added {radius}mm fillets to box corners")
        
    except Exception as e:
        print(f"Could not create fillets: {e}")
        print("This is normal - edge names depend on creation order")

# Main execution
if __name__ == "__main__":
    print("=== Alibre Design Addon Template Script ===")
    print("This is a template script. Modify it for your specific needs.")
    
    # Execute the example
    create_example_box()
    add_rounded_corners()
    
    print("=== Script completed ===")
    print("TODO: Replace this template with your addon-specific functionality")