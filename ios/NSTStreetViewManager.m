//
//  NSTStreetViewManager.m
//  react-native-streetview
//
//  Created by Amit Palomo on 26/04/2017.
//  Copyright © 2019 Nester.co.il.
//

#import <Foundation/Foundation.h> // NM Suppression car ne sert à rien je pense:
// https://www.tutorialspoint.com/objective_c/objective_c_foundation_framework.htm 
// https://developer.apple.com/documentation/foundation?language=objc
// -> En fait bizazrre j'ai l'impression qu'il le faut mais ca marche sans donc ???
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h> // Pour pouvoir appeler des fonctions RCT_EXPORT_METHOD
#import <React/RCTConvert+CoreLocation.h>
#import "NSTStreetView.h"
#import <React/RCTLog.h>// NM to test RCTLogInfo 
//@import GoogleMaps; // NM Supprimé car ne sert à rien ici puisque c'est déclaré dans NSTStreetView.h

// NM:
// https://reactnative.dev/docs/native-components-ios#events
// Native views are created and manipulated by subclasses of RCTViewManager. These subclasses are similar in function to view controllers
// They expose native views to the RCTUIManager, which delegates back to them to set and update the properties of the views as necessary. The RCTViewManagers are also typically the delegates for the views, sending events back to JavaScript via the bridge.
// To expose a view you can:
// - Subclass RCTViewManager to create a manager for your component.
// - Add the RCT_EXPORT_MODULE() marker macro.
// - Implement the -(UIView *)view method.

// NM: create a Manager for the component by creating a subclass of RCTViewManager
// NM Modif
// -> J'ai rajouté le nom du delegate <GMSPanoramaViewDelegate>  qui gère les events Google Street Map
// Il était avant déclaré dans NSStreetView.h -> Je l'ai remis ici comme dans la doc RN
// Ca permet de pouvoir gérer des events comme onXXXComplete 
// https://reactnative.dev/docs/native-components-ios#events
// Dans cette doc ils disent:
// it is a delegate for all the views it exposes, and forward events to JS by calling the event handler block from the native view.
// Par contre dans cette doc ils avaient mis le delegate dans l'équivalent de NSTStreetViewMaanger et pas ici
// -> liste des events Google StreetView ici gérés par le delegate GMSPanoramaViewDelegate: https://developers.google.com/maps/documentation/ios-sdk/reference/protocol_g_m_s_panorama_view_delegate-p
//@interface NSTStreetViewManager : RCTViewManager
@interface NSTStreetViewManager : RCTViewManager <GMSPanoramaViewDelegate>
@end

@implementation NSTStreetViewManager

// NM: Name to export the module.
// Si on ne spécfifie rien par défaut il va prendre NSTStreetViewManager apparemment
// If you do not specify a name, the JavaScript module name will match the Objective-C class name, with any "RCT" or "RK" prefixes removed.
// Without passing in a name this will export the native module name as the Objective-C class name with “RCT” removed
RCT_EXPORT_MODULE(NSTStreetView) // custom export name
//RCT_EXPORT_MODULE()

// NM: We create the View de type UIView
- (UIView *)view {
  //RCTLogInfo(@"Test RCTLogInfo TEST"); // Test log
  // NM: https://developers.google.com/maps/documentation/ios-sdk/streetview#maps_ios_streetview_add-objective-c
  // NSTStreetView est déclaré comme étant un GMSPanoramaView dans NSTStreetView.h
  //NSTStreetView *panoView = [[NSTStreetView alloc] initWithFrame:CGRectZero]; // NM CGRectZero est une constante pour définir la taille de la the map's frame: A rectangle constant with location (0,0), and width and height of 0 -> https://developer.apple.com/documentation/coregraphics/cgrectzero?language=objc
  NSTStreetView *panoView = [[NSTStreetView alloc] initWithFrame:CGRectZero];
  // -> Dans la doc RN ils utilisent alloc init puis new, et dans la doc Google ils utilisent alloc
  // -> en fait il n'y a pas de diff entre les 2
  // https://stackoverflow.com/questions/719877/use-of-alloc-init-instead-of-new
  
  // NM modif pour avoir la meme conf que dans la doc RN
  //panoView.delegate = panoView; //NM suppression
  panoView.delegate = self; // Dans la doc RN -> Si on ne le met pas on n'intercpte plus les events du delegate
  // Ce n'est pas dans la doc Google StreetView mais dans la doc Google map ils déclarent le delegate de la meme facon: mapView.delegate = self
  
  // Dans la doc Google il y a la ligne suivante mais ca me donne l'erreur: No setter method 'setView:' for assignment to property. J'imagine qu'il n'y en a pas besoin avec RN car la config de la View est différente
  // self.view = panoView; 
  
  //printf("Initialisation -----");
  // On peut modifier ici toutes les propriétés qu'on ne gère pas avec RN
  //panoView.navigationLinksHidden= true;
    
  return panoView;
}

