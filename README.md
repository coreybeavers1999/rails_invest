# Rails Invest

Rails Invest is a personal Ruby on Rails and Stimulus project in the early stages of development. It will become a massively multiplayer investment game where players buy and sell shares in a simulated economy.

## Game concept

Companies are influenced by three factors:

- The overall global economy
- The popularity of their industry
- The decisions made by their current CEO

Companies can go bankrupt, so holding a position and waiting for a company to grow is not a guaranteed strategy. If a company fails, players can lose all the money they invested in it.

## Economy simulation

The overall economy and industry popularity are generated with a stacked Perlin noise algorithm. This creates more interesting waves of highs and lows instead of purely random fluctuations.

Simulation values are updated during the nightly reset. The algorithm uses:

- The current date, converted to epoch time, as its input
- A secret environment variable as the base noise seed

Changing the seed environment variable will completely change the simulation's outcome.

## CEOs

CEOs are hired by companies and directly influence their growth or decline while they are in charge. A CEO does not permanently belong to any one company.

Companies can fire CEOs when they cause enough turmoil. Each company has its own threshold for how much downturn it will tolerate before terminating its CEO. Firing a CEO immediately causes a significant negative impact on the company's value, after which the company must select a replacement from the pool of available candidates.

CEOs also have predetermined retirement dates. When a CEO retires, the company must choose another candidate from the pool. New CEOs are added periodically to ensure that there are always more available CEOs than companies.
