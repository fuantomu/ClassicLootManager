local  _, CLM = ...

CLM.ChangelogData = {
    {
        version = "v1.0.0",
        data =
        {
            {
                name = "Developers note",
                data = {
                    {header = "CLM is now fully complete!", body = "Thanks everyone for supporting us through this journey! Join our discord for more info: |cff44cc44https://tiny.one/clm-discord|r"},
                },
            },
            {
                name = "Features",
                data = {
                    {header = "Time Travel", body = "Have you ever awarded some DKP only a few days later, to realise it was in error? The thought of fixing it is such a hassle since you did a bunch of other stuff since then (eg, decay) and instead of the audit table looking clean now, it's full of manual corrections? Then this feature is for you! With |cff44cc44Time Travel|r mode, you can now jump back to a point in time in your audit log and add/remove entries to make corrections / additions in certain point in time! Simply activate time travel through audit GUI and make your changes. They are applied instantly. AddOn management is almost fully available during time traveling. Raid management is disabled during time travel."},
                    {header = "Sandbox", body = "|cff44cc44Sandbox|r mode allows you to place the addon in a state where you are disconnected from others. While disconnected, you are free to do whatever you want without the worry of a change affecting your DKP setup. What might this be useful for? Say you bring a new officer into your team and you'd like to assign them the task of managing DKP. With this mode, they can train themselves doing all the normal DKP operations in isolation. If you make a set of changes, you can either choose to apply them or discard them once you are done."},
                },
            },
        },
    },
    {
        version = "v0.13.1",
        data = {
            {
                name = "Fixes",
                data = {
                    {header = "ElvUI compatibility", body = "Fix for ElvUI users which, after patch 2.19, handles UI differently, thus resulting in very weird button placements."},
                },
            },
        }
    },
    {
        version = "v0.13.0",
        data = {
            {
                name = "Features",
                data = {
                    {header = "Loot Queue", body = "You can now track items that you have looted into the inventory and auction them from a convenient list. Toggle it through |cff00cc00/clm queue|r. Tracked loot quality can be changed in configuration."},
                },
            },
            {
                name = "Fixes",
                data = {
                    {header = "Alt-Main linking points fix", body = "When alt-main linking in case of alt missing in roster, when that alt was added to roster, there was an error that did set both main and alts standings to 0 instead of keeping current. |cffeeccccPlease double check point values if using alt-main linking when moving to this version.|r"},
                    {header = "Untrusted window display", body = "Profiles, Raid and Audit window are now read-only accessible to all users through |cff00cc00/clm commands|r"},
                    {header = "Window location storing", body = "Window location is now properly stored and restored when window is moved to the right side of the screen."}
                },
            },
            {
                name = "Notes",
                data = {
                    {header = "Event based communication", body = "Auction Manager now uses events to communication. This is a needed step to allow further AddOn / WeakAuras integration."},
                },
            },
        }
    },
    {
        version = "v0.12.0",
        data = {
            {
                name = "Features",
                data = {
                    {header = "Auditing", body = "Introducing new auditing UI for managers. You can now check every entry created by ledger and restore already ignored entries by ignoring (removing) the original ignore."},
                }
            },
            {
                name = "Fixes",
                data = {
                    {header = "Migration", body = "Migration is now executed with comms disabled and is reversible by wiping entries."},
                    {header = "Hydross DKP award", body = "Hydross DKP boss kill bonus award workaround is now fixed."},
                    {header = "Weekly gains display", body = "Weekly gains are now tracked and displayed even if there is no weekly cap."},
                    {header = "Roster Decay", body = "Roster decay should now use proper, optimised entries. While this is a backwards compatible fix there is marginal chance to lead to DKP difference if profile that had DKP in multiple rosters was removed and then added again. Please double check the values when upgrading to this version."},
                }
            },
        }
    },
    {
        version = "v0.11.0",
        data = {
            {
                name = "Features - auto awards",
                data = {
                    {header = "Raid bonuses", body = "On-time bonus - awarded when starting raid and Raid completion bonus - awarded when ending raid"},
                    {header = "Interval bonus", body = "Bonus is awarded every configured interval [minutes]"},
                    {header = "Boss kill bonus", body = "Configurable per boss and through global value"},
                }
            },
            {
                name = "Fixes",
                data = {
                    {header = "!dkp response", body = "|cff00cc00!dkp|r without parameters should now return requester standings"},
                    {header = "!bid response", body = "Removed odd alerts when using |cff00cc00!bid|r chat command while CLM was enabled (still not recommended)."},
                }
            },
        }
    },
    {
        version = "v0.10.1",
        data = {
            {
                name = "Hotfix",
                data = {
                    {header = "Version check", body = "Hotfix version check for lower patch version in bigger minor."},
                }
            },
        }
    },
    {
        version = "v0.10.0",
        data = {
            {
                name = "Features",
                data = {
                    {header = "Zero-Sum DKP", body = "CLM now support Zero-Sum DKP. If you aren't aware of how Zero-Sum works, it's a DKP system where, at a rosters inception, an amount of DKP is awarded to each player and from that point onwards, no new DKP is awarded (although addon does not restrict it). When a player spends DKP (loot is awarded), that DKP is awarded evenly to the rest of the roster."},
                    {header = "Chat commands", body = "You can now use the |cff00cc00!bid X|r function to bid (even if you don't have CLM installed). It's not recommended though if you have CLM. Values supported include: value / pass / cancel. You can also get information about your standings through |cff00cc00!dkp|r. This function needs to be enabled per trusted person."},
                    {header = "Player search", body = "For convenience, you can now search for players by name on the standings screen. This is particularly helpful to those guilds with large rosters."},
                    {header = "Minimum bid increment", body = "You can now configure minimum bid increment to be used in open auction mode."},
                }
            },
            {
                name = "Quality of Life",
                data = {
                    {header = "Smart DKP award", body = "When applying DKP, CLM is now more context aware depending on filter settings. If you are in a raid, DKP will be assigned to raid members. If you aren't, it'll consider the roster, otherwise it will fall back onto the individual player selection. Alternately, selecting a player (or players) in a raid will override this new behaviour."},
                    {header = "Relaxed auctioning", body = "Auctioning is no longer restricted to the master looter. The raid leader can now perform similar functions. Should also allow for bidding from outside of guild raiders."},
                }
            },
        }
    },
    {
        version = "v0.9.3",
        data = {
            {
                name = "Features",
                data = {
                    {header = "Alerts!", body = "You will now see an alert when: receiving DKP; item is awarded to you; your bid is accepted; your bid is denied."},
                }
            },
            {
                name = "Bugfixes",
                data = {
                    {header = "Spec Sharing", body = "Proper talent information will now be shared."},
                }
            },
        }
    },
    {
        version = "v0.9.2",
        data = {
            {
                name = "Fixes",
                data = {
                    {header = "Invalid point value", body = "Fix for invalid point value due to alt-main linking introduction."},
                },
            },
        }
    },
    {
        version = "v0.9.1",
        data = {
            {
                name = "Hotfix",
                data = {
                    {header = "Fatal", body = "Hotfix fatal code error in some corner cases."},
                },
            },
        }
    },
    {
        version = "v0.9.0",
        data = {
            {
                name = "Features",
                data = {
                    {header = "Link your alt to your main character", body = "You can now link an alt character in a roster to your main for the purposes of sharing DKP. For linking to work, characters must exist in the same roster. When you link and alt to a main, the DKP each character currently has is added together. From that point onwards, when one linked character has their DKP changed, the others will also. Loot and point histories are tracked against the alt-linked character they are applied against so in future, if you disconnect a main from an alt, history and point calculations will be retained seperately (and recalculated). To get started, type: |cff00cc00/clm link alt main|r. You can unlink through |cff00cc00/clm unlink alt|r. Removing alt-linked main from a roster will also remove the alt - make sure you unlink before you remove a main! Only trusted players can do that."},
                    {header = "CommunityDKP Migration Support", body = "You can now migrate existing data to CLM. This includes: loot history, point history, and the current DKP standings. Configuration is not migrated. Undertaking a migration should be attempted by a GM with existing data backed up incase of a problem. Best practice is to do it as GM being the only one with CLM installed in the guild. You can trigger one through the command |cff00cc00/clm migrate|r. Check out more information on wiki."},
                    {header = "Spec Sharing", body = "Your spec will now be stored and shared numerically in the profile window for others to see."},
                    {header = "Bidding", body = "Base and max buttons are now disabled if the respective limit is set to 0. Your current DKP is now displayed on the bidding window for convenience"},
                    {header = "Standings", body = "You can now see information about weekly DKP gains and limits in the standings tooltips."},
                    {header = "Changelog", body = "You are reading it right now =)"},
                }
            },
            {
                name = "Bugfixes",
                data = {
                    {header = "Raid creation", body = "Fixed an issue where, in the raid window when attempting to create a new raid, if a user didn't re-select the team, CLM would complain."},
                    {header = "Pass on bid", body = "PASS notifciation is now properly being sorted at the end of the list instead of top."},
                    {header = "ElvUI auction from corpse", body = "Now works as expected!"},
                }
            },
            {
                name = "Notes",
                data = {
                    {header = "WoW DKP Bot integration", body = "Integration is now supported by CLM! To enable it go to Configuration and tick the bot integration box. Experimental. Might have performance impact."},
                }
            },
        },
    },
}