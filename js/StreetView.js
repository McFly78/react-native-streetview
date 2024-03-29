//
//  StreetView.js
//  react-native-streetview
//
//  Created by Amit Palomo on 26/04/2017.
//  Copyright © 2017 Nester.co.il.
//

/* Doc StreetView:
https://developers.google.com/maps/documentation/ios-sdk/streetview#maps_ios_streetview_add-objective-c
https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_view#ac1b66bc8c3728bbf90b5009940cc9040
https://developers.google.com/maps/documentation/ios-sdk/reference/protocol_g_m_s_panorama_view_delegate-p
https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama
https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_camera
https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_camera_update
https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_service
https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_link
https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_layer


*/
import React from 'react';
import PropTypes from 'prop-types';
import { View, requireNativeComponent } from 'react-native';

import { NativeModules } from "react-native";
import {
	//requireNativeComponent,
	UIManager,
	//ReactNative,
	findNodeHandle
  } from "react-native";

// NM important
// Si besoin que la modif des props coordinate ou pov n'entraine pas de refresh
// je pourrais aussi ajouter des props initialCoordinate et initialPov
// Voir exemple dans react-native-maps pour intialRegion dans react-native-maps/ios/AirMaps/AIRMap.m
// Il utilisent une variable _initialRegionSet pour ne l'utiliser qu'à l'initialisation.
const propTypes = {
	...View.propTypes,

	// Center point
	coordinate: PropTypes.shape({
	   latitude: PropTypes.number.isRequired,
	   longitude: PropTypes.number.isRequired,
	   // Search radius (meters) around coordinate.
	   //radius: PropTypes.number,
	}),

	radius: PropTypes.number, // Ajout -> spécifie le rayon de recherche des Panorama street view autour de la loc spécifié -> le plus proche est utilisé

	pov: PropTypes.shape({
	   tilt: PropTypes.number.isRequired,
	   bearing: PropTypes.number.isRequired,
	   zoom: PropTypes.number.isRequired,
	   fov: PropTypes.number,
	}),

	// Allowing user gestures (panning, zooming)
	allGesturesEnabled: PropTypes.bool,
	// NM: bizzarre que ca fonctionne alors que ce n'est meme pas une propriété mais une fonction dans la doc Google Street View !!!!
	// C'est peut etre un attribut deprecated mais qui fonctionne encore ???
	// Tres louche, si ca se trouve ca pose pb de l'utiliser

	zoomEnabled: PropTypes.bool, // NM ajout pour autoriser ou pas l'utilisateur à zoomer

	streetNamesHidden: PropTypes.bool,

	heading: PropTypes.number,

	// Functions
	onError: PropTypes.func,
	onSuccess: PropTypes.func
};

class StreetView extends React.PureComponent {

	constructor(props) {
		super(props);

		this.refStreetMap = React.createRef()
	}

	// NM ajout
	// Sinon dans le parent qui appelle le composant on doit extraire event.nativeEvent
	// C'est mieux de le gérer ici
	// Et ce qu'ils font dans la doc RN
	_onSuccess = event => {
		// On teste si on a une props onSuccess
		if (!this.props.onSuccess) {
			return;
		}

		// process raw event...
		this.props.onSuccess(event.nativeEvent);
	};

	_onError = event => {
		if (!this.props.onError) {
			return;
		}

		// process raw event...
		this.props.onError(event.nativeEvent);
	};

	_onCameraChange = event => {
		if (!this.props.onCameraChange) {
			return;
		}

		// process raw event...
		this.props.onCameraChange(event.nativeEvent);
	};

	_onLocationChange = event => {
		if (!this.props.onLocationChange ) {
			return;
		}

		// process raw event...
		this.props.onLocationChange(event.nativeEvent);
	};

	// NOK -> voir _setFov pour la solution
	_updatePitch(pitch){
		// TESTER aussi de rajouter une ref à <updatePitch
		//this.refStreetMap.current.updatePitch (pitch)
		NativeModules.NSTStreetView.updatePitch (pitch)
		//NativeModules.NSTStreetView.updatePitch (ReactNative.findNodeHandle(this.refStreetMap.current),pitch)
		// -> Voir ici pour voir comment indiquer quelle instance de StreetView utiliser si on en a plusieurs
		// https://reactnative.dev/docs/native-components-ios
		//NativeModules.TestView.testMethod(findNodeHandle(testRef.current), 'Hello World')
		// -> https://susuthapa19961227.medium.com/bridging-the-gap-how-to-call-native-component-functions-from-reactnative-a8d212588b72
		//console.log ("_updatePitch")
	}

