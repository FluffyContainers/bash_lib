# Add to the project as the submodule
```
git submodule add https://github.com/FluffyContainers/bash_lib.git lib
```

# Clone repository with submodules
```
git clone --recursive  ......
```

# Pull submodules for cloned repo with submodules
```
git submodule update --init --recursive
```

# Update submodules to most recent version
```
git submodule update --remote --merge
```