// NM: vu ici: https://blog.logrocket.com/build-native-ui-components-react-native/
// We’ve also added a requiresMainQueueSetup method, which will run our component on the main thread.
// Je ne sais pas si ca fonctionne ou pas
// En tout je trouve que j'e n'ai plus de blocage de la map quand je repasse de street View à la map classique
// Autre explication ici: https://stackoverflow.com/questions/50773748/difference-requiresmainqueuesetup-and-dispatch-get-main-queue
// https://medium.com/@abhisheknalwaya/react-native-bridge-for-ios-and-android-43feb9712fcb
// To understand it better let's understand about all the thread React Native runs:
// Main thread: where UIKit work
// Shadow queue: where the layout happens
// JavaScript thread: where your JS code is actually running
//
// https://teabreak.e-spres-oh.com/swift-in-react-native-the-ultimate-guide-part-1-modules-9bb8d054db03
// You might get a warning telling you that you didn’t implement the requiresMainQueueSetup method. This happens when you use constantsToExport or have implemented an init() method for UIKit components
// https://react-mongolia.github.io/react-native/docs/native-modules-ios
//If you override - constantsToExport then you should also implement + requiresMainQueueSetup to let React Native know if your module needs to be initialized on the main thread. Otherwise you will see a warning that in the future your module may be initialized on a background thread unless you explicitly opt out with + requiresMainQueueSetup
// FINALEMENT PAS CERTAIN d'EN AVOIR BESOIN
/*
+ (BOOL)requiresMainQueueSetup {
    return YES; // only do this if your module initialization relies on calling UIKit!
}
*/

// NM Attention RCT_EXPORT_VIEW_PROPERTY permet de setter directement des propriétés natives de GMSPanoramaView ayant exactement le meme nom
// En fait il s'agit des proprétés de NSTStreetiew qu'on a déclaré comme étant une sous-classe de GMSPanoramaView
// NSTStreetiew reprend les mêmes propriétés que GMSPanoramaView
// Et on peut rajouter nos propres propriétés à NSTStreetiew via NSTStreetView.h en utilisant @property 
// On peut par exemple rajouter des propriétés pour stocker des valeurs de props passées en paramètre et y accéder dans d'autres fonctions par ex
// On peut aussi créer des propriétés pour gérer des props de type fonction pour gérer les events -> voir ex pour le rajout de l'event onSuccess -> @property (nonatomic,copy) RCTDirectEventBlock onSuccess;
RCT_EXPORT_VIEW_PROPERTY(allGesturesEnabled, BOOL);
RCT_EXPORT_VIEW_PROPERTY(streetNamesHidden, BOOL);
RCT_EXPORT_VIEW_PROPERTY(navigationGestures, BOOL); //NM Ajout
RCT_EXPORT_VIEW_PROPERTY(radius, double); // NM ajout pour rajouter une props radius
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock);
//RCT_EXPORT_VIEW_PROPERTY(onSuccess, RCTDirectEventBlock); // NM remplacé par _onLocationChange
RCT_EXPORT_VIEW_PROPERTY(onCameraChange, RCTBubblingEventBlock); // Ajout NM -> J'ai utilisé RCTBubblingEventBlock car dans React-native-maps c'est ce qu'ils ont utilisé pour ce type d'event. J'ai pas compris la diiféérence avec RCTDirectEventBlock
RCT_EXPORT_VIEW_PROPERTY(onLocationChange, RCTDirectEventBlock); // Ajout NM 

