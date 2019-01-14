
function printTimeAndScore(startTime, scoreGain, currentStateString)
    local ss = (os.time() - startTime) % 60
    local mm = (((os.time() - startTime - ss) % 3600) / 60)
    local hh = (os.time() - startTime - mm*60 - ss) / 3600
    print("Time: " .. string.format("%02d", hh) .. ":" .. string.format("%02d", mm) .. ":" .. string.format("%02d", ss) .. ". " .. currentStateString .. " Score: " .. current.GetEnergyScore() .. ", Total: +" .. scoreGain)
end

function initializeActions()
    performAction = {}

    performAction[0] = function()
        structure.WiggleAll(3)
    end

    performAction[1] = function()
        structure.MutateSidechainsAll(1)
    end

    performAction[2] = function()
        local startSegmentNumber = math.random(1, structure.GetCount() - 9)
        local endSegmentNumber = math.random(startSegmentNumber + 8, structure.GetCount())
        band.AddBetweenSegments(startSegmentNumber, endSegmentNumber)
        band.SetStrength(1, 10)
        band.SetGoalLength(1, structure.GetDistance(startSegmentNumber, endSegmentNumber) * 0.9)
    end

    performAction[3] = function()
        band.DeleteAll()
    end

    performAction[4] = function()
        recentbest.Restore()
    end

    performAction[5] = function()
        local startSegmentNumber = math.random(1,structure.GetCount() - 3)
        selection.DeselectAll()
        selection.SelectRange(startSegmentNumber, startSegmentNumber + 3)
        structure.RebuildSelected(2)
        selection.DeselectAll()
    end

    performAction[6] = function()
        behavior.SetClashImportance(1)
    end

    performAction[7] = function()
        behavior.SetClashImportance(0.5)
    end

    performAction[8] = function()
        behavior.SetClashImportance(0.02)
    end

    performAction[9] = function()
        local startSegmentNumber = math.random(1, structure.GetCount() - 3)
        selection.DeselectAll()
        selection.SelectRange(startSegmentNumber, startSegmentNumber + 3)
        structure.IdealizeSelected()
        selection.DeselectAll()
    end

    performAction[10] = function()
        local lengthOfSegment = math.random(1, 3)
        local segmentInformation = {}
        local workSegmentNumber = math.random(1, 3)
        local function sortSegments(segmentInformation)
            for i = 1, #segmentInformation - 1 do
                for j = i + 1, #segmentInformation do
                    if segmentInformation[i][3] > segmentInformation[j][3] then
                        segmentInformation[i], segmentInformation[j] = segmentInformation[j], segmentInformation[i]
                    end
                end
            end
            return segmentInformation
        end

        for i = 1, structure.GetCount() - lengthOfSegment + 1 do
            segmentInformation[i] = {i, i + lengthOfSegment - 1, current.GetSegmentEnergyScore(i) }
            for j = 2, lengthOfSegment do
                segmentInformation[i][3] = segmentInformation[i][3] + current.GetSegmentEnergyScore(i + j - 1)
            end
        end
        segmentInformation = sortSegments(segmentInformation)

        selection.DeselectAll()
        selection.SelectRange(math.max(segmentInformation[workSegmentNumber][1] - 1, 1), math.min(segmentInformation[workSegmentNumber][2] + 1, structure.GetCount()))
        structure.RebuildSelected(2)
        selection.DeselectAll()
    end
end

function addHashToAlgorithm(algorithm)
    algorithm.Hash = ""
    local shift = 0
    for i = 1, #algorithm do
        if algorithm[i] >= 10 then shift = 7 else shift = 0 end
        algorithm.Hash = algorithm.Hash .. string.char(HashStartCharacterCode + algorithm[i] + shift)
    end
end

function createRandomAlgorithm(algorithm)
    initializeAlgorithm(algorithm)
    for i = 1, NumberOfAlgorithmSteps do
        algorithm[i] = math.random(0, NumberOfActions - 1)
    end
    optimizeAlgorithm(algorithm)
