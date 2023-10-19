# YFT 2023 Grid

Download YFT 2023 assessment report:

- **Stock assessment of yellowfin tuna in the western and central Pacific Ocean: 2023**\
  **[WCPFC-SC19-2023/SA-WP-04](https://meetings.wcpfc.int/node/19352)**

Download YFT 2023 diagnostic model:

- Clone the **[yft-2023-diagnostic](https://github.com/PacificCommunity/ofp-sam-yft-2023-diagnostic)** repository or download as **[main.zip](https://github.com/PacificCommunity/ofp-sam-yft-2023-diagnostic/archive/refs/heads/main.zip)** file

Download YFT 2023 grid results:

- The **[yft-2023-grid](https://github.com/PacificCommunity/ofp-sam-yft-2023-grid)** repository includes a **[yft-2023-grid-results.zip](https://github.com/PacificCommunity/ofp-sam-yft-2023-grid/releases/download/file/yft-2023-grid-results.zip)** file

## Grid of ensemble models

The YFT 2023 assessment used a structural uncertainty grid with 54 models:

Axis                | Levels | Option
------------------- | ------ | -----------------------------------
Tag mixing          |      2 | 1, 2* quarters
Size data weighting |      3 | Sample sizes divided by 10, 20*, 40
Age data weighting  |      3 | 0.5, 0.75*, 1
Steepness           |      3 | 0.65, 0.80*, 0.95

## Grid results

The [yft-2023-grid-results.zip](https://github.com/PacificCommunity/ofp-sam-yft-2023-grid/releases/download/file/yft-2023-grid-results.zip) file contains all files necessary to run or browse the YFT 2023 grid models.

The grid models are run from a par file, as described in the corresponding `doitall.sh` script. This starting par file is the best of 20 jittered par files from the pre-grid analysis.

The final par and rep files are consistently named `final.par` and `plot-final.par.rep` to facilitate harvesting results from across the 54 grid member models.

Preview of zip file contents:

```
yft-2023-grid-results.zip
├── bin
│   └── mfclo64
└── grid
    ├── m1_s10_a050_h65
    │   ├── 13.par
    │   ├── 14.par
    │   ├── dohessian_standalone.sh
    │   ├── doitall.sh
    │   ├── final.par
    │   ├── mfcl.cfg
    │   ├── neigenvalues
    │   ├── plot-final.par.rep
    │   ├── test_plot_output
    │   ├── xinit.rpt
    │   ├── yft.age_length
    │   ├── yft.frq
    │   ├── yft_hess_inv_diag
    │   ├── yft_pos_hess_cor
    │   ├── yft.tag
    │   └── yft.var
    ├── m1_s10_a050_h80
    │   ├── ...
```

## Incorporating structural and estimation uncertainty

The [estimation_uncertainty.R](notes/estimation_uncertainty.R) script uses Monte Carlo simulations to add estimation uncertainty to the structural uncertainty grid estimates of reference points. The resulting means and quantiles are found in [estimation_uncertainty.csv](notes/estimation_uncertainty.csv).

See also Section 6.2.3 and Table 5 in the YFT 2023 stock assessment [report](https://meetings.wcpfc.int/node/19352).

```
install_github("flr/FLCore")
install_github("PacificCommunity/FLR4MFCL")
```
