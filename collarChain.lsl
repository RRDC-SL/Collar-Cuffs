// [SGD] RRDC Collar Chains v1.3.0 (c) 2021 Sasha Wyrding (alex.carpenter) @ Second Life.
// Based on combined Lockmeister and LockGuard script by Felis Darwin.
// ----------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// ========================================================================================

// Modifiable Variables.
// ----------------------------------------------------------------------------------------
integer g_appChan           = -89039937;        // The channel for this application set.

// ========================================================================================
// CAUTION: Modifying anything below this line may cause issues. Edit at your own risk!
// ========================================================================================
string  g_partTex;                              // Current particle texture.
float   g_partSizeX;                            // Current particle X size.
float   g_partSizeY;                            // Current particle Y size.
float   g_partLife;                             // Current particle life.
float   g_partGravity;                          // Current particle gravity.
vector  g_partColor;                            // Current particle color.
float   g_partRate;                             // Current particle rate.
integer g_partFollow;                           // Current particle follow flag.
integer g_leashPartOn;                          // If TRUE, leashLink particles are on.
integer g_shacklePartOn;                        // If TRUE, shackleLink particles are on.
string  g_leashPartTarget;                      // Key of the target prim for LG/leash.
string  g_shacklePartTarget;                    // Key of the target prim for shackle.
integer g_leashLink;                            // Link number of the leash/LGLM emitter.
integer g_shackleLink;                          // Link number of the shackle emitter.
integer g_particleMode;                         // FALSE = LG/LM, TRUE = Intercuff.
// ========================================================================================

// getAvChannel - Given an avatar key, returns a static channel XORed with g_appChan.
// ----------------------------------------------------------------------------------------
integer getAvChannel(key av)
{
    return (0x80000000 | ((integer)("0x"+(string)av) ^ g_appChan));
}

// fClamp - Given a number, returns number bounded by lower and upper.
// ----------------------------------------------------------------------------------------
float fClamp(float value, float lower, float upper)
{
    if (value < lower)
    {
        return lower;
    }
    else if (value > upper)
    {
        return upper;
    }
    return value;
}

// leashParticles - Turns leash/LockGuard chain/rope particles on or off.
// ----------------------------------------------------------------------------------------
leashParticles(integer on)
{
    g_leashPartOn = on; // Save the state we passed in.
    
    if(!on) // If LG particles should be turned off, turn them off and reset defaults.
    {
        llLinkParticleSystem(g_leashLink, []); // Stop particle system and clear target.
        g_leashPartTarget   = NULL_KEY;
    }
    else // If LG particles are to be turned on, turn them on.
    {
        llLinkParticleSystem(g_leashLink,
        [
            PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_DROP,
            PSYS_SRC_BURST_PART_COUNT,  1,
            PSYS_SRC_MAX_AGE,           0.0,
            PSYS_PART_MAX_AGE,          g_partLife,
            PSYS_SRC_BURST_RATE,        g_partRate,
            PSYS_SRC_TEXTURE,           g_partTex,
            PSYS_PART_START_COLOR,      g_partColor,
            PSYS_PART_START_SCALE,      <g_partSizeX, g_partSizeY, 0.0>,
            PSYS_SRC_ACCEL,             <0.0, 0.0, (g_partGravity * -1.0)>,
            PSYS_SRC_TARGET_KEY,        (key)g_leashPartTarget,
            PSYS_PART_FLAGS,            (PSYS_PART_TARGET_POS_MASK                           |
                                         PSYS_PART_FOLLOW_VELOCITY_MASK                      |
                                         PSYS_PART_TARGET_LINEAR_MASK * (g_partGravity == 0) |
                                         PSYS_PART_FOLLOW_SRC_MASK * (g_partFollow == TRUE))
        ]);
    }
}

// shackleParticles - Turns shackle chain/rope particles on or off.
// ----------------------------------------------------------------------------------------
shackleParticles(integer on)
{
    g_shacklePartOn = on;

    if (!on) // Turn shackle particle system off.
    {
        llLinkParticleSystem(g_shackleLink, []); // Stop particle system and clear target.
        g_shacklePartTarget   = NULL_KEY;
    }
    else // Turn the shackle particle system on.
    {
        llLinkParticleSystem(g_shackleLink,
        [
            PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_DROP,
            PSYS_SRC_BURST_PART_COUNT,  1,
            PSYS_SRC_MAX_AGE,           0.0,
            PSYS_PART_MAX_AGE,          1.2,
            PSYS_SRC_BURST_RATE,        0.01,
            PSYS_SRC_TEXTURE,           "dbeee6e7-4a63-9efe-125f-ceff36ceeed2", // thinchain.
            PSYS_PART_START_COLOR,      <1.0, 1.0, 1.0>,
            PSYS_PART_START_SCALE,      <0.04, 0.04, 0.0>,
            PSYS_SRC_ACCEL,             <0.0, 0.0, -0.3>,
            PSYS_SRC_TARGET_KEY,        (key)g_shacklePartTarget,
            PSYS_PART_FLAGS,            (PSYS_PART_TARGET_POS_MASK      |
                                         PSYS_PART_FOLLOW_VELOCITY_MASK |
                                         PSYS_PART_FOLLOW_SRC_MASK)
        ]);
    }
}

