# EasyGrad
Easy Gradient code generation from Julia functions / expression. 

Extremly fast gradient code can be achieved. Literally 0 allocation at forward and backward propagation. Close to 100x speedup can be achieved or even more in special cases compared to Zygote. (But of course there are compilation time that has to be considered.) 

The package isn't ready, so if you like the idea, don't hesitate to continue the work! 
Motto: ALWAYS the simplest and easiest the better! "Perfection is achieved when there is nothing left be take away!" Gradient computation is easy we just made it complicated. :D


We didn't have time to implement:
- fields are ignored from gradient computing.
- kw args not really supported in function calls -> use normal call in these cases

For a high speed we made some decision we don't support...
- for should be sort of fixed... so: for i in 1:10 for j in 1:i .... isn't a good idea... preallocation with j won't work... (use if continue instead)

You have to be aware, some solution has downside
- Mutability can be expensive: Reassign causes memory allocation, mainly in for cycle it can be really big! Watch out for that!

TODO:
- break
- continue
- enumerate for iterator name generation fix: __i, __j, __k, __l, __m, __n, __o

LONG term:
- In for assignment banned. Only function performation, += and -= is allowed atm.
- y .*= sum(a); y  errors -> use: x = sum(a); y .*= x; y

Very LONG term:
- autopreallocation and then referencing... -> zero alloc with pulling out allocation memory from function.
- Parallelize the computational graph...
- AST usage instead of graph gen...
- ChainRules.jl support for sum, prod, linalg... functions... 

### Lot of thing is working... the hard part I would say is ready, we already could use it in some cases. :D 
But there is 200 hours work left to clean and finish everything to be easily used by everyone.
