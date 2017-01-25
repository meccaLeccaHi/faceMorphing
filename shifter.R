shifter <- function(x, n = 1) 
{  # shift each element to the Nth index (neg=rightward,pos=leftward)
  if (n == 0) x else c(tail(x, -n), head(x, n))
}
