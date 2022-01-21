//
//  MapViewController.swift
//  UIComponents
//
//  Created by Semih Emre ÜNLÜ on 9.01.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    
    //MARK: - IBOutles
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationPermission()
        addLongGestureRecognizer()
        previousButton.isEnabled = false
        nextButton.isEnabled = false
    }
    
    //MARK: - Variables
    private var currentCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    private var routeIndex: Int  = 0
    private var routeCount: Int = 0
    
    //MARK: - Functions
    func addLongGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPressGesture(_ :)))
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        destinationCoordinate = coordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned"
        mapView.addAnnotation(annotation)
    }
    
    func checkLocationPermission() {
        switch self.locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.requestLocation()
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
    
    func configureNextButtonStatus() {
        if self.routeIndex < self.routeCount - 1 { self.nextButton.isEnabled = true }
        else { self.nextButton.isEnabled = false }
    }
    
    func configurePreviousButtonStatus() {
        if self.routeIndex > 0 { self.previousButton.isEnabled = true }
        else { self.previousButton.isEnabled = false }
    }
    
    
    //MARK: - IBActions
    @IBAction func showCurrentLocationTapped(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func drawRouteButtonTapped(_ sender: UIButton) {
        guard let currentCoordinate = currentCoordinate,
              let destinationCoordinate = destinationCoordinate else { return }
        
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let source = MKMapItem(placemark: sourcePlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destination = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate { response, error in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            guard let route: MKRoute = response?.routes.first else { return }
            let polyline: MKPolyline = route.polyline
            self.routeCount = (response?.routes.count)!
            print("hasan: routcount: ", self.routeCount)
            
            self.configurePreviousButtonStatus()
            self.configureNextButtonStatus()
            
            switch sender.tag {
            case 0:
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.addOverlay(polyline, level: .aboveLabels)
                self.routeIndex = 0
                
                self.configureNextButtonStatus()
                self.configurePreviousButtonStatus()
                
                configureRegion()
                
            case 1:
                print("hasan: previous")
                self.mapView.removeOverlays(self.mapView.overlays)
                self.routeIndex -= 1
                guard let previousRoute: MKRoute = response?.routes[self.routeIndex] else { return }
                let previousPolyline: MKPolyline = previousRoute.polyline
                self.mapView.addOverlay(previousPolyline, level: .aboveLabels)
                print("hasan: index: ", self.routeIndex)
                
                self.configurePreviousButtonStatus()
                self.configureNextButtonStatus()
                
            case 2:
                print("hasan: next")
                self.mapView.removeOverlays(self.mapView.overlays)
                self.routeIndex += 1
                guard let nextRoute: MKRoute = response?.routes[self.routeIndex] else { return }
                let nextPolyline: MKPolyline = nextRoute.polyline
                self.mapView.addOverlay(nextPolyline, level: .aboveLabels)
                print("hasan: index: ", self.routeIndex)
                print()
                
                self.configurePreviousButtonStatus()
                self.configureNextButtonStatus()
                
            default:
                print("error occurred")
            }
            
            func configureRegion() {
                let rect = polyline.boundingMapRect
                let region = MKCoordinateRegion(rect)
                self.mapView.setRegion(region, animated: true)
            }
            
        }
        
    }
    
    
}

//MARK: - Extensions
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        currentCoordinate = coordinate
        print("latitude: \(coordinate.latitude)")
        print("longitude: \(coordinate.longitude)")
        
        mapView.setCenter(coordinate, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .magenta
        renderer.lineWidth = 8
        return renderer
    }
}
