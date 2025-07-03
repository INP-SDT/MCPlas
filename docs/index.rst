.. MATLAB Sphinx Documentation Test documentation master file, created by
   sphinx-quickstart on Wed Jan 15 11:38:03 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to MCPlas toolbox!
=====================================

.. image:: images/Logo.jpg
   :scale: 25%
   :align: center
  

Introduction:
--------------

.. include:: manual_rst_introduction/introduction.rst
   
   
Structure
-----------------
The code directory has the following structure:

..  code-block:: none
        
    MCPlas
    ├── MCPlas.m
    │  
    ├── Toolbox
    │   
    ├── Application
    │ 
    └── Plasma


.. toctree::
   :maxdepth: 2

MCPlas.m
*********
This script serves as the core file of the MCPlas toolbox. 
It begins by loading user-defined chemistry and general model settings from JSON files, parsing them into structured input objects. 
After initializing the COMSOL environment and defining the working path, it systematically calls MATLAB functions to establish parameters, geometry, physical constants, variables, transport and reaction coefficients, and model equations. 
It configures electrical conditions, surface effects, and postprocessing elements like probes and plots. 
Meshing and solver settings are finalized before the complete model is saved as a .mph file. 

.. function:: MCPlas.MCPlas

Toolbox
*********
The Toolbox folder in the MCPlas toolbox contains a collection of MATLAB functions essential for building a COMSOL model using the MATLAB LiveLink module.  
These functions automate model generation by systematically calling COMSOL-specific commands to define all essential features of the model.
By organizing model-building tasks into modular scripts, the folder ensures clarity, maintainability, and flexibility of the model building process.
  
.. toctree::
   :maxdepth: 3
   
   manual_rst_toolbox/ReadJSON.rst
   manual_rst_toolbox/InpRKM.rst
   manual_rst_toolbox/InpGeneral.rst
   manual_rst_toolbox/SetParameters.rst
   manual_rst_toolbox/SetConstants.rst
   manual_rst_toolbox/SetVariables.rst
   manual_rst_toolbox/SetTransportCoefficients.rst
   manual_rst_toolbox/SetRateCoefficients.rst
   manual_rst_toolbox/SetEnergyRateCoefficients.rst
   manual_rst_toolbox/SetRates.rst
   manual_rst_toolbox/SetEnergyRates.rst
   manual_rst_toolbox/SetFluxes.rst
   manual_rst_toolbox/SetSources.rst
   manual_rst_toolbox/SetProbesAndGraphs.rst
   manual_rst_toolbox/AddSurfaceChargeAccumulation.rst
   manual_rst_toolbox/AddPoissonEquation.rst
   manual_rst_toolbox/AddFluidEquations.rst
   manual_rst_toolbox/SetElectrical
   manual_rst_toolbox/SetSelection.rst
   manual_rst_toolbox/msg.rst
   manual_rst_toolbox/num2strcell.rst
   manual_rst_toolbox/IsModelMember.rst
   manual_rst_toolbox/ActivatePlasma.rst
   
   
Application
************
The Application folder in the MCPlas toolbox serves as the central location for organizing geometry-specific modeling cases.
It contains subfolders such as Generic1D, Generic1p5D, Generic2D, and Generic2p5D, each corresponding to a particular modelling geometry. 
Within each subfolder, there are dedicated MATLAB scripts responsible for defining the geometry, generating the mesh, and configuring project-specific properties such as solvers and study steps. 
Each case also includes a General JSON input file that provides essential settings tailored to that specific geometry.
After the model-building process is completed, the resulting .mph file is automatically saved in the same subfolder, keeping all related files organized and localized. 

Generic1D
^^^^^^^^^^

The Generic1D subfolder is dedicated to application of one-dimensional, time-dependent plasma modeling. 
It contains MATLAB scripts that define the geometry, mesh, and project settings specific to 1D simulations. 
This modeling case is designed to support plasma source configurations featuring either rectangular or circular electrodes (figure 1), making it suitable for simplified yet physically relevant geometries. 
The correct specification of electrode dimensions is crucial and must be provided accurately in the associated General JSON input file.

