# AeroNix
**A pure, multi-distro Nix SDK for ROS 2 and Drone Simulation.**

AeroNix provides a declarative foundation for drone development. It eliminates "it works on my machine" issues by pinning dependencies like **FastDDS**, **MAVLink**, and **ROS 2** into immutable Nix flakes.

---

## Key Features

* **Multi-Distro Support**: Switch between `Humble`, `Jazzy`, and `Rolling` effortlessly.
* **Flattened Dependencies**: Access custom-patched builds of `FastDDS`, `FastCDR`, and `Micro-XRCE-DDS` as top-level packages.
* **Graphics Compatibility**: Integrated `nixGL` support for running **Rviz2** and **Gazebo** on non-NixOS systems (Ubuntu, Fedora, etc.).
* **SDK Architecture**: Exported `lib` functions allow child flakes to extend the environment with custom ROS nodes.

---

## Quick Start

### 1. Initialize a new project
Use the built-in template to bootstrap a new repository in seconds:

```bash
mkdir my-drone-app && cd my-drone-app
nix flake init -t github:mark26745/AeroNix
nix develop
```


### 2. Run specific ROS environments
AeroNix provides pre-configured shells for different ROS 2 distributions:

```bash
# Launch a ROS 2 Humble shell (Default)
nix develop github:mark26745/AeroNix

# Launch a ROS 2 Jazzy shell
nix develop github:mark26745/AeroNix#jazzy

# Launch a ROS 2 Rolling shell
nix develop github:mark26745/AeroNix#rolling
```

### 3. Available packages and shells
You can build or run individual tools directly from the flake. Use nix flake show to see the full list of enumerated tools.

```bash
nix flake show github:mark26745/AeroNix
```
