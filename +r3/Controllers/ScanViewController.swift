//
//  ScanViewController.swift
//  +r3
//
//  Created by Xin Hua on 9/21/16.
//  Copyright © 2016 Igor Gubanov. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import CoreMotion
import QuartzCore

// Constants;
let DEGREES_TO_RADIANS: Float = (Float(M_PI) / Float(180.0))
let WGS84_A: Float = 6378137.0  // WGS 84 semi-major axis constant in meters
let WGS84_E: Float = 8.1819190842622e-2 // WGS 84 eccentricity

// Types;
struct mat4f {
    public var m11: Float = 0.0
    public var m12: Float = 0.0
    public var m13: Float = 0.0
    public var m14: Float = 0.0
    public var m21: Float = 0.0
    public var m22: Float = 0.0
    public var m23: Float = 0.0
    public var m24: Float = 0.0
    public var m31: Float = 0.0
    public var m32: Float = 0.0
    public var m33: Float = 0.0
    public var m34: Float = 0.0
    public var m41: Float = 0.0
    public var m42: Float = 0.0
    public var m43: Float = 0.0
    public var m44: Float = 0.0
    
    public init() {
        
    }
}

struct vec4f {
    public var v1: Float = 0.0
    public var v2: Float = 0.0
    public var v3: Float = 0.0
    public var v4: Float = 0.0
    
    public init() {
        
    }
}

// Creates a Projection Matrix;
func createProjectionMatrix(_ matrix: inout mat4f, _ fovy: Float, _ aspect: Float, _ zNear: Float, _ zFar: Float) {
    let f = 1.0 / tanf(fovy / 2.0)
    
    matrix.m11 = f / aspect
    matrix.m12 = 0.0
    matrix.m13 = 0.0
    matrix.m14 = 0.0
    
    matrix.m21 = 0.0
    matrix.m22 = f
    matrix.m23 = 0.0
    matrix.m24 = 0.0
    
    matrix.m31 = 0.0
    matrix.m32 = 0.0
    matrix.m33 = (zFar + zNear) / (zNear - zFar)
    matrix.m34 = -1.0
    
    matrix.m41 = 0.0
    matrix.m42 = 0.0
    matrix.m43 = 2 * zFar * zNear / (zNear-zFar)
    matrix.m44 = 0.0
}

// Matrix - Vector and Matrix - Matricx Multiplication Routines;
func multiplyMatrixAndVector(_ vout: inout vec4f, _ m: mat4f, _ v: vec4f) {
    vout.v1 = m.m11 * v.v1 + m.m21 * v.v2 + m.m31 * v.v3 + m.m41 * v.v4
    vout.v2 = m.m12 * v.v1 + m.m22 * v.v2 + m.m32 * v.v3 + m.m42 * v.v4
    vout.v3 = m.m13 * v.v1 + m.m23 * v.v2 + m.m33 * v.v3 + m.m43 * v.v4
    vout.v4 = m.m14 * v.v1 + m.m24 * v.v2 + m.m34 * v.v3 + m.m44 * v.v4
}

func multiplyMatrixAndMatrix(_ c: inout mat4f, _ a: mat4f, _ b: mat4f) {
    c.m11 = a.m11 * b.m11 + a.m21 * b.m12 + a.m31 * b.m13 + a.m41 * b.m14
    c.m12 = a.m12 * b.m11 + a.m22 * b.m12 + a.m32 * b.m13 + a.m42 * b.m14
    c.m13 = a.m13 * b.m11 + a.m23 * b.m12 + a.m33 * b.m13 + a.m43 * b.m14
    c.m14 = a.m14 * b.m11 + a.m24 * b.m12 + a.m34 * b.m13 + a.m44 * b.m14
    
    c.m21 = a.m11 * b.m21 + a.m21 * b.m22 + a.m31 * b.m23 + a.m41 * b.m24
    c.m22 = a.m12 * b.m21 + a.m22 * b.m22 + a.m32 * b.m23 + a.m42 * b.m24
    c.m23 = a.m13 * b.m21 + a.m23 * b.m22 + a.m33 * b.m23 + a.m43 * b.m24
    c.m24 = a.m14 * b.m21 + a.m24 * b.m22 + a.m34 * b.m23 + a.m44 * b.m24
    
    c.m31 = a.m11 * b.m31 + a.m21 * b.m32 + a.m31 * b.m33 + a.m41 * b.m34
    c.m32 = a.m12 * b.m31 + a.m22 * b.m32 + a.m32 * b.m33 + a.m42 * b.m34
    c.m33 = a.m13 * b.m31 + a.m23 * b.m32 + a.m33 * b.m33 + a.m43 * b.m34
    c.m34 = a.m14 * b.m31 + a.m24 * b.m32 + a.m34 * b.m33 + a.m44 * b.m34
    
    c.m41 = a.m11 * b.m41 + a.m21 * b.m42 + a.m31 * b.m43 + a.m41 * b.m44
    c.m42 = a.m12 * b.m41 + a.m22 * b.m42 + a.m32 * b.m43 + a.m42 * b.m44
    c.m43 = a.m13 * b.m41 + a.m23 * b.m42 + a.m33 * b.m43 + a.m43 * b.m44
    c.m44 = a.m14 * b.m41 + a.m24 * b.m42 + a.m34 * b.m43 + a.m44 * b.m44
}