// Si on a des props qui n'ont pas le meme nom que les propriété natives on peut modifier le nom avec RCT_REMAP_VIEW_PROPERTY
// Voir exemple dans react-native/packages/react-native/React/Views/RCTSwitchManager.m
RCT_REMAP_VIEW_PROPERTY(zoomEnabled, zoomGestures, BOOL); // Ajout NM

// Pour les propriétés passées en props du composant et qui ne sont pas des propriétés de NSTStreetiew
// il faut utiliser RCT_CUSTOM_VIEW_PROPERTY
// Ca permet de récupérer la props et de faire une action avec celle-ci si on ne souhaite pas la sauvegarder comme propriété de NSTStreetiew

// NM Comment
// coordinate: RN component props name
// -> recoit {longitude, latitude, radius}
// NSTStreetView -> use the same name as the return type used in the UIView at the end of the file
// CLLocationCoordinate ??? -> n'existe meme pas comme type et meme en mettant n'importe quoi ca fonctionne
//   -> Bizzarre car normallement je comprends que c'est le type des datas contenues dans le json relatif à la props -> en fait j'imagine que c'est pour convertir automatiquement la valeur de json au format objective-C ????
//
// Si besoin je peux passer CLLocationCoordinate2D à la place de CLLocationCoordinate qui n'existe pas
// et supprimer le radius des props ou passer le radius dans une autre props ????
// -> C'est ce que j'ai fait -> OK
RCT_CUSTOM_VIEW_PROPERTY(coordinate, CLLocationCoordinate2D /*CLLocationCoordinate*/, NSTStreetView) {
  // Si pas de valeur pour le paramètre
  if (json == nil) return; 

  // Modif NM
  // Je récupère le radius dans une nouvelle props radius que j'ai rajouté
  // plutot que de récupérer le radius dans les coordonnées car pas logique
  NSInteger radius= view.radius; // On transforme en Integer car pas pas besoin de précision
  /*
  // NM: We extract radius from the JSON parameters
  NSInteger radius = [[json valueForKey:@"radius"] intValue];
  // NM Other way not tested to do it https://reactnative.dev/docs/native-components-ios
  //json = [self NSDictionary:json];
  //NSInteger radius= [json[@"radius"]]
  */

  // NM: default Value if not specified
  // On met 50 par défaut
  if(radius == 0){
    radius = 50;
  }

  //printf ("Radius");
  //printf ("%ld\n", radius);

  // J'ai testé RCTLogInfo mais bizzarre il m'affiche une erreur meme quand j'affiche juste du texte -> Error setting property 'coordinate' of NSTStreetView with tag #445: Test RCTLogInfo TEST
  //RCTLogInfo(@"Test RCTLogInfo %ld", radius);
  //RCTLogInfo(@"Test RCTLogInfo TEST");

  // NM: Extract the {longitude, latitude} value from the json and create a CLLocationCoordinate2D via RCTConvert 
  [view moveNearCoordinate:[RCTConvert CLLocationCoordinate2D:json]
                    radius: radius
                    //source: kGMSPanoramaSourceOutside // On ne recherche que les panorama à l'extérieur -> attention à bien mettre le meme paramètre que l'API https://maps.googleapis.com/maps/api/streetview/metadata? dans MapScreen
                    // Bizzare ca n'a pas l'air de fonctionner ce filtre
                    // En fait si mais c'est bizzarre car ca filtre par ex le point de vue StreetView au milieu du bassin de la sourderie
                    // et ca ne filtre pas le le StreetView dans le chateau de Versailles par ex donc je l'enlève.
                    ];
}

RCT_CUSTOM_VIEW_PROPERTY(heading, CLLocationDegrees, NSTStreetView) {
  if (json == nil) return;
  view.camera = [GMSPanoramaCamera cameraWithHeading:[RCTConvert CLLocationDegrees:json] pitch:0 zoom:1];
}

