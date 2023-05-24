<img src="README-AppIcon.png" width=64 />

# Shitmulation

### Computation time (on M1 Pro, 16GB)

| Kind                             | Trees | Distributing | Sorting | Counting uniques | File size/memory usage |
|----------------------------------|-------|--------------|---------|------------------|------------------------|
| In memory,  1 million , 25 trees |  0.5s |      5s      |   N/A   |     12s total    |          213MB         |
| In memory, 10 millions, 25 trees |  0.5s |     51s      |   N/A   |    158s total    |         2.18GB         |
| File,      10 millions, 25 trees |  0.5s |     51s      |    9s   |    ~2s / trait   |         1.21GB         |
| File,     100 millions, 25 trees |  0.5s |    510s      |   90s   |   ~20s / trait   |         12.1GB         |

### Notes on manual file processing

```bash
# generate population file, then:

# LC_ALL=C compares bytes directly and not lexicographically, 10s of times faster
LC_ALL=C gsort people.txt > people_sorted.txt

# couting
for i in (seq 1 120); 
  echo "Trait $i";
  guniq -w $i -u people_sorted.txt | count -l;
end
```

### Possible optimisations 

- pack traits into bits
- walk the traits _byte by byte_ first, and then compare bit by bit inside those 8-traits segmentation
- bisect the population while comparing the traits
- execute by chunks -> generate only a part of the population (possible using pickABranch())
