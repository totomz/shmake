# shmake
[![test](https://github.com/totomz/shmake/actions/workflows/test.yml/badge.svg)](https://github.com/totomz/shmake/actions/workflows/test.yml)

Run bash functions as build targets — no Makefile, no NodeJS, just shell.

`shMakefile` give you a simple framework to invoke bash function with arguments, with ready-to-use functions to simplify the test/build/deploy cycle

**WARNING** this is a totally and highly opinionated way to organize the build & CI/CD pipeline, based on my experience.  
It works for me, it could not work for you!

Invoke a build command with an argument
```shell
./shMakefile build --env=prod
```

## Installation
This "tool" is made of 2 scripts: 
* `shMakefile` the main executable script that is invoked;
* `functions.sh` a collections of utilities functions

Just download these scripts in your repo, and you're ready.

one-liner with curl
```shell
curl -fsSL https://raw.githubusercontent.com/totomz/shmake/refs/heads/main/install.sh | sh
```
or with wget:
```shell
wget -qO- https://raw.githubusercontent.com/totomz/shmake/refs/heads/main/install.sh | sh
```

## Usage 
I have 2 founding ideas:

- A codebase should be built ina local environment or in a CI/CD pipeline with exactly the same commands;
- At the end, in most priojects, build&deploy is mainly gluing together some cli tool; 

The goal is to have the build/deploy logic in isolated, invocable bash functions.  

These are 2 simple functions that test and build a monorepo with multiple golang services 
```shell
build() {    
  mustVar service               # required argument
  local arch="${arch:-amd64}"   # optional argument, default "amd64" 
  
  # good engineers test their stuff before compile
  run-test
  time GOOS=linux GOARCH="${arch}" go build -o bin/daje app/main.go
  
}

run-test() {
  mustVar service
  # test the common package
  go vet ./common/...
  go test ./common/...  
  
  # test the service
  go vet ./services/${service}/...
  go test -timeout 180s -count=1 --parallel=6 ./services/${service}/
}
```

Need to run the tests?
```shell

$ ./shMakefile run-test --service=myservice
```

Or build?
```shell
# build for the default architecture
$ ./shMakefile build --service=myservice

# or not
$ ./shMakefile build --service=myservice --arch=arm64
```

Read the contents of `./shMakefile` for more details about:
* monorepo support - create children `shMakfeile` with all your functions separated from the main code
* where to place your custom scripts
* built-in fucntions (there are like 5 funcitons, it won't take too much time)

## built-in utilities functions


## Examples
See the `shMakefile` and an example of a sub-service `./services/bob/shMakefile`
# Faq

## Can I call a function "test"?
TL;DR: **NO**

Long version:
Yes, you can. In bash, functions take precedence over external commands (and non-special builtins).
`test` is not a special builtin (those are: break, continue, eval, exec, exit, export, readonly, return, set, shift, trap, unset),
so it can be overridden without issues.
```shell
test() {
  echo "hello"
}
test  # prints "hello"
```
To call the original test from inside the function, use builtin test or command test (or the absolute path /usr/bin/).

**Practical warning**: overriding `test` is a time bomb because `[` is an alias for test! 
All `if [ ... ]` statements will stop behaving as expected!
