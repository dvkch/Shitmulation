<img src="README-AppIcon.png" width=64 />

# Shitmulation

### Computation time (on M1 Pro, 16GB, Release)

| Parameters             | Trees | Distributing | Mem usage  | File usage | Sorting     | Counting uniques |  Total  |
|------------------------|-------|--------------|------------|------------|-------------|------------------|---------|
|   1 million,  42 trees |  1.6s |    0.2s      |    16MB    |     16MB   |   0.1s      |       0.1s       |   2.5s  |
|  10 millions, 42 trees |  1.6s |    2.0s      |   160MB    |    160MB   |   0.5s      |       0.7s       |   3.7s  |
| 100 millions, 42 trees |  1.6s |    6.4s      | 160MB / th |    1.6GB   |   5.4s      |       6.0s       |    20s  |
|   1 billion,  42 trees |  1.6s |     51s      | 160MB / th |   16.0GB   |  500s (6GB) |  44s  (4s/Trait) |  ~590s  |
|  10 billions, 42 trees |  1.6s |    474s      | 160MB / th |  160.0GB   | 6363s (8GB) | 601s (41s/Trait) | ~7475s  |

### Results

cf <./Results>

### Possible optimisations 

- walk the traits _byte by byte_ first, and then compare bit by bit inside those 8-traits segmentation
- bisect the population while comparing the traits, and filter through smaller files instead
- sort on smaller amount of bits first, then again on the full thing ? parallelize sorting ?
