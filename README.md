<img src="README-AppIcon.png" width=64 />

# Shitmulation

### Computation time (on M1 Pro, 16GB)

| Parameters             | Trees | Distributing | Mem usage  | Sorting    | Counting uniques | File usage |
|------------------------|-------|--------------|------------|------------|------------------|------------|
|   1 million,  42 trees |  1.6s |    0.2s      |    16MB    |  0.1s      |       0.3s       |     16MB   |
|  10 millions, 42 trees |  1.6s |    2.0s      |   160MB    |  0.5s      |       3.4s       |    160MB   |
| 100 millions, 42 trees |  1.6s |    6.4s      | 160MB / th |  5.4s      |      46.6s       |    1.6GB   |
|   1 billion,  42 trees |  1.6s |     51s      | 160MB / th | 501s (6GB) |                  |   16.0GB   |

### Results

cf <./Results>

### Possible optimisations 

- walk the traits _byte by byte_ first, and then compare bit by bit inside those 8-traits segmentation
- bisect the population while comparing the traits
- sort on smaller amount of bits first, then again on the full thing ?
