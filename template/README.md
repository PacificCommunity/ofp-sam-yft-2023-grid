## 14a_Five_Regions

This model started from a basic .ini file with decent starting values, close to
the diagnostic MLE values for M and growth parameters, up to 2 significant
digits. The resulting fit, `10.par`, was not a great fit for the diagnostic
model, but it's a starting point that may work well across the grid, after
jittering.

## 14c_M_Growth_Phase_Eleven

This model started from an .ini fil with M and growth parameters at the
diagnostic MLE values and then estimated them in the last phase 11. The
resulting fit, `11.par`, was the best fit for the diagnostic model, so it may
work well across the grid, after jittering.

This is a rendition of the diagnostic model that fits the data very well (best
objective function) and results in a PDH for the diagnostic model configuration.
It is equivalent to first running `14x_Fixed_M_Growth_MLE` (phases 1-10) and
then `14y_Extra_M_Growth` (phase 11).