end

function testAlgorithm(algorithm)

    resetPuzzle()
    algorithm.Score[0] = current.GetEnergyScore()
    algorithm.GainScore[0] = 999999
    local iteration = 1

    while algorithm.GainScore[iteration - 1] >= IterationScoreThreshold do

        local iterationStartScore = current.GetEnergyScore()
        --print("Iteration: "..iteration..". Start. Score: "..algorithm.Score[iteration])

        for i = 1, #algorithm do
            performAction[algorithm[i]]()
            --print("Step: " ..i..". Action: "..algorithm[i]..". Score: "..current.GetEnergyScore())
        end

        recentbest.Restore()
        algorithm.Score[iteration] = current.GetEnergyScore()
        algorithm.GainScore[iteration] = algorithm.Score[iteration] - iterationStartScore
        --print("Iteration: "..iteration..". End. Score: "..algorithm.Score[iteration])
        printTimeAndScore(startTime, algorithm.Score[iteration] - algorithm.Score[0], algorithm.CurrentStateString .. " Iteration " .. string.format("%02d", iteration) .. ".")

        iteration = iteration + 1

    end
    updateBestPosition()
end

function initializeAlgorithm(algorithm)
    algorithm.Score = {}
    algorithm.GainScore = {}
    algorithm.Hash = ""
    algorithm.CurrentStateString = ""
end

function copyAlgorithm(algorithm)
    local newAlgorithm = {}
    initializeAlgorithm(newAlgorithm)
    for i = 1, #algorithm do
        newAlgorithm[i] = algorithm[i]
    end
    newAlgorithm.Hash = algorithm.Hash
    return newAlgorithm
end

function mutateAlgorithm(algorithm)
    for i = 1, #algorithm do
        if math.random(0, 1) <= MutateRate then
            algorithm[i] = math.random(0, NumberOfActions - 1)
        end
    end
    optimizeAlgorithm(algorithm)
end

function createCrossAlgorithm(algorithmFirst, algorithmSecond)
    local algorithmFirstHash = algorithmFirst.Hash
    for i = 1, #algorithmFirst do
        if math.random(0, 1) <= 0.5 then
            algorithmFirst[i] = algorithmSecond[i]
        end
    end
    optimizeAlgorithm(algorithmFirst)
    if algorithmFirstHash == algorithmFirst.Hash or algorithmFirst.Hash == algorithmSecond.Hash then
        print("Crossing " .. algorithmFirst.Hash .. " changed to Mutation")
        mutateAlgorithm(algorithmFirst)
    end
end

