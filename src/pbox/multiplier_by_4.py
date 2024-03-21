import numpy as np
n=8
sgn=1
s=[]
l=[0,0,0,0,0,0,0,0]
a=[0,0,1,0,0,0,1,1]
b=[0,0,0,1,0,0,1,0]
        
for i in range(n):
        s.append([0,0,0,0,0,0,0,0])
c=0

for i in range(n):
    for j in range(n):
        if (((j==n-1) or (i==n-1)) and not((j==n-1) and (i==n-1))):
            print("a")
            s[i][j] = (a[j]*b[i])
            
        elif (((j==(3*n/4)-1) or (i==(3*n/4)-1)) and not(((j==(3*n/4)-1) and (i==(3*n/4)-1))) and ((j>=(n/2)) or (i>=(n/2)))):
            s[i][j] = ((a[j]*b[i])^sgn)
            print("b")
            
        elif (((j==(n/4)-1) or (i==(n/4)-1)) and not(((j==(n/4)-1) and (i==(n/4)-1))) and ((j<(n/4)) or (i<(n/4)))):
            s[i][j] = ((a[j]*b[i])^sgn)
            print("c")
            
        elif (((i<(n/4)) and (j>=(n/4))) or ((i>=(n/4)) and (j<(n/4)))):
            s[i][j] = ((a[j]*b[i])&(not(sgn)))
            print("d")
        else:
            s[i][j] = (a[j]*b[i])
            print("e")
        #for k in range(n):
        #    print(s[i])
        #print("\n")
        c=c+1
x=[0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0]

for i in range(n):
    for j in range(i+1):
        s[i].append(0)
        