// NM ajout
// CLLocationDegrees indique le type de data reçu mais je ne comprend pas à quoi ca sert car ca ne change rien.
// Et en plus le type CLLocationDegrees n'existe pas et ca fonctionne en mettant n'importe quoi !!???
RCT_CUSTOM_VIEW_PROPERTY(pov, CLLocationDegrees, NSTStreetView) {

  if (json == nil) return;

   // On récupère les datas du pov
   // On transforme en entier mais je pourrais transformer en double ou NSNumber je pense ???
   NSInteger tilt = [[json valueForKey:@"tilt"] floatValue];
   NSInteger bearing = [[json valueForKey:@"bearing"] floatValue];
   NSInteger zoom = [[json valueForKey:@"zoom"] floatValue];
   NSInteger fov = [[json valueForKey:@"fov"] floatValue];
   
   // Si le fov est 0 je remet le fov par défaut à 90°
   //if (fov == 0){
   // fov = 90;
   //}

    
   // NM: Attention c'est un constructeur donc ca doit créer une nouvelle Camera
   // plutot que de modifier la camera existante.
   // Oui mais j'ai essayé de modifier directement view.camera.zoom par ex et il me dit que c'est en lecture seule
   
   //Si le fov est 0 on utilise une fonction différente sans le paramaètre du Fov
   // Ca arrive quand le Fov n'est pas spécifié par ex
   if (fov == 0){
        //printf ("fov----- %ld", fov);
        view.camera = [GMSPanoramaCamera cameraWithHeading:bearing pitch:tilt zoom:zoom];
   }
   else {
        view.camera = [GMSPanoramaCamera cameraWithHeading:bearing pitch:tilt zoom:zoom FOV:fov];       
   }

}


