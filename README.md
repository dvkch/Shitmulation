<img src="README-AppIcon.png" width=64 />

# Shitmulation

### Computation time

#### M1 Pro, 8 cores, 7 threads, 16GB, Release

| Parameters                 | Trees | Distributing | Mem usage  | File usage | Sorting  | Counting uniques |  Total  |
|----------------------------|-------|--------------|------------|------------|----------|------------------|---------|
|   1 million, <br/>42 trees |  1.6s |    0.2s      |    16MB    |     16MB   |   0.1s   |       0.1s       |   2.5s  |
|  10 millions,<br/>42 trees |  1.6s |    2.0s      |   160MB    |    160MB   |   0.5s   |       0.7s       |   3.7s  |
| 100 millions,<br/>42 trees |  1.6s |    8.7s      | 160MB / th |    1.6GB   |   1.3s   |       4.0s       |    19s  |
|   1 billion, <br/>42 trees |  1.6s |     60s      | 160MB / th |   16.0GB   |    24s   |  41s  (2s/Trait) |   130s  |
|  10 billions,<br/>42 trees |  1.6s |    454s      | 160MB / th |  160.0GB   |  ~350s   | 408s (16s/Trait) |  1350s  |

#### Ubuntu x64, 2 vCPU, 2 threads, 4GB, Release

| Parameters                 | Trees | Distributing | Mem usage  | File usage | Sorting  | Counting uniques |  Total  |
|----------------------------|-------|--------------|------------|------------|----------|------------------|---------|
|   1 million, <br/>42 trees |   13s |      1s      |    16MB    |     16MB   |   0.3s   |       0.3s       |    14s  |
|  10 millions,<br/>42 trees |   13s |      5s      |   160MB    |    160MB   |   0.7s   |       3.3s       |    23s  |
| 100 millions,<br/>42 trees |   13s |     52s      | 160MB / th |    1.6GB   |     7s   |        36s       |   108s  |
|   1 billion, <br/>42 trees |   13s |    527s      | 160MB / th |   16.0GB   |    93s   |       563s       |  1190s  |

#### Notes

- 160MB/thread is to hold a full slice of population, strata of 10 000 000 people. for brief moments, we need twice this, to dispatch in the proper population files.
- 160GB file size is cumulative. individual file sizes are around 160GB/256, but in reality some of there are around 3GB and others are way smaller (few MB)

### Results

cf [Results](./Results)

### Linux

```
# https://www.swiftlang.xyz/
curl -s https://archive.swiftlang.xyz/install.sh | sudo bash
sudo apt install swiftlang

# https://github.com/pelotoncycle/bsort
sudo apt install autoconf make build-essential
git clone https://github.com/pelotoncycle/bsort.git
cd bsort
autoreconf --install
./configure
make
sudo make install

./Shitmulation
```

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
