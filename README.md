<img src="README-AppIcon.png" width=64 />

# Shitmulation

### Computation time (on M1 Pro, 16GB, Release)

| Parameters             | Trees | Distributing | Mem usage  | File usage | Sorting             | Counting uniques |  Total  |
|------------------------|-------|--------------|------------|------------|---------------------|------------------|---------|
|   1 million,  42 trees |  1.6s |    0.2s      |    16MB    |     16MB   |   0.1s              |       0.1s       |   2.5s  |
|  10 millions, 42 trees |  1.6s |    2.0s      |   160MB    |    160MB   |   0.5s              |       0.7s       |   3.7s  |
| 100 millions, 42 trees |  1.6s |    6.4s      | 160MB / th |    1.6GB   |   6.0s              |       2.8s       |    16s  |
|   1 billion,  42 trees |  1.6s |     51s      | 160MB / th |   16.0GB   |  120s +  151s (6GB) |  32s  (2s/Trait) |  ~340s  |
|  10 billions, 42 trees |  1.6s |    474s      | 160MB / th |  160.0GB   | 1200s + 1800s (8GB) | 268s (16s/Trait) | ~3900s  |

### Results

cf [Results](./Results)

### Possible optimisations 

- walk the traits _byte by byte_ first, and then compare bit by bit inside those 8-traits segmentation
- bisect the population while comparing the traits, and filter through smaller files instead. it has been abandonned for now because it would required dividing the original population file into two files, which requires twice the space. If we ever go that route again :
        
    ```
    // Mean values for trait # where the pop is divided 50/50 unique
    //  10k => 15
    // 100k => 19
    //   1m => 22
    //  10m => 25
    let bisectionIndex = 4 + (Int(Darwin.log(Double(population)) / Darwin.log(Double(10)))) * 3
    ```

- sort on smaller amount of bits first, then again on the full thing ? parallelize sorting ?
