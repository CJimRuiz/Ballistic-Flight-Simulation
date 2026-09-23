# Ballistic Flight Simulation

A numerical simulation modeling the flight trajectory and aerodynamics of a ballistic projectile.

## Overview
This project simulates projectile dynamics taking into account gravitational force, aerodynamic drag, and atmospheric conditions. It evaluates state variables over time using numerical integration to predict trajectory, range, velocity, and apogee.

## Features
- **Trajectory Modeling**: Computes 2D/3D flight paths from launch to impact.
- **Aerodynamic Drag**: Implements standard drag models based on velocity and air density.
- **State Estimation**: Tracks position, velocity, and acceleration across discrete time steps.
- **Visualization**: Generates trajectory plots and flight telemetry curves.

## Governing Equations & Dynamics
- **Gravitational Acceleration**: Constant or altitude-dependent gravity ($g$).
- **Aerodynamic Drag**:
  $$F_d = \frac{1}{2} \rho v^2 C_d A$$
- **Integration**: Solved using numerical integration methods (e.g., Euler, Runge-Kutta 4th Order).

## Getting Started

### Prerequisites
- Python 3.8+ (or MATLAB / C++)
- Required libraries:
  ```bash
  pip install numpy matplotlib scipy
