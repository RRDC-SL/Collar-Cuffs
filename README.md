# RRDC Collar and Cuffs

Scripts for the RRDC collar, cuffs, and associated extras in Second Life.
------

## Collar and Cuffs Upgrade Instructions ##

**Version 1.0 and Newer**
1. Wear or rez collar and cuff set on the ground.
2. Right click and edit the collar, and go to the Content tab.
3. Delete the old script.
4. Drop in the new script.
5. Repeat steps 2-4 for each cuff.

**Version 0.9 and Older**
1. Rez collar and cuff set on the ground.
2. Delete all scripts from every prim of every object.
3. For each object, go through every prim in the linkset and copy any contents to your inventory.
    * After copying the contents, delete them from the prim.

4. Rename the following animations to make them consistent with the naming scheme:
    * Rename 'cuffedArmsCollar001' to 'cuffedArmsCollar001a'.
    * Rename 'cuffedNeckForward001' to 'cuffedNeckForward001a'.
    
5. Copy assets from the folder you created back into the collar/cuffs.
    * Copy all animations into the root prim of the collar.
    * (OPTIONAL) Copy all sounds into the root prim of the collar.
    * (OPTIONAL) Copy all textures into the root prim of the collar.
    * (OPTIONAL) Copy 'thinchain' into the root prim of each cuff.

6. (OPTIONAL) Remove unnecessary prims from each cuffs linkset.
    * Each cuff should have exactly two transparent spheres. One on each side.
    * Unlink and delete additional spheres. Pay attention to which side 'LM-LG link' spheres are on.
    * Make sure the remaining spheres are centered on the top of the cuff anchor point.

7. Name the spheres on the 'LM-LG link' side of each cuff 'outerLink'.
8. Name the spheres on the opposite side of each cuff 'innerLink'.
9. Set the description of the root prim of the collar and each cuff as follows:
    * Collar should have the description 'collar'.
    * Left wrist cuff should have the description 'lcuff'.
    * Right wrist cuff should have the description 'rcuff'.
    * Left ankle cuff should have the description 'llcuff'.
    * Right ankle cuff should have the descrption 'rlcuff'.

10. Drop the collar.lsl script into the root prim of the collar.
11. Drop the cuff.lsl script into the root prim of each cuff.

------

## Leash Handle Script Instructions ##

1. Edit the object you want to act as a leash handle and select the prim you want to receive chains.
2. Drop the leash_handle.lsl script into the prim.

------

## Shock Remote Instructions ##

1. Edit the Shock Remote object and navigate to the content tab.
2. Drop the shock_remote.lsl script into the object.