// Initialize mout to be an affine transform corresponding to the same rotation specified by m;
func transformFromCMRotationMatrix(_ mout: inout mat4f, _ m: CMRotationMatrix) {
    mout.m11 = Float(m.m11)
    mout.m12 = Float(m.m21)
    mout.m13 = Float(m.m31)
    mout.m14 = 0.0
    
    mout.m21 = Float(m.m12)
    mout.m22 = Float(m.m22)
    mout.m23 = Float(m.m32)
    mout.m24 = 0.0

    mout.m31 = Float(m.m13)
    mout.m32 = Float(m.m23)
    mout.m33 = Float(m.m33)
    mout.m34 = 0.0

    mout.m41 = 0.0
    mout.m42 = 0.0
    mout.m43 = 0.0
    mout.m44 = 1.0
}

// Converts latitude, longitude to ECEF coordinate system;
func latLonToEcef(_ lat: Float, _ lon: Float, _ alt: Float, _ x: inout Float, _ y: inout Float, _ z: inout Float) {
    let clat = cos(lat * DEGREES_TO_RADIANS)
    let slat = sin(lat * DEGREES_TO_RADIANS)
    let clon = cos(lon * DEGREES_TO_RADIANS)
    let slon = sin(lon * DEGREES_TO_RADIANS)
    
    let N = WGS84_A / sqrt( 1.0 - WGS84_E * WGS84_E * slat * slat );
    
    x = (N + alt) * clat * clon;
    y = (N + alt) * clat * slon;
    z = (N * (1.0 - WGS84_E * WGS84_E) + alt) * slat;
}

// Coverts ECEF to ENU coordinates centered at given lat, lon;
func ecefToEnu(_ lat: Float, _ lon: Float, _ x: Float, _ y: Float, _ z: Float, _ xr: Float, _ yr: Float, _ zr: Float, _ e: inout Float, _ n: inout Float, _ u: inout Float)
{
    let clat = cos(lat * DEGREES_TO_RADIANS)
    let slat = sin(lat * DEGREES_TO_RADIANS)
    let clon = cos(lon * DEGREES_TO_RADIANS)
    let slon = sin(lon * DEGREES_TO_RADIANS)
    let dx = x - xr
    let dy = y - yr
    let dz = z - zr
    
    e = -slon * dx  + clon * dy
    n = -slat * clon * dx - slat * slon * dy + clat * dz
    u = clat * clon * dx + clat * slon * dy + slat * dz
}

class ScanViewController: UIViewController, CLLocationManagerDelegate, PlaceViewDelegate {

    @IBOutlet var cameraView: UIView?
    @IBOutlet var contentView: UIView?

    // Camera;
    var captureSession: AVCaptureSession! = nil
    var captureDeviceInput: AVCaptureDeviceInput! = nil
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer! = nil
    
    // Location;
    var locationManager: CLLocationManager! = nil
    var location: CLLocation! = nil
    
    // Motion Manager;
    var motionManager: CMMotionManager! = nil
    var accelerometerData: CMAccelerometerData! = nil
    
    // Display Link;
    var displayLink: CADisplayLink! = nil
    
    // Location Views;
    var placeViews: [PlaceView] = []
    
    // Matrix;
    var projectionTransform: mat4f = mat4f()
    var cameraTransform: mat4f = mat4f()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Projection Matrix ;
        createProjectionMatrix(&projectionTransform, 60.0 * DEGREES_TO_RADIANS, Float(contentView!.bounds.width) / Float(contentView!.bounds.height), 0.25, 1000.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start;
        startCamera()
        startLocationManager()
        startMotionManager()
        startDisplayLink()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop;
        stopCamera()
        stopLocationManager()
        stopMotionManager()
        stopDisplayLink()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location;
        location = locations.last
        
        // Request;
        APIClient.shared.places(location) { (places) in
            // Update;
            self.updateLocation(places)
        }
    }

    // MARK: - Camera
    func startCamera() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

        if captureDevice == nil {
            return
        }

        do {
            // Session;
            captureSession = AVCaptureSession()
            
            // Device Input;
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)

            // Video Preview Layer;
            captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            captureVideoPreviewLayer?.frame = UIScreen.main.bounds
            captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            cameraView?.layer.insertSublayer(captureVideoPreviewLayer, below: cameraView?.layer.sublayers?[0])
            