function sortPopulation(population)
    for i = 1, #population - 1 do
        for j = i + 1, #population do
            if population[i].Score[#population[i].Score] < population[j].Score[#population[j].Score] then
                population[i], population[j] = population[j], population[i]
            end
        end
    end
end

function printPopulation(population)
    for i = 1, #population do
        print(string.format("%4s", i) .. ", " .. population[i].Hash .. ", score: " .. population[i].Score[#population[i].Score])
        if i == PopulationSize then
            print("--------------------------------------------------")
        end
    end
end

function optimizeAlgorithm(algorithm)
    for i = #algorithm + 1, NumberOfAlgorithmSteps do
        algorithm[i] = math.random(0, NumberOfActions - 1)
    end
    for i = NumberOfAlgorithmSteps + 1, #algorithm do
        algorithm[i] = nil
    end

    local actionNumber = 1
    while actionNumber <= #algorithm do
        if actionNumber == 1 and algorithm[actionNumber] == 4 then -- Delete first if recentbest.Restore()
            deleteAction(algorithm, actionNumber)
        elseif actionNumber > 1 and algorithm[actionNumber] == algorithm[actionNumber - 1] and algorithm[actionNumber] == 1 then -- Delete if second in a row structure.ShakeSidechainsAll(1)
            deleteAction(algorithm, actionNumber)
        elseif actionNumber > 1 and algorithm[actionNumber] == algorithm[actionNumber - 1] and algorithm[actionNumber] == 3 then -- Delete if second in a row band.DeleteAll()
            deleteAction(algorithm, actionNumber)
        elseif actionNumber > 1 and algorithm[actionNumber] == algorithm[actionNumber - 1] and algorithm[actionNumber] == 4 then -- Delete if second in a row recentbest.Restore()
            deleteAction(algorithm, actionNumber)
        elseif actionNumber > 1 and algorithm[actionNumber] == 3 and algorithm[actionNumber - 1] == 2 then -- Delete if second in a row recentbest.Restore()
            deleteAction(algorithm, actionNumber)
        elseif actionNumber == #algorithm and algorithm[actionNumber] == 4 then -- Delete last if recentbest.Restore()
            deleteAction(algorithm, actionNumber)
        elseif actionNumber == #algorithm and algorithm[actionNumber] == 2 then -- Delete last if it is add band.
            deleteAction(algorithm, actionNumber)
        elseif actionNumber == #algorithm and algorithm[actionNumber] == 6 then -- Delete last if change of clashing importance
            deleteAction(algorithm, actionNumber)
        elseif actionNumber == #algorithm and algorithm[actionNumber] == 7 then -- Delete last if change of clashing importance
            deleteAction(algorithm, actionNumber)
        elseif actionNumber == #algorithm and algorithm[actionNumber] == 8 then -- Delete last if change of clashing importance
            deleteAction(algorithm, actionNumber)
        elseif actionNumber > 1 and algorithm[actionNumber] == 6 and (algorithm[actionNumber - 1] == 7 or algorithm[actionNumber - 1] == 8) then -- Delete if second in a row change of clashing importance
            deleteAction(algorithm, actionNumber)
        elseif actionNumber > 1 and algorithm[actionNumber] == 7 and (algorithm[actionNumber - 1] == 6 or algorithm[actionNumber - 1] == 8) then -- Delete if second in a row change of clashing importance
            deleteAction(algorithm, actionNumber)
        elseif actionNumber > 1 and algorithm[actionNumber] == 8 and (algorithm[actionNumber - 1] == 6 or algorithm[actionNumber - 1] == 7) then -- Delete if second in a row change of clashing importance
            deleteAction(algorithm, actionNumber)
        else actionNumber = actionNumber + 1
        end
    end
    addHashToAlgorithm(algorithm)
end

function deleteAction(algorithm, actionNumber)
    for i = actionNumber, #algorithm - 1 do
        algorithm[i] = algorithm[i + 1]
    end
    algorithm[#algorithm] = math.random(0, NumberOfActions - 1)
end

function updateBestPosition()
    if current.GetEnergyScore() > bestScore then
        bestScore = current.GetEnergyScore()
        save.Quicksave(2)
    end
end

function resetPuzzle()
    save.Quickload(1)
    recentbest.Save()
    behavior.SetClashImportance(1)
end

function printMainInformation()
    print("PopulationSize: " .. PopulationSize)
    print("MutationSize: " .. MutationSize)
    print("AliensSize: " .. AliensSize)
    print("CrossSize: " .. CrossSize)
    print("NumberOfAlgorithmSteps: " .. NumberOfAlgorithmSteps)
    print("IterationScoreThreshold: " .. IterationScoreThreshold)
    print("ResetWorldGeneration: " .. ResetWorldGeneration)
    print("MutateRate: " .. MutateRate)
    print("StartScore: " .. current.GetEnergyScore())
end

function showMainDialog()
    local mainDialog = dialog.CreateDialog("AI Learns to play FoldIt.")
    mainDialog.PopulationSize = dialog.AddSlider("Population Size:", PopulationSize, 3, 200, 0)
    mainDialog.MutationSize = dialog.AddSlider("Mutation Size:", MutationSize, 0, 200, 0)
    mainDialog.AliensSize = dialog.AddSlider("Aliens Size:", AliensSize, 0, 200, 0)
    mainDialog.CrossSize = dialog.AddSlider("Cross Size:", CrossSize, 0, 200, 0)
    mainDialog.LabelNumberOfAlgorithmSteps = dialog.AddLabel("Number Of Algorithm Steps:")
    mainDialog.NumberOfAlgorithmSteps = dialog.AddSlider("", NumberOfAlgorithmSteps, 5, 200, 0)
    mainDialog.LabelIterationScoreThreshold = dialog.AddLabel("Iteration Score Threshold:")
    mainDialog.IterationScoreThreshold = dialog.AddSlider("", IterationScoreThreshold, 0.1, 100, 1)
    mainDialog.LabelResetWorldGeneration = dialog.AddLabel("Reset World Generation Each:")
    mainDialog.ResetWorldGeneration = dialog.AddSlider("", ResetWorldGeneration, 1, 200, 0)
    mainDialog.MutateRate = dialog.AddSlider("Mutate Rate:", MutateRate, 0.1, 1, 1)

    mainDialog.OK = dialog.AddButton("OK", 1)
    mainDialog.More = dialog.AddButton("More", 2)
    mainDialog.Cancel = dialog.AddButton("Cancel", 0)

    local mainDialogResult = dialog.Show(mainDialog)

    if (mainDialogResult >= 1) then
        PopulationSize = mainDialog.PopulationSize.value
        MutationSize = mainDialog.MutationSize.value
        AliensSize = mainDialog.AliensSize.value
        CrossSize = mainDialog.CrossSize.value
        NumberOfAlgorithmSteps = mainDialog.NumberOfAlgorithmSteps.value
        IterationScoreThreshold = mainDialog.IterationScoreThreshold.value
        ResetWorldGeneration = mainDialog.ResetWorldGeneration.value
        MutateRate = mainDialog.MutateRate.value

        -- TODO: Fix windows management. Currently if you go back to Main and click Cancel it is still start script
        if (mainDialogResult == 2) then
            showMoreDialog()
        end
        return true
    end
    return false
end

function showMoreDialog()
    local moreDialog = dialog.CreateDialog("Additional options.")
    moreDialog.Label = dialog.AddLabel("Include pre-defined algorithms:")
    moreDialog.AddAlgorithm1 = dialog.AddCheckbox("51042031048016049104", true)
    moreDialog.AddAlgorithm2 = dialog.AddCheckbox("91042031047016045104", true)
    moreDialog.OK = dialog.AddButton("Return", 1)

    local moreDialogResult = dialog.Show(moreDialog)
    if (moreDialogResult == 1) then
        InitialAlgorithm[1] = moreDialog.AddAlgorithm1.value
        InitialAlgorithm[2] = moreDialog.AddAlgorithm2.value
        showMainDialog()
    end
end

function getCurrentStateString(generation, stateType, typeNumber)
    return "Generation " .. string.format("%03d", generation) .. ". " .. string.format("%8s", stateType) .. " Num " .. string.format("%03d", typeNumber) .. ": "
end

function runMainProgram()
    local population = {}
    local algorithm = {}
    initializeActions()
    printMainInformation()

    -- Create initial population

    -- Add own algorithms

    if InitialAlgorithm[#population + 1] then
        algorithm = {5,1,0,4,2,0,3,1,0,4,8,0,1,6,0,4,9,1,0,4}
        initializeAlgorithm(algorithm)
        optimizeAlgorithm(algorithm)
        algorithm.CurrentStateString = getCurrentStateString(0, "Initial", #population + 1) .. algorithm.Hash .. "."
        testAlgorithm(algorithm)
        table.insert(population, algorithm)
    end

    if InitialAlgorithm[#population + 1] then
        algorithm = {9,1,0,4,2,0,3,1,0,4,7,0,1,6,0,4,5,1,0,4}
        initializeAlgorithm(algorithm)
        optimizeAlgorithm(algorithm)
        algorithm.CurrentStateString = getCurrentStateString(0, "Initial", #population + 1) .. algorithm.Hash .. "."
        testAlgorithm(algorithm)
        table.insert(population, algorithm)
    end

    -- Add random algorithms

    for i = #population + 1, PopulationSize do
        local algorithm = {}
        createRandomAlgorithm(algorithm)
        algorithm.CurrentStateString = getCurrentStateString(0, "Initial", i) .. algorithm.Hash .. "."
        testAlgorithm(algorithm)
        table.insert(population, algorithm)
    end

    sortPopulation(population)
    printPopulation(population)

    -- Grow of new generations

    local generation = 1
    while generation <= MaxGenerationSize do

        -- Reset world to best solution in case of Generations limit
        if generation % ResetWorldGeneration == 0 then
            print("World has been reseted!")
            print("--------------------------------------------------")
            save.Quickload(2)
            save.Quicksave(1)
            recentbest.Save()

            -- Replace old algorithms score with new for new world.
            for i = 1, #population do
                local newAlgorithm = copyAlgorithm(population[1])
                table.remove(population,1)
                newAlgorithm.CurrentStateString = getCurrentStateString(generation, "Recheck", i) .. newAlgorithm.Hash .. "."
                testAlgorithm(newAlgorithm)
                table.insert(population, newAlgorithm)
            end
        end

        -- Mutation
        for i = 1, math.min(#population, MutationSize) do
            local newAlgorithm = copyAlgorithm(population[i])
            mutateAlgorithm(newAlgorithm)
            newAlgorithm.CurrentStateString = getCurrentStateString(generation, "Mutation", i) .. population[i].Hash .. " to " .. newAlgorithm.Hash .. "."
            testAlgorithm(newAlgorithm)
            table.insert(population, newAlgorithm)
        end

        -- Crossing
        local crossDistance = 1
        local generatedCrossings = 0
        while crossDistance <= PopulationSize - 1 do
            local i = 1
            while i <= PopulationSize - crossDistance and generatedCrossings < CrossSize do
                local newAlgorithm = copyAlgorithm(population[i])
                local newAlgorithmSecond = copyAlgorithm(population[i + crossDistance])
                createCrossAlgorithm(newAlgorithm,newAlgorithmSecond)
                generatedCrossings = generatedCrossings + 1
                newAlgorithm.CurrentStateString = getCurrentStateString(generation, "Crossing", generatedCrossings) .. population[i].Hash .. " + " .. population[i + crossDistance].Hash .. " to " .. newAlgorithm.Hash .. "."
                testAlgorithm(newAlgorithm)
                table.insert(population, newAlgorithm)
                i = i + 1
            end
            crossDistance = crossDistance + 1
        end

        -- Aliens
        for i = 1, AliensSize do
            local newAlgorithm = {}
            createRandomAlgorithm(newAlgorithm)
            newAlgorithm.CurrentStateString = getCurrentStateString(generation, "Alien", i) .. newAlgorithm.Hash .. "."
            testAlgorithm(newAlgorithm)
            table.insert(population, newAlgorithm)
        end

        -- Remove worst from population

        sortPopulation(population)
        print("Top " .. PopulationSize .. " will survive:")
        printPopulation(population)
        while #population > PopulationSize do
            table.remove(population)
        end

        generation = generation + 1
    end
end

---------------------------------------------------------------
---------------------      MAIN PROGRAM     -------------------
---------------------------------------------------------------

NumberOfAlgorithmSteps = 20
NumberOfActions = 11
IterationScoreThreshold = 1
ResetWorldGeneration = 10
MutateRate = 0.2
InitialAlgorithm = {true,true}

PopulationSize = 5
MutationSize = 5
AliensSize = 5
CrossSize = 5

MaxGenerationSize = 1000
HashStartCharacterCode = 48

save.Quicksave(1)
recentbest.Save()
--startScore = current.GetEnergyScore()
bestScore = current.GetEnergyScore()
startTime = os.time()
math.randomseed(startTime)

if showMainDialog() then
    runMainProgram()
else print("Execution cancelled by user.")
end
