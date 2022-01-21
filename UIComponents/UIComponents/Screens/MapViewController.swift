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
        
        // Configurations
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
    // Long gesture recognizer
    func addLongGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPressGesture(_ :)))
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    // Objective-C funciton for long gesture recognizer
    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        destinationCoordinate = coordinate
        // Add an annotation in the place of the long gesture
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned"
        mapView.addAnnotation(annotation)
    }
    
    // Check the location permissions
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
    
    // Check the .isEnabled status of nextButton
    func configureNextButtonStatus() {
        if self.routeIndex < self.routeCount - 1 { self.nextButton.isEnabled = true }
        else { self.nextButton.isEnabled = false }
    }
    
    // Check the .isEnabled status of previousButton
    func configurePreviousButtonStatus() {
        if self.routeIndex > 0 { self.previousButton.isEnabled = true }
        else { self.previousButton.isEnabled = false }
    }
    
    
    //MARK: - IBActions
    @IBAction func showCurrentLocationTapped(_ sender: UIButton) {
        // Request the location
        locationManager.requestLocation()
    }
    
    @IBAction func drawRouteButtonTapped(_ sender: UIButton) {
        // Get the current and destination coordinates
        guard let currentCoordinate = currentCoordinate,
              let destinationCoordinate = destinationCoordinate else { return }
        
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let source = MKMapItem(placemark: sourcePlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destination = MKMapItem(placemark: destinationPlacemark)
        
        // Configure the direction request
        let directionRequest = MKDirections.Request()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: directionRequest)
        
        // Check for response after requesting the location
        direction.calculate { response, error in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            // Get the first route out of the response
            guard let route: MKRoute = response?.routes.first else { return }
            let polyline: MKPolyline = route.polyline
            self.routeCount = (response?.routes.count)!
            // Configure previous and next buttons
            self.configurePreviousButtonStatus()
            self.configureNextButtonStatus()
            
            // Switch the sender.tag
            switch sender.tag {
            case 0:
                // Case 0: for 'Draw route' button
                // Remove older overlays if existing, and add new ones
                self.mapView.removeOverlays(self.mapView.overlays)
                // Show all possible routes to the user in real time
                for i in 0...(self.routeCount - 1) {
                    guard let tempRoute: MKRoute = response?.routes[i] else { return }
                    let tempPolyline: MKPolyline = tempRoute.polyline
                    self.mapView.addOverlay(tempPolyline, level: .aboveLabels)
                }
                // Selected route is still the first one, so set routeIndex to 0
                self.routeIndex = 0
                // Configure previous and next buttons
                self.configureNextButtonStatus()
                self.configurePreviousButtonStatus()
                // Configure the region to focus on the route
                configureRegion()
                
            case 1:
                // Case 1: for 'previous' button
                self.routeIndex -= 1
                // Remove older overlays if existing
                self.mapView.removeOverlays(self.mapView.overlays)
                // Create and add new overlay
                guard let previousRoute: MKRoute = response?.routes[self.routeIndex] else { return }
                let previousPolyline: MKPolyline = previousRoute.polyline
                self.mapView.addOverlay(previousPolyline, level: .aboveLabels)
                print("hasan: route index: " + String(self.routeIndex + 1) + "/" + String(self.routeCount))
                // Configure previous and next buttons
                self.configurePreviousButtonStatus()
                self.configureNextButtonStatus()
                
            case 2:
                // Case 2: for 'next' button
                self.routeIndex += 1
                // Remove older overlays if existing
                self.mapView.removeOverlays(self.mapView.overlays)
                // Create and add new overlay
                guard let nextRoute: MKRoute = response?.routes[self.routeIndex] else { return }
                let nextPolyline: MKPolyline = nextRoute.polyline
                self.mapView.addOverlay(nextPolyline, level: .aboveLabels)
                print("hasan: route index: " + String(self.routeIndex + 1) + "/" + String(self.routeCount))
                // Configure previous and next buttons
                self.configurePreviousButtonStatus()
                self.configureNextButtonStatus()
                
            default:
                // Print error message for other cases
                print("error occurred, switch case out of bound")
            }
            
            // private function to configure and set the region to focus on the route
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
    // Function to run when location gets updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get the new coordinates
        guard let coordinate = locations.first?.coordinate else { return }
        currentCoordinate = coordinate
        print("latitude: \(coordinate.latitude)")
        print("longitude: \(coordinate.longitude)")
        // Set the center of the screen to focus on the route
        mapView.setCenter(coordinate, animated: true)
    }
    
    // Function to run when location authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }
    
    // Function to run if an error happens with location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
}

extension MapViewController: MKMapViewDelegate {
    // Configure the polyline for rendering
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .magenta
        renderer.lineWidth = 8
        return renderer
    }
}
