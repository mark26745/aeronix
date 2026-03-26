{
  lib,
  buildRosPackage,
  fetchFromGitHub,
  ament-cmake,
  rosidl-default-generators,
  rosidl-default-runtime,
  builtin-interfaces,
}:

buildRosPackage {
  pname = "px4-msgs";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "PX4";
    repo = "px4_msgs";
    rev = "release/1.15";
    sha256 = "sha256-2NUCZ4NtfDF6w2d7kS8RQc9dDMcRd7SNfJku8wxgRto=";
  };

  buildType = "ament_cmake";

  nativeBuildInputs = [
    ament-cmake
    rosidl-default-generators
    builtin-interfaces
  ];

  propagatedBuildInputs = [
    rosidl-default-runtime
    builtin-interfaces
  ];

  meta = {
    description = "ROS 2 messages for PX4 Autopilot";
    license = "BSD-3-Clause";
  };
}
