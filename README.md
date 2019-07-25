# 2D CFAR

-   Determine the number of Training cells for each dimension. Similarly, pick the number of guard cells.
-   Slide the cell under test across the complete matrix. Make sure the CUT has margin for Training and Guard cells from the edges.
-   For every iteration sum the signal level within all the training cells. To sum convert the value from logarithmic to linear using db2pow function.
-   Average the summed values for all of the training cells used. After averaging convert it back to logarithmic using pow2db.
-   Further add the offset to it to determine the threshold.
-   Next, compare the signal under CUT against this threshold.
-   If the CUT level > threshold assign it a value of 1, else equate it to 0.

Trainig range cell count is 10.
Trainig dopler cell count is 8.
Guard range cell count is 4.
Guard dopler cell count is 4.
Offset is 10.