// resetParticles - When activated sets current leash particle settings to defaults.
// ---------------------------------------------------------------------------------------------------------
resetParticles()
{
    g_partTex        = "dbeee6e7-4a63-9efe-125f-ceff36ceeed2"; // thinchain.
    g_partSizeX      = 0.04;
    g_partSizeY      = 0.04;
    g_partLife       = 1.2;
    g_partGravity    = 0.3;
    g_partColor      = <1.0, 1.0, 1.0>;
    g_partRate       = 0.01;
    g_partFollow     = TRUE;
}

// toggleMode - Controls particle system when changing between LG/LM and Interlink.
// ----------------------------------------------------------------------------------------
toggleMode(integer mode)
{
    if (g_particleMode != mode) // If the mode actually changed.
    {
        leashParticles(FALSE); // Clear all particles.
        shackleParticles(FALSE);
        resetParticles();

        g_particleMode = mode; // Toggle mode.

        if (!mode) // Send stop poses or stop leash command.
        {
            if (g_LMTag == "lcuff")
            {
                llWhisper(getAvChannel(llGetOwner()), "stopposes collarfrontloop");
            }
            else if (g_LMTag == "llcuff")
            {
                llWhisper(getAvChannel(llGetOwner()), "stopleash collarfrontloop");
            }
        }
    }
}

