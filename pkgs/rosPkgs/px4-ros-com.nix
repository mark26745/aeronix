{
  lib,
  buildRosPackage,
  fetchFromGitHub,
  ament-cmake,
  rclcpp,
  rclpy,
  px4-msgs,
  eigen,
  eigen3-cmake-module,
  geometry-msgs,
  sensor-msgs,
  rosidl-default-runtime,
}:

buildRosPackage {
  pname = "px4-ros-com";
  version = "1.15.0-unstable"; # "unstable" is standard Nix-speak for a specific git commit

  src = fetchFromGitHub {
    owner = "PX4";
    repo = "px4_ros_com";
    rev = "release/1.15";
    sha256 = "sha256-5Nt9i+7sr4DsYIU5p/1zdxYdKGo8RxZ8iC5PPCcGDBY=";
  };

  buildType = "ament_cmake";

  nativeBuildInputs = [
    ament-cmake
    eigen3-cmake-module
  ];

  propagatedBuildInputs = [
    rclcpp
    rclpy
    px4-msgs
    eigen
    geometry-msgs
    sensor-msgs
    rosidl-default-runtime
  ];

  # This is a common fix needed for px4_ros_com because it
  # sometimes struggles to find Eigen headers in Nix
  cmakeFlags = [
    "-DEIGEN3_INCLUDE_DIR=${eigen}/include/eigen3"
  ];

  meta = {
    description = "PX4 ROS 2 communication bridge helpers";
    license = "BSD-3-Clause";
  };
}
