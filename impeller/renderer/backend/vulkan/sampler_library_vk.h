// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_IMPELLER_RENDERER_BACKEND_VULKAN_SAMPLER_LIBRARY_VK_H_
#define FLUTTER_IMPELLER_RENDERER_BACKEND_VULKAN_SAMPLER_LIBRARY_VK_H_

#include "impeller/base/backend_cast.h"
#include "impeller/core/sampler_descriptor.h"
#include "impeller/renderer/backend/vulkan/device_holder.h"
#include "impeller/renderer/sampler_library.h"

namespace impeller {

class SamplerLibraryVK final
    : public SamplerLibrary,
      public BackendCast<SamplerLibraryVK, SamplerLibrary> {
 public:
  // |SamplerLibrary|
  ~SamplerLibraryVK() override;

 private:
  friend class ContextVK;

  std::weak_ptr<DeviceHolder> device_holder_;
  SamplerMap samplers_;

  explicit SamplerLibraryVK(const std::weak_ptr<DeviceHolder>& device_holder);

  // |SamplerLibrary|
  std::shared_ptr<const Sampler> GetSampler(
      SamplerDescriptor descriptor) override;

  SamplerLibraryVK(const SamplerLibraryVK&) = delete;

  SamplerLibraryVK& operator=(const SamplerLibraryVK&) = delete;
};

}  // namespace impeller

#endif  // FLUTTER_IMPELLER_RENDERER_BACKEND_VULKAN_SAMPLER_LIBRARY_VK_H_
