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

- `TotalGardeners`: Number of gardeners in the simulation.
- `Velocity`: Speed at which gardeners move.
- `Consumption`: Rate at which gardeners consume leaves.
- `Area1`, `Area2`, `Area3`: Number of leaves generated in different garden areas.
- `Dictection`, `Harvest`, `Proximity`: Radius values defining the range in which gardeners detect leaves or interact with other gardeners.
- `Gift`: Number of leaves shared when a gardener encounters a hungry gardener.
- `Interval`: Mutiple for creating new leaves.

### How to Run

1. **Setup**: Press the `setup` button to initialize the environment. This will create gardeners and leaves, set initial conditions, and prepare the environment.
2. **Go**: Press the `go` button to start the simulation. The gardeners will begin moving, harvesting leaves, and interacting with each other according to the selected movement rule.

### Movement Rules

- To switch between **Commoning** and **Segregation**:
  - Set the `rule` variable to `"Commoning"` or `"Segregation"` before running the simulation.
  - The gardeners will adjust their movement patterns accordingly.

## Weather Effects in the Simulation
The code snippet defines two procedures, apply-weather-effects-in-com and apply-weather-effects-in-seg, to simulate the impact of different weather conditions on the behavior of two types of agents: leaves and gardeners. The weather conditions considered include "neutral", "sunny", "rainy", and "stormy". Each condition affects the agents differently in terms of movement, appearance, and resource management.

### 1. apply-weather-effects-in-com
This procedure applies weather effects in the "com" mode of the simulation. The weather conditions influence the following agent behaviors:

Neutral Weather:

Gardeners move at their normal speed (Velocity).
Gardeners with leaves in their possession change color to 21 (a specific color code).
Gardeners without leaves turn red.
Sunny Weather:

Leaves have an interval of 2.
Gardeners with leaves move at their normal speed and change color to 21.
Gardeners without leaves turn red.
Gardeners are assigned additional attributes: Gift is set to 10, consumption to 1, and shareTime to 30.
Rainy Weather:

Leaves have an interval of 3.
Gardeners move slower due to wet conditions, with their velocity halved (Velocity / 2).
Gardeners with leaves change color to black, while those without leaves remain red.
Gardeners have reduced Gift (set to 8), lower consumption (set to 0.8), and increased shareTime (set to 40).
Stormy Weather:

Leaves have an interval of 4.
Gardeners move much slower, with their velocity reduced to one-tenth of the normal (Velocity / 10).
Gardeners with leaves change color to violet, while those without leaves remain red.
Gardeners experience further reduced Gift (set to 5), consumption (set to 0.5), and a longer shareTime (set to 60).

### 2. apply-weather-effects-in-seg
This procedure applies weather effects in the "seg" mode, which includes additional agent movement constraints within bounded areas. The agent behaviors under different weather conditions are as follows:

Sunny Weather:

Leaves have an interval of 2.
Gardeners move within the specified bounds while avoiding walls.
Gardeners with leaves move at their normal speed and change color to 21.
Gardeners without leaves turn red.
Gardeners have Gift set to 10, consumption to 1, and shareTime to 30.
Rainy Weather (if leaves are in possession):

Leaves have an interval of 3.
Gardeners move within the specified bounds and slower due to wet conditions, with their velocity halved (Velocity / 2).
Gardeners with leaves change color to black, while those without leaves remain red.
Gardeners have Gift set to 8, consumption to 0.8, and shareTime to 40.
Stormy Weather (if leaves are in possession):

Leaves have an interval of 4.
Gardeners move within the specified bounds and much slower, with their velocity reduced to one-tenth of the normal (Velocity / 10).
Gardeners with leaves change color to violet, while those without leaves remain red.
Gardeners have Gift set to 5, consumption to 0.5, and shareTime to 60.

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





# FEW MORE SCENARIOS AND IMPLEMENTATION... THE UNKNOWNS 😎

### 1. **Weather Impact Scenario**
   - **Scenario**: Introduce weather conditions that affect the availability of leaves and the movement speed of gardeners. For example, rain could decrease the number of leaves generated or slow down the gardeners, while sunshine could increase leaf growth and speed up the gardeners.
   - **Implementation**: Add a global variable for weather, and create conditions that alter leaf growth rates (`creating-leaves`) and gardener speed (`move`).

### 2. **Disease Spread Among Gardeners**
   - **Scenario**: Simulate the spread of a disease that affects the gardeners. Diseased gardeners could have reduced movement speed and a higher rate of leaf consumption. The disease could spread when gardeners collide.
   - **Implementation**: Introduce a variable for health status. When two gardeners collide, there's a chance the disease spreads. Diseased gardeners have different behaviors like reduced speed and increased leaf consumption.

### 3. **Introduction of Pests**
   - **Scenario**: Introduce pests that consume leaves before the gardeners can harvest them. Pests could move randomly and reduce the leaf count in their vicinity.
   - **Implementation**: Create a new breed for pests that move randomly and interact with leaves by reducing their count or turning them brown (indicating they are unusable).

### 4. **Cooperation vs. Competition**
   - **Scenario**: Introduce two types of gardeners—those who cooperate by sharing leaves when they collide and those who compete by taking leaves from each other. The overall happiness and survival rate could be compared between these two strategies.
   - **Implementation**: Add a breed or variable for gardener type (cooperative or competitive). Modify the collision handling (`check-collision-in-com` and `check-collision-in-seg`) to reflect cooperative or competitive behavior.

### 5. **Seasonal Changes**
   - **Scenario**: Implement seasonal changes that affect the growth rate of leaves and the behavior of gardeners. For example, in autumn, more leaves could be generated, but in winter, the gardeners consume leaves faster to stay warm.
   - **Implementation**: Introduce a seasonal cycle that changes the parameters for leaf growth and gardener behavior periodically (e.g., every 100 ticks).

### 6. **Resource Scarcity and Migration**
   - **Scenario**: Create a scenario where leaves become scarcer over time in certain areas, forcing gardeners to migrate to more fertile areas.
   - **Implementation**: Modify the `creating-leaves` procedure to reduce leaf generation in certain areas over time. Add logic for gardeners to move towards areas with more leaves (`check-radius-in-com` and `check-radius-in-seg`).

### 7. **Introduction of Hierarchies**
   - **Scenario**: Introduce a hierarchical system among gardeners where some gardeners are leaders who can influence the behavior of others (e.g., directing them to abundant leaf areas).
   - **Implementation**: Assign a leadership role to some gardeners with a variable, and have other gardeners follow their direction or mimic their behavior when within a certain radius.

### 8. **Pollution Impact**
   - **Scenario**: Introduce pollution that affects the health of gardeners and the quality of leaves. Polluted leaves might not provide as much sustenance, causing gardeners to consume more.
   - **Implementation**: Add a pollution variable that influences leaf quality and gardener health. Polluted areas could generate leaves that are less effective at increasing leaf possession.

### 9. **External Predators**
   - **Scenario**: Introduce predators that target gardeners. When a gardener is caught, they lose a significant portion of their leaves, affecting their happiness and survival.
   - **Implementation**: Create a new breed for predators that move towards gardeners and reduce their leaves-possession on collision.

### 10. **Social Influence**
   - **Scenario**: Simulate social influence where gardeners' behavior changes based on the behavior of neighboring gardeners. For example, if many gardeners around are hoarding leaves, others might start hoarding as well.
   - **Implementation**: Introduce a variable for social conformity and adjust gardener behavior based on the average behavior of neighboring gardeners.

These scenarios can help explore different dynamics and interactions in your model, providing deeper insights into the behaviors and outcomes of the gardener-leaf ecosystem.
