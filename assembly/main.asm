################################################################################
# Address: 0x8013ff10
################################################################################

.include "assembly/common/common.s"

################################################################################

################################################################################
# Function: FN_Main
# Inject @ 8013ff10
# ------------------------------------------------------------------------------
# Description: Main inject logic loop
# ------------------------------------------------------------------------------
################################################################################


FN_Main:
backupFull

bl FN_PushVisualizer

restoreFull
blr

# FN_Main
################################################################################



################################################################################
# Function: FN_PushVisualizer
# ------------------------------------------------------------------------------
# Description: Visualizes push mechanics with a graphic
# ------------------------------------------------------------------------------
################################################################################

FN_PushVisualizer:
backup

### check each pointer and see if push visualizer is allocated
li r21, 0
bl FNDATA_PushVisualizer_ActorPointers
mflr r22

LBL_PushVisualizer_PointerLoop:

# get pointer
mulli r23, r21, 0x0004
add r23, r23, r22
lwz r29, 0(r23)

# null check
cmpwi r29, 0
beq LBL_PushVisualizer_Allocate

# check if X is now deallocated
lbz r24, CONST_ActorAllocatedByte(r29)
cmpwi r24, 0
beq LBL_PushVisualizer_Allocate

# check if TKRM
lwz r24, CONST_ActorType(r29)
load r25, 0x544B524D
cmpw r24, r25
bne LBL_PushVisualizer_Allocate

LBL_PushVisualizer_PointerLoopNext:
addi r21, r21, 1
cmpwi r21, CONST_LinkCount
beq LBL_PushVisualizer_UpdateCoordinates
b LBL_PushVisualizer_PointerLoop

LBL_PushVisualizer_Allocate:

### get link coordinates and set float data
bl FNDATA_PushVisualizer_Floats
mflr r4
addi r3, r21, 0x0000
bl FN_WritePlayerCoords

### Set up function call to spawn actor
bl FN_GetActorHeap       # r3 - Pointer to Actor Heap
load r4, 0x544B524D      # r4 - TKRM (x marks the spot)
li r5, 0x0000            # r5 - ?
bl FNDATA_PushVisualizer_Floats
mflr r6                  # r6 - Float Data
li r7, 0x0000            # r7 - Actor Parameters
load r8, 0xFFFFFFFF      # r8 - ?
load r9, 0xFFFFFFFF      # r9 - ? (Attach Link ?)

branchl r20, FN_SpawnActor

addi r4, r4, -0x60
stw r4, 0(r23)

b LBL_PushVisualizer_PointerLoopNext

LBL_PushVisualizer_UpdateCoordinates:

### update each X
li r21, 0

LBL_PushVisualizer_UpdateLoop:

# get pointer
mulli r23, r21, 0x0004
add r23, r23, r22
lwz r29, 0(r23)

### X logic start
# r21 - current link
# r29 - pointer to X data

# UNCOMMENT LATER
# addi r3, r21, 0
# bl FN_IsPlayerBeingPushed
# cmpwi r3, 0
# beq LBL_PushVisualizer_UpdateLoopNotPushed

addi r3, r21, 0
bl FN_GetLink

addi r24, r3, CONST_LinkX
addi r25, r3, CONST_LinkPushX
addi r26, r29, CONST_ActorCoords

addi r3, r24, 0
addi r4, r25, 0
addi r5, r26, 0

bl FN_AddXZY

### X logic end

LBL_PushVisualizer_UpdateLoopNotPushed:

addi r21, r21, 1
cmpwi r21, CONST_LinkCount
bne LBL_PushVisualizer_UpdateLoop

FN_PushVisualizerExit:

restore
blr

# FN_PushVisualizer
################################################################################

FNDATA_PushVisualizer_Floats:
blrl 

.float 1.000 # x
.float 2.000 # z
.float 3.000 # y

FNDATA_PushVisualizer_ActorPointers:
blrl 

.word 0x00000000 # Green
.word 0x00000000 # Red
.word 0x00000000 # Blue
.word 0x00000000 # Purple
.word 0x00000000 # Green
.word 0x00000000 # Red
.word 0x00000000 # Blue
.word 0x00000000 # Purple

# FNDATA_PushVisualizer
################################################################################



################################################################################
# Function: FN_GetLink
#-------------------------------------------------------------------------------
# Inputs:
# r3 - Link index, valid values 0-3
#-------------------------------------------------------------------------------
# Outputs:
# r3 - Pointer to the desired Link
#-------------------------------------------------------------------------------
# Description:
# Returns a pointer to a desired Link.
#-------------------------------------------------------------------------------

FN_GetLink:
backup

# get pointer to link table
loadwz r20, DATA_LinkTable