// Export des méthodes
// Attention obligé de spécifier nonnull sinon j'ai le message suivant
// Argument 0 (NSNumber) of NSTStreetView.updatePitch has unspecified nullability but React requires that all NSNumber arguments are explicitly marked as `nonnull` to ensure compatibility with Android.
// Attention pour que les méthode RCT_EXPORT_METHOD aient accès à la View et puissent accéder aux paramètres
// il faut passer l'ID de la View -> voir la fonction setFov
// Je n'en ai pas besoin ici car j'ai juste besoin d'un GMSPanoramaService que je rédéclare à chaque appel
// Pour passer la localisation j'ai trouvé l'exemple dans la fonction 
// RCT_EXPORT_METHOD(animateCamera:(nonnull NSNumber *)reactTag
//                  withCamera:(id)json
//                  withDuration:(CGFloat)duration)
// de https://github.com/react-native-maps/react-native-maps/blob/master/ios/AirMaps/AIRMapManager.m
// Je ne sais pas à quoi correspond le type id -> apparemment ce serait un json
RCT_EXPORT_METHOD(isStreetViewAvailable:(id) json){
    RCTLogInfo(@"isStreetViewAvailable Function");
    
    // Récupération du Json dans un NSDictionary
    //NSDictionary *deserializedDictionary = (NSDictionary *)json;
    //NSLog(@"Deserialized JSON Dictionary = %@", deserializedDictionary);
    //double latitude2= [deserializedDictionary[@"latitude"] doubleValue]; // il faut rajouter @ car c'est un pointeur -> Xcode qui indique l'erreur sinon
    //double longitude2= [deserializedDictionary[@"longitude"] doubleValue];
    //NSString * longitude2String= [deserializedDictionary[@"longitude"] stringValue];
    //NSString * latitude2String= [deserializedDictionary[@"latitude"] stringValue];
    //printf ("COORDINATE LATITUDE3: %lf\n", latitude2);
    //printf ("COORDINATE LATITUDE3: %lf\n", latitude2);
    //NSLog (@"COORDINATE LONGITUDE3String: %@\n", longitude2String);
    
    // on peut aussi créer un CLLocationCoordinate2D avec la fonction:
    // CLLocationCoordinate2DMake(latitude, longitude)

    // J'avais l'erreur suivante meme juste pour la déclaration de GMSPanoramaService
    // Exception 'The API method must be called from the main thread' was thrown while invoking isStreetViewAvailable on target NSTStreetView with params (
    // Du coup je me suis posé la question Est-ce que ce n'est pas du fait qu'il me manque une conf de bridging que je n'ai pas utilisé car j'ai utilisé la conf RN pour les Natives UI Component et pas les Natives Modules ???
    // https://reactnative.dev/docs/native-modules-ios
    //    #import <React/RCTBridgeModule.h>
    //    @interface RCTCalendarModule : NSObject <RCTBridgeModule>
    //    @end
    // En fait j'ai trouvé une solution pour exécuter le code dans le main thread ici
    // https://stackoverflow.com/questions/42665696/gmsthreadexception-reason-the-api-method-must-be-called-from-the-main-thread
    // il faut encapsuler le code dans: 
    // dispatch_async(dispatch_get_main_queue(), ^{
    //  ......
    // }
    // ou 
    // dispatch_sync(dispatch_get_main_queue(), ^{
    // Touts les types de dispatch: https://developer.apple.com/documentation/dispatch/1453050-dispatch_apply?language=objc
     dispatch_async(dispatch_get_main_queue(), ^{
     //dispatch_sync(dispatch_get_main_queue(), ^{
        GMSPanoramaService *panoramaService = [[GMSPanoramaService alloc] init];
        //panoramaService-> = self; 
        // On convertit le json en CLLocationCoordinate2D via RCTConvert
 
        CLLocationCoordinate2D coordinate= [RCTConvert CLLocationCoordinate2D:json];
        // On peut aussi récupérer séparément les infos du Json via:
        //double latitude = [[json valueForKey:@"latitude"] doubleValue];
        //double longitude = [[json valueForKey:@"longitude"] doubleValue];
        //NSString longitudeString = [[json valueForKey:@"latitude"] ];
        //NSString latitudeString = [[json valueForKey:@"latitude"] NSString];
        //printf ("COORDINATE LATITUDE: %lf\n", latitude);
        //printf ("COORDINATE LATITUDE: %f\n", latitudeString);
        
        //printf ("COORDINATE: %lf\n", coordinate.latitude);
        //printf ("COORDINATE: %lf\n", coordinate.longitude);

        //double lat1=48.76501639934256;//2.021775709818229;
        //double lon1=2.017590167202087;//48.76655458960042; 
        //coordinate.latitude= 48.76328344946861;//lat1;//[latitude2String doubleValue];//latitude2;//(double) 48.766788;//48.766203810004576;
        //coordinate.longitude= 2.024157342544555;//lon1;//[longitude2String doubleValue]; //(double) 2.021918;//2.0215024579056546;
        //printf ("COORDINATE2: %lf\n", coordinate.latitude);
        //printf ("COORDINATE2: %lf\n", coordinate.longitude);
        // Attentio: printf n'affiche que les 6 premiers digits
        
        NSInteger radius=50;

        // requestPanoramaNearCoordinate pour savoir si StreetView est dispo pour une loc en précisant un rayon
        // -> https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_service#af5251a07c154f056f6b4a7f311bec3da
        // https://stackoverflow.com/questions/29373691/gmspanoramaservice-requestpanoramanearcoordinate-no-result
        // https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_service#a8ad164bc6cb1f858e5ce864d5f17c2ee
        // Callback for when a panorama metadata becomes available.
        // If an error occurred, panorama is nil and error is not nil. Otherwise, panorama is not nil and error is nil.
        // Info callback aussi ici: https://stackoverflow.com/questions/18137219/obj-c-usage-of-callbacks
        // ici aussi: https://stackoverflow.com/questions/20923297/gmspanoramaview-blank-screen
        // -> Bon ben c'est bizzarre
        // j'ai l'impression que le callback n'est appellé que si la loc est exactement une loc où street view est dispo
        // et donc j'ai l'impression que radius ne fonctionne pas
        // par contre c'est bizzare que le callback ne soit pas appelé quand la loc n'est pas dispo car on devrait avoir une erreur !!!
        // Bizzarre car si je réécrase les valeur de coordinate en faisant coordinate.latitude= 48.76328344946861; j'ai bien le callback sauf si dans le radius il n' ya a pas de streetview dispo mais pourquoi le callback ne se déclenche pas dans ce cas avec l'error ????
        // BUG ?????? Faudrait essayer avec une nouvelle version du SDK map IOS
        // Et une fois que j'aurais résolu ce pb il faudra gérer le retour de la dispo dans une promesse -> voir doc https://reactnative.dev/docs/native-modules-ios#promises
        [panoramaService requestPanoramaNearCoordinate:coordinate radius:500 /* CLLocationCoordinate2DMake(latitude, longitude)*/ //
            // Fonction de callback
            callback:^(GMSPanorama * /*_Nullable*/ panorama, NSError * /*_Nullable*/ error) {
                
                //printf ("PANORAMA SERVICE\n");
                NSLog(@"the service returned a panorama=%@ and an error=%@", panorama, error);
                //NSLog (@"PANORAMA SERVICE");
                if (error) {
                    //NSLog(@"StreetView is not available at latlong = %f,%f", coordinate.latitude, coordinate.longitude);
                    //return;
                }
                else{
                    //NSLog(@"StreetView is available at latlong = %f,%f", coordinate.latitude, coordinate.longitude);

                }
            
            }
        ];
     });
   
   
    
    
    


}

