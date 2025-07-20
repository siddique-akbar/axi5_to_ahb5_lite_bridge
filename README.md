<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
![GitHub Repo stars](https://img.shields.io/github/stars/siddique-akbar/axi5_to_ahb5_lite_bridge?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/siddique-akbar/axi5_to_ahb5_lite_bridge?style=flat-square)
![GitHub issues](https://img.shields.io/github/issues/siddique-akbar/axi5_to_ahb5_lite_bridge?style=flat-square)
![GitHub license](https://img.shields.io/github/license/siddique-akbar/axi5_to_ahb5_lite_bridge?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/siddique-akbar/axi5_to_ahb5_lite_bridge?style=flat-square)

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge">
    <img src="https://upload.wikimedia.org/wikipedia/commons/e/e5/Gospers_glider_gun.gif" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">AXI5 to AHB lite Synchronous bridge Design in System Verilog</h3>

  <p align="center">
    This project implement AXI5 to AHB lite synchronous bridge Design in System Verilog.
    <br />
    <!-- <a href="https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge">View Demo</a>
    &middot; -->
    <a href="https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
       <a href="#features">Features</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

This repository contains a synthesizable RTL implementation of a synchronous AXI4-to-AHB-Lite bridge, compliant with AMBA AXI4 (slave interface) and AMBA AHB-Lite (master interface) protocols. The bridge is designed to enable interoperability between AXI-based initiators (e.g., high-performance ARM CPUs, DMA engines) and legacy AHB-Lite-based peripherals or subsystems.
<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

<p>
  <img src="https://img.shields.io/badge/SystemVerilog-gray?style=for-the-badge" alt="System Verilog" />
  <img src="(https://img.shields.io/badge/Vivado-gray?style=for-the-badge&logo=xilinx&logoColor=white)
" alt="Xilinx (AMD) Vivado" />
</p>
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- Features -->
## Features
<ul>
  <li>Fully synchronous design with shared <code>ACLK</code> and <code>HCLK</code> domains.</li>
<li>Common asynchronous reset with synchronized deassertion logic.</li>
<li>AXI4 slave interface (compliant with AMBA 5 AXI4 spec).
  <ul>
    <li>Supports burst and single-beat transactions.</li>
    <li>Handles concurrent read and write requests.</li>
    <li>Supports standard AXI protection attributes and lock signals.</li>
  </ul>
</li>
<li>AHB-Lite master interface (compliant with AMBA 5 AHB-Lite).
  <ul>
    <li>Generates AHB single or incrementing burst transfers.</li>
    <li>Maps AXI burst transactions to sequential AHB transfers.</li>
    <li>Maintains protocol timing constraints and data integrity.</li>
  </ul>
</li>
<li>Configurable data width (typically 32 or 64 bits).</li>
<li>Minimal latency and pipelining support.</li>
<li>Designed for integration into SoCs with mixed AXI and AHB buses.</li>



<!-- GETTING STARTED -->
## Getting Started

This is an ongoing project.

### Prerequisites

The only prerequisite is install the <p align="right">(<a href="(https://gcc.gnu.org/install/)">GCC</a>)</p> toolchain.


### Installation


1. Clone the repo
   ```sh
   git clone https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge.git
   ```
3. 
5. Change git remote url to avoid accidental pushes to base project
   ```sh
   git remote set-url --push origin no-push
   git remote -v # confirm the changes
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Use Cases
<p> The bridge is ideal for SOC plateforms where: </p>
<ul>
  <li>AXI-based masters (e.g., Cortex-A CPUs, AXI interconnects) need to communicate with AHB-Lite-based memory-mapped peripherals.
  </li>
  <li>Legacy AHB subsystems must be retained within newer AXI-dominant designs.</li>
  <li>Deterministic timing and simplified integration are preferred over full AHB master arbitration.</li>
</ul>
<!-- _For more examples, please refer to the [Documentation](https://example.com)_ -->

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [ ] Single transaction for all channels of AXI to AHB
- [ ] AXI burst `INCR` mode to AHB for all channels

See the [open issues](https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Top contributors:

<a href="https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=github_username/repo_name" alt="contrib.rocks image" />
</a>



<!-- LICENSE -->
## License

Distributed under the project_license. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
<!-- ## Contact

Siddique Akbar - [@twitter_handle](https://twitter.com/twitter_handle) - email@email_client.com -->

Project Link: [https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge](https://github.com/siddique-akbar/axi5_to_ahb5_lite_bridge)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
<!-- ## Acknowledgments

* []()
* []()
* []()

<p align="right">(<a href="#readme-top">back to top</a>)</p> -->



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
