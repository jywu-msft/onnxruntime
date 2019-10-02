#!/bin/bash
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

LocalNuGetRepo=$1
SourceRoot=$2
BuildDir=$3
export CurrentOnnxRuntimeVersion=$4
set -x

OldDir=`pwd`
cd $SourceRoot

echo "Current NuGet package version is $CurrentOnnxRuntimeVersion"

if [ $RunTestCsharp = "true" ]; then
  # Run C# tests
  dotnet restore $SourceRoot/csharp/test/Microsoft.ML.OnnxRuntime.EndToEndTests/Microsoft.ML.OnnxRuntime.EndToEndTests.csproj -s $LocalNuGetRepo -s https://api.nuget.org/v3/index.json
  if [ $? -ne 0 ]; then
    echo "Failed to restore nuget packages for the test project"
    exit 1
  fi

  dotnet test $SourceRoot/csharp/test/Microsoft.ML.OnnxRuntime.EndToEndTests/Microsoft.ML.OnnxRuntime.EndToEndTests.csproj --no-restore --verbosity detailed
  if [ $? -ne 0 ]; then
    echo "Failed to build or execute the end-to-end test"
    exit 1
  fi
fi

if [ $RunTestNative = "true" ]; then
  # Run Native shared object test
  # PackageName is passed in environment (e.g. Microsoft.ML.OnnxRuntime)
  PackageName="$PackageName.$CurrentOnnxRuntimeVersion.nupkg"
  cd $LocalNuGetRepo
  TempDir=_tmp
  mkdir -p $TempDir && pushd $TempDir
  unzip ../$PackageName
  libs="-L runtimes/linux-x86/native -L runtimes/linux-x64/native -l onnxruntime"
  inc="-I build/native/include"
  g++ -std=c++14 $SourceRoot/csharp/test/Microsoft.ML.OnnxRuntime.EndToEndTests.Capi/C_Api_Sample.cpp $inc $libs -Wunused-result -o sampletest

  # Create link to versioned shared object required at runtime
  libname=`ldd sampletest | grep onnxruntime | xargs | cut -d" " -f1`
  ln -sf runtimes/linux-x64/native/libonnxruntime.so $libname

  # Copy Sample Model
  cp $SourceRoot/csharp/testdata/squeezenet.onnx .

  # Run the sample model
  ./sampletest
  popd
  rm -rf $TempDir
fi
cd $OldDir

