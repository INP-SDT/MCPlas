MCPlas workflow
****************
   
The general concept of the MCPlas toolbox is given by the workflow presented in figure 2. 
At the beginning of the MCPlas workflow, as a first step, all input data necessary for setting up the model must be provided. 
This considers general input data and plasma chemistry prepared in JSON data format.
The second step of the MCPlas workflow involves setting up the model by executing the main MATLAB script, MCPlas.m. 
This script systematically calls MATLAB functions (listed in section *toolbox*) specifically designed for the toolbox. 
The second and third steps automatically execute after running the MCPlas code, and they are not the user's concern. 