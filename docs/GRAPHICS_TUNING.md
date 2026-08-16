# Graphics & 3D Viewport Performance Tuning

Autodesk Inventor uses the **OGS (One Graphics System)** rendering engine, which builds on Direct3D 11.

---

## 1. DXVK Pipeline

By default, Wine's `wined3d` (OpenGL translation) fails to present swapchains into child window MDI viewports, resulting in a blank viewport. 

**DXVK** translates Direct3D 11 to Vulkan, resolving blank canvases and enabling native hardware acceleration.

### Tuning Options (`dxvk.conf`):
- `dxgi.syncInterval = 0`: Disables VSync tearing delay inside CAD canvases.
- `dxvk.enableAsync = true`: Enables asynchronous shader compilation to avoid stutters while rotating or rendering complex assemblies.
- `d3d11.cachedDynamicBuffers = true`: Caches dynamic vertex buffers frequently modified during 2D sketch manipulation.

---

## 2. In-App Hardware Settings

Inside Autodesk Inventor:
1. Navigate to **Tools** → **Application Options** → **Hardware** tab.
2. Under **Graphics Setting**:
   - **Quality**: Full Direct3D 11 effects with ambient occlusion, reflections, and realistic shadows.
   - **Performance**: High frame rate mode with optimized geometry batching (recommended for integrated GPUs).
   - **Conservative**: Strict D3D11 feature-level fallback for maximum stability.
   - **Software Graphics**: CPU rasterization fallback.

---

## 3. GPU Vendor Optimizations

### Intel Graphics (Iris Xe / Arc)
- Set `MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE=1`.
- Ensure `mesa-vulkan-drivers` or `intel-media-driver` is up-to-date.

### AMD Radeon (RADV)
- Mesa RADV provides out-of-the-box Vulkan support with optimal async compute performance.

### NVIDIA (Proprietary Driver)
- Ensure the proprietary NVIDIA driver (`nvidia-driver` / `kmod-nvidia`) and `nvidia-vulkan-icd` are active.
- `export __NV_PRIME_RENDER_OFFLOAD=1` and `export __GLX_VENDOR_LIBRARY_NAME=nvidia` on hybrid laptops.
