The MCPlas toolbox represents a collection of MATLAB functions for the automated generation of an equation-based fluid-Poisson model for non-thermal plasmas in the multiphysics simulation software COMSOL. 
Following the development of the new generation of the LXCat platform, all input data are prepared in a structured and interoperable JSON format and can be supplied and validated using existing JSON schemas. 
The toolbox includes fully transparent, editable MATLAB source code and offers an advanced description of electron transport in addition to commonly used approaches in the plasma modelling community. 
It supports one-dimensional and two-dimensional modelling geometries employing Cartesian, polar and cylindrical coordinate systems.

The plasma description provided by MCPlas is based on the equations of fluid-Poisson model

    .. math::
		\frac{\partial}{\partial t}n_j
        + \nabla\cdot\mathbf{\Gamma}_j = S_j,
        \label{eq:continuity}\\
        %
        \frac{\partial}{\partial t}w_\mathrm{e} 
        +\nabla\cdot\mathbf{Q}_\mathrm{e}
        = -e_0\mathbf{\Gamma}_\mathrm{e}\cdot \mathbf{E} + \tilde{S}_\mathrm{e},
        \label{eq:we}\\
        %
        -\nabla \cdot(\varepsilon_\mathrm{r}\varepsilon_0\nabla\phi)
        = \sum_j q_j n_j,
        \label{eq:poisson}

where the first equation represents the balance equations for the particle number densities :math:`n_j` of species with index :math:`j` (electrons, ions, neutrals),
charge :math:`q_j` and particle flux :math:`\mathbf{\Gamma}_j`. The second equation is the balance equation for the energy density :math:`w_\mathrm{e}=n_\mathrm{e}u_\mathrm{e}` of electrons (:math:`j = \mathrm{e}`) with the mean electron energy :math:`u_\mathrm{e}` and energy flux :math:`\mathbf{Q}_\mathrm{e}`. The third equation represents the Poisson equation for the self-consistent determination of the electric potential :math:`\phi` and electric field :math:`\mathbf{E}=-\nabla\phi`. 		
The elementary charge, the relative permittivity of the medium and the vacuum permittivity are denoted by :math:`e_0`, :math:`\varepsilon_\mathrm{r}` and :math:`\varepsilon_0`, respectively.
The source terms :math:`S_j` describe the gain and loss of particles due to collision and radiation processes, and :math:`\tilde{S}_\mathrm{e}` accounts for the corresponding gain and loss of electron energy. 
All variables (:math:`n_j`, :math:`w_\mathrm{e}`, :math:`\mathbf{\Gamma}_j`, :math:`\mathbf{Q}_\mathrm{e}`, :math:`S_j`,  :math:`\tilde{S}_\mathrm{e}` and :math:`\mathbf{E}`) are space- and time-dependent quantities. 
To improve clarity and readability, the explicit notation of their dependence on :math:`(\mathbf{r},t)` is suppressed in the text. 

The fluxes :math:`{\mathbf{\Gamma}}_\mathrm{h}` of heavy particles (:math:`j=\mathrm{h}`) are expressed by the common drift-diffusion approximation (*Sigeneger, R. Winkler, IEEE Trans. Plasma Sci. 27 (5)
(1999) 1254*, *G. K. Grubert, M. M. Becker, D. Loffhagen, Phys. Rev. E 80 (2009) 036405*)

    .. math::
        \mathbf{\Gamma}_\mathrm{h}
        = \mathrm{sgn}(q_\mathrm{h})n_\mathrm{h} b_\mathrm{h} \mathbf{E}   
        -D_\mathrm{h}\nabla n_\mathrm{h}\,, \label{eq:flux_particle}