	// Appel fonction native
	// Pour modifier le Fov de la camera
	_setFov = (fov) => {
		// https://teabreak.e-spres-oh.com/swift-in-react-native-the-ultimate-guide-part-2-ui-components-907767123d9e
		// Here you are telling React Native’s UIManager to dispatch a command to the ViewManager
		// the first argument is the node handle that you need to pass to your native method from the ViewManager. You have to use findNodeHandle and pass it the reference of your component; -> (nonnull NSNumber \*)reactTag  -  id of react view
		// the second is the method you have exposed on your ViewManager; -> commandID:(NSInteger)commandID  -  Id of the native method that should be called
		// the third and last one is just an array of arguments -> commandArgs:(NSArray<id> \*)commandArgs  -  Args of the native method that we can pass from JS to native.
		UIManager.dispatchViewManagerCommand(
		  /*ReactNative.*/findNodeHandle(this), // ou this.refStreetMap ???
		  UIManager.getViewManagerConfig('NSTStreetView').Commands.setFov,
		  [fov], // Liste des arguments
		);
	}

	// Pour modifier le Heading et le pitch de la camera
	_setHeadingPitch = (heading, pitch) => {
		// https://teabreak.e-spres-oh.com/swift-in-react-native-the-ultimate-guide-part-2-ui-components-907767123d9e
		// Here you are telling React Native’s UIManager to dispatch a command to the ViewManager
		// the first argument is the node handle that you need to pass to your native method from the ViewManager. You have to use findNodeHandle and pass it the reference of your component; -> (nonnull NSNumber \*)reactTag  -  id of react view
		// the second is the method you have exposed on your ViewManager; -> commandID:(NSInteger)commandID  -  Id of the native method that should be called
		// the third and last one is just an array of arguments -> commandArgs:(NSArray<id> \*)commandArgs  -  Args of the native method that we can pass from JS to native.
		UIManager.dispatchViewManagerCommand(
		  /*ReactNative.*/findNodeHandle(this), // ou this.refStreetMap ???
		  UIManager.getViewManagerConfig('NSTStreetView').Commands.setHeadingPitch,
		  [heading, pitch], // Liste des arguments
		);
	}



	_isStreetViewAvailable(localisation){
		//console.log ("StreetView.js: _isStreetViewAvailable")
		NativeModules.NSTStreetView.isStreetViewAvailable (localisation)
	}


	render() {
		return (
		<NSTStreetView 
			{...this.props} 
			ref={this.refStreetMap}// NM ajout pour appeller des fonctions
			//onSuccess={this._onSuccess} // NM ajout // NM remplacé par _onLocationChange
			onError={this._onError} // NM ajout
			onCameraChange={this._onCameraChange} // NM ajout
			onLocationChange={this._onLocationChange} // NM ajout
			
		/>
		)
	}
}

StreetView.propTypes = propTypes;

// NM Suppression
/*
const cfg = {
    nativeOnly: {
        onError: true,
        onSuccess: true,
    }
};
*/

//module.exports = requireNativeComponent('NSTStreetView', StreetView, cfg);

// NM: requireNativeComponent automatically resolves 'NSTStreetView' to 'NSTStreetViewManager'
// supression de cfg nativeOnly car n'est pas utile:
// https://archive-reactnative-dev.translate.goog/docs/0.8/native-components-ios?_x_tr_sch=http&_x_tr_sl=en&_x_tr_tl=fr&_x_tr_hl=fr&_x_tr_pto=sc
// https://github.com/facebook/react-native/issues/28351
// Sometimes your native component will have some reserved properties that you don't want to be part of the API for the associated React component. For example, Switch has a custom onChange handler for the raw native event, and exposes an onValueChange handler property that is invoked with the boolean value rather than the raw event. Since you don't want these native only properties to be part of the API, you don't want to put them in propTypes, but if you don't you'll get an error. The solution is to add them to the nativeOnly option, e.g.
// Ex:
//  var RCTSwitch = requireNativeComponent('RCTSwitch', Switch, {
//  nativeOnly: { onChange: true }
//});
// En plus il y avait une erreur car c'est pas StreetView qui était exporté mais NSTStreetView !!!!
// -> Bizzare dans la doc explicative c'est pas exactement pareil:
// Est-que le fait de passer plusieurs paramètres est équivalent ?
// https://reactnative.dev/docs/native-components-ios
// const RNTMap = requireNativeComponent('RNTMap');
// module.exports = MapView;
//
// Depuis que j'ai fait cette modif je reçoit le message "Tried to register two views with the same name NSTStreetView" à chaque fois que je sauvegarde ce fichier
// ils en parlent ici: https://stackoverflow.com/questions/46613149/tried-to-register-two-views-with-the-same-name-progressbarandroid
// Ils disent que ce n'est pas grave: je n'ai pas utilisé leur workaround qui necessite de créer un composant intermédaire dans un autre fichier le lequel on fait fichier supplémentaire pour 
const NSTStreetView= requireNativeComponent('NSTStreetView', null);
module.exports = StreetView;
// -> je ne sais pas c'est quoi la différence avec la ligne suivante qui fonctionne aussi !
//export default StreetView
