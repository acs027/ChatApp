//
//  CropAndResizeImage.swift
//  ChatApp
//
//  Created by ali cihan on 31.05.2024.
//

import Foundation
import UIKit

extension UIImage {
    // Function to crop and resize an image
    func cropAndResize(to desiredSize: Int) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let imgSize = cgImage.width > cgImage.height ? cgImage.height : cgImage.width
        let posX = (cgImage.width - imgSize) / 2
        let posY = (cgImage.height - imgSize) / 2
        
        let scale = CGFloat(Double(desiredSize)/Double(imgSize))
        
        let cropRect = CGRect(x: posX, y: posY, width: imgSize, height: imgSize) // Define the cropping rectangle
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: scale, orientation: self.imageOrientation)
        
        let scaleRatio = UIScreen.main.scale
        
        let targetSize = CGSize(width: CGFloat(desiredSize) / scaleRatio, height: CGFloat(desiredSize) / scaleRatio)
        
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let scaledImg = renderer.image { _ in
            croppedImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return scaledImg
      }
}
