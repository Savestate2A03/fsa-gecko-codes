# 0x8013ff10

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

.set GREEN_LINK,  0
.set RED_LINK,    1
.set BLUE_LINK,   2
.set PURPLE_LINK, 3

################################################################################

start:
backupFull

### check if B is held
li r3, 0x0200
li r4, RED_LINK
bl isButtonsPressed
cmplwi r3, 0
beq exitEarly

### get link coordinates and set dummy float data
li r3, GREEN_LINK
bl writePlayerCoords

# set up __SpawnActor params r3-r9
#   r3:  bigstruct
#   r4:  544B524D
#   r5:  00000000
#   r6:  pointer to init coords?
#   r7:  00000000
#   r8:  ffffffff
#   r9:  ffffffff (which link? 0-3)

### r3 - pointer to bigstruct
load r3, 0x8053154C
lwz r3, 0(r3)
lwz r3, 0x18(r3)

### r4 - TKRM
load r4, 0x544B524D

### r5
li r5, 0x0000

### r6 - pointer to init coords
bl float_data
mflr r6

### r7
li r7, 0x0000

### r8
load r8, 0xFFFFFFFF

### r9
load r9, 0xFFFFFFFF

# __SpawnActor 801feff4
branchl r20, 0x801feff4


exitEarly:

restoreFull
blr

################################################################################

# getLink
# r3 player, 0-3
# returns pointer to Link in r3

getLink:
backup

# get pointers to link
load r20, 0x80531948
lwz r20, 0x0000(r20)

addi r20, r20, 0x0004

# offset by 0,4,8,c
mulli r21, r3, 0x0004

# add offset
add r20, r20, r21

lwz r3, 0x0(r20)

restore
blr

################################################################################

# writePlayerCoords
# r3 player, 0-3
# sets dummy float data

writePlayerCoords:
backup

bl float_data
mflr r20

bl getLink

# copy to dummy float data
lwz r21, 0x0008(r3)
stw r21, 0x0000(r20)

lwz r21, 0x000c(r3)
stw r21, 0x0004(r20)

lwz r21, 0x0010(r3)
stw r21, 0x0008(r20)

restore
blr

################################################################################

# isButtonsPressed
# r3 is button bit mask
# r4 is controller number (0-3)
# returns 1 if any of selected buttons are pressed

# 0x00000001 L
# 0x00000002 R
# 0x00000004 D
# 0x00000008 U
# 0x00000020 Shoulder R
# 0x00000040 Shoulder L
# 0x00000100 A
# 0x00000200 B
# 0x00000400 Select
# 0x00001000 Start

isButtonsPressed:
backup

load r20, 0x808E4894

# offset by 0,4,8,c
mulli r21, r4, 0x0004
add r20, r20, r21
lwz r21, 0x0000(r20)

# and
and r21, r21, r3

li r3, 0x0
cmplwi r21, 0
beq isButtonsPressedFalse

isButtonsPressedTrue:
li r3, 0x1
isButtonsPressedFalse:
restore
blr

################################################################################

# lr contains pointer to dummy float data
float_data:
blrl 
.float 5.000 # x
.float 5.000 # z
.float 0.000 # y

# idk
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000

####