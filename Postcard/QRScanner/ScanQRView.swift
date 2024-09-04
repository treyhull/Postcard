//
//  ScanQRView.swift
//  Postcard
//
//  Created by Anna Hull on 8/2/24.
//

import SwiftUI
import AVFoundation
import CoreLocation
import FirebaseAuth
import CodeScanner

struct ScanQRView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ScanQRViewModel()
    @State private var isPresentingScanner = false
    
    var body: some View {
        VStack {
            Button("Scan QR Code") {
                isPresentingScanner = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            if let scannedCode = viewModel.scannedCode {
                Text("Scanned code: \(scannedCode)")
                    .padding()
            }
        }
        .sheet(isPresented: $isPresentingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Test QR Code", completion: handleScan)
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Postcard Scan"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isPresentingScanner = false
        switch result {
        case .success(let result):
            viewModel.handleScannedCode(result.string)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
            viewModel.showAlert = true
            viewModel.alertMessage = "Scanning failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ScanQRView()
}
