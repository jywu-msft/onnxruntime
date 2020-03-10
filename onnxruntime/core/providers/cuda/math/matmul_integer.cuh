// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "matmul_integer.h"
#include "core/providers/cpu/math/matmul_helper.h"
#include "core/providers/cuda/cuda_common.h"
#include "core/providers/cuda/shared_inc/cuda_utils.h"

namespace onnxruntime {
namespace cuda {

Status ReduceRowSumOnMatrixA(const int8_t* matrix, int32_t* row_sum, const int8_t offset, const MatMulComputeHelper& helper);
Status ReduceColSumOnMatrixB(const int8_t* matrix, int32_t* col_sum, const int8_t offset, const MatMulComputeHelper& helper);
Status OffsetOutput(const int32_t* row_sum,
                    const int32_t* col_sum,
                    int32_t* output,
                    const int8_t a_offset,
                    const int8_t b_offset,
                    const MatMulComputeHelper& helper);

Status PadMatrixInLeadingDimension(const int8_t* src, int8_t* dst, int64_t row, int64_t col, int64_t pad_size);

}  // namespace cuda
}  // namespace onnxruntime
