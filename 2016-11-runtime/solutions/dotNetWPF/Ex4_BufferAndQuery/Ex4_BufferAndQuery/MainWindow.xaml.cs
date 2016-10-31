using Esri.ArcGISRuntime.UI;
using Esri.ArcGISRuntime.Mapping;
using Esri.ArcGISRuntime.Geometry;
using Esri.ArcGISRuntime.Symbology;
using Esri.ArcGISRuntime.Data;
using Esri.ArcGISRuntime.Tasks.NetworkAnalyst;
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
            myMap = new Map(Basemap.CreateNationalGeographic());
            //Exercise 1: Assign the map to the MapView
            mapView.Map = myMap;

            //Exercise 3: Add mobile map package to the map
            var mmpk = await MobileMapPackage.OpenAsync(MMPK_PATH);
            if (mmpk.Maps.Count >= 0)
            {
                myMap = mmpk.Maps[0];
                //Exercise 3: Mobile map package does not contain a basemap so must add one.
                myMap.Basemap = Basemap.CreateNationalGeographic();
                mapView.Map = myMap;
            }
            mapView.GraphicsOverlays.Add(bufferAndQueryMapGraphics);
        }

        private async void ViewButton_Click(object sender, RoutedEventArgs e)
        {
            //Change button to 2D or 3D when button is clicked
            ViewButton.Content = FindResource(ViewButton.Content == FindResource("3D") ? "2D" : "3D");
            if (ViewButton.Content == FindResource("2D"))
            {
                threeD = true;
                if (myScene == null)
                {
                    //Create a new scene
                    myScene = new Scene(Basemap.CreateNationalGeographic());
                    sceneView.Scene = myScene;
                    // create an elevation source
                    var elevationSource = new ArcGISTiledElevationSource(new System.Uri(ELEVATION_IMAGE_SERVICE));
                    // create a surface and add the elevation surface
                    var sceneSurface = new Surface();
                    sceneSurface.ElevationSources.Add(elevationSource);
                    // apply the surface to the scene
                    sceneView.Scene.BaseSurface = sceneSurface;

                    //Exercise 3: Open mobie map package (.mmpk) and add its operational layers to the scene
                    var mmpk = await MobileMapPackage.OpenAsync(MMPK_PATH);

                    if (mmpk.Maps.Count >= 0)
                    {
                        myMap = mmpk.Maps[0];
                        LayerCollection layerCollection = myMap.OperationalLayers;

                        for (int i = 0; i < layerCollection.Count(); i++)
                        {
                            var thelayer = layerCollection[i];
                            myMap.OperationalLayers.Clear();
                            myScene.OperationalLayers.Add(thelayer);
                            sceneView.SetViewpoint(myMap.InitialViewpoint);
                            //Rotate the camera
                            Viewpoint viewpoint = sceneView.GetCurrentViewpoint(ViewpointType.CenterAndScale);
                            Esri.ArcGISRuntime.Geometry.MapPoint targetPoint = (MapPoint)viewpoint.TargetGeometry;
                            Camera camera = sceneView.Camera.RotateAround(targetPoint, 45.0, 65.0, 0.0);
                            await sceneView.SetViewpointCameraAsync(camera);
                        }
                        sceneView.Scene = myScene;
                        bufferAndQuerySceneGraphics.SceneProperties.SurfacePlacement = SurfacePlacement.Draped;
                        sceneView.GraphicsOverlays.Add(bufferAndQuerySceneGraphics);
                    }
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
            mapView.SetViewpointScaleAsync(mapView.GetCurrentViewpoint(ViewpointType.CenterAndScale).Scale / factor);
        }

        private void QueryandBufferButton_Click(object sender, RoutedEventArgs e)
        {
            //Change Query button to Selected image
            QueryandBufferButton.Content = FindResource(QueryandBufferButton.Content == FindResource("Location") ? "LocationSelected" : "Location");
            if (QueryandBufferButton.Content == FindResource("LocationSelected"))
            {
                if (sceneView != null)
                    sceneView.GeoViewTapped += OnView_Tapped;
                mapView.GeoViewTapped += OnView_Tapped;
            }       
            else
            {

                mapView.GeoViewTapped -= OnView_Tapped;
                sceneView.GeoViewTapped -= OnView_Tapped;
                bufferAndQueryMapGraphics.Graphics.Clear();
                bufferAndQuerySceneGraphics.Graphics.Clear();
                LayerCollection operationalLayers;
                if (threeD)
                    operationalLayers = sceneView.Scene.OperationalLayers;
                else
                    operationalLayers = mapView.Map.OperationalLayers;
                foreach (Layer layer in operationalLayers)
                {
                    ((FeatureLayer)layer).ClearSelection();
                }
            }
        }

        private void OnView_Tapped(object sender, Esri.ArcGISRuntime.UI.GeoViewInputEventArgs e)
        {
            MapPoint geoPoint = getGeoPoint(e);
            geoPoint = (MapPoint)GeometryEngine.Project(geoPoint, SpatialReference.Create(3857));
            Polygon buffer = (Polygon)GeometryEngine.Buffer(geoPoint, 1000.0);

            GraphicCollection graphics = (threeD ? bufferAndQuerySceneGraphics : bufferAndQueryMapGraphics).Graphics;
            graphics.Clear();
            graphics.Add(new Graphic(buffer, BUFFER_SYMBOL));
            graphics.Add(new Graphic(geoPoint, CLICK_SYMBOL));

            Esri.ArcGISRuntime.Data.QueryParameters query = new Esri.ArcGISRuntime.Data.QueryParameters();
            query.Geometry = buffer;
            LayerCollection operationalLayers;
            if (threeD)
                operationalLayers = sceneView.Scene.OperationalLayers;
            else
                operationalLayers = mapView.Map.OperationalLayers;
            foreach (Layer layer in operationalLayers)
            {
                ((FeatureLayer)layer).SelectFeaturesAsync(query, SelectionMode.New);
            }
        }
        private MapPoint getGeoPoint(GeoViewInputEventArgs point)
        {
            MapPoint geoPoint = null;
            Point screenPoint = new Point(point.Position.X, point.Position.Y);
            if (threeD)
            {
                geoPoint = sceneView.ScreenToBaseSurface(screenPoint);
            }
            else
            {
                geoPoint = mapView.ScreenToLocation(screenPoint);
            }
            return geoPoint;
        }
    }
}

