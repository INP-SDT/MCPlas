The input data necessary for running MCPlas includes information about the RKM, transport properties of the particle species, as well as general information about the modelling geometry, operating conditions, properties of the plasma source and fluid model properties. 
These data represent a heterogeneous data set that requires a standardised schema to be verified.
MCPlas adopts an extended version of the format proposed by the LXCat platform(open-source) (*E. Carbone, W. Graef, G. Hagelaar, D. Boer, M. M. Hopkins, J. C. Stephens, B. T. Yee, S. Pancheshnyi, J. van Dijk, L. Pitchford,  Atoms 9 (1) (2021) 1*, *D. Boer, S. Verhoeven, S. Ali, W. Graef, J. van Dijk, LXCat. URL https://github.com/LXCat-project/LXCat*). 
The basic, top-level structure of the JSON data describing an RKM is shown in figure 1. 
It comprises three main properties: *references*; an object storing the references from which included data are extracted, *states*; an object listing all the states of the particle species considered, and *processes*; an array of process objects that provide information on the reaction equations and corresponding data. 
Each individual element of the JSON document is accurately defined by a corresponding JSON schema definition. 
The exact definition of the LXCat schemas can be found in the LXCat GitHub repository (*D. Boer, S. Verhoeven, S. Ali, W. Graef, J. van Dijk, LXCat. URL https://github.com/LXCat-project/LXCat*).
These schemas can also be used to validate incoming documents. 
The development of MCPlas has contributed to the extension of the existing electron scattering schemas to further accommodate plasma chemistry data.