// A SUPPRIMER
RCT_EXTERN_METHOD(
  updateFromManager:(nonnull NSNumber *)node
  count:(nonnull NSNumber *)count

  view.camera = [GMSPanoramaCamera cameraWithHeading:100.0 pitch:45.0 zoom:1.0 FOV:90.0];
)

// Fonction exportées appelables
// Pour résumer afin de povoir accéder aux propriétés de ma View NSTStreetView et de la controller
// j'ai besoin de récupérer au préalable l'id viewTag de la view passé en paramètre 
// Doc ici meme si la plupart concerne Swift:
// https://reactnative-archive-august-2023.netlify.app/docs/native-components-ios#handling-multiple-native-views -> voir rubrique handling multiple view qui est similaire
// https://www.callstack.com/blog/handling-multiple-native-ios-views-in-react-native
// https://blog.logrocket.com/build-native-ui-components-react-native/
// https://teabreak.e-spres-oh.com/swift-in-react-native-the-ultimate-guide-part-2-ui-components-907767123d9e
// https://medium.com/@jjdanek/react-native-calling-class-methods-on-native-swift-views-521faf44f3dc
//
// Autre exemple un peu différent: https://pspdfkit.com/blog/2018/how-to-extend-react-native-api/
// This exported function will find a particular view using addUIBlock which contains the viewRegistry parameter and returns the component based on reactTag allowing it to call the method on the correct component.
// Attention obligé de spécifier nonnull sinon j'ai le message suivant
// Argument 0 (NSNumber) of NSTStreetView.updatePitch has unspecified nullability but React requires that all NSNumber arguments are explicitly marked as `nonnull` to ensure compatibility with Android.
RCT_EXPORT_METHOD(setFov:(nonnull NSNumber*) viewTag fov:(nonnull NSNumber *) fov) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,/*UIView*/ NSTStreetView *> *viewRegistry) {
        // Attention dans la doc RN et des example que j'ai trouvé il y avait:
        // NativeView *view = viewRegistry...
        // Mais Xcode me remontait une erreur comme quoi il ne connaissait pas NativeView
        // Dans cette ex https://blog.logrocket.com/build-native-ui-components-react-native/
        // A la place de NativeView ils mettent le type du composant natif -> NSTStreetView
        // Attention aussi: j'ai du rajouter (NSTStreetView *) devant viewRegistry sinon Xcode me mettait une erreur Incompatible pointer types initializing 'NSTStreetView *' with an expression of type 'UIView * _Nullable'
        // C'est parce que je crée un pointeur de type NSTStreetView alors que viewRegistry[viewTag] renvoie une UIView
        // Donc je convertie en NSTStreetView qui est une sous classe de GMSPanoramaView qui doit etre lui-meme une subcalsse de UIView j'imagine
        // -> j'ai trouvé cet ex ici https://stackoverflow.com/questions/34108787/incompatible-pointer-types-initializing-uinavigationcontroller-with-an-expressio
        // mais il ne recommande pas de le faire il dit de faire différemment -> à revoir
        // mais bon pour le moment ca fonctionne
        // Finalement je ne rajoute plus (NSTStreetView *)
        // Mais dans la commande précédente j'ai remplacé le type de viewRegistry par NSTStreetView au lieu de UIView
        // Ca fonctionne mais je ne sais pas si c'est très juste de faire ça -> A revoir si besoin
        //NSTStreetView *view = (NSTStreetView *)viewRegistry[viewTag]; 
        NSTStreetView *view = viewRegistry[viewTag]; 
        if (!view || ![view isKindOfClass:[NSTStreetView class]]) { // Idem que ci-dessus: remplacer NativeView par NSTStreetView
            RCTLogError(@"Cannot find NativeView with tag #%@", viewTag);
            return;
        }
        
        //Convert NSNumbers to double
        //double pitchDouble = [pitch doubleValue];

        //view.camera = [GMSPanoramaCamera cameraWithHeading:100.0 pitch:pitchDouble zoom:1.0 FOV:90.0];
        // Appel de la fonction qui modifie le pitch afin de pouvoir la réunitiliser si besoin
        // Plutot que de faire la modif du pitch ici
        [self setFovCamera: view fov:fov];
        //[view callNativeMethod];
    }];

}

