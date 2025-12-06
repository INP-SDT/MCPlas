# MCPlas

<div align="center">
<img src="./docs/images/Logo_version_2.jpg" width="250" height="250">
</div>

## Description

MCPlas toolbox represents a collection of MATLAB functions for the automated generation of an equation-based fluid-Poisson model for non-thermal plasmas in the multiphysics simulation software COMSOL. It aims at an easy and fast generation of models for the spatio-temporal modelling based on the input data containing all information about the considered species and reaction kinetic model. Following the development of the [LXCat platform](https://us.lxcat.net/home/news.php), all input data are prepared in a structured and interoperable JSON format and can be supplied and validated using existing JSON schemas. This supports the adoption of the FAIR (Findable, Accessible, Interoperable, Reusable) [data principles](https://www.nature.com/articles/sdata201618) in LTP research as well as the reproducibility of modelling results. A notable advantage of MCPlas over many commercial software packages lies in the transparent and direct access to all MATLAB source files, i.e. the specific model equations and boundary conditions.

## How to use?

[Watch](docs/_build/html/_images/my_video.mp4) a live demonstration of generating a COMSOL model using MCPlas. The demo covers everything from the initial toolbox setup to generating and running the resulting COMSOL file, with detailed steps and explanations throughout.


## Documentation

- ✅ Check the live documentation [here](https://inp-sdt.github.io/MCPlas/).

## Build status

Initial build - version 1.0

## Contributing
Any kind of contribution that would improve the project, whether new feature suggestions, bug reports or providing your own code suggestions, is welcome and encouraged.  Please, try to follow the following guidelines when contributing to the project.

**Bug reports**

Before creating bug reports, please check if somebody already reported the same bug, use a title that clearly describes the issue, provide a detailed description of the bug (including how you use MCPlas, on what machine and operating system) and the minimum working example that illustrates the bug.

**Feature suggestion**

If you have a new feature suggestion, please check if it has already been suggested and then clearly describe the idea behind the new feature you would like to see in the MCPlas.

**Code suggestion**

When contributing new code or modifying the existing, the authors would appreciate it if you would first discuss the changes you wish to make by creating a new issue or sending an e-mail to the authors.

In any case, communicating with the authors will make it easier to incorporate your changes and make the experience smoother for everyone. The authors look forward to your input.

## License

MCPlas is open source code developed under LGPLv3 (GNU Lesser General Public License version 3).

## Acknowledgment

The development of the MCPlas is funded by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation)—project number ..... The authors wish to thank the users of [FEniCS forum](https://fenicsproject.discourse.group) for useful information and discussion. Finally, the authors are grateful to Dr. Peter Hill and Dr. Liam Pattinson of the PlasmaFAIR project for carrying out the health check, and proposing and implementing significant improvements to the code. This support of PlasmaFAIR, funded by EPSRC (grant no. EP/V051822/1), is gratefully acknowledged.

## Citation

## Contact

[marjan.stankov@inp-greifswald.de](mailto:marjan.stankov@inp-greifswald.de)

[markus.becker@inp-greifswald.de](mailto:markus.becker@inp-greifswald.de)
