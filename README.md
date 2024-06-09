Known issues:

1) No exceptions are handled in division i.e. division by zero, zero divided by number and etc.

2) Multiplication with zero is not handled.

3) Subtraction is still being developed.

4) Addition is not fully tested.

5) All of the algorithms are slower compared to built-in GCC library's floating-point arithmetic.


To be able to use these functions, one must declare following function prototypes so that compiler won't typecast the arguments to default.
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
1) float float_div(float a, float b);
2) float float_mul(float a, float b);
3) float float_add(float a, float b);
4) float float_sub(float a, float b);
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>