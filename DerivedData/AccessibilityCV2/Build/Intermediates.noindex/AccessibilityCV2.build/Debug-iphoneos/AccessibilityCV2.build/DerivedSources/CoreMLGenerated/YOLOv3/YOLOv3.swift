//
// YOLOv3.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
class YOLOv3Input : MLFeatureProvider {

    /// 416x416 RGB image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
    var image: CVPixelBuffer

    /// This defines the radius of suppression. as optional double value
    var iouThreshold: Double? = nil

    /// Remove bounding boxes below this threshold (confidences should be nonnegative). as optional double value
    var confidenceThreshold: Double? = nil

    var featureNames: Set<String> {
        get {
            return ["image", "iouThreshold", "confidenceThreshold"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        if (featureName == "iouThreshold") {
            return iouThreshold == nil ? nil : MLFeatureValue(double: iouThreshold!)
        }
        if (featureName == "confidenceThreshold") {
            return confidenceThreshold == nil ? nil : MLFeatureValue(double: confidenceThreshold!)
        }
        return nil
    }
    
    init(image: CVPixelBuffer, iouThreshold: Double? = nil, confidenceThreshold: Double? = nil) {
        self.image = image
        self.iouThreshold = iouThreshold
        self.confidenceThreshold = confidenceThreshold
    }
}

/// Model Prediction Output Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
class YOLOv3Output : MLFeatureProvider {

    /// Source provided by CoreML

    private let provider : MLFeatureProvider


    /// Confidence derived for each of the bounding boxes.  as multidimensional array of doubles
    lazy var confidence: MLMultiArray = {
        [unowned self] in return self.provider.featureValue(for: "confidence")!.multiArrayValue
    }()!

    /// Normalised coordiantes (relative to the image size) for each of the bounding boxes (x,y,w,h).  as multidimensional array of doubles
    lazy var coordinates: MLMultiArray = {
        [unowned self] in return self.provider.featureValue(for: "coordinates")!.multiArrayValue
    }()!

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(confidence: MLMultiArray, coordinates: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["confidence" : MLFeatureValue(multiArray: confidence), "coordinates" : MLFeatureValue(multiArray: coordinates)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
class YOLOv3 {
    var model: MLModel

/// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: YOLOv3.self)
        return bundle.url(forResource: "YOLOv3", withExtension:"mlmodelc")!
    }

    /**
        Construct a model with explicit path to mlmodelc file
        - parameters:
           - url: the file url of the model
           - throws: an NSError object that describes the problem
    */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration
        - parameters:
           - configuration: the desired model configuration
           - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct a model with explicit path to mlmodelc file and configuration
        - parameters:
           - url: the file url of the model
           - configuration: the desired model configuration
           - throws: an NSError object that describes the problem
    */
    init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as YOLOv3Input
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as YOLOv3Output
    */
    func prediction(input: YOLOv3Input) throws -> YOLOv3Output {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as YOLOv3Input
           - options: prediction options 
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as YOLOv3Output
    */
    func prediction(input: YOLOv3Input, options: MLPredictionOptions) throws -> YOLOv3Output {
        let outFeatures = try model.prediction(from: input, options:options)
        return YOLOv3Output(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - image: 416x416 RGB image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
            - iouThreshold: This defines the radius of suppression. as optional double value
            - confidenceThreshold: Remove bounding boxes below this threshold (confidences should be nonnegative). as optional double value
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as YOLOv3Output
    */
    func prediction(image: CVPixelBuffer, iouThreshold: Double?, confidenceThreshold: Double?) throws -> YOLOv3Output {
        let input_ = YOLOv3Input(image: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface
        - parameters:
           - inputs: the inputs to the prediction as [YOLOv3Input]
           - options: prediction options 
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as [YOLOv3Output]
    */
    func predictions(inputs: [YOLOv3Input], options: MLPredictionOptions = MLPredictionOptions()) throws -> [YOLOv3Output] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [YOLOv3Output] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  YOLOv3Output(features: outProvider)
            results.append(result)
        }
        return results
    }
}