RCT_EXPORT_METHOD(setHeadingPitch:(nonnull NSNumber*) viewTag heading:(nonnull NSNumber *) heading pitch:(nonnull NSNumber *) pitch){
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,/*UIView*/ NSTStreetView *> *viewRegistry) {
        NSTStreetView *view = viewRegistry[viewTag]; 
        if (!view || ![view isKindOfClass:[NSTStreetView class]]) { // Idem que ci-dessus: remplacer NativeView par NSTStreetView
            RCTLogError(@"Cannot find NativeView with tag #%@", viewTag);
            return;
        }
        
        // appel à setHeadingPitchCamera
        [self setHeadingPitchCamera: view heading:heading pitch:pitch];
    }];

}

// Il existe aussi:
// RCT_REMAP_METHOD

// Modifie le pitch
// On passe la ref à NSTStreetView pour pouvoir faire des modifs
-(void) setFovCamera:(NSTStreetView *)panoramaView fov:(NSNumber*) fov{
    //Convert NSNumbers to double
    double fovDouble = [fov doubleValue];

    //printf("Camera Pitch %f", panoramaView.camera.orientation.pitch);
    panoramaView.camera = [GMSPanoramaCamera cameraWithHeading:panoramaView.camera.orientation.heading pitch:panoramaView.camera.orientation.pitch zoom:panoramaView.camera.zoom FOV:fovDouble];
}

// Modifie le pitch
// On passe la ref à NSTStreetView pour pouvoir faire des modifs
-(void) setHeadingPitchCamera:(NSTStreetView *)panoramaView heading:(NSNumber*) heading pitch:(NSNumber*) pitch{
    //Convert NSNumbers to double
    double headingDouble = [heading doubleValue];
    double pitchDouble = [pitch doubleValue];
    
    //printf("Camera Pitch %f", panoramaView.camera.orientation.pitch);
    panoramaView.camera = [GMSPanoramaCamera cameraWithHeading:headingDouble pitch:pitchDouble zoom:panoramaView.camera.zoom FOV:panoramaView.camera.FOV];

}

// Fonctions Events gérés par le Delegate
// NM Reprendre le meme nom que le delegate spécifié plus haut
#pragma mark GMSPanoramaViewDelegate 
// -> J'ai l'impression que c'est juste pour faire des indicateurs de séparation mais que ca ne sert à rien

// NM : https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_view#ae723a558a1a316f2502c11137767b947
// Quand moveNearCoordinate est exécuté, quand il y a une erreur panoramaView:error:onMoveNearCoordinate: will be sent.
// Donc cette fonction est exécutée uniquement en cas d'erreur
// Attention bien prendre NSTStreetView comme type pour panoramaView et pas GMSPanoramaView sinon je n'ai pas accès à mes fonctions passées en props
- (void)panoramaView:(NSTStreetView *)panoramaView error:(NSError *)error 
    onMoveNearCoordinate:(CLLocationCoordinate2D)coordinate {
    
    //printf ("panoramaView\n");

    // Retourne la nouvelle loc après avoir bougé s'il y a une erreur
    // -> Se produit quand on sélectionne une loc où StreetView n'est pas dispo par ex
    // cette loc est récupérée via onMoveNearCoordinate apparement
  
    // si on n'a pas de props onError en paramètre du composant on sort
    if(!panoramaView.onError) { // Modif NM
        return;
    }

    //printf ("panoramaView - OnError\n");
    
    /* NM Suprression
    NSNumber *lat = [[NSNumber alloc] initWithDouble:coordinate.latitude];
    NSNumber *lng = [[NSNumber alloc] initWithDouble:coordinate.longitude];

    // NM Il faut retourner un objet de type NSDictionary
    NSDictionary *coord = @{@"latitude":lat,@"longitude":lng};
    _onError(@{@"coordinate":coord});
    */
    
    // NM ajout pour faire comme dans la doc RN et en plus c'est plus simple
    // On retourne un objet de type NSDictionary
    // En fait on ne retourne rien, on exécute la fonction en paramètre je pense
    panoramaView.onError(@{
        @"coordinate":@{
            @"latitude": @(coordinate.latitude),
            @"longitude": @(coordinate.longitude)
        }
    });
}

