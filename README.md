# AxisDraw_Template
Template for an AxisDraw project.

Important functions:
- setupPloter(): setup the ploter.
- drawPloter(): sends the commands to the ploter.
- doConnection(): if the program is not connected to the ploter, trys to connect again.

Important variables:
- ToDoList: Array of points and special commands. The order of the array is the order of the commands.
	- Special commands:
		- (-30, 0): raise pen
		- (-31, 0): lower pen
		- (-33, 0): 3 seconds delay
		- (-35, 0): back to (0, 0)
		
