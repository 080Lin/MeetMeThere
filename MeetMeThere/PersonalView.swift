//
//  PersonalView.swift
//  MeetMeThere
//
//  Created by Максим Нуждин on 24.01.2022.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct PersonalView: View {
    
    @State private var name = "Anonymous"
    @State private var email = "you@gmail.com"
    
    @State private var qrCode = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("name", text: $name)
                    .textContentType(.name)
                    .font(.title)
                
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .font(.title)
                
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        Button {
                            let imageSaver = ImageSaver()
                            
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        } label: {
                            Label("save to photos", systemImage: "square.and.arrow.down")
                        }
                    }
                
            }.navigationTitle("Your stats")
                .onAppear(perform: updateQRCode)
                .onChange(of: name) { newValue in
                    updateQRCode()
                }
                .onChange(of: email) { newValue in
                    updateQRCode()
                }
        }
    }
    
    func updateQRCode() {
        qrCode = generateQRcode(from: "\(name)\n\(email)")
    }
    
    func generateQRcode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
                
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct PersonalView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalView()
    }
}
