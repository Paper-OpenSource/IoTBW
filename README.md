# IoTBW

**Sensitivity-Aware Bit-Width Optimization for Energy-Efficient Fixed-Point Hardware in Edge Computing**

Research artifact accompanying our submission to the *IEEE Internet of Things Journal*. This repository provides MATLAB implementations for bit-width optimization and VHDL RTL hardware designs for evaluating IoTBW against state-of-the-art methods on a shared fixed-point matrix multiply--accumulate (MAC) datapath.

## Overview

- **Software** — Sensitivity-aware dynamic bit-width allocation based on range profiling, reverse-mode sensitivity analysis, Lagrangian relaxation and cost-aware integer rounding.
- **Hardware** — Fixed-point `matrix_mul` RTL with method-specific operand bit-widths, together with Xilinx constraint files targeting the Zynq UltraScale+ MPSoC ZU15EG platform.

## Requirements

| Component | Tool |
|-----------|------|
| Software | MATLAB (Symbolic Math Toolbox recommended for `vpasolve`) |
| Hardware | Xilinx Vivado 2024.2 |
| Target Device | Xilinx Zynq UltraScale+ MPSoC ZU15EG (`xczu15eg-ffvb1156-2-i`) |

## Repository Layout

```
IoTBW-main/
├── README.md          # Repository overview, setup instructions, and usage guide
├── LICENSE            # License information
├── Hardware/          # VHDL RTL and XDC constraint files
│   ├── IoTBW_HW/      # Proposed IoTBW bit-width allocation
│   ├── AA_HW/         # Enhanced AA baseline
│   ├── DC_HW/         # Divide-and-Conquer baseline
│   ├── UFB_HW/        # UFB baseline
│   └── TABU_HW/       # Tabu Search baseline
└── Software/
    ├── matrix ploy/   # Single-instance matrix-polynomial optimizer
    └── batch ploy/    # Batch-aware polynomial optimizer
```

Each `*_HW/` folder contains:

- `mul.vhd` — Pipelined `matrix_mul` datapath
- `matrix_top.vhd` — Structural top wrapper
- `matrix_mul_tb.vhd` — Behavioral testbench

Matching `*_XDC/xdc.xdc` files provide the corresponding constraints. To reproduce the results, create a Vivado project and add the selected `*_HW` RTL sources together with their matching `*_XDC` constraint files.

## Quick Start

### Software — Matrix Polynomial Demo

```matlab
cd('Software/matrix ploy')
run_demo_matrix_poly
```

Build benchmark → estimate exponents → compute sensitivities → solve continuous widths → round to integers → report cost and error.

### Software — Batch Polynomial Demo

```matlab
cd('Software/batch ploy')
run_demo_matrix_poly
```

Multi-batch profiling → per-batch Lagrangian solve → cross-batch aggregation → integer projection → summary.

### Hardware — Synthesis and Post-Implementation

1. Create a new Vivado project targeting the ZU15EG device.
2. Add all `.vhd` files from one selected `*_HW/` folder, such as `IoTBW_HW/`.
3. Add the matching `xdc.xdc` constraint file from the corresponding `*_XDC/` folder.
4. Set `matrix_mul` as the synthesis top module and run RTL synthesis.
5. After synthesis completes successfully, run Vivado implementation, including placement and routing.
6. Report resource utilization, timing, and power results from the post-implementation reports.
7. Set `matrix_mul_tb` as the simulation top and run behavioral simulation to verify functional correctness.

## Method Comparison (Hardware)

| Folder | Method |
|--------|--------|
| `IoTBW_HW` | Proposed IoTBW |
| `AA_HW` | Enhanced Affine Arithmetic |
| `DC_HW` | Divide-and-Conquer |
| `UFB_HW` | Uniform Fixed Bit-Width |
| `TABU_HW` | Tabu Search |

RTL structure is identical across variants. Operand and internal bit widths differ per optimization result.

## Citation

If you use this code in your research, please cite our paper (bibtex to be added upon publication).

## License

MIT License — see [LICENSE](LICENSE).

## Contact

xmmeng2-c@my.cityu.edu.hk
