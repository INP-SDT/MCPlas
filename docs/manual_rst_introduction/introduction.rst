The presented toolbox is developed in MATLAB for the automated build-up of an equation-based fluid-Poisson model in Comsol using linking between Matlab and Comsol provided by the Comsol Live link *for* MATLAB module. 
This Matlab-Comsol toolbox (MCPlas) aims easy and fast generation of models for the spatio-temporal modelling of non-thermal plasmas based on the input data containing all information about considered reaction kinetic model. 
The generated models are ready to be used without Comsol's Plasma Module or any additional Comsol modules. 
Depending on the user's needs, model equations can be solved in either Cartesian, polar or cylindrical coordinates using numerical solvers provided by Comsol.

The plasma description provided by MCPlas is based on the equations of fluid-Poisson model

    .. math::
        \frac{\partial}{\partial t}n_j(\mathbf{r},t)
        + \nabla\cdot\mathbf{\Gamma}_j(\mathbf{r},t) = S_j(\mathbf{r},t),
        \label{eq:continuity}\\
        %
        \frac{\partial}{\partial t}w_\mathrm{e}(\mathbf{r},t) 
        +\nabla\cdot\mathbf{Q}_\mathrm{e}(\mathbf{r},t)
        = -e_0\mathbf{\Gamma}_\mathrm{e}(\mathbf{r},t) \mathbf{E}(\mathbf{r},t) - P(\mathbf{r},t),
        \label{eq:we}\\
        %
        -\nabla \cdot(\varepsilon_\mathrm{r}\varepsilon_0\nabla\phi(\mathbf{r},t))
        = \sum_j q_j n_j(\mathbf{r},t),
        \label{eq:poisson}


where the first and second relations represent balance equations for the particle number densities :math:`n_j` of species of kind :math:`j`
with charge :math:`q_j` and electron energy density :math:`w_\mathrm{e}=n_\mathrm{e}u_\mathrm{e}` with mean electron energy :math:`u_\mathrm{e}`, respectively. 
Third equation is Poisson's equation for the self-consistent determination of the electric potential :math:`\phi` and the electric field :math:`\mathbf{E}(\mathbf{r},t)=-\nabla\phi(\mathbf{r},t)`. 
In the second equation, :math:`e_0` and :math:`P_\mathrm{e}` determine the elementary charge and the loss of electron energy in collision processes and in the third, :math:`\varepsilon_\mathrm{r}` and :math:`\varepsilon_\mathrm{0}` are
the relative and vacuum permittivity.

The fluxes :math:`{\mathbf{\Gamma}}_\mathrm{h}` of heavy particles (:math:`j=\mathrm{h}`) in particel balance equation are expressed by the common drift–diffusion approximation (*Sigeneger, R. Winkler, IEEE Trans. Plasma Sci. 27 (5)
(1999) 1254*, *G. K. Grubert, M. M. Becker, D. Loffhagen, Phys. Rev. E 80 (2009) 036405*}

    .. math::
        \mathbf{\Gamma}_\mathrm{h}(\mathbf{r},t)
        = \mathrm{sgn}(q_\mathrm{h})n_\mathrm{h}(\mathbf{r},t) b_\mathrm{h}(\mathbf{r},t) \mathbf{E}(\mathbf{r},t)   
        -\nabla(D_\mathrm{h}(\mathbf{r},t) n_\mathrm{h}(\mathbf{r},t))
        \,  \label{eq:flux_particle}.
 
Here, :math:`b_\mathrm{h}` and :math:`D_\mathrm{h}` stand for the  mobility and diffusion coefficient of heavy species :math:`\mathrm{h}`, respectively, while the function :math:`\mathrm{sgn}(q_\mathrm{h})` defines the sign of :math:`q_\mathrm{h}`.

