using Esri.ArcGISRuntime.UI;
using Esri.ArcGISRuntime.Mapping;
using Esri.ArcGISRuntime.Geometry;
using Esri.ArcGISRuntime.Symbology;
using Esri.ArcGISRuntime.Data;
using Esri.ArcGISRuntime.Portal;
using Esri.ArcGISRuntime.Security;

using System;
using System.Diagnostics;
using System.Linq;
using System.Windows;
using System.Windows.Media;

namespace Ex1_MapAndScene
{
    public partial class MainWindow : Window
    {
        private Map myMap = null;
        private static string ELEVATION_IMAGE_SERVICE =
        "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer";
        private Scene myScene = null;
        private bool threeD = false;
        private static string MMPK_PATH = @"..\..\data\DC_Crime_Data.mmpk";
        private static string SCENE_SERVICE_URL = "https://www.arcgis.com/home/item.html?id=606596bae9e44394b42621e099ba392a";
        ArcGISSceneLayer _sceneLayer;
        private SimpleMarkerSymbol CLICK_SYMBOL = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle.Circle, Colors.Orange, 10);
        private SimpleFillSymbol BUFFER_SYMBOL = new SimpleFillSymbol(SimpleFillSymbolStyle.Null, Colors.Transparent, new SimpleLineSymbol(SimpleLineSymbolStyle.Solid, Colors.Orange, 3));
        private GraphicsOverlay bufferAndQueryMapGraphics = new GraphicsOverlay();
        private GraphicsOverlay bufferAndQuerySceneGraphics = new GraphicsOverlay();

        public MainWindow()
        {
            InitializeComponent();

            //Exercise 1 create the UI, setup the control references, and execute initalization
            Initialize();
        }
        private async void Initialize()
        {
            //Exercise 1: Create new Map with basemap and initial location
            myMap = new Map(Basemap.CreateStreetsVector());

            //Exercise 1: Assign the map to the MapView
            mapView.Map = myMap;

            //Exercise 3: Add mobile map package to the map
            var mmpk = await MobileMapPackage.OpenAsync(MMPK_PATH);
            if (mmpk.Maps.Count >= 0)
            {
                myMap = mmpk.Maps[0];
                //Exercise 3: Mobile map package does not contain a basemap so must add one.
                myMap.Basemap = Basemap.CreateStreetsVector();
                mapView.Map = myMap;
            }
            mapView.GraphicsOverlays.Add(bufferAndQueryMapGraphics);
        }

        private void ViewButton_Click(object sender, RoutedEventArgs e)
        {
            //Change button to 2D or 3D when button is clicked
            ViewButton.Content = FindResource(ViewButton.Content == FindResource("3D") ? "2D" : "3D");
            if (ViewButton.Content == FindResource("2D"))
            {
                threeD = true;
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
                    sceneView.Scene = myScene;

                    // Exercise 2: Enable the lock focus button
                    LockButton.IsEnabled = true;

                    _sceneLayer = new ArcGISSceneLayer(new Uri(SCENE_SERVICE_URL));
                    myScene.OperationalLayers.Add(_sceneLayer);

                    //Make sure layer is loaded
                    _sceneLayer.LoadStatusChanged += SceneLayer_LoadStatusChanged;

                }
                
                //Exercise 1 Once the scene has been created hide the mapView and show the sceneView
                mapView.Visibility = Visibility.Hidden;
                sceneView.Visibility = Visibility.Visible;
                
            }
            else
            {
                threeD = false;
                sceneView.Visibility = Visibility.Hidden;
                mapView.Visibility = Visibility.Visible;
            }
        }
        private async void SceneLayer_LoadStatusChanged(object sender, Esri.ArcGISRuntime.LoadStatusEventArgs e)
        {
            // If layer isn't loaded, do nothing
            if (e.Status != Esri.ArcGISRuntime.LoadStatus.Loaded)
                return;

            sceneView.SetViewpoint(new Viewpoint(_sceneLayer.FullExtent));

            //Rotate the camera
            sceneView.SetViewpoint(new Viewpoint(_sceneLayer.FullExtent));
            Viewpoint viewpoint = sceneView.GetCurrentViewpoint(ViewpointType.CenterAndScale);
            Esri.ArcGISRuntime.Geometry.MapPoint targetPoint = (MapPoint)viewpoint.TargetGeometry;
            Camera camera = sceneView.Camera.RotateAround(targetPoint, 45.0, 65.0, 0.0);

            await sceneView.SetViewpointCameraAsync(camera);
        }
        private void LockButton_Click(object sender, RoutedEventArgs e)
        {
            if (threeD)
            {
                //Change button to lock or lock_selected when button is clicked
                LockButton.Content = FindResource(LockButton.Content == FindResource("LockFocusSelected") ? "LockFocus" : "LockFocusSelected");
                if (LockButton.Content == FindResource("LockFocusSelected"))
                {
                    Esri.ArcGISRuntime.Geometry.Geometry target = sceneView.GetCurrentViewpoint(ViewpointType.CenterAndScale).TargetGeometry;
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

        private void QueryandBufferButton_Click(object sender, RoutedEventArgs e)
        {
            if (!threeD)
            {
                //Change Query button to Selected image
                QueryandBufferButton.Content = FindResource(QueryandBufferButton.Content == FindResource("Location") ? "LocationSelected" : "Location");
                if (QueryandBufferButton.Content == FindResource("LocationSelected"))
                {
                    mapView.GeoViewTapped += OnView_Tapped;
                }
                else
                {

                    mapView.GeoViewTapped -= OnView_Tapped;
                    bufferAndQueryMapGraphics.Graphics.Clear();
                    bufferAndQuerySceneGraphics.Graphics.Clear();
                    LayerCollection operationalLayers;
                    
                    operationalLayers = mapView.Map.OperationalLayers;
                    foreach (Layer layer in operationalLayers)
                    {
                        ((FeatureLayer)layer).ClearSelection();
                    }
                }
            }
        }

        private void OnView_Tapped(object sender, Esri.ArcGISRuntime.UI.Controls.GeoViewInputEventArgs e)
        {
            if (!threeD)
            {
                MapPoint geoPoint = getGeoPoint(e);
                geoPoint = (MapPoint)GeometryEngine.Project(geoPoint, SpatialReference.Create(3857));
                Polygon buffer = (Polygon)GeometryEngine.Buffer(geoPoint, 1000.0);

                GraphicCollection graphics = bufferAndQueryMapGraphics.Graphics;
                graphics.Clear();
                graphics.Add(new Graphic(buffer, BUFFER_SYMBOL));
                graphics.Add(new Graphic(geoPoint, CLICK_SYMBOL));

                Esri.ArcGISRuntime.Data.QueryParameters query = new Esri.ArcGISRuntime.Data.QueryParameters();
                query.Geometry = buffer;
                LayerCollection operationalLayers;
                
                operationalLayers = mapView.Map.OperationalLayers;
                foreach (Layer layer in operationalLayers)
                {
                    ((FeatureLayer)layer).SelectFeaturesAsync(query, SelectionMode.New);
                }
            }
        }
        private MapPoint getGeoPoint(Esri.ArcGISRuntime.UI.Controls.GeoViewInputEventArgs point)
        {
            MapPoint geoPoint = null;
            Point screenPoint = new Point(point.Position.X, point.Position.Y);
            if (!threeD)
            {
                geoPoint = mapView.ScreenToLocation(screenPoint);
            }
            
            return geoPoint;
        }
    }
}

