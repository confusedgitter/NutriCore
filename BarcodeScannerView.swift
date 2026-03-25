import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    
    var completion: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onCodeScanned = { code in
            completion(code)
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var onCodeScanned: ((String) -> Void)?
    private let session = AVCaptureSession()
    private let overlayView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupOverlay()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce]
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        
        session.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.sublayers?.compactMap { $0 as? AVCaptureVideoPreviewLayer }.first?.frame = view.bounds
    }
    
    private func setupOverlay() {
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isUserInteractionEnabled = false
        
        let frameSize: CGFloat = 250
        let frameView = UIView(frame: CGRect(
            x: (view.bounds.width - frameSize) / 2,
            y: (view.bounds.height - frameSize) / 2,
            width: frameSize,
            height: frameSize
        ))
        
        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.borderWidth = 2
        frameView.backgroundColor = .clear
        
        let path = UIBezierPath(rect: overlayView.bounds)
        let cutout = UIBezierPath(rect: frameView.frame)
        path.append(cutout)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        overlayView.layer.mask = maskLayer
        
        overlayView.addSubview(frameView)
        
        let label = UILabel()
        label.text = "Align barcode within frame"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        overlayView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            label.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 16)
        ])
        
        view.addSubview(overlayView)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }
        
        session.stopRunning()
        onCodeScanned?(code)
        dismiss(animated: true)
    }
}
