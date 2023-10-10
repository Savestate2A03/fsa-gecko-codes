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

### check if B is held
li r3, BTN_B
li r4, ENUM_Red
li r5, CONST_Strict
bl FN_ButtonPressed
cmplwi r3, 0
beq FN_PushVisualizerExit

### get link coordinates and set dummy float data
bl FNDATA_PushVisualizer
mflr r4
li r3, ENUM_Green
bl FN_WritePlayerCoords

### Set up function call to spawn actor
bl FN_GetActorHeap  # r3 - Pointer to Actor Heap
load r4, 0x544B524D # r4 - TKRM (x marks the spot)
li r5, 0x0000       # r5 - ?
bl FNDATA_PushVisualizer
mflr r6             # r6 - Float Data
li r7, 0x0000       # r7 - Actor Parameters
load r8, 0xFFFFFFFF # r8 - ?
load r9, 0xFFFFFFFF # r9 - ? (Attach Link ?)

branchl r20, FN_SpawnActor

FN_PushVisualizerExit:

restore
blr

# FN_PushVisualizer
################################################################################

FNDATA_PushVisualizer:
blrl 

# Green
.float 1.000 # x
.float 2.000 # z
.float 3.000 # y

# Red
.float 1.000 # x
.float 2.000 # z
.float 3.000 # y

# Blue
.float 1.000 # x
.float 2.000 # z
.float 3.000 # y

# Purple
.float 1.000 # x
.float 2.000 # z
.float 3.000 # y

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