A consistent drift-diffusion approximation for the flux :math:`{\mathbf{\Gamma}}_\mathrm{e}` of electron (:math:`j=\mathrm{e}`) and the flux :math:`{\mathbf{Q}}_\mathrm{e}` of the electron energy has been deduced by an expansion of the electron velocity distribution function (EVDF) in Legendre polynomials and the derivation of the first four moment equations from the electron Boltzmann equation (*M. M. Becker, D. Loffhagen, AIP Adv. 3 (2013) 012108*, *M. M. Becker, D. Loffhagen, Adv. Pure Math. 3 (2013) 343*). 
It reads

    .. math::
        \mathbf{\Gamma}_\mathrm{e}(\mathbf{r},t)
        = -\frac{1}{m_\mathrm{e}\nu_\mathrm{e}}\frac{\partial}{\partial z}
        \Bigl((\xi_0 + \xi_2)n_\mathrm{e}(\mathbf{r},t) \Bigr)
        -\frac{e_0}{m_\mathrm{e}\nu_\mathrm{e}} \mathbf{E}(\mathbf{r},t) n_\mathrm{e}(\mathbf{r},t)\,, \label{eq:JeDDAn}\\
        %
        \mathbf{Q}_\mathrm{e}(\mathbf{r},t) = -\frac{1}{m_\mathrm{e}\tilde{\nu}_\mathrm{e}}\frac{\partial}{\partial z}
        \Bigl((\tilde{\xi}_0 + \tilde{\xi}_2) w_\mathrm{e}(\mathbf{r},t) \Bigr) \label{eq:QeDDAn}\\
        \qquad\qquad\; -\frac{e_0}{m_\mathrm{e}\tilde{\nu}_\mathrm{e}}\Bigl(\frac{5}{3}
        + \frac{2}{3}\frac{\xi_2}{\xi_0}\Bigr)\mathbf{E}(\mathbf{r},t) w_\mathrm{e}(\mathbf{r},t), \nonumber


and includes the momentum and energy flux dissipation frequencies :math:`\nu_\mathrm{e}` and :math:`\tilde{\nu}_\mathrm{e}` as well as the transport coefficients :math:`\xi_0`, :math:`\xi_2`, :math:`\tilde{\xi}_0` and :math:`\tilde{\xi}_2`. 
These properties are given as integrals of the isotropic part :math:`f_0` and the first two contributions :math:`f_1` and :math:`f_2` to the anisotropy of the EVDF over the kinetic energy :math:`U` of the electrons with mass :math:`m_\mathrm{e}`, respectively, according to

    .. math::
        \nu_\mathrm{e} = \frac{2}{3m_\mathrm{e}\mathit{\Gamma}_\mathrm{e}}\int\limits_0^\infty 
        \frac{U^{\frac{3}{2}}}{\lambda_\mathrm{e}(U)} f_1(U)\,\mathrm{d}U, \label{eq:nu}\\
        %	
        \tilde{\nu}_\mathrm{e} = \frac{2}{3m_\mathrm{e} Q_\mathrm{e}}\int\limits_0^\infty 
        \frac{U^{\frac{5}{2}}}{\lambda_\mathrm{e}(U)} f_1(U)\,\mathrm{d}U, \label{eq:enu}\\
        %	
        \xi_0 = \frac{2}{3 n_\mathrm{e}}\int\limits_0^\infty 
        U^{\frac{3}{2}} f_0(U)\,\mathrm{d}U\,, \label{eq:transp_first}\\
        %	
        \xi_2 = \frac{4}{15 n_\mathrm{e}}\int\limits_0^\infty 
        U^{\frac{3}{2}} f_2(U)\,\mathrm{d}U,
		\\	
        %	
        \tilde{\xi}_0 = \frac{2}{3 n_\mathrm{e}}\int\limits_0^\infty 
        U^{\frac{5}{2}} f_0(U)\,\mathrm{d}U, \\
        %	
        \tilde{\xi}_2 = \frac{4}{15 n_\mathrm{e}}\int\limits_0^\infty 
        U^{\frac{5}{2}} f_2(U)\,\mathrm{d}U. \label{eq:transp_last}		
		
It is important to note that MCPlas also provides the option to apply a common drift-diffusion approximation for electron transport.

