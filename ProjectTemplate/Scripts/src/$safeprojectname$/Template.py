# $projectname$ Template Script
# Generated from Alibre Script Addon Template

import math
import sys
import clr
from System.Runtime.InteropServices import Marshal
from AlibreScript.API import *

# Get Alibre application instance
alibre = Marshal.GetActiveObject("AlibreX.AutomationHook")
root = alibre.Root
myPart = Part(root.TopmostSession)

# Set units to millimeters
Units.Current = UnitTypes.Millimeters

# Create a simple example shape - a rectangular block
length = 100.0
width = 50.0
height = 25.0

# Create a new part
examplePart = myPart

# Create a sketch on the XY plane
sketch = examplePart.AddSketch('BaseSketch', examplePart.GetPlane('XY-Plane'))

# Create a rectangular outline
rectangle = Polyline()
rectangle.AddPoint(PolylinePoint(-width/2, -length/2))
rectangle.AddPoint(PolylinePoint(width/2, -length/2))
rectangle.AddPoint(PolylinePoint(width/2, length/2))
rectangle.AddPoint(PolylinePoint(-width/2, length/2))
rectangle.AddPoint(PolylinePoint(-width/2, -length/2))

# Add the rectangle to the sketch
sketch.AddPolyline(rectangle, False)

# Extrude the sketch to create a 3D shape
examplePart.AddExtrudeBoss('BaseExtrude', sketch, height, False)

print(f"{myPart.Name} template script completed successfully!")
print(f"Created a {width}mm x {length}mm x {height}mm rectangular block.")
print("Modify this script to create your own custom shapes.")