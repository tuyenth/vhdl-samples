li r15, 42
lui r15, 0
li r01, 1
lui r01, 0
add r02, r00, r00
lui r03, upper8(A)
li r03, lower8(A)
A: add r02, r02, r01
bne r03, r02, r15
store r15, r15
