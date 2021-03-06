require "torch"
require "nn"

dofile 'Asserts.lua'
dofile 'CrossRNN.lua'

local leftInSize = 50;
local rightInSize = 50;
local totalInSize = leftInSize + rightInSize;

local leftInput = torch.rand(leftInSize)
local rightInput = torch.rand(rightInSize)
local gradOutput = torch.rand(leftInSize)
local concatenedInput = torch.rand(leftInSize + rightInSize)
local sumedGradOutput = torch.Tensor(leftInSize):fill(1)

--test CrossCore --random test
local core = nn.CrossCore(
    torch.rand(leftInSize,totalInSize),torch.rand(leftInSize))
core:forward(concatenedInput)
core:backward(concatenedInput,sumedGradOutput)
print(core:parameters())
print(core:getGradWeight())

--test CrossWord
local wordSize = rightInSize;
local wordIndexSize = 1;
local inputWord = torch.rand(wordSize);
local inputIndex = torch.rand(wordIndexSize);
local crossWord = nn.CrossWord(inputWord, inputIndex);
print("getGradWeight:");
print(crossWord:getGradWeight(inputWord));
print("getOutput():");
print(crossWord:getOutput());

--test CrossTag
local featureSize = leftInSize;
local classesSize = 3;
local weight = torch.rand(classesSize,featureSize);
local bias = torch.rand(classesSize);
local tag = 2;
local crossTag = nn.CrossTag(weight, bias, tag);
local nodeRepresentation = torch.rand(leftInSize);
crossTag:forward(nodeRepresentation);
crossTag:backward(nodeRepresentation);
print("getGradWeight():");
print(crossTag:getGradWeight());
print("getGradInput():");
print(crossTag:getGradInput());
print("getPredTag():");
print(crossTag:getPredTag());

--test Cross
local testCross = nn.Cross(core,crossWord,crossTag)
print(testCross:forward(leftInput))
print(testCross:backward(leftInput,gradOutput))
print(testCross:getGradParameters())

--now test CrossRNN
dofile 'LoadedLookupTable.lua'

local lookupTable = nn.LoadedLookupTable.load()
--local lookUpTable = torch.rand(3);		--lookUpTable not used in RNN.
local initialNode = torch.rand(leftInSize);
local testCrossRNN = nn.CrossRNN(leftInSize, rightInSize, classesSize, lookupTable);
--create a simple sentenceTuple
local sentence = {torch.rand(rightInSize),torch.rand(rightInSize),torch.rand(rightInSize)};
local index = {1,2,3};
local tag = {1,2,3};
local sentenceTuple = {represents = sentence, index = index, tagsId = tag};
local learningRates = 0.1;

print("Testing CrossRNN forward:\n");
print(testCrossRNN:forward(sentenceTuple, initialNode));

testCrossRNN:backward(sentenceTuple, initialNode);
print("Testing CrossRNN backward success!\n");

testCrossRNN:updateParameters(learningRates);
print("Testing CrossRNN update success!\n");
