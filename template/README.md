The `14a_Five_Regions` model starts from a basic .ini file with decent starting
values, close to the MLE values for M and growth parameters, up to 2 significant
digits. This general model is a workhorse that can be applied across the grid.
We do not expect good convergence until after jittering, so the final grid
member will chosen from jittered models, based on the best total objective
function value.
