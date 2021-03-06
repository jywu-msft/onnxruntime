// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "core/framework/onnx_object.h"
#include "core/session/onnxruntime_cxx_api.h"
#include <gtest/gtest.h>

#ifdef _WIN32
typedef const wchar_t* PATH_TYPE;
#define TSTR(X) L##X
#else
#define TSTR(X) (X)
typedef const char* PATH_TYPE;
#endif

//empty
static inline void ONNXRUNTIME_API_STATUSCALL MyLoggingFunction(void*, ONNXRuntimeLoggingLevel, const char*, const char*, const char*, const char*) {
}
template <bool use_customer_logger>
class CApiTestImpl : public ::testing::Test {
 protected:
  ONNXRuntimeEnv* env = nullptr;

  void SetUp() override {
    if (use_customer_logger) {
      ONNXRUNTIME_THROW_ON_ERROR(ONNXRuntimeInitializeWithCustomLogger(MyLoggingFunction, nullptr, ONNXRUNTIME_LOGGING_LEVEL_kINFO, "Default", &env));
    } else {
      ONNXRUNTIME_THROW_ON_ERROR(ONNXRuntimeInitialize(ONNXRUNTIME_LOGGING_LEVEL_kINFO, "Default", &env));
    }
  }

  void TearDown() override {
    if (env) ONNXRuntimeReleaseObject(env);
  }

  // Objects declared here can be used by all tests in the test case for Foo.
};

typedef CApiTestImpl<false> CApiTest;
