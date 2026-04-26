//
//  BackgroundRemovalService.swift
//  Fits
//

import UIKit
import Vision
import CoreImage

@available(iOS 17, *)
enum BackgroundRemovalService {

    /// Returns a background-removed cutout, or the original image on any failure.
    /// Never throws — the Tag flow must never be blocked by this step.
    nonisolated static func cutout(from image: UIImage) async -> UIImage {
        do { return try performCutout(image) }
        catch { return image }
    }

    nonisolated private static func performCutout(_ image: UIImage) throws -> UIImage {
        guard let cg = image.cgImage else { return image }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cg)
        try handler.perform([request])

        guard let result = request.results?.first else { return image }

        let masked = try result.generateMaskedImage(
            ofInstances: result.allInstances,
            from: handler,
            croppedToInstancesExtent: true
        )

        let ci = CIImage(cvPixelBuffer: masked)
        guard let out = CIContext().createCGImage(ci, from: ci.extent) else { return image }
        return UIImage(cgImage: out)
    }
}