addi r20, r20, 0x0004
mulli r21, r3, 0x0004
add r20, r20, r21
lwz r3, 0x0(r20)

restore
blr

# FN_GetLink
################################################################################



################################################################################
# Function: FN_WritePlayerCoords
#-------------------------------------------------------------------------------
# Inputs:
# r3 - Link index, valid values 0-3
# r4 - Write location to copy player coordinates
#-------------------------------------------------------------------------------
# Description:
# Writes player coordinates to a desired location
#-------------------------------------------------------------------------------

FN_WritePlayerCoords:
backup

mr r20, r4

bl FN_GetLink

# copy position data to destination

#--- X
lwz r21, 0x0008(r3)
stw r21, 0x0000(r20)
#--- Z
lwz r21, 0x000c(r3)
stw r21, 0x0004(r20)
#--- Y
lwz r21, 0x0010(r3)
stw r21, 0x0008(r20)

restore
blr

# FN_WritePlayerCoords
################################################################################



################################################################################
# Function: FN_ButtonPressed
#-------------------------------------------------------------------------------
# Inputs:
# r3 - Button bit mask
# r4 - Controller number (0-3)
# r5 - Strict? (0 = no, non-zero = yes)
#-------------------------------------------------------------------------------
# Outputs:
# r3 - Boolean true/false if button(s) are pressed
#-------------------------------------------------------------------------------
# Description:
# Checks if a button or buttons are pressed. 
#
# When using strict, it will make sure the bitmask matches exactly the
# current buttons pressed. When using non-strict, it will check to see
# if ANY of the bitmask buttons are pressed.
#-------------------------------------------------------------------------------

FN_ButtonPressed:
backup

load r20, DATA_Controllers

# put controller data into r21
mulli r21, r4, 0x0004
add r20, r20, r21
lwz r21, 0x0000(r20)

cmplwi r5, 0
beq LBL_ButtonPressed__Nonstrict

LBL_ButtonPressed__Strict:
cmplw r21, r3
beq LBL_ButtonPressed__True
b LBL_ButtonPressed__False

LBL_ButtonPressed__Nonstrict:
and r21, r21, r3
cmplwi r21, 0
beq LBL_ButtonPressed__False

LBL_ButtonPressed__True:
li r3, 0x1
b LBL_ButtonPressed__Exit

LBL_ButtonPressed__False:
li r3, 0x0

LBL_ButtonPressed__Exit:
restore
blr

# FN_ButtonPressed
################################################################################



################################################################################
# Function: FN_GetActorHeap
#-------------------------------------------------------------------------------
# Outputs:
# r3 - Address to actor heap
#-------------------------------------------------------------------------------

FN_GetActorHeap:

loadwz r3, DATA_HeapInfo
addi r3, r3, CONST_HeapOffset

blr

# FN_GetActorHeap
################################################################################



################################################################################
# Function: FN_IsPlayerBeingPushed
#-------------------------------------------------------------------------------
# Inputs:
# r3 - Link index, valid values 0-3
#-------------------------------------------------------------------------------
# Outputs:
# r3 - Boolean true/false
#-------------------------------------------------------------------------------
# Description:
# Checks if a player's X or Z push values are non-zero.
#-------------------------------------------------------------------------------

FN_IsPlayerBeingPushed:

bl FN_GetLink

lwz r4, CONST_LinkPushX(r3)
cmpwi r4, 0
bne LBL_IsPlayerBeingPushedTrue

lwz r4, CONST_LinkPushZ(r3)
cmpwi r4, 0
bne LBL_IsPlayerBeingPushedTrue

li r3, 0
blr

LBL_IsPlayerBeingPushedTrue:

li r3, 1
blr

# FN_IsPlayerBeingPushed
################################################################################



################################################################################
# Function: FN_AddXZY
#-------------------------------------------------------------------------------
# Inputs:
# r3 - pointer to 3 floats of data
# r4 - pointer to 3 floats of data
# r5 - pointer to destination
#-------------------------------------------------------------------------------
# Description:
# Adds X+X, Z+Z, and Y+Y and stores them consecutively at r5
#-------------------------------------------------------------------------------

FN_AddXZY:

lfs f0, 0x0000(r3)
lfs f1, 0x0000(r4)
fadds f2, f0, f1
stfs f2, 0x0000(r5)

lfs f0, 0x0004(r3)
lfs f1, 0x0004(r4)
fadds f2, f0, f1
stfs f2, 0x0004(r5)

lfs f0, 0x0008(r3)
lfs f1, 0x0008(r4)
fadds f2, f0, f1
stfs f2, 0x0008(r5)

blr

# FN_AddXZY
################################################################################