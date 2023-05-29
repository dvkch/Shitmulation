<img src="README-AppIcon.png" width=64 />

# Shitmulation

### Computation time (on M1 Pro, 16GB)

| Parameters             | Trees | Distributing | Mem usage  | File usage | Sorting    | Counting uniques |
|------------------------|-------|--------------|------------|------------|------------|------------------|
|   1 million,  42 trees |  1.6s |    0.2s      |    16MB    |     16MB   |  0.1s      |       0.3s       |
|  10 millions, 42 trees |  1.6s |    2.0s      |   160MB    |    160MB   |  0.5s      |       1.9s       |
| 100 millions, 42 trees |  1.6s |    6.4s      | 160MB / th |    1.6GB   |  5.4s      |      21.0s       |
|   1 billion,  42 trees |  1.6s |     51s      | 160MB / th |   16.0GB   | 501s (6GB) |     23s/trait    |

### Results

cf <./Results>

### Possible optimisations 

- walk the traits _byte by byte_ first, and then compare bit by bit inside those 8-traits segmentation
- bisect the population while comparing the traits
- sort on smaller amount of bits first, then again on the full thing ?
