//
//  NSTStreetView.h
//  NSTStreetview
//
//  Copyright © 2019 Nester. All rights reserved.
//

#import <Foundation/Foundation.h> //Suppression NM
// https://www.tutorialspoint.com/objective_c/objective_c_foundation_framework.htm 
// https://developer.apple.com/documentation/foundation?language=objc
// -> En fait bizazrre j'ai l'impression qu'il le faut mais ca marche sans donc ???

//#import <React/RCTViewManager.h> // NM Suppression
#import <React/RCTComponent.h> // NM ajout
//#import "StreetView.h" // Dans la doc Google il y a ca aussi mais ca fonctionne sans et si je l'importe il me dit qu'il ne trouve pas le fichier !!!???


@import GoogleMaps;
// NM: on déclare NSTStreetView comme étant une sous classe de GMSPanoramaView 
// Ca permet de pouvoir rajouter mes propres fonctions passées en props car on ne peut pas en rajouter directement à GMSPanoramaView
// NM Modifs suppresion de la déclaration du delegate -> transféré dans NSTStreetViewManager.m car je gère les events du delegate dans NSTStreetViewManager.m et plus dans NSTStreetView.m
// -> Pour avoir la meme conf que dans la doc RN
//@interface NSTStreetView : GMSPanoramaView <GMSPanoramaViewDelegate>
@interface NSTStreetView : GMSPanoramaView

// On rajoute ici des propriétés à la sous-classe NSTStreetView pour nos propres besoins
// On peut rajouter des variables et des fonctions
// NM Gestion des Events passés en props
// https://reactnative.dev/docs/native-components-ios#events
// Attention cans cette doc, ils disent qu'on doit préfixer tous les event par on...
@property (nonatomic,copy) RCTDirectEventBlock onError;
//@property (nonatomic,copy) RCTDirectEventBlock onSuccess; // NM remplacé par _onLocationChange
@property (nonatomic,copy) RCTBubblingEventBlock onCameraChange; // NM ajout -> J'ai utilisé RCTBubblingEventBlock car dans React-native-maps c'est ce qu'ils ont utilisé pour ce type d'event. J'ai pas compris la diiféérence avec RCTDirectEventBlock
@property (nonatomic,copy) RCTBubblingEventBlock onLocationChange; // NM ajout

// Attention pour rajouter des propriétés qui ne sont pas des fonctions il faut préciser assign et non copy
// J'ai trouvé l'info dans Airmap.h de react-native-maps
// Je rajoute une propriété radius pour stocker le radius passé en props
@property (nonatomic,assign) double radius;

// https://blog.logrocket.com/build-native-ui-components-react-native
// ici ils déclarent aussi des property de type
// @property (strong, nullable) ... -> je ne connait pas la différence
@end