where,  :math:`b_\mathrm{h}` and :math:`D_\mathrm{h}` stand for the  mobility and diffusion coefficient of heavy species :math:`\mathrm{h}`, respectively, while the function :math:`\mathrm{sgn}(q_\mathrm{h})` defines the sign of :math:`q_\mathrm{h}`.
Three options are offered by MCPlas for the definition of the electron flux :math:`{\mathbf{\Gamma}}_\mathrm{e}` and electron energy flux :math:`{\mathbf{Q}}_\mathrm{e}`. 
The conventional drift-diffusion approximation (option ``DDAc``) for these fluxes reads

    .. math::
        \mathbf{\Gamma}_\mathrm{e}
        = -n_\mathrm{e} b_\mathrm{e} \mathbf{E}   
        -\nabla(D_\mathrm{e}n_\mathrm{e})\,,\label{eq:JeDDAc}\\
        %
        \mathbf{Q}_\mathrm{e}
        = -w_\mathrm{e} \tilde{b}_\mathrm{e} \mathbf{E}   
        -\nabla(\tilde{D}_\mathrm{e}w_\mathrm{e})\,,\label{eq:QeDDAc}
 
where :math:`b_\mathrm{e}` and :math:`D_\mathrm{e}` are electron transport coefficients, and :math:`\tilde{b}_\mathrm{e}` and :math:`\tilde{D}_\mathrm{e}` represent the electron energy transport coefficients. 
The frequently used approach (option ``DDA53``) employs the simplified form of the electron energy flux

    .. math::
        \mathbf{Q}_\mathrm{e}
        = -\frac{5}{3} w_\mathrm{e} {b}_\mathrm{e} \mathbf{E}   
        -\frac{5}{3}\nabla({D}_\mathrm{e}w_\mathrm{e})\,.\label{eq:QeDDA53}

The improved drift-diffusion approximation (option ``DDAn``) represents a third way of characterising :math:`{\mathbf{\Gamma}}_\mathrm{e}` and  :math:`{\mathbf{Q}}_\mathrm{e}`. 
It was deduced by an expansion of the electron velocity distribution function (EVDF) in Legendre polynomials and the derivation of the first four moment equations from the electron Boltzmann equation (*M. M. Becker, D. Loffhagen, AIP Adv. 3 (2013) 012108*, *M. M. Becker, D. Loffhagen, Adv. Pure Math. 3 (2013) 343*). 
It reads

    .. math::
        \mathbf{\Gamma}_\mathrm{e}
        = -\frac{e_0}{m_\mathrm{e}\nu_\mathrm{e}}\nabla
        \Bigl((\xi_0 + \xi_2)n_\mathrm{e} \Bigr)
        -\frac{e_0}{m_\mathrm{e}\nu_\mathrm{e}} \mathbf{E} n_\mathrm{e}\,, \label{eq:JeDDAn}\\
        %
        \mathbf{Q}_\mathrm{e} = -\frac{e_0}{m_\mathrm{e}\tilde{\nu}_\mathrm{e}}\nabla
        \Bigl((\tilde{\xi}_0 + \tilde{\xi}_2) w_\mathrm{e} \Bigr) \label{eq:QeDDAn}\\
        \qquad\qquad\; -\frac{e_0}{m_\mathrm{e}\tilde{\nu}_\mathrm{e}}\Bigl(\frac{5}{3}
        + \frac{2}{3}\frac{\xi_2}{\xi_0}\Bigr)\mathbf{E} w_\mathrm{e}, \nonumber

and includes the momentum and energy flux dissipation frequencies :math:`\nu_\mathrm{e}` and :math:`\tilde{\nu}_\mathrm{e}`, respectively, the transport coefficients :math:`\xi_0`, :math:`\xi_2`, :math:`\tilde{\xi}_0` and :math:`\tilde{\xi}_2`, as well as electron mass :math:`m_\mathrm{e}`.  
It should be emphasized that this approximation is unique to the MCPlas toolbox, as to our knowledge it is not part of any other modelling tool.
Considering the accuracy improvements relative to the drift–diffusion approximation at low and atmospheric pressures (*M. Baeva, D. Loffhagen, M. M. Becker, D. Uhrlandt Plasma Chem. Plasma Process. 39 (4) (2019) 949–968*), it represents a highly significant feature of the toolbox.


