#!/bin/bash

DIR="$1"
## note double bracket syntax:
if [[ -z "$DIR" ]]
then
    echo "Please set \$DIR"
    exit 1
else
    rm -rf $DIR
fi

#check if directory exists
if [ -d "$DIR" ];
then
    echo "$DIR directory exists."
    exit 1
else
    echo "Creating project $DIR"
fi

mkdir -p $DIR
cd $DIR
touch main.cpp
cat > main.cpp <<EOF
#include <iostream>

int main(int argc, char **argv)
{
    std::cout << "Hello world" << std::endl;
}
EOF

touch .gitignore
cat > .gitignore <<EOF
**/build
EOF

touch CMakeLists.txt
cat > CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.0.0)
project(${DIR} CXX)

set(CMAKE_CXX_STANDARD 11)

add_executable(\${CMAKE_PROJECT_NAME} main.cpp)
EOF
mkdir -p .vscode
cd .vscode
touch launch.json
cat > launch.json <<EOF
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Build and debug",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${workspaceFolder}/build/$DIR",
      "args": [],
      "stopAtEntry": false,
      "cwd": "\${workspaceFolder}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "build",
      "miDebuggerPath": "/usr/bin/gdb"
    }
  ]
}
EOF
touch tasks.json
cat > tasks.json <<EOF
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "configure",
            "type": "shell",
            "group": "none",
            "command": "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug -S . -B build"
        },
        {
            "label": "build",
            "type": "shell",
            "group": "build",
            "dependsOn": "configure",
            "command": "cmake --build build -j \$(nproc)"
        },
        {
            "label": "clean",
            "type": "shell",
            "group": "build",
            "command": "rm -rf build"
        },
        {
            "label": "rebuild",
            "type": "shell",
            "group": "build",
            "dependsOrder":"sequence",
            "dependsOn":[
                "clean",
                "build"
            ]
        }
    ]
}
EOF
