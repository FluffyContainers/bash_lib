# Introduction
When working with a lot of code, there are alwas a need to keep some reusable service functions in a separate files and include them each time to the base script, same as provide them as separate files and make sure that all dependencies are present. 

While it is a normal way of how it should be, there's a need to provide some scripts as an single file. In such scenarios - keeping all reusable logic updated and in sync become a hassle.

With this lib we trying to solve the problem and keep reusable logic in separate modules, while source script files could be updated dynmically. 

# Quickstart 
### 1. Add to the project as the submodule in the root folder
```
git submodule add https://github.com/FluffyContainers/bash_lib.git lib
```

### 2. Symlink update script at project root folder
```
ln -s ./lib/update_includes.sh  ./update_includes.sh
```

### 3. Add template folder
In the template folder, where the module injectino would be needed: 
- add empty file with name `.replace`
- to initialy inject modules into source code, at the desired line in the file add "# [template]"


### 4. Add custom modules
 In the custom modules folder create empty file ".module". Example, on how to create modules could be checked in a existing global modules provided.

### 5. Inject modules to source files.
 Execute `update_includes.sh` from the project root lcation. Files would be initialized or updated.



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