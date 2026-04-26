//
//  BackgroundRemovalService.swift
//  Fits
//

import UIKit
import Vision
import CoreImage

@available(iOS 17, *)
enum BackgroundRemovalService {

    /// Returns a clothes-only cutout, or the original image on any failure. tldr runs bg removal; whitening human skin; then bg remove to get rid of that
    static func cutout(from image: UIImage) async -> UIImage {
        let normalized = normalizeOrientation(image)
        // Pass 1: VisionKit foreground extraction + skin removal
        guard let fgCutout = try? performForegroundCutout(normalized) else { return normalized }
        let afterSkin = removeSkinTones(from: fgCutout) ?? fgCutout

        // Pass 2: re-run VisionKit on the already-processed output to clear any
        // residual white/gray artifacts left behind where body parts were removed
        let final = (try? performForegroundCutout(afterSkin)) ?? afterSkin
        return final
    }

    // Redraws image into a fresh context so CGImage access always sees .up orientation.
    // Camera photos are typically .right (sensor mounted sideways) — without this,
    // VisionKit and CGContext operations run on the raw rotated pixel buffer.
    private static func normalizeOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: image.size)) }
    }

    // MARK: - Step 1: VisionKit foreground extraction

    private static func performForegroundCutout(_ image: UIImage) throws -> UIImage {
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

    // MARK: - Step 2: Skin-tone removal

    /// Removes skin-tone pixels by making them transparent.
    private static func removeSkinTones(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width  = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow   = width * bytesPerPixel

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else { return nil }
        let buf = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        var skinMask = [Bool](repeating: false, count: width * height)

        for i in 0 ..< width * height {
            let a = buf[i * 4 + 3]
            guard a > 10 else { continue }

            let r = Float(buf[i * 4 + 0]) / 255
            let g = Float(buf[i * 4 + 1]) / 255
            let b = Float(buf[i * 4 + 2]) / 255

            if isSkinTone(r: r, g: g, b: b) {
                skinMask[i] = true
            }
        }

        // Dilation (expand mask slightly to remove halos)
        var dilated = skinMask
        for row in 1 ..< (height - 1) {
            for col in 1 ..< (width - 1) {
                if skinMask[row * width + col] {
                    dilated[(row - 1) * width + col] = true
                    dilated[(row + 1) * width + col] = true
                    dilated[row * width + (col - 1)] = true
                    dilated[row * width + (col + 1)] = true
                }
            }
        }

        // Apply mask
        for i in 0 ..< width * height {
            if dilated[i] {
                buf[i * 4 + 3] = 0
            }
        }

        guard let result = context.makeImage() else { return nil }
        return UIImage(cgImage: result, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Skin tone detection

    private static func isSkinTone(r: Float, g: Float, b: Float) -> Bool {
        let (h, s, v) = rgbToHSV(r: r, g: g, b: b)

        let inHueBand = h <= 0.139 || h >= 0.917
        let inSatBand = s >= 0.08 && s <= 0.82
        let inValBand = v >= 0.18 && v <= 0.97

        return inHueBand && inSatBand && inValBand
    }

    private static func rgbToHSV(r: Float, g: Float, b: Float) -> (h: Float, s: Float, v: Float) {
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let diff = maxC - minC

        let v = maxC
        let s = maxC < 1e-6 ? 0 : diff / maxC

        var h: Float = 0
        if diff > 1e-6 {
            if maxC == r {
                h = (g - b) / diff
            } else if maxC == g {
                h = 2 + (b - r) / diff
            } else {
                h = 4 + (r - g) / diff
            }
            h /= 6
            if h < 0 { h += 1 }
        }

        return (h, s, v)
    }
}
