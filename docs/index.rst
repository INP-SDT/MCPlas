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
This is the main matlab file

.. function:: MCPlas.MCPlas

Toolbox
*********
This is the folder with functions
  
.. toctree::
   :maxdepth: 3
   
   manual_rst_toolbox/InpRKM.rst
   manual_rst_toolbox/SetConstants.rst
   manual_rst_toolbox/SetVariables.rst
   manual_rst_toolbox/SetTransportCoefficients.rst
   manual_rst_toolbox/SetRateCoefficients.rst
   manual_rst_toolbox/SetEnergyRateCoefficients.rst
   manual_rst_toolbox/SetRates.rst
   manual_rst_toolbox/SetEnergyRates.rst
   manual_rst_toolbox/SetFluxes.rst
   manual_rst_toolbox/SetSources.rst
   manual_rst_toolbox/AddSurfaceChargeAccumulation.rst
   manual_rst_toolbox/AddPoissonEquation.rst
   manual_rst_toolbox/AddFluidEquations.rst
   manual_rst_toolbox/msg.rst
   manual_rst_toolbox/num2strcell.rst
   
   
Application
************
This is the folder with application cases

Generic1D
^^^^^^^^^^

This is the folder with 1D applicationfunctions  

.. toctree::
   :maxdepth: 3
   
   manual_rst_application/Generic1D/SetGeometry.rst
   manual_rst_application/Generic1D/SetMesh.rst
   manual_rst_application/Generic1D/SetProject.rst
   manual_rst_application/Generic1D/Generic1D.rst

Generic2D
^^^^^^^^^^

This is the folder with 2D applicationfunctions  

.. toctree::
   :maxdepth: 3
   
   manual_rst_application/Generic2D/SetGeometry.rst
   manual_rst_application/Generic2D/SetMesh.rst
   manual_rst_application/Generic2D/SetProject.rst
   manual_rst_application/Generic2D/Generic2D.rst

   
Plasma
*******

.. include:: manual_rst_plasma/plasma_introduction.rst
.. figure:: images/File_structure.jpg
   :width: 75%
   :align: center

   Figure 1, A schematic representing the top-level structure of an LXCat JSON document for LTP input data.
   
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

   Figure 2, MCPlas worklow.
   

.. include:: manual_rst_tutorial/Step_by_step_tutorial.rst

   
   

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