// Appellé quand le render de la nouvelle loc est terminé
// Important, en fait ce n'est pas exactement c'est quand l'affichage à l'écran est terminé
// mais attention car la totalité de l'image n'est pas chargée, seule la partie affichée est chargée !!!
// Donc le fait de tourner la caméra sans changer de loc va générer plusieurs events
// Une fois qu'on a fait un 360° toutes les images sont chargés et l'event n'est plus déclenché
- (void)panoramaViewDidFinishRendering:(NSTStreetView *)panoramaView
{   
    //printf ("panoramaViewDidFinishRendering\n");

    // Bon j'ai supprimé onSuccess pour le remplacer par onLocationChange
    // Retourne la nouvelle loc après avoir bougé

    // si on n'a pas de props onLocationChange en paramètre du composant on sort
    if(!panoramaView.onLocationChange) { // Ajout NM
        return;
    }

    /*
    // si on n'a pas de props onSuccess en paramètre du composant on sort
    if(!panoramaView.onSuccess) { // Modif NM
        return;
    }
    */
    /* // NM suppression
    NSNumber *lat = [[NSNumber alloc] initWithDouble:panoramaView.panorama.coordinate.latitude];
    NSNumber *lng = [[NSNumber alloc] initWithDouble:panoramaView.panorama.coordinate.longitude];
    NSDictionary *coord = @{@"latitude":lat,@"longitude":lng};
    _onSuccess(@{@"coordinate":coord}); 
    */

    // NM ajout pour faire comme dans la doc RN et en plus c'est plus simple
    // On retourne un objet de type NSDictionary
    // En fait on ne retourne rien, on exécute la fonction en paramètre je pense
    
    /*
    panoramaView.onSuccess(@{
        @"coordinate":@{
            @"latitude": @(panoramaView.panorama.coordinate.latitude),
            @"longitude": @(panoramaView.panorama.coordinate.longitude)
        }
    });
    */

    // On retourne un objet de type NSDictionary
    // En fait on ne retourne rien, on exécute la fonction en paramètre je pense
    panoramaView.onLocationChange(@{
        @"coordinate":@{
            @"latitude": @(panoramaView.panorama.coordinate.latitude),
            @"longitude": @(panoramaView.panorama.coordinate.longitude)
        }
    });
}

// Il y a aussi:
// RCT_EXTERN_METHOD https://medium.com/@andrei.pfeiffer/react-natives-rct-extern-method-c61c17bf17b2


// Ajout NM
// Récupère les infos de la camera quand l'utilisateur bouge la camera
- (void)panoramaView:(NSTStreetView *)panoramaView didMoveCamera:(GMSPanoramaCamera *)camera
{   
    //printf ("Camera Zoom: %f", camera.zoom);
    //printf ("Camera Fov %f", camera.FOV);
     // si on n'a pas de props onSuccess en paramètre du composant on sort
    if(!panoramaView.onCameraChange) { // Modif NM
        return;
    }

    panoramaView.onCameraChange(@{
        @"cameraInfo":@{
            @"zoom": @(camera.zoom),
            @"fov": @(camera.FOV),
            @"orientation": @{
              @"heading": @(camera.orientation.heading),
              @"pitch": @(camera.orientation.pitch)
            }
        }
    });

    // On peut aussi utiliser NSDictionary
    /*    NSDictionary *cameraDict = @{
 			// @"orientation": @{
 			// 		@"heading":@(camera.orientation.heading),
 			// 		@"pitch":@(camera.orientation.pitch),
 			// },
 			@"heading":@(camera.orientation.heading),
 			@"pitch":@(camera.orientation.pitch),
 			@"FOV":@(camera.FOV),
 			@"zoom":@(camera.zoom)
 		};

 		_onDidMoveCamera(@{@"camera":cameraDict});
    */

}


@end
