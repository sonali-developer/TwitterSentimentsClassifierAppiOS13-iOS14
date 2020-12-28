import Cocoa
import CreateML

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/sonalipatel/Downloads/twitter-sanders-apple3.csv"))

let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)

let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")

let evaluationmetrices = sentimentClassifier.evaluation(on: testingData, textColumn: "text", labelColumn: "class")

let evaluationAccuracy = (1.0 - evaluationmetrices.classificationError) * 100

let metaData = MLModelMetadata(author: "Sonali Patel", shortDescription: "A model for evaluating sentiments on tweets", version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/sonalipatel/iOS13-14Apps/TweeterSentimentClassifier.mlmodel"))

try sentimentClassifier.prediction(from: "@apple is a great company for stocks")

try sentimentClassifier.prediction(from: "@apple will provide more value on stocks")

try sentimentClassifier.prediction(from: "@apple is the best company")

try sentimentClassifier.prediction(from: "@apple is a bad choice for Android Fans")
