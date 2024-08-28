# Gardener Simulation Model

## Overview

This NetLogo model simulates the behavior of gardeners in a garden as they harvest and consume leaves. The gardeners interact with the environment by moving around, harvesting leaves, and sharing them with other gardeners. The simulation explores two different rules of movement: **Commoning** and **Segregation**.

## Features

- **Gardeners**: Agents that move around the environment, harvest leaves, and consume them. Gardeners can be in various states, such as happy, hungry, or weak, depending on their possession of leaves.
- **Leaves**: Resources that gardeners harvest. Leaves are periodically created and can change color when they are ready to be harvested.
  - **Commoning**: Gardeners move in a way that encourages clustering and collective resource sharing.
  - **Segregation**: Gardeners move in a way that promotes separation, reducing interaction with others.
- **Happiness and Sharing**: Gardeners' happiness is influenced by their possession of leaves and their proximity to other gardeners. Gardeners can share leaves with others if they encounter hungry gardeners.

## Setup and Usage

### Parameters

- `NofGardeners`: Number of gardeners in the simulation.
- `fdSpeed`: Speed at which gardeners move.
- `Eat`: Rate at which gardeners consume leaves.
- `P1leaves`, `P2leaves`, `P3leaves`: Number of leaves generated in different areas of the garden.
- `Closeness`, `Harvest`, `Close2HungryG`: Radius values that define the range within which gardeners detect leaves or interact with other gardeners.
- `leafgift`: Number of leaves shared when a gardener encounters a hungry gardener.
- `multiple`: Interval for creating new leaves.

### How to Run

1. **Setup**: Press the `setup` button to initialize the environment. This will create gardeners and leaves, set initial conditions, and prepare the environment.
2. **Go**: Press the `go` button to start the simulation. The gardeners will begin moving, harvesting leaves, and interacting with each other according to the selected movement rule.

### Movement Rules

- To switch between **Commoning** and **Segregation**:
  - Set the `rule` variable to `"Commoning"` or `"Segregation"` before running the simulation.
  - The gardeners will adjust their movement patterns accordingly.

### Key Procedures

- `move`: Handles the movement of gardeners according to the selected rule.
- `pluck-leaves-in-commoning` and `pluck-leaves-in-segregation`: Control how gardeners detect and harvest leaves in commoning or segregation movement modes.
- `check-happiness`: Determines the happiness state of gardeners based on their leaf possession and proximity to other gardeners or leaves.
- `check-collision-in-commoning` and `check-collision-in-segregation`: Manage interactions between gardeners, including the sharing of leaves.

## Customization

- **Gardener Behavior**: Modify the `consume-leaves`, `check-possession-status-in-commoning`, and `check-possession-status-in-segregation` procedures to change how gardeners consume leaves and transition between states (e.g., happy, hungry).
- **Environment**: Adjust the `space` procedure to change the layout of the environment, including the distribution of green and brown patches.
- **Leaf Creation**: Modify the `creating-leaves` procedure to change how and where leaves are generated in the environment.

## Visual Output

- The model includes labels that display the number of leaves each gardener possesses.
- The simulation also plots the average time (ticks) it takes for gardeners to harvest leaves over time.

## Contact

For any questions or support, please contact Favour Chizurum Onuoha at dovo.fav@aol.com
