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


# Include options
- `# include: module1,module2` — list of modules to inject.
- `# opts: binary` — (optional) embed modules as compressed base64+gzip blobs with an `eval` loader. Good when you need compact, harder-to-tamper inserts. Omit to keep plain text modules.

Options are read from the line immediately after `# include:`.

# Dependency resolution
- Modules can declare their own includes inside the module file (e.g., `# include: colors,tput`).
- `update_includes.sh` will resolve dependencies recursively and include each module only once.
- Dependent modules are marked with `(dependency)` in the generated block.

# Function Documentation Standard (MANDATORY)
**All functions in module files MUST be documented using this exact format.**

- Any comment lines immediately above a function definition are captured as that function's docs.
- Format inside module files (order matters):
	```
	# function_name [optional_arg1] [optional_arg2] required_arg1 required_arg2
	# One-line or multi-line description
    #
	#     arg1       - explanation of arg1 (if needed)
	#     arg2       - explanation of arg2 (if needed)
    #
	# Inputs: ... (optional, if function uses $1-$X input variables, it is permanent)
	# Results: ... (optional)
	my_func(){
		...
	}
	```
- Example for the format: 
  ```
    # __run [-t "command caption" [-s] [-f "echo_func_name"]] [-a] [-o] [--stream] [--sudo] command
    # Execute command with tracking it's status
    #
    #    -t       - instead of command itself, show the specified text
    #    -s       - if provided, command itself would be hidden from the output
    #    -f       - if provided, output of function would be displayed in title
    #    -a       - attach mode, command would be execute in curent context
    #    -o       - always show output of the command
    #    --stream - read application line-per-line and proxy output to stdout. In contrary to "-a", output are wrapped. 
    #    --sudo   - trying to exeute command under elevated permissions, when required. Forcing "-a" mode for sudo password input
    # 
    # Samples:
    #   _test(){
    #     echo "lol" 
    #   }
    #
    #   __run -s -t "Updating" -f "_test" update_dirs
  ```
- When emitted (plain or binary), these docs appear as `# ...` comment lines above the module block.

# Defining new functions in modules
- Place the module code between `# [start]` and `# [end]` markers.
- Add any `# include:` dependencies near the top of the module to ensure they are resolved.
- Add doc comments immediately before each function (see “Docs extraction rules”).
- Run `./update_includes.sh` to propagate changes into target scripts.



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