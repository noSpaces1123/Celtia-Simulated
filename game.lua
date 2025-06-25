Teams = {
    {},
    {},
}

MaxTeamSize = 4

SelectingCelsToAffect = {
    targetTeamIndex = nil, targetGuyIndex = nil,
    affecterTeamIndex = nil, affecterGuyIndex = nil,
    celSelection = {},
    celsSelected = 0, minCelsToSelect = 3, maxCelsToSelect = 3,
    running = false,
    effect = nil,
}

TeamColors = { {0,.5,1}, {1,.5,0} }



function BeginCelSelectionProcess(affecterGuy, targetGuy, minCelsToSelect, maxCelsToSelect, effectFunc)
    SelectingCelsToAffect.affecterTeamIndex = affecterGuy.myTeamIndex
    SelectingCelsToAffect.affecterGuyIndex = affecterGuy.myGuyIndexInTheTeam

    SelectingCelsToAffect.celsSelected = 0
    SelectingCelsToAffect.minCelsToSelect = minCelsToSelect
    SelectingCelsToAffect.maxCelsToSelect = maxCelsToSelect

    SelectingCelsToAffect.celSelection = {
        {0,0,0},
        {0,0,0},
        {0,0,0},
    }

    SelectingCelsToAffect.effect = effectFunc

    SelectingCelsToAffect.running = true

    zutil.playsfx(SFX.celSelectingTime, .3, 1)
end