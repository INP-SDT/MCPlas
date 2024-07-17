MCPlas workflow
****************
   
The general concept of the MCPlas toolbox is given by the workflow presented in figure 2. 
At the beginning of the MCPlas workflow, as a first step, all input data necessary for setting up the model must be provided. 
This considers general input data and plasma chemistry prepared in JSON data format.
In the second step of the MCPlas workflow, based on the input data, setting up the model takes place by calling the functions defined in Matlab. 
More specifically, these functions are used to automatically set up the geometry of the modelling domain (*SetGeometry*), all the included coefficients and variables (*SetConstants*, *SetVariables*, *SetTransportCoefficients*, *SetRateCoefficients*, *SetFluxes*, *SetSources*), the model equations (*AddPoissonEquation*, *AddFluidEquations*), as well as the numerical solver (*SetMesh*, *SetProject*). 
The third step considers employing Live link *for* MATLAB to compile the Comsol model. 
The second and third steps automatically execute after running the MCPlas code, and they are not the user's concern. 