Boundary conditions for the balance equation for electron density and mean electron energy are included in MCPlas in accordance with the study given by Hagelaar *et al.* (*G. J. M. Hagelaar, F. J. de Hoog, G. M. W. Kroesen, Phys. Rev. E 62 (1) (2000) 1452*) and read

    .. math::
        \mathbf{\Gamma}_\mathrm{e}\cdot\boldsymbol{\nu}
        = \frac{1-r_\mathrm{e}}{1+r_\mathrm{e}}
        \Bigl(\left|n_\mathrm{e} \mathbf{v}_{\mathrm{dr},\mathrm{e}} \right|
        +\frac{1}{2}n_\mathrm{e} v_{\mathrm{th},\mathrm{e}}\Bigr)
        -\frac{2}{1+r_\mathrm{e}}\gamma\sum_i\max(\mathbf{\Gamma}_i\cdot\boldsymbol{\nu},0)
        \label{eq:boundary_e}\,,\\
        %
        \mathbf{Q}_\mathrm{e}\cdot\boldsymbol{\nu}
        = \frac{1-r_\mathrm{e}}{1+r_\mathrm{e}}
        \Bigl(\left| n_\mathrm{e} \tilde{\mathbf{v}}_{\mathrm{dr},\mathrm{e}} \right|
        +\frac{1}{2} n_\mathrm{e} \tilde{v}_{\mathrm{th},\mathrm{e}} 
        \Bigr) 
        -\frac{2}{1+r_\mathrm{e}}
        \gamma u_\mathrm{e}^\gamma
        \sum_i\max(\mathbf{\Gamma}_i\cdot\boldsymbol{\nu},0)\,,
        \label{eq:boundary_eps}
		
where :math:`\boldsymbol{\nu}` represents the normal vector pointing toward the plasma boundaries. 
The vector of electron drift velocity :math:`\mathbf{v}_{\mathrm{dr},\mathrm{e}}`, the thermal velocity of electron :math:`v_{\mathrm{th},\mathrm{e}}`, the vector of electron energy drift velocity :math:`\tilde{\mathbf{v}}_{\mathrm{dr},\mathrm{e}}`, and the thermal velocities of electron energy :math:`\tilde{v}_{\mathrm{th}, \mathrm{e}}` are given by

    .. math::
        \mathbf{v}_{\mathrm{dr},\mathrm{e}} 
        = -\frac{e_0}{m_\mathrm{e}\nu_\mathrm{e}} \mathbf{E}(\mathbf{r},t)\,,
        \qquad
        %\\
        v_{\mathrm{th},\mathrm{e}} 
        = \sqrt{\frac{8 k_\mathrm{B} T_\mathrm{e}}{\pi m_\mathrm{e}}}\,,\\
        \tilde{\mathbf{v}}_{\mathrm{dr},\mathrm{e}} 
        = -\frac{e_0u_\mathrm{e}}{m_\mathrm{e}\tilde{\nu}_\mathrm{e}}\Bigl(\frac{5}{3}
        + \frac{2}{3}\frac{\xi_2}{\xi_0}\Bigr) \mathbf{E}(\mathbf{r},t)\,,
        \qquad
        %\\
        \tilde{v}_{\mathrm{th},\mathrm{e}}
        = 2 k_\mathrm{B} T_\mathrm{e}\sqrt{\frac{8 k_\mathrm{B} T_\mathrm{e}}{\pi m_\mathrm{e}}}\,,    

respectively. 
Here, :math:`T_\mathrm{e} = 2u_\mathrm{e}/(3k_\mathrm{B})` is the temperature of electrons and :math:`k_\mathrm{B}` is the Boltzmann constant. 
Also, :math:`r_\mathrm{e}`, :math:`\gamma`, :math:`u_\mathrm{e}^\gamma` and :math:`\mathbf{\Gamma}_i` denote the electron reflection coefficient, the secondary electron emission coefficient,  mean energy of secondary electrons and the ion fluxes at the boundaries, respectively. 
The boundary condition for heavy particles balance equation has the following form

    .. math::
        \mathbf{\Gamma}_\mathrm{h}\cdot\boldsymbol{\nu}
        = \frac{1-r_\mathrm{h}}{1+r_\mathrm{h}}
        \Bigl(\left|\mathrm{sgn}(q_\mathrm{h}) 
        n_\mathrm{h} \mathbf{v}_{\mathrm{dr},\mathrm{h}}  \right|
        +\frac{1}{2} n_\mathrm{h} {v}_{\mathrm{th},\mathrm{h}} \Bigr),     
        \label{eq:boundary_heavy}\\

where variables and coefficients associated with heavy particles are defined in a manner analogous to that of electrons. 
It should be noted that in the case of dielectric boundaries, the accumulation of surface charges is taken into account, as described in Stankov *et al.* (*M. Stankov, M. M. Becker, R. Bansemer, K.-D. Weltmann, D. Loffhagen, Plasma Sources Sci. Technol. 29 (12)
(2020) 125009*).		