default
{
    // Initialize the script.
    // ----------------------------------------------------------------------------------------
    state_entry()
    {
        integer i; // Find the emitter links.
        string tag;
        for (i = 1; i <= llGetNumberOfPrims(); i++)
        {
            tag = llToLower(llStringTrim(llGetLinkName(i), STRING_TRIM));
            if (tag == "shacklelink")
            {
                g_shackleLink = i;
            }
            else if (tag == "leashlink")
            {
                g_leashLink = i;
            }
        }

        if (g_shackleLink <= 0 || g_leashLink <= 0) // Stop if system not intact.
        {
            llOwnerSay("FATAL: Unknown anchor and/or missing chain emitters!");
            return; // Ensure safe-ish LGTags lookup.
        }

        llSetMemoryLimit(llGetUsedMemory() + 2048); // Limit script memory consumption.

        resetParticles();
        shackleParticles(FALSE); // Stop any particle effects and init.
        leashParticles(FALSE);

        llListen(-8888,"",NULL_KEY,""); // Open up LockGuard and Lockmeister listens.
        llListen(-9119,"",NULL_KEY,"");

        llListen(getAvChannel(llGetOwner()), "", "", ""); // Open collar/cuffs avChannel.
    }

    // Reset the script on rez.
    // ----------------------------------------------------------------------------------------
    on_rez(integer param)
    {
        llResetScript();
    }

    // Listen for LG and LM commands.
    // ----------------------------------------------------------------------------------------
    listen(integer chan, string name, key id, string mesg)
    {
        if (chan == getAvChannel(llGetOwner()) && llGetOwnerKey(id) != id) // Process RRDC commands.
        {
            list l = llParseString2List(mesg, [" "], []);
            if (llList2String(l, 1) == "collarfrontloop") // LG tag match.
            {
                name = llToLower(llList2String(l, 0));
                if (name == "unlink") // unlink <tag> <shackle|leash>
                {
                    if (llToLower(llList2String(l, 2)) == "shackle")
                    {
                        shackleParticles(FALSE);
                    }
                    else if (g_particleMode) // leash.
                    {
                        resetParticles();
                        leashParticles(FALSE);
                    }
                }
                else if (name == "link") // link <tag> <shackle|leash> <dest-uuid>
                {
                    toggleMode(TRUE);
                    if (llToLower(llList2String(l, 2)) == "shackle")
                    {
                        g_shacklePartTarget = llList2Key(l, 3);
                        shackleParticles(TRUE);
                    }
                    else // leash.
                    {
                        g_leashPartTarget = llList2Key(l, 3);
                        leashParticles(TRUE);
                    }
                }       // linkrequest <dest-tag> <shackle|leash|x> <src-tag> <shackle|leash>
                else if (name == "linkrequest")
                {
                    if (llToLower(llList2String(l, 2)) == "shackle") // Get the link UUID.
                    {
                        name = (string)llGetLinkKey(g_shackleLink);
                    }
                    else // leash.
                    {
                        name = (string)llGetLinkKey(g_leashLink);
                    }

                    llWhisper(getAvChannel(llGetOwnerKey(id)), "link " + // Send link message.
                        llList2String(l, 3) + " " +
                        llList2String(l, 4) + " " + name
                    );
                }           // leashto <src-tag> <shackle|leash> <uuid> <dest-tag> <shackle|leash|x>
                else if (name == "leashto")
                {
                    toggleMode(TRUE);
                    g_partLife = 2.4;     // Make the chain a little longer for leash/chain gang.
                    g_partGravity = 0.15;

                    if (llToLower(llList2String(l, 2)) == "shackle") // Make a temp link.
                    {
                        g_shacklePartTarget = llList2Key(l, 3);
                        shackleParticles(TRUE);
                    }
                    else // leash.
                    {
                        g_leashPartTarget = llList2Key(l, 3);
                        leashParticles(TRUE);
                    }

                    llWhisper(getAvChannel(llList2Key(l, 3)), "linkrequest " +
                        llList2String(l, 4) + " " +
                        llList2String(l, 5) + " " +
                        llList2String(l, 1) + " " +
                        llList2String(l, 2)
                    );
                }
                else if (name == "ping") // ping <dest-tag> <src-tag>
                {
                    llWhisper(getAvChannel(llGetOwnerKey(id)), "pong " + 
                        llList2String(l, 2) + " " +
                        llList2String(l, 1)
                    );
                }
                else if (name == "settexture") // settexture <tag> <uuid>
                {
                    llSetLinkPrimitiveParamsFast(LINK_THIS, [
                        PRIM_TEXTURE, 1, llList2String(l, 2), <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
                    ]);
                }
            }
        }
        else if(chan == -8888 && llGetSubString(mesg, 0, 35) == ((string)llGetOwner())) // Process LM.
        {
            if(llGetSubString(mesg, 36, -1) == "collar")
            {
                toggleMode(FALSE);
                llRegionSayTo(id, -8888, mesg + " ok");
            }
            else if (llGetSubString(mesg, 36, 54) == "|LMV2|RequestPoint|" &&      // LMV2.
                     llGetSubString(mesg, 55, -1) == "collar")
            {
                llRegionSayTo(id, -8888, ((string)llGetOwner()) + "|LMV2|ReplyPoint|" + 
                    llGetSubString(mesg, 55, -1) + "|" + ((string)llGetLinkKey(g_leashLink))
                );
            }
        }                                                                          // Process LG.
        else if(chan == -9119 && llSubStringIndex(mesg, "lockguard " + ((string)llGetOwner())) == 0)
        {
            list tList = llParseString2List(mesg, [" "], []);
            
            // lockguard [avatarKey/ownerKey] [item] [command] [variable(s)] 
            if(llList2String(l, 1) == "collarfrontloop" || llList2String(tList, 2) == "all")
            {
                integer i = 3; // Start at the first command position and parse the commands.
                while(i < llGetListLength(tList))
                {                    
                    name = llList2String(tList, i);
                    if(name == "link")
                    {
                        toggleMode(FALSE);
                        g_leashPartTarget = llList2Key(tList, (i + 1));
                        leashParticles(TRUE);
                        i += 2;
                    }
                    else if(name == "unlink" && !g_particleMode)
                    {
                        resetParticles();
                        leashParticles(FALSE);
                        tList = [];
                        return;
                    }
                    else if(name == "gravity")
                    {
                        toggleMode(FALSE);
                        g_partGravity = fClamp(llList2Float(tList, (i + 1)), 0.0, 100.0);
                        i += 2;
                    }
                    else if(name == "life")
                    {
                        toggleMode(FALSE);
                        g_partLife = fClamp(llList2Float(tList, (i + 1)), 0.0, 30.0);
                        i += 2;
                    }
                    else if(name == "texture")
                    {
                        toggleMode(FALSE);
                        name = llList2String(tList, (i + 1));
                        if(name != "chain" && name != "rope")
                        {
                            g_partTex = name;
                        }
                        i += 2;
                    }
                    else if(name == "rate")
                    {
                        toggleMode(FALSE);
                        g_partRate = fClamp(llList2Float(tList, (i + 1)), 0.0, 60.0);
                        i += 2;
                    }
                    else if(name == "follow")
                    {
                        toggleMode(FALSE);
                        g_partFollow = (llList2Integer(tList, (i + 1)) > 0);
                        i += 2;
                    }
                    else if(name == "size")
                    {
                        toggleMode(FALSE);
                        g_partSizeX = fClamp(llList2Float(tList, (i + 1)), 0.03125, 4.0);
                        g_partSizeY = fClamp(llList2Float(tList, (i + 2)), 0.03125, 4.0);
                        i += 3;
                    }
                    else if(name == "color")
                    {
                        toggleMode(FALSE);
                        g_partColor.x = fClamp(llList2Float(tList, (i + 1)), 0.0, 1.0);
                        g_partColor.y = fClamp(llList2Float(tList, (i + 2)), 0.0, 1.0);
                        g_partColor.z = fClamp(llList2Float(tList, (i + 3)), 0.0, 1.0);
                        i += 4;
                    }
                    else if(name == "ping")
                    {
                        llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " collarfrontloop okay");
                        i++;
                    }
                    else if(name == "free")
                    {
                        if(g_leashPartOn)
                        {
                            llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " collarfrontloop no");
                        }
                        else
                        {
                            llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " collarfrontloop yes");
                        }
                        i++;
                    }
                    else // Skip unknown commands.
                    {
                        i++;
                    }
                }
                
                leashParticles(g_leashPartOn); // Refresh particles.
            }
        }
    }
}