            DispatchQueue.main.async {
                self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
                self.captureSession.startRunning()
            }
        }
        catch {
        
        }
    }
    
    func stopCamera() {
        // Session;
        captureSession.stopRunning()
        captureSession.removeInput(captureDeviceInput)
        captureSession = nil
        
        // Device Input;
        captureDeviceInput = nil

        // Video Preview Layer;
        captureVideoPreviewLayer.removeFromSuperlayer()
        captureVideoPreviewLayer = nil
    }
    
    // MARK: - Location Manager
    func startLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.headingFilter = 1.0
        locationManager.distanceFilter = 1.0
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager = nil
    }
    
    // MARK: - Device Motion
    func startMotionManager() {
        motionManager = CMMotionManager()
        
        // Accelerometer;
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData, error) in
            self.accelerometerData = accelerometerData
        }
        
        // Motion;
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xTrueNorthZVertical, to: OperationQueue.current!) { (motionManager, error) in
            
        }
    }
    
    func stopMotionManager() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager = nil
    }

    // MARK: - Display Link
    func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLink))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func stopDisplayLink() {
        displayLink.invalidate()
        displayLink = nil
    }
    
    func onDisplayLink() {
        // Location?
        if location == nil {
            return
        }
        
        // PlaceViews?
        if placeViews.count == 0 {
            return
        }
        
        if let deviceMotion = motionManager.deviceMotion {
            let rotationMatrix = deviceMotion.attitude.rotationMatrix
            
            // Transform;
            transformFromCMRotationMatrix(&cameraTransform, rotationMatrix)
            
            // Update;
            updatePlaceViews()
        }
    }
    
    func placeView(didTapped place: Place!) {
        if place != nil {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            viewController.place = place
            self.present(viewController, animated: true, completion: { 
                
            })
        }
    }
    
    func updateLocation(_ places: [Place]) {
        // Remove;
        for placeView in placeViews {
            placeView.removeFromSuperview()
        }
        
        placeViews.removeAll()
        
        // Append;
        for place in places {
            let placeView = PlaceView.instanceFromNib()
            placeView.delegate = self
            placeView.place = place
            
            placeViews.append(placeView)
        }
    }
    
    func updatePlaceViews() {
        // Project Camera Transform;
        var projectionCameraTransform: mat4f = mat4f()
        
        multiplyMatrixAndMatrix(&projectionCameraTransform, projectionTransform, cameraTransform)

        // Current Location;
        var myX: Float = 0.0
        var myY: Float = 0.0
        var myZ: Float = 0.0
        
        latLonToEcef(Float(location.coordinate.latitude), Float(location.coordinate.longitude), 0.0, &myX, &myY, &myZ)
        
        // PlaceViews;
        for placeView in placeViews {
            // Place Location;
            var poiX: Float = 0
            var poiY: Float = 0
            var poiZ: Float = 0

            latLonToEcef(Float((placeView.place!.location?.coordinate.latitude)!), Float((placeView.place.location?.coordinate.longitude)!), 0.0, &poiX, &poiY, &poiZ)

            // ECEF Location;
            var e: Float = 0
            var n: Float = 0
            var u: Float = 0

            ecefToEnu(Float(location.coordinate.latitude), Float(location.coordinate.longitude), myX, myY, myZ, poiX, poiY, poiZ, &e, &n, &u)

            // Place Vector;
            var place: vec4f = vec4f()
            
            place.v1 = n
            place.v2 = -e
            place.v3 = 0.0
            place.v4 = 1.0

            // Vector;
            var vector: vec4f = vec4f()

            multiplyMatrixAndVector(&vector, projectionCameraTransform, place)
        
            // X, Y;
            let x: Float = (vector.v1 / vector.v4 + 1.0) * 0.5
            let y: Float = (vector.v2 / vector.v4 + 1.0) * 0.5

            if vector.v3 < 0.0 {
                // Add View;
                contentView?.addSubview(placeView)
                
                // Center;
                placeView.center = CGPoint(x: CGFloat(x) * (contentView?.bounds.width)!, y: (contentView?.bounds.height)! - CGFloat(y) * (contentView?.bounds.height)!)

                // Transform;
                var transform: CGAffineTransform =  CGAffineTransform()

                let rotation = atan2(-accelerometerData.acceleration.y, accelerometerData.acceleration.x) * 180 / 3.14
                if rotation > 0 {
                    transform = CGAffineTransform(rotationAngle: CGFloat(rotation - 90.0) * CGFloat(DEGREES_TO_RADIANS))
                }
                else {
                    transform = CGAffineTransform(rotationAngle: CGFloat(270.0 + rotation) * CGFloat(DEGREES_TO_RADIANS))
                }
                
                placeView.transform = transform;
            }
            else
            {
                placeView.removeFromSuperview()
            }
        }
    }
    
    
}