Boundary conditions for the electron density and mean electron energy balance equations are included in MCPlas in accordance with the study given by Hagelaar *et al.* (*G. J. M. Hagelaar, F. J. de Hoog, G. M. W. Kroesen, Phys. Rev. E 62 (1) (2000) 1452*) and read

    .. math::
        \mathbf{\Gamma}_\mathrm{e}\cdot\boldsymbol{\nu}
        = \frac{1-r_\mathrm{e}}{1+r_\mathrm{e}}
        \Bigl(\left|n_\mathrm{e} \mathbf{v}_{\mathrm{d},\mathrm{e}}\cdot\boldsymbol{\nu} \right|
        +\frac{1}{2}n_\mathrm{e} v_{\mathrm{th},\mathrm{e}}\Bigr)
        -\frac{2}{1+r_\mathrm{e}}\gamma\sum_i\max(\mathbf{\Gamma}_i\cdot\boldsymbol{\nu},0)
        \label{eq:boundary_e}\,,\\
        %
        \mathbf{Q}_\mathrm{e}\cdot\boldsymbol{\nu}
        = \frac{1-r_\mathrm{e}}{1+r_\mathrm{e}}
        \Bigl(\left| w_\mathrm{e} \tilde{\mathbf{v}}_{\mathrm{d},\mathrm{e}}\cdot\boldsymbol{\nu} \right|
        +\frac{2}{3} w_\mathrm{e} v_{\mathrm{th},\mathrm{e}} 
        \Bigr) 
        -\frac{2}{1+r_\mathrm{e}}
        \gamma u_\mathrm{e}^\gamma
        \sum_i\max(\mathbf{\Gamma}_i\cdot\boldsymbol{\nu},0)\,,

where :math:`\boldsymbol{\nu}` represents the normal vector pointing toward the plasma boundaries, and :math:`r_\mathrm{e}`, :math:`\gamma`, :math:`u_\mathrm{e}^\gamma` and :math:`\mathbf{\Gamma}_i` denote the electron reflection coefficient, the secondary electron emission coefficient, mean energy of secondary electrons and the ion fluxes at the boundaries, respectively. 
The vector of electron drift velocity :math:`\mathbf{v}_{\mathrm{d},\mathrm{e}}`, the thermal velocity of electron :math:`v_{\mathrm{th},\mathrm{e}}`, and the vector of electron energy drift velocity :math:`\tilde{\mathbf{v}}_{\mathrm{d},\mathrm{e}}` in the case of the conventional drift-diffusion approximation (option ``DDAc``) are defined as

    .. math::
        \mathbf{v}_{\mathrm{d},\mathrm{e}} 
        = -b_\mathrm{e} \mathbf{E}\, ,
        \qquad
        %
        v_{\mathrm{th},\mathrm{e}} 
        = \sqrt{\frac{8 k_\mathrm{B} T_\mathrm{e}}{\pi m_\mathrm{e}}}\, ,
        \qquad
        %
        \tilde{\mathbf{v}}_{\mathrm{d},\mathrm{e}} 
        = -\tilde{b}_\mathrm{e} \mathbf{E}\, ,

while in the case of commonly used drift-diffusion approximation (option ``DDA53``) the vector of electron energy drift velocity :math:`\tilde{\mathbf{v}}_{\mathrm{d},\mathrm{e}}` is equal to :math:`-\frac{5}{3}b_\mathrm{e}\mathbf{E}`. For the improved drift-diffusion approximation (option ``DDAn``), :math:`\mathbf{v}_{\mathrm{d},\mathrm{e}}` and :math:`\tilde{\mathbf{v}}_{\mathrm{d},\mathrm{e}}` are defined differently, taking the expressions
    .. math::
        \mathbf{v}_{\mathrm{d},\mathrm{e}} 
        = -\frac{e_0}{m_\mathrm{e}\nu_\mathrm{e}} \mathbf{E}\, ,
        \qquad
        %\\
        \tilde{\mathbf{v}}_{\mathrm{d},\mathrm{e}} 
        = -\frac{e_0}{m_\mathrm{e}\tilde{\nu}_\mathrm{e}}\Bigl(\frac{5}{3}
        + \frac{2}{3}\frac{\xi_2}{\xi_0}\Bigr) \mathbf{E}\, .
        \qquad

In above relations, :math:`T_\mathrm{e} = 2u_\mathrm{e}/(3k_\mathrm{B})` is the temperature of electrons and :math:`k_\mathrm{B}` is the Boltzmann constant. 

