.ifndef HEADER_FSA

################################################################################
# Macros
################################################################################

.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro loadwz reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
lwz \reg, 0(\reg)
.endm

.macro loadbz reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
lbz \reg, 0(\reg)
.endm

.macro loadf regf,reg,address
lis \reg, \address @h
ori \reg, \reg, \address @l
stw \reg,-0x4(sp)
lfs \regf,-0x4(sp)
.endm

# make space for r3-r31
# also backs up r0
.macro backupFull
mflr r0
stw r0, 0x4(r1)
stwu r1,-0x78(r1)	
stmw r3,0x8(r1)
.endm

# release the space
.macro restoreFull
lmw r3,0x8(r1)
lwz r0, 0x7c(r1)
addi r1,r1,0x78
mtlr r0
.endm

# make space for 12 registers
# makes r20 - r31 available for use
.macro backup
mflr r0
stw r0, 0x4(r1)
stwu r1,-0x50(r1)	
stmw r20,0x8(r1)
.endm

# release the space
.macro restore
lmw r20,0x8(r1)
lwz r0, 0x54(r1)
addi r1,r1,0x50
mtlr r0
.endm

################################################################################
# Static Function and Data Locations
################################################################################

.set FN_EXAMPLE, 0x80001234
.set FN_SpawnActor, 0x801feff4

.set DATA_LinkTable, 0x80531948
.set DATA_Controllers, 0x808E4894
.set DATA_HeapInfo, 0x80531948

################################################################################
# Const and Enum Definitions
################################################################################

# Link Color to Number
.set ENUM_Green,  0
.set ENUM_Red,    1
.set ENUM_Blue,   2
.set ENUM_Purple, 3

.set CONST_LinkCount, 4

# Strict and Nonstrict
.set CONST_Nonstrict, 0
.set CONST_Strict,    1

# Offsets
.set CONST_HeapOffset, 0x63B4
.set CONST_PushX, 0x02D0
.set CONST_PushZ, 0x02D4

.set CONST_ActorAllocatedByte, 0x11C
.set CONST_ActorType, 0x1A0
.set CONST_ActorX, 0xC
.set CONST_ActorZ, 0x10
.set CONST_ActorY, 0x14
.set CONST_ActorTKRM, 0x544B524D

# Buttons
.set BTN_Left,   0x0001
.set BTN_Right,  0x0002
.set BTN_Down,   0x0004
.set BTN_Up,     0x0008
.set BTN_R,      0x0020
.set BTN_L,      0x0040
.set BTN_A,      0x0100
.set BTN_B,      0x0200
.set BTN_Select, 0x0400
.set BTN_Start,  0x1000

################################################################################

.endif
.set HEADER_FSA, 1
