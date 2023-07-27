## 14a_Five_Regions

This model starts from a basic .ini file with decent starting values, close to
the diagnostic MLE values for M and growth parameters, up to 2 significant
digits. This general model is a workhorse that can be applied across the grid.
We do not expect good convergence until after jittering, so the final grid
member will chosen from jittered models, based on the best total objective
function value.

## 14c_M_Growth_Phase_Eleven

This model starts from an .ini fil with M and growth parameters at the
diagnostic MLE values and estimates them in the last phase 11. This is a
rendition of the diagnostic model that fits the data very well (best objective
function) model and results in a PDH for the diagnostic model configuration.

This model is equivalent to first running `14x_Fixed_M_Growth_MLE` (phases 1-10)
and then `14y_Extra_M_Growth` (phase 11).
