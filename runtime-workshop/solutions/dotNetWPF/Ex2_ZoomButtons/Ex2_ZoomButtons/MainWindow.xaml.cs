using Esri.ArcGISRuntime.Mapping;
using Esri.ArcGISRuntime.Geometry;
using Esri.ArcGISRuntime.Symbology;
using Esri.ArcGISRuntime.Data;
using Esri.ArcGISRuntime.Portal;
using Esri.ArcGISRuntime.Security;
using Esri.ArcGISRuntime.UI;

using System;
using System.Diagnostics;
using System.Linq;
using System.Windows;

namespace Ex1_MapAndScene
{
    public partial class MainWindow : Window
    {
        private Map myMap = null;
        private static string ELEVATION_IMAGE_SERVICE =
        "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer";
        private Scene myScene = null;
        private bool threeD = false;
        
        public MainWindow()
        {
            InitializeComponent();

            //Exercise 1 create the UI, setup the control references, and execute initalization
            Initialize();
        }
        private void Initialize()
        {
            //Exercise 1: Create new Map with basemap and initial location
            myMap = new Map(Basemap.CreateStreetsVector());

            //Exercise 1: Assign the map to the MapView
            mapView.Map = myMap;
        }

        private void ViewButton_Click(object sender, RoutedEventArgs e)
        {
            //Change button to 2D or 3D when button is clicked
            ViewButton.Content = FindResource(ViewButton.Content == FindResource("3D") ? "2D" : "3D");
            if (ViewButton.Content == FindResource("2D"))
            {
                
                if (myScene == null)
                {
                    //Create a new scene
                    myScene = new Scene(Basemap.CreateImageryWithLabels());
                    sceneView.Scene = myScene;
                    // create an elevation source
                    var elevationSource = new ArcGISTiledElevationSource(new System.Uri(ELEVATION_IMAGE_SERVICE));
                    // create a surface and add the elevation surface
                    var sceneSurface = new Surface();
                    sceneSurface.ElevationSources.Add(elevationSource);
                    // apply the surface to the scene
                    sceneView.Scene.BaseSurface = sceneSurface;

                    // Exercise 2: Enable the lock focus button
                    LockButton.IsEnabled = true;
                }
                //Once the scene has been created hide the mapView and show the sceneView
                mapView.Visibility = Visibility.Hidden;
                sceneView.Visibility = Visibility.Visible;
                threeD = true;
            }
            else
            {
                
                sceneView.Visibility = Visibility.Hidden;
                mapView.Visibility = Visibility.Visible;
                threeD = false;
            }
        }

        //Exercise 2 Adding Lock Focus Button Click
        private void LockButton_Click(object sender, RoutedEventArgs e)
        {
            //Change button to lock or lock_selected when button is clicked
            LockButton.Content = FindResource(LockButton.Content == FindResource("LockFocusSelected") ? "LockFocus" : "LockFocusSelected");
            if (LockButton.Content == FindResource("LockFocusSelected"))
            {
                Geometry target = sceneView.GetCurrentViewpoint(ViewpointType.CenterAndScale).TargetGeometry;
                if (target.GeometryType == GeometryType.Point)
                {
                    Esri.ArcGISRuntime.Geometry.MapPoint targetPoint = (Esri.ArcGISRuntime.Geometry.MapPoint)target;
                    Camera currentCamera = sceneView.Camera;
                    Esri.ArcGISRuntime.Geometry.MapPoint currentCameraPoint = currentCamera.Location;
                    if (null != currentCameraPoint)
                    { 
                        double xyDistance = GeometryEngine.DistanceGeodetic(targetPoint, currentCameraPoint, LinearUnits.Meters, AngularUnits.Degrees, GeodeticCurveType.Geodesic).Distance;
                        double zDistance = currentCameraPoint.Z;
                        double distanceToTarget = Math.Sqrt(Math.Pow(xyDistance, 2.0) + Math.Pow(zDistance, 2.0));

                        OrbitLocationCameraController cameraController = new OrbitLocationCameraController((MapPoint)target, distanceToTarget);
                        cameraController.CameraHeadingOffset = currentCamera.Heading;
                        cameraController.CameraPitchOffset = currentCamera.Pitch;
                        sceneView.CameraController = cameraController;
                    }
                }
            }
            else
            {
                sceneView.CameraController = new GlobeCameraController();
            }
        }
        //Exercise 2
        private void ZoomInButton_Click(object sender, RoutedEventArgs e)
        {
            zoom(2);
        }
        //Exercise 2
        private void ZoomOutButton_Click(object sender, RoutedEventArgs e)
        {
            zoom(.5);
        }
        //Exercise 2
        private void zoom(double factor)
        {
            if (threeD)
            {
                zoomScene(factor);
            }
            else
            {
                zoomMap(factor);
            }
        }
        //Exercise 2
        private void zoomScene(double factor)
        {
            Esri.ArcGISRuntime.Geometry.Geometry target = sceneView.GetCurrentViewpoint(ViewpointType.CenterAndScale).TargetGeometry;
            if (target.GeometryType == GeometryType.Point)
            {
                Camera camera = sceneView.Camera.ZoomToward((Esri.ArcGISRuntime.Geometry.MapPoint)target, factor);
                sceneView.SetViewpointCameraAsync(camera, new TimeSpan(1000));
            }
        }
        //Exercise 2
        private void zoomMap(double factor)
        {
            mapView.SetViewpointScaleAsync(mapView.GetCurrentViewpoint(ViewpointType.CenterAndScale).TargetScale / factor);
        }
    }
}