.. figure:: images/1D.svg
   :width: 75%
   :align: center 

   Figure 1, 1D modelling geometry.   

.. toctree::
   :maxdepth: 3
   
   manual_rst_application/Generic1D/SetGeometry.rst
   manual_rst_application/Generic1D/SetMesh.rst
   manual_rst_application/Generic1D/SetProject.rst
   manual_rst_application/Generic1D/Generic1D.rst
   
Generic1p5D
^^^^^^^^^^^^

The Generic1p5D subfolder is dedicated to application of one-dimensional, time-dependent plasma modeling in polar coordinates. 
It contains MATLAB scripts that configure the geometry, meshing, and project settings only for coaxial plasma source configurations (figure 2). 
This requires that electrode dimensions—such as radius of inner and outer electrodes—be accurately defined in the corresponding General JSON input file. 
These inputs determine the plasma domain and boundary conditions essential for correct simulation behavior.

.. figure:: images/1p5D.svg
   :width: 75%
   :align: center 

   Figure 2, 1p5D modelling geometry for simulations in polar coordiantes. 

.. toctree::
   :maxdepth: 3
   
   manual_rst_application/Generic1p5D/SetGeometry.rst
   manual_rst_application/Generic1p5D/SetMesh.rst
   manual_rst_application/Generic1p5D/SetProject.rst
   manual_rst_application/Generic1p5D/Generic1p5D.rst   

Generic2D
^^^^^^^^^^

The Generic2D subfolder is dedicated to application of two-dimensional, time-dependent plasma modeling in Cartesian coordinates. 
It contains MATLAB scripts responsible for setting up the geometry, mesh, and project configuration for rectangular electrodes (see figure). 
The dimensions and positions of the rectangular electrodes must be properly specified in the associated General JSON input file.

.. figure:: images/2D.svg
   :width: 75%
   :align: center 

   Figure 3, 2D modelling geometry for simulations in Cartesian coordinates.  

.. toctree::
   :maxdepth: 3
   
   manual_rst_application/Generic2D/SetGeometry.rst
   manual_rst_application/Generic2D/SetMesh.rst
   manual_rst_application/Generic2D/SetProject.rst
   manual_rst_application/Generic2D/Generic2D.rst
   
Generic2p5D
^^^^^^^^^^^^

The Generic2p5D subfolder is dedicated to the application of two-dimensional, time-dependent plasma modeling in cylindrical coordinates.
It contains MATLAB scripts responsible for setting up the geometry, mesh, and project configuration for plasma sources with rectangular or circular electrode shapes.
The dimensions and positions of both rectangular and circular electrodes must be properly specified in the associated General JSON input file, as they directly affect domain generation and boundary condition assignment.  

.. toctree::
   :maxdepth: 3
   
   manual_rst_application/Generic2p5D/SetGeometry.rst
   manual_rst_application/Generic2p5D/SetMesh.rst
   manual_rst_application/Generic2p5D/SetProject.rst
   manual_rst_application/Generic2p5D/Generic2p5D.rst

   
Plasma
*******

.. include:: manual_rst_plasma/plasma_introduction.rst
.. figure:: images/File_structure.jpg
   :width: 75%
   :align: center

   Figure 5, A schematic representing the top-level structure of an LXCat JSON document for LTP input data.
   
   Here are two JSON input data files for argon 4-species and 23-species RKM: 

.. toctree::
   :maxdepth: 3
   
   manual_rst_plasma/Ar_Becker_2009.rst
   manual_rst_plasma/Ar_Stankov_2022.rst

How to use it
-------------
  
.. include:: manual_rst_tutorial/MCPlas_workflow.rst
.. figure:: images/MCPlas_workflow.jpg
   :width: 75%
   :align: center 

   Figure 6, MCPlas worklow.
   

.. include:: manual_rst_tutorial/Step_by_step_tutorial.rst

   
   

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
