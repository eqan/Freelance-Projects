The X values will always be natural numbers starting from 1.

A point has an X,Y coordinate.

In order to use the trapezoidal rule to find the area under the curve created by points (normal case),
 you must have at least two connected points.

For continuous points, the area is determined as normal.
For piecewise points, the area is the sum of the individual areas of connected points.

---How to handle the logic when there are not two points?---
1) For missing points (unknown Y value for the point), the area will be taken as 0. Please see the requirement.

(X,Y) = (1, 2) (2, 3) (3,Y) --- The third point is missing

2) For isolated points (Unknown Y value of the previous point and the following point), the area
 will be taken as 0. Please see the requirement.

(X,Y) = (1, 2) (2, Y) (3,3) --- The first point is isolated between it cannot connect with the missing point
 with X-value 2 and the previous value cannot exist because X-value 0 is not a natural number.

(X,Y) = (1, 2) (2, 4) (3,Y) (4,1) (5,Y) --- The third point and the fifth point are missing,
 so the fourth point is isolated. It cannot connect to a point behind it or in front of it.