The boundary condition for the balance equation of  heavy particle densities has the following form

    .. math::
        \mathbf{\Gamma}_\mathrm{h}\cdot\boldsymbol{\nu}
        = \frac{1-r_\mathrm{h}}{1+r_\mathrm{h}}
        \Bigl(\left|\mathrm{sgn}(q_\mathrm{h}) 
        n_\mathrm{h} \mathbf{v}_{\mathrm{d},\mathrm{h}}  \cdot\boldsymbol{\nu}\right|
        +\frac{1}{2} n_\mathrm{h} {v}_{\mathrm{th},\mathrm{h}} \Bigr),     
        %       

where the variables and coefficients associated to heavy particles are defined in a manner analogous to that of the electrons. 

For the Poisson equation, the boundary conditions are defined by setting the applied voltage :math:`U_\mathrm{a}` at the powered electrode and zero potential at the grounded electrode.
The accumulation of surface charges is additionally taken into account in the case of dielectric boundaries using the interface condition

    .. math::
        - \varepsilon_\mathrm{r}
        \varepsilon_0
        \mathbf{E} \cdot \boldsymbol{\nu} 
        =
        \sigma.

Here, :math:`\varepsilon_\mathrm{r}` is 1 in the plasma region, while in the dielectric region it has a value characteristic of the considered dielectric. The surface charge density :math:`\sigma` is determined from the charged particle currents coming
onto the dielectric via equation

    .. math::
        \frac{\partial \sigma}{\partial t}
        =
        \sum_{j}q_j
        \mathbf{\Gamma}_j \cdot \boldsymbol{\nu}.

The source terms :math:`S_j` of the electron density balance equations is defined as 

    .. math::
        S_j = \sum_{l=1}^{N_\mathrm{r}} (G_{jl} - L_{jl}) R_l, 
        \label{eq:S_j}\,

where :math:`R_l` is the reaction rate of reaction :math:`l`, given by

    .. math::
        R_l = k_l \prod_{i=1}^{N_\mathrm{s}} n_i^{\beta_{il}}.

Here, :math:`\beta_{il}` and :math:`k_l` denote the partial reaction order of species :math:`i` and the rate coefficient for reaction :math:`l`. :math:`N_\mathrm{r}` represents the number of reactions, while :math:`N_\mathrm{s}` is the number of species considered in the model.
:math:`G_{jl}` and :math:`L_{jl}` are the gain and loss matrix elements, respectively, defined by the stoichiometric coefficients for the given species and reactions. MCPlas automatically generates these matrices from the RKM input data, which facilitates effortless switching between models with different levels of complexity.

The source terms :math:`\tilde{S}_\mathrm{e}` of the electron energy balance equation is defined as 

    .. math::        
        \tilde{S}_\mathrm{e} = \sum_{l=1}^{N_\mathrm{r}} \tilde{R}_l,

where :math:`\tilde{R}_l` is the electron energy rate for reaction :math:`l`, which is usually defined as reaction rate :math:`R_l` multiplied by the net electron energy change (gain or loss) :math:`\Delta\varepsilon_l`. 
In the case where electron energy rate coefficient :math:`\tilde{k}_l` is defined, e.g.\ for elastic collision, :math:`\tilde{R}_l` is determined as :math:`\tilde{k}_l \prod_{i=1}^{N_\mathrm{s}} n_i^{\beta_{il}}`. 
For reactions in which electrons do not participate :math:`\tilde{R}_l` is equal to zero.

To ensure numerical stability and obtain consistent solutions, MCPlas uses some stabilisation techniques. 
One such approach involves the logarithmic transformation of the densities of particle species and the mean electron energy.  
This inherently enforces positivity and suppresses oscillations in regions with steep gradients or low concentrations
The toolbox also implements a source term stabilisation method applicable to all particles and electron energy balance equations, in a similar way to that used in Comsol Plasma Module.
This term is designed to counteract numerical instabilities caused by stiff or nonlinear reactions. 
It acts as a buffer at very low particle number densities, preventing the appearance of negative values, and becomes negligible at higher number densities.

	